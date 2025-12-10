#!/bin/bash

# Script đo mức sử dụng RAM và CPU khi idle và khi có tải
# Sử dụng: ./measure_resource_usage.sh [docker|vm] [duration_seconds]

MODE=${1:-docker}
DURATION=${2:-60}  # Mặc định đo trong 60 giây
RESULTS_DIR="measurement_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${RESULTS_DIR}/resource_usage_${MODE}_${TIMESTAMP}.txt"
CSV_FILE="${RESULTS_DIR}/resource_usage_${MODE}_${TIMESTAMP}.csv"

mkdir -p ${RESULTS_DIR}

echo "=== Đo mức sử dụng RAM và CPU - Mode: ${MODE} ===" | tee ${OUTPUT_FILE}
echo "Thời gian đo: ${DURATION} giây" | tee -a ${OUTPUT_FILE}
echo "Thời gian bắt đầu: $(date)" | tee -a ${OUTPUT_FILE}
echo "" | tee -a ${OUTPUT_FILE}

# Tạo file CSV header
echo "timestamp,cpu_percent,memory_mb,memory_percent" > ${CSV_FILE}

if [ "$MODE" = "docker" ]; then
    echo "--- Đo tài nguyên Docker Container ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Đảm bảo container đang chạy
    if ! docker ps | grep -q exam-grading; then
        echo "Khởi động container..." | tee -a ${OUTPUT_FILE}
        docker-compose up -d
        sleep 10
    fi
    
    CONTAINER_NAMES=("exam-grading-app" "exam-grading-nginx")
    
    echo "Đang đo trong ${DURATION} giây..." | tee -a ${OUTPUT_FILE}
    echo "Timestamp,Container,CPU %,Memory (MB),Memory %" | tee -a ${OUTPUT_FILE}
    
    START_TIME=$(date +%s)
    END_TIME=$((START_TIME + DURATION))
    
    while [ $(date +%s) -lt $END_TIME ]; do
        TIMESTAMP_NOW=$(date +%Y-%m-%d\ %H:%M:%S)
        for CONTAINER in "${CONTAINER_NAMES[@]}"; do
            STATS=$(docker stats --no-stream --format "{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}}" ${CONTAINER} 2>/dev/null)
            if [ -n "$STATS" ]; then
                CPU=$(echo $STATS | cut -d',' -f1 | sed 's/%//')
                MEM_USAGE=$(echo $STATS | cut -d',' -f2 | cut -d'/' -f1 | sed 's/MiB//' | xargs)
                MEM_PERC=$(echo $STATS | cut -d',' -f3 | sed 's/%//')
                echo "$TIMESTAMP_NOW,$CONTAINER,$CPU,$MEM_USAGE,$MEM_PERC" | tee -a ${OUTPUT_FILE}
                echo "$(date +%s),$CPU,$MEM_USAGE,$MEM_PERC" >> ${CSV_FILE}
            fi
        done
        sleep 1
    done
    
    echo "" | tee -a ${OUTPUT_FILE}
    echo "--- Thống kê tổng hợp ---" | tee -a ${OUTPUT_FILE}
    
    # Tính toán thống kê từ CSV
    for CONTAINER in "${CONTAINER_NAMES[@]}"; do
        echo "" | tee -a ${OUTPUT_FILE}
        echo "Container: $CONTAINER" | tee -a ${OUTPUT_FILE}
        # Có thể thêm tính toán thống kê ở đây
    done
    
elif [ "$MODE" = "vm" ]; then
    echo "--- Đo tài nguyên VM ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    echo "Đang đo trong ${DURATION} giây..." | tee -a ${OUTPUT_FILE}
    echo "Timestamp,CPU %,Memory (MB),Memory %" | tee -a ${OUTPUT_FILE}
    
    START_TIME=$(date +%s)
    END_TIME=$((START_TIME + DURATION))
    
    while [ $(date +%s) -lt $END_TIME ]; do
        TIMESTAMP_NOW=$(date +%Y-%m-%d\ %H:%M:%S)
        
        # Đo từ bên trong VM qua SSH hoặc từ host nếu có công cụ
        # Giả sử có thể SSH vào VM
        CPU=$(ssh user@vm_ip "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{print 100 - \$1}'" 2>/dev/null)
        MEM=$(ssh user@vm_ip "free -m | grep Mem | awk '{print \$3}'" 2>/dev/null)
        MEM_TOTAL=$(ssh user@vm_ip "free -m | grep Mem | awk '{print \$2}'" 2>/dev/null)
        MEM_PERC=$(echo "scale=2; $MEM * 100 / $MEM_TOTAL" | bc)
        
        echo "$TIMESTAMP_NOW,$CPU,$MEM,$MEM_PERC" | tee -a ${OUTPUT_FILE}
        echo "$(date +%s),$CPU,$MEM,$MEM_PERC" >> ${CSV_FILE}
        
        sleep 1
    done
fi

echo "" | tee -a ${OUTPUT_FILE}
echo "Kết quả đã được lưu vào:" | tee -a ${OUTPUT_FILE}
echo "  - Text: ${OUTPUT_FILE}" | tee -a ${OUTPUT_FILE}
echo "  - CSV: ${CSV_FILE}" | tee -a ${OUTPUT_FILE}
echo "Thời gian kết thúc: $(date)" | tee -a ${OUTPUT_FILE}


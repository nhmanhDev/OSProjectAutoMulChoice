#!/bin/bash

# Script đo mức sử dụng RAM và CPU từ BÊN TRONG VM/Docker
# Sử dụng: ./measure_resource_usage_internal.sh [docker|vm] [duration_seconds]

MODE=${1:-docker}
DURATION=${2:-60}  # Mặc định đo trong 60 giây
# Script đang nằm trong measurement_results
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Lưu kết quả vào folder tương ứng
if [ "$MODE" = "docker" ]; then
    OUTPUT_DIR="${RESULTS_DIR}/docker"
else
    OUTPUT_DIR="${RESULTS_DIR}/VM"
fi

mkdir -p ${OUTPUT_DIR}
OUTPUT_FILE="${OUTPUT_DIR}/resource_usage_internal_${TIMESTAMP}.txt"
CSV_FILE="${OUTPUT_DIR}/resource_usage_internal_${TIMESTAMP}.csv"

echo "=== Đo mức sử dụng RAM và CPU từ BÊN TRONG - Mode: ${MODE} ===" | tee ${OUTPUT_FILE}
echo "Thời gian đo: ${DURATION} giây" | tee -a ${OUTPUT_FILE}
echo "Thời gian bắt đầu: $(date)" | tee -a ${OUTPUT_FILE}
echo "" | tee -a ${OUTPUT_FILE}

# Tạo file CSV header
echo "timestamp,cpu_percent,memory_mb,memory_percent" > ${CSV_FILE}

if [ "$MODE" = "docker" ]; then
    echo "--- Đo tài nguyên từ BÊN TRONG Docker Container ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Đảm bảo container đang chạy
    CONTAINER_NAME="exam-automated-app"
    if ! docker ps 2>/dev/null | grep -q "$CONTAINER_NAME"; then
        echo "Container không đang chạy. Khởi động container..." | tee -a ${OUTPUT_FILE}
        docker compose -f "$PARENT_DIR/deployment/docker-compose.yml" up -d 2>&1 | tee -a ${OUTPUT_FILE}
        sleep 10
    fi
    
    echo "Đang đo từ BÊN TRONG container trong ${DURATION} giây..." | tee -a ${OUTPUT_FILE}
    echo "Timestamp,CPU %,Memory (MB),Memory %" | tee -a ${OUTPUT_FILE}
    
    START_TIME=$(date +%s)
    END_TIME=$((START_TIME + DURATION))
    
    while [ $(date +%s) -lt $END_TIME ]; do
        TIMESTAMP_NOW=$(date +%Y-%m-%d\ %H:%M:%S)
        
        # Đo từ bên trong container
        STATS=$(docker exec $CONTAINER_NAME sh -c "top -bn1 | grep -E '^%Cpu|^Mem|^Swap' | head -3" 2>/dev/null)
        
        if [ -n "$STATS" ]; then
            # Parse CPU usage
            CPU=$(echo "$STATS" | grep "%Cpu" | awk '{print $2}' | sed 's/%us,//' | awk '{print $1}')
            
            # Parse Memory
            MEM_LINE=$(echo "$STATS" | grep "^Mem")
            MEM_TOTAL=$(echo "$MEM_LINE" | awk '{print $2}' | sed 's/[^0-9]//g')
            MEM_USED=$(echo "$MEM_LINE" | awk '{print $4}' | sed 's/[^0-9]//g')
            
            # Convert từ KB sang MB
            if [ -n "$MEM_TOTAL" ] && [ "$MEM_TOTAL" != "0" ]; then
                MEM_TOTAL_MB=$(awk "BEGIN {printf \"%.2f\", $MEM_TOTAL / 1024}")
                MEM_USED_MB=$(awk "BEGIN {printf \"%.2f\", $MEM_USED / 1024}")
                MEM_PERC=$(awk "BEGIN {printf \"%.2f\", ($MEM_USED / $MEM_TOTAL) * 100}")
            else
                MEM_USED_MB="0"
                MEM_PERC="0"
            fi
            
            echo "$TIMESTAMP_NOW,$CPU,$MEM_USED_MB,$MEM_PERC" | tee -a ${OUTPUT_FILE}
            echo "$(date +%s),$CPU,$MEM_USED_MB,$MEM_PERC" >> ${CSV_FILE}
        else
            # Fallback: dùng docker stats
            STATS_FALLBACK=$(docker stats --no-stream --format "{{.CPUPerc}},{{.MemUsage}}" $CONTAINER_NAME 2>/dev/null)
            if [ -n "$STATS_FALLBACK" ]; then
                CPU=$(echo $STATS_FALLBACK | cut -d',' -f1 | sed 's/%//')
                MEM_USAGE=$(echo $STATS_FALLBACK | cut -d',' -f2 | cut -d'/' -f1 | sed 's/MiB//' | xargs)
                MEM_PERC=$(echo $STATS_FALLBACK | cut -d',' -f2 | cut -d'/' -f2 | sed 's/MiB//' | xargs | awk '{print $1}')
                echo "$TIMESTAMP_NOW,$CPU,$MEM_USAGE,$MEM_PERC" | tee -a ${OUTPUT_FILE}
                echo "$(date +%s),$CPU,$MEM_USAGE,$MEM_PERC" >> ${CSV_FILE}
            fi
        fi
        
        sleep 1
    done
    
elif [ "$MODE" = "vm" ]; then
    echo "--- Đo tài nguyên từ BÊN TRONG VM ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Cấu hình SSH
    VM_SSH=${VM_SSH:-"vm-ubuntu"}
    VM_SSH_PORT=${VM_SSH_PORT:-"2222"}
    
    if [ "$VM_SSH" = "vm-ubuntu" ]; then
        SSH_CMD="ssh vm-ubuntu"
    else
        SSH_CMD="ssh -p ${VM_SSH_PORT} -o StrictHostKeyChecking=no ${VM_SSH}"
    fi
    
    echo "SSH connection: ${VM_SSH}" | tee -a ${OUTPUT_FILE}
    echo "Đang đo từ BÊN TRONG VM trong ${DURATION} giây..." | tee -a ${OUTPUT_FILE}
    echo "Timestamp,CPU %,Memory (MB),Memory %" | tee -a ${OUTPUT_FILE}
    
    START_TIME=$(date +%s)
    END_TIME=$((START_TIME + DURATION))
    
    while [ $(date +%s) -lt $END_TIME ]; do
        TIMESTAMP_NOW=$(date +%Y-%m-%d\ %H:%M:%S)
        
        # Đo từ bên trong VM qua SSH
        CPU=$($SSH_CMD "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{print 100 - \$1}'" 2>/dev/null)
        MEM=$($SSH_CMD "free -m | grep Mem | awk '{print \$3}'" 2>/dev/null)
        MEM_TOTAL=$($SSH_CMD "free -m | grep Mem | awk '{print \$2}'" 2>/dev/null)
        
        if [ -n "$MEM" ] && [ -n "$MEM_TOTAL" ] && [ "$MEM_TOTAL" != "0" ]; then
            MEM_PERC=$(awk "BEGIN {printf \"%.2f\", ($MEM * 100) / $MEM_TOTAL}")
        else
            MEM="0"
            MEM_PERC="0"
        fi
        
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


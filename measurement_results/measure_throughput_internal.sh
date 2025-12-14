#!/bin/bash

# Script đo thông lượng từ BÊN TRONG VM/Docker
# Sử dụng: ./measure_throughput_internal.sh [docker|vm] [tool] [concurrent] [requests]

MODE=${1:-docker}
TOOL=${2:-ab}  # ab hoặc wrk
CONCURRENT=${3:-10}
REQUESTS=${4:-1000}
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
OUTPUT_FILE="${OUTPUT_DIR}/throughput_internal_${TOOL}_${TIMESTAMP}.txt"

echo "=== Đo thông lượng từ BÊN TRONG - Mode: ${MODE} ===" | tee ${OUTPUT_FILE}
echo "Tool: ${TOOL}" | tee -a ${OUTPUT_FILE}
echo "Concurrent requests: ${CONCURRENT}" | tee -a ${OUTPUT_FILE}
echo "Total requests: ${REQUESTS}" | tee -a ${OUTPUT_FILE}
echo "Thời gian bắt đầu: $(date)" | tee -a ${OUTPUT_FILE}
echo "" | tee -a ${OUTPUT_FILE}

# URL để test (từ bên trong, dùng localhost)
URL="http://localhost/"

echo "Testing URL: ${URL} (từ bên trong)" | tee -a ${OUTPUT_FILE}
echo "" | tee -a ${OUTPUT_FILE}

if [ "$MODE" = "docker" ]; then
    CONTAINER_NAME="exam-automated-app"
    if ! docker ps 2>/dev/null | grep -q "$CONTAINER_NAME"; then
        echo "Container không đang chạy. Khởi động container..." | tee -a ${OUTPUT_FILE}
        docker compose -f "$PARENT_DIR/deployment/docker-compose.yml" up -d 2>&1 | tee -a ${OUTPUT_FILE}
        sleep 5
    fi
    
    if [ "$TOOL" = "ab" ]; then
        echo "--- Chạy Apache Bench từ BÊN TRONG container ---" | tee -a ${OUTPUT_FILE}
        echo "" | tee -a ${OUTPUT_FILE}
        
        # Kiểm tra ab có trong container không
        if docker exec $CONTAINER_NAME which ab >/dev/null 2>&1; then
            docker exec $CONTAINER_NAME ab -n ${REQUESTS} -c ${CONCURRENT} ${URL} 2>&1 | tee -a ${OUTPUT_FILE}
        else
            echo "⚠️  ab không có trong container. Cài đặt hoặc dùng tool khác." | tee -a ${OUTPUT_FILE}
        fi
    elif [ "$TOOL" = "wrk" ]; then
        echo "--- Chạy wrk từ BÊN TRONG container ---" | tee -a ${OUTPUT_FILE}
        if docker exec $CONTAINER_NAME which wrk >/dev/null 2>&1; then
            docker exec $CONTAINER_NAME wrk -t4 -c${CONCURRENT} -d30s ${URL} 2>&1 | tee -a ${OUTPUT_FILE}
        else
            echo "⚠️  wrk không có trong container." | tee -a ${OUTPUT_FILE}
        fi
    fi
    
elif [ "$MODE" = "vm" ]; then
    # Cấu hình SSH
    VM_SSH=${VM_SSH:-"vm-ubuntu"}
    VM_SSH_PORT=${VM_SSH_PORT:-"2222"}
    
    if [ "$VM_SSH" = "vm-ubuntu" ]; then
        SSH_CMD="ssh vm-ubuntu"
    else
        SSH_CMD="ssh -p ${VM_SSH_PORT} -o StrictHostKeyChecking=no ${VM_SSH}"
    fi
    
    if [ "$TOOL" = "ab" ]; then
        echo "--- Chạy Apache Bench từ BÊN TRONG VM ---" | tee -a ${OUTPUT_FILE}
        echo "" | tee -a ${OUTPUT_FILE}
        
        # Kiểm tra ab có trong VM không
        if $SSH_CMD "which ab >/dev/null 2>&1"; then
            $SSH_CMD "ab -n ${REQUESTS} -c ${CONCURRENT} ${URL}" 2>&1 | tee -a ${OUTPUT_FILE}
        else
            echo "⚠️  ab không có trong VM. Cài đặt: sudo apt-get install apache2-utils" | tee -a ${OUTPUT_FILE}
        fi
    elif [ "$TOOL" = "wrk" ]; then
        echo "--- Chạy wrk từ BÊN TRONG VM ---" | tee -a ${OUTPUT_FILE}
        if $SSH_CMD "which wrk >/dev/null 2>&1"; then
            $SSH_CMD "wrk -t4 -c${CONCURRENT} -d30s ${URL}" 2>&1 | tee -a ${OUTPUT_FILE}
        else
            echo "⚠️  wrk không có trong VM." | tee -a ${OUTPUT_FILE}
        fi
    fi
fi

echo "" | tee -a ${OUTPUT_FILE}
echo "Kết quả đã được lưu vào: ${OUTPUT_FILE}" | tee -a ${OUTPUT_FILE}
echo "Thời gian kết thúc: $(date)" | tee -a ${OUTPUT_FILE}


#!/bin/bash

# Script đo dung lượng đĩa từ BÊN TRONG VM/Docker
# Sử dụng: ./measure_disk_usage_internal.sh [docker|vm]

MODE=${1:-docker}
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
OUTPUT_FILE="${OUTPUT_DIR}/disk_usage_internal_${TIMESTAMP}.txt"

echo "=== Đo dung lượng đĩa từ BÊN TRONG - Mode: ${MODE} ===" | tee ${OUTPUT_FILE}
echo "Thời gian: $(date)" | tee -a ${OUTPUT_FILE}
echo "" | tee -a ${OUTPUT_FILE}

if [ "$MODE" = "docker" ]; then
    echo "--- Dung lượng đĩa từ BÊN TRONG Docker Container ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    CONTAINER_NAME="exam-automated-app"
    if ! docker ps 2>/dev/null | grep -q "$CONTAINER_NAME"; then
        echo "Container không đang chạy. Khởi động container..." | tee -a ${OUTPUT_FILE}
        docker compose -f "$PARENT_DIR/deployment/docker-compose.yml" up -d 2>&1 | tee -a ${OUTPUT_FILE}
        sleep 5
    fi
    
    echo "1. Disk usage tổng thể (từ bên trong container):" | tee -a ${OUTPUT_FILE}
    docker exec $CONTAINER_NAME df -h 2>/dev/null | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    echo "2. Dung lượng thư mục ứng dụng:" | tee -a ${OUTPUT_FILE}
    docker exec $CONTAINER_NAME du -sh /app 2>/dev/null | tee -a ${OUTPUT_FILE}
    docker exec $CONTAINER_NAME du -sh /app/* 2>/dev/null | sort -h | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    echo "3. Dung lượng thư mục frontend:" | tee -a ${OUTPUT_FILE}
    docker exec $CONTAINER_NAME du -sh /app/frontend/dist 2>/dev/null | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    echo "4. Tổng dung lượng container filesystem:" | tee -a ${OUTPUT_FILE}
    docker exec $CONTAINER_NAME sh -c "df -h / | tail -1" 2>/dev/null | tee -a ${OUTPUT_FILE}
    
elif [ "$MODE" = "vm" ]; then
    echo "--- Dung lượng đĩa từ BÊN TRONG VM ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Cấu hình SSH
    VM_SSH=${VM_SSH:-"vm-ubuntu"}
    VM_SSH_PORT=${VM_SSH_PORT:-"2222"}
    
    if [ "$VM_SSH" = "vm-ubuntu" ]; then
        SSH_CMD="ssh vm-ubuntu"
    else
        SSH_CMD="ssh -p ${VM_SSH_PORT} -o StrictHostKeyChecking=no ${VM_SSH}"
    fi
    
    echo "1. Disk usage tổng thể (từ bên trong VM):" | tee -a ${OUTPUT_FILE}
    $SSH_CMD "df -h" 2>/dev/null | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    echo "2. Dung lượng thư mục ứng dụng:" | tee -a ${OUTPUT_FILE}
    APP_DIR=$($SSH_CMD "find /home /opt /var -name '*exam*' -type d 2>/dev/null | head -1" 2>/dev/null)
    if [ -z "$APP_DIR" ]; then
        APP_DIR="/opt/exam-automated"
    fi
    
    $SSH_CMD "du -sh $APP_DIR 2>/dev/null" | tee -a ${OUTPUT_FILE}
    $SSH_CMD "du -sh $APP_DIR/* 2>/dev/null | sort -h" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    echo "3. Dung lượng root filesystem:" | tee -a ${OUTPUT_FILE}
    $SSH_CMD "df -h /" 2>/dev/null | tee -a ${OUTPUT_FILE}
fi

echo "" | tee -a ${OUTPUT_FILE}
echo "Kết quả đã được lưu vào: ${OUTPUT_FILE}" | tee -a ${OUTPUT_FILE}


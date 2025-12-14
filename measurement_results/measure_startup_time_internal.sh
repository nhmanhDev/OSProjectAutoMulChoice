#!/bin/bash

# Script đo thời gian khởi động từ BÊN TRONG VM/Docker
# Sử dụng: ./measure_startup_time_internal.sh [docker|vm]

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
OUTPUT_FILE="${OUTPUT_DIR}/startup_time_internal_${TIMESTAMP}.txt"
CSV_FILE="${OUTPUT_DIR}/startup_time_internal_${TIMESTAMP}.csv"

echo "=== Đo thời gian khởi động từ BÊN TRONG - Mode: ${MODE} ===" | tee ${OUTPUT_FILE}
echo "Thời gian bắt đầu: $(date)" | tee -a ${OUTPUT_FILE}
echo "" | tee -a ${OUTPUT_FILE}

# Tạo CSV header
echo "metric,time_seconds,time_milliseconds" > ${CSV_FILE}

# Hàm tính toán thời gian
calc_time() {
    local start=$1
    local end=$2
    awk "BEGIN {printf \"%.6f\", $end - $start}"
}

get_timestamp() {
    date +%s.%N 2>/dev/null || date +%s
}

if [ "$MODE" = "docker" ]; then
    echo "--- Đo thời gian khởi động từ BÊN TRONG Docker Container ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    CONTAINER_NAME="exam-automated-app"
    
    # Dừng container nếu đang chạy
    echo "Dừng container hiện tại (nếu có)..." | tee -a ${OUTPUT_FILE}
    docker stop $CONTAINER_NAME >/dev/null 2>&1 || true
    sleep 2
    
    # Đo thời gian start container
    echo "1. Đo thời gian start container..." | tee -a ${OUTPUT_FILE}
    START_START=$(get_timestamp)
    docker start $CONTAINER_NAME 2>&1 | tee -a ${OUTPUT_FILE}
    END_START=$(get_timestamp)
    START_TIME=$(calc_time $START_START $END_START)
    START_TIME_MS=$(awk "BEGIN {printf \"%.0f\", $START_TIME * 1000}")
    echo "Thời gian start: ${START_TIME} giây (${START_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
    echo "start,${START_TIME},${START_TIME_MS}" >> ${CSV_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Đợi service sẵn sàng (từ bên trong container)
    echo "2. Đợi service sẵn sàng (từ bên trong container)..." | tee -a ${OUTPUT_FILE}
    START_READY=$(get_timestamp)
    MAX_WAIT=60
    ELAPSED=0
    
    while awk "BEGIN {exit !($ELAPSED < $MAX_WAIT)}"; do
        # Kiểm tra từ bên trong container
        if docker exec $CONTAINER_NAME curl -sf http://localhost:8000/health >/dev/null 2>&1 || \
           docker exec $CONTAINER_NAME curl -sf http://localhost/health >/dev/null 2>&1; then
            END_READY=$(get_timestamp)
            READY_TIME=$(calc_time $START_READY $END_READY)
            READY_TIME_MS=$(awk "BEGIN {printf \"%.0f\", $READY_TIME * 1000}")
            echo "Service ready sau: ${READY_TIME} giây (${READY_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
            echo "ready,${READY_TIME},${READY_TIME_MS}" >> ${CSV_FILE}
            break
        fi
        sleep 0.5
        ELAPSED=$(awk "BEGIN {printf \"%.1f\", $ELAPSED + 0.5}")
    done
    
    if awk "BEGIN {exit !($ELAPSED >= $MAX_WAIT)}"; then
        echo "⚠️  Service không sẵn sàng sau ${MAX_WAIT} giây" | tee -a ${OUTPUT_FILE}
    fi
    
elif [ "$MODE" = "vm" ]; then
    echo "--- Đo thời gian khởi động từ BÊN TRONG VM ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Cấu hình SSH
    VM_SSH=${VM_SSH:-"vm-ubuntu"}
    VM_SSH_PORT=${VM_SSH_PORT:-"2222"}
    
    if [ "$VM_SSH" = "vm-ubuntu" ]; then
        SSH_CMD="ssh vm-ubuntu"
    else
        SSH_CMD="ssh -p ${VM_SSH_PORT} -o StrictHostKeyChecking=no ${VM_SSH}"
    fi
    
    # Dừng service nếu đang chạy
    echo "Dừng service hiện tại (nếu có)..." | tee -a ${OUTPUT_FILE}
    $SSH_CMD "sudo systemctl stop exam-automated" 2>&1 | tee -a ${OUTPUT_FILE} || true
    sleep 2
    
    # Đo thời gian start service
    echo "1. Đo thời gian start service..." | tee -a ${OUTPUT_FILE}
    START_START=$(get_timestamp)
    $SSH_CMD "sudo systemctl start exam-automated" 2>&1 | tee -a ${OUTPUT_FILE}
    END_START=$(get_timestamp)
    START_TIME=$(calc_time $START_START $END_START)
    START_TIME_MS=$(awk "BEGIN {printf \"%.0f\", $START_TIME * 1000}")
    echo "Thời gian start service: ${START_TIME} giây (${START_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
    echo "start,${START_TIME},${START_TIME_MS}" >> ${CSV_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Đợi service sẵn sàng (từ bên trong VM)
    echo "2. Đợi service sẵn sàng (từ bên trong VM)..." | tee -a ${OUTPUT_FILE}
    START_READY=$(get_timestamp)
    MAX_WAIT=60
    ELAPSED=0
    
    while awk "BEGIN {exit !($ELAPSED < $MAX_WAIT)}"; do
        # Kiểm tra từ bên trong VM
        if $SSH_CMD "curl -sf http://localhost/health >/dev/null 2>&1" || \
           $SSH_CMD "curl -sf http://localhost:8000/health >/dev/null 2>&1"; then
            END_READY=$(get_timestamp)
            READY_TIME=$(calc_time $START_READY $END_READY)
            READY_TIME_MS=$(awk "BEGIN {printf \"%.0f\", $READY_TIME * 1000}")
            echo "Service ready sau: ${READY_TIME} giây (${READY_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
            echo "ready,${READY_TIME},${READY_TIME_MS}" >> ${CSV_FILE}
            break
        fi
        sleep 0.5
        ELAPSED=$(awk "BEGIN {printf \"%.1f\", $ELAPSED + 0.5}")
    done
    
    if awk "BEGIN {exit !($ELAPSED >= $MAX_WAIT)}"; then
        echo "⚠️  Service không sẵn sàng sau ${MAX_WAIT} giây" | tee -a ${OUTPUT_FILE}
    fi
fi

echo "" | tee -a ${OUTPUT_FILE}
echo "=== TỔNG KẾT ===" | tee -a ${OUTPUT_FILE}
echo "Start time: ${START_TIME} giây (${START_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
if [ -n "$READY_TIME" ]; then
    echo "Ready time: ${READY_TIME} giây (${READY_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
fi
echo "" | tee -a ${OUTPUT_FILE}
echo "Kết quả đã được lưu vào:" | tee -a ${OUTPUT_FILE}
echo "  - Text: ${OUTPUT_FILE}" | tee -a ${OUTPUT_FILE}
echo "  - CSV: ${CSV_FILE}" | tee -a ${OUTPUT_FILE}
echo "Thời gian kết thúc: $(date)" | tee -a ${OUTPUT_FILE}


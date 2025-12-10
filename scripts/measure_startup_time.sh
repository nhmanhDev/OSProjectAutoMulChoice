#!/bin/bash

# Script đo thời gian khởi động dịch vụ
# Sử dụng: ./measure_startup_time.sh [docker|vm] [--no-build]

set -e  # Exit on error

MODE=${1:-docker}
NO_BUILD=${2:-""}
RESULTS_DIR="measurement_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${RESULTS_DIR}/startup_time_${MODE}_${TIMESTAMP}.txt"
CSV_FILE="${RESULTS_DIR}/startup_time_${MODE}_${TIMESTAMP}.csv"

mkdir -p ${RESULTS_DIR}

# Kiểm tra dependencies
command -v bc >/dev/null 2>&1 || { echo "Lỗi: bc chưa được cài đặt. Cài đặt: sudo apt-get install bc" >&2; exit 1; }
if [ "$MODE" = "docker" ]; then
    command -v docker >/dev/null 2>&1 || { echo "Lỗi: Docker chưa được cài đặt" >&2; exit 1; }
    command -v curl >/dev/null 2>&1 || { echo "Lỗi: curl chưa được cài đặt" >&2; exit 1; }
fi

# Hàm tính toán thời gian chính xác
calc_time() {
    local start=$1
    local end=$2
    echo "$end - $start" | bc -l
}

# Hàm lấy timestamp với độ chính xác cao
get_timestamp() {
    if command -v gdate >/dev/null 2>&1; then
        gdate +%s.%N  # macOS với coreutils
    else
        date +%s.%N    # Linux
    fi
}

echo "=== Đo thời gian khởi động dịch vụ - Mode: ${MODE} ===" | tee ${OUTPUT_FILE}
echo "Thời gian bắt đầu: $(date)" | tee -a ${OUTPUT_FILE}
echo "Timestamp: ${TIMESTAMP}" | tee -a ${OUTPUT_FILE}
echo "" | tee -a ${OUTPUT_FILE}

# Tạo CSV header
echo "metric,time_seconds,time_milliseconds" > ${CSV_FILE}

if [ "$MODE" = "docker" ]; then
    echo "--- Đo thời gian khởi động Docker Container ---" | tee -a ${OUTPUT_FILE}
    
    # Dừng containers nếu đang chạy
    echo "Dừng containers hiện tại (nếu có)..." | tee -a ${OUTPUT_FILE}
    docker compose down >/dev/null 2>&1 || true
    sleep 2
    
    # Đo thời gian build image (chỉ nếu không có flag --no-build)
    BUILD_TIME=0
    if [ "$NO_BUILD" != "--no-build" ]; then
        echo "1. Đo thời gian build Docker image..." | tee -a ${OUTPUT_FILE}
        START_BUILD=$(get_timestamp)
        docker compose build --no-cache 2>&1 | tee -a ${OUTPUT_FILE} | grep -E "(Step|ERROR|Successfully)" || true
        END_BUILD=$(get_timestamp)
        BUILD_TIME=$(calc_time $START_BUILD $END_BUILD)
        BUILD_TIME_MS=$(echo "$BUILD_TIME * 1000" | bc -l | cut -d. -f1)
        echo "Thời gian build: ${BUILD_TIME} giây (${BUILD_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
        echo "build,${BUILD_TIME},${BUILD_TIME_MS}" >> ${CSV_FILE}
        echo "" | tee -a ${OUTPUT_FILE}
    else
        echo "1. Bỏ qua build (--no-build flag)" | tee -a ${OUTPUT_FILE}
        echo "build,0,0" >> ${CSV_FILE}
        echo "" | tee -a ${OUTPUT_FILE}
    fi
    
    # Đo thời gian start container
    echo "2. Đo thời gian start container..." | tee -a ${OUTPUT_FILE}
    START_START=$(get_timestamp)
    docker compose up -d 2>&1 | tee -a ${OUTPUT_FILE} | tail -5
    END_START=$(get_timestamp)
    START_TIME=$(calc_time $START_START $END_START)
    START_TIME_MS=$(echo "$START_TIME * 1000" | bc -l | cut -d. -f1)
    echo "Thời gian start: ${START_TIME} giây (${START_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
    echo "start,${START_TIME},${START_TIME_MS}" >> ${CSV_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Đợi containers khởi động
    echo "Đợi containers khởi động..." | tee -a ${OUTPUT_FILE}
    sleep 3
    
    # Đo thời gian từ khi start đến khi service ready
    echo "3. Đo thời gian từ start đến khi service ready..." | tee -a ${OUTPUT_FILE}
    START_READY=$(get_timestamp)
    MAX_WAIT=300  # 5 phút
    ELAPSED=0
    READY_TIME=0
    READY_TIME_MS=0
    
    while (( $(echo "$ELAPSED < $MAX_WAIT" | bc -l) )); do
        if curl -sf http://localhost/ > /dev/null 2>&1; then
            END_READY=$(get_timestamp)
            READY_TIME=$(calc_time $START_READY $END_READY)
            READY_TIME_MS=$(echo "$READY_TIME * 1000" | bc -l | cut -d. -f1)
            echo "Service ready sau: ${READY_TIME} giây (${READY_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
            echo "ready,${READY_TIME},${READY_TIME_MS}" >> ${CSV_FILE}
            break
        fi
        sleep 0.1
        ELAPSED=$(echo "$ELAPSED + 0.1" | bc -l)
    done
    
    if (( $(echo "$ELAPSED >= $MAX_WAIT" | bc -l) )); then
        echo "⚠️  Service không ready sau ${MAX_WAIT} giây" | tee -a ${OUTPUT_FILE}
        echo "ready,-1,-1" >> ${CSV_FILE}
        READY_TIME=-1
    fi
    
    # Đo thời gian stop
    echo "" | tee -a ${OUTPUT_FILE}
    echo "4. Đo thời gian stop container..." | tee -a ${OUTPUT_FILE}
    START_STOP=$(get_timestamp)
    docker compose down 2>&1 | tee -a ${OUTPUT_FILE} | tail -3
    END_STOP=$(get_timestamp)
    STOP_TIME=$(calc_time $START_STOP $END_STOP)
    STOP_TIME_MS=$(echo "$STOP_TIME * 1000" | bc -l | cut -d. -f1)
    echo "Thời gian stop: ${STOP_TIME} giây (${STOP_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
    echo "stop,${STOP_TIME},${STOP_TIME_MS}" >> ${CSV_FILE}
    
    # Tổng kết
    echo "" | tee -a ${OUTPUT_FILE}
    echo "=== TỔNG KẾT ===" | tee -a ${OUTPUT_FILE}
    if [ "$NO_BUILD" != "--no-build" ]; then
        echo "Build time:     ${BUILD_TIME} giây (${BUILD_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
    fi
    echo "Start time:     ${START_TIME} giây (${START_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
    if [ "$READY_TIME" != "-1" ]; then
        echo "Ready time:     ${READY_TIME} giây (${READY_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
    else
        echo "Ready time:     TIMEOUT" | tee -a ${OUTPUT_FILE}
    fi
    echo "Stop time:      ${STOP_TIME} giây (${STOP_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
    
    if [ "$READY_TIME" != "-1" ]; then
        TOTAL_TIME=$(echo "$BUILD_TIME + $START_TIME + $READY_TIME" | bc -l)
        TOTAL_TIME_MS=$(echo "$TOTAL_TIME * 1000" | bc -l | cut -d. -f1)
        echo "Tổng (build + start + ready): ${TOTAL_TIME} giây (${TOTAL_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
        echo "total,${TOTAL_TIME},${TOTAL_TIME_MS}" >> ${CSV_FILE}
    fi
    
elif [ "$MODE" = "vm" ]; then
    echo "--- Đo thời gian khởi động VM ---" | tee -a ${OUTPUT_FILE}
    echo "Lưu ý: Cần chạy script này từ bên trong VM hoặc từ host với SSH" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Cấu hình VM (có thể thay đổi)
    VM_NAME=${VM_NAME:-"exam-grading-vm"}
    VM_SSH=${VM_SSH:-"user@localhost"}
    VM_SSH_PORT=${VM_SSH_PORT:-"2222"}
    
    # Đo thời gian boot VM (cần VBoxManage)
    if command -v VBoxManage >/dev/null 2>&1; then
        echo "1. Đo thời gian boot VM: ${VM_NAME}..." | tee -a ${OUTPUT_FILE}
        
        # Dừng VM nếu đang chạy
        VBoxManage controlvm ${VM_NAME} poweroff >/dev/null 2>&1 || true
        sleep 2
        
        START_BOOT=$(get_timestamp)
        VBoxManage startvm ${VM_NAME} --type headless 2>&1 | tee -a ${OUTPUT_FILE}
        END_BOOT=$(get_timestamp)
        BOOT_TIME=$(calc_time $START_BOOT $END_BOOT)
        BOOT_TIME_MS=$(echo "$BOOT_TIME * 1000" | bc -l | cut -d. -f1)
        echo "Thời gian boot VM: ${BOOT_TIME} giây (${BOOT_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
        echo "boot,${BOOT_TIME},${BOOT_TIME_MS}" >> ${CSV_FILE}
        echo "" | tee -a ${OUTPUT_FILE}
        
        # Đợi VM boot hoàn tất
        echo "Đợi VM boot hoàn tất..." | tee -a ${OUTPUT_FILE}
        sleep 10
        
        # Đợi SSH sẵn sàng
        echo "Đợi SSH sẵn sàng..." | tee -a ${OUTPUT_FILE}
        MAX_SSH_WAIT=120
        SSH_ELAPSED=0
        while (( $(echo "$SSH_ELAPSED < $MAX_SSH_WAIT" | bc -l) )); do
            if ssh -p ${VM_SSH_PORT} -o ConnectTimeout=2 -o StrictHostKeyChecking=no ${VM_SSH} "echo ready" >/dev/null 2>&1; then
                echo "SSH sẵn sàng sau ${SSH_ELAPSED} giây" | tee -a ${OUTPUT_FILE}
                break
            fi
            sleep 2
            SSH_ELAPSED=$(echo "$SSH_ELAPSED + 2" | bc -l)
        done
    else
        echo "⚠️  VBoxManage không tìm thấy. Bỏ qua đo thời gian boot VM." | tee -a ${OUTPUT_FILE}
        echo "boot,0,0" >> ${CSV_FILE}
    fi
    
    # Đo thời gian start service trong VM
    echo "" | tee -a ${OUTPUT_FILE}
    echo "2. Đo thời gian start service trong VM..." | tee -a ${OUTPUT_FILE}
    START_SERVICE=$(get_timestamp)
    
    # Kiểm tra SSH connection
    if ssh -p ${VM_SSH_PORT} -o ConnectTimeout=5 ${VM_SSH} "echo test" >/dev/null 2>&1; then
        ssh -p ${VM_SSH_PORT} ${VM_SSH} "sudo systemctl start exam-grading" 2>&1 | tee -a ${OUTPUT_FILE} || true
        END_SERVICE=$(get_timestamp)
        SERVICE_TIME=$(calc_time $START_SERVICE $END_SERVICE)
        SERVICE_TIME_MS=$(echo "$SERVICE_TIME * 1000" | bc -l | cut -d. -f1)
        echo "Thời gian start service: ${SERVICE_TIME} giây (${SERVICE_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
        echo "service_start,${SERVICE_TIME},${SERVICE_TIME_MS}" >> ${CSV_FILE}
        
        # Đo thời gian service ready
        echo "" | tee -a ${OUTPUT_FILE}
        echo "3. Đo thời gian service ready..." | tee -a ${OUTPUT_FILE}
        START_READY=$(get_timestamp)
        MAX_WAIT=60
        ELAPSED=0
        
        while (( $(echo "$ELAPSED < $MAX_WAIT" | bc -l) )); do
            if curl -sf http://localhost:8080/ >/dev/null 2>&1 || \
               ssh -p ${VM_SSH_PORT} ${VM_SSH} "curl -sf http://localhost/ >/dev/null 2>&1"; then
                END_READY=$(get_timestamp)
                READY_TIME=$(calc_time $START_READY $END_READY)
                READY_TIME_MS=$(echo "$READY_TIME * 1000" | bc -l | cut -d. -f1)
                echo "Service ready sau: ${READY_TIME} giây (${READY_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
                echo "ready,${READY_TIME},${READY_TIME_MS}" >> ${CSV_FILE}
                break
            fi
            sleep 0.5
            ELAPSED=$(echo "$ELAPSED + 0.5" | bc -l)
        done
        
        if (( $(echo "$ELAPSED >= $MAX_WAIT" | bc -l) )); then
            echo "⚠️  Service không ready sau ${MAX_WAIT} giây" | tee -a ${OUTPUT_FILE}
            echo "ready,-1,-1" >> ${CSV_FILE}
        fi
    else
        echo "⚠️  Không thể kết nối SSH đến VM. Kiểm tra cấu hình VM_SSH và VM_SSH_PORT." | tee -a ${OUTPUT_FILE}
        echo "service_start,-1,-1" >> ${CSV_FILE}
    fi
    
    # Tổng kết
    echo "" | tee -a ${OUTPUT_FILE}
    echo "=== TỔNG KẾT ===" | tee -a ${OUTPUT_FILE}
    if [ -n "$BOOT_TIME" ] && [ "$BOOT_TIME" != "0" ]; then
        echo "Boot time:      ${BOOT_TIME} giây (${BOOT_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
    fi
    if [ -n "$SERVICE_TIME" ] && [ "$SERVICE_TIME" != "-1" ]; then
        echo "Service start:   ${SERVICE_TIME} giây (${SERVICE_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
    fi
    if [ -n "$READY_TIME" ] && [ "$READY_TIME" != "-1" ]; then
        echo "Ready time:     ${READY_TIME} giây (${READY_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
    fi
fi

echo "" | tee -a ${OUTPUT_FILE}
echo "=== KẾT QUẢ ===" | tee -a ${OUTPUT_FILE}
echo "File text: ${OUTPUT_FILE}" | tee -a ${OUTPUT_FILE}
echo "File CSV:  ${CSV_FILE}" | tee -a ${OUTPUT_FILE}
echo "Thời gian kết thúc: $(date)" | tee -a ${OUTPUT_FILE}


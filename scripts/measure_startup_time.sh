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

# Kiểm tra dependencies - bc là optional, sẽ dùng awk nếu không có
# command -v bc >/dev/null 2>&1 || { echo "Cảnh báo: bc chưa được cài đặt, sẽ dùng awk thay thế" >&2; }
if [ "$MODE" = "docker" ]; then
    command -v docker >/dev/null 2>&1 || { echo "Lỗi: Docker chưa được cài đặt" >&2; exit 1; }
    command -v curl >/dev/null 2>&1 || { echo "Lỗi: curl chưa được cài đặt" >&2; exit 1; }
fi

# Hàm tính toán thời gian chính xác
calc_time() {
    local start=$1
    local end=$2
    # Dùng awk thay vì bc (awk có sẵn trong Git Bash)
    awk "BEGIN {printf \"%.6f\", $end - $start}"
}

# Hàm tính toán với awk (thay thế bc)
calc_awk() {
    local expr=$1
    awk "BEGIN {printf \"%.6f\", $expr}"
}

# Hàm so sánh số thực (thay thế bc)
compare_float() {
    local a=$1
    local op=$2
    local b=$3
    awk "BEGIN {if ($a $op $b) exit 0; else exit 1}"
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
    docker compose -f deployment/docker-compose.yml down >/dev/null 2>&1 || true
    sleep 2
    
    # Đo thời gian build image (chỉ nếu không có flag --no-build)
    BUILD_TIME=0
    if [ "$NO_BUILD" != "--no-build" ]; then
        echo "1. Đo thời gian build Docker image..." | tee -a ${OUTPUT_FILE}
        START_BUILD=$(get_timestamp)
        docker compose -f deployment/docker-compose.yml build --no-cache 2>&1 | tee -a ${OUTPUT_FILE} | grep -E "(Step|ERROR|Successfully)" || true
        END_BUILD=$(get_timestamp)
        BUILD_TIME=$(calc_time $START_BUILD $END_BUILD)
        BUILD_TIME_MS=$(awk "BEGIN {printf \"%.0f\", $BUILD_TIME * 1000}")
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
    docker compose -f deployment/docker-compose.yml up -d 2>&1 | tee -a ${OUTPUT_FILE} | tail -5
    END_START=$(get_timestamp)
    START_TIME=$(calc_time $START_START $END_START)
    START_TIME_MS=$(awk "BEGIN {printf \"%.0f\", $START_TIME * 1000}")
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
    
    while awk "BEGIN {exit !($ELAPSED < $MAX_WAIT)}"; do
        if curl -sf http://localhost/ > /dev/null 2>&1; then
            END_READY=$(get_timestamp)
            READY_TIME=$(calc_time $START_READY $END_READY)
            READY_TIME_MS=$(awk "BEGIN {printf \"%.0f\", $READY_TIME * 1000}")
            echo "Service ready sau: ${READY_TIME} giây (${READY_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
            echo "ready,${READY_TIME},${READY_TIME_MS}" >> ${CSV_FILE}
            break
        fi
        sleep 0.1
        ELAPSED=$(awk "BEGIN {printf \"%.1f\", $ELAPSED + 0.1}")
    done
    
    if awk "BEGIN {exit !($ELAPSED >= $MAX_WAIT)}"; then
        echo "⚠️  Service không ready sau ${MAX_WAIT} giây" | tee -a ${OUTPUT_FILE}
        echo "ready,-1,-1" >> ${CSV_FILE}
        READY_TIME=-1
    fi
    
    # Đo thời gian stop
    echo "" | tee -a ${OUTPUT_FILE}
    echo "4. Đo thời gian stop container..." | tee -a ${OUTPUT_FILE}
    START_STOP=$(get_timestamp)
    docker compose -f deployment/docker-compose.yml down 2>&1 | tee -a ${OUTPUT_FILE} | tail -3
    END_STOP=$(get_timestamp)
    STOP_TIME=$(calc_time $START_STOP $END_STOP)
    STOP_TIME_MS=$(awk "BEGIN {printf \"%.0f\", $STOP_TIME * 1000}")
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
        TOTAL_TIME=$(awk "BEGIN {printf \"%.6f\", $BUILD_TIME + $START_TIME + $READY_TIME}")
        TOTAL_TIME_MS=$(awk "BEGIN {printf \"%.0f\", $TOTAL_TIME * 1000}")
        echo "Tổng (build + start + ready): ${TOTAL_TIME} giây (${TOTAL_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
        echo "total,${TOTAL_TIME},${TOTAL_TIME_MS}" >> ${CSV_FILE}
    fi
    
elif [ "$MODE" = "vm" ]; then
    echo "--- Đo thời gian khởi động VM ---" | tee -a ${OUTPUT_FILE}
    echo "Lưu ý: Cần chạy script này từ bên trong VM hoặc từ host với SSH" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Cấu hình VM (có thể thay đổi)
    VM_NAME=${VM_NAME:-"ubuntu"}
    VM_SSH=${VM_SSH:-"vm-ubuntu"}
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
        BOOT_TIME_MS=$(awk "BEGIN {printf \"%.0f\", $BOOT_TIME * 1000}")
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
        while awk "BEGIN {exit !($SSH_ELAPSED < $MAX_SSH_WAIT)}"; do
            if ssh -p ${VM_SSH_PORT} -o ConnectTimeout=2 -o StrictHostKeyChecking=no -o PasswordAuthentication=no ${VM_SSH} "echo ready" >/dev/null 2>&1 || \
               ssh -p ${VM_SSH_PORT} -o ConnectTimeout=2 -o StrictHostKeyChecking=no ${VM_SSH} "echo ready" >/dev/null 2>&1; then
                echo "SSH sẵn sàng sau ${SSH_ELAPSED} giây" | tee -a ${OUTPUT_FILE}
                break
            fi
            sleep 2
            SSH_ELAPSED=$(awk "BEGIN {printf \"%.1f\", $SSH_ELAPSED + 2}")
        done
    else
        echo "⚠️  VBoxManage không tìm thấy. Bỏ qua đo thời gian boot VM." | tee -a ${OUTPUT_FILE}
        echo "boot,0,0" >> ${CSV_FILE}
    fi
    
    # Đo thời gian start service trong VM
    echo "" | tee -a ${OUTPUT_FILE}
    echo "2. Đo thời gian start service trong VM..." | tee -a ${OUTPUT_FILE}
    START_SERVICE=$(get_timestamp)
    
    # Xác định URL để test service ready
    if [ -n "$VM_URL" ]; then
        VM_TEST_URL="$VM_URL"
    elif [ -n "$VM_IP" ]; then
        VM_TEST_URL="http://${VM_IP}/"
    else
        VM_TEST_URL="http://127.0.0.1:8080/"  # Mặc định dùng port forwarding
    fi
    
    # Kiểm tra SSH connection - dùng SSH config nếu là vm-ubuntu
    if [ "$VM_SSH" = "vm-ubuntu" ]; then
        SSH_CMD="ssh vm-ubuntu"
    else
        SSH_CMD="ssh -p ${VM_SSH_PORT} -o StrictHostKeyChecking=no ${VM_SSH}"
    fi
    
    if $SSH_CMD "echo test" >/dev/null 2>&1; then
        $SSH_CMD "sudo systemctl start exam-automated" 2>&1 | tee -a ${OUTPUT_FILE} || true
        END_SERVICE=$(get_timestamp)
        SERVICE_TIME=$(calc_time $START_SERVICE $END_SERVICE)
        SERVICE_TIME_MS=$(awk "BEGIN {printf \"%.0f\", $SERVICE_TIME * 1000}")
        echo "Thời gian start service: ${SERVICE_TIME} giây (${SERVICE_TIME_MS} ms)" | tee -a ${OUTPUT_FILE}
        echo "service_start,${SERVICE_TIME},${SERVICE_TIME_MS}" >> ${CSV_FILE}
        
        # Đo thời gian service ready
        echo "" | tee -a ${OUTPUT_FILE}
        echo "3. Đo thời gian service ready..." | tee -a ${OUTPUT_FILE}
        echo "Testing URL: ${VM_TEST_URL}" | tee -a ${OUTPUT_FILE}
        START_READY=$(get_timestamp)
        MAX_WAIT=60
        ELAPSED=0
        
        while awk "BEGIN {exit !($ELAPSED < $MAX_WAIT)}"; do
            if curl -sf ${VM_TEST_URL} >/dev/null 2>&1 || \
               $SSH_CMD "curl -sf http://localhost/ >/dev/null 2>&1"; then
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


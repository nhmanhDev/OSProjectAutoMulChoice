#!/bin/bash

# Script đo thông lượng (throughput) sử dụng ab (Apache Bench) hoặc wrk
# Sử dụng: ./measure_throughput.sh [docker|vm] [tool] [concurrent] [requests]

MODE=${1:-docker}
TOOL=${2:-ab}  # ab hoặc wrk
CONCURRENT=${3:-10}  # Số request đồng thời
REQUESTS=${4:-1000}  # Tổng số request
RESULTS_DIR="measurement_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${RESULTS_DIR}/throughput_${MODE}_${TOOL}_${TIMESTAMP}.txt"

mkdir -p ${RESULTS_DIR}

echo "=== Đo thông lượng (Throughput) - Mode: ${MODE} ===" | tee ${OUTPUT_FILE}
echo "Tool: ${TOOL}" | tee -a ${OUTPUT_FILE}
echo "Concurrent requests: ${CONCURRENT}" | tee -a ${OUTPUT_FILE}
echo "Total requests: ${REQUESTS}" | tee -a ${OUTPUT_FILE}
echo "Thời gian bắt đầu: $(date)" | tee -a ${OUTPUT_FILE}
echo "" | tee -a ${OUTPUT_FILE}

# URL để test
URL="http://localhost/"

if [ "$MODE" = "docker" ]; then
    # Đảm bảo container đang chạy
    if ! docker ps | grep -q exam-grading; then
        echo "Khởi động container..." | tee -a ${OUTPUT_FILE}
        docker-compose up -d
        sleep 10
    fi
    URL="http://localhost/"
elif [ "$MODE" = "vm" ]; then
    URL="http://vm_ip/"
fi

echo "Testing URL: ${URL}" | tee -a ${OUTPUT_FILE}
echo "" | tee -a ${OUTPUT_FILE}

if [ "$TOOL" = "ab" ]; then
    # Kiểm tra ab có sẵn không
    if ! command -v ab &> /dev/null; then
        echo "Lỗi: ab (Apache Bench) chưa được cài đặt" | tee -a ${OUTPUT_FILE}
        echo "Cài đặt: sudo apt-get install apache2-utils" | tee -a ${OUTPUT_FILE}
        exit 1
    fi
    
    echo "--- Chạy Apache Bench (ab) ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Warm-up requests
    echo "Warm-up: 10 requests..." | tee -a ${OUTPUT_FILE}
    ab -n 10 -c 1 ${URL} > /dev/null 2>&1
    sleep 2
    
    # Test chính
    echo "Chạy test chính..." | tee -a ${OUTPUT_FILE}
    ab -n ${REQUESTS} -c ${CONCURRENT} -g ${RESULTS_DIR}/ab_${MODE}_${TIMESTAMP}.tsv ${URL} | tee -a ${OUTPUT_FILE}
    
    echo "" | tee -a ${OUTPUT_FILE}
    echo "Chi tiết đã được lưu vào: ${RESULTS_DIR}/ab_${MODE}_${TIMESTAMP}.tsv" | tee -a ${OUTPUT_FILE}
    
elif [ "$TOOL" = "wrk" ]; then
    # Kiểm tra wrk có sẵn không
    if ! command -v wrk &> /dev/null; then
        echo "Lỗi: wrk chưa được cài đặt" | tee -a ${OUTPUT_FILE}
        echo "Cài đặt: sudo apt-get install wrk hoặc compile từ source" | tee -a ${OUTPUT_FILE}
        exit 1
    fi
    
    echo "--- Chạy wrk ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    DURATION=30  # 30 giây
    THREADS=4
    
    # Warm-up
    echo "Warm-up: 10 giây..." | tee -a ${OUTPUT_FILE}
    wrk -t${THREADS} -c${CONCURRENT} -d10s ${URL} > /dev/null 2>&1
    sleep 2
    
    # Test chính
    echo "Chạy test chính..." | tee -a ${OUTPUT_FILE}
    wrk -t${THREADS} -c${CONCURRENT} -d${DURATION}s --latency ${URL} | tee -a ${OUTPUT_FILE}
    
    # Test với script Lua để đo chi tiết hơn
    if [ -f "scripts/wrk_script.lua" ]; then
        echo "" | tee -a ${OUTPUT_FILE}
        echo "Chạy test với script Lua..." | tee -a ${OUTPUT_FILE}
        wrk -t${THREADS} -c${CONCURRENT} -d${DURATION}s -s scripts/wrk_script.lua ${URL} | tee -a ${OUTPUT_FILE}
    fi
fi

# Đo tài nguyên trong khi test
echo "" | tee -a ${OUTPUT_FILE}
echo "--- Đo tài nguyên trong khi test ---" | tee -a ${OUTPUT_FILE}

if [ "$MODE" = "docker" ]; then
    # Chạy đo tài nguyên song song
    (
        START_TIME=$(date +%s)
        END_TIME=$((START_TIME + 60))
        while [ $(date +%s) -lt $END_TIME ]; do
            docker stats --no-stream --format "{{.Container}},{{.CPUPerc}},{{.MemUsage}}" | tee -a ${RESULTS_DIR}/stats_during_test_${TIMESTAMP}.txt
            sleep 1
        done
    ) &
    STATS_PID=$!
fi

# Chờ test hoàn thành
wait

if [ -n "$STATS_PID" ]; then
    kill $STATS_PID 2>/dev/null
fi

echo "" | tee -a ${OUTPUT_FILE}
echo "Kết quả đã được lưu vào: ${OUTPUT_FILE}" | tee -a ${OUTPUT_FILE}
echo "Thời gian kết thúc: $(date)" | tee -a ${OUTPUT_FILE}


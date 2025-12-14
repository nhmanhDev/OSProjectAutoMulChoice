#!/bin/bash

# Script chạy tất cả các phép đo và tạo báo cáo tổng hợp
# Sử dụng: ./run_all_measurements.sh [docker|vm]

MODE=${1:-docker}
RESULTS_DIR="measurement_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="${RESULTS_DIR}/full_report_${MODE}_${TIMESTAMP}.md"

mkdir -p ${RESULTS_DIR}

# Set biến môi trường cho VM mode
if [ "$MODE" = "vm" ]; then
    export VM_NAME=${VM_NAME:-"ubuntu"}
    export VM_SSH=${VM_SSH:-"vm-ubuntu"}
    export VM_SSH_PORT=${VM_SSH_PORT:-"2222"}
    export VM_URL=${VM_URL:-"http://127.0.0.1:8080/"}
    export VDI_PATH=${VDI_PATH:-""}  # Có thể set: export VDI_PATH="E:/VB/mayao/ubuntu/ubuntu.vdi"
    echo "VM Environment variables set:"
    echo "  VM_NAME: $VM_NAME"
    echo "  VM_SSH: $VM_SSH"
    echo "  VM_SSH_PORT: $VM_SSH_PORT"
    echo "  VM_URL: $VM_URL"
    if [ -n "$VDI_PATH" ]; then
        echo "  VDI_PATH: $VDI_PATH"
    fi
    echo ""
fi

echo "=== Chạy tất cả các phép đo - Mode: ${MODE} ==="
echo "Báo cáo sẽ được lưu vào: ${REPORT_FILE}"
echo ""

# Tạo file báo cáo
cat > ${REPORT_FILE} << EOF
# Báo Cáo Đo Lường Hiệu Năng - ${MODE}
**Thời gian:** $(date)
**Mode:** ${MODE}

---

EOF

# 1. Đo thời gian khởi động
echo "1. Đo thời gian khởi động..."
echo "## 1. Thời Gian Khởi Động" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
bash scripts/measure_startup_time.sh ${MODE} 2>&1 | tee -a ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
echo "---" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}

# 2. Đo dung lượng đĩa
echo ""
echo "2. Đo dung lượng đĩa..."
echo "## 2. Dung Lượng Đĩa" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
bash scripts/measure_disk_usage.sh ${MODE} 2>&1 | tee -a ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
echo "---" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}

# 3. Đo tài nguyên khi idle (từ HOST WINDOWS)
echo ""
echo "3. Đo tài nguyên khi idle từ HOST (60 giây)..."
echo "## 3. Sử Dụng Tài Nguyên Khi Idle (từ HOST)" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
bash scripts/measure_resource_usage.sh ${MODE} 60 2>&1 | tee -a ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
echo "---" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}

# 4. Đo thông lượng
echo ""
echo "4. Đo thông lượng..."
echo "## 4. Thông Lượng (Throughput)" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
bash scripts/measure_throughput.sh ${MODE} ab 10 1000 2>&1 | tee -a ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
echo "---" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}

# 5. Đo tài nguyên khi có tải (từ HOST WINDOWS)
echo ""
echo "5. Đo tài nguyên khi có tải từ HOST (trong khi chạy benchmark)..."
echo "## 5. Sử Dụng Tài Nguyên Khi Có Tải (từ HOST)" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
# Chạy benchmark và đo tài nguyên song song (từ host)
(bash scripts/measure_throughput.sh ${MODE} ab 50 5000 > /dev/null 2>&1 &)
BENCHMARK_PID=$!
bash scripts/measure_resource_usage.sh ${MODE} 60 2>&1 | tee -a ${REPORT_FILE}
wait $BENCHMARK_PID
echo "" >> ${REPORT_FILE}
echo "---" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}

# 6. Đo isolation overhead (từ HOST WINDOWS)
echo ""
echo "6. Đo isolation overhead từ HOST và quản lý tài nguyên..."
echo "## 6. Isolation Overhead và Quản Lý Tài Nguyên (từ HOST)" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
bash scripts/measure_isolation_overhead.sh ${MODE} 2>&1 | tee -a ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
echo "---" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}

# 7. Phân tích nguyên lý HĐH và so sánh kiến trúc
echo ""
echo "7. Phân tích nguyên lý HĐH và so sánh kiến trúc..."
echo "## 7. Phân Tích Nguyên Lý HĐH và So Sánh Kiến Trúc" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
bash scripts/analyze_os_principles.sh ${MODE} 2>&1 | tee -a ${REPORT_FILE}
ANALYSIS_FILE=$(ls -t ${RESULTS_DIR}/os_principles_analysis_*.md 2>/dev/null | head -1)
if [ -n "$ANALYSIS_FILE" ] && [ -f "$ANALYSIS_FILE" ]; then
    echo "" >> ${REPORT_FILE}
    echo "📄 Chi tiết phân tích đã được lưu vào: \`${ANALYSIS_FILE}\`" >> ${REPORT_FILE}
    echo "" >> ${REPORT_FILE}
    # Thêm nội dung phân tích vào report
    cat "$ANALYSIS_FILE" >> ${REPORT_FILE}
fi
echo "" >> ${REPORT_FILE}
echo "---" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}

# 8. Generate thống kê tổng hợp
echo ""
echo "8. Generate thống kê tổng hợp..."
echo "## 8. Thống Kê Tổng Hợp" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
bash scripts/generate_statistics.sh ${MODE} all 2>&1 | tee -a ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
echo "---" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}

# 9. Generate biểu đồ (nếu có cả Docker và VM)
HAS_DOCKER=$(ls ${RESULTS_DIR}/startup_time_docker_*.csv 2>/dev/null | wc -l)
HAS_VM=$(ls ${RESULTS_DIR}/startup_time_vm_*.csv 2>/dev/null | wc -l)

if [ "$MODE" = "both" ] || ([ "$HAS_DOCKER" -gt 0 ] && [ "$HAS_VM" -gt 0 ]); then
    echo ""
    echo "9. Generate biểu đồ so sánh..."
    echo "## 9. Biểu Đồ So Sánh" >> ${REPORT_FILE}
    echo "" >> ${REPORT_FILE}
    
    if command -v python3 >/dev/null 2>&1; then
        python3 scripts/generate_charts.py both 2>&1 | tee -a ${REPORT_FILE}
        echo "" >> ${REPORT_FILE}
        echo "Biểu đồ đã được tạo:" >> ${REPORT_FILE}
        if [ -f "${RESULTS_DIR}/comparison_charts.html" ]; then
            echo "- HTML: \`${RESULTS_DIR}/comparison_charts.html\`" >> ${REPORT_FILE}
        fi
        if [ -f "${RESULTS_DIR}/comparison_charts.png" ]; then
            echo "- PNG: \`${RESULTS_DIR}/comparison_charts.png\`" >> ${REPORT_FILE}
        fi
    else
        echo "⚠️  Python3 chưa được cài đặt. Không thể generate biểu đồ." >> ${REPORT_FILE}
        echo "   Cài đặt: sudo apt-get install python3 python3-pip" >> ${REPORT_FILE}
        echo "   pip3 install matplotlib numpy" >> ${REPORT_FILE}
        echo "" >> ${REPORT_FILE}
        echo "   Hoặc chạy sau khi có cả 2 report:" >> ${REPORT_FILE}
        echo "   python3 scripts/generate_charts.py both" >> ${REPORT_FILE}
    fi
    echo "" >> ${REPORT_FILE}
    echo "---" >> ${REPORT_FILE}
    echo "" >> ${REPORT_FILE}
else
    echo "" >> ${REPORT_FILE}
    echo "## 9. Biểu Đồ So Sánh" >> ${REPORT_FILE}
    echo "" >> ${REPORT_FILE}
    echo "⚠️  Chưa có đủ dữ liệu để so sánh (cần cả Docker và VM)." >> ${REPORT_FILE}
    echo "" >> ${REPORT_FILE}
    echo "Sau khi có cả 2 report, chạy:" >> ${REPORT_FILE}
    echo "\`\`\`bash" >> ${REPORT_FILE}
    echo "python3 scripts/generate_charts.py both" >> ${REPORT_FILE}
    echo "\`\`\`" >> ${REPORT_FILE}
    echo "" >> ${REPORT_FILE}
    echo "---" >> ${REPORT_FILE}
    echo "" >> ${REPORT_FILE}
fi

# Tổng kết
cat >> ${REPORT_FILE} << EOF
## Tổng Kết

Báo cáo này bao gồm các phép đo (TẤT CẢ ĐO TỪ HOST WINDOWS):
1. Thời gian khởi động dịch vụ
2. Dung lượng đĩa sử dụng (.vdi vs Docker image)
3. Mức sử dụng RAM và CPU khi idle (từ HOST)
4. Thông lượng (requests/giây) với benchmark (ab/wrk)
5. Mức sử dụng RAM và CPU khi có tải (từ HOST)
6. Isolation overhead và quản lý tài nguyên từ HOST (Docker daemon/VirtualBox process)
7. Phân tích nguyên lý HĐH và so sánh kiến trúc (ảo hóa phần cứng vs ảo hóa cấp HĐH)
8. Thống kê tổng hợp (min, max, avg, median)
9. Biểu đồ so sánh (nếu có cả Docker và VM)

Tất cả các file chi tiết được lưu trong thư mục: \`${RESULTS_DIR}/\`

**Thời gian hoàn thành:** $(date)
EOF

echo ""
echo "=== Hoàn thành ==="
echo "Báo cáo đã được lưu vào: ${REPORT_FILE}"


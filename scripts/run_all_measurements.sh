#!/bin/bash

# Script chạy tất cả các phép đo và tạo báo cáo tổng hợp
# Sử dụng: ./run_all_measurements.sh [docker|vm]

MODE=${1:-docker}
RESULTS_DIR="measurement_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="${RESULTS_DIR}/full_report_${MODE}_${TIMESTAMP}.md"

mkdir -p ${RESULTS_DIR}

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

# 3. Đo tài nguyên khi idle
echo ""
echo "3. Đo tài nguyên khi idle (60 giây)..."
echo "## 3. Sử Dụng Tài Nguyên Khi Idle" >> ${REPORT_FILE}
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

# 5. Đo tài nguyên khi có tải
echo ""
echo "5. Đo tài nguyên khi có tải (trong khi chạy benchmark)..."
echo "## 5. Sử Dụng Tài Nguyên Khi Có Tải" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
# Chạy benchmark và đo tài nguyên song song
(bash scripts/measure_throughput.sh ${MODE} ab 50 5000 > /dev/null 2>&1 &)
BENCHMARK_PID=$!
bash scripts/measure_resource_usage.sh ${MODE} 60 2>&1 | tee -a ${REPORT_FILE}
wait $BENCHMARK_PID
echo "" >> ${REPORT_FILE}
echo "---" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}

# Tổng kết
cat >> ${REPORT_FILE} << EOF
## Tổng Kết

Báo cáo này bao gồm các phép đo:
1. Thời gian khởi động dịch vụ
2. Dung lượng đĩa sử dụng
3. Mức sử dụng RAM và CPU khi idle
4. Thông lượng (requests/giây)
5. Mức sử dụng RAM và CPU khi có tải

Tất cả các file chi tiết được lưu trong thư mục: \`${RESULTS_DIR}/\`

**Thời gian hoàn thành:** $(date)
EOF

echo ""
echo "=== Hoàn thành ==="
echo "Báo cáo đã được lưu vào: ${REPORT_FILE}"


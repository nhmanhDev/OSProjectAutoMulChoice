#!/bin/bash

# Script chạy tất cả các phép đo từ BÊN TRONG VM/Docker
# Sử dụng: ./run_all_measurements_internal.sh [docker|vm]

MODE=${1:-docker}
# Script đang nằm trong measurement_results
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Lưu kết quả vào folder tương ứng
if [ "$MODE" = "docker" ]; then
    OUTPUT_DIR="${RESULTS_DIR}/docker"
    REPORT_FILE="${OUTPUT_DIR}/full_report_internal_${TIMESTAMP}.md"
else
    OUTPUT_DIR="${RESULTS_DIR}/VM"
    REPORT_FILE="${OUTPUT_DIR}/full_report_internal_${TIMESTAMP}.md"
    
    # Set biến môi trường cho VM mode
    export VM_NAME=${VM_NAME:-"ubuntu"}
    export VM_SSH=${VM_SSH:-"vm-ubuntu"}
    export VM_SSH_PORT=${VM_SSH_PORT:-"2222"}
fi

mkdir -p ${OUTPUT_DIR}

echo "=== Chạy tất cả các phép đo từ BÊN TRONG - Mode: ${MODE} ==="
echo "Báo cáo sẽ được lưu vào: ${REPORT_FILE}"
echo ""

# Tạo file báo cáo
cat > ${REPORT_FILE} << EOF
# Báo Cáo Đo Lường Hiệu Năng Từ BÊN TRONG - ${MODE}
**Thời gian:** $(date)
**Mode:** ${MODE}
**Ghi chú:** Tất cả measurements được thực hiện từ BÊN TRONG ${MODE}

---

EOF

# 1. Đo thời gian khởi động
echo "1. Đo thời gian khởi động từ bên trong..."
echo "## 1. Thời Gian Khởi Động (Từ Bên Trong)" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
bash ${SCRIPT_DIR}/measure_startup_time_internal.sh ${MODE} 2>&1 | tee -a ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
echo "---" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}

# 2. Đo dung lượng đĩa
echo ""
echo "2. Đo dung lượng đĩa từ bên trong..."
echo "## 2. Dung Lượng Đĩa (Từ Bên Trong)" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
bash ${SCRIPT_DIR}/measure_disk_usage_internal.sh ${MODE} 2>&1 | tee -a ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
echo "---" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}

# 3. Đo tài nguyên khi idle
echo ""
echo "3. Đo tài nguyên khi idle từ bên trong (60 giây)..."
echo "## 3. Sử Dụng Tài Nguyên Khi Idle (Từ Bên Trong)" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
bash ${SCRIPT_DIR}/measure_resource_usage_internal.sh ${MODE} 60 2>&1 | tee -a ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
echo "---" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}

# 4. Đo thông lượng
echo ""
echo "4. Đo thông lượng từ bên trong..."
echo "## 4. Thông Lượng (Throughput) - Từ Bên Trong" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
bash ${SCRIPT_DIR}/measure_throughput_internal.sh ${MODE} ab 10 1000 2>&1 | tee -a ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
echo "---" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}

# 5. Đo tài nguyên khi có tải
echo ""
echo "5. Đo tài nguyên khi có tải từ bên trong (trong khi chạy benchmark)..."
echo "## 5. Sử Dụng Tài Nguyên Khi Có Tải (Từ Bên Trong)" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}
# Chạy benchmark và đo tài nguyên song song
(bash ${SCRIPT_DIR}/measure_throughput_internal.sh ${MODE} ab 50 5000 > /dev/null 2>&1 &)
BENCHMARK_PID=$!
bash ${SCRIPT_DIR}/measure_resource_usage_internal.sh ${MODE} 60 2>&1 | tee -a ${REPORT_FILE}
wait $BENCHMARK_PID
echo "" >> ${REPORT_FILE}
echo "---" >> ${REPORT_FILE}
echo "" >> ${REPORT_FILE}

# Tổng kết
cat >> ${REPORT_FILE} << EOF
## Tổng Kết

Báo cáo này bao gồm các phép đo từ BÊN TRONG ${MODE}:
1. Thời gian khởi động dịch vụ (từ bên trong)
2. Dung lượng đĩa sử dụng (từ bên trong)
3. Mức sử dụng RAM và CPU khi idle (từ bên trong)
4. Thông lượng (requests/giây) - từ bên trong
5. Mức sử dụng RAM và CPU khi có tải (từ bên trong)

Tất cả các file chi tiết được lưu trong thư mục: \`${OUTPUT_DIR}/\`

**Thời gian hoàn thành:** $(date)
EOF

echo ""
echo "=== Hoàn thành ==="
echo "Báo cáo đã được lưu vào: ${REPORT_FILE}"


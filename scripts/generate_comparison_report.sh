#!/bin/bash

# Script để generate báo cáo so sánh và biểu đồ sau khi có cả Docker và VM reports
# Sử dụng: bash scripts/generate_comparison_report.sh

RESULTS_DIR="measurement_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="${RESULTS_DIR}/comparison_report_${TIMESTAMP}.md"

mkdir -p ${RESULTS_DIR}

echo "=== Generate Báo Cáo So Sánh Docker vs VM ==="
echo "Báo cáo sẽ được lưu vào: ${REPORT_FILE}"
echo ""

# Kiểm tra có đủ dữ liệu không
HAS_DOCKER=$(ls ${RESULTS_DIR}/startup_time_docker_*.csv 2>/dev/null | wc -l)
HAS_VM=$(ls ${RESULTS_DIR}/startup_time_vm_*.csv 2>/dev/null | wc -l)

if [ "$HAS_DOCKER" -eq 0 ]; then
    echo "❌ Không tìm thấy dữ liệu Docker. Vui lòng chạy: bash scripts/run_all_measurements.sh docker"
    exit 1
fi

if [ "$HAS_VM" -eq 0 ]; then
    echo "❌ Không tìm thấy dữ liệu VM. Vui lòng chạy: bash scripts/run_all_measurements.sh vm"
    exit 1
fi

# Tạo file báo cáo
cat > ${REPORT_FILE} << EOF
# Báo Cáo So Sánh Hiệu Năng: Docker vs VM
**Thời gian:** $(date)
**Mode:** Comparison

---

## Tổng Quan

Báo cáo này so sánh hiệu năng của ứng dụng khi chạy trên Docker và Virtual Machine (VM).

---

## 1. Thống Kê Tổng Hợp

### Docker

EOF

# Thống kê Docker
bash scripts/generate_statistics.sh docker all >> ${REPORT_FILE} 2>&1

cat >> ${REPORT_FILE} << EOF

### VM

EOF

# Thống kê VM
bash scripts/generate_statistics.sh vm all >> ${REPORT_FILE} 2>&1

cat >> ${REPORT_FILE} << EOF

---

## 2. Biểu Đồ So Sánh

EOF

# Generate biểu đồ
if command -v python3 >/dev/null 2>&1; then
    echo "Đang generate biểu đồ..."
    python3 scripts/generate_charts.py both >> ${REPORT_FILE} 2>&1
    
    if [ -f "${RESULTS_DIR}/comparison_charts.html" ]; then
        cat >> ${REPORT_FILE} << EOF

### Biểu Đồ Tương Tác (HTML)

Mở file [comparison_charts.html](${RESULTS_DIR}/comparison_charts.html) trong trình duyệt để xem biểu đồ tương tác.

EOF
    fi
    
    if [ -f "${RESULTS_DIR}/comparison_charts.png" ]; then
        cat >> ${REPORT_FILE} << EOF

### Biểu Đồ PNG

![Comparison Charts](${RESULTS_DIR}/comparison_charts.png)

EOF
    fi
else
    cat >> ${REPORT_FILE} << EOF

⚠️  Python3 chưa được cài đặt. Không thể generate biểu đồ.

Cài đặt:
\`\`\`bash
sudo apt-get install python3 python3-pip
pip3 install matplotlib numpy
\`\`\`

Sau đó chạy:
\`\`\`bash
python3 scripts/generate_charts.py both
\`\`\`

EOF
fi

cat >> ${REPORT_FILE} << EOF

---

## 3. Kết Luận

Báo cáo này cung cấp so sánh chi tiết về:
- Thời gian khởi động
- Dung lượng đĩa sử dụng
- Mức sử dụng RAM và CPU (idle và under load)
- Thông lượng (Throughput)

**Thời gian hoàn thành:** $(date)
EOF

echo ""
echo "=== Hoàn thành ==="
echo "Báo cáo so sánh đã được lưu vào: ${REPORT_FILE}"

if [ -f "${RESULTS_DIR}/comparison_charts.html" ]; then
    echo "Biểu đồ HTML: ${RESULTS_DIR}/comparison_charts.html"
fi


#!/bin/bash

# Script đo dung lượng đĩa sử dụng
# Sử dụng: ./measure_disk_usage.sh [docker|vm]

MODE=${1:-docker}
RESULTS_DIR="measurement_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${RESULTS_DIR}/disk_usage_${MODE}_${TIMESTAMP}.txt"

mkdir -p ${RESULTS_DIR}

echo "=== Đo dung lượng đĩa sử dụng - Mode: ${MODE} ===" | tee ${OUTPUT_FILE}
echo "Thời gian: $(date)" | tee -a ${OUTPUT_FILE}
echo "" | tee -a ${OUTPUT_FILE}

if [ "$MODE" = "docker" ]; then
    echo "--- Dung lượng Docker Image và Container ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Kích thước Docker images
    echo "1. Kích thước Docker Images:" | tee -a ${OUTPUT_FILE}
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Chi tiết từng image
    echo "2. Chi tiết kích thước từng image:" | tee -a ${OUTPUT_FILE}
    docker images --format "{{.Repository}}:{{.Tag}}" | while read image; do
        SIZE=$(docker image inspect "$image" --format='{{.Size}}' | numfmt --to=iec-i --suffix=B)
        echo "  $image: $SIZE" | tee -a ${OUTPUT_FILE}
    done
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Kích thước container (running)
    echo "3. Kích thước Container (đang chạy):" | tee -a ${OUTPUT_FILE}
    docker ps --format "table {{.Names}}\t{{.Size}}" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Tổng dung lượng Docker
    echo "4. Tổng dung lượng Docker sử dụng:" | tee -a ${OUTPUT_FILE}
    docker system df -v | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Kích thước volumes
    echo "5. Kích thước Volumes:" | tee -a ${OUTPUT_FILE}
    docker volume ls -q | while read volume; do
        SIZE=$(docker volume inspect "$volume" --format='{{.Mountpoint}}' | xargs du -sh 2>/dev/null | cut -f1)
        echo "  $volume: $SIZE" | tee -a ${OUTPUT_FILE}
    done
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Kích thước thư mục dự án
    echo "6. Kích thước thư mục dự án:" | tee -a ${OUTPUT_FILE}
    du -sh . | tee -a ${OUTPUT_FILE}
    du -sh */ 2>/dev/null | sort -h | tee -a ${OUTPUT_FILE}
    
elif [ "$MODE" = "vm" ]; then
    echo "--- Dung lượng VM ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Kích thước file .vdi
    if command -v VBoxManage &> /dev/null; then
        VM_NAME="exam-grading-vm"
        echo "1. Kích thước file .vdi của VM:" | tee -a ${OUTPUT_FILE}
        VBoxManage showvminfo ${VM_NAME} --machinereadable | grep "SATA-0-0" | tee -a ${OUTPUT_FILE}
        
        # Tìm file .vdi
        VDI_PATH=$(VBoxManage showvminfo ${VM_NAME} --machinereadable | grep "SATA-0-0" | cut -d'"' -f4)
        if [ -n "$VDI_PATH" ]; then
            VDI_SIZE=$(du -h "$VDI_PATH" | cut -f1)
            VDI_SIZE_BYTES=$(du -b "$VDI_PATH" | cut -f1)
            echo "  File: $VDI_PATH" | tee -a ${OUTPUT_FILE}
            echo "  Kích thước: $VDI_SIZE ($VDI_SIZE_BYTES bytes)" | tee -a ${OUTPUT_FILE}
        fi
        echo "" | tee -a ${OUTPUT_FILE}
    fi
    
    # Dung lượng đĩa trong VM
    echo "2. Dung lượng đĩa trong VM (qua SSH):" | tee -a ${OUTPUT_FILE}
    echo "  Chạy lệnh sau trong VM:" | tee -a ${OUTPUT_FILE}
    echo "  df -h" | tee -a ${OUTPUT_FILE}
    echo "  du -sh /opt/exam-grading" | tee -a ${OUTPUT_FILE}
fi

echo "" | tee -a ${OUTPUT_FILE}
echo "Kết quả đã được lưu vào: ${OUTPUT_FILE}" | tee -a ${OUTPUT_FILE}


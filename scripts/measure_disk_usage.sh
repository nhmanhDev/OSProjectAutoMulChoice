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
    
    # Kích thước file .vdi (theo yêu cầu đề bài: so sánh .vdi vs Docker image)
    VM_NAME=${VM_NAME:-"ubuntu"}
    VDI_PATH_CUSTOM=${VDI_PATH:-""}  # Cho phép set đường dẫn .vdi tùy chỉnh
    
    if command -v VBoxManage &> /dev/null || [ -f "/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" ]; then
        echo "1. Kích thước file .vdi của VM:" | tee -a ${OUTPUT_FILE}
        
        # Dùng VBoxManage từ Windows hoặc Linux
        if [ -f "/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" ]; then
            VBOX_CMD="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
        elif [ -f "C:/Program Files/Oracle/VirtualBox/VBoxManage.exe" ]; then
            VBOX_CMD="C:/Program Files/Oracle/VirtualBox/VBoxManage.exe"
        else
            VBOX_CMD="VBoxManage"
        fi
        
        # Test VBoxManage
        if [ -f "$VBOX_CMD" ] && [[ "$VBOX_CMD" == *".exe" ]]; then
            # Dùng PowerShell để chạy Windows executable
            VBOX_CMD_WRAPPER="powershell -Command \"& '$VBOX_CMD'\""
        fi
        
        # Nếu có đường dẫn .vdi tùy chỉnh, dùng luôn
        if [ -n "$VDI_PATH_CUSTOM" ] && [ -f "$VDI_PATH_CUSTOM" ]; then
            VDI_PATH="$VDI_PATH_CUSTOM"
            echo "  Sử dụng đường dẫn .vdi tùy chỉnh: $VDI_PATH" | tee -a ${OUTPUT_FILE}
        else
            # Convert Unix-style path sang Windows path
            if [[ "$VBOX_CMD" == /c/* ]] || [[ "$VBOX_CMD" == /C/* ]]; then
                VBOX_CMD_WIN=$(echo "$VBOX_CMD" | sed 's|^/c/|C:/|' | sed 's|^/C/|C:/|')
            elif [[ "$VBOX_CMD" == *".exe" ]]; then
                VBOX_CMD_WIN="$VBOX_CMD"
            else
                VBOX_CMD_WIN="$VBOX_CMD"
            fi
            
            # Tìm VM name từ danh sách VMs đang chạy
            if [ -f "$VBOX_CMD" ] || [ -f "$VBOX_CMD_WIN" ]; then
                if [[ "$VBOX_CMD" == *".exe" ]] || [[ "$VBOX_CMD_WIN" == *".exe" ]]; then
                    RUNNING_VMS=$(powershell -Command "& '$VBOX_CMD_WIN' list runningvms" 2>&1)
                else
                    RUNNING_VMS=$($VBOX_CMD list runningvms 2>&1)
                fi
            else
                RUNNING_VMS=$($VBOX_CMD list runningvms 2>&1)
            fi
            
            if [ -n "$RUNNING_VMS" ] && [ "$RUNNING_VMS" != "" ]; then
                # Lấy VM đầu tiên đang chạy nếu VM_NAME không khớp
                ACTUAL_VM_NAME=$(echo "$RUNNING_VMS" | head -1 | sed 's/^"\([^"]*\)".*/\1/')
                if [ -n "$ACTUAL_VM_NAME" ] && [ "$ACTUAL_VM_NAME" != "" ]; then
                    echo "  Tìm thấy VM đang chạy: ${ACTUAL_VM_NAME}" | tee -a ${OUTPUT_FILE}
                    VM_NAME="$ACTUAL_VM_NAME"
                fi
            fi
            
            # Tìm file .vdi từ VM info (chỉ lấy .vdi, không lấy .iso)
            if [ -f "$VBOX_CMD" ] || [ -f "$VBOX_CMD_WIN" ]; then
                if [[ "$VBOX_CMD" == *".exe" ]] || [[ "$VBOX_CMD_WIN" == *".exe" ]]; then
                    VM_INFO=$(powershell -Command "& '$VBOX_CMD_WIN' showvminfo \"${VM_NAME}\" --machinereadable" 2>&1)
                else
                    VM_INFO=$($VBOX_CMD showvminfo "${VM_NAME}" --machinereadable 2>&1)
                fi
                
                # Tìm tất cả storage devices, filter chỉ lấy .vdi (không lấy .iso)
                VDI_PATH=$(echo "$VM_INFO" | grep -E "SATA-0-0|IDE-0-0|SATA-1-0|IDE-1-0" | grep -i "\.vdi" | grep -v -i "\.iso" | head -1 | cut -d'"' -f4)
                
                # Nếu không tìm thấy, thử tìm tất cả storage và filter
                if [ -z "$VDI_PATH" ]; then
                    VDI_PATH=$(echo "$VM_INFO" | grep -i "\.vdi" | grep -v -i "\.iso" | head -1 | cut -d'"' -f4)
                fi
            else
                VM_INFO=$($VBOX_CMD showvminfo "${VM_NAME}" --machinereadable 2>&1)
                VDI_PATH=$(echo "$VM_INFO" | grep -E "SATA-0-0|IDE-0-0" | grep -i "\.vdi" | grep -v -i "\.iso" | head -1 | cut -d'"' -f4)
            fi
            
            if [ -z "$VDI_PATH" ]; then
                # Thử các đường dẫn phổ biến (hỗ trợ cả Windows và Unix path)
                POSSIBLE_PATHS=(
                    "$HOME/VirtualBox VMs/${VM_NAME}"
                    "E:/VB/mayao/${VM_NAME}"
                    "E:\\VB\\mayao\\${VM_NAME}"
                    "/e/VB/mayao/${VM_NAME}"
                    "/e/VB/mayao/ubuntu"
                )
                
                for DIR in "${POSSIBLE_PATHS[@]}"; do
                    # Kiểm tra thư mục tồn tại
                    if [ -d "$DIR" ] || [ -d "$(echo "$DIR" | sed 's|\\|/|g')" ]; then
                        NORMALIZED_DIR=$(echo "$DIR" | sed 's|\\|/|g')
                        # Chỉ tìm .vdi, không tìm .iso
                        VDI_PATH=$(find "$NORMALIZED_DIR" -name "*.vdi" -not -name "*.iso" 2>/dev/null | head -1)
                        if [ -n "$VDI_PATH" ] && [ -f "$VDI_PATH" ]; then
                            break
                        fi
                    fi
                done
                
                # Nếu vẫn không tìm thấy, thử tìm trực tiếp file .vdi bằng PowerShell (chỉ .vdi, không .iso)
                if [ -z "$VDI_PATH" ]; then
                    if command -v powershell >/dev/null 2>&1; then
                        VDI_PATH=$(powershell -Command "Get-ChildItem -Path 'E:\VB\mayao\ubuntu' -Filter '*.vdi' -Recurse -ErrorAction SilentlyContinue | Where-Object {\$_.Extension -eq '.vdi'} | Select-Object -First 1 -ExpandProperty FullName" 2>/dev/null)
                    fi
                fi
            fi
        fi
        
        if [ -n "$VDI_PATH" ] && [ -f "$VDI_PATH" ]; then
            if command -v du >/dev/null 2>&1; then
                VDI_SIZE=$(du -h "$VDI_PATH" 2>/dev/null | cut -f1)
                VDI_SIZE_BYTES=$(du -b "$VDI_PATH" 2>/dev/null | cut -f1)
                echo "  File: $VDI_PATH" | tee -a ${OUTPUT_FILE}
                echo "  Kích thước: $VDI_SIZE ($VDI_SIZE_BYTES bytes)" | tee -a ${OUTPUT_FILE}
            else
                # Windows PowerShell fallback
                VDI_SIZE_GB=$(powershell -Command "[math]::Round((Get-Item '$VDI_PATH').Length / 1GB, 2)" 2>/dev/null)
                VDI_SIZE_BYTES=$(powershell -Command "(Get-Item '$VDI_PATH').Length" 2>/dev/null)
                echo "  File: $VDI_PATH" | tee -a ${OUTPUT_FILE}
                echo "  Kích thước: ${VDI_SIZE_GB} GB (${VDI_SIZE_BYTES} bytes)" | tee -a ${OUTPUT_FILE}
            fi
        else
            echo "  ⚠️  Không tìm thấy file .vdi cho VM: ${VM_NAME}" | tee -a ${OUTPUT_FILE}
            echo "  Đã thử tìm trong:" | tee -a ${OUTPUT_FILE}
            echo "    - VM info từ VBoxManage" | tee -a ${OUTPUT_FILE}
            echo "    - $HOME/VirtualBox VMs/${VM_NAME}/" | tee -a ${OUTPUT_FILE}
            echo "    - E:/VB/mayao/${VM_NAME}/" | tee -a ${OUTPUT_FILE}
            echo "  💡 Gợi ý: Set biến môi trường VDI_PATH='E:/VB/mayao/ubuntu/ubuntu.vdi'" | tee -a ${OUTPUT_FILE}
        fi
        echo "" | tee -a ${OUTPUT_FILE}
    else
        echo "1. Kích thước file .vdi của VM:" | tee -a ${OUTPUT_FILE}
        echo "  ⚠️  VBoxManage không tìm thấy. Không thể đo kích thước .vdi." | tee -a ${OUTPUT_FILE}
        echo "  Vui lòng cài VirtualBox hoặc cung cấp đường dẫn đến VBoxManage.exe" | tee -a ${OUTPUT_FILE}
        echo "" | tee -a ${OUTPUT_FILE}
    fi
    
    # Dung lượng đĩa trong VM
    echo "2. Dung lượng đĩa trong VM (qua SSH):" | tee -a ${OUTPUT_FILE}
    
    # Cấu hình SSH từ biến môi trường
    VM_SSH=${VM_SSH:-"vm-ubuntu"}
    VM_SSH_PORT=${VM_SSH_PORT:-"2222"}
    
    # Dùng SSH config nếu là vm-ubuntu
    if [ "$VM_SSH" = "vm-ubuntu" ]; then
        SSH_CMD="ssh vm-ubuntu"
    else
        SSH_CMD="ssh -p ${VM_SSH_PORT} -o StrictHostKeyChecking=no ${VM_SSH}"
    fi
    
    echo "  Disk usage tổng thể:" | tee -a ${OUTPUT_FILE}
    $SSH_CMD "df -h" 2>/dev/null | tee -a ${OUTPUT_FILE} || echo "  Không thể kết nối SSH" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Tìm thư mục ứng dụng
    echo "  Tìm thư mục ứng dụng:" | tee -a ${OUTPUT_FILE}
    
    # Tìm từ working directory của process đang chạy
    APP_DIR=$($SSH_CMD "pgrep -f 'user_interface.py' | head -1 | xargs -I {} readlink -f /proc/{}/cwd 2>/dev/null | xargs dirname 2>/dev/null" 2>/dev/null)
    
    # Nếu không tìm được, tìm từ file user_interface.py
    if [ -z "$APP_DIR" ]; then
        APP_DIR=$($SSH_CMD "find /home -name 'user_interface.py' -type f 2>/dev/null | head -1 | xargs dirname 2>/dev/null | xargs dirname 2>/dev/null" 2>/dev/null)
    fi
    
    # Nếu vẫn không tìm được, thử các thư mục phổ biến
    if [ -z "$APP_DIR" ]; then
        for dir in /home/sysadmin/Desktop/OSProjectAutoMulChoice /home/sysadmin/OSProjectAutoMulChoice /opt/exam-automated /opt/exam-grading; do
            if $SSH_CMD "test -d $dir" 2>/dev/null; then
                APP_DIR="$dir"
                break
            fi
        done
    fi
    
    if [ -n "$APP_DIR" ]; then
        echo "  Thư mục ứng dụng: $APP_DIR" | tee -a ${OUTPUT_FILE}
        echo "  Dung lượng:" | tee -a ${OUTPUT_FILE}
        $SSH_CMD "du -sh $APP_DIR 2>/dev/null" | tee -a ${OUTPUT_FILE} || echo "  Không thể đo dung lượng" | tee -a ${OUTPUT_FILE}
        
        # Đo chi tiết các thư mục con
        echo "" | tee -a ${OUTPUT_FILE}
        echo "  Dung lượng các thư mục con:" | tee -a ${OUTPUT_FILE}
        $SSH_CMD "cd $APP_DIR && du -sh */ 2>/dev/null | sort -h" | tee -a ${OUTPUT_FILE} || true
    else
        echo "  Không tìm thấy thư mục ứng dụng" | tee -a ${OUTPUT_FILE}
        echo "  Thử các thư mục phổ biến:" | tee -a ${OUTPUT_FILE}
        for dir in /home/sysadmin/Desktop/OSProjectAutoMulChoice /home/sysadmin/OSProjectAutoMulChoice /opt/exam-automated /opt/exam-grading /home/sysadmin; do
            $SSH_CMD "test -d $dir && echo \"$dir:\" && du -sh $dir 2>/dev/null" | tee -a ${OUTPUT_FILE} || true
        done
    fi
    echo "" | tee -a ${OUTPUT_FILE}
fi

echo "" | tee -a ${OUTPUT_FILE}
echo "Kết quả đã được lưu vào: ${OUTPUT_FILE}" | tee -a ${OUTPUT_FILE}


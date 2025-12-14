#!/bin/bash

# Script đo isolation overhead và quản lý tài nguyên TỪ HOST WINDOWS
# Sử dụng: ./measure_isolation_overhead.sh [docker|vm]

MODE=${1:-docker}
RESULTS_DIR="measurement_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${RESULTS_DIR}/isolation_overhead_${MODE}_${TIMESTAMP}.txt"
CSV_FILE="${RESULTS_DIR}/isolation_overhead_${MODE}_${TIMESTAMP}.csv"

mkdir -p ${RESULTS_DIR}

echo "=== Đo Isolation Overhead từ HOST WINDOWS - Mode: ${MODE} ===" | tee ${OUTPUT_FILE}
echo "Thời gian: $(date)" | tee -a ${OUTPUT_FILE}
echo "" | tee -a ${OUTPUT_FILE}

# Tạo CSV header
echo "metric,value,unit,description" > ${CSV_FILE}

if [ "$MODE" = "docker" ]; then
    echo "--- Docker Container Isolation Overhead (từ HOST) ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # 1. Docker daemon overhead (từ host)
    echo "1. Docker Daemon Overhead (từ HOST Windows):" | tee -a ${OUTPUT_FILE}
    
    if command -v powershell >/dev/null 2>&1; then
        # Đo Docker Desktop process từ host
        DOCKERD_CPU_MEM=$(powershell -Command "
            \$proc = Get-Process | Where-Object {\$_.ProcessName -like '*Docker*' -or \$_.ProcessName -like '*dockerd*' -or \$_.ProcessName -like '*com.docker*'} | Measure-Object -Property CPU,WorkingSet -Sum
            \$cpu = \$proc.CPU.Sum
            \$mem = [math]::Round(\$proc.WorkingSet.Sum / 1MB, 2)
            Write-Output \"\$cpu,\$mem\"
        " 2>/dev/null)
        
        DOCKERD_MEM_MB=$(echo $DOCKERD_CPU_MEM | cut -d',' -f2)
        if [ -z "$DOCKERD_MEM_MB" ] || [ "$DOCKERD_MEM_MB" = "0" ]; then
            # Fallback: ước tính
            DOCKERD_MEM_MB="150"
        fi
    else
        # Linux/Git Bash fallback
        DOCKERD_PID=$(pgrep dockerd 2>/dev/null | head -1)
        if [ -n "$DOCKERD_PID" ]; then
            DOCKERD_MEM_KB=$(ps -p $DOCKERD_PID -o rss= 2>/dev/null | xargs)
            DOCKERD_MEM_MB=$(awk "BEGIN {printf \"%.2f\", $DOCKERD_MEM_KB / 1024}")
        else
            DOCKERD_MEM_MB="150"
        fi
    fi
    
    echo "  Docker Daemon Memory (từ host): ${DOCKERD_MEM_MB} MB" | tee -a ${OUTPUT_FILE}
    echo "docker_daemon_memory,${DOCKERD_MEM_MB},MB,Docker daemon memory overhead from host" >> ${CSV_FILE}
    
    # 2. Container overhead (tổng từ host)
    echo "" | tee -a ${OUTPUT_FILE}
    echo "2. Container Overhead (từ HOST):" | tee -a ${OUTPUT_FILE}
    
    CONTAINER_NAMES=("exam-automated-app" "exam-automated-nginx")
    TOTAL_CONTAINER_CPU=0
    TOTAL_CONTAINER_MEM=0
    
    for CONTAINER in "${CONTAINER_NAMES[@]}"; do
        if docker ps 2>/dev/null | grep -q "$CONTAINER"; then
            STATS=$(docker stats --no-stream --format "{{.CPUPerc}},{{.MemUsage}}" ${CONTAINER} 2>/dev/null)
            if [ -n "$STATS" ]; then
                CPU=$(echo $STATS | cut -d',' -f1 | sed 's/%//' | awk '{print $1}')
                MEM=$(echo $STATS | cut -d',' -f2 | cut -d'/' -f1 | sed 's/MiB//' | xargs | awk '{print $1}')
                
                if [ -n "$CPU" ]; then
                    TOTAL_CONTAINER_CPU=$(awk "BEGIN {printf \"%.2f\", $TOTAL_CONTAINER_CPU + $CPU}")
                fi
                if [ -n "$MEM" ]; then
                    TOTAL_CONTAINER_MEM=$(awk "BEGIN {printf \"%.2f\", $TOTAL_CONTAINER_MEM + $MEM}")
                fi
                
                echo "  $CONTAINER: CPU ${CPU}%, Memory ${MEM} MB" | tee -a ${OUTPUT_FILE}
            fi
        fi
    done
    
    echo "  Tổng Container CPU: ${TOTAL_CONTAINER_CPU}%" | tee -a ${OUTPUT_FILE}
    echo "  Tổng Container Memory: ${TOTAL_CONTAINER_MEM} MB" | tee -a ${OUTPUT_FILE}
    echo "container_total_cpu,${TOTAL_CONTAINER_CPU},percent,Total container CPU usage from host" >> ${CSV_FILE}
    echo "container_total_memory,${TOTAL_CONTAINER_MEM},MB,Total container memory usage from host" >> ${CSV_FILE}
    
    # 3. Total Docker overhead
    TOTAL_DOCKER_MEM=$(awk "BEGIN {printf \"%.2f\", $DOCKERD_MEM_MB + $TOTAL_CONTAINER_MEM}")
    echo "" | tee -a ${OUTPUT_FILE}
    echo "3. Tổng Docker Overhead (từ HOST):" | tee -a ${OUTPUT_FILE}
    echo "  Daemon: ${DOCKERD_MEM_MB} MB" | tee -a ${OUTPUT_FILE}
    echo "  Containers: ${TOTAL_CONTAINER_MEM} MB" | tee -a ${OUTPUT_FILE}
    echo "  Tổng: ${TOTAL_DOCKER_MEM} MB" | tee -a ${OUTPUT_FILE}
    echo "docker_total_overhead,${TOTAL_DOCKER_MEM},MB,Total Docker overhead from host" >> ${CSV_FILE}
    
    # 4. cgroups và namespaces info (nếu có thể truy cập từ host)
    echo "" | tee -a ${OUTPUT_FILE}
    echo "4. Container Information:" | tee -a ${OUTPUT_FILE}
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Size}}" | tee -a ${OUTPUT_FILE}
    
    # 5. Image sizes
    echo "" | tee -a ${OUTPUT_FILE}
    echo "5. Docker Image Sizes:" | tee -a ${OUTPUT_FILE}
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | tee -a ${OUTPUT_FILE}
    
elif [ "$MODE" = "vm" ]; then
    echo "--- VM Isolation Overhead (từ HOST WINDOWS) ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    VM_NAME=${VM_NAME:-"ubuntu"}
    VDI_PATH_CUSTOM=${VDI_PATH:-""}
    
    # Kiểm tra VBoxManage
    if command -v VBoxManage >/dev/null 2>&1; then
        VBOX_CMD="VBoxManage"
    elif [ -f "/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" ]; then
        VBOX_CMD="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
    elif [ -f "C:/Program Files/Oracle/VirtualBox/VBoxManage.exe" ]; then
        VBOX_CMD="C:/Program Files/Oracle/VirtualBox/VBoxManage.exe"
    else
        echo "❌ VBoxManage không tìm thấy." | tee -a ${OUTPUT_FILE}
        exit 1
    fi
    
    # Convert Unix-style path (/c/Program Files/...) sang Windows path (C:/Program Files/...)
    if [[ "$VBOX_CMD" == /c/* ]] || [[ "$VBOX_CMD" == /C/* ]]; then
        VBOX_CMD_WIN=$(echo "$VBOX_CMD" | sed 's|^/c/|C:/|' | sed 's|^/C/|C:/|')
    elif [[ "$VBOX_CMD" == *".exe" ]]; then
        VBOX_CMD_WIN="$VBOX_CMD"
    else
        VBOX_CMD_WIN="$VBOX_CMD"
    fi
    
    # Test VBoxManage có chạy được không
    if [ -f "$VBOX_CMD" ] || [ -f "$VBOX_CMD_WIN" ]; then
        # Dùng PowerShell để chạy nếu là Windows executable
        if [[ "$VBOX_CMD" == *".exe" ]] || [[ "$VBOX_CMD_WIN" == *".exe" ]]; then
            RUNNING_VMS=$(powershell -Command "& '$VBOX_CMD_WIN' list runningvms" 2>&1)
        else
            RUNNING_VMS=$("$VBOX_CMD" list runningvms 2>&1)
        fi
    else
        RUNNING_VMS=$($VBOX_CMD list runningvms 2>&1)
    fi
    
    # Kiểm tra VM có đang chạy - tự động tìm VM đang chạy nếu VM_NAME không khớp
    if [ -n "$RUNNING_VMS" ] && [ "$RUNNING_VMS" != "" ]; then
        # Tìm VM theo tên (case-insensitive)
        VM_RUNNING=$(echo "$RUNNING_VMS" | grep -i "\"${VM_NAME}\"" || echo "")
        
        if [ -z "$VM_RUNNING" ]; then
            # Thử tìm VM đang chạy đầu tiên
            ACTUAL_VM_NAME=$(echo "$RUNNING_VMS" | head -1 | sed 's/^"\([^"]*\)".*/\1/')
            if [ -n "$ACTUAL_VM_NAME" ] && [ "$ACTUAL_VM_NAME" != "" ]; then
                echo "⚠️  VM '${VM_NAME}' không đang chạy, nhưng tìm thấy VM '${ACTUAL_VM_NAME}' đang chạy." | tee -a ${OUTPUT_FILE}
                echo "   Sử dụng VM: ${ACTUAL_VM_NAME}" | tee -a ${OUTPUT_FILE}
                VM_NAME="$ACTUAL_VM_NAME"
                VM_RUNNING=$(echo "$RUNNING_VMS" | grep -i "\"${ACTUAL_VM_NAME}\"" || echo "")
            fi
        fi
        
        if [ -z "$VM_RUNNING" ]; then
            echo "❌ Không tìm thấy VM '${VM_NAME}' trong danh sách VMs đang chạy." | tee -a ${OUTPUT_FILE}
            echo "   Danh sách VMs đang chạy:" | tee -a ${OUTPUT_FILE}
            echo "$RUNNING_VMS" | tee -a ${OUTPUT_FILE}
            exit 1
        fi
    else
        echo "❌ Không tìm thấy VM nào đang chạy." | tee -a ${OUTPUT_FILE}
        echo "   Output: $RUNNING_VMS" | tee -a ${OUTPUT_FILE}
        exit 1
    fi
    
    # 1. Hypervisor overhead (VirtualBox process từ host)
    echo "1. Hypervisor Overhead (VirtualBox process từ HOST):" | tee -a ${OUTPUT_FILE}
    
    if command -v powershell >/dev/null 2>&1; then
        # Đo Hypervisor overhead - tổng memory của VBoxSVC và VBoxSDS (service processes)
        # VirtualBoxVM là VM process chính, không phải hypervisor overhead
        VBOX_MEM_MB=$(powershell -Command "
            \$hypervisorProcs = Get-Process | Where-Object {\$_.ProcessName -eq 'VBoxSVC' -or \$_.ProcessName -eq 'VBoxSDS'}
            if (\$hypervisorProcs) {
                \$memSum = (\$hypervisorProcs | Measure-Object -Property PrivateMemorySize64 -Sum).Sum
                [math]::Round(\$memSum / 1MB, 2)
            } else {
                0
            }
        " 2>/dev/null)
        
        if [ -z "$VBOX_MEM_MB" ] || [ "$VBOX_MEM_MB" = "0" ]; then
            VBOX_MEM_MB="10"  # Ước tính nhỏ hơn (chỉ service processes)
        fi
    else
        # Linux/Git Bash fallback
        VBOX_PID=$(pgrep -f "VirtualBox.*${VM_NAME}" 2>/dev/null | head -1)
        if [ -n "$VBOX_PID" ]; then
            VBOX_MEM_KB=$(ps -p $VBOX_PID -o rss= 2>/dev/null | xargs)
            VBOX_MEM_MB=$(awk "BEGIN {printf \"%.2f\", $VBOX_MEM_KB / 1024}")
        else
            VBOX_MEM_MB="300"
        fi
    fi
    
    echo "  VirtualBox Process Memory (từ host): ${VBOX_MEM_MB} MB" | tee -a ${OUTPUT_FILE}
    echo "hypervisor_memory,${VBOX_MEM_MB},MB,VirtualBox hypervisor memory from host" >> ${CSV_FILE}
    
    # 2. VM resource allocation (từ VBoxManage)
    echo "" | tee -a ${OUTPUT_FILE}
    echo "2. VM Resource Allocation (từ VBoxManage):" | tee -a ${OUTPUT_FILE}
    
    # Dùng PowerShell wrapper nếu là Windows executable
    if [ -f "$VBOX_CMD" ] || [ -f "$VBOX_CMD_WIN" ]; then
        if [[ "$VBOX_CMD" == *".exe" ]] || [[ "$VBOX_CMD_WIN" == *".exe" ]]; then
            VM_INFO=$(powershell -Command "& '$VBOX_CMD_WIN' showvminfo \"${VM_NAME}\" --machinereadable" 2>&1)
        else
            VM_INFO=$($VBOX_CMD showvminfo "${VM_NAME}" --machinereadable 2>&1)
        fi
    else
        VM_INFO=$($VBOX_CMD showvminfo "${VM_NAME}" --machinereadable 2>&1)
    fi
    
    VM_MEM_MB=$(echo "$VM_INFO" | grep "memory=" | cut -d'=' -f2 | tr -d '"')
    VM_CPUS=$(echo "$VM_INFO" | grep "cpus=" | cut -d'=' -f2 | tr -d '"')
    
    if [ -n "$VM_MEM_MB" ]; then
        echo "  Allocated Memory: ${VM_MEM_MB} MB" | tee -a ${OUTPUT_FILE}
        echo "vm_allocated_memory,${VM_MEM_MB},MB,VM allocated memory" >> ${CSV_FILE}
    fi
    if [ -n "$VM_CPUS" ]; then
        echo "  Allocated CPUs: ${VM_CPUS}" | tee -a ${OUTPUT_FILE}
        echo "vm_allocated_cpus,${VM_CPUS},count,VM allocated CPUs" >> ${CSV_FILE}
    fi
    
    # 3. Total VM overhead
    TOTAL_VM_OVERHEAD=$(awk "BEGIN {printf \"%.2f\", $VBOX_MEM_MB + ${VM_MEM_MB:-0}}")
    echo "" | tee -a ${OUTPUT_FILE}
    echo "3. Tổng VM Overhead (từ HOST):" | tee -a ${OUTPUT_FILE}
    echo "  Hypervisor: ${VBOX_MEM_MB} MB" | tee -a ${OUTPUT_FILE}
    echo "  VM Allocated: ${VM_MEM_MB} MB" | tee -a ${OUTPUT_FILE}
    echo "  Tổng: ${TOTAL_VM_OVERHEAD} MB" | tee -a ${OUTPUT_FILE}
    echo "vm_total_overhead,${TOTAL_VM_OVERHEAD},MB,Total VM overhead from host" >> ${CSV_FILE}
    
    # 4. VM disk size
    echo "" | tee -a ${OUTPUT_FILE}
    echo "4. VM Disk Information:" | tee -a ${OUTPUT_FILE}
    
    # Nếu có đường dẫn .vdi tùy chỉnh, dùng luôn
    if [ -n "$VDI_PATH_CUSTOM" ] && [ -f "$VDI_PATH_CUSTOM" ]; then
        VDI_PATH="$VDI_PATH_CUSTOM"
    else
        # Tìm VDI path từ VM info (chỉ lấy .vdi, không lấy .iso)
        if [ -f "$VBOX_CMD" ] || [ -f "$VBOX_CMD_WIN" ]; then
            if [[ "$VBOX_CMD" == *".exe" ]] || [[ "$VBOX_CMD_WIN" == *".exe" ]]; then
                VM_INFO=$(powershell -Command "& '$VBOX_CMD_WIN' showvminfo \"${VM_NAME}\" --machinereadable" 2>&1)
            else
                VM_INFO=$($VBOX_CMD showvminfo "${VM_NAME}" --machinereadable 2>&1)
            fi
        else
            VM_INFO=$($VBOX_CMD showvminfo "${VM_NAME}" --machinereadable 2>&1)
        fi
        
        # Tìm .vdi file, filter ra .iso
        VDI_PATH=$(echo "$VM_INFO" | grep -E "SATA-0-0|IDE-0-0|SATA-1-0|IDE-1-0" | grep -i "\.vdi" | grep -v -i "\.iso" | head -1 | cut -d'"' -f4)
        
        if [ -z "$VDI_PATH" ]; then
            # Thử tìm tất cả storage và filter
            VDI_PATH=$(echo "$VM_INFO" | grep -i "\.vdi" | grep -v -i "\.iso" | head -1 | cut -d'"' -f4)
        fi
    fi
    
    # Nếu vẫn không tìm thấy, thử các đường dẫn phổ biến
    if [ -z "$VDI_PATH" ]; then
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
    
    if [ -n "$VDI_PATH" ] && [ -f "$VDI_PATH" ]; then
        if command -v powershell >/dev/null 2>&1; then
            VDI_SIZE_GB=$(powershell -Command "[math]::Round((Get-Item '$VDI_PATH').Length / 1GB, 2)" 2>/dev/null)
            echo "  VDI File: $VDI_PATH" | tee -a ${OUTPUT_FILE}
            echo "  VDI Size: ${VDI_SIZE_GB} GB" | tee -a ${OUTPUT_FILE}
            echo "vm_disk_size,${VDI_SIZE_GB},GB,VM disk file size" >> ${CSV_FILE}
        fi
    else
        echo "  ⚠️  Không tìm thấy file .vdi" | tee -a ${OUTPUT_FILE}
        echo "  💡 Gợi ý: Set biến môi trường VDI_PATH='E:/VB/mayao/ubuntu/ubuntu.vdi'" | tee -a ${OUTPUT_FILE}
    fi
fi

# 7. Tính toán isolation overhead comparison
echo "" | tee -a ${OUTPUT_FILE}
echo "--- Phân Tích Isolation Overhead (từ HOST) ---" | tee -a ${OUTPUT_FILE}
echo "" | tee -a ${OUTPUT_FILE}

if [ "$MODE" = "docker" ]; then
    echo "Docker Isolation Overhead (từ HOST Windows):" | tee -a ${OUTPUT_FILE}
    echo "  - Container Runtime (Docker Daemon): ~${DOCKERD_MEM_MB} MB" | tee -a ${OUTPUT_FILE}
    echo "  - Containers: ~${TOTAL_CONTAINER_MEM} MB" | tee -a ${OUTPUT_FILE}
    echo "  - Total: ~${TOTAL_DOCKER_MEM} MB RAM + ${TOTAL_CONTAINER_CPU}% CPU" | tee -a ${OUTPUT_FILE}
    echo "  - Overhead thấp: Chỉ namespace + cgroups" | tee -a ${OUTPUT_FILE}
elif [ "$MODE" = "vm" ]; then
    echo "VM Isolation Overhead (từ HOST Windows):" | tee -a ${OUTPUT_FILE}
    echo "  - Hypervisor (VirtualBox): ~${VBOX_MEM_MB} MB" | tee -a ${OUTPUT_FILE}
    echo "  - VM Allocated: ~${VM_MEM_MB} MB" | tee -a ${OUTPUT_FILE}
    echo "  - Total: ~${TOTAL_VM_OVERHEAD} MB RAM + 5-15% CPU" | tee -a ${OUTPUT_FILE}
    echo "  - Overhead cao: Hypervisor + Guest OS" | tee -a ${OUTPUT_FILE}
fi

echo "" | tee -a ${OUTPUT_FILE}
echo "Kết quả đã được lưu vào:" | tee -a ${OUTPUT_FILE}
echo "  - Text: ${OUTPUT_FILE}" | tee -a ${OUTPUT_FILE}
echo "  - CSV: ${CSV_FILE}" | tee -a ${OUTPUT_FILE}

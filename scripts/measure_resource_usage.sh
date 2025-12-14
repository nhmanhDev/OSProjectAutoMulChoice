#!/bin/bash

# Script đo mức sử dụng RAM và CPU từ HOST WINDOWS (không đo từ bên trong)
# Sử dụng: ./measure_resource_usage.sh [docker|vm] [duration_seconds]

MODE=${1:-docker}
DURATION=${2:-60}  # Mặc định đo trong 60 giây
RESULTS_DIR="measurement_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${RESULTS_DIR}/resource_usage_${MODE}_${TIMESTAMP}.txt"
CSV_FILE="${RESULTS_DIR}/resource_usage_${MODE}_${TIMESTAMP}.csv"

mkdir -p ${RESULTS_DIR}

echo "=== Đo mức sử dụng RAM và CPU từ HOST WINDOWS - Mode: ${MODE} ===" | tee ${OUTPUT_FILE}
echo "Thời gian đo: ${DURATION} giây" | tee -a ${OUTPUT_FILE}
echo "Thời gian bắt đầu: $(date)" | tee -a ${OUTPUT_FILE}
echo "" | tee -a ${OUTPUT_FILE}

# Tạo file CSV header
echo "timestamp,cpu_percent,memory_mb,memory_percent" > ${CSV_FILE}

if [ "$MODE" = "docker" ]; then
    echo "--- Đo tài nguyên Docker Container từ HOST ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    # Đảm bảo container đang chạy
    if ! docker ps 2>/dev/null | grep -q exam-automated; then
        echo "Khởi động container..." | tee -a ${OUTPUT_FILE}
        docker compose -f deployment/docker-compose.yml up -d 2>&1 | tee -a ${OUTPUT_FILE}
        sleep 10
    fi
    
    CONTAINER_NAMES=("exam-automated-app" "exam-automated-nginx")
    
    echo "Đang đo từ HOST trong ${DURATION} giây..." | tee -a ${OUTPUT_FILE}
    echo "Timestamp,Container,CPU %,Memory (MB),Memory %" | tee -a ${OUTPUT_FILE}
    
    START_TIME=$(date +%s)
    END_TIME=$((START_TIME + DURATION))
    
    # Lấy tổng memory của host để tính phần trăm
    if command -v powershell >/dev/null 2>&1; then
        TOTAL_MEM_MB=$(powershell -Command "[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB)" 2>/dev/null || echo "8192")
    else
        TOTAL_MEM_MB="8192"  # Default 8GB
    fi
    
    while [ $(date +%s) -lt $END_TIME ]; do
        TIMESTAMP_NOW=$(date +%Y-%m-%d\ %H:%M:%S)
        TOTAL_CPU=0
        TOTAL_MEM=0
        
        for CONTAINER in "${CONTAINER_NAMES[@]}"; do
            # Đo từ host bằng docker stats
            STATS=$(docker stats --no-stream --format "{{.CPUPerc}},{{.MemUsage}}" ${CONTAINER} 2>/dev/null)
            if [ -n "$STATS" ]; then
                CPU=$(echo $STATS | cut -d',' -f1 | sed 's/%//' | awk '{print $1}')
                MEM_USAGE=$(echo $STATS | cut -d',' -f2 | cut -d'/' -f1 | sed 's/MiB//' | xargs | awk '{print $1}')
                
                if [ -n "$CPU" ] && [ "$CPU" != "0" ]; then
                    TOTAL_CPU=$(awk "BEGIN {printf \"%.2f\", $TOTAL_CPU + $CPU}")
                fi
                if [ -n "$MEM_USAGE" ] && [ "$MEM_USAGE" != "0" ]; then
                    TOTAL_MEM=$(awk "BEGIN {printf \"%.2f\", $TOTAL_MEM + $MEM_USAGE}")
                fi
                
                echo "$TIMESTAMP_NOW,$CONTAINER,$CPU,$MEM_USAGE" | tee -a ${OUTPUT_FILE}
            fi
        done
        
        # Tính memory percent từ host
        if [ -n "$TOTAL_MEM" ] && [ "$TOTAL_MEM" != "0" ] && [ "$TOTAL_MEM_MB" != "0" ]; then
            MEM_PERC=$(awk "BEGIN {printf \"%.2f\", ($TOTAL_MEM * 100) / $TOTAL_MEM_MB}")
        else
            MEM_PERC="0"
        fi
        
        # Lưu tổng vào CSV
        echo "$(date +%s),$TOTAL_CPU,$TOTAL_MEM,$MEM_PERC" >> ${CSV_FILE}
        
        sleep 1
    done
    
    echo "" | tee -a ${OUTPUT_FILE}
    echo "--- Thống kê tổng hợp ---" | tee -a ${OUTPUT_FILE}
    echo "Tổng CPU: $TOTAL_CPU%" | tee -a ${OUTPUT_FILE}
    echo "Tổng Memory: $TOTAL_MEM MB ($MEM_PERC%)" | tee -a ${OUTPUT_FILE}
    
elif [ "$MODE" = "vm" ]; then
    echo "--- Đo tài nguyên VM từ HOST WINDOWS ---" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
    VM_NAME=${VM_NAME:-"ubuntu"}
    
    # Kiểm tra VM có đang chạy không
    if command -v VBoxManage >/dev/null 2>&1; then
        VBOX_CMD="VBoxManage"
    elif [ -f "/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" ]; then
        VBOX_CMD="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
    elif [ -f "C:/Program Files/Oracle/VirtualBox/VBoxManage.exe" ]; then
        VBOX_CMD="C:/Program Files/Oracle/VirtualBox/VBoxManage.exe"
    else
        echo "❌ VBoxManage không tìm thấy. Không thể đo VM từ host." | tee -a ${OUTPUT_FILE}
        echo "   Đã thử tìm trong:" | tee -a ${OUTPUT_FILE}
        echo "   - PATH" | tee -a ${OUTPUT_FILE}
        echo "   - /c/Program Files/Oracle/VirtualBox/VBoxManage.exe" | tee -a ${OUTPUT_FILE}
        echo "   - C:/Program Files/Oracle/VirtualBox/VBoxManage.exe" | tee -a ${OUTPUT_FILE}
        exit 1
    fi
    
    # Test VBoxManage có chạy được không
    echo "Đang kiểm tra VBoxManage..." | tee -a ${OUTPUT_FILE}
    
    # Convert Unix-style path (/c/Program Files/...) sang Windows path (C:/Program Files/...)
    if [[ "$VBOX_CMD" == /c/* ]] || [[ "$VBOX_CMD" == /C/* ]]; then
        VBOX_CMD_WIN=$(echo "$VBOX_CMD" | sed 's|^/c/|C:/|' | sed 's|^/C/|C:/|')
    elif [[ "$VBOX_CMD" == *".exe" ]]; then
        VBOX_CMD_WIN="$VBOX_CMD"
    else
        VBOX_CMD_WIN="$VBOX_CMD"
    fi
    
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
    
    # Debug: hiển thị output
    echo "Output của 'VBoxManage list runningvms':" | tee -a ${OUTPUT_FILE}
    echo "$RUNNING_VMS" | tee -a ${OUTPUT_FILE}
    echo "" | tee -a ${OUTPUT_FILE}
    
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
    
    echo "VM đang chạy: ${VM_NAME}" | tee -a ${OUTPUT_FILE}
    echo "Đang đo từ HOST trong ${DURATION} giây..." | tee -a ${OUTPUT_FILE}
    echo "Timestamp,CPU %,Memory (MB),Memory %" | tee -a ${OUTPUT_FILE}
    
    # Lấy tổng memory của host
    if command -v powershell >/dev/null 2>&1; then
        TOTAL_MEM_MB=$(powershell -Command "[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB)" 2>/dev/null || echo "8192")
    else
        TOTAL_MEM_MB="8192"
    fi
    
    START_TIME=$(date +%s)
    END_TIME=$((START_TIME + DURATION))
    DEBUG_DONE=0  # Flag để debug chỉ 1 lần
    
    while [ $(date +%s) -lt $END_TIME ]; do
        TIMESTAMP_NOW=$(date +%Y-%m-%d\ %H:%M:%S)
        
        # Đo VirtualBox process từ host Windows
        if command -v powershell >/dev/null 2>&1; then
            # Debug: Liệt kê tất cả VirtualBox processes ở lần đo đầu tiên
            if [ "$DEBUG_DONE" = "0" ]; then
                echo "Debug: Đang tìm VirtualBox processes..." | tee -a ${OUTPUT_FILE}
                powershell -Command "Get-Process | Where-Object {\$_.ProcessName -like '*VirtualBox*' -or \$_.ProcessName -like '*VBox*'} | Select-Object ProcessName, Id, PrivateMemorySize64 | Format-Table" 2>&1 | tee -a ${OUTPUT_FILE}
                DEBUG_DONE=1
            fi
            
            # Đo CPU % và Memory trực tiếp từ PowerShell - Tìm process chạy VM
            CPU_MEM=$(powershell -Command "
                # Tìm tất cả VirtualBox processes
                \$allProcs = Get-Process | Where-Object {\$_.ProcessName -like '*VirtualBox*' -or \$_.ProcessName -like '*VBox*'}
                
                # Tìm process chính chạy VM (ưu tiên VBoxHeadless, sau đó VirtualBox, cuối cùng là process có memory lớn nhất)
                \$vmProc = \$null
                
                # Thử tìm VBoxHeadless trước (headless mode)
                \$vmProc = \$allProcs | Where-Object {\$_.ProcessName -eq 'VBoxHeadless'} | Select-Object -First 1
                
                # Nếu không có, tìm VirtualBox.exe (GUI mode)
                if (-not \$vmProc) {
                    \$vmProc = \$allProcs | Where-Object {\$_.ProcessName -eq 'VirtualBox'} | Select-Object -First 1
                }
                
                # Nếu vẫn không có, lấy process có memory lớn nhất (thường là VM process)
                if (-not \$vmProc -and \$allProcs) {
                    \$vmProc = \$allProcs | Sort-Object PrivateMemorySize64 -Descending | Select-Object -First 1
                }
                
                if (\$vmProc) {
                    # CPU % - dùng Get-Counter (có thể fail, sẽ fallback)
                    \$cpuPerc = 0
                    try {
                        \$procName = \$vmProc.ProcessName
                        \$counter = Get-Counter \"\\Process(\$procName)\\% Processor Time\" -ErrorAction SilentlyContinue
                        if (\$counter) {
                            \$cpu = \$counter.CounterSamples[0].CookedValue
                            if (\$cpu) { \$cpuPerc = \$cpu }
                        }
                    } catch {
                        # Fallback: sẽ tính sau bằng CPU time diff
                    }
                    
                    # Memory - dùng PrivateMemorySize64 (memory thực tế, khớp Task Manager)
                    \$memMB = [math]::Round(\$vmProc.PrivateMemorySize64 / 1MB, 2)
                    
                    Write-Output \"\$cpuPerc,\$memMB\"
                } else {
                    Write-Output \"0,0\"
                }
            " 2>/dev/null)
            
            # Parse CPU và Memory
            CPU_PERC=$(echo $CPU_MEM | cut -d',' -f1)
            MEM_MB=$(echo $CPU_MEM | cut -d',' -f2)
            
            # Nếu CPU % = 0, thử cách khác (cần 2 lần đo)
            if [ -z "$CPU_PERC" ] || [ "$CPU_PERC" = "0" ] || [ "$CPU_PERC" = "" ]; then
                # Fallback: dùng cách đo CPU với 2 lần đo (tìm process có memory lớn nhất)
                if [ -z "$LAST_CPU_TIME" ]; then
                    LAST_CPU_TIME=$(powershell -Command "\$allProcs = Get-Process | Where-Object {\$_.ProcessName -like '*VirtualBox*' -or \$_.ProcessName -like '*VBox*'}; \$proc = \$allProcs | Sort-Object PrivateMemorySize64 -Descending | Select-Object -First 1; if (\$proc) { \$proc.CPU } else { 0 }" 2>/dev/null)
                    LAST_MEASURE_TIME=$(date +%s)
                    CPU_PERC="0"
                else
                    CURRENT_CPU_TIME=$(powershell -Command "\$allProcs = Get-Process | Where-Object {\$_.ProcessName -like '*VirtualBox*' -or \$_.ProcessName -like '*VBox*'}; \$proc = \$allProcs | Sort-Object PrivateMemorySize64 -Descending | Select-Object -First 1; if (\$proc) { \$proc.CPU } else { 0 }" 2>/dev/null)
                    CURRENT_TIME=$(date +%s)
                    TIME_DIFF=$(awk "BEGIN {printf \"%.2f\", $CURRENT_TIME - $LAST_MEASURE_TIME}")
                    CPU_DIFF=$(awk "BEGIN {printf \"%.2f\", $CURRENT_CPU_TIME - $LAST_CPU_TIME}")
                    
                    if [ "$TIME_DIFF" != "0" ] && [ "$CPU_DIFF" != "0" ]; then
                        CPU_CORES=$(powershell -Command "(Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors" 2>/dev/null || echo "4")
                        CPU_PERC=$(awk "BEGIN {printf \"%.2f\", ($CPU_DIFF / $TIME_DIFF) / $CPU_CORES * 100}")
                    else
                        CPU_PERC="0"
                    fi
                    
                    LAST_CPU_TIME=$CURRENT_CPU_TIME
                    LAST_MEASURE_TIME=$CURRENT_TIME
                fi
            fi
            
            # Nếu memory = 0, thử fallback (tìm process có memory lớn nhất)
            if [ -z "$MEM_MB" ] || [ "$MEM_MB" = "0" ] || [ "$MEM_MB" = "" ]; then
                MEM_MB=$(powershell -Command "\$allProcs = Get-Process | Where-Object {\$_.ProcessName -like '*VirtualBox*' -or \$_.ProcessName -like '*VBox*'}; \$proc = \$allProcs | Sort-Object PrivateMemorySize64 -Descending | Select-Object -First 1; if (\$proc) { [math]::Round(\$proc.PrivateMemorySize64 / 1MB, 2) } else { 0 }" 2>/dev/null)
            fi
        else
            # Fallback cho Linux/Git Bash
            VBOX_PID=$(pgrep -f "VirtualBox.*${VM_NAME}" 2>/dev/null | head -1)
            if [ -n "$VBOX_PID" ]; then
                CPU_PERC=$(ps -p $VBOX_PID -o %cpu= 2>/dev/null | xargs || echo "0")
                MEM_KB=$(ps -p $VBOX_PID -o rss= 2>/dev/null | xargs || echo "0")
                MEM_MB=$(awk "BEGIN {printf \"%.2f\", $MEM_KB / 1024}")
            else
                CPU_PERC="0"
                MEM_MB="0"
            fi
        fi
        
        # Tính memory percent
        if [ -n "$MEM_MB" ] && [ "$MEM_MB" != "0" ] && [ "$TOTAL_MEM_MB" != "0" ]; then
            MEM_PERC=$(awk "BEGIN {printf \"%.2f\", ($MEM_MB * 100) / $TOTAL_MEM_MB}")
        else
            MEM_PERC="0"
        fi
        
        echo "$TIMESTAMP_NOW,$CPU_PERC,$MEM_MB,$MEM_PERC" | tee -a ${OUTPUT_FILE}
        echo "$(date +%s),$CPU_PERC,$MEM_MB,$MEM_PERC" >> ${CSV_FILE}
        
        sleep 1
    done
fi

echo "" | tee -a ${OUTPUT_FILE}
echo "Kết quả đã được lưu vào:" | tee -a ${OUTPUT_FILE}
echo "  - Text: ${OUTPUT_FILE}" | tee -a ${OUTPUT_FILE}
echo "  - CSV: ${CSV_FILE}" | tee -a ${OUTPUT_FILE}
echo "Thời gian kết thúc: $(date)" | tee -a ${OUTPUT_FILE}

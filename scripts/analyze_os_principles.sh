#!/bin/bash

# Script phân tích nguyên lý HĐH: Quản lý tài nguyên và Isolation
# Sử dụng: ./analyze_os_principles.sh [docker|vm|both]

MODE=${1:-both}
RESULTS_DIR="measurement_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${RESULTS_DIR}/os_principles_analysis_${TIMESTAMP}.md"

mkdir -p ${RESULTS_DIR}

cat > ${OUTPUT_FILE} << EOF
# Phân Tích Nguyên Lý HĐH: Quản Lý Tài Nguyên và Isolation Overhead
**Thời gian:** $(date)
**Mode:** ${MODE}

---

## 0. So Sánh Kiến Trúc: Ảo Hóa Phần Cứng (VM) vs Ảo Hóa Cấp HĐH (Container)

### 0.1. Kiến Trúc Ảo Hóa Phần Cứng (Hardware Virtualization - VM)

**Đặc điểm:**
- **Hypervisor**: Lớp phần mềm quản lý hardware virtualization
  - Type 1 (Bare-metal): Chạy trực tiếp trên hardware (VMware ESXi, Hyper-V)
  - Type 2 (Hosted): Chạy trên host OS (VirtualBox, VMware Workstation)
- **Guest OS**: Mỗi VM chạy một OS hoàn chỉnh với kernel riêng
- **Virtual Hardware**: CPU, RAM, Disk, Network được virtualize
- **Isolation Level**: Hardware-level (hoàn toàn cô lập)

**Ưu điểm:**
- ✅ Security isolation hoàn toàn
- ✅ Chạy được nhiều OS khác nhau trên cùng hardware
- ✅ Không phụ thuộc vào host kernel
- ✅ Phù hợp cho multi-tenant environments

**Nhược điểm:**
- ❌ Overhead cao (hypervisor + guest OS)
- ❌ Khởi động chậm (boot OS)
- ❌ Tốn tài nguyên (mỗi VM cần OS riêng)
- ❌ Khó scale

### 0.2. Kiến Trúc Ảo Hóa Cấp HĐH (OS-level Virtualization - Container)

**Đặc điểm:**
- **Container Runtime**: Quản lý containers (Docker, containerd)
- **Shared Kernel**: Tất cả containers chia sẻ kernel của host OS
- **Namespaces**: Cô lập process, network, filesystem
- **cgroups**: Giới hạn và theo dõi tài nguyên
- **Isolation Level**: Process-level (cô lập ở mức process)

**Ưu điểm:**
- ✅ Overhead thấp (chỉ namespace + cgroups)
- ✅ Khởi động nhanh (không cần boot OS)
- ✅ Tiết kiệm tài nguyên (chia sẻ kernel, COW)
- ✅ Dễ scale và quản lý
- ✅ Phù hợp cho microservices

**Nhược điểm:**
- ❌ Security isolation kém hơn VM
- ❌ Phụ thuộc vào host kernel
- ❌ Chỉ chạy được OS cùng kernel với host

### 0.3. So Sánh Tổng Quan

| Tiêu Chí | VM (Hardware Virtualization) | Container (OS-level Virtualization) |
|----------|------------------------------|-------------------------------------|
| **Kiến trúc** | Hypervisor + Guest OS | Container Runtime + Shared Kernel |
| **Isolation** | Hardware-level | Process-level |
| **Kernel** | Mỗi VM có kernel riêng | Chia sẻ kernel của host |
| **Startup Time** | 30-60 giây (boot OS) | 1-5 giây |
| **Memory Overhead** | 200-500 MB (OS + hypervisor) | 50-100 MB (runtime) |
| **CPU Overhead** | 5-15% | 1-2% |
| **Security** | Excellent (hardware isolation) | Good (namespace isolation) |
| **Portability** | Good | Excellent |
| **Use Case** | Multi-tenant, Security-critical | Microservices, CI/CD, Development |

---

## 1. Quản Lý Tài Nguyên (Resource Management)

EOF

if [ "$MODE" = "docker" ] || [ "$MODE" = "both" ]; then
    cat >> ${OUTPUT_FILE} << 'EOF'
### 1.1. Docker Container - cgroups và namespaces

**Cơ chế quản lý tài nguyên:**

#### cgroups (Control Groups)
- **CPU Management:**
  - `cpu.cfs_quota_us`: Giới hạn CPU quota
  - `cpu.cfs_period_us`: CPU period
  - `cpu.shares`: CPU shares (weight)
  
- **Memory Management:**
  - `memory.limit_in_bytes`: Giới hạn memory
  - `memory.usage_in_bytes`: Memory đang dùng
  - `memory.stat`: Thống kê memory chi tiết

- **I/O Management:**
  - `blkio.weight`: I/O weight
  - `blkio.throttle.read_bps_device`: Giới hạn read bandwidth
  - `blkio.throttle.write_bps_device`: Giới hạn write bandwidth

**Đo lường:**
EOF

    # Đo cgroups cho Docker
    CONTAINER_IDS=$(docker ps -q 2>/dev/null)
    if [ -n "$CONTAINER_IDS" ]; then
        for CID in $CONTAINER_IDS; do
            CONTAINER_NAME=$(docker ps --format "{{.Names}}" --filter "id=$CID")
            echo "" >> ${OUTPUT_FILE}
            echo "**Container: $CONTAINER_NAME ($CID)**" >> ${OUTPUT_FILE}
            echo "" >> ${OUTPUT_FILE}
            
            # CPU limits
            if [ -d "/sys/fs/cgroup/cpu/docker/$CID" ]; then
                CPU_QUOTA=$(cat /sys/fs/cgroup/cpu/docker/$CID/cpu.cfs_quota_us 2>/dev/null || echo "-1")
                CPU_PERIOD=$(cat /sys/fs/cgroup/cpu/docker/$CID/cpu.cfs_period_us 2>/dev/null || echo "100000")
                if [ "$CPU_QUOTA" != "-1" ]; then
                    CPU_LIMIT=$(awk "BEGIN {printf \"%.2f\", ($CPU_QUOTA / $CPU_PERIOD) * 100}")
                    echo "- CPU Limit: ${CPU_LIMIT}%" >> ${OUTPUT_FILE}
                else
                    echo "- CPU Limit: Unlimited" >> ${OUTPUT_FILE}
                fi
            fi
            
            # Memory limits
            if [ -d "/sys/fs/cgroup/memory/docker/$CID" ]; then
                MEM_LIMIT=$(cat /sys/fs/cgroup/memory/docker/$CID/memory.limit_in_bytes 2>/dev/null || echo "0")
                MEM_USAGE=$(cat /sys/fs/cgroup/memory/docker/$CID/memory.usage_in_bytes 2>/dev/null || echo "0")
                if [ "$MEM_LIMIT" != "0" ] && [ "$MEM_LIMIT" != "9223372036854771712" ]; then
                    MEM_LIMIT_MB=$(awk "BEGIN {printf \"%.2f\", $MEM_LIMIT / 1024 / 1024}")
                    MEM_USAGE_MB=$(awk "BEGIN {printf \"%.2f\", $MEM_USAGE / 1024 / 1024}")
                    echo "- Memory Limit: ${MEM_LIMIT_MB} MB" >> ${OUTPUT_FILE}
                    echo "- Memory Usage: ${MEM_USAGE_MB} MB" >> ${OUTPUT_FILE}
                else
                    echo "- Memory Limit: Unlimited" >> ${OUTPUT_FILE}
                fi
            fi
        done
    fi

    cat >> ${OUTPUT_FILE} << 'EOF'

#### namespaces
- **PID namespace**: Cô lập process IDs
- **Network namespace**: Cô lập network stack
- **Mount namespace**: Cô lập filesystem
- **UTS namespace**: Cô lập hostname
- **IPC namespace**: Cô lập inter-process communication
- **User namespace**: Cô lập user IDs

**Overhead:**
- CPU: ~1-2% (namespace switching)
- RAM: ~50-100 MB (container runtime)
- I/O: Minimal (shared filesystem với Copy-on-Write)

EOF
fi

if [ "$MODE" = "vm" ] || [ "$MODE" = "both" ]; then
    cat >> ${OUTPUT_FILE} << 'EOF'
### 1.2. Virtual Machine - Hypervisor

**Cơ chế quản lý tài nguyên:**

#### Hypervisor (VirtualBox Type 2)
- **Hardware Virtualization:**
  - VT-x/AMD-V: Hardware-assisted virtualization
  - Virtual CPU scheduling
  - Memory management với shadow page tables
  
- **Resource Allocation:**
  - CPU: Virtual CPUs được schedule bởi hypervisor
  - Memory: Dedicated memory cho mỗi VM
  - I/O: Virtualized devices (network, disk)

**Đo lường:**
EOF

    # Đo VM resources
    VM_SSH=${VM_SSH:-"vm-ubuntu"}
    if [ "$VM_SSH" = "vm-ubuntu" ]; then
        SSH_CMD="ssh vm-ubuntu"
    else
        SSH_CMD="ssh -p ${VM_SSH_PORT:-2222} -o StrictHostKeyChecking=no ${VM_SSH}"
    fi
    
    VM_CPU=$($SSH_CMD "nproc" 2>/dev/null)
    VM_MEM=$($SSH_CMD "free -m | grep '^Mem:' | awk '{print \$2}'" 2>/dev/null)
    VM_MEM_USED=$($SSH_CMD "free -m | grep '^Mem:' | awk '{print \$3}'" 2>/dev/null)
    
    echo "- Virtual CPUs: ${VM_CPU}" >> ${OUTPUT_FILE}
    echo "- Total Memory: ${VM_MEM} MB" >> ${OUTPUT_FILE}
    echo "- Used Memory: ${VM_MEM_USED} MB" >> ${OUTPUT_FILE}
    echo "" >> ${OUTPUT_FILE}
    
    cat >> ${OUTPUT_FILE} << 'EOF'
**Overhead:**
- CPU: ~5-15% (hypervisor + guest OS scheduling)
- RAM: ~200-500 MB (guest OS + hypervisor)
- I/O: Higher overhead (virtualized devices, emulation)

EOF
fi

cat >> ${OUTPUT_FILE} << 'EOF'
---

## 2. Chi Phí Cô Lập (Isolation Overhead)

### 2.1. Isolation Levels

| Aspect | Docker | VM |
|--------|--------|----|
| **Process Isolation** | ✅ PID namespace | ✅ Full OS isolation |
| **Network Isolation** | ✅ Network namespace | ✅ Virtual network |
| **Filesystem Isolation** | ✅ Mount namespace + COW | ✅ Virtual disk |
| **Hardware Isolation** | ❌ Shared kernel | ✅ Virtual hardware |
| **Kernel Isolation** | ❌ Shared kernel | ✅ Separate kernel |

### 2.2. Overhead Comparison

EOF

# Tính toán overhead từ dữ liệu đã đo
if [ "$MODE" = "both" ]; then
    # Tìm file isolation overhead mới nhất
    DOCKER_OVERHEAD=$(ls -t ${RESULTS_DIR}/isolation_overhead_docker_*.csv 2>/dev/null | head -1)
    VM_OVERHEAD=$(ls -t ${RESULTS_DIR}/isolation_overhead_vm_*.csv 2>/dev/null | head -1)
    
    if [ -n "$DOCKER_OVERHEAD" ] && [ -f "$DOCKER_OVERHEAD" ]; then
        DOCKER_MEM=$(grep "docker_daemon_memory" "$DOCKER_OVERHEAD" | cut -d',' -f2)
        cat >> ${OUTPUT_FILE} << EOF
**Docker Overhead:**
- Container Runtime: ~${DOCKER_MEM} MB RAM
- Namespace switching: ~1-2% CPU
- cgroups management: ~0.1% CPU
- **Total: ~${DOCKER_MEM} MB RAM + 1-2% CPU**

EOF
    fi
    
    if [ -n "$VM_OVERHEAD" ] && [ -f "$VM_OVERHEAD" ]; then
        VM_TOTAL=$(grep "total_vm_overhead" "$VM_OVERHEAD" | cut -d',' -f2)
        cat >> ${OUTPUT_FILE} << EOF
**VM Overhead:**
- Hypervisor: ~200-500 MB RAM
- Guest OS: ~${VM_TOTAL} MB RAM
- Virtual hardware: ~5-15% CPU
- **Total: ~${VM_TOTAL} MB RAM + 5-15% CPU**

EOF
    fi
fi

cat >> ${OUTPUT_FILE} << 'EOF'
### 2.3. Memory Management Comparison

#### Docker - Copy-on-Write (COW)
- **Shared Base Image**: Nhiều containers chia sẻ base image
- **Layer-based**: Chỉ lưu differences
- **Efficiency**: Tiết kiệm ~70-80% disk space

**Ví dụ:**
```
Base Image (Python): 900 MB
Container 1: +100 MB (app code)
Container 2: +100 MB (app code)
Total: 900 + 100 + 100 = 1100 MB (không phải 2000 MB)
```

#### VM - Dedicated Resources
- **Full OS**: Mỗi VM có OS riêng
- **No Sharing**: Không chia sẻ resources
- **Dedicated Memory**: Memory được allocate riêng

**Ví dụ:**
```
VM 1: 2 GB (Ubuntu + app)
VM 2: 2 GB (Ubuntu + app)
Total: 4 GB (không chia sẻ)
```

### 2.4. CPU Scheduling Comparison

#### Docker
- **Host Kernel Scheduler**: Dùng scheduler của host OS
- **cgroups CPU Shares**: Phân bổ CPU theo weight
- **Low Latency**: Không có virtualization layer
- **Context Switch**: Chỉ process context switch

#### VM
- **Hypervisor Scheduler**: Hypervisor quản lý CPU
- **Guest OS Scheduler**: Guest OS có scheduler riêng
- **Higher Latency**: Nhiều layer (Host → Hypervisor → Guest OS → Process)
- **Context Switch**: VM context switch + process context switch

---

## 3. Kết Luận

### 3.1. Quản Lý Tài Nguyên

**Docker:**
- ✅ Hiệu quả hơn (cgroups + namespaces)
- ✅ Overhead thấp (~1-2% CPU, ~50-100 MB RAM)
- ✅ Dễ scale và quản lý
- ❌ Security isolation kém hơn VM

**VM:**
- ✅ Isolation hoàn toàn (hardware-level)
- ✅ Chạy được nhiều OS khác nhau
- ❌ Overhead cao (~5-15% CPU, ~200-500 MB RAM)
- ❌ Khó scale

### 3.2. Isolation Overhead

**Docker:** ~70-80% overhead thấp hơn VM
**VM:** ~3-5x overhead cao hơn Docker nhưng isolation tốt hơn

### 3.3. Khuyến Nghị

- **Docker**: Phù hợp cho microservices, development, CI/CD
- **VM**: Phù hợp cho security-critical applications, multi-tenant

EOF

echo "✅ Đã tạo phân tích nguyên lý HĐH: ${OUTPUT_FILE}"


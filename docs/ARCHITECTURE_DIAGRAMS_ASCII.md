# Sơ Đồ Kiến Trúc và Lưu Đồ Thuật Toán (ASCII Art)
## Hệ Thống So Sánh Hiệu Năng VM và Docker

---

## 1. Kiến Trúc Tổng Thể Hệ Thống

### 1.1. Sơ Đồ Khối Tổng Quan

```
┌─────────────────────────────────────────────────────────────────┐
│                    Host Machine (Windows)                        │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              Measurement Scripts                           │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  run_all_measurements.sh                            │  │  │
│  │  │  ├── measure_startup_time.sh                        │  │  │
│  │  │  ├── measure_resource_usage.sh                      │  │  │
│  │  │  ├── measure_disk_usage.sh                          │  │  │
│  │  │  ├── measure_throughput.sh                          │  │  │
│  │  │  └── measure_isolation_overhead.sh                  │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                            │                                     │
│                            ├─────────────────┐                   │
│                            │                 │                   │
│                            ▼                 ▼                   │
│  ┌──────────────────┐  ┌──────────────────────────────────┐    │
│  │  Docker Engine   │  │      VirtualBox Hypervisor       │    │
│  │                  │  │                                  │    │
│  │  ┌────────────┐  │  │  ┌────────────────────────────┐ │    │
│  │  │  Nginx     │  │  │  │   Virtual Machine (Ubuntu) │ │    │
│  │  │  Container │  │  │  │                            │ │    │
│  │  └─────┬──────┘  │  │  │  ┌──────────────────────┐  │ │    │
│  │        │         │  │  │  │   Guest OS Kernel    │  │ │    │
│  │        │         │  │  │  └──────────┬───────────┘  │ │    │
│  │        ▼         │  │  │             │              │ │    │
│  │  ┌────────────┐  │  │  │  ┌──────────▼───────────┐  │ │    │
│  │  │  FastAPI   │  │  │  │  │   Systemd Services   │  │ │    │
│  │  │  Container │  │  │  │  └──────────┬───────────┘  │ │    │
│  │  └────────────┘  │  │  │             │              │ │    │
│  │                  │  │  │  ┌──────────▼───────────┐  │ │    │
│  │                  │  │  │  │   Nginx (Port 80)    │  │ │    │
│  │                  │  │  │  └──────────┬───────────┘  │ │    │
│  │                  │  │  │             │              │ │    │
│  │                  │  │  │  ┌──────────▼───────────┐  │ │    │
│  │                  │  │  │  │  FastAPI (Port 8000) │  │ │    │
│  │                  │  │  │  └──────────────────────┘  │ │    │
│  │                  │  │  └────────────────────────────┘ │    │
│  └──────────────────┘  └──────────────────────────────────┘    │
│                            │                                     │
│                            └─────────────┐                       │
│                                          ▼                       │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              Measurement Results                          │  │
│  │  ├── full_report_*.md                                    │  │
│  │  ├── startup_time_*.csv                                  │  │
│  │  ├── resource_usage_*.csv                                │  │
│  │  ├── throughput_*.txt                                    │  │
│  │  ├── VM/ (internal measurements)                         │  │
│  │  └── docker/ (internal measurements)                     │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. So Sánh Kiến Trúc VM vs Docker

### 2.1. Docker Container - OS-level Virtualization

```
┌─────────────────────────────────────────────────────────────┐
│                    Host OS (Windows/Linux)                   │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Linux Kernel (Shared)                     │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │         Docker Engine                            │  │  │
│  │  │  ┌───────────────────────────────────────────┐  │  │  │
│  │  │  │  Container Runtime (containerd/runc)      │  │  │  │
│  │  │  └───────────────────────────────────────────┘  │  │  │
│  │  │                                                  │  │  │
│  │  │  ┌───────────────────────────────────────────┐  │  │  │
│  │  │  │  Namespaces                               │  │  │  │
│  │  │  │  ├── PID Namespace                        │  │  │  │
│  │  │  │  ├── Network Namespace                    │  │  │  │
│  │  │  │  ├── Mount Namespace                      │  │  │  │
│  │  │  │  └── User Namespace                       │  │  │  │
│  │  │  └───────────────────────────────────────────┘  │  │  │
│  │  │                                                  │  │  │
│  │  │  ┌───────────────────────────────────────────┐  │  │  │
│  │  │  │  cgroups (Control Groups)                 │  │  │  │
│  │  │  │  ├── CPU cgroup                           │  │  │  │
│  │  │  │  ├── Memory cgroup                        │  │  │  │
│  │  │  │  └── I/O cgroup                           │  │  │  │
│  │  │  └───────────────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
│                          │                                    │
│                          ▼                                    │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Container (Isolated Process)              │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │  Application (FastAPI + Nginx)                  │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘

Overhead: ~1-2% CPU, ~50-100 MB RAM
```

### 2.2. Virtual Machine - Hardware Virtualization

```
┌─────────────────────────────────────────────────────────────┐
│                    Host OS (Windows)                         │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         VirtualBox Hypervisor (Type 2)                │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │  Virtual Machine Monitor (VMM)                  │  │  │
│  │  │  ├── VT-x/AMD-V (Hardware-assisted)             │  │  │
│  │  │  ├── Shadow Page Tables                         │  │  │
│  │  │  └── Virtual Device Emulation                   │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
│                          │                                    │
│                          ▼                                    │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Virtual Hardware                         │  │
│  │  ├── Virtual CPU                                     │  │
│  │  ├── Virtual Memory                                  │  │
│  │  ├── Virtual Disk (.vdi file)                        │  │
│  │  └── Virtual Network                                 │  │
│  └───────────────────────────────────────────────────────┘  │
│                          │                                    │
│                          ▼                                    │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Guest OS (Ubuntu)                        │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │  Guest OS Kernel                                │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │  System Services (systemd)                      │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │  Application (FastAPI + Nginx)                  │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘

Overhead: ~5-15% CPU, ~200-500 MB RAM
```

---

## 3. Lưu Đồ Thuật Toán

### 3.1. Lưu Đồ Tổng Thể - Quy Trình Đo Lường

```
                    ┌─────────────┐
                    │   BẮT ĐẦU   │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ Chọn Mode?  │
                    └──┬────────┬─┘
                       │        │
            ┌──────────┘        └──────────┐
            │                              │
            ▼                              ▼
    ┌───────────────┐            ┌───────────────┐
    │ Docker Mode   │            │   VM Mode     │
    └───────┬───────┘            └───────┬───────┘
            │                            │
            ▼                            ▼
    ┌───────────────┐            ┌───────────────┐
    │ Khởi động     │            │ Kiểm tra VM   │
    │ Container     │            │ đang chạy     │
    └───────┬───────┘            └───────┬───────┘
            │                            │
            └────────────┬───────────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │  Đo Startup Time       │
            └────────────┬───────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │  Đo Disk Usage         │
            └────────────┬───────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │  Đo Resource Usage     │
            │  (Idle)                │
            └────────────┬───────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │  Đo Throughput         │
            └────────────┬───────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │  Đo Resource Usage     │
            │  (Under Load)          │
            └────────────┬───────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │  Phân tích OS          │
            │  Principles            │
            └────────────┬───────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │  Đo Isolation          │
            │  Overhead              │
            └────────────┬───────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │  Tạo Báo Cáo           │
            │  & Charts              │
            └────────────┬───────────┘
                         │
                         ▼
                    ┌─────────────┐
                    │   KẾT THÚC  │
                    └─────────────┘
```

### 3.2. Lưu Đồ Đo Startup Time

```
                    ┌─────────────┐
                    │   BẮT ĐẦU   │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ Chọn Mode?  │
                    └──┬────────┬─┘
                       │        │
            ┌──────────┘        └──────────┐
            │                              │
            ▼                              ▼
    ┌───────────────┐            ┌───────────────┐
    │ Docker:       │            │ VM:           │
    │ docker stop   │            │ systemctl     │
    │ container     │            │ stop service  │
    └───────┬───────┘            └───────┬───────┘
            │                            │
            ▼                            ▼
    ┌───────────────┐            ┌───────────────┐
    │ Ghi T1        │            │ Ghi T1        │
    └───────┬───────┘            └───────┬───────┘
            │                            │
            ▼                            ▼
    ┌───────────────┐            ┌───────────────┐
    │ docker start  │            │ systemctl     │
    │ container     │            │ start service │
    └───────┬───────┘            └───────┬───────┘
            │                            │
            ▼                            ▼
    ┌───────────────┐            ┌───────────────┐
    │ Ghi T2        │            │ Ghi T2        │
    └───────┬───────┘            └───────┬───────┘
            │                            │
            └────────────┬───────────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │ Start Time = T2 - T1   │
            └────────────┬───────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │ Đợi Health Check       │
            │ (curl /health)         │
            └────────────┬───────────┘
                         │
                         ▼
            ┌────────────────────────┐
            │ Service Ready?         │
            └──┬───────────────┬─────┘
               │               │
            Yes│               │No
               │               │
               │               └──┐
               │                  │
               ▼                  │
    ┌────────────────────────┐   │
    │ Ghi T3                 │   │
    └────────────┬───────────┘   │
                 │                │
                 ▼                │
    ┌────────────────────────┐   │
    │ Ready Time = T3 - T2   │   │
    └────────────┬───────────┘   │
                 │                │
                 └────────┬───────┘
                          │
                          ▼
                 ┌─────────────┐
                 │  Lưu kết quả│
                 └─────────────┘
```

### 3.3. Lưu Đồ Đo Resource Usage

```
                    ┌─────────────┐
                    │   BẮT ĐẦU   │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ Chọn Mode?  │
                    └──┬────────┬─┘
                       │        │
            ┌──────────┘        └──────────┐
            │                              │
            ▼                              ▼
    ┌───────────────┐            ┌───────────────┐
    │ Docker Mode   │            │   VM Mode     │
    └──┬──────────┬─┘            └──┬──────────┬─┘
       │          │                 │          │
    ┌──┘          └──┐           ┌──┘          └──┐
    │                │           │                │
    ▼                ▼           ▼                ▼
┌─────────┐    ┌─────────┐  ┌─────────┐    ┌─────────┐
│ Từ Host │    │ Từ bên  │  │ Từ Host │    │ Từ bên  │
│ docker  │    │ trong   │  │PowerShell│    │ trong   │
│ stats   │    │docker   │  │Get-Process│   │SSH+top  │
│         │    │exec top │  │          │    │/free    │
└────┬────┘    └────┬────┘  └────┬────┘    └────┬────┘
     │              │            │              │
     └──────┬───────┴────────────┴──────────────┘
            │
            ▼
    ┌────────────────────────┐
    │ Parse CPU%, Memory     │
    └────────────┬───────────┘
                 │
                 ▼
    ┌────────────────────────┐
    │ Ghi vào CSV            │
    └────────────┬───────────┘
                 │
                 ▼
    ┌────────────────────────┐
    │ Đủ thời gian?          │
    └──┬───────────────┬─────┘
       │               │
    Yes│               │No
       │               │
       │               └──┐
       │                  │
       ▼                  │
┌─────────────┐          │
│ Lưu kết quả │          │
└─────────────┘          │
                         │
                         └──┐
                            │
                            ▼
                    (Quay lại đo)
```

### 3.4. Lưu Đồ Đo Throughput

```
                    ┌─────────────┐
                    │   BẮT ĐẦU   │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ Chọn Tool?  │
                    └──┬────────┬─┘
                       │        │
            ┌──────────┘        └──────────┐
            │                              │
            ▼                              ▼
    ┌───────────────┐            ┌───────────────┐
    │     ab        │            │     wrk       │
    │(Apache Bench) │            │               │
    └───────┬───────┘            └───────┬───────┘
            │                            │
            └────────────┬───────────────┘
                         │
                         ▼
                    ┌─────────────┐
                    │ Chọn Mode?  │
                    └──┬────────┬─┘
                       │        │
            ┌──────────┘        └──────────┐
            │                              │
            ▼                              ▼
    ┌───────────────┐            ┌───────────────┐
    │ Docker Mode   │            │   VM Mode     │
    └──┬──────────┬─┘            └──┬──────────┬─┘
       │          │                 │          │
    ┌──┘          └──┐           ┌──┘          └──┐
    │                │           │                │
    ▼                ▼           ▼                ▼
┌─────────┐    ┌─────────┐  ┌─────────┐    ┌─────────┐
│ Từ Host │    │ Từ bên  │  │ Từ Host │    │ Từ bên  │
│ ab/wrk  │    │ trong   │  │ ab/wrk  │    │ trong   │
│ localhost│   │docker   │  │127.0.0.1│    │SSH+ab/  │
│         │    │exec ab  │  │:8080    │    │wrk      │
└────┬────┘    └────┬────┘  └────┬────┘    └────┬────┘
     │              │            │              │
     └──────┬───────┴────────────┴──────────────┘
            │
            ▼
    ┌────────────────────────┐
    │ Parse requests/sec     │
    │ latency (p50, p90, p99)│
    └────────────┬───────────┘
                 │
                 ▼
    ┌────────────────────────┐
    │ Lưu kết quả            │
    └────────────────────────┘
```

---

## 4. Cấu Trúc Dữ Liệu

### 4.1. Cấu Trúc Thư Mục Kết Quả

```
measurement_results/
│
├── full_report_docker_*.md          # Báo cáo tổng hợp Docker
├── full_report_vm_*.md              # Báo cáo tổng hợp VM
│
├── startup_time_docker_*.csv        # Startup time data
├── startup_time_vm_*.csv
│
├── resource_usage_docker_*.csv      # Resource usage data
├── resource_usage_vm_*.csv
│
├── disk_usage_docker_*.txt          # Disk usage report
├── disk_usage_vm_*.txt
│
├── throughput_docker_*.txt          # Throughput report
├── throughput_vm_*.txt
│
├── isolation_overhead_*.csv         # Isolation overhead data
├── os_principles_analysis_*.md      # OS principles analysis
│
├── VM/                              # Kết quả đo từ bên trong VM
│   ├── full_report_internal_*.md
│   ├── resource_usage_internal_*.csv
│   ├── disk_usage_internal_*.txt
│   └── throughput_internal_*.txt
│
└── docker/                          # Kết quả đo từ bên trong Docker
    ├── full_report_internal_*.md
    ├── resource_usage_internal_*.csv
    ├── disk_usage_internal_*.txt
    └── throughput_internal_*.txt
```

### 4.2. Luồng Xử Lý Dữ Liệu

```
┌─────────────────┐
│  Raw Data       │
│  (CSV/TXT)      │
└────────┬────────┘
         │
         ├─────────────────┐
         │                 │
         ▼                 ▼
┌─────────────────┐  ┌─────────────────┐
│ generate_       │  │ analyze_os_     │
│ statistics.sh   │  │ principles.sh   │
│                 │  │                 │
│ Tính:           │  │ Phân tích:      │
│ - min/max/avg   │  │ - cgroups       │
│ - median        │  │ - namespaces    │
│ - std dev       │  │ - hypervisor    │
└────────┬────────┘  └────────┬────────┘
         │                    │
         └──────────┬─────────┘
                    │
                    ▼
         ┌─────────────────┐
         │ generate_       │
         │ charts.py       │
         │                 │
         │ Vẽ biểu đồ:     │
         │ - HTML (Chart.js)│
         │ - PNG (Matplotlib)│
         └────────┬────────┘
                  │
                  ▼
         ┌─────────────────┐
         │ Comparison      │
         │ Report          │
         │                 │
         │ Tổng hợp:       │
         │ - Statistics    │
         │ - Charts        │
         │ - OS Analysis   │
         └────────┬────────┘
                  │
                  ▼
         ┌─────────────────┐
         │ Final Report    │
         │ (Markdown)      │
         └─────────────────┘
```

---

## 5. Nguyên Lý Hệ Điều Hành

### 5.1. Docker - Resource Management

```
┌─────────────────────────────────────────────────────────┐
│              Host Linux Kernel                          │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  cgroups (Control Groups)                        │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │  CPU cgroup                                │  │  │
│  │  │  ├── cpu.cfs_quota_us (limit)              │  │  │
│  │  │  └── cpu.cfs_period_us (period)            │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │  Memory cgroup                             │  │  │
│  │  │  ├── memory.limit_in_bytes                 │  │  │
│  │  │  └── memory.usage_in_bytes                 │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │  I/O cgroup                                │  │  │
│  │  │  └── blkio.weight                          │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Namespaces                                       │  │
│  │  ├── PID Namespace  (Process isolation)          │  │
│  │  ├── Network Namespace (Network isolation)       │  │
│  │  ├── Mount Namespace (Filesystem isolation)      │  │
│  │  └── User Namespace (User ID isolation)          │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│                          │                               │
│                          ▼                               │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Container Process (Isolated)                    │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 5.2. VM - Hypervisor Resource Management

```
┌─────────────────────────────────────────────────────────┐
│              Host OS (Windows)                          │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  VirtualBox Hypervisor                           │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │  Virtual Machine Monitor (VMM)             │  │  │
│  │  │  ├── VT-x/AMD-V (Hardware-assisted)        │  │  │
│  │  │  ├── Shadow Page Tables                    │  │  │
│  │  │  └── Device Emulation                      │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  │                                                   │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │  Resource Allocation                       │  │  │
│  │  │  ├── CPU: Fixed allocation                 │  │  │
│  │  │  ├── Memory: Dedicated allocation          │  │  │
│  │  │  └── I/O: Virtualized devices              │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────┘  │
│                          │                               │
│                          ▼                               │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Virtual Hardware                                │  │
│  │  ├── Virtual CPU                                │  │
│  │  ├── Virtual Memory                             │  │
│  │  └── Virtual I/O                                │  │
│  └──────────────────────────────────────────────────┘  │
│                          │                               │
│                          ▼                               │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Guest OS (Ubuntu)                               │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │  Guest Kernel                              │  │  │
│  │  │  └── Process Scheduling                    │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │  Application                               │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 6. So Sánh Memory Management

### 6.1. Docker - Copy-on-Write (COW)

```
Base Image Layer (Read-only)
    │
    ├── Layer 1: OS Base
    ├── Layer 2: Python Runtime
    ├── Layer 3: Dependencies
    └── Layer 4: Application Code
            │
            ▼
Container Layer (Read-Write)
    │
    ├── Changes to files → New layer
    └── Shared memory with host

Memory Usage:
- Base layers: Shared across containers
- Container layer: Only unique changes
- Total: Minimal overhead
```

### 6.2. VM - Dedicated Memory Allocation

```
Host Memory
    │
    ├── Host OS: ~2-4 GB
    ├── Hypervisor: ~200-500 MB
    └── VM Allocation: ~4 GB (fixed)
            │
            ▼
Guest OS Memory
    │
    ├── Kernel: ~100-200 MB
    ├── System Services: ~200-300 MB
    └── Application: ~500 MB - 3 GB

Memory Usage:
- Fixed allocation (cannot share)
- Higher overhead
- Total: Full OS + Application
```

---

## 7. Tóm Tắt

### 7.1. Bảng So Sánh

```
┌─────────────────────┬──────────────────┬──────────────────┐
│     Aspect          │   Docker         │   Virtual Machine│
├─────────────────────┼──────────────────┼──────────────────┤
│ Virtualization      │ OS-level         │ Hardware-level   │
│ Kernel              │ Shared           │ Dedicated        │
│ Isolation           │ Namespaces       │ Hypervisor       │
│                     │ + cgroups        │                  │
│ CPU Overhead        │ ~1-2%            │ ~5-15%           │
│ Memory Overhead     │ ~50-100 MB       │ ~200-500 MB      │
│ Startup Time        │ Vài giây         │ Vài chục giây    │
│ Disk Usage          │ Nhỏ (layers)     │ Lớn (full OS)    │
│ Memory Model        │ Copy-on-Write    │ Dedicated        │
│ I/O Performance     │ Native           │ Virtualized      │
└─────────────────────┴──────────────────┴──────────────────┘
```

---

**Tài liệu này cung cấp sơ đồ ASCII art để dễ đọc ở mọi môi trường.**


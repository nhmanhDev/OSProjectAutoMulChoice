# Sơ Đồ Kiến Trúc và Lưu Đồ Thuật Toán
## Hệ Thống So Sánh Hiệu Năng VM và Docker

---

## 1. Kiến Trúc Tổng Thể Hệ Thống

### 1.1. Sơ Đồ Khối Tổng Quan

```mermaid
graph TB
    subgraph "Host Machine (Windows)"
        A[Measurement Scripts] --> B{Chọn Mode}
        B -->|docker| C[Docker Engine]
        B -->|vm| D[VirtualBox]
        
        C --> E[Docker Container]
        D --> F[Virtual Machine]
        
        E --> G[FastAPI App]
        E --> H[Nginx]
        
        F --> I[Ubuntu OS]
        I --> J[FastAPI App]
        I --> K[Nginx]
        
        G --> L[Application Logic]
        J --> L
        
        A --> M[Measurement Results]
        M --> N[Reports & Charts]
    end
    
    style A fill:#e1f5ff
    style M fill:#fff4e1
    style N fill:#e8f5e9
```

### 1.2. Kiến Trúc Docker Container

```mermaid
graph TB
    subgraph "Host OS (Windows)"
        subgraph "Docker Engine"
            subgraph "Docker Network"
                A[Nginx Container<br/>Port 80]
                B[FastAPI Container<br/>Port 8000]
            end
        end
        C[Measurement Scripts<br/>docker stats]
    end
    
    A -->|Proxy| B
    B --> D[Python Application]
    B --> E[OpenCV/TensorFlow]
    
    C -->|Monitor| A
    C -->|Monitor| B
    
    F[Client Browser] -->|HTTP| A
    
    style A fill:#4fc3f7
    style B fill:#81c784
    style C fill:#ffb74d
```

### 1.3. Kiến Trúc Virtual Machine

```mermaid
graph TB
    subgraph "Host OS (Windows)"
        A[VirtualBox Hypervisor]
        B[Measurement Scripts<br/>PowerShell/VBoxManage]
    end
    
    subgraph "Virtual Machine (Ubuntu)"
        C[Guest OS Kernel]
        D[Systemd Services]
        E[Nginx<br/>Port 80]
        F[FastAPI<br/>Port 8000]
        G[Python Application]
        H[OpenCV/TensorFlow]
    end
    
    A -->|Virtualization| C
    C --> D
    D --> E
    D --> F
    F --> G
    F --> H
    
    E -->|Proxy| F
    
    B -->|SSH| C
    B -->|VBoxManage| A
    B -->|Port Forwarding| E
    
    I[Client Browser] -->|HTTP:8080| A
    A -->|NAT| E
    
    style A fill:#ff9800
    style C fill:#4caf50
    style B fill:#ffb74d
```

---

## 2. So Sánh Kiến Trúc VM vs Docker

### 2.1. Sơ Đồ So Sánh Cấp Độ Cô Lập

```mermaid
graph TB
    subgraph "Docker Container - OS-level Virtualization"
        A1[Host OS Kernel] --> A2[Docker Engine]
        A2 --> A3[Container Runtime]
        A3 --> A4[Namespaces<br/>PID, Network, Mount]
        A3 --> A5[cgroups<br/>CPU, Memory, I/O]
        A4 --> A6[Application]
        A5 --> A6
    end
    
    subgraph "Virtual Machine - Hardware Virtualization"
        B1[Host OS] --> B2[Hypervisor<br/>VirtualBox]
        B2 --> B3[Virtual Hardware]
        B3 --> B4[Guest OS Kernel]
        B4 --> B5[System Services]
        B5 --> B6[Application]
    end
    
    style A1 fill:#81c784
    style A2 fill:#4fc3f7
    style B2 fill:#ff9800
    style B4 fill:#4caf50
```

### 2.2. Overhead và Resource Management

```mermaid
graph LR
    subgraph "Docker Overhead"
        A1[Container Runtime<br/>~50-100 MB] --> A2[Namespace Switching<br/>~1-2% CPU]
        A2 --> A3[Shared Kernel<br/>Minimal I/O]
    end
    
    subgraph "VM Overhead"
        B1[Hypervisor<br/>~200-500 MB] --> B2[Full OS<br/>~5-15% CPU]
        B2 --> B3[Virtualized Devices<br/>Higher I/O]
    end
    
    style A1 fill:#e8f5e9
    style A2 fill:#c8e6c9
    style B1 fill:#fff3e0
    style B2 fill:#ffe0b2
```

---

## 3. Lưu Đồ Thuật Toán Đo Lường

### 3.1. Lưu Đồ Tổng Thể - Quy Trình Đo Lường

```mermaid
flowchart TD
    Start([Bắt đầu]) --> Input{Chọn Mode}
    Input -->|docker| DockerMode[Docker Mode]
    Input -->|vm| VMMode[VM Mode]
    
    DockerMode --> D1[Khởi động Container]
    VMMode --> V1[Kiểm tra VM đang chạy]
    
    D1 --> D2[Đo Startup Time]
    V1 --> V2[Đo Startup Time]
    
    D2 --> D3[Đo Disk Usage]
    V2 --> V3[Đo Disk Usage]
    
    D3 --> D4[Đo Resource Usage Idle]
    V3 --> V4[Đo Resource Usage Idle]
    
    D4 --> D5[Đo Throughput]
    V4 --> V5[Đo Throughput]
    
    D5 --> D6[Đo Resource Usage Under Load]
    V5 --> V6[Đo Resource Usage Under Load]
    
    D6 --> D7[Phân tích OS Principles]
    V6 --> V7[Phân tích OS Principles]
    
    D7 --> D8[Đo Isolation Overhead]
    V7 --> V8[Đo Isolation Overhead]
    
    D8 --> D9[Tạo Báo Cáo]
    V8 --> V9[Tạo Báo Cáo]
    
    D9 --> Generate[Generate Charts & Statistics]
    V9 --> Generate
    
    Generate --> End([Kết thúc])
    
    style Start fill:#4caf50
    style End fill:#f44336
    style DockerMode fill:#4fc3f7
    style VMMode fill:#ff9800
```

### 3.2. Lưu Đồ Đo Lường Từ Host

```mermaid
flowchart TD
    Start([Bắt đầu đo từ Host]) --> Check{Mode?}
    
    Check -->|docker| DockerHost[Docker Mode]
    Check -->|vm| VMHost[VM Mode]
    
    subgraph "Docker - Từ Host"
        DockerHost --> D1[docker ps<br/>Kiểm tra container]
        D1 --> D2{docker stats<br/>Đo CPU/RAM}
        D2 --> D3[docker images<br/>Đo disk size]
        D3 --> D4[curl localhost<br/>Đo throughput]
        D4 --> D5[Lưu kết quả]
    end
    
    subgraph "VM - Từ Host"
        VMHost --> V1[VBoxManage list runningvms<br/>Kiểm tra VM]
        V1 --> V2[PowerShell Get-Process<br/>Đo VirtualBox process]
        V2 --> V3[Get-Item .vdi file<br/>Đo disk size]
        V3 --> V4[curl 127.0.0.1:8080<br/>Đo throughput qua port forwarding]
        V4 --> V5[Lưu kết quả]
    end
    
    D5 --> End([Kết thúc])
    V5 --> End
    
    style Start fill:#4caf50
    style End fill:#f44336
    style DockerHost fill:#4fc3f7
    style VMHost fill:#ff9800
```

### 3.3. Lưu Đồ Đo Lường Từ Bên Trong

```mermaid
flowchart TD
    Start([Bắt đầu đo từ bên trong]) --> Check{Mode?}
    
    Check -->|docker| DockerInternal[Docker Mode]
    Check -->|vm| VMInternal[VM Mode]
    
    subgraph "Docker - Từ Bên Trong"
        DockerInternal --> D1[docker exec container<br/>Vào trong container]
        D1 --> D2[top -bn1<br/>Đo CPU/RAM]
        D2 --> D3[df -h<br/>Đo disk usage]
        D3 --> D4[ab/wrk localhost<br/>Đo throughput]
        D4 --> D5[Lưu vào docker/]
    end
    
    subgraph "VM - Từ Bên Trong"
        VMInternal --> V1[SSH vào VM<br/>vm-ubuntu]
        V1 --> V2[top/free -m<br/>Đo CPU/RAM]
        V2 --> V3[df -h<br/>Đo disk usage]
        V3 --> V4[ab/wrk localhost<br/>Đo throughput]
        V4 --> V5[Lưu vào VM/]
    end
    
    D5 --> End([Kết thúc])
    V5 --> End
    
    style Start fill:#4caf50
    style End fill:#f44336
    style DockerInternal fill:#4fc3f7
    style VMInternal fill:#ff9800
```

### 3.4. Lưu Đồ Đo Startup Time

```mermaid
flowchart TD
    Start([Bắt đầu đo Startup Time]) --> Mode{Mode?}
    
    Mode -->|docker| DockerStart[Docker]
    Mode -->|vm| VMStart[VM]
    
    subgraph "Docker Startup"
        DockerStart --> D1[docker stop container]
        D1 --> D2[Ghi timestamp T1]
        D2 --> D3[docker start container]
        D3 --> D4[Ghi timestamp T2]
        D4 --> D5[Start Time = T2 - T1]
        D5 --> D6[Đợi health check]
        D6 --> D7{Service ready?}
        D7 -->|No| D6
        D7 -->|Yes| D8[Ghi timestamp T3]
        D8 --> D9[Ready Time = T3 - T2]
    end
    
    subgraph "VM Startup"
        VMStart --> V1[systemctl stop service]
        V1 --> V2[Ghi timestamp T1]
        V2 --> V3[systemctl start service]
        V3 --> V4[Ghi timestamp T2]
        V4 --> V5[Start Time = T2 - T1]
        V5 --> V6[Đợi health check]
        V6 --> V7{Service ready?}
        V7 -->|No| V6
        V7 -->|Yes| V8[Ghi timestamp T3]
        V8 --> V9[Ready Time = T3 - T2]
    end
    
    D9 --> Save[Lưu kết quả]
    V9 --> Save
    Save --> End([Kết thúc])
    
    style Start fill:#4caf50
    style End fill:#f44336
```

### 3.5. Lưu Đồ Đo Resource Usage

```mermaid
flowchart TD
    Start([Bắt đầu đo Resource Usage]) --> Mode{Mode?}
    
    Mode -->|docker| DockerRes[Docker]
    Mode -->|vm| VMRes[VM]
    
    subgraph "Docker Resource Measurement"
        DockerRes --> D1{Đo từ đâu?}
        D1 -->|Host| D2[docker stats<br/>--no-stream]
        D1 -->|Internal| D3[docker exec<br/>top -bn1]
        D2 --> D4[Parse CPU%, Memory]
        D3 --> D4
        D4 --> D5[Ghi vào CSV]
        D5 --> D6{Đủ thời gian?}
        D6 -->|No| D2
        D6 -->|Yes| D7[Lưu kết quả]
    end
    
    subgraph "VM Resource Measurement"
        VMRes --> V1{Đo từ đâu?}
        V1 -->|Host| V2[PowerShell<br/>Get-Process VirtualBox]
        V1 -->|Internal| V3[SSH + top/free]
        V2 --> V4[Parse CPU%, Memory]
        V3 --> V4
        V4 --> V5[Ghi vào CSV]
        V5 --> V6{Đủ thời gian?}
        V6 -->|No| V2
        V6 -->|Yes| V7[Lưu kết quả]
    end
    
    D7 --> End([Kết thúc])
    V7 --> End
    
    style Start fill:#4caf50
    style End fill:#f44336
```

### 3.6. Lưu Đồ Đo Throughput

```mermaid
flowchart TD
    Start([Bắt đầu đo Throughput]) --> Mode{Mode?}
    
    Mode -->|docker| DockerThru[Docker]
    Mode -->|vm| VMThru[VM]
    
    subgraph "Docker Throughput"
        DockerThru --> D1{Đo từ đâu?}
        D1 -->|Host| D2[ab/wrk localhost]
        D1 -->|Internal| D3[docker exec<br/>ab/wrk localhost]
        D2 --> D4[Parse requests/sec]
        D3 --> D4
        D4 --> D5[Lưu kết quả]
    end
    
    subgraph "VM Throughput"
        VMThru --> V1{Đo từ đâu?}
        V1 -->|Host| V2[ab/wrk 127.0.0.1:8080<br/>Port forwarding]
        V1 -->|Internal| V3[SSH + ab/wrk localhost]
        V2 --> V4[Parse requests/sec]
        V3 --> V4
        V4 --> V5[Lưu kết quả]
    end
    
    D5 --> End([Kết thúc])
    V5 --> End
    
    style Start fill:#4caf50
    style End fill:#f44336
```

---

## 4. Cấu Trúc Dữ Liệu và Luồng Xử Lý

### 4.1. Cấu Trúc Thư Mục Kết Quả

```mermaid
graph TD
    A[measurement_results/] --> B[full_report_*.md]
    A --> C[startup_time_*.csv]
    A --> D[resource_usage_*.csv]
    A --> E[throughput_*.txt]
    A --> F[disk_usage_*.txt]
    A --> G[VM/]
    A --> H[docker/]
    
    G --> G1[full_report_internal_*.md]
    G --> G2[resource_usage_internal_*.csv]
    
    H --> H1[full_report_internal_*.md]
    H --> H2[resource_usage_internal_*.csv]
    
    style A fill:#e1f5ff
    style G fill:#fff3e0
    style H fill:#e8f5e9
```

### 4.2. Luồng Xử Lý Dữ Liệu

```mermaid
flowchart LR
    A[Raw Data<br/>CSV/TXT] --> B[generate_statistics.sh<br/>Tính min/max/avg]
    B --> C[generate_charts.py<br/>Vẽ biểu đồ]
    C --> D[HTML Charts<br/>Chart.js]
    C --> E[PNG Charts<br/>Matplotlib]
    
    A --> F[analyze_os_principles.sh<br/>Phân tích nguyên lý]
    F --> G[OS Principles Report]
    
    B --> H[Comparison Report]
    C --> H
    G --> H
    
    H --> I[Final Report<br/>Markdown]
    
    style A fill:#ffebee
    style I fill:#e8f5e9
```

---

## 5. Nguyên Lý Hệ Điều Hành - Resource Management

### 5.1. Docker - cgroups và Namespaces

```mermaid
graph TB
    subgraph "Host Kernel"
        A[Linux Kernel] --> B[cgroups Subsystem]
        A --> C[Namespaces]
    end
    
    subgraph "Docker Container"
        B --> D[CPU cgroup<br/>cpu.cfs_quota_us]
        B --> E[Memory cgroup<br/>memory.limit_in_bytes]
        B --> F[I/O cgroup<br/>blkio.weight]
        
        C --> G[PID Namespace]
        C --> H[Network Namespace]
        C --> I[Mount Namespace]
        C --> J[User Namespace]
        
        D --> K[Container Process]
        E --> K
        F --> K
        G --> K
        H --> K
        I --> K
        J --> K
    end
    
    style A fill:#4caf50
    style B fill:#81c784
    style C fill:#4fc3f7
    style K fill:#ffb74d
```

### 5.2. Virtual Machine - Hypervisor

```mermaid
graph TB
    subgraph "Host OS"
        A[Windows OS] --> B[VirtualBox VMM<br/>Type 2 Hypervisor]
    end
    
    subgraph "Virtual Hardware"
        B --> C[Virtual CPU<br/>VT-x/AMD-V]
        B --> D[Virtual Memory<br/>Shadow Page Tables]
        B --> E[Virtual I/O<br/>Virtual Disk/Network]
    end
    
    subgraph "Guest OS"
        C --> F[Ubuntu Kernel]
        D --> F
        E --> F
        
        F --> G[Systemd]
        G --> H[Application]
    end
    
    style A fill:#2196f3
    style B fill:#ff9800
    style F fill:#4caf50
    style H fill:#ffb74d
```

### 5.3. So Sánh Memory Management

```mermaid
graph LR
    subgraph "Docker - Copy-on-Write"
        A1[Base Image Layer] --> A2[Container Layer]
        A2 -->|COW| A3[Shared Memory<br/>Minimal Overhead]
    end
    
    subgraph "VM - Dedicated Memory"
        B1[Host Memory] --> B2[Hypervisor Allocation]
        B2 --> B3[Guest OS Memory<br/>Fixed Allocation]
        B3 --> B4[Application Memory]
    end
    
    style A3 fill:#c8e6c9
    style B4 fill:#ffe0b2
```

---

## 6. Tóm Tắt Kiến Trúc

### 6.1. Điểm Khác Biệt Chính

| Aspect | Docker Container | Virtual Machine |
|--------|-----------------|-----------------|
| **Virtualization Level** | OS-level | Hardware-level |
| **Kernel** | Shared với host | Kernel riêng |
| **Isolation** | Namespaces + cgroups | Hypervisor |
| **Overhead** | Thấp (~1-2% CPU) | Cao (~5-15% CPU) |
| **Startup Time** | Nhanh (vài giây) | Chậm (vài chục giây) |
| **Memory** | Copy-on-Write | Dedicated allocation |
| **Disk Usage** | Nhỏ (layers) | Lớn (full OS) |

### 6.2. Khi Nào Dùng Gì?

```mermaid
graph TD
    Start{Chọn công nghệ} --> Q1{Cần isolation mạnh?}
    Q1 -->|Yes| Q2{Cần chạy OS khác?}
    Q1 -->|No| Docker
    
    Q2 -->|Yes| VM
    Q2 -->|No| Q3{Performance quan trọng?}
    
    Q3 -->|Yes| Docker
    Q3 -->|No| Q4{Resource hạn chế?}
    
    Q4 -->|Yes| Docker
    Q4 -->|No| Both[Cả hai đều được]
    
    style Docker fill:#4fc3f7
    style VM fill:#ff9800
    style Both fill:#81c784
```

---

## 7. Ghi Chú Kỹ Thuật

### 7.1. Measurement Scripts Architecture

```
scripts/
├── measure_startup_time.sh          # Đo từ Host
├── measure_resource_usage.sh        # Đo từ Host
├── measure_disk_usage.sh            # Đo từ Host
├── measure_throughput.sh            # Đo từ Host
├── measure_isolation_overhead.sh    # Đo overhead
├── analyze_os_principles.sh         # Phân tích nguyên lý
├── generate_charts.py               # Vẽ biểu đồ
├── generate_statistics.sh           # Tính toán thống kê
└── run_all_measurements.sh          # Orchestrator

measurement_results/
├── measure_*_internal.sh            # Đo từ bên trong
├── run_all_measurements_internal.sh # Orchestrator internal
├── VM/                              # Kết quả VM internal
└── docker/                          # Kết quả Docker internal
```

### 7.2. Data Flow

```
Measurement Scripts
    ↓
Collect Raw Data (CSV/TXT)
    ↓
Process & Analyze
    ↓
Generate Statistics
    ↓
Create Charts
    ↓
Generate Reports (Markdown)
    ↓
Final Output
```

---

**Tài liệu này mô tả đầy đủ kiến trúc và thuật toán của hệ thống so sánh hiệu năng VM và Docker.**


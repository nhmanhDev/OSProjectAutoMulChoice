# Báo Cáo So Sánh VM vs Docker
## Automated Multiple-Choice Exam Grading System

**Ngày thực hiện:** [Ngày]  
**Người thực hiện:** [Tên]  
**Môi trường test:** [Mô tả hardware]

---

## 1. Tổng Quan

### 1.1. Mục Tiêu
So sánh hiệu năng và tài nguyên giữa hai phương pháp triển khai:
- **Docker Container**: Ảo hóa cấp hệ điều hành
- **Virtual Machine**: Ảo hóa phần cứng

### 1.2. Ứng Dụng Test
- **Tên**: Automated Multiple-Choice Exam Grading
- **Stack**: FastAPI + Nginx + OpenCV + TensorFlow
- **Chức năng**: Chấm bài thi trắc nghiệm tự động

### 1.3. Môi Trường Test
- **Host OS**: [Ubuntu 22.04 / Windows 11 / macOS]
- **CPU**: [Intel i5 / AMD Ryzen 5 / ...] - [Số cores] cores
- **RAM**: [8GB / 16GB / ...]
- **Storage**: [SSD / HDD] - [500GB / 1TB]
- **Docker Version**: [20.10.x]
- **VirtualBox Version**: [6.1.x / 7.0.x]

---

## 2. Kết Quả Đo Lường

### 2.1. Thời Gian Khởi Động Dịch Vụ

#### Docker Container

| Lần đo | Build Time (s) | Start Time (s) | Ready Time (s) | Tổng (s) |
|--------|---------------|----------------|----------------|----------|
| 1      |               |                |                |          |
| 2      |               |                |                |          |
| 3      |               |                |                |          |
| 4      |               |                |                |          |
| 5      |               |                |                |          |
| **TB** |               |                |                |          |
| **Min**|               |                |                |          |
| **Max**|               |                |                |          |

**Ghi chú:**
- Build time: Thời gian build Docker image (chỉ lần đầu)
- Start time: Thời gian từ lệnh `docker-compose up` đến container running
- Ready time: Thời gian từ container running đến service sẵn sàng nhận request

#### Virtual Machine

| Lần đo | Boot Time (s) | Service Start (s) | Ready Time (s) | Tổng (s) |
|--------|--------------|-------------------|----------------|----------|
| 1      |              |                   |                |          |
| 2      |              |                   |                |          |
| 3      |              |                   |                |          |
| 4      |              |                   |                |          |
| 5      |              |                   |                |          |
| **TB** |              |                   |                |          |
| **Min**|              |                   |                |          |
| **Max**|              |                   |                |          |

**Ghi chú:**
- Boot time: Thời gian từ lệnh start VM đến OS boot hoàn tất
- Service start: Thời gian start systemd service
- Ready time: Thời gian từ service start đến sẵn sàng nhận request

#### So Sánh

| Chỉ Số | Docker | VM | Chênh Lệch | % |
|--------|--------|----|-----------|---|
| Build/Boot | X s | Y s | Z s | W% |
| Start | X s | Y s | Z s | W% |
| Ready | X s | Y s | Z s | W% |
| **Tổng** | **X s** | **Y s** | **Z s** | **W%** |

**Phân tích:**
[Docker nhanh hơn VM khoảng X lần do...]

---

### 2.2. Dung Lượng Đĩa Sử Dụng

#### Docker

| Component | Size | Ghi Chú |
|-----------|------|---------|
| Base Image (python:3.10) | X MB | |
| Application Code | X MB | |
| Dependencies | X MB | |
| Model Files (weight.keras) | X MB | |
| **Total Image Size** | **X GB** | |
| Container Runtime | +X MB | Khi đang chạy |
| Volumes | X MB | |
| **Total Docker Usage** | **X GB** | |

**Chi tiết layers:**
```
[Liệt kê các layers và kích thước]
```

#### Virtual Machine

| Component | Size | Ghi Chú |
|-----------|------|---------|
| Ubuntu Server Base | X GB | |
| Application Code | X MB | |
| Dependencies | X MB | |
| Model Files | X MB | |
| System Files | X GB | |
| **Total .vdi File** | **X GB** | |
| **Actual Disk Usage** | **X GB** | Trong VM |

**Chi tiết:**
```bash
# Kết quả từ lệnh
df -h
du -sh /opt/exam-grading
```

#### So Sánh

| Chỉ Số | Docker | VM | Chênh Lệch | % |
|--------|--------|----|-----------|---|
| Base System | X GB | Y GB | Z GB | W% |
| Application | X MB | Y MB | Z MB | W% |
| **Tổng** | **X GB** | **Y GB** | **Z GB** | **W%** |

**Phân tích:**
[Docker tiết kiệm X% dung lượng do...]

---

### 2.3. Mức Sử Dụng RAM và CPU Khi Idle

#### Docker

**Đo trong 60 giây khi không có request:**

| Container | CPU Avg (%) | CPU Min (%) | CPU Max (%) | RAM Avg (MB) | RAM Min (MB) | RAM Max (MB) |
|-----------|-------------|-------------|-------------|--------------|--------------|--------------|
| exam-grading-app | | | | | | |
| exam-grading-nginx | | | | | | |
| **Tổng** | | | | | | |

**Biểu đồ:**
[Chèn biểu đồ CPU và RAM usage over time]

**Phân tích:**
- CPU baseline: X%
- RAM baseline: X MB
- Fluctuations: [Mô tả]

#### Virtual Machine

**Đo trong 60 giây khi không có request:**

| Process/Service | CPU Avg (%) | RAM (MB) |
|-----------------|-------------|----------|
| FastAPI (uvicorn) | | |
| Nginx | | |
| System (OS) | | |
| **Tổng VM** | | |

**Biểu đồ:**
[Chèn biểu đồ CPU và RAM usage over time]

#### So Sánh

| Chỉ Số | Docker | VM | Chênh Lệch | % |
|--------|--------|----|-----------|---|
| CPU Idle | X% | Y% | Z% | W% |
| RAM Idle | X MB | Y MB | Z MB | W% |
| Overhead | X MB | Y MB | Z MB | W% |

**Phân tích:**
[Docker tiết kiệm X% RAM do không cần full OS...]

---

### 2.4. Thông Lượng (Throughput)

#### Test Configuration

- **Tool**: Apache Bench (ab) / wrk
- **URL**: http://localhost/
- **Concurrent Requests**: 1, 5, 10, 20, 50, 100
- **Total Requests**: 1000, 5000, 10000
- **Duration**: 30s, 60s

#### Docker - Results

| Concurrent | Requests/s | Time/Request (ms) | Latency p50 (ms) | Latency p99 (ms) | Failed Requests |
|------------|------------|-------------------|------------------|------------------|-----------------|
| 1          |            |                   |                  |                  |                 |
| 5          |            |                   |                  |                  |                 |
| 10         |            |                   |                  |                  |                 |
| 20         |            |                   |                  |                  |                 |
| 50         |            |                   |                  |                  |                 |
| 100        |            |                   |                  |                  |                 |

**Biểu đồ:**
[Chèn biểu đồ throughput vs concurrent requests]

**Phân tích:**
- Peak throughput: X req/s tại Y concurrent
- Optimal concurrent: Z requests
- Bottleneck: [CPU / RAM / Network / ...]

#### Virtual Machine - Results

| Concurrent | Requests/s | Time/Request (ms) | Latency p50 (ms) | Latency p99 (ms) | Failed Requests |
|------------|------------|-------------------|------------------|------------------|-----------------|
| 1          |            |                   |                  |                  |                 |
| 5          |            |                   |                  |                  |                 |
| 10         |            |                   |                  |                  |                 |
| 20         |            |                   |                  |                  |                 |
| 50         |            |                   |                  |                  |                 |
| 100        |            |                   |                  |                  |                 |

**Biểu đồ:**
[Chèn biểu đồ throughput vs concurrent requests]

#### So Sánh

| Concurrent | Docker (req/s) | VM (req/s) | Chênh Lệch | % |
|------------|----------------|------------|-----------|---|
| 1          |                |            |           |   |
| 10         |                |            |           |   |
| 50         |                |            |           |   |
| 100        |                |            |           |   |
| **Peak**   |                |            |           |   |

**Phân tích:**
[Docker có throughput cao hơn X% do overhead thấp hơn...]

---

### 2.5. Mức Sử Dụng RAM và CPU Khi Có Tải

#### Docker - Under Load

**Test với 50 concurrent requests trong 60 giây:**

| Container | CPU Avg (%) | CPU Peak (%) | RAM Avg (MB) | RAM Peak (MB) |
|-----------|-------------|--------------|--------------|---------------|
| exam-grading-app | | | | |
| exam-grading-nginx | | | | |
| **Tổng** | | | | |

**So với Idle:**
- CPU tăng: X% → Y% (+Z%)
- RAM tăng: X MB → Y MB (+Z MB)

**Biểu đồ:**
[Chèn biểu đồ resource usage khi có tải]

#### Virtual Machine - Under Load

**Test với 50 concurrent requests trong 60 giây:**

| Component | CPU Avg (%) | CPU Peak (%) | RAM Avg (MB) | RAM Peak (MB) |
|-----------|-------------|--------------|--------------|---------------|
| FastAPI | | | | |
| Nginx | | | | |
| System | | | | |
| **Tổng** | | | | |

**So với Idle:**
- CPU tăng: X% → Y% (+Z%)
- RAM tăng: X MB → Y MB (+Z MB)

#### So Sánh

| Chỉ Số | Docker Idle | Docker Load | VM Idle | VM Load | Chênh Lệch |
|--------|-------------|-------------|----------|---------|------------|
| CPU | X% | Y% | A% | B% | |
| RAM | X MB | Y MB | A MB | B MB | |

**Phân tích:**
[So sánh scaling behavior...]

---

## 3. Phân Tích Nguyên Lý HĐH

### 3.1. Quản Lý Tài Nguyên

#### Docker Container

**Cơ chế:**
- **cgroups (Control Groups)**: 
  - Giới hạn CPU: `cpu.cfs_quota_us`, `cpu.cfs_period_us`
  - Giới hạn RAM: `memory.limit_in_bytes`
  - Giới hạn I/O: `blkio.weight`
- **namespaces**:
  - PID namespace: Cô lập process IDs
  - Network namespace: Cô lập network stack
  - Mount namespace: Cô lập filesystem
  - User namespace: Cô lập user IDs

**Overhead:**
- CPU: ~1-2% (chỉ namespace switching)
- RAM: ~50-100 MB (container runtime)
- I/O: Minimal (shared filesystem)

**Ưu điểm:**
- Lightweight, nhanh
- Dễ scale
- Resource limits chính xác

**Nhược điểm:**
- Security isolation kém hơn VM
- Phụ thuộc vào kernel của host

#### Virtual Machine

**Cơ chế:**
- **Hypervisor (VirtualBox sử dụng Type 2)**:
  - VirtualBox VMM: Quản lý hardware virtualization
  - VT-x/AMD-V: Hardware-assisted virtualization
  - Memory management: Shadow page tables
- **Full OS**: Mỗi VM chạy kernel riêng

**Overhead:**
- CPU: ~5-15% (hypervisor + full OS)
- RAM: ~200-500 MB (OS + hypervisor)
- I/O: Higher (virtualized devices)

**Ưu điểm:**
- Security isolation hoàn toàn
- Chạy được nhiều OS khác nhau
- Không phụ thuộc vào host kernel

**Nhược điểm:**
- Nặng, chậm
- Khó scale
- Resource overhead cao

### 3.2. Chi Phí Cô Lập (Isolation Overhead)

#### Isolation Levels

| Aspect | Docker | VM |
|--------|--------|----|
| **Process Isolation** | ✅ Namespace | ✅ Full |
| **Network Isolation** | ✅ Network namespace | ✅ Virtual network |
| **Filesystem Isolation** | ✅ Mount namespace | ✅ Virtual disk |
| **Hardware Isolation** | ❌ | ✅ |
| **Kernel Isolation** | ❌ | ✅ |

#### Overhead Comparison

**Docker:**
```
Total Overhead = Container Runtime + Namespace + cgroups
               ≈ 50-100 MB RAM + 1-2% CPU
```

**VM:**
```
Total Overhead = Hypervisor + Guest OS + Virtual Hardware
               ≈ 200-500 MB RAM + 5-15% CPU
```

**Kết luận:**
- Docker có overhead thấp hơn ~70-80%
- VM có isolation tốt hơn nhưng đánh đổi bằng overhead cao

### 3.3. Memory Management

#### Docker

- **Shared Kernel Memory**: Containers chia sẻ kernel memory
- **cgroups Memory Limits**: Giới hạn chính xác
- **Copy-on-Write**: Image layers dùng chung, chỉ copy khi modify

**Ví dụ:**
```
Base Image: 900 MB
Container 1: +100 MB (application)
Container 2: +100 MB (application)
Total: 900 + 100 + 100 = 1100 MB (không phải 2000 MB)
```

#### VM

- **Dedicated Memory**: Mỗi VM có memory riêng
- **Hypervisor Memory**: Overhead cho virtualization
- **No Sharing**: Không chia sẻ memory giữa các VM

**Ví dụ:**
```
VM 1: 2 GB (OS + application)
VM 2: 2 GB (OS + application)
Total: 4 GB (không chia sẻ)
```

### 3.4. CPU Scheduling

#### Docker

- **Host Kernel Scheduler**: Dùng scheduler của host OS
- **cgroups CPU Shares**: Phân bổ CPU theo weight
- **Low Latency**: Không có layer virtualization

#### VM

- **Hypervisor Scheduler**: Hypervisor quản lý CPU
- **Guest OS Scheduler**: Guest OS có scheduler riêng
- **Higher Latency**: Nhiều layer scheduling

---

## 4. Kết Luận và Khuyến Nghị

### 4.1. Tổng Kết So Sánh

| Tiêu Chí | Docker | VM | Winner |
|----------|--------|----|--------|
| **Startup Time** | X s | Y s | Docker |
| **Disk Usage** | X GB | Y GB | Docker |
| **RAM Usage (Idle)** | X MB | Y MB | Docker |
| **CPU Usage (Idle)** | X% | Y% | Docker |
| **Throughput** | X req/s | Y req/s | Docker |
| **Security** | Good | Excellent | VM |
| **Isolation** | Process-level | Hardware-level | VM |
| **Portability** | Excellent | Good | Docker |
| **Ease of Use** | Easy | Moderate | Docker |

### 4.2. Khi Nào Dùng Docker?

✅ **Nên dùng Docker khi:**
- Cần deploy nhanh, scale dễ dàng
- Tài nguyên hạn chế
- Ứng dụng stateless, microservices
- Development và testing
- CI/CD pipelines
- Multi-tenant với trust cao

### 4.3. Khi Nào Dùng VM?

✅ **Nên dùng VM khi:**
- Cần security cao, isolation hoàn toàn
- Chạy ứng dụng legacy cần full OS
- Multi-tenant với yêu cầu bảo mật cao
- Cần chạy nhiều OS khác nhau
- Compliance yêu cầu hardware isolation

### 4.4. Kết Luận

[Dựa trên kết quả đo lường, Docker có ưu thế về:
- Startup time: Nhanh hơn X lần
- Resource usage: Tiết kiệm X% RAM, Y% CPU
- Throughput: Cao hơn Z%

Tuy nhiên, VM vẫn có ưu điểm về:
- Security: Isolation hoàn toàn
- Compatibility: Chạy được mọi OS

Tùy vào use case cụ thể mà chọn phương pháp phù hợp.]

---

## 5. Phụ Lục

### A. Raw Data

[Chèn các file CSV, log files, screenshots]

### B. Scripts Sử Dụng

[Liệt kê các scripts đã dùng]

### C. Biểu Đồ và Hình Ảnh

[Chèn các biểu đồ, screenshots]

### D. Tài Liệu Tham Khảo

1. Docker Documentation
2. VirtualBox Manual
3. Linux Kernel Documentation (cgroups, namespaces)
4. [Các tài liệu khác]

---

**Ngày hoàn thành:** [Ngày]  
**Người thực hiện:** [Tên]  
**Version:** 1.0


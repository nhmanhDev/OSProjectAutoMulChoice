# 📚 WIKI - Automated Multiple-Choice Exam Grading
## Tài Liệu Tổng Hợp Đầy Đủ

---

## 📑 Mục Lục

1. [Tổng Quan Dự Án](#1-tổng-quan-dự-án)
2. [Kiến Trúc Hệ Thống](#2-kiến-trúc-hệ-thống)
3. [Yêu Cầu Hệ Thống](#3-yêu-cầu-hệ-thống)
4. [Triển Khai với Docker](#4-triển-khai-với-docker)
5. [Triển Khai với VirtualBox VM](#5-triển-khai-với-virtualbox-vm)
6. [Đo Lường Hiệu Năng](#6-đo-lường-hiệu-năng)
7. [So Sánh Docker vs VM](#7-so-sánh-docker-vs-vm)
8. [Sử Dụng Ứng Dụng](#8-sử-dụng-ứng-dụng)
9. [Troubleshooting](#9-troubleshooting)
10. [Cấu Trúc Dự Án](#10-cấu-trúc-dự-án)
11. [Tài Liệu Tham Khảo](#11-tài-liệu-tham-khảo)

---

## 1. Tổng Quan Dự Án

### 1.1. Giới Thiệu

**Automated Multiple-Choice Exam Grading** là hệ thống tự động chấm bài thi trắc nghiệm bằng cách xử lý ảnh bài thi đã scan và so sánh với đáp án. Hệ thống được thiết kế để triển khai trên cả **Docker Container** và **Virtual Machine** nhằm so sánh hiệu năng giữa hai phương pháp ảo hóa.

### 1.2. Tính Năng Chính

- ✅ **Upload và xử lý ảnh bài thi** (JPG, PNG, PDF)
- ✅ **Nhận diện số báo danh (SBD)** và mã đề thi (MDT)
- ✅ **Chấm điểm tự động** 120 câu trắc nghiệm
- ✅ **Hiển thị kết quả** với ảnh đã chú thích
- ✅ **Web interface** thân thiện, dễ sử dụng
- ✅ **API RESTful** với FastAPI
- ✅ **So sánh hiệu năng** Docker vs VM

### 1.3. Stack Công Nghệ

| Component | Technology |
|-----------|-----------|
| **Backend** | FastAPI (Python 3.10) |
| **Web Server** | Nginx (reverse proxy) |
| **Image Processing** | OpenCV, TensorFlow |
| **Frontend** | HTML/CSS/JavaScript |
| **Containerization** | Docker, Docker Compose |
| **Virtualization** | VirtualBox |

---

## 2. Kiến Trúc Hệ Thống

### 2.1. Kiến Trúc Docker

```
┌─────────────────────────────────────┐
│         Host Machine                │
│  ┌───────────────────────────────┐  │
│  │    Docker Network             │  │
│  │  ┌──────────┐  ┌───────────┐  │  │
│  │  │  Nginx   │──│  FastAPI  │  │  │
│  │  │:80       │  │  :8000    │  │  │
│  │  └──────────┘  └───────────┘  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

**Services:**
- `exam-grading-nginx`: Nginx reverse proxy (port 80)
- `exam-grading-app`: FastAPI application (port 8000)

### 2.2. Kiến Trúc VM

```
┌─────────────────────────────────────┐
│         Host Machine                │
│  ┌───────────────────────────────┐  │
│  │    VirtualBox VM              │  │
│  │  ┌──────────┐  ┌───────────┐  │  │
│  │  │  Nginx   │──│  FastAPI  │  │  │
│  │  │:80       │  │  :8000    │  │  │
│  │  └──────────┘  └───────────┘  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

### 2.3. So Sánh Kiến Trúc

| Khía Cạnh | Docker Container | Virtual Machine |
|-----------|------------------|-----------------|
| **Isolation Level** | Process-level | Hardware-level |
| **Guest OS** | Không cần (dùng kernel của host) | Cần cài đặt đầy đủ |
| **Overhead** | Thấp (chỉ namespace, cgroups) | Cao (hypervisor, full OS) |
| **Startup Time** | Nhanh (giây) | Chậm (phút) |
| **Resource Usage** | Thấp | Cao |
| **Portability** | Rất cao | Trung bình |
| **Security** | Good | Excellent |

---

## 3. Yêu Cầu Hệ Thống

### 3.1. Cho Docker

- **OS**: Windows 10/11, Linux, hoặc macOS
- **Docker**: Version 20.10+
- **Docker Compose**: Version 1.29+ (hoặc Docker Compose v2)
- **RAM**: Tối thiểu 4GB (khuyến nghị 8GB)
- **Disk**: Tối thiểu 10GB trống

### 3.2. Cho VirtualBox VM

- **OS**: Windows, Linux, hoặc macOS
- **VirtualBox**: Version 6.1+
- **RAM**: Tối thiểu 8GB (phân bổ 4GB cho VM)
- **Disk**: Tối thiểu 20GB trống
- **Ubuntu Server ISO**: 22.04 LTS

---

## 4. Triển Khai với Docker

### 4.1. Cài Đặt Docker

#### Windows/macOS:
- Tải Docker Desktop từ: https://www.docker.com/products/docker-desktop
- Cài đặt và khởi động lại máy

#### Linux (Ubuntu/Debian):
```bash
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -aG docker $USER
newgrp docker
```

### 4.2. Build và Chạy

```bash
# 1. Navigate đến dự án
cd Automated-Multiple-Choice-Exam-Grading

# 2. Build Docker images
docker compose build

# 3. Khởi động services
docker compose up -d

# 4. Kiểm tra trạng thái
docker compose ps

# 5. Xem logs
docker compose logs -f
```

### 4.3. Truy Cập Ứng Dụng

Mở trình duyệt và truy cập:
- **URL**: http://localhost/
- **Giao diện**: http://localhost/static/index.html

### 4.4. Dừng Services

```bash
# Dừng services
docker compose down

# Dừng và xóa volumes
docker compose down -v
```

### 4.5. Cấu Hình Docker

**docker-compose.yml:**
```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: exam-grading-app
    volumes:
      - ./results:/src/results
      - ./Exam:/src/Exam
      - ./AnswerKey:/src/AnswerKey
    environment:
      - PYTHONUNBUFFERED=1
    restart: unless-stopped
    networks:
      - exam-grading-network

  nginx:
    image: nginx:alpine
    container_name: exam-grading-nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - app
    restart: unless-stopped
    networks:
      - exam-grading-network
```

---

## 5. Triển Khai với VirtualBox VM

### 5.1. Cài Đặt VirtualBox

**Windows/macOS:**
- Tải từ: https://www.virtualbox.org/wiki/Downloads
- Cài đặt theo hướng dẫn

**Linux:**
```bash
sudo apt-get update
sudo apt-get install -y virtualbox virtualbox-ext-pack
```

### 5.2. Tạo Virtual Machine

#### Bằng Command Line:

```bash
# Tạo VM
VBoxManage createvm --name "exam-grading-vm" --ostype "Ubuntu_64" --register

# Cấu hình RAM (4GB)
VBoxManage modifyvm "exam-grading-vm" --memory 4096

# Cấu hình CPU (2 cores)
VBoxManage modifyvm "exam-grading-vm" --cpus 2

# Tạo virtual disk (20GB)
VBoxManage createhd --filename "exam-grading-vm.vdi" --size 20480 --format VDI

# Gắn disk vào VM
VBoxManage storagectl "exam-grading-vm" --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach "exam-grading-vm" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "exam-grading-vm.vdi"

# Gắn ISO Ubuntu
VBoxManage storagectl "exam-grading-vm" --name "IDE Controller" --add ide
VBoxManage storageattach "exam-grading-vm" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium ubuntu-22.04-server-amd64.iso

# Cấu hình network với port forwarding
VBoxManage modifyvm "exam-grading-vm" --nic1 nat
VBoxManage modifyvm "exam-grading-vm" --natpf1 "guestssh,tcp,,2222,,22"
VBoxManage modifyvm "exam-grading-vm" --natpf1 "guesthttp,tcp,,8080,,80"
```

#### Bằng GUI:
1. Mở VirtualBox
2. Click "New"
3. Đặt tên: `exam-grading-vm`
4. Type: Linux, Version: Ubuntu (64-bit)
5. RAM: 4096 MB
6. Tạo virtual hard disk: 20GB, VDI
7. Settings → Network → Adapter 1 → NAT → Port Forwarding:
   - SSH: Host 2222 → Guest 22
   - HTTP: Host 8080 → Guest 80

### 5.3. Cài Đặt Ubuntu Server

1. Khởi động VM
2. Boot từ ISO Ubuntu Server
3. Cài đặt Ubuntu:
   - Chọn ngôn ngữ, múi giờ
   - Cấu hình user và password
   - **Quan trọng**: Cài đặt OpenSSH server
   - Hoàn tất cài đặt

### 5.4. Cấu Hình VM Sau Khi Cài Đặt

#### Kết Nối SSH:
```bash
ssh -p 2222 username@localhost
```

#### Cập Nhật Hệ Thống:
```bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y build-essential curl wget git
```

#### Cài Đặt Python và Dependencies:
```bash
# Python 3.10
sudo apt-get install -y python3.10 python3.10-venv python3-pip

# System dependencies
sudo apt-get install -y \
    poppler-utils \
    libgl1 \
    libglib2.0-0 \
    nginx

# TensorFlow dependencies
sudo apt-get install -y \
    python3-dev \
    libhdf5-dev \
    pkg-config
```

#### Deploy Ứng Dụng:
```bash
# Tạo thư mục
sudo mkdir -p /opt/exam-grading
sudo chown $USER:$USER /opt/exam-grading
cd /opt/exam-grading

# Copy files từ host
scp -P 2222 -r Automated-Multiple-Choice-Exam-Grading/* username@localhost:/opt/exam-grading/

# Hoặc clone từ git
git clone <repository-url> .

# Tạo virtual environment
python3 -m venv venv
source venv/bin/activate

# Cài đặt Python packages
pip install --upgrade pip
pip install -r requirements.txt
```

#### Cấu Hình Nginx:
```bash
sudo nano /etc/nginx/sites-available/exam-grading
```

Nội dung:
```nginx
server {
    listen 80;
    server_name localhost;
    client_max_body_size 20M;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/exam-grading /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### Tạo Systemd Service:
```bash
sudo nano /etc/systemd/system/exam-grading.service
```

Nội dung:
```ini
[Unit]
Description=Exam Grading FastAPI Application
After=network.target

[Service]
Type=simple
User=username
WorkingDirectory=/opt/exam-grading
Environment="PATH=/opt/exam-grading/venv/bin"
ExecStart=/opt/exam-grading/venv/bin/uvicorn user_interface:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable exam-grading
sudo systemctl start exam-grading
sudo systemctl status exam-grading
```

### 5.5. Kiểm Tra

```bash
# Từ trong VM
curl http://localhost/

# Từ host machine
curl http://localhost:8080/
```

---

## 6. Đo Lường Hiệu Năng

### 6.1. Cài Đặt Công Cụ

```bash
# Linux/WSL
sudo apt-get install -y \
    apache2-utils \  # ab (Apache Bench)
    bc \              # Calculator
    curl \
    wget

# Windows (qua WSL)
wsl sudo apt-get install -y apache2-utils bc
```

### 6.2. Các Script Đo Lường

| Script | Mô Tả |
|--------|-------|
| `measure_startup_time.sh` | Đo thời gian khởi động dịch vụ |
| `measure_disk_usage.sh` | Đo dung lượng đĩa sử dụng |
| `measure_resource_usage.sh` | Đo RAM và CPU (idle và under load) |
| `measure_throughput.sh` | Đo thông lượng (requests/giây) |
| `run_all_measurements.sh` | Chạy tất cả phép đo tự động |

### 6.3. Chạy Đo Lường

#### Trên Windows (PowerShell):

```powershell
# Chạy qua WSL
wsl bash scripts/measure_startup_time.sh docker --no-build
wsl bash scripts/measure_disk_usage.sh docker
wsl bash scripts/measure_resource_usage.sh docker 60
wsl bash scripts/measure_throughput.sh docker ab 10 1000
```

#### Trên Linux/WSL:

```bash
# Cấp quyền thực thi
chmod +x scripts/*.sh

# Đo thời gian khởi động
./scripts/measure_startup_time.sh docker --no-build
./scripts/measure_startup_time.sh docker

# Đo dung lượng đĩa
./scripts/measure_disk_usage.sh docker

# Đo RAM/CPU khi idle (60 giây)
./scripts/measure_resource_usage.sh docker 60

# Đo thông lượng
./scripts/measure_throughput.sh docker ab 10 1000

# Chạy tất cả phép đo
./scripts/run_all_measurements.sh docker
```

#### Đo Lường VM:

```bash
# Đo thời gian khởi động VM
./scripts/measure_startup_time.sh vm

# Đo dung lượng đĩa VM
./scripts/measure_disk_usage.sh vm

# Đo RAM/CPU VM (cần SSH)
export VM_SSH="user@localhost"
export VM_SSH_PORT="2222"
./scripts/measure_resource_usage.sh vm 60

# Chạy tất cả phép đo cho VM
./scripts/run_all_measurements.sh vm
```

### 6.4. Các Chỉ Số Đo Lường

1. **Thời gian khởi động dịch vụ**
   - Build time (Docker)
   - Start time
   - Ready time (từ start đến khi service sẵn sàng)

2. **Dung lượng đĩa sử dụng**
   - Docker image size
   - Container size
   - VM .vdi file size

3. **Mức sử dụng RAM và CPU**
   - Khi idle (không có request)
   - Khi có tải (under load)

4. **Thông lượng (Throughput)**
   - Requests per second
   - Latency (p50, p75, p90, p99)
   - Time per request

### 6.5. Kết Quả

Tất cả kết quả được lưu trong `measurement_results/`:
- `startup_time_*.txt` - Báo cáo chi tiết
- `startup_time_*.csv` - Dữ liệu CSV
- `disk_usage_*.txt` - Dung lượng đĩa
- `resource_usage_*.txt` - RAM/CPU usage
- `resource_usage_*.csv` - RAM/CPU data
- `throughput_*.txt` - Thông lượng
- `full_report_*.md` - Báo cáo tổng hợp

---

## 7. So Sánh Docker vs VM

### 7.1. Nguyên Lý HĐH

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

### 7.2. Chi Phí Cô Lập (Isolation Overhead)

| Aspect | Docker | VM |
|--------|--------|----|
| **Process Isolation** | ✅ Namespace | ✅ Full |
| **Network Isolation** | ✅ Network namespace | ✅ Virtual network |
| **Filesystem Isolation** | ✅ Mount namespace | ✅ Virtual disk |
| **Hardware Isolation** | ❌ | ✅ |
| **Kernel Isolation** | ❌ | ✅ |

**Overhead Comparison:**
- Docker: ~50-100 MB RAM + 1-2% CPU
- VM: ~200-500 MB RAM + 5-15% CPU

### 7.3. Kết Luận So Sánh

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

### 7.4. Khi Nào Dùng Docker?

✅ **Nên dùng Docker khi:**
- Cần deploy nhanh, scale dễ dàng
- Tài nguyên hạn chế
- Ứng dụng stateless, microservices
- Development và testing
- CI/CD pipelines
- Multi-tenant với trust cao

### 7.5. Khi Nào Dùng VM?

✅ **Nên dùng VM khi:**
- Cần security cao, isolation hoàn toàn
- Chạy ứng dụng legacy cần full OS
- Multi-tenant với yêu cầu bảo mật cao
- Cần chạy nhiều OS khác nhau
- Compliance yêu cầu hardware isolation

### 7.6. Template Báo Cáo

Xem [COMPARISON_TEMPLATE.md](COMPARISON_TEMPLATE.md) để tạo báo cáo so sánh chi tiết.

---

## 8. Sử Dụng Ứng Dụng

### 8.1. Truy Cập Giao Diện

Mở trình duyệt và truy cập:
- **URL**: http://localhost/ (Docker)
- **URL**: http://localhost:8080/ (VM)

### 8.2. Upload Bài Thi

1. Chọn file ảnh bài thi (JPG, PNG, hoặc PDF)
2. Chọn file đáp án (Excel .xlsx)
3. Click "Tải lên"

### 8.3. Xem Kết Quả

Kết quả hiển thị:
- **Số báo danh (SBD)**: 6 chữ số
- **Mã đề thi (MDT)**: 3 chữ số
- **Số câu đúng**: X / 120
- **Điểm số**: X.XX / 10
- **Ảnh đã chú thích**: Có thể tải xuống

### 8.4. Format Đáp Án

File Excel đáp án cần có cấu trúc:
- Cột 1: STT (1-120)
- Cột 2: Answer (A, B, C, hoặc D)

---

## 9. Troubleshooting

### 9.1. Docker

#### Container không start

```bash
# Kiểm tra logs
docker compose logs

# Kiểm tra trạng thái
docker compose ps

# Kiểm tra resource
docker stats
```

#### Port đã được sử dụng

Sửa `docker-compose.yml`:
```yaml
ports:
  - "8080:80"  # Thay vì "80:80"
```

#### Out of memory

```bash
# Tăng memory limit trong docker-compose.yml
deploy:
  resources:
    limits:
      memory: 2G
```

#### Build failed

```bash
# Xóa cache và build lại
docker compose build --no-cache

# Kiểm tra Dockerfile
cat Dockerfile
```

### 9.2. VirtualBox VM

#### VM không boot

```bash
# Kiểm tra VM state
VBoxManage showvminfo exam-grading-vm

# Reset VM
VBoxManage controlvm exam-grading-vm reset

# Kiểm tra logs
VBoxManage showvminfo exam-grading-vm --log
```

#### Không kết nối được SSH

```bash
# Kiểm tra port forwarding
VBoxManage showvminfo exam-grading-vm | grep natpf

# Test connection
telnet localhost 2222

# Kiểm tra SSH trong VM
sudo systemctl status ssh
```

#### Service không start

```bash
# Kiểm tra logs
sudo journalctl -u exam-grading -f

# Kiểm tra status
sudo systemctl status exam-grading

# Test manual
cd /opt/exam-grading
source venv/bin/activate
uvicorn user_interface:app --host 0.0.0.0 --port 8000
```

### 9.3. Scripts

#### Script không chạy được trên Windows

```powershell
# Chạy qua WSL
wsl bash scripts/measure_startup_time.sh docker --no-build
```

#### Lỗi "command not found"

```bash
# Cài đặt dependencies
sudo apt-get install -y bc apache2-utils

# Kiểm tra Docker
docker --version
```

#### Lỗi "permission denied"

```bash
# Cấp quyền thực thi
chmod +x scripts/*.sh
```

### 9.4. Ứng Dụng

#### Không upload được file

- Kiểm tra kích thước file (tối đa 20MB)
- Kiểm tra format file (JPG, PNG, PDF cho ảnh; XLSX cho đáp án)
- Kiểm tra logs: `docker compose logs app`

#### Kết quả không chính xác

- Kiểm tra chất lượng ảnh (độ phân giải, độ sáng)
- Kiểm tra format đáp án (STT và Answer)
- Kiểm tra model weights: `weight.keras`

---

## 10. Cấu Trúc Dự Án

```
Automated-Multiple-Choice-Exam-Grading/
├── 📄 Core Files
│   ├── Dockerfile                 # Docker image definition
│   ├── docker-compose.yml         # Docker Compose config
│   ├── nginx.conf                 # Nginx reverse proxy config
│   ├── requirements.txt           # Python dependencies
│   └── .dockerignore              # Docker ignore file
│
├── 🐍 Python Application
│   ├── main.py                    # Main processing logic
│   ├── user_interface.py          # FastAPI application
│   ├── process_answer.py          # Answer processing
│   ├── process_sbd_mdt.py         # SBD/MDT processing
│   ├── model_answer.py            # CNN model
│   └── weight.keras               # Trained model weights
│
├── 📂 Data Directories
│   ├── static/                    # Frontend files
│   ├── Exam/                      # Sample exam images
│   ├── AnswerKey/                 # Answer key files
│   ├── results/                   # Output results
│   └── create_dataset/            # Dataset để train model
│
├── 📊 Measurement Scripts
│   ├── measure_startup_time.sh    # Đo thời gian khởi động
│   ├── measure_disk_usage.sh      # Đo dung lượng đĩa
│   ├── measure_resource_usage.sh  # Đo RAM/CPU
│   ├── measure_throughput.sh      # Đo thông lượng
│   ├── run_all_measurements.sh    # Chạy tất cả phép đo
│   ├── wrk_script.lua             # Script Lua cho wrk
│   └── README_WINDOWS.md          # Hướng dẫn Windows
│
├── 📈 Results
│   └── measurement_results/        # Kết quả đo lường
│
└── 📚 Documentation
    ├── WIKI.md                    # File này (Wiki tổng hợp)
    ├── README.md                   # Tổng quan dự án
    ├── RUN_GUIDE.md                # Hướng dẫn chạy chi tiết
    ├── DEPLOYMENT_AND_MEASUREMENT_GUIDE.md  # Hướng dẫn triển khai
    ├── COMPARISON_TEMPLATE.md      # Template báo cáo so sánh
    ├── QUICK_START.md              # Quick start guide
    ├── README_DEPLOYMENT.md        # Tổng quan deployment
    └── CLEANUP_SUMMARY.md          # Tóm tắt dọn dẹp
```

### 10.1. Files Quan Trọng

#### Để Chạy Docker:
1. `docker-compose.yml` - Cấu hình Docker Compose
2. `Dockerfile` - Docker image definition
3. `nginx.conf` - Nginx reverse proxy config
4. `requirements.txt` - Python dependencies

#### Để Chạy VM:
1. Tất cả files Python
2. `nginx.conf` - Cấu hình Nginx (copy vào VM)
3. `requirements.txt` - Cài đặt dependencies

#### Để Đo Lường:
1. `scripts/measure_startup_time.sh` - Đo thời gian khởi động
2. `scripts/measure_disk_usage.sh` - Đo dung lượng đĩa
3. `scripts/measure_resource_usage.sh` - Đo RAM/CPU
4. `scripts/measure_throughput.sh` - Đo thông lượng
5. `scripts/run_all_measurements.sh` - Chạy tất cả phép đo

---

## 11. Tài Liệu Tham Khảo

### 11.1. Official Documentation

- **Docker**: https://docs.docker.com/
- **Docker Compose**: https://docs.docker.com/compose/
- **VirtualBox**: https://www.virtualbox.org/manual/
- **Nginx**: https://nginx.org/en/docs/
- **FastAPI**: https://fastapi.tiangolo.com/
- **OpenCV**: https://docs.opencv.org/
- **TensorFlow**: https://www.tensorflow.org/api_docs

### 11.2. Kiến Trúc và Nguyên Lý

- **Linux Namespaces**: https://man7.org/linux/man-pages/man7/namespaces.7.html
- **cgroups**: https://www.kernel.org/doc/Documentation/cgroup-v1/cgroups.txt
- **Hypervisor**: https://en.wikipedia.org/wiki/Hypervisor
- **Container vs VM**: https://www.docker.com/resources/what-container/

### 11.3. Benchmarking Tools

- **Apache Bench (ab)**: https://httpd.apache.org/docs/2.4/programs/ab.html
- **wrk**: https://github.com/wg/wrk
- **Docker Stats**: https://docs.docker.com/engine/reference/commandline/stats/

---

## 📝 Quick Reference

### Docker Commands

```bash
# Build
docker compose build

# Start
docker compose up -d

# Stop
docker compose down

# Logs
docker compose logs -f

# Status
docker compose ps

# Stats
docker stats
```

### VM Commands

```bash
# Start VM
VBoxManage startvm exam-grading-vm --type headless

# Stop VM
VBoxManage controlvm exam-grading-vm poweroff

# SSH
ssh -p 2222 user@localhost

# Service
sudo systemctl start exam-grading
sudo systemctl status exam-grading
```

### Measurement Commands

```bash
# Startup time
./scripts/measure_startup_time.sh docker --no-build

# Disk usage
./scripts/measure_disk_usage.sh docker

# Resource usage
./scripts/measure_resource_usage.sh docker 60

# Throughput
./scripts/measure_throughput.sh docker ab 10 1000

# All measurements
./scripts/run_all_measurements.sh docker
```

---

## ✅ Checklist

### Docker Deployment
- [ ] Docker đã cài đặt
- [ ] `docker compose build` thành công
- [ ] `docker compose up -d` thành công
- [ ] Truy cập được http://localhost/
- [ ] Đã chạy các script đo lường

### VM Deployment
- [ ] VirtualBox đã cài đặt
- [ ] VM đã tạo và cài Ubuntu
- [ ] SSH kết nối được
- [ ] Ứng dụng đã deploy
- [ ] Nginx đã cấu hình
- [ ] Systemd service đã tạo
- [ ] Truy cập được http://localhost:8080/
- [ ] Đã chạy các script đo lường

### Measurement
- [ ] Đã cài đặt công cụ đo lường
- [ ] Đã chạy đo lường cho Docker
- [ ] Đã chạy đo lường cho VM
- [ ] Đã ghi lại tất cả kết quả
- [ ] Đã tạo bảng so sánh
- [ ] Đã viết báo cáo phân tích

---

## 📞 Contact

For questions or feedback:
- **Email**: nhmanh.dev@gmail.com
- **Repository**: [GitHub URL]

---

## 📄 License

This project is licensed under the MIT License.

---

**Version:** 1.0  
**Last Updated:** 2025-12-10  
**Maintained by:** [Your Name]

---

## 🔗 Internal Links

- [README.md](README.md) - Tổng quan dự án
- [RUN_GUIDE.md](RUN_GUIDE.md) - Hướng dẫn chạy chi tiết
- [DEPLOYMENT_AND_MEASUREMENT_GUIDE.md](DEPLOYMENT_AND_MEASUREMENT_GUIDE.md) - Hướng dẫn triển khai
- [COMPARISON_TEMPLATE.md](COMPARISON_TEMPLATE.md) - Template báo cáo
- [QUICK_START.md](QUICK_START.md) - Quick start guide

---

**⭐ Bắt đầu ngay:** Đọc phần [4. Triển Khai với Docker](#4-triển-khai-với-docker) hoặc [5. Triển Khai với VirtualBox VM](#5-triển-khai-với-virtualbox-vm)!


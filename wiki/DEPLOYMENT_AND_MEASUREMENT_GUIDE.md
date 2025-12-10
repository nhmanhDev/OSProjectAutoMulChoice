# Hướng Dẫn Triển Khai và Đo Lường Hiệu Năng
## So Sánh Virtual Machine (VM) và Docker Container

---

## Mục Lục

1. [Tổng Quan](#tổng-quan)
2. [Kiến Trúc Hệ Thống](#kiến-trúc-hệ-thống)
3. [Triển Khai với Docker](#triển-khai-với-docker)
4. [Triển Khai với VirtualBox VM](#triển-khai-với-virtualbox-vm)
5. [Hướng Dẫn Đo Lường Chi Tiết](#hướng-dẫn-đo-lường-chi-tiết)
6. [Phân Tích và So Sánh](#phân-tích-và-so-sánh)
7. [Troubleshooting](#troubleshooting)

---

## Tổng Quan

### Mục Tiêu

Bài tập này nhằm so sánh hai công nghệ ảo hóa:
- **Virtual Machine (VM)**: Ảo hóa phần cứng (Hardware Virtualization)
- **Docker Container**: Ảo hóa cấp hệ điều hành (OS-level Virtualization)

### Ứng Dụng Được Triển Khai

Hệ thống chấm bài thi trắc nghiệm tự động (Automated Multiple-Choice Exam Grading):
- **Backend**: FastAPI (Python)
- **Web Server**: Nginx (reverse proxy)
- **Xử lý ảnh**: OpenCV, TensorFlow
- **Frontend**: HTML/CSS/JavaScript

### Các Chỉ Số Đo Lường

1. **Thời gian khởi động dịch vụ** (Startup Time)
2. **Dung lượng đĩa sử dụng** (Disk Usage)
3. **Mức sử dụng RAM và CPU khi idle** (Idle Resource Usage)
4. **Thông lượng** (Throughput - requests/giây)
5. **Mức sử dụng RAM và CPU khi có tải** (Resource Usage Under Load)

---

## Kiến Trúc Hệ Thống

### Kiến Trúc Docker

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

### Kiến Trúc VM

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

### So Sánh Kiến Trúc

| Khía Cạnh | Docker Container | Virtual Machine |
|-----------|------------------|-----------------|
| **Isolation Level** | Process-level | Hardware-level |
| **Guest OS** | Không cần (dùng kernel của host) | Cần cài đặt đầy đủ |
| **Overhead** | Thấp (chỉ namespace, cgroups) | Cao (hypervisor, full OS) |
| **Startup Time** | Nhanh (giây) | Chậm (phút) |
| **Resource Usage** | Thấp | Cao |
| **Portability** | Rất cao | Trung bình |

---

## Triển Khai với Docker

### Yêu Cầu Hệ Thống

- **OS**: Linux, macOS, hoặc Windows (với WSL2)
- **Docker**: Version 20.10 trở lên
- **Docker Compose**: Version 1.29 trở lên
- **RAM**: Tối thiểu 4GB (khuyến nghị 8GB)
- **Disk**: Tối thiểu 10GB trống

### Bước 1: Cài Đặt Docker

#### Trên Ubuntu/Debian:

```bash
# Cập nhật package list
sudo apt-get update

# Cài đặt dependencies
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Thêm Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Setup repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Cài đặt Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Thêm user vào docker group (không cần sudo)
sudo usermod -aG docker $USER
newgrp docker

# Kiểm tra cài đặt
docker --version
docker compose version
```

#### Trên Windows:

1. Tải Docker Desktop từ: https://www.docker.com/products/docker-desktop
2. Cài đặt và khởi động lại máy
3. Đảm bảo WSL2 được bật

### Bước 2: Chuẩn Bị Dự Án

```bash
# Clone hoặc copy dự án
cd Automated-Multiple-Choice-Exam-Grading

# Kiểm tra các file cần thiết
ls -la
# Cần có: Dockerfile, docker-compose.yml, nginx.conf
```

### Bước 3: Build và Chạy

```bash
# Build Docker images
docker compose build

# Khởi động services
docker compose up -d

# Kiểm tra trạng thái
docker compose ps

# Xem logs
docker compose logs -f
```

### Bước 4: Kiểm Tra

```bash
# Kiểm tra nginx
curl http://localhost/

# Kiểm tra FastAPI
curl http://localhost/static/index.html

# Mở trình duyệt
# http://localhost/static/index.html
```

### Bước 5: Dừng và Dọn Dẹp

```bash
# Dừng services
docker compose down

# Dừng và xóa volumes
docker compose down -v

# Xóa images
docker compose down --rmi all
```

---

## Triển Khai với VirtualBox VM

### Yêu Cầu Hệ Thống

- **Host OS**: Windows, Linux, hoặc macOS
- **VirtualBox**: Version 6.1 trở lên
- **RAM**: Tối thiểu 8GB (phân bổ 4GB cho VM)
- **Disk**: Tối thiểu 20GB trống
- **ISO Ubuntu Server**: 22.04 LTS

### Bước 1: Cài Đặt VirtualBox

#### Trên Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y virtualbox virtualbox-ext-pack
```

#### Trên Windows/macOS:

Tải từ: https://www.virtualbox.org/wiki/Downloads

### Bước 2: Tạo Virtual Machine

#### 2.1. Tạo VM mới

```bash
# Sử dụng VBoxManage (command line)
VBoxManage createvm --name "exam-grading-vm" --ostype "Ubuntu_64" --register

# Hoặc sử dụng GUI:
# 1. Mở VirtualBox
# 2. Click "New"
# 3. Đặt tên: "exam-grading-vm"
# 4. Type: Linux
# 5. Version: Ubuntu (64-bit)
```

#### 2.2. Cấu Hình VM

```bash
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

# Cấu hình network (NAT với port forwarding)
VBoxManage modifyvm "exam-grading-vm" --nic1 nat
VBoxManage modifyvm "exam-grading-vm" --natpf1 "guestssh,tcp,,2222,,22"
VBoxManage modifyvm "exam-grading-vm" --natpf1 "guesthttp,tcp,,8080,,80"
```

#### 2.3. Khởi Động và Cài Đặt Ubuntu

```bash
# Khởi động VM
VBoxManage startvm "exam-grading-vm" --type gui

# Hoặc headless
VBoxManage startvm "exam-grading-vm" --type headless
```

**Trong quá trình cài đặt Ubuntu:**
- Chọn ngôn ngữ, múi giờ
- Cấu hình user và password
- Cài đặt OpenSSH server (quan trọng!)
- Hoàn tất cài đặt

### Bước 3: Cấu Hình VM Sau Khi Cài Đặt

#### 3.1. Kết Nối SSH

```bash
# Từ host machine
ssh -p 2222 username@localhost

# Hoặc nếu có IP của VM
ssh username@vm_ip
```

#### 3.2. Cập Nhật Hệ Thống

```bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y build-essential curl wget git
```

#### 3.3. Cài Đặt Python và Dependencies

```bash
# Cài đặt Python 3.10
sudo apt-get install -y python3.10 python3.10-venv python3-pip

# Cài đặt system dependencies
sudo apt-get install -y \
    poppler-utils \
    libgl1-mesa-glx \
    libglib2.0-0 \
    nginx

# Cài đặt TensorFlow dependencies
sudo apt-get install -y \
    python3-dev \
    libhdf5-dev \
    pkg-config
```

#### 3.4. Deploy Ứng Dụng

```bash
# Tạo thư mục
sudo mkdir -p /opt/exam-grading
sudo chown $USER:$USER /opt/exam-grading
cd /opt/exam-grading

# Copy files từ host (sử dụng scp hoặc git)
# Từ host machine:
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

#### 3.5. Cấu Hình Nginx

```bash
# Copy nginx config
sudo cp nginx.conf /etc/nginx/nginx.conf

# Hoặc tạo config riêng
sudo nano /etc/nginx/sites-available/exam-grading
```

Nội dung file `/etc/nginx/sites-available/exam-grading`:

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
# Enable site
sudo ln -s /etc/nginx/sites-available/exam-grading /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### 3.6. Tạo Systemd Service

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
# Enable và start service
sudo systemctl daemon-reload
sudo systemctl enable exam-grading
sudo systemctl start exam-grading
sudo systemctl status exam-grading
```

### Bước 4: Kiểm Tra

```bash
# Kiểm tra nginx
curl http://localhost/

# Kiểm tra từ host machine
curl http://localhost:8080/
```

---

## Hướng Dẫn Đo Lường Chi Tiết

### Cài Đặt Công Cụ Đo Lường

```bash
# Cài đặt các công cụ cần thiết
sudo apt-get install -y \
    apache2-utils \  # ab (Apache Bench)
    bc \              # Calculator cho scripts
    curl \
    wget \
    htop \
    iotop \
    sysstat

# Cài đặt wrk (nếu cần)
# Từ source:
git clone https://github.com/wg/wrk.git
cd wrk
make
sudo cp wrk /usr/local/bin/
```

### Cấu Trúc Thư Mục Scripts

```
scripts/
├── measure_startup_time.sh      # Đo thời gian khởi động
├── measure_disk_usage.sh         # Đo dung lượng đĩa
├── measure_resource_usage.sh     # Đo RAM/CPU
├── measure_throughput.sh         # Đo thông lượng
├── wrk_script.lua                # Script Lua cho wrk
└── run_all_measurements.sh       # Chạy tất cả phép đo
```

### 1. Đo Thời Gian Khởi Động Dịch Vụ

#### 1.1. Với Docker

```bash
# Cấp quyền thực thi
chmod +x scripts/measure_startup_time.sh

# Chạy đo lường
./scripts/measure_startup_time.sh docker

# Kết quả sẽ được lưu trong:
# measurement_results/startup_time_docker_YYYYMMDD_HHMMSS.txt
```

**Các chỉ số đo được:**
- **Build time**: Thời gian build Docker image
- **Start time**: Thời gian start container
- **Ready time**: Thời gian từ start đến khi service sẵn sàng nhận request
- **Stop time**: Thời gian dừng container

**Phân tích chi tiết:**

```bash
# Xem kết quả
cat measurement_results/startup_time_docker_*.txt

# So sánh nhiều lần chạy
for i in {1..5}; do
    echo "=== Lần chạy $i ==="
    ./scripts/measure_startup_time.sh docker
    sleep 5
done
```

#### 1.2. Với VM

```bash
# Đo thời gian boot VM
VBoxManage startvm "exam-grading-vm" --type headless
time (until ssh -p 2222 user@localhost "echo ready"; do sleep 1; done)

# Đo thời gian start service trong VM
ssh -p 2222 user@localhost "sudo systemctl start exam-grading"
time (until curl -f http://localhost:8080/ > /dev/null 2>&1; do sleep 0.1; done)
```

**Lưu ý:**
- Đo nhiều lần và lấy trung bình
- Ghi lại thời gian chính xác đến millisecond
- So sánh với Docker

### 2. Đo Dung Lượng Đĩa Sử Dụng

#### 2.1. Với Docker

```bash
chmod +x scripts/measure_disk_usage.sh
./scripts/measure_disk_usage.sh docker
```

**Các chỉ số đo được:**
- **Image size**: Kích thước Docker images
- **Container size**: Kích thước container khi chạy
- **Volume size**: Dung lượng volumes
- **Total Docker usage**: Tổng dung lượng Docker sử dụng

**Phân tích:**

```bash
# Xem chi tiết
docker system df -v

# So sánh image layers
docker history exam-grading-app:latest

# Đo kích thước từng layer
docker image inspect exam-grading-app:latest --format='{{.Size}}' | numfmt --to=iec-i
```

#### 2.2. Với VM

```bash
# Đo kích thước file .vdi
VBoxManage showhdinfo exam-grading-vm.vdi

# Hoặc từ command line
du -h exam-grading-vm.vdi

# Đo dung lượng trong VM
ssh -p 2222 user@localhost "df -h"
ssh -p 2222 user@localhost "du -sh /opt/exam-grading"
```

**So sánh:**
- Docker image size vs VM .vdi file size
- Docker container size vs VM disk usage
- Tính toán overhead của mỗi phương pháp

### 3. Đo Mức Sử Dụng RAM và CPU Khi Idle

#### 3.1. Với Docker

```bash
chmod +x scripts/measure_resource_usage.sh

# Đo trong 60 giây khi idle
./scripts/measure_resource_usage.sh docker 60
```

**Các chỉ số đo được:**
- **CPU %**: Phần trăm CPU sử dụng
- **Memory (MB)**: RAM sử dụng tính bằng MB
- **Memory %**: Phần trăm RAM sử dụng

**Phân tích chi tiết:**

```bash
# Xem kết quả CSV
cat measurement_results/resource_usage_docker_*.csv

# Tính toán thống kê
awk -F',' 'NR>1 {sum+=$2; count++} END {print "CPU trung bình:", sum/count "%"}' \
    measurement_results/resource_usage_docker_*.csv

# Vẽ biểu đồ (cần gnuplot hoặc Python)
python3 -c "
import pandas as pd
import matplotlib.pyplot as plt
df = pd.read_csv('measurement_results/resource_usage_docker_*.csv')
plt.plot(df['timestamp'], df['cpu_percent'])
plt.xlabel('Time')
plt.ylabel('CPU %')
plt.title('CPU Usage Over Time')
plt.savefig('cpu_usage.png')
"
```

#### 3.2. Với VM

```bash
# Đo từ bên trong VM
ssh -p 2222 user@localhost "top -bn1 | grep 'Cpu(s)'"
ssh -p 2222 user@localhost "free -m"

# Hoặc sử dụng script
./scripts/measure_resource_usage.sh vm 60
```

**So sánh:**
- RAM baseline: Docker vs VM
- CPU baseline: Docker vs VM
- Overhead của mỗi phương pháp

### 4. Đo Thông Lượng (Throughput)

#### 4.1. Sử Dụng Apache Bench (ab)

```bash
chmod +x scripts/measure_throughput.sh

# Test với 10 concurrent requests, 1000 total requests
./scripts/measure_throughput.sh docker ab 10 1000
```

**Các chỉ số đo được:**
- **Requests per second**: Số request/giây
- **Time per request**: Thời gian trung bình mỗi request
- **Transfer rate**: Tốc độ truyền dữ liệu
- **Latency**: Độ trễ (min, max, mean, median)

**Phân tích:**

```bash
# Xem kết quả chi tiết
cat measurement_results/throughput_docker_ab_*.txt

# So sánh với các mức concurrent khác nhau
for c in 1 5 10 20 50 100; do
    echo "=== Concurrent: $c ==="
    ab -n 1000 -c $c http://localhost/ > results_ab_c${c}.txt
    grep "Requests per second" results_ab_c${c}.txt
done
```

#### 4.2. Sử Dụng wrk

```bash
# Cài đặt wrk (nếu chưa có)
git clone https://github.com/wg/wrk.git
cd wrk && make && sudo cp wrk /usr/local/bin/

# Chạy test
./scripts/measure_throughput.sh docker wrk 10 1000
```

**Ưu điểm của wrk:**
- Hỗ trợ Lua scripting
- Đo latency percentiles chi tiết hơn
- Hiệu năng cao hơn ab

#### 4.3. Test Với Tải Thực Tế

```bash
# Simulate upload file (cần tạo file test)
ab -n 100 -c 5 -p test_image.jpg -T 'multipart/form-data' \
   http://localhost/upload-image

# Hoặc sử dụng curl script
for i in {1..100}; do
    curl -X POST -F "image=@test_image.jpg" -F "answer_key=@answer_key.xlsx" \
         http://localhost/upload-image &
done
wait
```

### 5. Đo Tài Nguyên Khi Có Tải

```bash
# Chạy benchmark và đo tài nguyên song song
(
    # Chạy benchmark trong background
    ab -n 5000 -c 50 http://localhost/ > /dev/null 2>&1 &
    BENCH_PID=$!
    
    # Đo tài nguyên
    ./scripts/measure_resource_usage.sh docker 60
    
    # Đợi benchmark hoàn thành
    wait $BENCH_PID
)
```

**So sánh:**
- RAM usage khi idle vs khi có tải
- CPU usage khi idle vs khi có tải
- Scaling behavior của mỗi phương pháp

### 6. Chạy Tất Cả Phép Đo Tự Động

```bash
chmod +x scripts/run_all_measurements.sh

# Chạy tất cả phép đo cho Docker
./scripts/run_all_measurements.sh docker

# Chạy tất cả phép đo cho VM
./scripts/run_all_measurements.sh vm
```

**Kết quả:**
- Báo cáo tổng hợp trong `measurement_results/full_report_*.md`
- Tất cả các file chi tiết trong `measurement_results/`

---

## Phân Tích và So Sánh

### Bảng So Sánh Tổng Hợp

Tạo file `COMPARISON_REPORT.md` với bảng so sánh:

| Chỉ Số | Docker | VM | Chênh Lệch | Ghi Chú |
|--------|--------|----|-----------|---------|
| **Startup Time** | X giây | Y giây | Z% | ... |
| **Disk Usage** | X GB | Y GB | Z% | ... |
| **RAM Idle** | X MB | Y MB | Z% | ... |
| **CPU Idle** | X% | Y% | Z% | ... |
| **Throughput** | X req/s | Y req/s | Z% | ... |
| **RAM Under Load** | X MB | Y MB | Z% | ... |
| **CPU Under Load** | X% | Y% | Z% | ... |

### Phân Tích Chi Tiết

#### 1. Thời Gian Khởi Động

**Docker:**
- Build image: ~2-5 phút (lần đầu)
- Start container: ~1-3 giây
- Service ready: ~5-10 giây
- **Tổng**: ~10-15 giây (không tính build)

**VM:**
- Boot VM: ~30-60 giây
- Start service: ~5-10 giây
- **Tổng**: ~35-70 giây

**Kết luận:** Docker nhanh hơn 3-5 lần

#### 2. Dung Lượng Đĩa

**Docker:**
- Base image (Python): ~900 MB
- Application code: ~100 MB
- Dependencies: ~500 MB
- **Tổng image**: ~1.5 GB
- **Container running**: +50-100 MB

**VM:**
- Ubuntu Server base: ~2.5 GB
- Application: ~100 MB
- Dependencies: ~500 MB
- **Tổng .vdi**: ~3-4 GB

**Kết luận:** Docker tiết kiệm ~50% dung lượng

#### 3. Tài Nguyên Khi Idle

**Docker:**
- RAM: ~200-300 MB
- CPU: ~0.5-1%

**VM:**
- RAM: ~500-800 MB (bao gồm OS)
- CPU: ~1-2%

**Kết luận:** Docker tiết kiệm ~60% RAM

#### 4. Thông Lượng

**Docker:**
- Requests/second: ~500-800 (tùy hardware)
- Latency p50: ~10-20ms
- Latency p99: ~50-100ms

**VM:**
- Requests/second: ~400-700
- Latency p50: ~15-25ms
- Latency p99: ~60-120ms

**Kết luận:** Docker có hiệu năng tốt hơn ~10-20%

### Nguyên Lý HĐH Liên Quan

#### 1. Quản Lý Tài Nguyên

**Docker sử dụng:**
- **cgroups**: Giới hạn và theo dõi tài nguyên (CPU, RAM, I/O)
- **namespaces**: Cô lập process, network, filesystem
- **Overhead thấp**: Chỉ thêm một lớp abstraction mỏng

**VM sử dụng:**
- **Hypervisor**: Quản lý toàn bộ hardware virtualization
- **Full OS**: Mỗi VM chạy một OS hoàn chỉnh
- **Overhead cao**: Phải quản lý kernel, drivers, system services

#### 2. Chi Phí Cô Lập (Isolation Overhead)

**Docker:**
- Isolation level: Process-level
- Overhead: ~1-5% CPU, ~50-100 MB RAM
- Security: Namespace isolation (tốt nhưng không bằng VM)

**VM:**
- Isolation level: Hardware-level
- Overhead: ~5-15% CPU, ~200-500 MB RAM
- Security: Hoàn toàn cô lập (tốt hơn)

### Kết Luận và Khuyến Nghị

**Sử dụng Docker khi:**
- Cần deploy nhanh, scale dễ dàng
- Tài nguyên hạn chế
- Ứng dụng stateless, microservices
- Development và testing

**Sử dụng VM khi:**
- Cần security cao, isolation hoàn toàn
- Chạy ứng dụng legacy cần full OS
- Multi-tenant với yêu cầu bảo mật cao
- Cần chạy nhiều OS khác nhau

---

## Troubleshooting

### Vấn Đề Với Docker

#### 1. Container không start

```bash
# Kiểm tra logs
docker compose logs

# Kiểm tra resource
docker stats

# Kiểm tra network
docker network ls
docker network inspect exam-grading-network
```

#### 2. Port đã được sử dụng

```bash
# Tìm process đang dùng port 80
sudo lsof -i :80
sudo netstat -tulpn | grep :80

# Thay đổi port trong docker-compose.yml
ports:
  - "8080:80"
```

#### 3. Out of memory

```bash
# Tăng memory limit
docker update --memory=2g exam-grading-app

# Hoặc trong docker-compose.yml
deploy:
  resources:
    limits:
      memory: 2G
```

### Vấn Đề Với VM

#### 1. VM không boot

```bash
# Kiểm tra VM state
VBoxManage showvminfo exam-grading-vm

# Reset VM
VBoxManage controlvm exam-grading-vm reset

# Kiểm tra logs
VBoxManage showvminfo exam-grading-vm --log
```

#### 2. Không kết nối được SSH

```bash
# Kiểm tra port forwarding
VBoxManage showvminfo exam-grading-vm | grep natpf

# Kiểm tra network
VBoxManage showvminfo exam-grading-vm | grep NIC

# Test connection
telnet localhost 2222
```

#### 3. Service không start

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

---

## Phụ Lục

### A. Scripts Bổ Sung

Tạo các script Python để phân tích dữ liệu:

```python
# scripts/analyze_results.py
import pandas as pd
import matplotlib.pyplot as plt

# Đọc CSV
df = pd.read_csv('measurement_results/resource_usage_docker_*.csv')

# Vẽ biểu đồ
plt.figure(figsize=(12, 6))
plt.subplot(2, 1, 1)
plt.plot(df['timestamp'], df['cpu_percent'])
plt.title('CPU Usage Over Time')
plt.ylabel('CPU %')

plt.subplot(2, 1, 2)
plt.plot(df['timestamp'], df['memory_mb'])
plt.title('Memory Usage Over Time')
plt.xlabel('Time')
plt.ylabel('Memory (MB)')

plt.tight_layout()
plt.savefig('resource_usage.png')
```

### B. Tài Liệu Tham Khảo

- Docker Documentation: https://docs.docker.com/
- VirtualBox Manual: https://www.virtualbox.org/manual/
- Nginx Documentation: https://nginx.org/en/docs/
- FastAPI Documentation: https://fastapi.tiangolo.com/

### C. Checklist Đo Lường

- [ ] Đã cài đặt tất cả công cụ cần thiết
- [ ] Đã chạy đo lường cho Docker
- [ ] Đã chạy đo lường cho VM
- [ ] Đã ghi lại tất cả kết quả
- [ ] Đã tạo bảng so sánh
- [ ] Đã viết báo cáo phân tích
- [ ] Đã vẽ biểu đồ minh họa

---

**Tác giả:** [Tên của bạn]  
**Ngày:** $(date)  
**Version:** 1.0


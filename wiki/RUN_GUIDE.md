# Hướng Dẫn Chạy Hệ Thống
## Automated Multiple-Choice Exam Grading

---

## 📋 Mục Lục

1. [Yêu Cầu Hệ Thống](#yêu-cầu-hệ-thống)
2. [Triển Khai với Docker](#triển-khai-với-docker)
3. [Triển Khai với VirtualBox VM](#triển-khai-với-virtualbox-vm)
4. [Đo Lường Hiệu Năng](#đo-lường-hiệu-năng)
5. [Troubleshooting](#troubleshooting)

---

## 🔧 Yêu Cầu Hệ Thống

### Cho Docker
- **OS**: Windows 10/11, Linux, hoặc macOS
- **Docker**: Version 20.10+ 
- **Docker Compose**: Version 1.29+ (hoặc Docker Compose v2)
- **RAM**: Tối thiểu 4GB (khuyến nghị 8GB)
- **Disk**: Tối thiểu 10GB trống

### Cho VirtualBox VM
- **OS**: Windows, Linux, hoặc macOS
- **VirtualBox**: Version 6.1+
- **RAM**: Tối thiểu 8GB (phân bổ 4GB cho VM)
- **Disk**: Tối thiểu 20GB trống
- **Ubuntu Server ISO**: 22.04 LTS

---

## 🐳 Triển Khai với Docker

### Bước 1: Kiểm Tra Docker

```bash
# Kiểm tra Docker đã cài đặt
docker --version
docker compose version

# Nếu chưa có, cài đặt Docker Desktop từ:
# https://www.docker.com/products/docker-desktop
```

### Bước 2: Clone/Navigate đến Dự Án

```bash
cd Automated-Multiple-Choice-Exam-Grading
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

### Bước 4: Truy Cập Ứng Dụng

Mở trình duyệt và truy cập:
- **URL**: http://localhost/
- **Giao diện**: http://localhost/static/index.html

### Bước 5: Dừng Services

```bash
# Dừng services
docker compose down

# Dừng và xóa volumes
docker compose down -v
```

### Cấu Trúc Docker

```
┌─────────────────────────────┐
│   Docker Network            │
│  ┌──────────┐  ┌─────────┐ │
│  │  Nginx   │──│ FastAPI │ │
│  │  :80     │  │  :8000  │ │
│  └──────────┘  └─────────┘ │
└─────────────────────────────┘
```

**Services:**
- `exam-grading-nginx`: Nginx reverse proxy (port 80)
- `exam-grading-app`: FastAPI application (port 8000)

---

## 💻 Triển Khai với VirtualBox VM

### Bước 1: Cài Đặt VirtualBox

**Windows/macOS:**
- Tải từ: https://www.virtualbox.org/wiki/Downloads
- Cài đặt theo hướng dẫn

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install -y virtualbox virtualbox-ext-pack
```

### Bước 2: Tạo Virtual Machine

#### 2.1. Tạo VM bằng Command Line

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

#### 2.2. Hoặc Tạo VM bằng GUI

1. Mở VirtualBox
2. Click "New"
3. Đặt tên: `exam-grading-vm`
4. Type: Linux
5. Version: Ubuntu (64-bit)
6. RAM: 4096 MB
7. Tạo virtual hard disk: 20GB, VDI
8. Settings → Network → Adapter 1 → NAT → Port Forwarding:
   - SSH: Host 2222 → Guest 22
   - HTTP: Host 8080 → Guest 80

### Bước 3: Cài Đặt Ubuntu Server

1. Khởi động VM
2. Boot từ ISO Ubuntu Server
3. Cài đặt Ubuntu:
   - Chọn ngôn ngữ, múi giờ
   - Cấu hình user và password
   - **Quan trọng**: Cài đặt OpenSSH server
   - Hoàn tất cài đặt

### Bước 4: Cấu Hình VM Sau Khi Cài Đặt

#### 4.1. Kết Nối SSH

```bash
# Từ host machine
ssh -p 2222 username@localhost

# Hoặc nếu có IP của VM
ssh username@vm_ip
```

#### 4.2. Cập Nhật Hệ Thống

```bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y build-essential curl wget git
```

#### 4.3. Cài Đặt Python và Dependencies

```bash
# Cài đặt Python 3.10
sudo apt-get install -y python3.10 python3.10-venv python3-pip

# Cài đặt system dependencies
sudo apt-get install -y \
    poppler-utils \
    libgl1 \
    libglib2.0-0 \
    nginx

# Cài đặt TensorFlow dependencies
sudo apt-get install -y \
    python3-dev \
    libhdf5-dev \
    pkg-config
```

#### 4.4. Deploy Ứng Dụng

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

#### 4.5. Cấu Hình Nginx

```bash
# Tạo nginx config
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
# Enable site
sudo ln -s /etc/nginx/sites-available/exam-grading /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### 4.6. Tạo Systemd Service

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

### Bước 5: Kiểm Tra

```bash
# Kiểm tra từ trong VM
curl http://localhost/

# Kiểm tra từ host machine
curl http://localhost:8080/
```

---

## 📊 Đo Lường Hiệu Năng

### Cài Đặt Công Cụ

```bash
# Trên Linux/WSL
sudo apt-get install -y \
    apache2-utils \  # ab (Apache Bench)
    bc \              # Calculator
    curl \
    wget

# Trên Windows (qua WSL)
wsl sudo apt-get install -y apache2-utils bc
```

### Chạy Đo Lường

#### Trên Windows (PowerShell)

```powershell
# Sử dụng wrapper script
.\scripts\measure_startup_time_wrapper.ps1 docker -NoBuild
.\scripts\measure_startup_time_wrapper.ps1 docker

# Hoặc chạy trực tiếp qua WSL
wsl bash scripts/measure_startup_time.sh docker --no-build
wsl bash scripts/measure_disk_usage.sh docker
wsl bash scripts/measure_resource_usage.sh docker 60
wsl bash scripts/measure_throughput.sh docker ab 10 1000
```

#### Trên Linux/WSL

```bash
# Cấp quyền thực thi
chmod +x scripts/*.sh

# Đo thời gian khởi động
./scripts/measure_startup_time.sh docker --no-build
./scripts/measure_startup_time.sh docker

# Đo dung lượng đĩa
./scripts/measure_disk_usage.sh docker

# Đo RAM/CPU (60 giây)
./scripts/measure_resource_usage.sh docker 60

# Đo thông lượng
./scripts/measure_throughput.sh docker ab 10 1000

# Chạy tất cả phép đo
./scripts/run_all_measurements.sh docker
```

#### Đo Lường VM

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

### Kết Quả

Tất cả kết quả được lưu trong `measurement_results/`:
- `startup_time_*.txt` - Báo cáo chi tiết
- `startup_time_*.csv` - Dữ liệu CSV
- `disk_usage_*.txt` - Dung lượng đĩa
- `resource_usage_*.txt` - RAM/CPU usage
- `resource_usage_*.csv` - RAM/CPU data
- `throughput_*.txt` - Thông lượng
- `full_report_*.md` - Báo cáo tổng hợp

---

## 🔍 Troubleshooting

### Docker

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

### VirtualBox VM

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

### Scripts

#### Script không chạy được trên Windows

```powershell
# Sử dụng wrapper script
.\scripts\measure_startup_time_wrapper.ps1 docker -NoBuild

# Hoặc chạy qua WSL
wsl bash scripts/measure_startup_time.sh docker --no-build
```

#### Lỗi "command not found"

```bash
# Cài đặt dependencies
sudo apt-get install -y bc apache2-utils

# Kiểm tra Docker
docker --version
```

---

## 📁 Cấu Trúc Dự Án

```
Automated-Multiple-Choice-Exam-Grading/
├── Dockerfile                 # Docker image cho FastAPI
├── docker-compose.yml         # Docker Compose config
├── nginx.conf                 # Nginx reverse proxy config
├── requirements.txt           # Python dependencies
│
├── main.py                    # Main processing logic
├── user_interface.py          # FastAPI application
├── process_answer.py          # Answer processing
├── process_sbd_mdt.py         # SBD/MDT processing
├── model_answer.py            # CNN model
├── weight.keras               # Trained model weights
│
├── static/                    # Frontend files
├── Exam/                      # Sample exam images
├── AnswerKey/                 # Answer key files
├── results/                   # Output results
│
├── scripts/                   # Measurement scripts
│   ├── measure_startup_time.sh
│   ├── measure_startup_time_wrapper.ps1
│   ├── measure_disk_usage.sh
│   ├── measure_resource_usage.sh
│   ├── measure_throughput.sh
│   ├── run_all_measurements.sh
│   └── wrk_script.lua
│
├── measurement_results/       # Measurement results
│
├── RUN_GUIDE.md              # File này
├── DEPLOYMENT_AND_MEASUREMENT_GUIDE.md  # Hướng dẫn chi tiết
├── COMPARISON_TEMPLATE.md    # Template báo cáo
└── QUICK_START.md            # Quick start guide
```

---

## 📚 Tài Liệu Tham Khảo

- **Docker**: https://docs.docker.com/
- **VirtualBox**: https://www.virtualbox.org/manual/
- **Nginx**: https://nginx.org/en/docs/
- **FastAPI**: https://fastapi.tiangolo.com/

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

---

**Version:** 1.0  
**Last Updated:** $(date)


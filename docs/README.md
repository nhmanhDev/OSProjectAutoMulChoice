# AUTOMATED MULTIPLE-CHOICE EXAM GRADING
## Hệ Thống Chấm Bài Thi Trắc Nghiệm Tự Động

---

## 📋 Tổng Quan

Hệ thống tự động chấm bài thi trắc nghiệm bằng cách xử lý ảnh bài thi đã scan và so sánh với đáp án. Hệ thống hỗ trợ triển khai trên cả **Docker Container** và **Virtual Machine** để so sánh hiệu năng.

### Tính Năng

- ✅ Upload và xử lý ảnh bài thi (JPG, PNG, PDF)
- ✅ Nhận diện số báo danh (SBD) và mã đề thi (MDT)
- ✅ Chấm điểm tự động 120 câu trắc nghiệm
- ✅ Hiển thị kết quả với ảnh đã chú thích
- ✅ Web interface thân thiện
- ✅ API RESTful với FastAPI

---

## 🚀 Bắt Đầu Nhanh

### Với Docker (Khuyến nghị)

```bash
# 1. Build và chạy
docker compose build
docker compose up -d

# 2. Truy cập
# Mở trình duyệt: http://localhost/
```

### Với VirtualBox VM

Xem chi tiết trong [RUN_GUIDE.md](RUN_GUIDE.md)

---

## 📚 Tài Liệu

| File | Mô Tả |
|------|-------|
| **[RUN_GUIDE.md](RUN_GUIDE.md)** | ⭐ **Hướng dẫn chạy chi tiết cho Docker và VM** |
| [DEPLOYMENT_AND_MEASUREMENT_GUIDE.md](DEPLOYMENT_AND_MEASUREMENT_GUIDE.md) | Hướng dẫn triển khai và đo lường chi tiết |
| [QUICK_START.md](QUICK_START.md) | Hướng dẫn nhanh 5 phút |
| [COMPARISON_TEMPLATE.md](COMPARISON_TEMPLATE.md) | Template báo cáo so sánh VM vs Docker |
| [README_DEPLOYMENT.md](README_DEPLOYMENT.md) | Tổng quan về deployment |

---

## 🏗️ Kiến Trúc

### Stack Công Nghệ

- **Backend**: FastAPI (Python)
- **Web Server**: Nginx (reverse proxy)
- **Image Processing**: OpenCV, TensorFlow
- **Frontend**: HTML/CSS/JavaScript
- **Containerization**: Docker, Docker Compose

### Cấu Trúc

```
┌─────────────┐
│   Nginx     │ :80
│ (Reverse    │
│   Proxy)    │
└──────┬──────┘
       │
┌──────▼──────┐
│   FastAPI   │ :8000
│ Application │
└─────────────┘
```

---

## 📦 Yêu Cầu

### Cho Docker
- Docker 20.10+
- Docker Compose 1.29+
- RAM: 4GB+ (khuyến nghị 8GB)
- Disk: 10GB+

### Cho VM
- VirtualBox 6.1+
- Ubuntu Server 22.04 ISO
- RAM: 8GB+ (phân bổ 4GB cho VM)
- Disk: 20GB+

---

## 🔧 Cài Đặt

### 1. Clone Repository

```bash
git clone <repository-url>
cd Automated-Multiple-Choice-Exam-Grading
```

### 2. Triển Khai

**Docker:**
```bash
docker compose build
docker compose up -d
```

**VM:**
Xem [RUN_GUIDE.md](RUN_GUIDE.md) phần "Triển Khai với VirtualBox VM"

---

## 📊 Đo Lường Hiệu Năng

Hệ thống bao gồm các script để đo lường và so sánh hiệu năng giữa Docker và VM:

### Trên Windows

```powershell
# Sử dụng wrapper script
.\scripts\measure_startup_time_wrapper.ps1 docker -NoBuild
```

### Trên Linux/WSL

```bash
chmod +x scripts/*.sh

# Đo thời gian khởi động
./scripts/measure_startup_time.sh docker --no-build

# Đo dung lượng đĩa
./scripts/measure_disk_usage.sh docker

# Đo RAM/CPU
./scripts/measure_resource_usage.sh docker 60

# Đo thông lượng
./scripts/measure_throughput.sh docker ab 10 1000

# Chạy tất cả
./scripts/run_all_measurements.sh docker
```

Kết quả được lưu trong `measurement_results/`

---

## 📁 Cấu Trúc Dự Án

```
Automated-Multiple-Choice-Exam-Grading/
├── Dockerfile                 # Docker image
├── docker-compose.yml         # Docker Compose config
├── nginx.conf                 # Nginx config
├── requirements.txt           # Python dependencies
│
├── main.py                    # Main processing
├── user_interface.py          # FastAPI app
├── process_answer.py          # Answer processing
├── process_sbd_mdt.py         # SBD/MDT processing
├── model_answer.py            # CNN model
├── weight.keras               # Model weights
│
├── static/                    # Frontend
├── Exam/                      # Sample exams
├── AnswerKey/                 # Answer keys
├── results/                   # Output results
│
├── scripts/                   # Measurement scripts
│   ├── measure_startup_time.sh
│   ├── measure_startup_time_wrapper.ps1
│   ├── measure_disk_usage.sh
│   ├── measure_resource_usage.sh
│   ├── measure_throughput.sh
│   └── run_all_measurements.sh
│
├── measurement_results/       # Measurement results
│
└── Documentation/
    ├── RUN_GUIDE.md          # ⭐ Hướng dẫn chạy
    ├── DEPLOYMENT_AND_MEASUREMENT_GUIDE.md
    ├── COMPARISON_TEMPLATE.md
    └── QUICK_START.md
```

---

## 🎯 Sử Dụng

### 1. Truy Cập Giao Diện

Mở trình duyệt: http://localhost/

### 2. Upload Bài Thi

1. Chọn file ảnh bài thi (JPG, PNG, hoặc PDF)
2. Chọn file đáp án (Excel .xlsx)
3. Click "Tải lên"

### 3. Xem Kết Quả

- Số báo danh (SBD)
- Mã đề thi (MDT)
- Số câu đúng / Tổng số câu
- Điểm số
- Ảnh đã chú thích (có thể tải xuống)

---

## 🔬 So Sánh Docker vs VM

Hệ thống được thiết kế để so sánh hiệu năng giữa:
- **Docker Container**: Ảo hóa cấp hệ điều hành
- **Virtual Machine**: Ảo hóa phần cứng

Các chỉ số đo lường:
- Thời gian khởi động
- Dung lượng đĩa sử dụng
- Mức sử dụng RAM và CPU
- Thông lượng (requests/giây)

Xem [COMPARISON_TEMPLATE.md](COMPARISON_TEMPLATE.md) để tạo báo cáo so sánh.

---

## 🛠️ Troubleshooting

### Docker không start

```bash
docker compose logs
docker compose ps
```

### Port đã được sử dụng

Sửa `docker-compose.yml`:
```yaml
ports:
  - "8080:80"  # Thay vì "80:80"
```

### Scripts không chạy trên Windows

```powershell
# Sử dụng wrapper
.\scripts\measure_startup_time_wrapper.ps1 docker -NoBuild

# Hoặc qua WSL
wsl bash scripts/measure_startup_time.sh docker --no-build
```

Xem [RUN_GUIDE.md](RUN_GUIDE.md) phần Troubleshooting để biết thêm.

---

## 📝 License

This project is licensed under the MIT License.

---

## 👤 Contact

For questions or feedback, please contact: nhmanh.dev@gmail.com

---

## 📖 Tài Liệu Tham Khảo

- [Docker Documentation](https://docs.docker.com/)
- [VirtualBox Manual](https://www.virtualbox.org/manual/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)

---

**⭐ Bắt đầu ngay:** Đọc [RUN_GUIDE.md](RUN_GUIDE.md) để triển khai hệ thống!

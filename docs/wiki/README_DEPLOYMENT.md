# Hướng Dẫn Triển Khai và Đo Lường
## So Sánh Docker Container vs Virtual Machine

---

## 📋 Mục Lục

- [Tổng Quan](#tổng-quan)
- [Cấu Trúc Dự Án](#cấu-trúc-dự-án)
- [Quick Start](#quick-start)
- [Tài Liệu Chi Tiết](#tài-liệu-chi-tiết)

---

## 🎯 Tổng Quan

Dự án này triển khai hệ thống chấm bài thi trắc nghiệm tự động trên hai môi trường:
1. **Docker Container** - Ảo hóa cấp hệ điều hành
2. **Virtual Machine (VirtualBox)** - Ảo hóa phần cứng

Sau đó đo lường và so sánh hiệu năng giữa hai phương pháp.

### Các Chỉ Số Đo Lường

✅ Thời gian khởi động dịch vụ  
✅ Dung lượng đĩa sử dụng  
✅ Mức sử dụng RAM và CPU khi idle  
✅ Thông lượng (requests/giây)  
✅ Mức sử dụng RAM và CPU khi có tải  

---

## 📁 Cấu Trúc Dự Án

```
Automated-Multiple-Choice-Exam-Grading/
├── Dockerfile                 # Docker image cho FastAPI app
├── docker-compose.yml         # Docker Compose config với Nginx
├── nginx.conf                 # Nginx reverse proxy config
├── .dockerignore              # Files bỏ qua khi build Docker
│
├── scripts/                   # Scripts đo lường
│   ├── measure_startup_time.sh
│   ├── measure_disk_usage.sh
│   ├── measure_resource_usage.sh
│   ├── measure_throughput.sh
│   ├── wrk_script.lua
│   └── run_all_measurements.sh
│
├── measurement_results/       # Kết quả đo lường (tự động tạo)
│
├── DEPLOYMENT_AND_MEASUREMENT_GUIDE.md  # Hướng dẫn chi tiết
├── COMPARISON_TEMPLATE.md     # Template báo cáo so sánh
├── QUICK_START.md             # Hướng dẫn nhanh
└── README_DEPLOYMENT.md       # File này
```

---

## 🚀 Quick Start

### Với Docker (Khuyến nghị)

```bash
# 1. Build và chạy
docker compose build
docker compose up -d

# 2. Kiểm tra
curl http://localhost/

# 3. Đo lường
chmod +x scripts/*.sh
./scripts/run_all_measurements.sh docker

# 4. Xem kết quả
ls -lh measurement_results/
```

### Với VirtualBox VM

Xem chi tiết trong `DEPLOYMENT_AND_MEASUREMENT_GUIDE.md` phần "Triển Khai với VirtualBox VM"

---

## 📚 Tài Liệu Chi Tiết

### 1. QUICK_START.md
Hướng dẫn nhanh để bắt đầu trong 5 phút.

### 2. DEPLOYMENT_AND_MEASUREMENT_GUIDE.md
**Tài liệu chính** bao gồm:
- Hướng dẫn cài đặt Docker và VirtualBox
- Triển khai chi tiết từng bước
- Hướng dẫn đo lường tất cả các chỉ số
- Phân tích nguyên lý HĐH
- Troubleshooting

### 3. COMPARISON_TEMPLATE.md
Template để điền kết quả và tạo báo cáo so sánh.

---

## 🔧 Yêu Cầu Hệ Thống

### Docker
- Docker 20.10+
- Docker Compose 1.29+
- RAM: 4GB+ (khuyến nghị 8GB)
- Disk: 10GB+

### VirtualBox
- VirtualBox 6.1+
- RAM: 8GB+ (phân bổ 4GB cho VM)
- Disk: 20GB+
- Ubuntu Server 22.04 ISO

---

## 📊 Các Script Đo Lường

### 1. Đo Thời Gian Khởi Động
```bash
./scripts/measure_startup_time.sh docker
./scripts/measure_startup_time.sh vm
```

### 2. Đo Dung Lượng Đĩa
```bash
./scripts/measure_disk_usage.sh docker
./scripts/measure_disk_usage.sh vm
```

### 3. Đo RAM/CPU
```bash
# Idle (60 giây)
./scripts/measure_resource_usage.sh docker 60

# Under load (chạy benchmark song song)
```

### 4. Đo Thông Lượng
```bash
# Sử dụng Apache Bench
./scripts/measure_throughput.sh docker ab 10 1000

# Sử dụng wrk
./scripts/measure_throughput.sh docker wrk 10 1000
```

### 5. Chạy Tất Cả
```bash
./scripts/run_all_measurements.sh docker
./scripts/run_all_measurements.sh vm
```

---

## 📈 Kết Quả

Sau khi chạy các script, kết quả sẽ được lưu trong:
- `measurement_results/` - Tất cả file kết quả
- `measurement_results/full_report_*.md` - Báo cáo tổng hợp

Điền kết quả vào `COMPARISON_TEMPLATE.md` để tạo báo cáo so sánh.

---

## 🆘 Troubleshooting

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

### Scripts không chạy được
```bash
chmod +x scripts/*.sh
```

Xem chi tiết trong `DEPLOYMENT_AND_MEASUREMENT_GUIDE.md` phần Troubleshooting.

---

## 📝 Checklist Hoàn Thành

- [ ] Đã cài đặt Docker/VirtualBox
- [ ] Đã triển khai với Docker
- [ ] Đã triển khai với VM
- [ ] Đã chạy tất cả phép đo cho Docker
- [ ] Đã chạy tất cả phép đo cho VM
- [ ] Đã điền kết quả vào COMPARISON_TEMPLATE.md
- [ ] Đã viết báo cáo phân tích

---

## 📖 Tài Liệu Tham Khảo

- [Docker Documentation](https://docs.docker.com/)
- [VirtualBox Manual](https://www.virtualbox.org/manual/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)

---

## 👤 Liên Hệ

Nếu có vấn đề hoặc câu hỏi, vui lòng xem:
1. `DEPLOYMENT_AND_MEASUREMENT_GUIDE.md` - Hướng dẫn chi tiết
2. `QUICK_START.md` - Hướng dẫn nhanh
3. Phần Troubleshooting trong các file trên

---

**Version:** 1.0  
**Last Updated:** $(date)


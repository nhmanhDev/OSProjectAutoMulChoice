# Quick Start Guide
## Triển Khai Nhanh với Docker và Nginx

---

## 1. Triển Khai với Docker (5 phút)

### Bước 1: Kiểm tra Docker

```bash
docker --version
docker compose version
```

### Bước 2: Build và Chạy

```bash
# Build images
docker compose build

# Start services
docker compose up -d

# Kiểm tra
docker compose ps
```

### Bước 3: Truy Cập

Mở trình duyệt: http://localhost/

### Bước 4: Dừng

```bash
docker compose down
```

---

## 2. Đo Lường Hiệu Năng

### Chạy Tất Cả Phép Đo

```bash
# Cấp quyền
chmod +x scripts/*.sh

# Chạy tất cả phép đo cho Docker
./scripts/run_all_measurements.sh docker
```

### Chạy Từng Phép Đo Riêng

```bash
# 1. Đo thời gian khởi động
./scripts/measure_startup_time.sh docker

# 2. Đo dung lượng đĩa
./scripts/measure_disk_usage.sh docker

# 3. Đo RAM/CPU khi idle (60 giây)
./scripts/measure_resource_usage.sh docker 60

# 4. Đo thông lượng
./scripts/measure_throughput.sh docker ab 10 1000
```

### Xem Kết Quả

```bash
# Xem tất cả kết quả
ls -lh measurement_results/

# Xem báo cáo tổng hợp
cat measurement_results/full_report_docker_*.md
```

---

## 3. Triển Khai với VirtualBox VM

### Bước 1: Tạo VM

```bash
VBoxManage createvm --name "exam-grading-vm" --ostype "Ubuntu_64" --register
VBoxManage modifyvm "exam-grading-vm" --memory 4096 --cpus 2
VBoxManage createhd --filename "exam-grading-vm.vdi" --size 20480
VBoxManage storagectl "exam-grading-vm" --name "SATA Controller" --add sata
VBoxManage storageattach "exam-grading-vm" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "exam-grading-vm.vdi"
```

### Bước 2: Cài Ubuntu và Deploy

Xem chi tiết trong `DEPLOYMENT_AND_MEASUREMENT_GUIDE.md`

### Bước 3: Đo Lường

```bash
./scripts/run_all_measurements.sh vm
```

---

## 4. So Sánh Kết Quả

1. Chạy đo lường cho cả Docker và VM
2. Điền vào `COMPARISON_TEMPLATE.md`
3. Tạo báo cáo so sánh

---

## 5. Troubleshooting

### Docker không start

```bash
docker compose logs
docker compose ps
```

### Port đã được sử dụng

Sửa `docker-compose.yml`, đổi port:
```yaml
ports:
  - "8080:80"  # Thay vì "80:80"
```

### Xem chi tiết

Xem file `DEPLOYMENT_AND_MEASUREMENT_GUIDE.md` để có hướng dẫn đầy đủ.

---

**Tài liệu đầy đủ:** `DEPLOYMENT_AND_MEASUREMENT_GUIDE.md`


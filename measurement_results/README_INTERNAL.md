# Scripts Đo Lường Từ Bên Trong VM/Docker

Các scripts này đo lường từ **BÊN TRONG** VM hoặc Docker container, khác với các scripts trong `scripts/` đo từ HOST.

## Cấu Trúc Thư Mục

```
measurement_results/
├── VM/                    # Kết quả đo từ bên trong VM
├── docker/                # Kết quả đo từ bên trong Docker
└── measure_*_internal.sh  # Scripts đo từ bên trong
```

## Scripts

### 1. `measure_resource_usage_internal.sh`
Đo RAM và CPU từ bên trong VM/Docker.

**Sử dụng:**
```bash
cd measurement_results
bash measure_resource_usage_internal.sh docker 60
bash measure_resource_usage_internal.sh vm 60
```

**Kết quả:** Lưu vào `VM/` hoặc `docker/`

### 2. `measure_disk_usage_internal.sh`
Đo dung lượng đĩa từ bên trong VM/Docker.

**Sử dụng:**
```bash
bash measure_disk_usage_internal.sh docker
bash measure_disk_usage_internal.sh vm
```

### 3. `measure_throughput_internal.sh`
Đo thông lượng từ bên trong VM/Docker.

**Sử dụng:**
```bash
bash measure_throughput_internal.sh docker ab 10 1000
bash measure_throughput_internal.sh vm ab 10 1000
```

### 4. `measure_startup_time_internal.sh`
Đo thời gian khởi động từ bên trong VM/Docker.

**Sử dụng:**
```bash
bash measure_startup_time_internal.sh docker
bash measure_startup_time_internal.sh vm
```

### 5. `run_all_measurements_internal.sh`
Chạy tất cả các phép đo từ bên trong.

**Sử dụng:**
```bash
bash run_all_measurements_internal.sh docker
bash run_all_measurements_internal.sh vm
```

## So Sánh: Đo Từ Host vs Từ Bên Trong

| Aspect | Từ Host (`scripts/`) | Từ Bên Trong (`measurement_results/`) |
|--------|---------------------|--------------------------------------|
| **Docker** | `docker stats` | `docker exec` + `top` |
| **VM** | PowerShell đo VirtualBox process | SSH vào VM + `top`/`free` |
| **Memory** | Process memory từ host | Memory thực tế bên trong |
| **CPU** | CPU % của process | CPU % của hệ thống bên trong |
| **Disk** | Docker image size / VDI file | `df -h` từ bên trong |
| **Kết quả** | `measurement_results/` | `measurement_results/VM/` hoặc `docker/` |

## Lưu Ý

- **Docker**: Cần container đang chạy
- **VM**: Cần SSH access (đã setup với `vm-ubuntu` alias)
- Các scripts tự động tạo folder `VM/` và `docker/` nếu chưa có


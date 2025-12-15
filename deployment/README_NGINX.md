# Hướng dẫn chạy Web với Nginx trên Ubuntu (Virtual)

## Các bước thực hiện:

### 1. Cài đặt và cấu hình Nginx

Chạy script tự động:
```bash
cd /home/sysadmin/Desktop/OSProjectAutoMulChoice/deployment
bash setup_nginx.sh
```

Hoặc làm thủ công:

```bash
# Cài đặt nginx
sudo apt update
sudo apt install -y nginx

# Copy config
sudo cp osproject-site.conf /etc/nginx/sites-available/osproject
sudo ln -sf /etc/nginx/sites-available/osproject /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test config
sudo nginx -t

# Khởi động nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### 2. Khởi động FastAPI Backend

Mở terminal mới và chạy:
```bash
cd /home/sysadmin/Desktop/OSProjectAutoMulChoice/app
python3 user_interface.py
```

Backend sẽ chạy tại: `http://localhost:8000`

### 3. Truy cập Web App

Mở trình duyệt và truy cập:
- **http://localhost** (port 80 - qua nginx)
- Hoặc **http://localhost:8000** (trực tiếp FastAPI)

## Kiểm tra trạng thái:

```bash
# Kiểm tra nginx
sudo systemctl status nginx

# Xem logs nginx
sudo tail -f /var/log/nginx/osproject-access.log
sudo tail -f /var/log/nginx/osproject-error.log

# Test nginx config
sudo nginx -t

# Reload nginx (sau khi sửa config)
sudo systemctl reload nginx
```

## Cấu trúc:

- **Nginx (port 80)**: Serve static files từ `frontend/dist` và proxy API requests
- **FastAPI (port 8000)**: Backend API xử lý upload và grading
- **React Build**: Static files trong `frontend/dist/`

## Troubleshooting:

1. **Lỗi 502 Bad Gateway**: 
   - Kiểm tra FastAPI backend có đang chạy không
   - `curl http://localhost:8000/health`

2. **Lỗi 404 cho static files**:
   - Kiểm tra đường dẫn: `ls -la /home/sysadmin/Desktop/OSProjectAutoMulChoice/frontend/dist`
   - Kiểm tra quyền: `sudo chown -R www-data:www-data /home/sysadmin/Desktop/OSProjectAutoMulChoice/frontend/dist`

3. **Port 80 đã được sử dụng**:
   - Kiểm tra: `sudo lsof -i :80`
   - Hoặc đổi port trong config: `listen 8080;`


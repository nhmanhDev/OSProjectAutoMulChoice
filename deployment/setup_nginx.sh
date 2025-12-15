#!/bin/bash

# Script setup nginx cho local development
# Chạy với: bash setup_nginx.sh

echo "=== Cài đặt và cấu hình Nginx ==="

# 1. Cài đặt nginx
echo "Bước 1: Cài đặt nginx..."
sudo apt update
sudo apt install -y nginx

# 2. Backup config mặc định
echo "Bước 2: Backup config mặc định..."
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

# 3. Copy config mới
echo "Bước 3: Copy config mới..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Tạo symlink hoặc copy config
sudo cp "$SCRIPT_DIR/osproject-site.conf" /etc/nginx/sites-available/osproject
sudo ln -sf /etc/nginx/sites-available/osproject /etc/nginx/sites-enabled/

# Disable default site
sudo rm -f /etc/nginx/sites-enabled/default

# 4. Test config
echo "Bước 4: Test cấu hình nginx..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✓ Cấu hình hợp lệ!"
    
    # 5. Khởi động nginx
    echo "Bước 5: Khởi động nginx..."
    sudo systemctl restart nginx
    sudo systemctl enable nginx
    
    echo ""
    echo "=== Hoàn tất! ==="
    echo "Nginx đã được cấu hình và khởi động."
    echo "Web app sẽ chạy tại: http://localhost"
    echo ""
    echo "Lưu ý: Đảm bảo FastAPI backend đang chạy tại port 8000:"
    echo "  cd $PROJECT_ROOT/app && python3 user_interface.py"
    echo ""
    echo "Kiểm tra trạng thái nginx:"
    echo "  sudo systemctl status nginx"
else
    echo "✗ Có lỗi trong cấu hình nginx. Vui lòng kiểm tra lại."
    exit 1
fi


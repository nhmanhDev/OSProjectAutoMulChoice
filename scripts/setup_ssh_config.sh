#!/bin/bash

# Script để setup SSH config cho VM
# Chạy: bash scripts/setup_ssh_config.sh

SSH_CONFIG="$HOME/.ssh/config"
SSH_DIR="$HOME/.ssh"

# Tạo thư mục .ssh nếu chưa có
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Kiểm tra xem config đã có entry cho vm-ubuntu chưa
if grep -q "Host vm-ubuntu" "$SSH_CONFIG" 2>/dev/null; then
    echo "SSH config đã có entry cho vm-ubuntu"
    echo "Nếu muốn cập nhật, xóa entry cũ trong $SSH_CONFIG"
else
    # Thêm config vào file
    cat >> "$SSH_CONFIG" << 'EOF'

# VM Ubuntu for measurements
Host vm-ubuntu
    HostName 127.0.0.1
    Port 2222
    User sysadmin
    IdentityFile ~/.ssh/id_ed25519_vm
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
    chmod 600 "$SSH_CONFIG"
    echo "✅ Đã thêm SSH config cho vm-ubuntu vào $SSH_CONFIG"
fi

echo ""
echo "Test SSH connection:"
ssh vm-ubuntu "echo 'SSH connection successful!'"


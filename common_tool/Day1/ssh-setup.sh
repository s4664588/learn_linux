#!/bin/bash

# SSH 測試環境設定腳本
# 此腳本用於建立 SSH 金鑰對並配置測試環境

set -e

echo "🔧 開始設定 SSH 測試環境..."

# 建立 SSH 金鑰目錄
mkdir -p ./ssh-keys
chmod 700 ./ssh-keys

# 生成 SSH 金鑰對（如果不存在）
if [ ! -f "./ssh-keys/id_rsa" ]; then
    echo "📋 生成 SSH 金鑰對..."
    ssh-keygen -t rsa -b 4096 -f "./ssh-keys/id_rsa" -N "" -C "ssh-tunnel-test"
    echo "✅ SSH 金鑰對已生成"
else
    echo "ℹ️  SSH 金鑰對已存在，跳過生成"
fi

# 設定金鑰權限
chmod 600 ./ssh-keys/id_rsa
chmod 644 ./ssh-keys/id_rsa.pub

# 建立 authorized_keys 檔案
cp ./ssh-keys/id_rsa.pub ./ssh-keys/authorized_keys
chmod 600 ./ssh-keys/authorized_keys

# 建立 SSH 配置檔案
cat > ./ssh-keys/config << 'EOF'
# SSH 測試環境配置

# SSH 跳板主機
Host gateway
    HostName localhost
    Port 2222
    User sshuser
    IdentityFile ~/.ssh-keys/id_rsa
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

# 透過跳板連接目標伺服器 1（使用 SSH Tunnel）
Host target1-via-gateway
    HostName localhost
    Port 8081
    User root
    IdentityFile ~/.ssh-keys/id_rsa
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

# 透過跳板連接目標伺服器 2（使用 SSH Tunnel）
Host target2-via-gateway
    HostName localhost
    Port 8082
    User root
    IdentityFile ~/.ssh-keys/id_rsa
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

# SSH Tunnel 配置範例
# 本機 port 8080 -> target-server-1:80 (Web)
# ssh -L 8080:target-server-1:80 gateway

# 本機 port 8081 -> target-server-1:22 (SSH)
# ssh -L 8081:target-server-1:22 gateway

# 本機 port 8082 -> target-server-2:22 (SSH)
# ssh -L 8082:target-server-2:22 gateway

# 本機 port 8083 -> target-server-2:3306 (MySQL)
# ssh -L 8083:target-server-2:3306 gateway
EOF

chmod 600 ./ssh-keys/config

echo "✅ SSH 測試環境設定完成！"
echo ""
echo "📖 使用說明："
echo "1. 啟動環境: docker-compose up -d"
echo "2. 查看狀態: docker-compose ps"
echo "3. 連接跳板: ssh -F ./ssh-keys/config gateway"
echo "4. 測試 Tunnel: ssh -L 8080:target-server-1:80 -F ./ssh-keys/config gateway"
echo "5. 開啟瀏覽器: http://localhost:8080"
echo ""
echo "🔍 更多測試指令請參考 ssh-test-commands.md"


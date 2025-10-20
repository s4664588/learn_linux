# SSH Tunnel 測試指令參考

> 基於 hello02923 的 SSH Tunnel 文章實作  
> 參考：https://ithelp.ithome.com.tw/articles/10290848

## 🚀 環境啟動

```powershell
# 啟動測試環境
docker-compose up -d

# 檢查狀態
docker-compose ps
```

## 🔑 基本連線

### SSH Gateway 連線
```bash
# 密碼連線
ssh -p 2222 sshuser@localhost
# 密碼: password123

# 在跳板主機內測試
ping target-server-1
ping target-server-2
curl http://target-server-1
```

## 🌉 SSH Tunnel 實作

### 1. Web 服務 Tunnel
```bash
# PuTTY 設定: 8080 → target-server-1:80
# 或命令列:
ssh -L 8080:target-server-1:80 -p 2222 sshuser@localhost

# 測試:
curl http://localhost:8080
```

### 2. SSH 服務 Tunnel
```bash
# PuTTY 設定: 8081 → target-server-1:22
# 或命令列:
ssh -L 8081:target-server-1:22 -p 2222 sshuser@localhost

# 測試:
ssh -p 8081 root@localhost
# 密碼: rootpassword
```

### 3. 資料庫服務 Tunnel
```bash
# PuTTY 設定: 8083 → target-server-2:3306
# 或命令列:
ssh -L 8083:target-server-2:3306 -p 2222 sshuser@localhost

# 測試:
mysql -h localhost -P 8083 -u testuser -p
# 密碼: testpass
```

### 4. 多重 Tunnel
```bash
# 同時建立多個 Port Forwarding
ssh -L 8080:target-server-1:80 \
    -L 8081:target-server-1:22 \
    -L 8083:target-server-2:3306 \
    -p 2222 sshuser@localhost
```

## 🔧 進階技巧

### 背景執行
```bash
# 背景執行 SSH Tunnel
ssh -f -L 8080:target-server-1:80 -p 2222 sshuser@localhost -N

# 終止背景程序
pkill -f "ssh.*8080"
```

### SOCKS 代理
```bash
# 建立 SOCKS 代理
ssh -D 1080 -p 2222 sshuser@localhost

# 使用代理
curl --socks5 localhost:1080 http://target-server-1
```

## 📊 監控除錯

### 連線狀態檢查
```powershell
# 檢查本機 Port
netstat -an | findstr :808

# 檢查容器狀態
docker-compose ps

# 檢查服務日誌
docker logs ssh-gateway
```

### SSH 除錯
```bash
# 詳細模式
ssh -v -L 8080:target-server-1:80 -p 2222 sshuser@localhost

# 容器內部檢查
docker exec -it ssh-gateway bash
docker exec -it target-server-1 bash
```

## 🧹 環境清理

```powershell
# 停止環境
docker-compose down

# 清理資源
docker system prune -f
```

---

**重點**：所有指令都基於 Client (PuTTY) → SSH Gateway → Target Server 的三層架構設計。
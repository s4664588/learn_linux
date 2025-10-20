# PuTTY SSH Tunnel 使用指南

> Windows 用戶使用 PuTTY 進行 SSH Tunnel 連線  
> 基於 hello02923 的 SSH Tunnel 文章實作  
> 參考：https://ithelp.ithome.com.tw/articles/10290848

## 🎯 核心架構

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Client    │    │SSH Gateway  │    │Target Server│
│   (PuTTY)   │◄──►│ (跳板主機)   │◄──►│ (目標主機)   │
│             │    │ Port: 2222  │    │ Port: 80,22 │
│             │    │ sshuser     │    │ Port: 3306  │
└─────────────┘    └─────────────┘    └─────────────┘
      本機              localhost:2222        內部網路
```

## 🚀 快速開始

### 1. 自動化測試（推薦）
```powershell
# 啟動互動式工具
.\putty-tunnel-test.ps1

# 選擇操作：
# 1 - 安裝 PuTTY
# 2 - 設定環境  
# 3 - 執行測試
# 4 - 清理環境
# 5 - 完整流程
```

### 2. 手動操作
```powershell
# 啟動測試環境
docker-compose up -d

# 使用 PuTTY 連線
# Host: localhost, Port: 2222
# User: sshuser, Password: password123
```

## 🔧 PuTTY 設定

### GUI 設定步驟
1. **基本連線**：
   - Host Name: `localhost`
   - Port: `2222`
   - Connection type: `SSH`

2. **SSH Tunnel 設定**（Connection → SSH → Tunnels）：
   - `8080` → `target-server-1:80` (Web 服務)
   - `8081` → `target-server-1:22` (SSH 服務)
   - `8083` → `target-server-2:3306` (資料庫)

3. **儲存 Session**：`SSH-Gateway-Tunnels`

### 命令列操作
```cmd
# 建立 SSH Tunnel
plink -ssh -L 8080:target-server-1:80 -L 8081:target-server-1:22 -L 8083:target-server-2:3306 -P 2222 sshuser@localhost

# 背景執行
plink -ssh -L 8080:target-server-1:80 -P 2222 sshuser@localhost -N
```

## 🧪 測試驗證

### 驗證 SSH Tunnel
```powershell
# 檢查 Port 狀態
netstat -an | findstr :808

# 測試 Web 服務
curl http://localhost:8080

# 測試 SSH 服務
putty -ssh -P 8081 root@localhost

# 測試資料庫
Test-NetConnection localhost -Port 8083
```

## 🛠️ 故障排除

### 常見問題
1. **PuTTY 未安裝**：使用工具選項 1 自動安裝
2. **Docker 未啟動**：啟動 Docker Desktop
3. **SSH 主機金鑰問題**：第一次連線需要接受主機金鑰
   - 看到 "Store key in cache? (y/n)" 時輸入 `y`
   - 或執行 `.\setup-ssh-keys.ps1` 自動設定
4. **連線被拒**：檢查容器狀態 `docker-compose ps`
5. **Port 被佔用**：使用 `netstat -ano | findstr :8080` 檢查

### 環境檢查
```powershell
# 使用工具選項 7 檢查環境狀態 (在 Day1 資料夾中執行)
cd Day1
.\putty-tunnel-test.ps1
# 輸入: 7
```

## 📋 實際應用

### 企業場景
- **遠端辦公**：家中電腦 → 公司跳板機 → 內部系統
- **系統管理**：管理員電腦 → 跳板機 → 內部伺服器
- **開發存取**：開發電腦 → 跳板機 → 內部資料庫

### 安全考量
- 使用金鑰認證替代密碼
- 限制 SSH 連線來源 IP
- 定期更換認證資訊
- 監控連線日誌

---

**核心重點**：透過 PuTTY 建立 SSH Tunnel，讓本機可以安全存取內部網路服務，完全符合企業級跳板主機應用需求。
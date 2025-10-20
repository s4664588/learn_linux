# SSH Tunnel 學習記錄

> 基於 hello02923 的「SSH 入門及 SSH Tunnel靈活運用」文章學習實作  
> 參考：https://ithelp.ithome.com.tw/articles/10290848  
> 學習期間：2025年10月 - 30天完整學習計畫

## 📅 Day 1: SSH Tunnel 三層架構理解與環境建立

**學習日期**: 2025-10-20  
**學習重點**: 理解 SSH Tunnel 核心概念，建立完整測試環境

### 🎯 今日學習目標

1. **理解 SSH Tunnel 三層架構**
   - Client (PuTTY) - 本機用戶端
   - SSH Gateway (跳板主機) - 中介伺服器
   - Target Server (目標主機) - 內部服務

2. **建立 Docker 測試環境**
   - 配置多容器網路環境
   - 實現網路隔離設計
   - 部署完整測試架構

3. **掌握基本操作流程**
   - 使用互動式測試工具
   - 驗證環境正確性
   - 理解核心工作原理

### 🏗️ 系統架構學習

#### 核心架構設計
```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose 環境                      │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐      │
│  │   Client    │    │SSH Gateway  │    │Target Server│      │
│  │   (PuTTY)   │◄──►│ (跳板主機)   │◄──►│ (目標主機)   │      │
│  │             │    │ Port: 2222  │    │ Port: 80,22 │      │
│  │             │    │ sshuser     │    │ Port: 3306  │      │
│  └─────────────┘    └─────────────┘    └─────────────┘      │
│        │                   │                   │            │
│        └───────────────────┼───────────────────┘            │
│                            │                                │
│  ┌─────────────────────────┼─────────────────────────────┐  │
│  │          Public Network │ (172.30.0.0/16)            │  │
│  │          本機可直接存取   │                             │  │
│  └─────────────────────────┼─────────────────────────────┘  │
│                            │                                │
│  ┌─────────────────────────┼─────────────────────────────┐  │
│  │         Internal Network│ (10.100.0.0/24)            │  │
│  │         內部隔離網路     │ (本機無法直接存取)            │  │
│  └─────────────────────────┼─────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

#### 網路隔離設計
- **Public Network** (172.30.0.0/16)：外部網路，本機可直接存取
- **Internal Network** (10.100.0.0/24)：內部隔離網路，僅能透過跳板主機存取
- **安全原則**：內部服務完全隔離，必須透過 SSH Gateway 才能存取

### 🐳 Docker 容器配置

#### SSH Gateway (跳板主機)
```yaml
服務名稱: ssh-gateway
基礎映像: Ubuntu 22.04 LTS
連接埠: 2222:22 (對外開放 SSH)
網路: public-net, internal-net (橋接內外網)
認證: sshuser / password123
功能: SSH 服務、Port Forwarding、網路橋接
```

#### Target Server 1 (Web 伺服器)
```yaml
服務名稱: target-server-1
基礎映像: Ubuntu 22.04 LTS
連接埠: 80 (Nginx), 22 (SSH)
網路: internal-net (僅內部網路)
認證: root / rootpassword
服務: Nginx Web Server
用途: 模擬內部 Web 應用系統
```

#### Target Server 2 (資料庫伺服器)
```yaml
服務名稱: target-server-2
基礎映像: Ubuntu 22.04 LTS
連接埠: 22 (SSH), 3306 (MySQL)
網路: internal-net (僅內部網路)
認證: root / rootpassword, testuser / testpass (MySQL)
服務: MySQL Database Server
用途: 模擬內部資料庫系統
```

### 🔧 SSH Tunnel 實作原理

#### Port Forwarding 機制
```bash
# 基本 SSH Tunnel 語法
ssh -L [本機Port]:[目標主機]:[目標Port] -p [跳板Port] [跳板用戶]@[跳板IP]

# 實際範例
ssh -L 8080:target-server-1:80 -p 2222 sshuser@localhost
```

#### 三種主要 Tunnel 類型
1. **Web 服務 Tunnel**
   - 本機 8080 → target-server-1:80
   - 用途：存取內部 Web 應用
   - 測試：`curl http://localhost:8080`

2. **SSH 服務 Tunnel**
   - 本機 8081 → target-server-1:22
   - 用途：SSH 連接內部伺服器
   - 測試：`ssh -p 8081 root@localhost`

3. **資料庫服務 Tunnel**
   - 本機 8083 → target-server-2:3306
   - 用途：連接內部資料庫
   - 測試：`mysql -h localhost -P 8083 -u testuser -p`

### 🛠️ 自動化工具學習

#### 互動式測試工具功能
```powershell
.\putty-tunnel-test.ps1              # 啟動互動式選單

# 主要功能選項：
# 1 - 安裝 PuTTY (自動化安裝)
# 2 - 設定測試環境 (Docker + PuTTY Session)
# 3 - 執行 SSH Tunnel 測試 (完整驗證)
# 4 - 清理測試環境 (環境清理)
# 5 - 執行完整測試流程 (一鍵完成)
# 6 - 顯示 PuTTY 手動操作說明
# 7 - 檢查環境狀態 (系統診斷)
# 0 - 退出程式
```

#### PuTTY 自動化配置
- **Session 名稱**: SSH-Gateway-Tunnels
- **連線設定**: localhost:2222, SSH
- **認證資訊**: sshuser / password123
- **Port Forwarding**: 自動配置三個主要 Tunnel

### 📋 今日實作步驟

#### 1. 環境準備
```powershell
# 檢查 Docker 環境
docker --version
docker-compose --version

# 檢查專案檔案
ls common_tool/
```

#### 2. 啟動測試環境
```powershell
# 使用互動式工具
.\putty-tunnel-test.ps1

# 選擇選項 2 - 設定測試環境
# 系統會自動：
# - 啟動 Docker Compose
# - 建立 PuTTY Session
# - 等待服務就緒
```

#### 3. 驗證環境
```powershell
# 選擇選項 7 - 檢查環境狀態
# 確認：
# - PuTTY 已安裝
# - Docker 容器運行正常
# - 網路連通性正常
# - PuTTY Session 已建立
```

#### 4. 執行基礎測試
```powershell
# 選擇選項 3 - 執行 SSH Tunnel 測試
# 驗證：
# - SSH Tunnel 建立成功
# - Port Forwarding 正常
# - 各項服務可存取
```

### 🎯 學習成果

#### 理論理解
- ✅ **SSH Tunnel 原理**：理解 Port Forwarding 工作機制
- ✅ **三層架構**：掌握 Client → Gateway → Target 設計
- ✅ **網路隔離**：理解內外網分離的安全架構
- ✅ **企業應用**：了解跳板主機在企業環境的重要性

#### 技術實作
- ✅ **Docker 環境**：成功建立多容器測試環境
- ✅ **網路配置**：實現內外網隔離設計
- ✅ **服務部署**：部署 SSH、Web、資料庫服務
- ✅ **自動化工具**：掌握互動式測試工具使用

#### 實際操作
- ✅ **PuTTY 配置**：自動建立 Session 和 Tunnel 設定
- ✅ **連線測試**：驗證所有 SSH Tunnel 功能
- ✅ **故障排除**：學會基本的問題診斷方法
- ✅ **環境管理**：掌握環境啟動、測試、清理流程

### 🔍 重要概念整理

#### SSH Tunnel 核心概念
1. **Local Port Forwarding**: 將本機 Port 轉發到遠端服務
2. **跳板主機**: 作為內外網橋接的中介伺服器
3. **網路隔離**: 內部服務完全隔離，提高安全性
4. **Port Mapping**: 本機 Port 與內部服務的對應關係

#### 企業應用場景
1. **遠端辦公**: 在家安全存取公司內部系統
2. **系統管理**: 透過跳板機維護內部伺服器
3. **開發環境**: 安全連接內部開發和測試資源
4. **資料庫存取**: 透過 SSH Tunnel 連接內部資料庫

#### 安全性考量
1. **認證機制**: SSH 金鑰認證優於密碼認證
2. **存取控制**: 限制連線來源和目標
3. **日誌監控**: 記錄所有連線活動
4. **權限管理**: 最小權限原則

### 📚 參考資料

#### 核心文章
- **原始文章**: [SSH 入門及 SSH Tunnel靈活運用](https://ithelp.ithome.com.tw/articles/10290848)
- **作者**: hello02923 (2022 iThome 鐵人賽)

#### 技術文件
- **Docker 官方文件**: https://docs.docker.com/
- **PuTTY 官方網站**: https://www.putty.org/
- **OpenSSH 文件**: https://www.openssh.com/

#### 專案檔案 (Day1 資料夾)
- **學習記錄**: SSH-Tunnel-Learn-Record.md
- **使用指南**: putty-ssh-tunnel-guide.md
- **測試指令**: ssh-test-commands.md
- **主要工具**: putty-tunnel-test.ps1
- **環境配置**: docker-compose.yml

### 🎯 明日學習預告

**Day 2: PuTTY 基礎操作與連線設定**
- 深入學習 PuTTY GUI 操作
- 掌握各種連線設定選項
- 學習 Session 管理和匯出入
- 實作不同類型的 SSH 連線

### ⚠️ 實作過程中遇到的問題與解決方案

#### 問題 1: Docker Compose 版本警告
**問題描述**:
```
level=warning msg="docker-compose.yml: the attribute version is obsolete"
```

**解決方案**:
```yaml
# 移除 docker-compose.yml 中的 version 屬性
# 從：
version: '3.8'
services:
  ...

# 改為：
services:
  ...
```

**學習重點**: 新版 Docker Compose 不再需要 version 屬性

#### 問題 2: Docker 網路衝突
**問題描述**:
```
Error response from daemon: invalid pool request: Pool overlaps with other one on this address space
```

**原因分析**: 
- 原始網路配置與主機現有網路重疊
- `172.25.0.0/16` 和 `192.168.200.0/24` 與現有網路衝突

**解決方案**:
```yaml
# 更新 docker-compose.yml 網路配置
networks:
  public-net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.30.0.0/16  # 原: 172.25.0.0/16
  internal-net:
    driver: bridge
    ipam:
      config:
        - subnet: 10.100.0.0/24  # 原: 192.168.200.0/24
```

**清理指令**:
```powershell
docker-compose down
docker network prune -f
docker rm -f $(docker ps -aq)
```

#### 問題 3: SSH 主機金鑰驗證失敗
**問題描述**:
```
Host key verification failed.
```

**原因分析**: Windows 主機第一次連接 SSH 服務器需要接受主機金鑰

**解決方案**:
```powershell
# 方法 1: 手動接受主機金鑰
echo y | plink -ssh -P 2222 sshuser@localhost -pw password123 "echo 'SSH測試'"

# 方法 2: 在腳本中自動處理
function Setup-SSHHostKey {
    $testConnection = & plink -ssh -P 2222 -pw "password123" -batch sshuser@localhost "echo 'SSH 連線測試'"
    if ($LASTEXITCODE -ne 0) {
        # 處理主機金鑰接受邏輯
    }
}
```

#### 問題 4: Port 衝突問題
**問題描述**: 
- Port 8080 被 Chrome 佔用
- Port 8083 被 Apache (httpd) 佔用

**診斷指令**:
```powershell
netstat -ano | findstr ":8080 :8081 :8083"
Get-Process -Id [PID] | Select-Object Id,ProcessName,Path
```

**解決方案**: 更換 Port 配置避免衝突
```powershell
# 原始 Port 配置
8080 → target-server-1:80  # Web 服務
8081 → target-server-1:22  # SSH 服務  
8083 → target-server-2:3306 # 資料庫服務

# 新的 Port 配置
8090 → target-server-1:80  # Web 服務
8091 → target-server-1:22  # SSH 服務
8093 → target-server-2:3306 # 資料庫服務
```

#### 問題 5: PuTTY plink 參數錯誤
**問題描述**:
```
plink: '*' is not a valid format for a manual host key specification
```

**原因分析**: `-hostkey "*"` 參數格式不正確

**解決方案**:
```powershell
# 錯誤的寫法
plink -ssh -P 2222 -pw "password123" -batch -hostkey "*" sshuser@localhost

# 正確的寫法 (移除 -hostkey 參數)
plink -ssh -P 2222 -pw "password123" -batch sshuser@localhost
```

#### 問題 6: PowerShell 執行權限
**問題描述**: PowerShell 腳本執行被阻止

**解決方案**:
```powershell
# 檢查執行原則
Get-ExecutionPolicy

# 設定執行原則 (以管理員身份執行)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 或暫時繞過
PowerShell -ExecutionPolicy Bypass -File .\putty-tunnel-test.ps1
```

### 🔧 最終成功的完整流程

#### 1. 環境檢查與準備
```powershell
# 檢查 Port 使用情況
netstat -an | findstr ":8090 :8091 :8093"

# 確認 Docker 環境
docker --version
docker-compose --version
```

#### 2. 執行完整測試
```powershell
# 進入 Day1 資料夾
cd Day1

# 使用修正後的腳本執行完整流程
.\putty-tunnel-test.ps1 -All

# 或使用互動式選單
.\putty-tunnel-test.ps1
# 選擇選項 5 - 執行完整測試流程
```

#### 3. 驗證測試結果
```powershell
# Web 服務測試
curl http://localhost:8090

# SSH 服務測試
plink -ssh -P 8091 -pw "rootpassword" -batch root@localhost "echo 'SSH Tunnel 成功'"

# 資料庫服務測試
Test-NetConnection localhost -Port 8093
```

### 📊 最終測試結果

✅ **所有測試項目通過**:
- 🔧 環境設定: PuTTY 檢查、Docker 啟動、SSH 金鑰設定
- 🔗 SSH Tunnel 建立: 基本連線測試、多重 Port Forwarding
- 🔌 Port 轉發驗證: 8090 (Web)、8091 (SSH)、8093 (DB)
- 🧪 服務功能測試: Web 服務、SSH 服務、資料庫服務
- 🧹 環境清理: 程序清理、Docker 環境停止

### 💡 學習心得

今天成功建立了完整的 SSH Tunnel 測試環境，深入理解了三層架構的設計原理。透過 Docker 容器化技術，我們模擬了真實的企業網路環境，實現了內外網隔離的安全架構。

最重要的收穫是理解了 SSH Tunnel 的核心價值：**透過安全的 SSH 連線，讓我們可以安全地存取內部網路服務，而不需要直接暴露這些服務到外部網路**。這在企業環境中具有重要的安全意義。

**實作過程中的重要學習**:
1. **問題診斷能力**: 學會如何系統性地分析和解決技術問題
2. **環境配置技巧**: 掌握 Docker 網路配置和 Port 衝突解決
3. **自動化思維**: 透過腳本自動化複雜的配置和測試流程
4. **安全意識**: 理解 SSH 主機金鑰驗證的重要性

互動式測試工具大大簡化了操作流程，讓複雜的環境配置變得簡單易用。透過今天的實作，不僅掌握了技術操作，更重要的是培養了解決問題的系統性思維。

---

**學習狀態**: ✅ 完成  
**總學習時間**: 4 小時

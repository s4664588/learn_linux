# Day 1: SSH Tunnel 三層架構實作

> 基於 hello02923 的「SSH 入門及 SSH Tunnel靈活運用」文章實作  
> 參考：https://ithelp.ithome.com.tw/articles/10290848  
> **學習重點**: SSH Tunnel 三層架構理解與環境建立

## 🎯 核心架構

```
Windows (PuTTY) → SSH Gateway (跳板主機) → Target Server (目標主機)
     本機              localhost:2222         內部網路服務
```

## 🎯 Day 1 學習目標

### 📋 今日重點
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

### 🏗️ 系統架構
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

## 🚀 快速開始

```powershell
# 1. 進入 Day1 資料夾
cd Day1

# 2. 啟動互動式工具
.\putty-tunnel-test.ps1

# 3. 選擇操作
# 1 - 安裝 PuTTY
# 2 - 設定環境
# 3 - 執行測試
# 5 - 完整流程 (推薦)
# 6 - 建立持續 SSH Tunnel (手動測試)
```

## 📋 Day 1 檔案結構

### 🔧 核心工具
- **`putty-tunnel-test.ps1`** - 主要測試工具（互動式選單）
- **`setup-ssh-keys.ps1`** - SSH 金鑰設定工具

### 📚 學習文件
- **`SSH-Tunnel-Learn-Record.md`** - Day 1 完整學習記錄
- **`README.md`** - Day 1 快速開始指南
- **`putty-ssh-tunnel-guide.md`** - PuTTY 詳細使用指南
- **`ssh-test-commands.md`** - 測試指令參考

### 🐳 環境配置
- **`docker-compose.yml`** - 容器環境配置
- **`Dockerfile.ssh-server`** - SSH Gateway 映像
- **`Dockerfile.target-server`** - Target Server 映像
- **`ssh-setup.sh`** - SSH 服務設定腳本
- **`ssh-keys/`** - SSH 金鑰存放目錄

## 🔧 SSH Tunnel 設定

### PuTTY 設定 (已修正 Port 衝突)
- Host: `localhost:2222`
- User: `sshuser` / Password: `password123`
- Tunnels:
  - `8090` → `target-server-1:80` (Web)
  - `8091` → `target-server-1:22` (SSH)
  - `8093` → `target-server-2:3306` (DB)

### 測試驗證
```powershell
curl http://localhost:8090              # Web 服務
putty -ssh -P 8091 root@localhost       # SSH 服務
Test-NetConnection localhost -Port 8093 # 資料庫
```

### 🔗 新功能：持續 SSH Tunnel 連線 (選項 6)

**功能說明**：
- 建立持續運行的 SSH Tunnel 連線
- 保持前景執行，方便手動測試
- 可隨時按 Ctrl+C 中斷連線

**使用方法**：
1. 執行 `.\putty-tunnel-test.ps1`
2. 選擇選項 `6`
3. SSH Tunnel 建立後，在瀏覽器訪問 `http://localhost:8090`
4. 按 Ctrl+C 停止連線

**適用場景**：
- 需要長時間測試 Web 服務
- 手動驗證 SSH Tunnel 功能
- 除錯和故障排除

## 🎯 應用場景

- 遠端辦公：安全存取公司內部系統
- 系統管理：透過跳板機維護伺服器
- 開發環境：連接內部開發資源

---

**一鍵開始**：`cd Day1` → `.\putty-tunnel-test.ps1` → 選擇 `5`

### 📁 檔案組織說明
- 所有 Day 1 相關檔案已移動到 `Day1/` 資料夾
- 執行任何腳本前請先 `cd Day1`
- 學習記錄包含完整的問題解決過程

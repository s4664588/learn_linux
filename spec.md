# Linux 學習環境專案規格文件
## 學習目標
- linux 系統環境相關語法學習
- shell script 學習 並建立自己的shell tools
  - 入門 https://tldp.org/LDP/abs/html/ 資訊過舊 已語法學習為主
  - 參考 google shell style https://google.github.io/styleguide/shellguide.html
  - 結合 ShellCheck 檢查網站
  - 確定安全性更高的寫法
- SSH 連線和 SSH Tunnel 技術學習
  - SSH 基本連線和金鑰管理
  - SSH Tunnel (Port Forwarding) 實作
  - 多主機網路環境模擬
  - 跳板主機 (Jump Host) 應用
## 專案概述

這是一個專為學習 Linux 系統而設計的 Docker 容器化環境，提供完整的 Linux 學習平台，包含常用工具、練習檔案和腳本，讓使用者可以在安全的容器環境中練習 Linux 命令和系統管理。此專案現已擴展支援 SSH 連線技術學習，包含多主機網路環境模擬，讓學習者可以實際體驗 SSH Tunnel 和跳板主機的應用場景。

## 專案目標

- 提供標準化的 Linux 學習環境
- 整合常用 Linux 工具和開發環境
- 建立結構化的練習內容和範例
- 支援容器化部署，確保環境一致性
- 提供完整的學習路徑和參考文件
- 建立多主機 SSH 測試環境
- 模擬真實網路架構和安全連線場景

## 技術棧

### 基礎技術
- **容器化技術**: Docker
- **基礎映像**: Ubuntu 22.04 LTS
- **Shell 環境**: Bash
- **包管理器**: apt (Debian/Ubuntu)

### 核心工具
- **文字編輯器**: vim, nano
- **版本控制**: git
- **網路工具**: curl, wget, net-tools, ping, netcat
- **檔案工具**: zip, unzip, tar, tree
- **系統監控**: htop, procps, lsof
- **開發工具**: gcc, make
- **文字處理**: grep, sed, gawk
- **SSH 工具**: openssh-server, openssh-client
- **Web 服務**: nginx
- **資料庫**: mysql-server

### 安全性考量
- 非 root 使用者環境 (linuxuser)
- sudo 權限管理
- 容器隔離機制
- 最小權限原則
- SSH 金鑰認證機制
- 網路隔離和存取控制
- 跳板主機安全配置

## 系統架構

### 容器架構

#### 單機學習環境
```
┌─────────────────────────────────────┐
│           Docker Container          │
│  ┌─────────────────────────────────┐ │
│  │        Ubuntu 22.04 LTS        │ │
│  │  ┌─────────────────────────────┐ │ │
│  │  │      linuxuser 環境         │ │ │
│  │  │  ┌─────────────────────────┐ │ │ │
│  │  │  │   練習目錄結構          │ │ │ │
│  │  │  │  ├── files/            │ │ │ │
│  │  │  │  ├── scripts/          │ │ │ │
│  │  │  │  └── projects/         │ │ │ │
│  │  │  └─────────────────────────┘ │ │ │
│  │  └─────────────────────────────┘ │ │
│  └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

#### SSH 多主機測試環境
```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose 環境                      │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐      │
│  │   Client    │    │SSH Gateway  │    │Target Server│      │
│  │ (學習環境)   │    │ (跳板主機)   │    │ (目標主機)   │      │
│  │             │    │             │    │             │      │
│  │ Port: -     │◄──►│ Port: 2222  │◄──►│ Port: 22    │      │
│  │             │    │             │    │ Port: 80    │      │
│  │             │    │             │    │ Port: 3306  │      │
│  └─────────────┘    └─────────────┘    └─────────────┘      │
│        │                   │                   │            │
│        └───────────────────┼───────────────────┘            │
│                            │                                │
│  ┌─────────────────────────┼─────────────────────────────┐  │
│  │          Public Network │ (172.20.0.0/16)            │  │
│  └─────────────────────────┼─────────────────────────────┘  │
│                            │                                │
│  ┌─────────────────────────┼─────────────────────────────┐  │
│  │         Internal Network│ (192.168.100.0/24)         │  │
│  │                         │ (隔離網路，僅內部存取)        │  │
│  └─────────────────────────┼─────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 目錄結構

#### 基礎學習環境
```
/home/linuxuser/
├── practice/
│   ├── files/           # 練習用檔案
│   │   ├── welcome.txt  # 歡迎訊息
│   │   └── test.txt     # 測試檔案
│   ├── scripts/         # 練習腳本
│   │   └── hello.sh     # 範例腳本
│   └── projects/        # 專案目錄
└── learn_record.md      # 學習記錄
```

#### SSH 測試環境檔案結構
```
專案根目錄/
├── Dockerfile                    # 基礎學習環境
├── Dockerfile.ssh-server         # SSH 跳板主機
├── Dockerfile.target-server      # 目標伺服器
├── docker-compose.yml           # 多容器編排
├── ssh-setup.sh                 # SSH 環境設定腳本
├── ssh-test-commands.md         # SSH 測試指令文件
├── ssh-keys/                    # SSH 金鑰目錄
│   ├── id_rsa                   # 私鑰
│   ├── id_rsa.pub              # 公鑰
│   ├── authorized_keys         # 授權金鑰
│   └── config                  # SSH 配置檔案
├── spec.md                     # 專案規格文件
├── learn_record.md             # 學習記錄
└── README.md                   # 專案說明
```

## API 規格

### Docker 映像 API

#### 映像名稱
- **名稱**: linux-practice
- **標籤**: latest
- **基礎映像**: ubuntu:22.04

#### 環境變數
| 變數名稱 | 值 | 說明 |
|---------|---|------|
| DEBIAN_FRONTEND | noninteractive | 避免互動式安裝提示 |

#### 使用者設定
| 項目 | 值 | 說明 |
|------|---|------|
| 使用者名稱 | linuxuser | 練習環境使用者 |
| 密碼 | password | 使用者密碼 |
| Shell | /bin/bash | 預設 shell |
| 權限 | sudo | 管理員權限 |

### 容器運行 API

#### 建立映像
```bash
docker build -t linux-practice .
```

#### 運行容器
```bash
# 單機學習環境
docker run -it linux-practice

# SSH 多主機測試環境
docker-compose up -d
```

#### 退出容器
```bash
# 單機環境
exit

# 多主機環境
docker-compose down
```

## 功能模組

### 1. 基礎命令練習模組
- **檔案操作**: ls, cd, pwd, mkdir, rmdir, cp, mv, rm
- **文字處理**: cat, head, tail, tac, less, touch
- **搜尋功能**: grep, find
- **權限管理**: chmod, chown, sudo

### 2. 系統管理模組
- **程序管理**: ps, htop, kill
- **檔案系統**: df, du, mount
- **網路管理**: netstat, ping, ifconfig
- **使用者管理**: useradd, usermod, passwd

### 3. 開發工具模組
- **編譯工具**: gcc, make
- **版本控制**: git
- **文字編輯**: vim, nano
- **腳本開發**: bash, sed, awk

### 4. 網路工具模組
- **下載工具**: curl, wget
- **連線測試**: ping, netcat
- **網路設定**: net-tools
- **除錯工具**: lsof

### 5. SSH 連線模組
- **SSH 基礎**: 金鑰生成、連線設定
- **SSH Tunnel**: Port Forwarding、動態代理
- **跳板主機**: 多層連線、安全存取
- **網路模擬**: 內外網隔離、服務模擬

## 學習路徑

### 初級階段
1. 基本檔案和目錄操作
2. 文字編輯器使用 (vim/nano)
3. 檔案搜尋和過濾
4. 基本權限管理

### 中級階段
1. 系統監控和程序管理
2. 網路工具使用
3. 腳本編寫基礎
4. 開發環境設定

### 高級階段
1. 系統管理進階
2. 自動化腳本開發
3. 效能調優
4. 安全性管理

### SSH 專項階段
1. SSH 基礎連線和金鑰管理
2. SSH Tunnel 和 Port Forwarding
3. 跳板主機配置和安全實務
4. 多主機網路環境管理

## 安全性規範

### 容器安全
- 使用非 root 使用者
- 最小化安裝原則
- 定期更新基礎映像
- 限制容器權限

### 使用者安全
- 強制密碼認證
- sudo 權限控制
- 檔案權限管理
- 網路存取限制

### 編碼安全
- 統一使用 UTF-8 編碼避免字符注入
- Web 服務設定正確的 Content-Type 標頭
- 防止編碼相關的 XSS 攻擊
- 確保多語言環境的字符安全處理

## 部署指南

### 開發環境
1. 安裝 Docker
2. 克隆專案程式碼
3. 建立 Docker 映像
4. 運行容器

### 生產環境
1. 使用 Docker Registry
2. 設定映像標籤
3. 配置容器編排
4. 監控和日誌

## 維護指南

### 定期維護
- 更新基礎映像
- 檢查安全漏洞
- 更新工具版本
- 備份重要資料

### 故障排除
- 容器啟動問題
- 權限問題
- 網路連線問題
- 工具安裝問題

## 版本歷史

### v1.1.0 (當前版本)
- **修復 8090 port 中文亂碼問題**
  - 新增 HTML UTF-8 編碼聲明 (`<meta charset="UTF-8">`)
  - 設定 Nginx 字符編碼配置 (`charset utf-8`)
  - 新增系統 locale 支援 (`LANG=C.UTF-8`)
  - 改善 Web 介面中文字體顯示 (`Microsoft JhengHei`)
  - 優化 HTML 頁面樣式和使用者體驗
- SSH Tunnel 測試環境穩定運行
- 多主機網路環境正常運作

### v1.0.0
- 初始版本發布
- 基礎 Linux 學習環境
- 常用工具整合
- 練習檔案和腳本

## 未來規劃

### 短期目標
- 增加更多練習範例
- 改善使用者介面
- 新增互動式教學
- 擴展工具集

### 長期目標
- 支援多種 Linux 發行版
- 整合雲端部署
- 建立學習社群
- 開發進階課程

## 參考資料

- [Docker 官方文件](https://docs.docker.com/)
- [Ubuntu 官方文件](https://ubuntu.com/tutorials)
- [Linux 命令參考](https://www.gnu.org/software/bash/manual/)
- [Vim 使用指南](https://vimhelp.org/)

---

**最後更新**: 2024年12月
**維護者**: 專案開發團隊
**授權**: MIT License 
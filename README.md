# Linux 練習環境 Docker 容器

這是一個專為學習 Linux 而設計的 Docker 環境。

## 功能特色

- 基於 Ubuntu 22.04
- 預裝常用 Linux 工具
- 包含練習用的檔案和腳本
- 非 root 使用者環境（linuxuser）
- 完整的開發工具鏈

## 安裝的工具

### 基本工具
- `curl`, `wget` - 網路下載工具
- `git` - 版本控制系統
- `vim`, `nano` - 文字編輯器
- `tree` - 目錄結構顯示
- `htop` - 系統監控工具

### 網路工具
- `net-tools` - 網路設定工具
- `ping` - 網路連線測試
- `netcat` - 網路除錯工具

### 檔案工具
- `zip`, `unzip` - 壓縮工具
- `tar` - 歸檔工具

### 系統工具
- `procps` - 包含 ps, top 等系統監控命令
- `lsof` - 列出開啟檔案的程序

### 開發工具
- `gcc` - C 編譯器
- `make` - 建置工具

### 文字處理工具
- `grep` - 文字搜尋工具
- `sed` - 串流編輯器
- `gawk` - AWK 程式語言實現

## 使用方法

### 1. 建立 Docker 映像
```bash
docker build -t linux-practice .
```

### 2. 運行容器
```bash
docker run -it linux-practice
```
#PS -it 才能保持交互 -d 會自動連上去即關閉容易因為沒交互

### 3. 進入練習環境
容器啟動後，您將以 `linuxuser` 身份登入，密碼為 `password`。

### 4. 探索練習檔案
```bash
# 查看目錄結構
tree practice/

# 查看歡迎檔案
cat practice/files/welcome.txt

# 執行測試腳本
./practice/scripts/hello.sh
```

## 建議的練習項目

1. **檔案和目錄操作**
   - 使用 `ls`, `cd`, `pwd` 瀏覽目錄
   - 使用 `mkdir`, `rmdir` 建立和刪除目錄
   - 使用 `cp`, `mv`, `rm` 複製、移動和刪除檔案

2. **文字處理**
   - 使用 `cat`, `less`, `head`, `tail` 查看檔案
   - 使用 `grep`, `sed`, `awk` 處理文字

3. **系統監控**
   - 使用 `ps`, `htop` 查看程序
   - 使用 `df`, `du` 查看磁碟使用情況

4. **網路工具**
   - 使用 `ping` 測試網路連線
   - 使用 `netstat` 查看網路連線

5. **權限管理**
   - 使用 `chmod`, `chown` 管理檔案權限
   - 使用 `sudo` 執行管理員命令

## 常用命令快速參考

| 命令 | 功能 |
|------|------|
| `ls -la` | 詳細列出檔案 |
| `pwd` | 顯示目前目錄 |
| `cd ~` | 回到家目錄 |
| `man <command>` | 查看命令手冊 |
| `history` | 查看命令歷史 |

## 退出容器
```bash
exit
```

## 注意事項
- 容器停止後，所有變更都會遺失（除非使用 volume 掛載）
- 如需保存練習成果，建議使用 Docker volume 或 bind mount
- 使用 `sudo` 時密碼為 `password` 
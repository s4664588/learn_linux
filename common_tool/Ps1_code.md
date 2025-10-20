# PowerShell (PS1) 與 Linux 語法對照指南

> 基於 SSH Tunnel 專案中的實際應用整理  
> 涵蓋系統管理、網路工具、程序控制等常用語法

## 📋 目錄
- [基本語法結構](#基本語法結構)
- [變數與參數](#變數與參數)
- [函數定義](#函數定義)
- [條件判斷](#條件判斷)
- [迴圈控制](#迴圈控制)
- [檔案與目錄操作](#檔案與目錄操作)
- [程序管理](#程序管理)
- [網路工具](#網路工具)
- [字串處理](#字串處理)
- [陣列操作](#陣列操作)
- [錯誤處理](#錯誤處理)
- [系統資訊](#系統資訊)
- [安全性考量](#安全性考量)

---

## 🔧 基本語法結構

### 腳本開頭和編碼設定

| PowerShell | Linux Bash | 說明 |
|------------|------------|------|
| `# PowerShell 註解` | `# Bash 註解` | 單行註解 |
| `<# 多行註解 #>` | `: '多行註解'` | 多行註解 |
| `$OutputEncoding = [System.Text.Encoding]::UTF8` | `export LANG=C.UTF-8` | UTF-8 編碼設定 |
| `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` | `export LC_ALL=C.UTF-8` | 控制台編碼 |

### 腳本參數定義

**PowerShell:**
```powershell
param(
    [switch]$Setup,
    [switch]$Test,
    [string]$ConfigFile = "default.conf",
    [int]$Port = 8080
)
```

**Linux Bash:**
```bash
#!/bin/bash
# 使用 getopts 處理參數
while getopts "stc:p:" opt; do
    case $opt in
        s) SETUP=true ;;
        t) TEST=true ;;
        c) CONFIG_FILE="$OPTARG" ;;
        p) PORT="$OPTARG" ;;
    esac
done

# 或使用位置參數
SETUP=${1:-false}
TEST=${2:-false}
CONFIG_FILE=${3:-"default.conf"}
PORT=${4:-8080}
```

---

## 📦 變數與參數

### 變數宣告與賦值

| PowerShell | Linux Bash | 說明 |
|------------|------------|------|
| `$variable = "value"` | `variable="value"` | 字串變數 |
| `$number = 42` | `number=42` | 數字變數 |
| `$array = @("a", "b", "c")` | `array=("a" "b" "c")` | 陣列變數 |
| `$hash = @{key="value"}` | `declare -A hash; hash[key]="value"` | 關聯陣列 |

### 環境變數

| PowerShell | Linux Bash | 說明 |
|------------|------------|------|
| `$env:PATH` | `$PATH` | 系統路徑 |
| `$env:USERNAME` | `$USER` | 使用者名稱 |
| `$env:COMPUTERNAME` | `$HOSTNAME` | 主機名稱 |
| `$env:TEMP` | `$TMPDIR` 或 `/tmp` | 暫存目錄 |

### 特殊變數

| PowerShell | Linux Bash | 說明 |
|------------|------------|------|
| `$LASTEXITCODE` | `$?` | 上一個命令的退出碼 |
| `$PSScriptRoot` | `$(dirname "$0")` | 腳本所在目錄 |
| `$args` | `$@` | 所有參數 |
| `$args.Count` | `$#` | 參數數量 |

---

## 🔨 函數定義

### 基本函數語法

**PowerShell:**
```powershell
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# 呼叫函數
Write-ColorOutput "Hello World" "Green"
```

**Linux Bash:**
```bash
write_color_output() {
    local message="$1"
    local color="${2:-white}"
    
    case $color in
        "red") echo -e "\033[31m$message\033[0m" ;;
        "green") echo -e "\033[32m$message\033[0m" ;;
        "yellow") echo -e "\033[33m$message\033[0m" ;;
        *) echo "$message" ;;
    esac
}

# 呼叫函數
write_color_output "Hello World" "green"
```

### 函數返回值

| PowerShell | Linux Bash | 說明 |
|------------|------------|------|
| `return $true` | `return 0` | 成功返回 |
| `return $false` | `return 1` | 失敗返回 |
| `$result = Function-Name` | `result=$(function_name)` | 捕獲返回值 |

---

## 🔀 條件判斷

### 基本條件語法

**PowerShell:**
```powershell
if ($condition) {
    # 執行程式碼
} elseif ($another_condition) {
    # 另一個條件
} else {
    # 預設情況
}

# 檔案存在檢查
if (Test-Path $filePath) {
    Write-Host "檔案存在"
}

# 命令存在檢查
if (Get-Command "docker" -ErrorAction SilentlyContinue) {
    Write-Host "Docker 已安裝"
}
```

**Linux Bash:**
```bash
if [ condition ]; then
    # 執行程式碼
elif [ another_condition ]; then
    # 另一個條件
else
    # 預設情況
fi

# 檔案存在檢查
if [ -f "$file_path" ]; then
    echo "檔案存在"
fi

# 命令存在檢查
if command -v docker >/dev/null 2>&1; then
    echo "Docker 已安裝"
fi
```

### 常用條件運算子

| PowerShell | Linux Bash | 說明 |
|------------|------------|------|
| `-eq` | `-eq` | 等於 |
| `-ne` | `-ne` | 不等於 |
| `-gt` | `-gt` | 大於 |
| `-lt` | `-lt` | 小於 |
| `-and` | `&&` 或 `-a` | 邏輯 AND |
| `-or` | `\|\|` 或 `-o` | 邏輯 OR |
| `-not` | `!` | 邏輯 NOT |
| `Test-Path` | `-f`, `-d`, `-e` | 檔案/目錄存在 |

---

## 🔄 迴圈控制

### foreach 迴圈

**PowerShell:**
```powershell
$commands = @("putty", "plink", "puttygen")
foreach ($cmd in $commands) {
    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        Write-Host "找到 $cmd"
    }
}
```

**Linux Bash:**
```bash
commands=("putty" "plink" "puttygen")
for cmd in "${commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "找到 $cmd"
    fi
done
```

### while 迴圈

**PowerShell:**
```powershell
do {
    Show-Menu
    $choice = Read-Host "請選擇"
} while ($choice -ne "0")
```

**Linux Bash:**
```bash
while true; do
    show_menu
    read -p "請選擇: " choice
    [ "$choice" = "0" ] && break
done
```

---

## 📁 檔案與目錄操作

### 基本檔案操作

| PowerShell | Linux Bash | 說明 |
|------------|------------|------|
| `Test-Path $path` | `[ -e "$path" ]` | 檢查路徑存在 |
| `New-Item -ItemType Directory` | `mkdir -p` | 建立目錄 |
| `Remove-Item -Recurse` | `rm -rf` | 刪除目錄 |
| `Copy-Item` | `cp` | 複製檔案 |
| `Move-Item` | `mv` | 移動檔案 |
| `Get-ChildItem` | `ls` | 列出檔案 |

### 檔案權限設定

**PowerShell:**
```powershell
# 設定檔案權限 (Windows ACL)
$acl = Get-Acl $filePath
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users","Read","Allow")
$acl.SetAccessRule($accessRule)
Set-Acl $filePath $acl
```

**Linux Bash:**
```bash
# 設定檔案權限
chmod 600 "$file_path"    # 僅擁有者可讀寫
chmod 644 "$file_path"    # 擁有者讀寫，其他人唯讀
chmod 755 "$file_path"    # 擁有者全權，其他人讀取執行
```

---

## ⚙️ 程序管理

### 程序查詢與控制

| PowerShell | Linux Bash | 說明 |
|------------|------------|------|
| `Get-Process -Name "plink"` | `ps aux \| grep plink` | 查詢程序 |
| `Stop-Process -Name "plink" -Force` | `pkill plink` | 停止程序 |
| `Start-Process` | `nohup command &` | 背景執行 |
| `Wait-Process` | `wait $PID` | 等待程序結束 |

### 實際範例

**PowerShell:**
```powershell
# 停止所有 plink 程序
Get-Process -Name "plink" -ErrorAction SilentlyContinue | Stop-Process -Force

# 啟動背景程序
$process = Start-Process -FilePath "plink" -ArgumentList @("-ssh", "-L", "8080:target:80") -PassThru
```

**Linux Bash:**
```bash
# 停止所有 plink 程序
pkill plink 2>/dev/null || true

# 啟動背景程序
plink -ssh -L 8080:target:80 &
PLINK_PID=$!
```

---

## 🌐 網路工具

### 網路連線測試

| PowerShell | Linux Bash | 說明 |
|------------|------------|------|
| `Test-NetConnection -Port 8080` | `nc -z localhost 8080` | 測試 Port 連線 |
| `Invoke-WebRequest` | `curl` | HTTP 請求 |
| `Resolve-DnsName` | `nslookup` 或 `dig` | DNS 查詢 |

### 實際範例

**PowerShell:**
```powershell
# 測試多個 Port
$testPorts = @(8090, 8091, 8093)
foreach ($port in $testPorts) {
    $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue
    if ($connection.TcpTestSucceeded) {
        Write-Host "✅ Port $port 連線正常" -ForegroundColor Green
    }
}

# HTTP 請求測試
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8090" -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Web 服務正常" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Web 服務異常: $($_.Exception.Message)" -ForegroundColor Red
}
```

**Linux Bash:**
```bash
# 測試多個 Port
test_ports=(8090 8091 8093)
for port in "${test_ports[@]}"; do
    if nc -z localhost "$port" 2>/dev/null; then
        echo "✅ Port $port 連線正常"
    else
        echo "❌ Port $port 連線失敗"
    fi
done

# HTTP 請求測試
if response=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8090" --max-time 10); then
    if [ "$response" = "200" ]; then
        echo "✅ Web 服務正常"
    else
        echo "❌ Web 服務異常: HTTP $response"
    fi
else
    echo "❌ Web 服務連線失敗"
fi
```

---

## 📝 字串處理

### 字串操作

| PowerShell | Linux Bash | 說明 |
|------------|------------|------|
| `$string.Length` | `${#string}` | 字串長度 |
| `$string.ToUpper()` | `${string^^}` | 轉大寫 |
| `$string.ToLower()` | `${string,,}` | 轉小寫 |
| `$string -replace "old","new"` | `${string/old/new}` | 字串替換 |
| `$string.Split(",")` | `IFS=',' read -ra array <<< "$string"` | 字串分割 |

### 字串格式化

**PowerShell:**
```powershell
# 字串插值
$name = "SSH Tunnel"
$message = "正在測試 $name 功能"

# 格式化字串
$formatted = "Port: {0}, Status: {1}" -f $port, $status

# Here-String (多行字串)
$config = @"
Host gateway
    HostName localhost
    Port 2222
"@
```

**Linux Bash:**
```bash
# 字串插值
name="SSH Tunnel"
message="正在測試 $name 功能"

# 格式化字串
formatted=$(printf "Port: %d, Status: %s" "$port" "$status")

# Here-Document (多行字串)
config=$(cat << 'EOF'
Host gateway
    HostName localhost
    Port 2222
EOF
)
```

---

## 📊 陣列操作

### 陣列基本操作

**PowerShell:**
```powershell
# 陣列宣告
$array = @("item1", "item2", "item3")
$array = 1..10  # 數字範圍

# 陣列操作
$array.Count           # 陣列長度
$array[0]             # 第一個元素
$array[-1]            # 最後一個元素
$array += "new_item"  # 新增元素

# 陣列遍歷
foreach ($item in $array) {
    Write-Host $item
}
```

**Linux Bash:**
```bash
# 陣列宣告
array=("item1" "item2" "item3")
array=($(seq 1 10))  # 數字範圍

# 陣列操作
${#array[@]}          # 陣列長度
${array[0]}           # 第一個元素
${array[-1]}          # 最後一個元素 (Bash 4.3+)
array+=("new_item")   # 新增元素

# 陣列遍歷
for item in "${array[@]}"; do
    echo "$item"
done
```

---

## ⚠️ 錯誤處理

### 異常處理語法

**PowerShell:**
```powershell
try {
    # 可能出錯的程式碼
    $result = Invoke-WebRequest -Uri $url -TimeoutSec 10
    Write-Host "請求成功"
} catch {
    # 錯誤處理
    Write-Host "請求失敗: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # 清理程式碼
    Write-Host "清理資源"
}

# 錯誤動作參數
Get-Command "nonexistent" -ErrorAction SilentlyContinue
```

**Linux Bash:**
```bash
# 使用 set -e 自動退出
set -e  # 任何命令失敗時退出

# 手動錯誤處理
if ! curl -s "$url" -o /dev/null --max-time 10; then
    echo "請求失敗" >&2
    exit 1
else
    echo "請求成功"
fi

# 使用 trap 處理清理
cleanup() {
    echo "清理資源"
    # 清理程式碼
}
trap cleanup EXIT

# 忽略錯誤
command_that_might_fail 2>/dev/null || true
```

---

## 🖥️ 系統資訊

### 系統資訊查詢

| PowerShell | Linux Bash | 說明 |
|------------|------------|------|
| `$env:COMPUTERNAME` | `hostname` | 主機名稱 |
| `Get-ComputerInfo` | `uname -a` | 系統資訊 |
| `Get-Location` | `pwd` | 目前目錄 |
| `Get-Date` | `date` | 目前時間 |
| `$PSVersionTable` | `$BASH_VERSION` | Shell 版本 |

### 實際範例

**PowerShell:**
```powershell
# 顯示系統資訊
Write-Host "主機名稱: $env:COMPUTERNAME"
Write-Host "使用者: $env:USERNAME"
Write-Host "作業系統: $((Get-ComputerInfo).WindowsProductName)"
Write-Host "PowerShell 版本: $($PSVersionTable.PSVersion)"
```

**Linux Bash:**
```bash
# 顯示系統資訊
echo "主機名稱: $(hostname)"
echo "使用者: $USER"
echo "作業系統: $(uname -s) $(uname -r)"
echo "Bash 版本: $BASH_VERSION"
```

---

## 🔒 安全性考量

### 輸入驗證與清理

**PowerShell:**
```powershell
# 參數驗證
param(
    [ValidateRange(1, 65535)]
    [int]$Port,
    
    [ValidatePattern('^[a-zA-Z0-9\-\.]+$')]
    [string]$HostName
)

# 路徑安全檢查
function Test-SafePath {
    param([string]$Path)
    
    # 檢查路徑遍歷攻擊
    if ($Path -match '\.\.' -or $Path -match '[<>:"|?*]') {
        throw "不安全的路徑: $Path"
    }
    
    return $true
}
```

**Linux Bash:**
```bash
# 輸入驗證函數
validate_port() {
    local port="$1"
    if [[ ! "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo "無效的 Port: $port" >&2
        return 1
    fi
}

validate_hostname() {
    local hostname="$1"
    if [[ ! "$hostname" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        echo "無效的主機名稱: $hostname" >&2
        return 1
    fi
}

# 路徑安全檢查
test_safe_path() {
    local path="$1"
    
    # 檢查路徑遍歷攻擊
    if [[ "$path" == *".."* ]] || [[ "$path" == *"~"* ]]; then
        echo "不安全的路徑: $path" >&2
        return 1
    fi
}
```

### 敏感資訊處理

**PowerShell:**
```powershell
# 使用 SecureString 處理密碼
$securePassword = Read-Host "輸入密碼" -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential("username", $securePassword)

# 避免在日誌中顯示敏感資訊
Write-Host "連線到主機: $hostname (密碼已隱藏)"
```

**Linux Bash:**
```bash
# 安全讀取密碼
read -s -p "輸入密碼: " password
echo  # 換行

# 避免密碼出現在程序列表中
export SSH_ASKPASS_PASSWORD="$password"
unset password  # 清除變數

# 使用 SSH 金鑰而非密碼
ssh -i "$private_key" -o PasswordAuthentication=no user@host
```

---

## 📚 實際應用範例

### SSH Tunnel 自動化腳本對照

**PowerShell 版本 (putty-tunnel-test.ps1):**
```powershell
function Test-PuTTYTunnels {
    Write-ColorOutput "`n🧪 測試 PuTTY SSH Tunnel" "Cyan"
    
    # 建立 SSH Tunnel
    $tunnelArgs = @(
        "-ssh",
        "-L", "8090:target-server-1:80",
        "-L", "8091:target-server-1:22", 
        "-L", "8093:target-server-2:3306",
        "-P", "2222",
        "-pw", "password123",
        "-batch",
        "sshuser@localhost",
        "-N"
    )
    
    try {
        $tunnelProcess = Start-Process -FilePath "plink" -ArgumentList $tunnelArgs -PassThru
        Start-Sleep -Seconds 3
        
        # 測試 Port Forwarding
        $testPorts = @(8090, 8091, 8093)
        foreach ($port in $testPorts) {
            $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue
            if ($connection.TcpTestSucceeded) {
                Write-ColorOutput "✅ Port $port 轉發正常" "Green"
            }
        }
        
    } catch {
        Write-ColorOutput "❌ SSH Tunnel 建立失敗: $($_.Exception.Message)" "Red"
    }
}
```

**Linux Bash 版本 (ssh-tunnel-test.sh):**
```bash
test_ssh_tunnels() {
    echo "🧪 測試 SSH Tunnel"
    
    # 建立 SSH Tunnel
    ssh -f -N \
        -L 8090:target-server-1:80 \
        -L 8091:target-server-1:22 \
        -L 8093:target-server-2:3306 \
        -p 2222 \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        sshuser@localhost
    
    sleep 3
    
    # 測試 Port Forwarding
    test_ports=(8090 8091 8093)
    for port in "${test_ports[@]}"; do
        if nc -z localhost "$port" 2>/dev/null; then
            echo "✅ Port $port 轉發正常"
        else
            echo "❌ Port $port 轉發失敗"
        fi
    done
}
```

---

## 🎯 最佳實務建議

### 1. **跨平台相容性**
- 使用相對路徑而非絕對路徑
- 避免平台特定的命令
- 統一錯誤處理方式

### 2. **安全性原則**
- 永遠驗證使用者輸入
- 使用參數化查詢避免注入攻擊
- 敏感資訊不要硬編碼在腳本中
- 使用最小權限原則

### 3. **程式碼品質**
- 函數保持單一職責
- 使用有意義的變數名稱
- 適當的錯誤處理和日誌記錄
- 程式碼註解要清楚明確

### 4. **效能考量**
- 避免不必要的迴圈
- 使用管道 (Pipeline) 處理大量資料
- 適當使用背景程序

---

## 📖 參考資源

- [PowerShell 官方文件](https://docs.microsoft.com/powershell/)
- [Bash 參考手冊](https://www.gnu.org/software/bash/manual/)
- [ShellCheck - Bash 語法檢查工具](https://www.shellcheck.net/)
- [PowerShell 最佳實務](https://docs.microsoft.com/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations)

---

**最後更新**: 2024年12月  
**基於專案**: Linux SSH Tunnel 學習環境  
**維護者**: 全端工程師團隊

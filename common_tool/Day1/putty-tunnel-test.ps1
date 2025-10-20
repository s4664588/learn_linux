# PuTTY SSH Tunnel 測試腳本
# 專為 Windows 用戶使用 PuTTY 設計

param(
    [switch]$Setup,
    [switch]$Test,
    [switch]$Cleanup,
    [switch]$All,
    [switch]$InstallPuTTY,
    [switch]$Interactive
)

# 設定編碼
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 顏色輸出函數
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# 檢查 PuTTY 是否安裝
function Test-PuTTYInstalled {
    $puttyCommands = @("putty", "plink", "puttygen")
    $allInstalled = $true
    
    foreach ($cmd in $puttyCommands) {
        if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
            Write-ColorOutput "❌ 未找到 $cmd" "Red"
            $allInstalled = $false
        } else {
            Write-ColorOutput "✅ 找到 $cmd" "Green"
        }
    }
    
    return $allInstalled
}

# 安裝 PuTTY
function Install-PuTTY {
    Write-ColorOutput "`n🔧 安裝 PuTTY..." "Cyan"
    
    # 嘗試使用 Chocolatey
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-ColorOutput "使用 Chocolatey 安裝 PuTTY..." "Yellow"
        choco install putty -y
        return $LASTEXITCODE -eq 0
    }
    
    # 嘗試使用 Winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-ColorOutput "使用 Winget 安裝 PuTTY..." "Yellow"
        winget install PuTTY.PuTTY --accept-source-agreements --accept-package-agreements
        return $LASTEXITCODE -eq 0
    }
    
    # 手動下載提示
    Write-ColorOutput "❌ 未找到套件管理器，請手動安裝 PuTTY" "Red"
    Write-ColorOutput "下載連結: https://www.putty.org/" "Cyan"
    return $false
}

# 檢查 Docker 環境
function Test-DockerEnvironment {
    Write-ColorOutput "`n🔍 檢查 Docker 環境..." "Yellow"
    
    try {
        docker version | Out-Null
        Write-ColorOutput "✅ Docker 運行正常" "Green"
        
        # 檢查容器狀態
        $containers = docker-compose ps --services --filter "status=running"
        if ($containers -contains "ssh-gateway") {
            Write-ColorOutput "✅ SSH Gateway 容器運行中" "Green"
            return $true
        } else {
            Write-ColorOutput "⚠️ SSH Gateway 容器未運行" "Yellow"
            return $false
        }
    } catch {
        Write-ColorOutput "❌ Docker 未運行或環境異常" "Red"
        return $false
    }
}

# 設定 SSH 主機金鑰
function Setup-SSHHostKey {
    Write-ColorOutput "`n🔑 設定 SSH 主機金鑰..." "Yellow"
    
    try {
        # 嘗試自動接受主機金鑰
        $acceptKey = "y`n" | plink -ssh -P 2222 sshuser@localhost -pw password123 "echo 'SSH 金鑰測試'" 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ SSH 主機金鑰已設定" "Green"
            return $true
        } else {
            Write-ColorOutput "⚠️ 需要手動接受 SSH 主機金鑰" "Yellow"
            Write-ColorOutput "請在出現提示時輸入 'y' 接受主機金鑰" "Gray"
            
            # 手動接受主機金鑰
            plink -ssh -P 2222 sshuser@localhost -pw password123 "echo 'SSH 金鑰已接受'" | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✅ SSH 主機金鑰設定完成" "Green"
                return $true
            } else {
                Write-ColorOutput "❌ SSH 主機金鑰設定失敗" "Red"
                return $false
            }
        }
    } catch {
        Write-ColorOutput "❌ SSH 主機金鑰設定異常: $($_.Exception.Message)" "Red"
        return $false
    }
}

# 設定測試環境
function Setup-TestEnvironment {
    Write-ColorOutput "`n🚀 設定 PuTTY SSH Tunnel 測試環境" "Cyan"
    
    # 檢查 PuTTY
    if (-not (Test-PuTTYInstalled)) {
        Write-ColorOutput "請先安裝 PuTTY 或使用 -InstallPuTTY 參數" "Red"
        return $false
    }
    
    # 啟動 Docker 環境
    Write-ColorOutput "`n🐳 啟動 Docker 環境..." "Yellow"
    docker-compose up -d
    
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "❌ Docker 環境啟動失敗" "Red"
        return $false
    }
    
    # 等待服務就緒
    Write-ColorOutput "`n⏳ 等待服務啟動 (30秒)..." "Yellow"
    Start-Sleep -Seconds 30
    
    # 檢查服務狀態
    Write-ColorOutput "`n📊 檢查容器狀態:" "Cyan"
    docker-compose ps
    
    # 設定 SSH 主機金鑰
    if (-not (Setup-SSHHostKey)) {
        Write-ColorOutput "❌ SSH 主機金鑰設定失敗，但環境已啟動" "Yellow"
        Write-ColorOutput "您可能需要手動接受 SSH 主機金鑰" "Gray"
    }
    
    return $true
}

# 建立 PuTTY Session 設定
function Create-PuTTYSession {
    Write-ColorOutput "`n🔧 建立 PuTTY Session 設定..." "Yellow"
    
    $sessionName = "SSH-Gateway-Tunnels"
    $regPath = "HKCU:\Software\SimonTatham\PuTTY\Sessions\$sessionName"
    
    try {
        # 建立註冊表項目
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        # 設定基本連線參數
        Set-ItemProperty -Path $regPath -Name "HostName" -Value "localhost"
        Set-ItemProperty -Path $regPath -Name "PortNumber" -Value 2222
        Set-ItemProperty -Path $regPath -Name "Protocol" -Value "ssh"
        Set-ItemProperty -Path $regPath -Name "UserName" -Value "sshuser"
        
        # 設定 Port Forwarding (使用新的 Port 避免衝突)
        Set-ItemProperty -Path $regPath -Name "PortForwardings" -Value "L8090=target-server-1:80,L8091=target-server-1:22,L8093=target-server-2:3306"
        
        Write-ColorOutput "✅ PuTTY Session '$sessionName' 設定完成" "Green"
        return $true
    } catch {
        Write-ColorOutput "❌ PuTTY Session 設定失敗: $($_.Exception.Message)" "Red"
        return $false
    }
}

# 測試 PuTTY SSH Tunnel
function Test-PuTTYTunnels {
    Write-ColorOutput "`n🧪 測試 PuTTY SSH Tunnel" "Cyan"
    
    # 檢查環境
    if (-not (Test-DockerEnvironment)) {
        Write-ColorOutput "❌ Docker 環境未就緒，請先執行 -Setup" "Red"
        return $false
    }
    
    Write-ColorOutput "`n📋 PuTTY SSH Tunnel 測試項目:" "Yellow"
    Write-ColorOutput "1. 建立 SSH Tunnel 連線" "White"
    Write-ColorOutput "2. 驗證 Port Forwarding" "White"
    Write-ColorOutput "3. 測試各項服務" "White"
    
    # 測試 1: 建立 SSH Tunnel
    Write-ColorOutput "`n🔗 測試 1: 建立 SSH Tunnel 連線" "Yellow"
    
    try {
        # 使用 plink 建立 SSH Tunnel (背景執行)
        Write-ColorOutput "正在建立 SSH Tunnel..." "Gray"
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
        
        # 先測試簡單的 SSH 連線
        Write-ColorOutput "測試基本 SSH 連線..." "Gray"
        $testConnection = & plink -ssh -P 2222 -pw "password123" -batch sshuser@localhost "echo 'SSH 連線測試'"
        
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ 基本 SSH 連線失敗，無法建立 Tunnel" "Red"
            Write-ColorOutput "錯誤碼: $LASTEXITCODE" "Red"
            return $false
        }
        
        Write-ColorOutput "✅ 基本 SSH 連線成功，建立 Tunnel..." "Green"
        
        $tunnelProcess = Start-Process -FilePath "plink" -ArgumentList $tunnelArgs -WindowStyle Hidden -PassThru
        
        # 等待 Tunnel 建立
        Start-Sleep -Seconds 8
        
        if ($tunnelProcess -and -not $tunnelProcess.HasExited) {
            Write-ColorOutput "✅ SSH Tunnel 建立成功 (PID: $($tunnelProcess.Id))" "Green"
        } else {
            Write-ColorOutput "❌ SSH Tunnel 程序異常退出" "Red"
            if ($tunnelProcess) {
                Write-ColorOutput "程序退出碼: $($tunnelProcess.ExitCode)" "Red"
            }
            return $false
        }
        
    } catch {
        Write-ColorOutput "❌ SSH Tunnel 建立異常: $($_.Exception.Message)" "Red"
        return $false
    }
    
    # 測試 2: 驗證 Port Forwarding
    Write-ColorOutput "`n🔍 測試 2: 驗證 Port Forwarding" "Yellow"
    
    $testPorts = @(8090, 8091, 8093)
    $portResults = @{}
    
    foreach ($port in $testPorts) {
        try {
            $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue
            $portResults[$port] = $connection.TcpTestSucceeded
            
            if ($connection.TcpTestSucceeded) {
                Write-ColorOutput "✅ Port $port 轉發正常" "Green"
            } else {
                Write-ColorOutput "❌ Port $port 轉發失敗" "Red"
            }
        } catch {
            Write-ColorOutput "❌ Port $port 測試異常" "Red"
            $portResults[$port] = $false
        }
    }
    
    # 測試 3: 服務功能測試
    Write-ColorOutput "`n🧪 測試 3: 服務功能測試" "Yellow"
    
    # Web 服務測試
    if ($portResults[8090]) {
        try {
            $webResponse = Invoke-WebRequest -Uri "http://localhost:8090" -TimeoutSec 10
            if ($webResponse.StatusCode -eq 200) {
                Write-ColorOutput "✅ Web 服務 (Port 8090) 測試成功" "Green"
            }
        } catch {
            Write-ColorOutput "❌ Web 服務測試失敗: $($_.Exception.Message)" "Red"
        }
    }
    
    # SSH 服務測試
    if ($portResults[8091]) {
        try {
            $sshTest = & plink -ssh -P 8091 -pw "rootpassword" -batch root@localhost "echo 'SSH Tunnel 連線成功'"
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✅ SSH 服務 (Port 8091) 測試成功" "Green"
            } else {
                Write-ColorOutput "❌ SSH 服務測試失敗" "Red"
            }
        } catch {
            Write-ColorOutput "❌ SSH 服務測試異常: $($_.Exception.Message)" "Red"
        }
    }
    
    # 資料庫服務測試
    if ($portResults[8093]) {
        Write-ColorOutput "✅ 資料庫服務 (Port 8093) Port 轉發正常" "Green"
        Write-ColorOutput "   可使用: mysql -h localhost -P 8093 -u testuser -p" "Gray"
    }
    
    # 清理測試程序
    if ($tunnelProcess -and -not $tunnelProcess.HasExited) {
        Write-ColorOutput "`n🧹 清理測試程序..." "Yellow"
        Stop-Process -Id $tunnelProcess.Id -Force -ErrorAction SilentlyContinue
        Write-ColorOutput "✅ 測試程序已清理" "Green"
    }
    
    return $true
}

# 建立持續的 SSH Tunnel 連線
function Start-PersistentTunnel {
    Write-ColorOutput "`n🔗 建立持續的 SSH Tunnel 連線" "Cyan"
    
    # 檢查環境
    if (-not (Test-DockerEnvironment)) {
        Write-ColorOutput "❌ Docker 環境未就緒，請先執行選項 2 設定環境" "Red"
        return $false
    }
    
    # 檢查是否已有 plink 程序運行
    $existingProcess = Get-Process -Name "plink" -ErrorAction SilentlyContinue
    if ($existingProcess) {
        Write-ColorOutput "⚠️ 發現已有 SSH Tunnel 運行中" "Yellow"
        Write-ColorOutput "PID: $($existingProcess.Id -join ', ')" "Gray"
        
        $choice = Read-Host "是否要停止現有連線並建立新連線？ (y/N)"
        if ($choice -eq 'y' -or $choice -eq 'Y') {
            $existingProcess | Stop-Process -Force
            Write-ColorOutput "✅ 已停止現有 SSH Tunnel" "Green"
            Start-Sleep -Seconds 2
        } else {
            Write-ColorOutput "❌ 取消建立新連線" "Red"
            return $false
        }
    }
    
    Write-ColorOutput "`n🚀 正在建立 SSH Tunnel..." "Yellow"
    Write-ColorOutput "連線資訊:" "White"
    Write-ColorOutput "  • 本機端口: 8090" "Gray"
    Write-ColorOutput "  • 目標服務: target-server-1:80" "Gray"
    Write-ColorOutput "  • SSH Gateway: localhost:2222" "Gray"
    
    try {
        # 先測試基本 SSH 連線
        Write-ColorOutput "`n🔑 測試 SSH 連線..." "Yellow"
        $testConnection = & plink -ssh -P 2222 -pw "password123" -batch sshuser@localhost "echo 'SSH 連線測試成功'"
        
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ SSH 連線測試失敗" "Red"
            return $false
        }
        
        Write-ColorOutput "✅ SSH 連線測試成功" "Green"
        
        # 建立 SSH Tunnel (前景執行)
        Write-ColorOutput "`n🔗 建立 SSH Tunnel 連線..." "Yellow"
        Write-ColorOutput "⚠️  注意: SSH Tunnel 將保持運行狀態" "Yellow"
        Write-ColorOutput "⚠️  請保持此視窗開啟，按 Ctrl+C 可中斷連線" "Yellow"
        Write-ColorOutput "⚠️  您現在可以在瀏覽器中訪問: http://localhost:8090" "Green"
        Write-ColorOutput "`n🌐 測試方法:" "Cyan"
        Write-ColorOutput "  1. 開啟瀏覽器訪問: http://localhost:8090" "White"
        Write-ColorOutput "  2. 或在新的 PowerShell 視窗執行: curl http://localhost:8090" "White"
        Write-ColorOutput "  3. 按 Ctrl+C 停止 SSH Tunnel" "White"
        Write-ColorOutput "`n" "White"
        
        # 執行 SSH Tunnel (前景模式，會阻塞直到用戶中斷)
        & plink -ssh -L 8090:target-server-1:80 -P 2222 -pw "password123" -batch sshuser@localhost -N
        
        Write-ColorOutput "`n✅ SSH Tunnel 已中斷" "Green"
        return $true
        
    } catch {
        Write-ColorOutput "❌ SSH Tunnel 建立失敗: $($_.Exception.Message)" "Red"
        return $false
    }
}

# 清理環境
function Cleanup-Environment {
    Write-ColorOutput "`n🧹 清理 PuTTY SSH Tunnel 環境" "Cyan"
    
    # 停止所有 plink 程序
    Get-Process -Name "plink" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-ColorOutput "✅ 已停止所有 plink 程序" "Green"
    
    # 停止 Docker 環境
    docker-compose down
    Write-ColorOutput "✅ Docker 環境已停止" "Green"
}

# 顯示互動式選單
function Show-InteractiveMenu {
    Clear-Host
    Write-ColorOutput "🖥️ PuTTY SSH Tunnel 互動式測試工具" "Cyan"
    Write-ColorOutput "═══════════════════════════════════════════════════" "Cyan"
    Write-ColorOutput "基於 hello02923 的 SSH Tunnel 文章實作" "Gray"
    Write-ColorOutput "參考: https://ithelp.ithome.com.tw/articles/10290848" "Gray"
    
    Write-ColorOutput "`n📋 請選擇要執行的操作:" "Yellow"
    Write-ColorOutput "  1️⃣  安裝 PuTTY (使用 Chocolatey 或 Winget)" "White"
    Write-ColorOutput "  2️⃣  設定測試環境 (啟動 Docker + 建立 PuTTY Session)" "White"
    Write-ColorOutput "  3️⃣  執行 SSH Tunnel 測試 (驗證所有功能)" "White"
    Write-ColorOutput "  4️⃣  清理測試環境 (停止服務 + 清理程序)" "White"
    Write-ColorOutput "  5️⃣  執行完整測試流程 (2→3→4 自動執行)" "White"
    Write-ColorOutput "  6️⃣  建立持續 SSH Tunnel 連線 (手動測試 8090 端口)" "White"
    Write-ColorOutput "  7️⃣  顯示 PuTTY 手動操作說明" "White"
    Write-ColorOutput "  8️⃣  檢查環境狀態 (Docker + PuTTY + 服務狀態)" "White"
    Write-ColorOutput "  0️⃣  退出程式" "White"
    
    Write-ColorOutput "`n🎯 目前環境狀態:" "Cyan"
    
    # 檢查 PuTTY 狀態
    if (Test-PuTTYInstalled) {
        Write-ColorOutput "  ✅ PuTTY 已安裝" "Green"
    } else {
        Write-ColorOutput "  ❌ PuTTY 未安裝" "Red"
    }
    
    # 檢查 Docker 狀態
    try {
        docker version | Out-Null
        Write-ColorOutput "  ✅ Docker 運行正常" "Green"
        
        # 檢查容器狀態
        $containers = docker-compose ps --services --filter "status=running" 2>$null
        if ($containers -contains "ssh-gateway") {
            Write-ColorOutput "  ✅ SSH Gateway 容器運行中" "Green"
        } else {
            Write-ColorOutput "  ⚠️ SSH Gateway 容器未運行" "Yellow"
        }
    } catch {
        Write-ColorOutput "  ❌ Docker 未運行" "Red"
    }
    
    Write-ColorOutput "`n" "White"
}

# 等待用戶輸入
function Wait-UserInput {
    param([string]$Message = "按任意鍵繼續...")
    Write-ColorOutput "`n$Message" "Gray"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# 執行互動式選單
function Start-InteractiveMode {
    do {
        Show-InteractiveMenu
        
        $choice = Read-Host "請輸入選項 (0-8)"
        
        switch ($choice) {
            "1" {
                Write-ColorOutput "`n🔧 執行選項 1: 安裝 PuTTY" "Cyan"
                Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
                
                if (Install-PuTTY) {
                    Write-ColorOutput "`n✅ PuTTY 安裝完成！" "Green"
                } else {
                    Write-ColorOutput "`n❌ PuTTY 安裝失敗，請手動安裝" "Red"
                    Write-ColorOutput "下載連結: https://www.putty.org/" "Cyan"
                }
                Wait-UserInput
            }
            
            "2" {
                Write-ColorOutput "`n🚀 執行選項 2: 設定測試環境" "Cyan"
                Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
                
                if (Setup-TestEnvironment) {
                    if (Create-PuTTYSession) {
                        Write-ColorOutput "`n✅ 測試環境設定完成！" "Green"
                        Write-ColorOutput "📋 已建立 PuTTY Session: SSH-Gateway-Tunnels" "Gray"
                    }
                } else {
                    Write-ColorOutput "`n❌ 測試環境設定失敗" "Red"
                }
                Wait-UserInput
            }
            
            "3" {
                Write-ColorOutput "`n🧪 執行選項 3: 執行 SSH Tunnel 測試" "Cyan"
                Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
                
                if (Test-PuTTYTunnels) {
                    Write-ColorOutput "`n✅ SSH Tunnel 測試完成！" "Green"
                } else {
                    Write-ColorOutput "`n❌ SSH Tunnel 測試失敗" "Red"
                }
                Wait-UserInput
            }
            
            "4" {
                Write-ColorOutput "`n🧹 執行選項 4: 清理測試環境" "Cyan"
                Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
                
                Cleanup-Environment
                Write-ColorOutput "`n✅ 測試環境清理完成！" "Green"
                Wait-UserInput
            }
            
            "5" {
                Write-ColorOutput "`n🎯 執行選項 5: 完整測試流程" "Cyan"
                Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
                
                Write-ColorOutput "🔄 步驟 1/3: 設定測試環境..." "Yellow"
                if (Setup-TestEnvironment) {
                    Create-PuTTYSession | Out-Null
                    
                    Write-ColorOutput "`n🔄 步驟 2/3: 執行 SSH Tunnel 測試..." "Yellow"
                    Start-Sleep -Seconds 2
                    Test-PuTTYTunnels | Out-Null
                    
                    Write-ColorOutput "`n🔄 步驟 3/3: 清理測試環境..." "Yellow"
                    Start-Sleep -Seconds 2
                    Cleanup-Environment
                    
                    Write-ColorOutput "`n✅ 完整測試流程執行完成！" "Green"
                } else {
                    Write-ColorOutput "`n❌ 完整測試流程執行失敗" "Red"
                }
                Wait-UserInput
            }
            
            "6" {
                Write-ColorOutput "`n🔗 執行選項 6: 建立持續 SSH Tunnel 連線" "Cyan"
                Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
                
                Start-PersistentTunnel
                Write-ColorOutput "`n📋 提示: 您可以繼續使用選單進行其他操作" "Gray"
                Wait-UserInput
            }
            
            "7" {
                Show-PuTTYManualGuide
                Wait-UserInput
            }
            
            "8" {
                Show-EnvironmentStatus
                Wait-UserInput
            }
            
            "0" {
                Write-ColorOutput "`n👋 感謝使用 PuTTY SSH Tunnel 測試工具！" "Green"
                Write-ColorOutput "如有問題請參考 putty-ssh-tunnel-guide.md" "Gray"
                return
            }
            
            default {
                Write-ColorOutput "`n❌ 無效的選項，請輸入 0-8 之間的數字" "Red"
                Wait-UserInput
            }
        }
    } while ($true)
}

# 顯示 PuTTY 手動操作指南
function Show-PuTTYManualGuide {
    Clear-Host
    Write-ColorOutput "📖 PuTTY 手動操作指南" "Cyan"
    Write-ColorOutput "═══════════════════════════════════════" "Cyan"
    
    Write-ColorOutput "`n🔧 PuTTY GUI 設定步驟:" "Yellow"
    Write-ColorOutput "1. 開啟 PuTTY 應用程式" "White"
    Write-ColorOutput "2. 在 Session 頁面設定:" "White"
    Write-ColorOutput "   • Host Name: localhost" "Gray"
    Write-ColorOutput "   • Port: 2222" "Gray"
    Write-ColorOutput "   • Connection type: SSH" "Gray"
    
    Write-ColorOutput "`n3. 設定 SSH Tunnel (Connection → SSH → Tunnels):" "White"
    Write-ColorOutput "   • Source port: 8080, Destination: target-server-1:80 → Add" "Gray"
    Write-ColorOutput "   • Source port: 8081, Destination: target-server-1:22 → Add" "Gray"
    Write-ColorOutput "   • Source port: 8083, Destination: target-server-2:3306 → Add" "Gray"
    
    Write-ColorOutput "`n4. 儲存設定:" "White"
    Write-ColorOutput "   • 回到 Session 頁面" "Gray"
    Write-ColorOutput "   • Saved Sessions 輸入: SSH-Gateway-Tunnels" "Gray"
    Write-ColorOutput "   • 點選 Save" "Gray"
    
    Write-ColorOutput "`n5. 建立連線:" "White"
    Write-ColorOutput "   • 點選 Open" "Gray"
    Write-ColorOutput "   • 使用者名稱: sshuser" "Gray"
    Write-ColorOutput "   • 密碼: password123" "Gray"
    
    Write-ColorOutput "`n🧪 測試指令:" "Yellow"
    Write-ColorOutput "開啟新的 PowerShell 視窗執行:" "White"
    Write-ColorOutput "  curl http://localhost:8090              # Web 服務" "Gray"
    Write-ColorOutput "  putty -ssh -P 8091 root@localhost       # SSH 服務" "Gray"
    Write-ColorOutput "  Test-NetConnection localhost -Port 8093 # 資料庫" "Gray"
    
    Write-ColorOutput "`n💡 提示:" "Yellow"
    Write-ColorOutput "• SSH Tunnel 需要保持 PuTTY 連線狀態" "White"
    Write-ColorOutput "• 關閉 PuTTY 視窗會中斷所有 Tunnel" "White"
    Write-ColorOutput "• 可以最小化 PuTTY 視窗在背景運行" "White"
}

# 顯示環境狀態
function Show-EnvironmentStatus {
    Clear-Host
    Write-ColorOutput "🔍 環境狀態檢查" "Cyan"
    Write-ColorOutput "═══════════════════════════════════════" "Cyan"
    
    # 檢查 PuTTY
    Write-ColorOutput "`n🖥️ PuTTY 狀態:" "Yellow"
    $puttyCommands = @("putty", "plink", "puttygen")
    foreach ($cmd in $puttyCommands) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            $version = & $cmd -V 2>$null | Select-Object -First 1
            Write-ColorOutput "  ✅ $cmd`: $version" "Green"
        } else {
            Write-ColorOutput "  ❌ $cmd`: 未安裝" "Red"
        }
    }
    
    # 檢查 Docker
    Write-ColorOutput "`n🐳 Docker 狀態:" "Yellow"
    try {
        $dockerVersion = docker --version
        Write-ColorOutput "  ✅ $dockerVersion" "Green"
        
        # 檢查 Docker Compose
        $composeVersion = docker-compose --version
        Write-ColorOutput "  ✅ $composeVersion" "Green"
        
    } catch {
        Write-ColorOutput "  ❌ Docker 未安裝或未運行" "Red"
    }
    
    # 檢查容器狀態
    Write-ColorOutput "`n📦 容器狀態:" "Yellow"
    try {
        $containers = docker-compose ps 2>$null
        if ($containers) {
            Write-ColorOutput $containers "Gray"
        } else {
            Write-ColorOutput "  ⚠️ 無運行中的容器" "Yellow"
        }
    } catch {
        Write-ColorOutput "  ❌ 無法檢查容器狀態" "Red"
    }
    
    # 檢查 Port 狀態
    Write-ColorOutput "`n🔌 Port 狀態:" "Yellow"
    $testPorts = @(2222, 8090, 8091, 8093)
    foreach ($port in $testPorts) {
        try {
            $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue
            if ($connection.TcpTestSucceeded) {
                Write-ColorOutput "  ✅ Port $port`: 監聽中" "Green"
            } else {
                Write-ColorOutput "  ❌ Port $port`: 未監聽" "Red"
            }
        } catch {
            Write-ColorOutput "  ❌ Port $port`: 檢查失敗" "Red"
        }
    }
    
    # 檢查 PuTTY Session
    Write-ColorOutput "`n🔧 PuTTY Session 狀態:" "Yellow"
    try {
        $sessionPath = "HKCU:\Software\SimonTatham\PuTTY\Sessions\SSH-Gateway-Tunnels"
        if (Test-Path $sessionPath) {
            Write-ColorOutput "  ✅ SSH-Gateway-Tunnels Session 已建立" "Green"
        } else {
            Write-ColorOutput "  ❌ SSH-Gateway-Tunnels Session 未建立" "Red"
        }
    } catch {
        Write-ColorOutput "  ❌ 無法檢查 PuTTY Session" "Red"
    }
}

# 顯示 PuTTY 使用說明
function Show-PuTTYUsage {
    Write-ColorOutput "`n📖 PuTTY SSH Tunnel 使用說明" "Cyan"
    Write-ColorOutput "基於 hello02923 的 SSH Tunnel 文章實作" "Gray"
    
    Write-ColorOutput "`n🚀 使用方法:" "Yellow"
    Write-ColorOutput "  .\putty-tunnel-test.ps1                # 啟動互動式選單" "White"
    Write-ColorOutput "  .\putty-tunnel-test.ps1 -Interactive   # 啟動互動式選單" "White"
    Write-ColorOutput "  .\putty-tunnel-test.ps1 -InstallPuTTY  # 安裝 PuTTY" "White"
    Write-ColorOutput "  .\putty-tunnel-test.ps1 -Setup        # 設定測試環境" "White"
    Write-ColorOutput "  .\putty-tunnel-test.ps1 -Test         # 執行 PuTTY 測試" "White"
    Write-ColorOutput "  .\putty-tunnel-test.ps1 -Cleanup      # 清理測試環境" "White"
    Write-ColorOutput "  .\putty-tunnel-test.ps1 -All          # 執行完整測試流程" "White"
    
    Write-ColorOutput "`n📚 詳細說明:" "Yellow"
    Write-ColorOutput "  查看 putty-ssh-tunnel-guide.md 獲得完整使用指南" "White"
}

# 主程式邏輯
if ($InstallPuTTY) {
    Write-ColorOutput "🖥️ PuTTY SSH Tunnel 測試工具" "Cyan"
    Write-ColorOutput "═══════════════════════════════════════" "Cyan"
    Install-PuTTY
    Write-ColorOutput "`n🎉 PuTTY 安裝程序完成！" "Green"
} elseif ($All) {
    Write-ColorOutput "🖥️ PuTTY SSH Tunnel 測試工具" "Cyan"
    Write-ColorOutput "═══════════════════════════════════════" "Cyan"
    if (Setup-TestEnvironment) {
        Create-PuTTYSession
        Start-Sleep -Seconds 2
        Test-PuTTYTunnels
        Start-Sleep -Seconds 2
        Cleanup-Environment
    }
    Write-ColorOutput "`n🎉 完整測試流程完成！" "Green"
} elseif ($Setup) {
    Write-ColorOutput "🖥️ PuTTY SSH Tunnel 測試工具" "Cyan"
    Write-ColorOutput "═══════════════════════════════════════" "Cyan"
    Setup-TestEnvironment
    Create-PuTTYSession
    Write-ColorOutput "`n🎉 環境設定完成！" "Green"
} elseif ($Test) {
    Write-ColorOutput "🖥️ PuTTY SSH Tunnel 測試工具" "Cyan"
    Write-ColorOutput "═══════════════════════════════════════" "Cyan"
    Test-PuTTYTunnels
    Write-ColorOutput "`n🎉 測試執行完成！" "Green"
} elseif ($Cleanup) {
    Write-ColorOutput "🖥️ PuTTY SSH Tunnel 測試工具" "Cyan"
    Write-ColorOutput "═══════════════════════════════════════" "Cyan"
    Cleanup-Environment
    Write-ColorOutput "`n🎉 環境清理完成！" "Green"
} elseif ($Interactive) {
    # 明確指定互動式模式
    Start-InteractiveMode
} else {
    # 預設啟動互動式選單
    Start-InteractiveMode
}

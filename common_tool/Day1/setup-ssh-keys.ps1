# SSH 主機金鑰設定腳本
# 解決 Windows 主機 SSH 連線問題

Write-Host "🔑 設定 SSH 主機金鑰" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan

# 檢查 Docker 環境
Write-Host "`n🔍 檢查 Docker 環境..." -ForegroundColor Yellow
try {
    $containers = docker-compose ps --services --filter "status=running"
    if ($containers -contains "ssh-gateway") {
        Write-Host "✅ SSH Gateway 容器運行中" -ForegroundColor Green
    } else {
        Write-Host "❌ SSH Gateway 容器未運行，請先執行 docker-compose up -d" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Docker 環境異常" -ForegroundColor Red
    exit 1
}

# 方法 1: 使用 plink 自動接受主機金鑰
Write-Host "`n🔧 方法 1: 自動接受 SSH 主機金鑰..." -ForegroundColor Yellow

try {
    # 使用 echo y 自動接受主機金鑰
    $acceptKey = "y`n" | plink -ssh -P 2222 sshuser@localhost -pw password123 "echo 'SSH 金鑰已接受'" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSH 主機金鑰已成功接受" -ForegroundColor Green
    } else {
        Write-Host "⚠️ 自動接受可能失敗，嘗試手動方式..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ 自動接受失敗，嘗試手動方式..." -ForegroundColor Yellow
}

# 方法 2: 手動接受主機金鑰
Write-Host "`n🔧 方法 2: 手動接受 SSH 主機金鑰..." -ForegroundColor Yellow
Write-Host "即將開啟 SSH 連線，請按照以下步驟操作：" -ForegroundColor White
Write-Host "1. 看到 'Store key in cache? (y/n)' 時，輸入 'y' 並按 Enter" -ForegroundColor Gray
Write-Host "2. 看到密碼提示時，輸入: password123" -ForegroundColor Gray
Write-Host "3. 連線成功後會顯示 'SSH 連線測試成功' 並自動斷線" -ForegroundColor Gray
Write-Host "`n按任意鍵開始手動設定..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

try {
    plink -ssh -P 2222 sshuser@localhost "echo 'SSH 連線測試成功'"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ SSH 主機金鑰設定完成！" -ForegroundColor Green
    } else {
        Write-Host "`n⚠️ 請檢查連線設定" -ForegroundColor Yellow
    }
} catch {
    Write-Host "`n❌ 手動設定失敗: $($_.Exception.Message)" -ForegroundColor Red
}

# 驗證設定
Write-Host "`n🧪 驗證 SSH 連線..." -ForegroundColor Yellow
try {
    $testResult = plink -ssh -P 2222 -pw password123 -batch sshuser@localhost "echo 'SSH 驗證成功'"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSH 連線驗證成功！現在可以使用 SSH Tunnel 了" -ForegroundColor Green
        
        # 測試 SSH Tunnel
        Write-Host "`n🌉 測試 SSH Tunnel..." -ForegroundColor Yellow
        $tunnelProcess = Start-Process -FilePath "plink" -ArgumentList @(
            "-ssh", "-L", "8080:target-server-1:80", "-P", "2222", 
            "-pw", "password123", "-batch", "sshuser@localhost", "-N"
        ) -WindowStyle Hidden -PassThru
        
        Start-Sleep -Seconds 3
        
        # 檢查 Port 8080 是否在監聽
        $portTest = Test-NetConnection -ComputerName localhost -Port 8080 -WarningAction SilentlyContinue
        
        if ($portTest.TcpTestSucceeded) {
            Write-Host "✅ SSH Tunnel 測試成功！Port 8080 已開啟" -ForegroundColor Green
            
            # 測試 Web 服務
            try {
                $webTest = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 5
                if ($webTest.StatusCode -eq 200) {
                    Write-Host "✅ Web 服務透過 SSH Tunnel 存取成功！" -ForegroundColor Green
                }
            } catch {
                Write-Host "⚠️ Web 服務測試失敗，但 SSH Tunnel 已建立" -ForegroundColor Yellow
            }
        } else {
            Write-Host "❌ SSH Tunnel 測試失敗" -ForegroundColor Red
        }
        
        # 清理測試程序
        if ($tunnelProcess -and -not $tunnelProcess.HasExited) {
            Stop-Process -Id $tunnelProcess.Id -Force -ErrorAction SilentlyContinue
            Write-Host "🧹 測試程序已清理" -ForegroundColor Gray
        }
        
    } else {
        Write-Host "❌ SSH 連線驗證失敗" -ForegroundColor Red
        Write-Host "請檢查：" -ForegroundColor White
        Write-Host "1. Docker 容器是否正常運行: docker-compose ps" -ForegroundColor Gray
        Write-Host "2. SSH 服務是否啟動: docker exec ssh-gateway service ssh status" -ForegroundColor Gray
        Write-Host "3. 防火牆是否阻擋 Port 2222" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ SSH 連線驗證異常: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 SSH 主機金鑰設定完成！" -ForegroundColor Green
Write-Host "現在您可以使用 .\putty-tunnel-test.ps1 進行完整測試" -ForegroundColor White

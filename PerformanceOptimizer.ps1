#Requires -RunAsAdministrator
$LogFile = "$env:windir\Temp\PerformanceOptimizer.log"
$Fixes = 0
$Issues = 0

function Write-Log {
    param([string]$Message)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$time] $Message"
}

function Show-Menu {
    Clear-Host
    Write-Host "=== Windows Performance Optimizer ===" -ForegroundColor Cyan
    Write-Host "[1] Full Optimization & Cleanup"
    Write-Host "[2] Performance Scan Only"
    Write-Host "[3] View Log Report"
    Write-Host "[4] Exit"
    Write-Host ""
    $choice = Read-Host "Select an option"
    switch ($choice) {
        "1" { Full-Optimize }
        "2" { Scan-Performance }
        "3" { notepad $LogFile; Show-Menu }
        "4" { exit }
        default { Show-Menu }
    }
}

function Full-Optimize {
    Write-Log "Full Optimization Started"

    # 1. Temp Cleanup
    Write-Host "[+] Cleaning Temp folders..." -ForegroundColor Yellow
    Get-ChildItem -Path $env:TEMP -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Get-ChildItem -Path "$env:windir\Temp" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Write-Log "Temp files cleaned"
    $Fixes++

    # 2. Recycle Bin
    Write-Host "[+] Emptying Recycle Bin..." -ForegroundColor Yellow
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Log "Recycle Bin emptied"
    $Fixes++

    # 3. Prefetch
    Write-Host "[+] Clearing Prefetch..." -ForegroundColor Yellow
    Get-ChildItem -Path "$env:windir\Prefetch" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Log "Prefetch cleaned"
    $Fixes++

    # 4. Disable third-party Startup apps
    Write-Host "[+] Disabling non-system startup apps..." -ForegroundColor Yellow
    $apps = Get-CimInstance Win32_StartupCommand | Where-Object { $_.Location -notlike "*Windows*" }
    foreach ($app in $apps) {
        try {
            $app | Remove-CimInstance -ErrorAction Stop
            Write-Log "Disabled startup: $($app.Name)"
        } catch {
            Write-Log "Failed to disable: $($app.Name)"
        }
    }
    $Fixes++

    Scan-Performance
}

function Scan-Performance {
    Write-Log "Performance Scan Started"
    Write-Host "[+] Analyzing top processes..." -ForegroundColor Green

    # Top CPU
    Write-Host "`n--- Top CPU Consumers ---"
    $topCPU = Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU
    $topCPU | Format-Table | Out-String | Write-Host
    $topCPU | Out-String | Add-Content $LogFile

    # Top RAM
    Write-Host "`n--- Top RAM Consumers ---"
    $topRAM = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, @{Name="RAM(MB)";Expression={[math]::Round($_.WorkingSet/1MB,2)}}
    $topRAM | Format-Table | Out-String | Write-Host
    $topRAM | Out-String | Add-Content $LogFile

    # Suspicious
    Write-Host "`n[+] Checking for suspicious processes..." -ForegroundColor Yellow
    $suspicious = Get-Process | Where-Object { $_.Path -and !(Test-Path $_.Path) }
    if ($suspicious) {
        Write-Log "--- Suspicious Processes ---"
        $suspicious | Select-Object Name, Id, Path | Format-Table | Out-String | Tee-Object -Variable output | Add-Content $LogFile
        $output | Write-Host -ForegroundColor Red
        $Issues++
    }

    # Unsigned
    Write-Host "[+] Checking for unsigned processes..." -ForegroundColor Yellow
    $unsigned = Get-Process | Where-Object {
        $_.Path -and (Get-AuthenticodeSignature $_.Path).Status -ne 'Valid'
    }
    if ($unsigned) {
        Write-Log "--- Unsigned Processes ---"
        $unsigned | Select-Object Name, Path | Format-Table | Out-String | Tee-Object -Variable output | Add-Content $LogFile
        $output | Write-Host -ForegroundColor Red
        $Issues++
    }

    # Disks
    Write-Host "[+] Checking disk usage..." -ForegroundColor Green
    Get-PSDrive -PSProvider FileSystem | Format-Table | Out-String | Add-Content $LogFile

    Final-Report
}

function Final-Report {
    Write-Host "`n=== Summary Report ===" -ForegroundColor Cyan
    Write-Host "Fixes Applied : $Fixes"
    Write-Host "Issues Found  : $Issues"
    Write-Host "Log File      : $LogFile"
    Write-Host "`n[!] Operation completed. Press Enter to return to menu..."
    Read-Host
    Show-Menu
}

# Create log file
Set-Content -Path $LogFile -Value "[INFO] Performance Optimizer Started at $(Get-Date)"
Show-Menu

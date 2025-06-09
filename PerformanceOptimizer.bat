@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: =============== ADMIN PRIVILEGES ===============
NET SESSION >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Administrator privileges are required.
    echo Please right-click and choose "Run as Administrator".
    timeout /t 5
    exit /b
)

:: =============== VARIABLES ===============
set "logfile=%SystemRoot%\Temp\PerformanceOptimizer.log"
set /a fixes=0
set /a issues=0

:: Initialize log
echo [%date% %time%] Performance Optimizer Started > "%logfile%"

:: =============== MENU ===============
:menu
cls
echo.
echo === Windows Performance Optimizer ===
echo [1] Full Optimization & Cleanup
echo [2] Performance Scan Only
echo [3] View Log Report
echo [4] Exit
echo.
choice /c 1234 /n /m "Select an option: "

if errorlevel 4 exit /b
if errorlevel 3 (
    if exist "%logfile%" (
        notepad "%logfile%"
    ) else (
        echo Log file not found!
        timeout /t 3
    )
    goto menu
)
if errorlevel 2 goto scan
if errorlevel 1 goto full_optimize

:: =============== FULL OPTIMIZATION ===============
:full_optimize
cls
echo [!] Running full optimization...
echo [%date% %time%] Full Optimization Started >> "%logfile%"

:: Clean Temp Files
echo [+] Cleaning Temp files...
del /f /s /q %temp%\* >nul 2>>"%logfile%"
del /f /s /q %SystemRoot%\Temp\* >nul 2>>"%logfile%"
echo    ✓ Temp files cleaned >> "%logfile%"
set /a fixes+=1

:: Disable Unused Startup Apps
echo [+] Disabling unused startup programs...
powershell -Command "Get-CimInstance Win32_StartupCommand | ForEach-Object { if ($_.Location -notlike '*Windows*') { $_ | Remove-CimInstance -ErrorAction SilentlyContinue }}" >> "%logfile%" 2>&1
echo    ✓ Startup programs cleaned >> "%logfile%"
set /a fixes+=1

:: Clear Prefetch
echo [+] Clearing Prefetch...
del /f /s /q %SystemRoot%\Prefetch\* >nul 2>>"%logfile%"
echo    ✓ Prefetch cleaned >> "%logfile%"
set /a fixes+=1

:: Run Scan
call :scan_performance

goto final_report

:: =============== PERFORMANCE SCAN ONLY ===============
:scan
cls
echo [!] Running performance scan...
echo [%date% %time%] Performance Scan Only >> "%logfile%"
call :scan_performance
goto final_report

:: =============== SCAN FUNCTION ===============
:scan_performance

echo [+] Checking top resource-consuming processes...
echo --- TOP PROCESSES (CPU/RAM) --- >> "%logfile%"
powershell -Command "Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 | Format-Table -AutoSize" >> "%logfile%" 2>&1

powershell -Command "Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 | Format-Table -AutoSize" >> "%logfile%" 2>&1

echo [+] Checking for suspicious processes...
echo --- SUSPICIOUS PROCESSES --- >> "%logfile%"
powershell -Command "Get-Process | Where-Object { $_.Path -ne $null -and !(Test-Path $_.Path) } | Format-Table Name,Id,Path" >> "%logfile%" 2>&1

echo [+] Checking for unsigned processes...
powershell -Command "Get-Process | Where-Object { $_.Path -and -not (Get-AuthenticodeSignature $_.Path).Status -eq 'Valid' } | Format-Table Name, Path" >> "%logfile%" 2>&1

echo [+] Checking disk usage...
powershell -Command "Get-PSDrive -PSProvider 'FileSystem'" >> "%logfile%" 2>&1

set /a issues+=1
exit /b

:: =============== FINAL REPORT ===============
:final_report
echo.
echo === Summary Report ===
echo Fixes Applied   : %fixes%
echo Issues Found    : %issues%
echo Log File        : %logfile%
echo -------------------------------
echo [!] Operation completed.
echo This window will close in 10 seconds...
timeout /t 10 /nobreak >nul
exit /b

@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Administrative Privileges Check
NET FILE >nul 2>&1 || (
    echo.
    echo    [X] Error: Administrator privileges required!
    echo.
    echo        Please right-click the script and select "Run as Administrator"
    echo       _____________________________________________________________
    timeout /t 5 /nobreak >nul
    exit /b 1
)

:: Configuration
set "logfile=%SystemRoot%\Temp\SystemCleaner.log"
set /a deleted_files=0
set /a errors=0
set "RED=9F" & set "GREEN=AF" & set "YELLOW=BF" & set "RESET=07"

:: Initialize Log File
echo [%date% %time%] Cleaning Process Started > "%logfile%"

:: Main Menu
:menu
cls
echo.
echo    === Windows 11 Advanced Cleaning Tool ===
echo    [1] Perform Full Automatic Cleanup
echo    [2] Choose Tasks Manually
echo    [3] View Log File
echo    [4] Exit
echo.
choice /c 1234 /n /m "Select an option [1-4]: "

if errorlevel 4 exit /b
if errorlevel 3 (
    if exist "%logfile%" (
        notepad "%logfile%"
    ) else (
        echo.
        echo    [!] Log file not found!
        timeout /t 3 /nobreak >nul
    )
    goto menu
)
if errorlevel 2 goto manual
if errorlevel 1 goto auto

:auto
set "clean_system_temp=1"
set "clean_user_temp=1"
set "clean_recycle_bin=1"
set "clean_disk_cleanup=1"
goto start_clean

:manual
cls
echo.
echo    === Manual Task Selection ===
echo    [1] System Temp Files  %systemroot%\temp
echo    [2] User Temp Files    %temp%
echo    [3] Recycle Bin
echo    [4] Disk Cleanup
echo    [5] All Tasks
echo    [6] Back
echo.
set "tasks="
set /p "tasks=Select tasks (e.g., 1 2 3): "
if "%tasks%"=="" goto manual

if "%tasks%"=="5" (
    set "clean_system_temp=1"
    set "clean_user_temp=1"
    set "clean_recycle_bin=1"
    set "clean_disk_cleanup=1"
    goto start_clean
)
if "%tasks%"=="6" goto menu

set "clean_system_temp="
set "clean_user_temp="
set "clean_recycle_bin="
set "clean_disk_cleanup="

for %%i in (%tasks%) do (
    if "%%i"=="1" set "clean_system_temp=1"
    if "%%i"=="2" set "clean_user_temp=1"
    if "%%i"=="3" set "clean_recycle_bin=1"
    if "%%i"=="4" set "clean_disk_cleanup=1"
)

goto start_clean

:start_clean
cls
echo.
echo    === Starting Cleaning Process ===

:: System Temp Files
if defined clean_system_temp (
    call :clean_task "Cleaning System Temp Files" "del /s /f /q %systemroot%\temp\*" "%systemroot%\temp"
)

:: User Temp Files
if defined clean_user_temp (
    call :clean_task "Cleaning User Temp Files" "del /s /f /q %temp%\*" "%temp%"
)

:: Recycle Bin
if defined clean_recycle_bin (
    call :clean_task "Emptying Recycle Bin" "powershell -Command Clear-RecycleBin -Force -ErrorAction Stop" "RecycleBin"
)

:: Disk Cleanup
if defined clean_disk_cleanup (
    call :clean_task "Running Disk Cleanup" "cleanmgr /sagerun:1" "DiskCleanup"
)

:: Final Report
echo.
echo    === Cleaning Report ===
echo    Successful Tasks : %deleted_files%
echo    Errors          : %errors%
echo    ______________________________
echo    Log File        : %logfile%
echo.
echo    [!] This window will close automatically in 10 seconds...
timeout /t 10 /nobreak >nul
exit /b

:: Clean Task Function
:clean_task
set "task_name=%~1"
set "command=%~2"
set "target=%~3"

echo.
echo    [!] Running %task_name% ...
echo [%date% %time%] Starting %task_name% >> "%logfile%"

set "temp_log=%temp%\%~n0_temp.log"
%command% 2>&1 > "%temp_log%"
type "%temp_log%" >> "%logfile%"

:: Count 'file in use' errors
set "error_count=0"
for /f "tokens=3" %%a in ('find /c "The process cannot access the file" "%temp_log%" 2^>nul') do set "error_count=%%a"
set /a errors+=error_count

:: Check for other errors (e.g., Access denied)
for /f "tokens=3" %%a in ('find /c "Access is denied" "%temp_log%" 2^>nul') do set /a errors+=%%a

if %errorlevel% equ 0 (
    echo    [!] %task_name% - ✓ Success
    echo [%date% %time%] Success: %task_name% >> "%logfile%"
    set /a deleted_files+=1
) else (
    echo    [!] %task_name% - ✗ Error
    echo [%date% %time%] ERROR: Failed %task_name% >> "%logfile%"
    set /a errors+=1
)

del "%temp_log%" >nul 2>&1
exit /b
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
set "logfile=%SystemRoot%\Temp\DiskManager.log"
set /a deleted_files=0
set /a errors=0
set "RED=9F" & set "GREEN=AF" & set "YELLOW=BF" & set "RESET=07"

:: Initialize Log File
echo [%date% %time%] Disk Management Process Started > "%logfile%"

:: Main Menu
:menu
cls
echo.
echo    === Windows Disk Management Tool ===
echo    [1] Display Disk Information
echo    [2] Check and Repair Disk (CHKDSK)
echo    [3] Format Disk
echo    [4] Clean Disk (Delete partitions and recreate)
echo    [5] Exit
echo.
choice /c 12345 /n /m "Select an option [1-5]: "

if errorlevel 5 exit /b
if errorlevel 4 goto clean_disk
if errorlevel 3 goto format_disk
if errorlevel 2 goto run_chkdsk
if errorlevel 1 goto display_disk_info

:: Display Disk Information
:display_disk_info
cls
echo.
echo    === Displaying Disk Information ===
echo.

:: List all disks (Fixed: Use wmic diskdrive here instead of logicaldisk to list disks)
set "disks="
set /a counter=0
for /f "skip=1 tokens=1,* delims=," %%a in ('wmic diskdrive get DeviceID /format:csv 2^>nul') do (
    if not "%%b"=="" (
        set /a counter+=1
        set "disks=!disks! %%b"
        echo    [!counter!] Disk %%b
    )
)

if %counter% equ 0 (
    echo    No disks available for operations.
    timeout /t 3 /nobreak >nul
    goto menu
)

echo    [0] Back to Main Menu
echo.
:select_disk_info
set /p "disk_select=Select a disk number [1-!counter!]: "
if "%disk_select%"=="0" goto menu

:: Validate input
set /a disk_select=%disk_select% 2>nul || (
    echo Invalid input.
    goto select_disk_info
)

if %disk_select% gtr %counter% (
    echo Input out of range.
    goto select_disk_info
)

:: Get selected disk (device path)
set /a index=0
for %%d in (%disks%) do (
    set /a index+=1
    if !index! equ %disk_select% (
        set "selected_disk=%%d"
    )
)

:: Display disk information
cls
echo.
echo    === Disk Information for !selected_disk! ===
echo.

:: Using diskpart to get info about selected disk
(
echo list partition
echo select disk !selected_disk!
echo detail disk
) | diskpart

echo.
echo    [!] Press any key to return to the main menu...
pause >nul
goto menu

:: Check and Repair Disk (CHKDSK)
:run_chkdsk
cls
echo.
echo    === Check and Repair Disk ===
echo.

:: List all logical drives
set "disks="
set /a counter=0
for /f "skip=1 delims=" %%d in ('wmic logicaldisk get deviceid 2^>nul') do (
    set "drive=%%d"
    set "drive=!drive: =!"
    if not "!drive!"=="" (
        set /a counter+=1
        set "disks=!disks! !drive!"
        echo    [!counter!] Disk !drive!
    )
)

if %counter% equ 0 (
    echo    No disks available for operations.
    timeout /t 3 /nobreak >nul
    goto menu
)

echo    [0] Back to Main Menu
echo.
:select_disk_chkdsk
set /p "disk_select=Select a disk number [1-!counter!]: "
if "%disk_select%"=="0" goto menu

:: Validate input
set /a disk_select=%disk_select% 2>nul || (
    echo Invalid input.
    goto select_disk_chkdsk
)

if %disk_select% gtr %counter% (
    echo Input out of range.
    goto select_disk_chkdsk
)

:: Get selected logical drive
set /a index=0
for %%d in (%disks%) do (
    set /a index+=1
    if !index! equ %disk_select% (
        set "selected_disk=%%d"
    )
)

:: Run CHKDSK
cls
echo.
echo [!] Running CHKDSK on !selected_disk!...
echo [%date% %time%] Starting CHKDSK on !selected_disk! >> "%logfile%"
chkdsk !selected_disk! /f /r
if errorlevel 1 (
    echo [X] Error during CHKDSK
    echo [%date% %time%] Failed CHKDSK on !selected_disk! >> "%logfile%"
    set /a errors+=1
) else (
    echo [✓] CHKDSK completed successfully
    echo [%date% %time%] Success: CHKDSK on !selected_disk! >> "%logfile%"
    set /a deleted_files+=1
)
timeout /t 5 /nobreak >nul
goto menu

:: Format Disk
:format_disk
cls
echo.
echo    === Format Disk ===
echo.

:: List all logical drives
set "disks="
set /a counter=0
for /f "skip=1 delims=" %%d in ('wmic logicaldisk get deviceid 2^>nul') do (
    set "drive=%%d"
    set "drive=!drive: =!"
    if not "!drive!"=="" (
        set /a counter+=1
        set "disks=!disks! !drive!"
        echo    [!counter!] Disk !drive!
    )
)

if %counter% equ 0 (
    echo    No disks available for operations.
    timeout /t 3 /nobreak >nul
    goto menu
)

echo    [0] Back to Main Menu
echo.
:select_disk_format
set /p "disk_select=Select a disk number [1-!counter!]: "
if "%disk_select%"=="0" goto menu

:: Validate input
set /a disk_select=%disk_select% 2>nul || (
    echo Invalid input.
    goto select_disk_format
)

if %disk_select% gtr %counter% (
    echo Input out of range.
    goto select_disk_format
)

:: Get selected logical drive
set /a index=0
for %%d in (%disks%) do (
    set /a index+=1
    if !index! equ %disk_select% (
        set "selected_disk=%%d"
    )
)

:: Confirm format
cls
echo.
echo [!!!] WARNING: This will erase ALL data on !selected_disk!
choice /m "Are you sure you want to continue" /c YN
if errorlevel 2 goto menu

:: Select file system
:select_fs
cls
echo.
echo    Select file system:
echo    [1] NTFS (Default)
echo    [2] exFAT (For large storage)
echo    [3] FAT32 (For compatibility)
echo.
set "fs=NTFS"
set /p "fs_select=Select file system [1-3]: "
if "%fs_select%"=="1" set "fs=NTFS"
if "%fs_select%"=="2" set "fs=exFAT"
if "%fs_select%"=="3" set "fs=FAT32"

:: Execute format
cls
echo.
echo [!] Formatting !selected_disk! with !fs!...
echo [%date% %time%] Starting format on !selected_disk! >> "%logfile%"
format !selected_disk! /FS:!fs! /Q /Y
if errorlevel 1 (
    echo [X] Error during format
    echo [%date% %time%] Failed format on !selected_disk! >> "%logfile%"
    set /a errors+=1
) else (
    echo [✓] Format completed successfully
    echo [%date% %time%] Success: Format on !selected_disk! >> "%logfile%"
    set /a deleted_files+=1
)
timeout /t 5 /nobreak >nul
goto menu

:: Clean Disk Section
:clean_disk
cls
echo.
echo    === Clean Disk (Remove partitions and reformat) ===
echo.

:: List physical disks
set "disks="
set /a counter=0
for /f "skip=1 tokens=1,* delims=," %%a in ('wmic diskdrive get DeviceID /format:csv 2^>nul') do (
    if not "%%b"=="" (
        set /a counter+=1
        set "disks=!disks! %%b"
        echo    [!counter!] Disk %%b
    )
)

if %counter% equ 0 (
    echo    No physical disks available.
    timeout /t 3 /nobreak >nul
    goto menu
)

echo    [0] Back to Main Menu
echo.
:select_disk_clean
set /p "disk_select=Select a disk number to clean [1-!counter!]: "
if "%disk_select%"=="0" goto menu

:: Validate input
set /a disk_select=%disk_select% 2>nul || (
    echo Invalid input.
    goto select_disk_clean
)

if %disk_select% gtr %counter% (
    echo Input out of range.
    goto select_disk_clean
)

:: Get selected disk number for diskpart (like 0,1,2...)
:: We need to get the disk number from the DeviceID, which is like \\.\PHYSICALDRIVE0
:: Extract the number at the end of the DeviceID string:
set /a index=0
for %%d in (%disks%) do (
    set /a index+=1
    if !index! equ %disk_select% (
        set "selected_disk=%%d"
    )
)

:: Extract disk number from selected_disk string
for /f "tokens=3 delims=." %%x in ("!selected_disk!") do set "disk_number=%%x"
:: disk_number will be like PHYSICALDRIVE0 => 0

cls
echo [!!!] WARNING: This will erase ALL data and partitions on disk !disk_number!
choice /m "Are you sure you want to continue" /c YN
if errorlevel 2 goto menu

:: Run diskpart clean commands
(
echo select disk !disk_number!
echo clean
echo create partition primary
echo format fs=ntfs quick
echo assign
echo exit
) | diskpart

if errorlevel 1 (
    echo [X] Error occurred during cleaning disk
    echo [%date% %time%] Failed clean on disk !disk_number! >> "%logfile%"
    set /a errors+=1
) else (
    echo [✓] Disk cleaned and formatted successfully
    echo [%date% %time%] Success: Cleaned disk !disk_number! >> "%logfile%"
    set /a deleted_files+=1
)

timeout /t 5 /nobreak >nul
goto menu

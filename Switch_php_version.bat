@echo off
title Switch PHP Version
cls

echo =============================
echo     Select PHP Version:
echo =============================
echo [1] PHP 8.1
echo [2] PHP 8.4.3
echo [0] Exit
echo.

set /p choice=Enter your choice: 

if "%choice%"=="1" (
    set "PATH=C:\xampp\php-8.1;%PATH%"
    echo Switched to PHP 8.1
    php -v
    cmd /k
    goto end
)

if "%choice%"=="2" (
    set "PATH=C:\xampp\php-8.4.3;%PATH%"
    echo Switched to PHP 8.4.3
    php -v
    cmd /k
    goto end
)

if "%choice%"=="0" (
    echo Exiting...
    goto end
)

echo Invalid choice! Please try again.
pause
call "%~f0"

:end

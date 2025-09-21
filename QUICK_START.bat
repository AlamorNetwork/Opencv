@echo off
chcp 65001 > nul
title 🚀 شروع فوری - پلتفرم PDF به متن فارسی

echo.
echo =============================================
echo      🚀 شروع فوری ویندوز سرور
echo =============================================
echo.
echo 💡 این اسکریپت همه کارهای نصب را خودکار انجام می‌دهد
echo.

REM بررسی دسترسی Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ برای نصب سرور، دسترسی Administrator لازم است
    echo.
    echo 🔄 در حال اجرای مجدد با دسترسی Administrator...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ✅ دسترسی Administrator تایید شد
echo.

REM بررسی Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python نصب نشده است!
    echo 📥 لطفا Python 3.8+ را از python.org نصب کنید
    start https://www.python.org/downloads/windows/
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo ✅ %PYTHON_VERSION% نصب است

REM تنظیم Execution Policy برای PowerShell
echo 🔧 تنظیم PowerShell...
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force" >nul 2>&1

REM اجرای Deploy اصلی
echo.
echo 🚀 شروع Deploy...
echo.

if exist "Deploy-WindowsServer.ps1" (
    echo 📋 استفاده از Deploy حرفه‌ای PowerShell...
    powershell -ExecutionPolicy Bypass -File "Deploy-WindowsServer.ps1"
    if %errorlevel% equ 0 (
        goto SUCCESS
    ) else (
        echo ⚠️ PowerShell Deploy ناموفق، تلاش با روش ساده...
    )
)

if exist "windows_server_deploy.bat" (
    echo 📋 استفاده از Deploy ساده...
    call windows_server_deploy.bat
    if %errorlevel% equ 0 (
        goto SUCCESS
    ) else (
        echo ⚠️ Deploy ساده ناموفق، تلاش با setup معمولی...
    )
)

if exist "setup_simple.bat" (
    echo 📋 استفاده از Setup معمولی...
    call setup_simple.bat
    if %errorlevel% equ 0 (
        goto BASIC_SUCCESS
    ) else (
        echo ❌ همه روش‌های نصب ناموفق بودند
        goto ERROR
    )
)

echo ❌ هیچ فایل نصبی یافت نشد!
goto ERROR

:SUCCESS
echo.
echo ========================================
echo 🎉 Deploy سرور با موفقیت تکمیل شد!
echo ========================================
echo.
echo 🌐 سرویس در حال اجرا: http://localhost:8501
echo 🔧 Windows Service: PDFToTextService
echo 📂 مسیر نصب: C:\PDFToText
echo.
echo 🔧 مدیریت سرویس:
echo   sc start PDFToTextService    - شروع
echo   sc stop PDFToTextService     - توقف
echo   sc query PDFToTextService    - وضعیت
echo.
goto END

:BASIC_SUCCESS
echo.
echo ========================================
echo 🎉 نصب پایه با موفقیت تکمیل شد!
echo ========================================
echo.
echo 🌐 برای اجرا: streamlit run app.py
echo 📂 مسیر فعلی: %CD%
echo.
echo 💡 برای نصب سرور حرفه‌ای:
echo   windows_server_deploy.bat
echo.
goto END

:ERROR
echo.
echo ========================================
echo ❌ خطا در نصب
echo ========================================
echo.
echo 🔧 راه‌حل‌های پیشنهادی:
echo 1. مطمئن شوید Python 3.8+ نصب است
echo 2. اتصال اینترنت برای دانلود پکیج‌ها
echo 3. دسترسی Administrator
echo 4. غیرفعال کردن موقت آنتی‌ویروس
echo.
echo 📞 در صورت ادامه مشکل:
echo   - بررسی فایل‌های لاگ
echo   - اجرای دستی هر اسکریپت
echo.

:END
echo.
echo 📋 برای خروج Enter را فشار دهید...
pause >nul

@echo off
chcp 65001 > nul
title پلتفرم تبدیل PDF به متن فارسی

echo.
echo ==========================================
echo    پلتفرم تبدیل PDF به متن فارسی
echo ==========================================
echo.

echo 📋 بررسی پیش‌نیازها...

REM بررسی نصب Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python نصب نشده است!
    echo لطفا Python 3.8+ را از python.org دانلود و نصب کنید
    pause
    exit /b 1
)

echo ✅ Python نصب شده است

REM بررسی وجود محیط مجازی
if not exist "venv" (
    echo 🔧 ایجاد محیط مجازی...
    python -m venv venv
    if %errorlevel% neq 0 (
        echo ❌ خطا در ایجاد محیط مجازی
        pause
        exit /b 1
    )
    echo ✅ محیط مجازی ایجاد شد
)

REM فعال‌سازی محیط مجازی
echo 🔄 فعال‌سازی محیط مجازی...
call venv\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo ❌ خطا در فعال‌سازی محیط مجازی
    pause
    exit /b 1
)

REM نصب وابستگی‌ها
echo 📦 بررسی و نصب وابستگی‌ها...
pip install --upgrade pip
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ❌ خطا در نصب وابستگی‌ها
    pause
    exit /b 1
)

echo ✅ تمام وابستگی‌ها نصب شدند

REM بررسی نصب Tesseract
echo 🔍 بررسی نصب Tesseract OCR...
tesseract --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Tesseract OCR یافت نشد
    echo برای نصب Tesseract:
    echo 1. از لینک زیر دانلود کنید:
    echo    https://github.com/UB-Mannheim/tesseract/wiki
    echo 2. یا با Chocolatey: choco install tesseract
    echo 3. یا با Scoop: scoop install tesseract
    echo.
    echo آیا می‌خواهید بدون Tesseract ادامه دهید؟ (y/N)
    set /p continue="پاسخ: "
    if /i not "%continue%"=="y" (
        pause
        exit /b 1
    )
) else (
    echo ✅ Tesseract OCR نصب شده است
)

echo.
echo 🚀 راه‌اندازی سرور...
echo.
echo برای متوقف کردن سرور از Ctrl+C استفاده کنید
echo سرور در آدرس http://localhost:8501 در حال اجرا است
echo.

REM اجرای برنامه
streamlit run app.py --server.port=8501 --server.address=localhost

pause

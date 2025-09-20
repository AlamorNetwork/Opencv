@echo off
chcp 65001 > nul
title نصب سریع پلتفرم PDF به متن فارسی

echo.
echo ==========================================
echo    نصب سریع در ویندوز
echo ==========================================
echo.

REM بررسی Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python نصب نشده است!
    pause
    exit /b 1
)
echo ✅ Python موجود است

REM ایجاد محیط مجازی
if not exist ".venv" (
    echo 🔧 ایجاد محیط مجازی...
    python -m venv .venv
)

REM فعال‌سازی محیط مجازی
echo 🔄 فعال‌سازی محیط مجازی...
call .venv\Scripts\activate.bat

REM به‌روزرسانی pip
echo 📦 به‌روزرسانی pip...
python -m pip install --upgrade pip

REM حل مشکل pandas
echo 🔧 حل مشکل pandas...
pip uninstall pandas numpy -y > nul 2>&1
pip install numpy==1.24.3 --only-binary=all --no-cache-dir
pip install pandas==2.0.3 --only-binary=all --no-cache-dir

REM نصب بقیه پکیج‌ها
echo 📦 نصب پکیج‌ها...
if exist "requirements_windows.txt" (
    pip install -r requirements_windows.txt --only-binary=all --no-cache-dir
) else (
    pip install -r requirements.txt --only-binary=all --no-cache-dir
)

REM تست
echo 🧪 تست...
python -c "import pandas, numpy, streamlit, cv2; print('✅ آماده!')"
if %errorlevel% neq 0 (
    echo ❌ خطا در تست
    pause
    exit /b 1
)

echo.
echo 🎉 نصب تکمیل شد!
echo 🚀 اجرای برنامه: streamlit run app.py
echo.
pause

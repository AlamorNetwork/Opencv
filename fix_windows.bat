@echo off
chcp 65001 > nul
title حل مشکل pandas در ویندوز

echo.
echo ==========================================
echo    حل مشکل pandas در ویندوز
echo ==========================================
echo.

REM فعال‌سازی محیط مجازی
if exist ".venv\Scripts\activate.bat" (
    echo 🔄 فعال‌سازی محیط مجازی...
    call .venv\Scripts\activate.bat
) else if exist "venv\Scripts\activate.bat" (
    echo 🔄 فعال‌سازی محیط مجازی...
    call venv\Scripts\activate.bat
) else (
    echo ❌ محیط مجازی یافت نشد!
    pause
    exit /b 1
)

echo.
echo 🔧 حل مشکل pandas...

REM حذف pandas های مشکل‌دار
echo 🗑️ حذف pandas های مشکل‌دار...
pip uninstall pandas numpy -y > nul 2>&1

REM به‌روزرسانی pip
echo 📦 به‌روزرسانی pip...
python -m pip install --upgrade pip

REM نصب numpy ابتدا
echo 📦 نصب numpy...
pip install numpy==1.24.3 --only-binary=all --no-cache-dir

REM نصب pandas با precompiled wheel
echo 📦 نصب pandas...
pip install pandas==2.0.3 --only-binary=all --no-cache-dir

REM نصب سایر پکیج‌ها
echo 📦 نصب سایر پکیج‌ها...
pip install -r requirements_windows.txt --only-binary=all --no-cache-dir

REM تست
echo.
echo 🧪 تست پکیج‌ها...
python -c "import pandas as pd; import numpy as np; import streamlit as st; print('✅ همه پکیج‌ها آماده هستند!')" 2>nul
if %errorlevel% equ 0 (
    echo ✅ تست موفقیت‌آمیز!
) else (
    echo ❌ خطا در تست
    pause
    exit /b 1
)

echo.
echo 🎉 مشکل حل شد!
echo.
echo برای اجرای برنامه:
echo   streamlit run app.py
echo.
pause

# اسکریپت PowerShell برای نصب کامل در ویندوز

Write-Host "🚀 نصب کامل پلتفرم PDF به متن فارسی در ویندوز" -ForegroundColor Blue
Write-Host "================================================" -ForegroundColor Blue

# بررسی وجود Python
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✅ $pythonVersion" -ForegroundColor Green
}
catch {
    Write-Host "❌ Python نصب نشده است!" -ForegroundColor Red
    Write-Host "لطفا Python 3.8+ را از python.org نصب کنید" -ForegroundColor Yellow
    exit 1
}

# ایجاد محیط مجازی
Write-Host "🔧 بررسی محیط مجازی..." -ForegroundColor Blue
if (-not (Test-Path ".venv")) {
    Write-Host "ایجاد محیط مجازی جدید..." -ForegroundColor Yellow
    python -m venv .venv
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ خطا در ایجاد محیط مجازی" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ محیط مجازی ایجاد شد" -ForegroundColor Green
} else {
    Write-Host "✅ محیط مجازی موجود است" -ForegroundColor Green
}

# فعال‌سازی محیط مجازی
Write-Host "🔄 فعال‌سازی محیط مجازی..." -ForegroundColor Blue
& ".\.venv\Scripts\Activate.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ خطا در فعال‌سازی محیط مجازی" -ForegroundColor Red
    # تلاش برای تغییر execution policy
    Write-Host "تلاش برای تنظیم execution policy..." -ForegroundColor Yellow
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    & ".\.venv\Scripts\Activate.ps1"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ نمی‌توان محیط مجازی را فعال کرد" -ForegroundColor Red
        Write-Host "لطفاً دستور زیر را با دسترسی مدیر اجرا کنید:" -ForegroundColor Yellow
        Write-Host "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned" -ForegroundColor Cyan
        exit 1
    }
}

# به‌روزرسانی pip
Write-Host "📦 به‌روزرسانی pip..." -ForegroundColor Blue
python -m pip install --upgrade pip

# حل مشکل pandas
Write-Host "🔧 حل مشکل pandas و numpy..." -ForegroundColor Blue
pip uninstall pandas numpy -y | Out-Null
pip install numpy==1.24.3 --only-binary=all --no-cache-dir
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ خطا در نصب numpy" -ForegroundColor Red
    exit 1
}

pip install pandas==2.0.3 --only-binary=all --no-cache-dir  
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ خطا در نصب pandas" -ForegroundColor Red
    exit 1
}

# نصب سایر پکیج‌ها
Write-Host "📦 نصب سایر پکیج‌ها..." -ForegroundColor Blue
if (Test-Path "requirements_windows.txt") {
    pip install -r requirements_windows.txt --only-binary=all --no-cache-dir
} else {
    pip install -r requirements.txt --only-binary=all --no-cache-dir
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ خطا در نصب پکیج‌ها" -ForegroundColor Red
    exit 1
}

# تست
Write-Host "🧪 تست پکیج‌ها..." -ForegroundColor Blue
python -c "import pandas as pd; import numpy as np; import streamlit as st; import cv2; print('✅ همه پکیج‌ها آماده هستند!')"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ تست موفقیت‌آمیز!" -ForegroundColor Green
} else {
    Write-Host "❌ خطا در تست پکیج‌ها" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 نصب با موفقیت تکمیل شد!" -ForegroundColor Green
Write-Host "🚀 برای اجرای برنامه:" -ForegroundColor Blue
Write-Host "   streamlit run app.py" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 محیط مجازی فعال است. برای غیرفعال کردن: deactivate" -ForegroundColor Yellow

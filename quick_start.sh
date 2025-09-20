#!/bin/bash

# اجرای فوری و خودکار - بدون تعامل
# استفاده: bash quick_start.sh

set -e
export DEBIAN_FRONTEND=noninteractive

echo "⚡ اجرای فوری پلتفرم PDF به متن فارسی"
echo "======================================"

# Kill existing processes
pkill -f "streamlit run app.py" 2>/dev/null || true

# نصب سریع پکیج‌های ضروری
if ! command -v tesseract &> /dev/null; then
    echo "📦 نصب پکیج‌های ضروری..."
    apt-get update -y > /dev/null 2>&1
    apt-get install -y python3-pip tesseract-ocr tesseract-ocr-fas \
        libglib2.0-0 libsm6 libxext6 poppler-utils > /dev/null 2>&1
fi

# حل مشکل numpy/pandas
echo "🔧 حل مشکل ناسازگاری پکیج‌ها..."
pip3 uninstall numpy pandas streamlit -y > /dev/null 2>&1 || true
pip3 install numpy==1.24.3 pandas==2.0.3 > /dev/null 2>&1
pip3 install -r requirements.txt --no-cache-dir > /dev/null 2>&1

# تست سریع
python3 -c "import streamlit, cv2, pandas, numpy; print('✅ همه پکیج‌ها آماده')" 2>/dev/null

# اجرای برنامه در background
echo "🚀 اجرای برنامه..."
nohup python3 -m streamlit run app.py \
    --server.port=8501 \
    --server.address=0.0.0.0 \
    --server.headless=true \
    --server.runOnSave=false \
    > /dev/null 2>&1 &

# Wait for startup
sleep 8

# Check if running
if pgrep -f "streamlit run app.py" > /dev/null; then
    echo "🎉 برنامه با موفقیت اجرا شد!"
    echo "🌐 آدرس: http://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_SERVER_IP'):8501"
else
    echo "❌ خطا در اجرای برنامه"
    echo "📋 بررسی لاگ: python3 -m streamlit run app.py"
fi

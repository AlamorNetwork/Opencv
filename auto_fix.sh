#!/bin/bash

# اسکریپت حل خودکار مشکلات سرور - بدون تعامل با کاربر

set -e

export DEBIAN_FRONTEND=noninteractive

echo "🚀 شروع نصب خودکار پلتفرم PDF به متن فارسی"
echo "================================================"

# 1. نصب پکیج‌های سیستمی
echo "📦 نصب پکیج‌های سیستمی..."
apt-get update -y
apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    tesseract-ocr \
    tesseract-ocr-fas \
    poppler-utils \
    libpoppler-cpp-dev

# 2. ایجاد محیط مجازی (اگر وجود نداشته باشد)
if [ ! -d "venv" ]; then
    echo "🔧 ایجاد محیط مجازی..."
    python3 -m venv venv
fi

# 3. فعال‌سازی محیط مجازی
echo "🔄 فعال‌سازی محیط مجازی..."
source venv/bin/activate

# 4. به‌روزرسانی pip
echo "📦 به‌روزرسانی pip..."
pip install --upgrade pip

# 5. پاک کردن کش
echo "🗑️ پاک کردن کش pip..."
pip cache purge

# 6. حذف پکیج‌های مشکل‌دار
echo "🗑️ حذف پکیج‌های ناسازگار..."
pip uninstall numpy pandas streamlit plotly scipy scikit-learn -y 2>/dev/null || true

# 7. نصب نسخه‌های سازگار
echo "📦 نصب numpy نسخه سازگار..."
pip install numpy==1.24.3

echo "📦 نصب pandas نسخه سازگار..."
pip install pandas==2.0.3

# 8. نصب سایر وابستگی‌ها
echo "📦 نصب سایر وابستگی‌ها..."
pip install -r requirements.txt --no-cache-dir

# 9. تست سریع
echo "🧪 تست پکیج‌ها..."
python3 -c "
import numpy as np
import pandas as pd
import cv2
print('✅ numpy:', np.__version__)
print('✅ pandas:', pd.__version__)
print('✅ opencv:', cv2.__version__)
print('✅ همه پکیج‌ها آماده هستند!')
"

# 10. ایجاد فایل systemd service
echo "🔧 ایجاد سرویس systemd..."
cat > /etc/systemd/system/pdf-to-text.service << EOF
[Unit]
Description=PDF to Persian Text Platform
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$(pwd)
Environment=PATH=$(pwd)/venv/bin
ExecStart=$(pwd)/venv/bin/streamlit run app.py --server.port=8501 --server.address=0.0.0.0 --server.headless=true
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 11. فعال‌سازی سرویس
echo "🚀 فعال‌سازی سرویس..."
systemctl daemon-reload
systemctl enable pdf-to-text
systemctl start pdf-to-text

# 12. بررسی وضعیت
echo "✅ بررسی وضعیت سرویس..."
sleep 5
systemctl status pdf-to-text --no-pager

echo ""
echo "🎉 نصب تکمیل شد!"
echo "🌐 سرویس در آدرس http://YOUR_SERVER_IP:8501 در حال اجرا است"
echo ""
echo "دستورات مفید:"
echo "  systemctl status pdf-to-text    # بررسی وضعیت"
echo "  systemctl stop pdf-to-text      # متوقف کردن"
echo "  systemctl start pdf-to-text     # شروع مجدد"
echo "  systemctl restart pdf-to-text   # ری‌استارت"
echo "  journalctl -u pdf-to-text -f    # مشاهده لاگ‌ها"

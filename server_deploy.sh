#!/bin/bash

# Deploy خودکار روی سرور - بدون نیاز به تعامل
# استفاده: bash server_deploy.sh

set -e

echo "🚀 Deploy خودکار پلتفرم PDF به متن فارسی"
echo "=============================================="

# تنظیمات
export DEBIAN_FRONTEND=noninteractive
PORT=${PORT:-8501}
DOMAIN=${DOMAIN:-"localhost"}

# 1. چک کردن دسترسی root
if [[ $EUID -ne 0 ]]; then
   echo "❌ این اسکریپت باید با دسترسی root اجرا شود"
   echo "استفاده: sudo bash server_deploy.sh"
   exit 1
fi

echo "✅ دسترسی root تایید شد"

# 2. انتخاب روش deploy
echo ""
echo "🔧 انتخاب روش deploy:"
echo "1) استفاده از systemd service (پیشنهادی)"
echo "2) استفاده از Docker"
echo "3) اجرای ساده در background"

# در سرور، روش پیش‌فرض را انتخاب کنیم
DEPLOY_METHOD=1

case $DEPLOY_METHOD in
    1)
        echo "📦 Deploy با systemd service..."
        
        # نصب Python و وابستگی‌ها
        apt-get update -y
        apt-get install -y python3 python3-pip python3-venv \
            libglib2.0-0 libsm6 libxext6 libxrender-dev libgomp1 \
            tesseract-ocr tesseract-ocr-fas poppler-utils
        
        # ایجاد محیط مجازی
        if [ ! -d "venv" ]; then
            python3 -m venv venv
        fi
        
        source venv/bin/activate
        pip install --upgrade pip
        pip install numpy==1.24.3 pandas==2.0.3
        pip install -r requirements.txt --no-cache-dir
        
        # ایجاد systemd service
        cat > /etc/systemd/system/pdf-to-text.service << EOF
[Unit]
Description=PDF to Persian Text Platform
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$(pwd)
Environment=PATH=$(pwd)/venv/bin
ExecStart=$(pwd)/venv/bin/streamlit run app.py --server.port=${PORT} --server.address=0.0.0.0 --server.headless=true
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

        systemctl daemon-reload
        systemctl enable pdf-to-text
        systemctl restart pdf-to-text
        
        echo "✅ سرویس systemd ایجاد و فعال شد"
        ;;
        
    2)
        echo "🐳 Deploy با Docker..."
        
        # نصب Docker
        if ! command -v docker &> /dev/null; then
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
            rm get-docker.sh
        fi
        
        # نصب Docker Compose
        if ! command -v docker-compose &> /dev/null; then
            curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
        fi
        
        # اجرای container
        docker-compose down 2>/dev/null || true
        docker-compose build
        docker-compose up -d
        
        echo "✅ Docker container در حال اجرا"
        ;;
        
    3)
        echo "🔧 اجرای ساده در background..."
        
        apt-get update -y
        apt-get install -y python3 python3-pip \
            libglib2.0-0 libsm6 libxext6 tesseract-ocr tesseract-ocr-fas
        
        pip3 install numpy==1.24.3 pandas==2.0.3
        pip3 install -r requirements.txt --no-cache-dir
        
        # Kill existing processes
        pkill -f "streamlit run app.py" 2>/dev/null || true
        
        # Run in background
        nohup python3 -m streamlit run app.py \
            --server.port=${PORT} \
            --server.address=0.0.0.0 \
            --server.headless=true \
            > streamlit.log 2>&1 &
        
        echo "✅ برنامه در background در حال اجرا"
        ;;
esac

# 3. تست connection
echo ""
echo "🧪 تست اتصال..."
sleep 10

if curl -s http://localhost:${PORT}/_stcore/health > /dev/null; then
    echo "✅ سرویس به درستی در حال اجرا است"
else
    echo "⚠️ سرویس هنوز آماده نیست، چند ثانیه صبر کنید"
fi

# 4. اطلاعات نهایی
echo ""
echo "🎉 Deploy تکمیل شد!"
echo "🌐 دسترسی: http://${DOMAIN}:${PORT}"
echo ""

# دستورات مفید
case $DEPLOY_METHOD in
    1)
        echo "دستورات مفید:"
        echo "  systemctl status pdf-to-text      # وضعیت"
        echo "  systemctl restart pdf-to-text     # ری‌استارت"
        echo "  journalctl -u pdf-to-text -f      # لاگ‌ها"
        ;;
    2)
        echo "دستورات مفید:"
        echo "  docker-compose logs -f            # لاگ‌ها"
        echo "  docker-compose restart            # ری‌استارت"
        echo "  docker-compose down               # متوقف کردن"
        ;;
    3)
        echo "دستورات مفید:"
        echo "  tail -f streamlit.log              # لاگ‌ها"
        echo "  pkill -f streamlit                 # متوقف کردن"
        ;;
esac

echo ""
echo "✅ برای دسترسی از مرورگر به آدرس بالا بروید"

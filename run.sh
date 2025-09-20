#!/bin/bash

# تنظیم رنگ‌ها برای خروجی
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "=========================================="
echo "   پلتفرم تبدیل PDF به متن فارسی"
echo "=========================================="
echo ""

echo -e "${BLUE}📋 بررسی پیش‌نیازها...${NC}"

# بررسی نصب Python
if ! command -v python3 &> /dev/null; then
    if ! command -v python &> /dev/null; then
        echo -e "${RED}❌ Python نصب نشده است!${NC}"
        echo "لطفا Python 3.8+ را نصب کنید:"
        echo "  Ubuntu/Debian: sudo apt-get install python3 python3-pip python3-venv"
        echo "  CentOS/RHEL: sudo yum install python3 python3-pip"
        echo "  macOS: brew install python3"
        exit 1
    else
        PYTHON_CMD="python"
    fi
else
    PYTHON_CMD="python3"
fi

echo -e "${GREEN}✅ Python نصب شده است${NC}"

# بررسی وجود محیط مجازی
if [ ! -d "venv" ]; then
    echo -e "${BLUE}🔧 ایجاد محیط مجازی...${NC}"
    $PYTHON_CMD -m venv venv
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ خطا در ایجاد محیط مجازی${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ محیط مجازی ایجاد شد${NC}"
fi

# فعال‌سازی محیط مجازی
echo -e "${BLUE}🔄 فعال‌سازی محیط مجازی...${NC}"
source venv/bin/activate
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ خطا در فعال‌سازی محیط مجازی${NC}"
    exit 1
fi

# نصب وابستگی‌ها
echo -e "${BLUE}📦 بررسی و نصب وابستگی‌ها...${NC}"
pip install --upgrade pip
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ خطا در نصب وابستگی‌ها${NC}"
    exit 1
fi

echo -e "${GREEN}✅ تمام وابستگی‌ها نصب شدند${NC}"

# بررسی وابستگی‌های سیستمی
echo -e "${BLUE}🔍 بررسی وابستگی‌های سیستمی...${NC}"

# بررسی اینکه آیا در محیط headless هستیم
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo -e "${BLUE}🖥️  محیط headless تشخیص داده شد${NC}"
    echo "از opencv-python-headless استفاده می‌شود"
fi

# بررسی نصب Tesseract
echo -e "${BLUE}🔍 بررسی نصب Tesseract OCR...${NC}"
if ! command -v tesseract &> /dev/null; then
    echo -e "${YELLOW}⚠️  Tesseract OCR یافت نشد${NC}"
    echo ""
    echo "آیا می‌خواهید وابستگی‌های سیستمی را نصب کنید؟ (y/N)"
    read -p "پاسخ: " install_deps
    
    if [[ $install_deps =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🔧 نصب وابستگی‌های سیستمی...${NC}"
        if [ -f "install_system_deps.sh" ]; then
            bash install_system_deps.sh
        else
            echo -e "${RED}❌ فایل install_system_deps.sh یافت نشد${NC}"
            echo "برای نصب دستی Tesseract:"
            echo "  Ubuntu/Debian: sudo apt-get install tesseract-ocr tesseract-ocr-fas"
            echo "  CentOS/RHEL: sudo yum install tesseract tesseract-langpack-fas"
            echo "  macOS: brew install tesseract tesseract-lang"
        fi
    else
        echo ""
        echo "آیا می‌خواهید بدون Tesseract ادامه دهید؟ (y/N): "
        read -p "پاسخ: " continue_choice
        if [[ ! $continue_choice =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    echo -e "${GREEN}✅ Tesseract OCR نصب شده است${NC}"
    
    # بررسی پشتیبانی زبان فارسی
    if tesseract --list-langs 2>/dev/null | grep -q "fas"; then
        echo -e "${GREEN}✅ پشتیبانی زبان فارسی موجود است${NC}"
    else
        echo -e "${YELLOW}⚠️  بسته زبان فارسی نصب نشده است${NC}"
        echo "برای نصب بسته زبان فارسی:"
        echo "  Ubuntu/Debian: sudo apt-get install tesseract-ocr-fas"
        echo "  macOS: نیاز به دانلود دستی بسته زبان"
    fi
fi

echo ""
echo -e "${BLUE}🚀 راه‌اندازی سرور...${NC}"
echo ""
echo "برای متوقف کردن سرور از Ctrl+C استفاده کنید"
echo "سرور در آدرس http://localhost:8501 در حال اجرا است"
echo ""

# اجرای برنامه
streamlit run app.py --server.port=8501 --server.address=localhost

# غیرفعال‌سازی محیط مجازی در پایان
deactivate

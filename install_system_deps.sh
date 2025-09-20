#!/bin/bash

# اسکریپت نصب وابستگی‌های سیستمی برای پلتفرم تبدیل PDF به متن فارسی
# این اسکریپت پکیج‌های مورد نیاز برای OpenCV و Tesseract را نصب می‌کند

set -e

# رنگ‌ها برای خروجی
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 نصب وابستگی‌های سیستمی برای پلتفرم PDF به متن فارسی${NC}"
echo "========================================================"

# تشخیص توزیع لینوکس
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    OS=openSUSE
elif [ -f /etc/redhat-release ]; then
    OS=RedHat
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

echo -e "${BLUE}📋 سیستم شناسایی شده: ${OS} ${VER}${NC}"

# بروزرسانی فهرست بسته‌ها
echo -e "${BLUE}🔄 به‌روزرسانی فهرست بسته‌ها...${NC}"

if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    sudo apt-get update -y
    
    echo -e "${BLUE}📦 نصب پکیج‌های مورد نیاز برای OpenCV...${NC}"
    sudo apt-get install -y \
        libglib2.0-0 \
        libsm6 \
        libxext6 \
        libxrender-dev \
        libgomp1 \
        libglib2.0-dev \
        libgtk2.0-dev \
        pkg-config \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev
    
    echo -e "${BLUE}📖 نصب Tesseract OCR و پشتیبانی زبان فارسی...${NC}"
    sudo apt-get install -y \
        tesseract-ocr \
        tesseract-ocr-fas \
        libtesseract-dev
    
    # پکیج‌های اضافی برای PDF processing
    echo -e "${BLUE}📄 نصب پکیج‌های مورد نیاز برای پردازش PDF...${NC}"
    sudo apt-get install -y \
        poppler-utils \
        libpoppler-cpp-dev

elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Fedora"* ]]; then
    if command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
    else
        PKG_MANAGER="yum"
    fi
    
    echo -e "${BLUE}📦 نصب پکیج‌های مورد نیاز برای OpenCV...${NC}"
    sudo $PKG_MANAGER install -y \
        glib2-devel \
        libSM \
        libXext \
        libXrender \
        libgomp \
        gtk2-devel \
        pkgconfig \
        ffmpeg-devel \
        opencv-devel
    
    echo -e "${BLUE}📖 نصب Tesseract OCR...${NC}"
    sudo $PKG_MANAGER install -y tesseract tesseract-langpack-fas
    
    # نصب poppler برای PDF
    sudo $PKG_MANAGER install -y poppler-utils poppler-cpp-devel

elif [[ "$OS" == *"openSUSE"* ]]; then
    echo -e "${BLUE}📦 نصب پکیج‌های مورد نیاز برای OpenCV...${NC}"
    sudo zypper install -y \
        glib2-devel \
        libSM6 \
        libXext6 \
        libXrender1 \
        libgomp1 \
        gtk2-devel \
        pkg-config \
        ffmpeg-devel
    
    echo -e "${BLUE}📖 نصب Tesseract OCR...${NC}"
    sudo zypper install -y tesseract-ocr tesseract-ocr-traineddata-persian
    
    # نصب poppler
    sudo zypper install -y poppler-tools libpoppler-cpp0

elif [[ "$OS" == *"Arch"* ]]; then
    echo -e "${BLUE}📦 نصب پکیج‌های مورد نیاز برای OpenCV...${NC}"
    sudo pacman -Sy --noconfirm \
        glib2 \
        libsm \
        libxext \
        libxrender \
        openmp \
        gtk2 \
        pkgconf \
        ffmpeg
    
    echo -e "${BLUE}📖 نصب Tesseract OCR...${NC}"
    sudo pacman -Sy --noconfirm tesseract tesseract-data-fas
    
    # نصب poppler
    sudo pacman -Sy --noconfirm poppler

else
    echo -e "${YELLOW}⚠️  توزیع لینوکس شناسایی نشد. لطفاً پکیج‌های زیر را دستی نصب کنید:${NC}"
    echo "- Tesseract OCR + Persian language data"
    echo "- OpenCV system libraries (libGL, libSM, libXext, etc.)"
    echo "- Poppler utilities for PDF processing"
    exit 1
fi

# بررسی نصب موفقیت‌آمیز
echo -e "${BLUE}✅ بررسی نصب...${NC}"

if command -v tesseract &> /dev/null; then
    TESSERACT_VERSION=$(tesseract --version | head -n1)
    echo -e "${GREEN}✅ Tesseract نصب شده: ${TESSERACT_VERSION}${NC}"
    
    # بررسی پشتیبانی زبان فارسی
    if tesseract --list-langs 2>/dev/null | grep -q "fas"; then
        echo -e "${GREEN}✅ پشتیبانی زبان فارسی موجود است${NC}"
    else
        echo -e "${YELLOW}⚠️  زبان فارسی برای Tesseract یافت نشد${NC}"
    fi
else
    echo -e "${RED}❌ Tesseract نصب نشده است${NC}"
fi

if command -v pdfinfo &> /dev/null; then
    echo -e "${GREEN}✅ Poppler utilities نصب شده${NC}"
else
    echo -e "${YELLOW}⚠️  Poppler utilities نصب نشده (برای پردازش PDF لازم است)${NC}"
fi

echo ""
echo -e "${GREEN}🎉 نصب وابستگی‌های سیستمی تکمیل شد!${NC}"
echo -e "${BLUE}💡 اکنون می‌توانید پروژه Python را نصب و اجرا کنید:${NC}"
echo "   ./run.sh"
echo ""

# راهنمای عیب‌یابی
echo -e "${BLUE}🔍 در صورت بروز مشکل:${NC}"
echo "1. مطمئن شوید که تمام پکیج‌ها با موفقیت نصب شده‌اند"
echo "2. سیستم را ری‌استارت کنید (در صورت نیاز)"
echo "3. متغیرهای محیطی را بررسی کنید"
echo "4. از opencv-python-headless به جای opencv-python استفاده کنید"

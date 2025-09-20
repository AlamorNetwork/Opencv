# 🔧 راهنمای حل مشکل OpenCV در محیط Headless Linux

## ❌ مشکل
```
ImportError: libGL.so.1: cannot open shared object file: No such file or directory
```

## ✅ راه‌حل‌ها

### روش 1: استفاده از opencv-python-headless (پیشنهادی)

این کتابخانه برای محیط‌های بدون رابط گرافیکی طراحی شده:

```bash
# حذف opencv-python
pip uninstall opencv-python opencv-contrib-python

# نصب opencv-python-headless
pip install opencv-python-headless
```

### روش 2: نصب پکیج‌های سیستمی مورد نیاز

#### Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install -y \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libgtk2.0-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    pkg-config
```

#### CentOS/RHEL/Fedora:
```bash
sudo yum install -y \
    glib2-devel \
    libSM \
    libXext \
    libXrender \
    libgomp \
    gtk2-devel \
    pkgconfig \
    ffmpeg-devel
```

### روش 3: استفاده از اسکریپت خودکار

```bash
# اجرای اسکریپت نصب وابستگی‌های سیستمی
./install_system_deps.sh

# سپس اجرای برنامه
./run.sh
```

## 🔍 تشخیص محیط

برای تشخیص اینکه در محیط headless هستید:

```bash
echo $DISPLAY
# اگر خالی بود، در محیط headless هستید

# یا
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "Headless environment detected"
fi
```

## 🐳 برای Docker

اگر از Docker استفاده می‌کنید، این خطوط را به Dockerfile اضافه کنید:

```dockerfile
# پکیج‌های سیستمی
RUN apt-get update && apt-get install -y \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    tesseract-ocr \
    tesseract-ocr-fas \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

# استفاده از opencv-python-headless
RUN pip install opencv-python-headless
```

## ✅ تست عملکرد

بعد از حل مشکل، این کد را تست کنید:

```python
import cv2
import numpy as np

# ایجاد تصویر تست
img = np.zeros((100, 100, 3), dtype=np.uint8)
print("OpenCV works fine!")
print(f"OpenCV version: {cv2.__version__}")
```

## 🚀 راه‌اندازی سریع

```bash
# 1. حذف opencv-python
pip uninstall opencv-python -y

# 2. نصب opencv-python-headless
pip install opencv-python-headless

# 3. اجرای برنامه
streamlit run app.py
```

## 📞 پشتیبانی بیشتر

اگر همچنان مشکل دارید:

1. ✅ مطمئن شوید که `opencv-python-headless` نصب شده
2. ✅ تمام پکیج‌های سیستمی را نصب کنید
3. ✅ محیط مجازی را دوباره بسازید
4. ✅ سیستم را ری‌استارت کنید (در صورت نیاز)

---
**💡 نکته: opencv-python-headless برای محیط‌های سرور و Docker بهینه شده و نیازی به OpenGL ندارد.**

# استفاده از Python 3.10 slim image
FROM python:3.10-slim

# تنظیم متغیرهای محیطی
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV STREAMLIT_SERVER_HEADLESS=true
ENV STREAMLIT_SERVER_ADDRESS=0.0.0.0
ENV STREAMLIT_SERVER_PORT=8501

# تنظیم working directory
WORKDIR /app

# نصب پکیج‌های سیستمی
RUN apt-get update && apt-get install -y \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libgtk2.0-dev \
    pkg-config \
    tesseract-ocr \
    tesseract-ocr-fas \
    poppler-utils \
    libpoppler-cpp-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# کپی فایل requirements
COPY requirements.txt .

# نصب وابستگی‌های Python با نسخه‌های سازگار
RUN pip install --upgrade pip && \
    pip install numpy==1.24.3 && \
    pip install pandas==2.0.3 && \
    pip install --no-cache-dir -r requirements.txt

# کپی کدهای برنامه
COPY . .

# ایجاد پوشه‌های مورد نیاز
RUN mkdir -p temp output logs

# expose کردن پورت
EXPOSE 8501

# health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# دستور اجرای برنامه
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0", "--server.headless=true"]

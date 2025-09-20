# 📖 پلتفرم تبدیل PDF به متن فارسی

یک پلتفرم پیشرفته و حرفه‌ای برای تبدیل کتاب‌های PDF فارسی اسکن شده به متن قابل ویرایش با استفاده از تکنولوژی OCR.

## ✨ ویژگی‌های کلیدی

- 🔄 **تبدیل خودکار PDF به متن فارسی**
- 🖼️ **پردازش پیشرفته تصاویر با OpenCV**
- 🧠 **تشخیص دقیق متن فارسی با Tesseract OCR**
- 📊 **نمایش نتایج در جدول DataFrame**
- 📈 **آمار و تحلیل کیفیت تشخیص**
- 💾 **دانلود نتایج در فرمت‌های مختلف (CSV, Excel, TXT)**
- 🎨 **رابط کاربری زیبا و کاربردی**
- ⚡ **پردازش سریع با نمایش پیشرفت**

## 🛠️ نصب و راه‌اندازی

### پیش‌نیازها

1. **نصب Python 3.8+**
2. **نصب Tesseract OCR:**

#### در ویندوز:
```bash
# دانلود و نصب Tesseract از:
# https://github.com/UB-Mannheim/tesseract/wiki

# یا با Chocolatey:
choco install tesseract

# یا با Scoop:
scoop install tesseract
```

#### در Linux:
```bash
sudo apt-get update
sudo apt-get install tesseract-ocr tesseract-ocr-fas
```

#### در macOS:
```bash
brew install tesseract tesseract-lang
```

### نصب پروژه

1. **کلون پروژه:**
```bash
git clone [URL_REPOSITORY]
cd PDFTOTEXT
```

2. **ایجاد محیط مجازی:**
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# یا
venv\Scripts\activate     # Windows
```

3. **نصب وابستگی‌ها:**
```bash
pip install -r requirements.txt
```

4. **اجرای برنامه:**
```bash
streamlit run app.py
```

## 🚀 نحوه استفاده

### مرحله 1: آپلود فایل
- فایل PDF خود را در تب "آپلود فایل" بارگذاری کنید
- اطمینان حاصل کنید که فایل شامل تصاویر اسکن شده متن فارسی است

### مرحله 2: پردازش
- روی دکمه "🚀 شروع پردازش" کلیک کنید
- منتظر تکمیل پردازش بمانید (نوار پیشرفت نمایش داده می‌شود)

### مرحله 3: مشاهده نتایج
- به تب "نتایج پردازش" بروید
- متن استخراج شده از هر صفحه را مشاهده کنید
- آمار و کیفیت تشخیص را بررسی کنید

### مرحله 4: دانلود
- نتایج را در فرمت‌های مختلف دانلود کنید:
  - 📊 Excel (.xlsx)
  - 📄 CSV (.csv)
  - 📝 متن خام (.txt)

## 📊 آمار و گزارش‌گیری

تب "آمار و گزارش" شامل:
- نمودار توزیع کلمات در صفحات
- نمودار کیفیت تشخیص متن
- آمار تفصیلی (تعداد کلمات، خطوط، کاراکترها)

## ⚙️ تنظیمات پیشرفته

### تنظیم مسیر Tesseract (در صورت نیاز):
اگر Tesseract در مسیر استاندارد نصب نشده، خط زیر را در `app.py` فعال کنید:

```python
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
```

### بهینه‌سازی کیفیت OCR:
- از فایل‌های PDF با رزولوشن بالا (300+ DPI) استفاده کنید
- اطمینان حاصل کنید که متن در تصاویر واضح و خوانا است
- از فایل‌هایی با کنتراست مناسب استفاده کنید

## 🔧 ساختار پروژه

```
PDFTOTEXT/
│
├── app.py                      # فایل اصلی برنامه Streamlit
├── config.py                   # تنظیمات و کانفیگ‌ها
├── utils.py                    # تابع‌های کمکی
├── requirements.txt            # وابستگی‌های Python
├── install.py                  # نصب خودکار پروژه
├── install_system_deps.sh      # نصب وابستگی‌های سیستمی Linux
├── run.bat                     # اجرا در ویندوز
├── run.sh                      # اجرا در Linux/macOS  
├── opencv_fix.md              # راهنمای حل مشکل OpenCV
├── README.md                  # راهنمای کامل
├── LICENSE                    # مجوز MIT
├── .gitignore                 # فایل‌های نادیده گرفته شده
└── temp/                      # پوشه موقت (ایجاد خودکار)
    └── output/                # پوشه خروجی (ایجاد خودکار)
```

## 📋 وابستگی‌های اصلی

- `streamlit` - رابط کاربری وب
- `opencv-python-headless` - پردازش تصویر (نسخه headless برای سرورها)
- `pytesseract` - تشخیص نویسه
- `pandas` - مدیریت داده‌ها
- `pdf2image` - تبدیل PDF به تصویر
- `Pillow` - پردازش تصویر
- `plotly` - نمودارها و گرافیک‌ها

## 🎯 نکات مهم

### برای بهترین نتایج:
- ✅ از فایل‌های PDF با کیفیت بالا استفاده کنید
- ✅ اطمینان حاصل کنید که متن فارسی واضح و خوانا است
- ✅ فایل‌های بزرگ ممکن است زمان بیشتری نیاز داشته باشند
- ✅ اتصال اینترنت پایدار برای بهترین عملکرد

### محدودیت‌ها:
- ⚠️ کیفیت OCR به کیفیت تصویر اصلی وابسته است
- ⚠️ متن‌های دست‌نویس ممکن است به درستی تشخیص داده نشوند
- ⚠️ فایل‌های بسیار بزرگ ممکن است زمان زیادی نیاز داشته باشند

## 🔍 عیب‌یابی

### مشکلات رایج:

1. **خطا در OpenCV (محیط Linux headless):**
   ```
   ImportError: libGL.so.1: cannot open shared object file
   ```
   **راه‌حل:**
   ```bash
   # حذف opencv-python و نصب نسخه headless
   pip uninstall opencv-python -y
   pip install opencv-python-headless
   
   # یا استفاده از اسکریپت خودکار
   ./install_system_deps.sh
   ```

2. **خطا در تشخیص Tesseract:**
   - اطمینان حاصل کنید که Tesseract نصب شده است
   - مسیر tesseract را در کد تنظیم کنید
   - برای Linux: `sudo apt-get install tesseract-ocr tesseract-ocr-fas`

3. **کیفیت پایین تشخیص:**
   - کیفیت تصاویر PDF را بررسی کنید
   - از فایل‌هایی با کنتراست بهتر استفاده کنید
   - DPI فایل PDF باید حداقل 300 باشد

4. **خطا در تبدیل PDF:**
   - اطمینان حاصل کنید که فایل PDF آسیب ندیده است
   - فایل را با نرم‌افزار دیگری باز کنید تا از سلامت آن مطمئن شوید
   - پکیج poppler-utils را نصب کنید: `sudo apt-get install poppler-utils`

5. **مشکلات محیط Docker:**
   ```dockerfile
   RUN apt-get update && apt-get install -y \
       libglib2.0-0 libsm6 libxext6 libxrender-dev \
       tesseract-ocr tesseract-ocr-fas poppler-utils
   RUN pip install opencv-python-headless
   ```

## 📞 پشتیبانی

در صورت بروز مشکل یا نیاز به راهنمایی بیشتر، می‌توانید:
- Issues بخش GitHub را بررسی کنید
- مستندات Tesseract OCR را مطالعه کنید
- تنظیمات OpenCV را بهینه‌سازی کنید

## 🌟 ویژگی‌های آینده

- [ ] پشتیبانی از زبان‌های دیگر
- [ ] بهبود دقت تشخیص با AI
- [ ] پردازش batch چندین فایل همزمان
- [ ] ذخیره تاریخچه پردازش‌ها
- [ ] API برای استفاده از برنامه‌های دیگر

---

**ساخته شده با ❤️ برای جامعه توسعه‌دهندگان فارسی‌زبان**
"# Opencv" 

# 🖥️ پلتفرم تبدیل PDF به متن فارسی - ویندوز سرور

یک پلتفرم حرفه‌ای و پیشرفته مخصوص **ویندوز سرور** برای تبدیل کتاب‌های PDF فارسی اسکن شده به متن قابل ویرایش.

## 🏢 مخصوص محیط Enterprise و ویندوز سرور

این پلتفرم بطور خاص برای محیط‌های حرفه‌ای ویندوز سرور طراحی شده:
- 🏢 **Windows Server 2016/2019/2022**
- 🔧 **Windows Service مخصوص**
- 🌐 **قابلیت ادغام با IIS**
- 🔒 **امنیت Enterprise**
- 📊 **مانیتورینگ کامل**

## ✨ ویژگی‌های کلیدی

- 🔄 **تبدیل خودکار PDF به متن فارسی**
- 🖼️ **پردازش پیشرفته تصاویر با OpenCV**
- 🧠 **تشخیص دقیق متن فارسی با Tesseract OCR**
- 📊 **نمایش نتایج در جدول DataFrame**
- 📈 **آمار و تحلیل کیفیت تشخیص**
- 💾 **دانلود نتایج در فرمت‌های مختلف (CSV, Excel, TXT)**
- 🎨 **رابط کاربری زیبا و کاربردی**
- ⚡ **پردازش سریع با نمایش پیشرفت**
- 🏢 **اجرای پایدار به عنوان Windows Service**

## 🛠️ نصب و راه‌اندازی ویندوز سرور

### 🔧 پیش‌نیازها

1. **Windows Server 2016/2019/2022**
2. **Python 3.8+ برای ویندوز** - [دانلود از python.org](https://www.python.org/downloads/windows/)
3. **Tesseract OCR:** [دانلود از GitHub](https://github.com/UB-Mannheim/tesseract/wiki)
4. **دسترسی Administrator**

### ⚡ روش 1: نصب خودکار (پیشنهادی سرور)

**PowerShell با دسترسی Administrator:**
```powershell
.\Deploy-WindowsServer.ps1
```

### 🔧 روش 2: نصب ساده
```cmd
REM با دسترسی Administrator اجرا کنید:
windows_server_deploy.bat
```

### 📋 روش 3: نصب گام به گام

1. **دانلود پروژه:**
```cmd
git clone [URL_REPOSITORY]
cd PDFTOTEXT
```

2. **اجرای نصب:**
```cmd
setup_simple.bat
```

3. **بررسی نصب:**
```cmd
python -c "import streamlit; print('✅ آماده!')"
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

## 🔧 ساختار پروژه ویندوز سرور

```
PDFTOTEXT/
│
├── 🚀 app.py                          # برنامه اصلی Streamlit
├── ⚙️ config.py                       # تنظیمات و کانفیگ‌ها
├── 🛠️ utils.py                        # تابع‌های کمکی
├── 📦 requirements.txt                # وابستگی‌های Python
├── 🪟 requirements_windows.txt        # وابستگی‌های مخصوص ویندوز
├── 🔧 install.py                      # نصب خودکار پروژه
├── 🏢 Deploy-WindowsServer.ps1        # Deploy PowerShell حرفه‌ای
├── 🖥️ windows_server_deploy.bat       # Deploy ساده ویندوز سرور
├── 🪟 run.bat                         # اجرای معمولی در ویندوز
├── 🔧 setup_simple.bat                # نصب سریع
├── 🔧 setup_windows.ps1               # نصب PowerShell
├── 🩹 fix_windows.bat                 # حل مشکل pandas در ویندوز
├── 📖 README.md                      # راهنمای کامل
├── ⚖️ LICENSE                        # مجوز MIT
└── 🚫 .gitignore                     # فایل‌های نادیده گرفته شده
```

### 📁 پوشه‌های ایجاد شده (خودکار)
```
C:\PDFToText/                    # مسیر نصب سرور
├── venv/                        # محیط مجازی Python
├── temp/                        # فایل‌های موقت
├── output/                      # خروجی‌ها
├── service.py                   # Windows Service
└── service.log                  # لاگ سرویس
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

## 🔍 عیب‌یابی ویندوز سرور

### 🚨 مشکلات رایج و راه‌حل‌ها:

#### 1. **خطا در نصب pandas/numpy:**
```
error: Microsoft Visual Studio 14.0 is required
```
**راه‌حل:**
```cmd
fix_windows.bat
```
یا
```cmd
pip install numpy==1.24.3 --only-binary=all --no-cache-dir
pip install pandas==2.0.3 --only-binary=all --no-cache-dir
```

#### 2. **خطا در PowerShell Execution Policy:**
```
cannot be loaded because running scripts is disabled
```
**راه‌حل:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### 3. **خطا در Windows Service:**
```
Error 1053: The service did not respond to the start request
```
**راه‌حل:**
- بررسی لاگ: `C:\PDFToText\service.log`
- اجرای دستی: `python service.py debug`
- بررسی مسیر Python در service.py

#### 4. **خطا در تشخیص Tesseract:**
**راه‌حل:**
- نصب از [GitHub](https://github.com/UB-Mannheim/tesseract/wiki)
- افزودن به PATH یا تنظیم مسیر در `app.py`:
```python
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
```

#### 5. **مشکل دسترسی به پورت:**
**راه‌حل:**
- بررسی فایروال ویندوز
- بررسی پورت‌های در حال استفاده:
```cmd
netstat -an | findstr :8501
```

#### 6. **خطا در محیط مجازی:**
```
'venv\Scripts\activate' is not recognized
```
**راه‌حل:**
```cmd
python -m venv .venv
.venv\Scripts\activate.bat
```

## 🏢 مدیریت ویندوز سرور

### 🔧 مدیریت Windows Service

```cmd
# شروع سرویس
sc start PDFToTextService
net start PDFToTextService

# توقف سرویس
sc stop PDFToTextService
net stop PDFToTextService

# وضعیت سرویس
sc query PDFToTextService

# حذف سرویس
python "C:\PDFToText\service.py" remove
```

### 📊 مانیتورینگ

```powershell
# بررسی عملکرد
Get-Process | Where-Object {$_.ProcessName -like "*python*"}

# بررسی پورت
Get-NetTCPConnection -LocalPort 8501

# مشاهده لاگ‌ها
Get-Content "C:\PDFToText\service.log" -Wait
```

### 🔒 امنیت و دسترسی

```cmd
# تنظیم فایروال
netsh advfirewall firewall add rule name="PDF Platform" dir=in action=allow protocol=TCP localport=8501

# مدیریت دسترسی‌ها (از طریق IIS)
# Configuration در applicationHost.config
```

## 📞 پشتیبانی Enterprise

### 🔧 پشتیبانی فنی:
- 📧 **Email:** support@your-domain.com  
- 📞 **تلفن:** برای محیط‌های Enterprise
- 🌐 **Portal:** پنل مدیریت آنلاین

### 📋 مستندات:
- **Windows Event Viewer** - لاگ‌های سیستمی
- **Service Log** - `C:\PDFToText\service.log`
- **Application Logs** - Event Viewer > Applications

### 🛡️ امنیت:
- **HTTPS** - پیکربندی با IIS  
- **Authentication** - ادغام با AD/LDAP
- **Access Control** - کنترل دسترسی سطح Enterprise

## 🌟 ویژگی‌های آینده

- [ ] ادغام با Active Directory
- [ ] پشتیبانی HTTPS و SSL Certificate  
- [ ] Dashboard مدیریتی Enterprise
- [ ] API RESTful برای Integration
- [ ] پردازش Batch چندین فایل همزمان
- [ ] تحلیل AI پیشرفته و Machine Learning
- [ ] پشتیبانی زبان‌های اضافی (عربی، انگلیسی)
- [ ] Export به فرمت‌های بیشتر (Word, PowerPoint)

---

## 🎯 مناسب برای:

✅ **شرکت‌های بزرگ و سازمان‌ها**  
✅ **کتابخانه‌ها و مراکز اسناد**  
✅ **مراکز آرشیو و مستندات**  
✅ **دانشگاه‌ها و موسسات تحقیقاتی**  
✅ **سازمان‌های دولتی**  

**💼 ساخته شده برای محیط‌های حرفه‌ای Enterprise با کیفیت Production** 

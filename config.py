"""
تنظیمات و کانفیگ‌های پلتفرم تبدیل PDF به متن فارسی
"""
import os
from pathlib import Path

# مسیرهای پروژه
BASE_DIR = Path(__file__).parent
TEMP_DIR = BASE_DIR / "temp"
OUTPUT_DIR = BASE_DIR / "output"

# ایجاد پوشه‌های مورد نیاز
TEMP_DIR.mkdir(exist_ok=True)
OUTPUT_DIR.mkdir(exist_ok=True)

# تنظیمات Tesseract OCR
class TesseractConfig:
    # مسیرهای احتمالی Tesseract در سیستم‌عامل‌های مختلف
    TESSERACT_PATHS = {
        'windows': [
            r'C:\Program Files\Tesseract-OCR\tesseract.exe',
            r'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe',
            r'C:\Users\{}\AppData\Local\Programs\Tesseract-OCR\tesseract.exe'.format(os.getenv('USERNAME', '')),
        ],
        'linux': [
            '/usr/bin/tesseract',
            '/usr/local/bin/tesseract',
        ],
        'darwin': [  # macOS
            '/usr/local/bin/tesseract',
            '/opt/homebrew/bin/tesseract',
        ]
    }
    
    # زبان‌های پشتیبانی شده
    SUPPORTED_LANGUAGES = {
        'فارسی': 'fas',
        'عربی': 'ara',
        'انگلیسی': 'eng',
        'فارسی + انگلیسی': 'fas+eng',
    }
    
    # تنظیمات پردازش OCR
    OCR_CONFIG = {
        'oem': 3,  # OCR Engine Mode (3 = Default)
        'psm': 6,  # Page Segmentation Mode (6 = Uniform block of text)
        'dpi': 300,  # Resolution for PDF to image conversion
    }
    
    # کاراکترهای مجاز فارسی
    PERSIAN_WHITELIST = 'آابپتثجچحخدذرزژسشصضطظعغفقکگلمنوهی۰۱۲۳۴۵۶۷۸۹.,;:!?()[]{}"\' \n\t-'

# تنظیمات پردازش تصویر
class ImageProcessingConfig:
    # پارامترهای پیش‌پردازش تصویر
    BLUR_KERNEL_SIZE = 3
    CLAHE_CLIP_LIMIT = 2.0
    CLAHE_TILE_GRID_SIZE = (8, 8)
    CANNY_THRESHOLD1 = 50
    CANNY_THRESHOLD2 = 150
    MORPH_KERNEL_SIZE = (2, 2)
    
    # تنظیمات کیفیت تصویر
    MIN_IMAGE_WIDTH = 800
    MIN_IMAGE_HEIGHT = 600
    MAX_IMAGE_WIDTH = 4000
    MAX_IMAGE_HEIGHT = 4000

# تنظیمات رابط کاربری
class UIConfig:
    # تنظیمات Streamlit
    PAGE_TITLE = "پلتفرم تبدیل PDF به متن فارسی"
    PAGE_ICON = "📖"
    LAYOUT = "wide"
    
    # رنگ‌های UI
    COLORS = {
        'primary': '#667eea',
        'secondary': '#764ba2',
        'success': '#2ecc71',
        'warning': '#f39c12',
        'error': '#e74c3c',
        'info': '#3498db',
    }
    
    # پیام‌های کاربر
    MESSAGES = {
        'upload_success': "✅ فایل با موفقیت آپلود شد!",
        'processing_start': "🚀 شروع پردازش...",
        'processing_complete': "🎉 پردازش با موفقیت تکمیل شد!",
        'processing_error': "❌ خطا در پردازش فایل!",
        'no_file_uploaded': "⚠️ لطفا ابتدا یک فایل PDF آپلود کنید.",
        'no_results': "⚠️ هنوز فایلی پردازش نشده است!",
    }

# تنظیمات فایل و صادرات
class FileConfig:
    # انواع فایل‌های پشتیبانی شده
    SUPPORTED_FILE_TYPES = ['pdf']
    
    # حداکثر اندازه فایل (مگابایت)
    MAX_FILE_SIZE = 100
    
    # فرمت‌های خروجی
    OUTPUT_FORMATS = {
        'csv': {'extension': '.csv', 'mime': 'text/csv'},
        'excel': {'extension': '.xlsx', 'mime': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'},
        'txt': {'extension': '.txt', 'mime': 'text/plain'},
        'json': {'extension': '.json', 'mime': 'application/json'},
    }

# تنظیمات کیفیت OCR
class QualityConfig:
    # آستانه‌های کیفیت براساس تعداد کلمات
    QUALITY_THRESHOLDS = {
        'high': 100,    # بیش از 100 کلمه = کیفیت بالا
        'medium': 50,   # 50-100 کلمه = کیفیت متوسط
        'low': 0,       # کمتر از 50 کلمه = کیفیت پایین
    }
    
    # درصد اعتماد کیفیت
    CONFIDENCE_LEVELS = {
        'excellent': 90,
        'good': 70,
        'fair': 50,
        'poor': 30,
    }

# تنظیمات لاگ و دیباگ
class LogConfig:
    LOG_LEVEL = 'INFO'
    LOG_FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    LOG_FILE = BASE_DIR / 'logs' / 'app.log'
    
    # ایجاد پوشه لاگ
    LOG_FILE.parent.mkdir(exist_ok=True)

# تنظیمات کش و حافظه
class CacheConfig:
    # فعال/غیرفعال کردن کش
    ENABLE_CACHING = True
    
    # مدت زمان نگهداری کش (ثانیه)
    CACHE_TTL = 3600  # 1 ساعت
    
    # حداکثر اندازه کش (مگابایت)
    MAX_CACHE_SIZE = 500

# تابع یافتن مسیر Tesseract
def find_tesseract_path():
    """یافتن مسیر Tesseract در سیستم"""
    import platform
    import shutil
    
    # ابتدا تلاش برای یافتن خودکار
    tesseract_path = shutil.which('tesseract')
    if tesseract_path:
        return tesseract_path
    
    # یافتن براساس سیستم‌عامل
    system = platform.system().lower()
    if system == 'windows':
        paths = TesseractConfig.TESSERACT_PATHS['windows']
    elif system == 'linux':
        paths = TesseractConfig.TESSERACT_PATHS['linux']
    elif system == 'darwin':
        paths = TesseractConfig.TESSERACT_PATHS['darwin']
    else:
        return None
    
    # بررسی وجود هر مسیر
    for path in paths:
        if os.path.exists(path):
            return path
    
    return None

# تنظیم خودکار مسیر Tesseract
TESSERACT_PATH = find_tesseract_path()

# صادرات تنظیمات برای استفاده آسان
__all__ = [
    'TesseractConfig',
    'ImageProcessingConfig', 
    'UIConfig',
    'FileConfig',
    'QualityConfig',
    'LogConfig',
    'CacheConfig',
    'TESSERACT_PATH',
    'BASE_DIR',
    'TEMP_DIR',
    'OUTPUT_DIR',
]

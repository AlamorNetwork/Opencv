"""
تابع‌های کمکی برای پلتفرم تبدیل PDF به متن فارسی
"""
import logging
import re
import os
import tempfile
from pathlib import Path
from typing import Optional, Tuple, List
import cv2
import numpy as np
from PIL import Image
import streamlit as st
from config import LogConfig, QualityConfig, TESSERACT_PATH

# تنظیمات لاگ
logging.basicConfig(
    level=LogConfig.LOG_LEVEL,
    format=LogConfig.LOG_FORMAT,
    handlers=[
        logging.FileHandler(LogConfig.LOG_FILE, encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class TextProcessor:
    """کلاس پردازش و بهبود متن استخراج شده"""
    
    @staticmethod
    def clean_persian_text(text: str) -> str:
        """تمیز کردن و بهبود متن فارسی"""
        if not text:
            return ""
        
        # حذف کاراکترهای غیرضروری
        text = re.sub(r'[^\u0600-\u06FF\u0020-\u007E\u200C\u200D]', '', text)
        
        # اصلاح فاصله‌ها
        text = re.sub(r'\s+', ' ', text)
        
        # حذف خطوط خالی اضافی
        text = re.sub(r'\n\s*\n', '\n', text)
        
        # اصلاح نیم‌فاصله
        text = text.replace('ي', 'ی').replace('ك', 'ک')
        
        return text.strip()
    
    @staticmethod
    def extract_statistics(text: str) -> dict:
        """استخراج آمار از متن"""
        words = text.split()
        lines = text.split('\n')
        
        return {
            'word_count': len(words),
            'line_count': len(lines),
            'char_count': len(text),
            'char_count_no_spaces': len(text.replace(' ', '')),
            'avg_word_length': sum(len(word) for word in words) / len(words) if words else 0,
            'persian_word_count': len([word for word in words if re.search(r'[\u0600-\u06FF]', word)])
        }

class ImageEnhancer:
    """کلاس بهبود کیفیت تصویر برای OCR"""
    
    @staticmethod
    def enhance_image_quality(image: np.ndarray) -> np.ndarray:
        """بهبود کیفیت تصویر برای OCR بهتر"""
        # تبدیل به grayscale اگر رنگی است
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        else:
            gray = image.copy()
        
        # کاهش نویز
        denoised = cv2.fastNlMeansDenoising(gray)
        
        # بهبود کنتراست
        clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8,8))
        enhanced = clahe.apply(denoised)
        
        # شارپ کردن تصویر
        kernel = np.array([[-1,-1,-1], [-1,9,-1], [-1,-1,-1]])
        sharpened = cv2.filter2D(enhanced, -1, kernel)
        
        # تنظیم آستانه adaptive
        binary = cv2.adaptiveThreshold(
            sharpened, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, 
            cv2.THRESH_BINARY, 11, 2
        )
        
        return binary
    
    @staticmethod
    def preprocess_for_ocr(image: np.ndarray) -> List[np.ndarray]:
        """پیش‌پردازش تصویر با چندین روش مختلف"""
        processed_images = []
        
        # روش 1: پردازش استاندارد
        processed_images.append(ImageEnhancer.enhance_image_quality(image))
        
        # روش 2: تنظیم gamma
        gamma_corrected = ImageEnhancer._adjust_gamma(image, gamma=1.2)
        processed_images.append(gamma_corrected)
        
        # روش 3: تنظیم کنتراست
        contrasted = ImageEnhancer._adjust_contrast_brightness(image, alpha=1.3, beta=10)
        processed_images.append(contrasted)
        
        return processed_images
    
    @staticmethod
    def _adjust_gamma(image: np.ndarray, gamma: float = 1.0) -> np.ndarray:
        """تنظیم gamma correction"""
        invGamma = 1.0 / gamma
        table = np.array([((i / 255.0) ** invGamma) * 255 for i in np.arange(0, 256)]).astype("uint8")
        return cv2.LUT(image, table)
    
    @staticmethod
    def _adjust_contrast_brightness(image: np.ndarray, alpha: float = 1.0, beta: int = 0) -> np.ndarray:
        """تنظیم کنتراست و روشنایی"""
        return cv2.convertScaleAbs(image, alpha=alpha, beta=beta)

class QualityAssessment:
    """کلاس ارزیابی کیفیت OCR"""
    
    @staticmethod
    def assess_text_quality(text: str) -> dict:
        """ارزیابی کیفیت متن استخراج شده"""
        stats = TextProcessor.extract_statistics(text)
        
        # تعیین کیفیت براساس تعداد کلمات
        if stats['word_count'] >= QualityConfig.QUALITY_THRESHOLDS['high']:
            quality = 'بالا'
            confidence = 85
        elif stats['word_count'] >= QualityConfig.QUALITY_THRESHOLDS['medium']:
            quality = 'متوسط'  
            confidence = 65
        else:
            quality = 'پایین'
            confidence = 35
        
        # ارزیابی نسبت کلمات فارسی
        persian_ratio = stats['persian_word_count'] / stats['word_count'] if stats['word_count'] > 0 else 0
        
        # ارزیابی طول متوسط کلمات (کلمات فارسی معمولا طولانی‌ترند)
        avg_word_length_score = min(stats['avg_word_length'] / 5, 1.0) * 100
        
        return {
            'quality_level': quality,
            'confidence_score': confidence,
            'persian_ratio': persian_ratio * 100,
            'readability_score': avg_word_length_score,
            'statistics': stats
        }
    
    @staticmethod
    def calculate_overall_quality(pages_quality: List[dict]) -> dict:
        """محاسبه کیفیت کلی تمام صفحات"""
        if not pages_quality:
            return {'overall_quality': 'نامشخص', 'average_confidence': 0}
        
        total_confidence = sum(page['confidence_score'] for page in pages_quality)
        avg_confidence = total_confidence / len(pages_quality)
        
        high_quality_count = sum(1 for page in pages_quality if page['quality_level'] == 'بالا')
        high_quality_ratio = high_quality_count / len(pages_quality)
        
        if high_quality_ratio >= 0.7:
            overall = 'عالی'
        elif high_quality_ratio >= 0.4:
            overall = 'خوب'
        elif avg_confidence >= 50:
            overall = 'متوسط'
        else:
            overall = 'ضعیف'
        
        return {
            'overall_quality': overall,
            'average_confidence': avg_confidence,
            'high_quality_pages': high_quality_count,
            'total_pages': len(pages_quality),
            'high_quality_ratio': high_quality_ratio * 100
        }

class FileHandler:
    """کلاس مدیریت فایل‌ها"""
    
    @staticmethod
    def create_temp_file(content: bytes, suffix: str = '.pdf') -> str:
        """ایجاد فایل موقت"""
        try:
            with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp_file:
                tmp_file.write(content)
                return tmp_file.name
        except Exception as e:
            logger.error(f"خطا در ایجاد فایل موقت: {str(e)}")
            raise
    
    @staticmethod
    def cleanup_temp_file(file_path: str) -> bool:
        """حذف فایل موقت"""
        try:
            if os.path.exists(file_path):
                os.unlink(file_path)
                return True
            return False
        except Exception as e:
            logger.error(f"خطا در حذف فایل موقت: {str(e)}")
            return False
    
    @staticmethod
    def validate_pdf_file(file) -> Tuple[bool, str]:
        """اعتبارسنجی فایل PDF"""
        if file is None:
            return False, "فایل انتخاب نشده است"
        
        if not file.name.lower().endswith('.pdf'):
            return False, "فرمت فایل باید PDF باشد"
        
        file_size_mb = len(file.getvalue()) / 1024 / 1024
        if file_size_mb > 100:  # حداکثر 100 مگابایت
            return False, f"حجم فایل ({file_size_mb:.1f} MB) بیش از حد مجاز است"
        
        return True, "فایل معتبر است"

class SystemChecker:
    """کلاس بررسی سیستم و وابستگی‌ها"""
    
    @staticmethod
    def check_tesseract_installation() -> Tuple[bool, str]:
        """بررسی نصب Tesseract"""
        if TESSERACT_PATH and os.path.exists(TESSERACT_PATH):
            return True, f"Tesseract در مسیر {TESSERACT_PATH} یافت شد"
        else:
            return False, "Tesseract OCR نصب نشده است یا در مسیر قابل دسترسی نیست"
    
    @staticmethod
    def check_system_requirements() -> dict:
        """بررسی کامل سیستم"""
        checks = {}
        
        # بررسی Tesseract
        tesseract_ok, tesseract_msg = SystemChecker.check_tesseract_installation()
        checks['tesseract'] = {'status': tesseract_ok, 'message': tesseract_msg}
        
        # بررسی فضای دیسک
        import shutil
        free_space_gb = shutil.disk_usage('.').free / (1024**3)
        space_ok = free_space_gb > 1.0  # حداقل 1 گیگابایت
        checks['disk_space'] = {
            'status': space_ok, 
            'message': f"فضای آزاد: {free_space_gb:.1f} GB"
        }
        
        # بررسی پوشه‌های موقت
        from config import TEMP_DIR, OUTPUT_DIR
        temp_ok = TEMP_DIR.exists() and os.access(TEMP_DIR, os.W_OK)
        output_ok = OUTPUT_DIR.exists() and os.access(OUTPUT_DIR, os.W_OK)
        
        checks['temp_directory'] = {
            'status': temp_ok,
            'message': "پوشه موقت قابل دسترسی است" if temp_ok else "مشکل در دسترسی به پوشه موقت"
        }
        
        checks['output_directory'] = {
            'status': output_ok,
            'message': "پوشه خروجی قابل دسترسی است" if output_ok else "مشکل در دسترسی به پوشه خروجی"
        }
        
        return checks

class ProgressTracker:
    """کلاس ردیابی پیشرفت عملیات"""
    
    def __init__(self, total_steps: int, description: str = "در حال پردازش..."):
        self.total_steps = total_steps
        self.current_step = 0
        self.description = description
        self.progress_bar = st.progress(0, text=description)
    
    def update(self, step: int = None, message: str = None):
        """به‌روزرسانی پیشرفت"""
        if step is not None:
            self.current_step = step
        else:
            self.current_step += 1
        
        progress = min(self.current_step / self.total_steps, 1.0)
        display_message = message or f"{self.description} ({self.current_step}/{self.total_steps})"
        
        self.progress_bar.progress(progress, text=display_message)
    
    def complete(self, message: str = "تکمیل شد"):
        """تکمیل پردازش"""
        self.progress_bar.progress(1.0, text=message)

def format_file_size(size_bytes: int) -> str:
    """فرمت کردن اندازه فایل"""
    if size_bytes == 0:
        return "0 B"
    
    size_names = ["B", "KB", "MB", "GB", "TB"]
    import math
    i = int(math.floor(math.log(size_bytes, 1024)))
    p = math.pow(1024, i)
    s = round(size_bytes / p, 2)
    return f"{s} {size_names[i]}"

def create_download_excel(df, filename: str = "نتایج_PDF_به_متن"):
    """ایجاد فایل Excel برای دانلود"""
    import io
    import pandas as pd
    
    output = io.BytesIO()
    
    with pd.ExcelWriter(output, engine='xlsxwriter') as writer:
        # نوشتن داده‌ها
        df.to_excel(writer, index=False, sheet_name='نتایج_OCR')
        
        # دریافت workbook و worksheet
        workbook = writer.book
        worksheet = writer.sheets['نتایج_OCR']
        
        # فرمت‌بندی هدرها
        header_format = workbook.add_format({
            'bold': True,
            'text_wrap': True,
            'valign': 'top',
            'fg_color': '#D7E4BC',
            'border': 1
        })
        
        # اعمال فرمت به هدرها
        for col_num, value in enumerate(df.columns.values):
            worksheet.write(0, col_num, value, header_format)
        
        # تنظیم عرض ستون‌ها
        worksheet.set_column('A:A', 10)  # صفحه
        worksheet.set_column('B:B', 50)  # متن استخراج شده
        worksheet.set_column('C:E', 15)  # سایر ستون‌ها
    
    return output.getvalue()

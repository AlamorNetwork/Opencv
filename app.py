import streamlit as st
import cv2
import numpy as np
import pandas as pd
import pytesseract
from PIL import Image
import pdf2image
import io
import base64
from streamlit_option_menu import option_menu
import plotly.express as px
import tempfile
import os

# تنظیمات صفحه
st.set_page_config(
    page_title="پلتفرم تبدیل PDF به متن فارسی",
    page_icon="📖",
    layout="wide",
    initial_sidebar_state="expanded"
)

# تنظیم مسیر Tesseract (در صورت نیاز)
# pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

class PDFToTextConverter:
    def __init__(self):
        self.processed_data = []
    
    def preprocess_image(self, image):
        """پیش پردازش تصویر برای بهبود OCR"""
        # تبدیل به grayscale
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # کاهش نویز
        denoised = cv2.medianBlur(gray, 3)
        
        # بهبود کنتراست
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
        enhanced = clahe.apply(denoised)
        
        # تشخیص لبه و تنظیم آستانه
        edges = cv2.Canny(enhanced, 50, 150)
        kernel = np.ones((2,2), np.uint8)
        processed = cv2.morphologyEx(edges, cv2.MORPH_CLOSE, kernel)
        
        # تبدیل به binary
        _, binary = cv2.threshold(enhanced, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        
        return binary
    
    def extract_text_from_image(self, image, lang='fas'):
        """استخراج متن از تصویر"""
        try:
            # پیش پردازش تصویر
            processed_image = self.preprocess_image(image)
            
            # تنظیمات Tesseract برای فارسی
            config = '--oem 3 --psm 6 -c tessedit_char_whitelist=آابپتثجچحخدذرزژسشصضطظعغفقکگلمنوهی'
            
            # استخراج متن
            text = pytesseract.image_to_string(
                processed_image, 
                lang=lang, 
                config=config
            )
            
            return text.strip()
        except Exception as e:
            st.error(f"خطا در استخراج متن: {str(e)}")
            return ""
    
    def convert_pdf_to_images(self, pdf_file):
        """تبدیل PDF به تصاویر"""
        try:
            # ذخیره موقت فایل PDF
            with tempfile.NamedTemporaryFile(delete=False, suffix='.pdf') as tmp_file:
                tmp_file.write(pdf_file.read())
                tmp_path = tmp_file.name
            
            # تبدیل PDF به تصاویر
            images = pdf2image.convert_from_path(tmp_path, dpi=300)
            
            # حذف فایل موقت
            os.unlink(tmp_path)
            
            return images
        except Exception as e:
            st.error(f"خطا در تبدیل PDF: {str(e)}")
            return []
    
    def process_pdf(self, pdf_file, progress_bar):
        """پردازش کامل PDF و تبدیل به DataFrame"""
        self.processed_data = []
        
        # تبدیل PDF به تصاویر
        images = self.convert_pdf_to_images(pdf_file)
        
        if not images:
            return pd.DataFrame()
        
        total_pages = len(images)
        
        for i, pil_image in enumerate(images):
            # به روزرسانی نوار پیشرفت
            progress = (i + 1) / total_pages
            progress_bar.progress(progress, text=f"پردازش صفحه {i + 1} از {total_pages}")
            
            # تبدیل PIL به OpenCV
            opencv_image = cv2.cvtColor(np.array(pil_image), cv2.COLOR_RGB2BGR)
            
            # استخراج متن
            extracted_text = self.extract_text_from_image(opencv_image)
            
            # ذخیره داده‌ها
            self.processed_data.append({
                'صفحه': i + 1,
                'متن_استخراج_شده': extracted_text,
                'تعداد_کلمات': len(extracted_text.split()),
                'تعداد_خطوط': len(extracted_text.split('\n')),
                'کیفیت_تشخیص': 'بالا' if len(extracted_text) > 100 else 'متوسط' if len(extracted_text) > 50 else 'پایین'
            })
        
        return pd.DataFrame(self.processed_data)

def create_download_link(df, filename):
    """ایجاد لینک دانلود برای DataFrame"""
    csv = df.to_csv(index=False, encoding='utf-8-sig')
    b64 = base64.b64encode(csv.encode('utf-8-sig')).decode()
    href = f'<a href="data:file/csv;base64,{b64}" download="{filename}.csv">📥 دانلود فایل CSV</a>'
    return href

def main():
    # هدر اصلی
    st.markdown("""
    <div style="text-align: center; padding: 20px; background: linear-gradient(90deg, #667eea 0%, #764ba2 100%); border-radius: 10px; margin-bottom: 30px;">
        <h1 style="color: white; font-size: 2.5rem; margin: 0;">📖 پلتفرم تبدیل PDF به متن فارسی</h1>
        <p style="color: white; font-size: 1.2rem; margin: 10px 0 0 0;">تبدیل کتاب‌های اسکن شده به متن قابل ویرایش</p>
    </div>
    """, unsafe_allow_html=True)
    
    # منوی کناری
    with st.sidebar:
        st.markdown("### ⚙️ تنظیمات")
        selected = option_menu(
            menu_title=None,
            options=["آپلود فایل", "نتایج پردازش", "آمار و گزارش"],
            icons=['cloud-upload', 'file-text', 'bar-chart'],
            default_index=0,
            orientation="vertical"
        )
    
    # ایجاد instance از converter
    converter = PDFToTextConverter()
    
    if selected == "آپلود فایل":
        col1, col2 = st.columns([2, 1])
        
        with col1:
            st.markdown("### 📁 آپلود فایل PDF")
            uploaded_file = st.file_uploader(
                "فایل PDF خود را انتخاب کنید",
                type=['pdf'],
                help="فایل PDF باید شامل تصاویر اسکن شده متن فارسی باشد"
            )
            
            if uploaded_file is not None:
                st.success(f"✅ فایل {uploaded_file.name} با موفقیت آپلود شد!")
                
                # نمایش اطلاعات فایل
                file_size = len(uploaded_file.getvalue()) / 1024 / 1024
                st.info(f"📏 حجم فایل: {file_size:.2f} مگابایت")
                
                if st.button("🚀 شروع پردازش", use_container_width=True):
                    with st.spinner("در حال پردازش..."):
                        # نوار پیشرفت
                        progress_bar = st.progress(0, text="آماده‌سازی...")
                        
                        # پردازش PDF
                        df_result = converter.process_pdf(uploaded_file, progress_bar)
                        
                        if not df_result.empty:
                            st.session_state['processed_df'] = df_result
                            st.success("🎉 پردازش با موفقیت تکمیل شد!")
                            st.balloons()
                        else:
                            st.error("❌ خطا در پردازش فایل!")
        
        with col2:
            st.markdown("### 💡 راهنمای استفاده")
            st.markdown("""
            **مراحل کار:**
            1. 📤 فایل PDF را آپلود کنید
            2. ⚡ روی دکمه پردازش کلیک کنید  
            3. ⏳ منتظر تکمیل پردازش بمانید
            4. 📊 نتایج را در تب "نتایج پردازش" ببینید
            
            **نکات مهم:**
            - کیفیت تصاویر باید مناسب باشد
            - متن فارسی باید خوانا باشد
            - فایل‌های بزرگ ممکن است زمان بیشتری نیاز داشته باشند
            """)
    
    elif selected == "نتایج پردازش":
        if 'processed_df' in st.session_state and not st.session_state['processed_df'].empty:
            df = st.session_state['processed_df']
            
            st.markdown("### 📊 نتایج پردازش")
            
            # خلاصه آماری
            col1, col2, col3, col4 = st.columns(4)
            
            with col1:
                st.metric("تعداد صفحات", len(df))
            
            with col2:
                total_words = df['تعداد_کلمات'].sum()
                st.metric("کل کلمات", f"{total_words:,}")
            
            with col3:
                avg_words = df['تعداد_کلمات'].mean()
                st.metric("متوسط کلمات در صفحه", f"{avg_words:.0f}")
            
            with col4:
                high_quality = len(df[df['کیفیت_تشخیص'] == 'بالا'])
                st.metric("صفحات با کیفیت بالا", high_quality)
            
            # نمایش جدول
            st.markdown("### 📋 جزئیات هر صفحه")
            st.dataframe(
                df,
                use_container_width=True,
                height=400,
                column_config={
                    'صفحه': st.column_config.NumberColumn('شماره صفحه'),
                    'متن_استخراج_شده': st.column_config.TextColumn('متن استخراج شده', width='large'),
                    'تعداد_کلمات': st.column_config.NumberColumn('تعداد کلمات'),
                    'تعداد_خطوط': st.column_config.NumberColumn('تعداد خطوط'),
                    'کیفیت_تشخیص': st.column_config.SelectboxColumn('کیفیت تشخیص')
                }
            )
            
            # دکمه‌های دانلود
            col1, col2, col3 = st.columns(3)
            
            with col1:
                st.markdown(create_download_link(df, "نتایج_PDF_به_متن"), unsafe_allow_html=True)
            
            with col2:
                if st.button("📄 دانلود متن خام"):
                    full_text = '\n\n--- صفحه جدید ---\n\n'.join(df['متن_استخراج_شده'])
                    st.download_button(
                        label="💾 ذخیره متن کامل",
                        data=full_text,
                        file_name="متن_کامل.txt",
                        mime="text/plain"
                    )
            
            with col3:
                excel_buffer = io.BytesIO()
                with pd.ExcelWriter(excel_buffer, engine='xlsxwriter') as writer:
                    df.to_excel(writer, index=False, sheet_name='نتایج')
                st.download_button(
                    label="📊 دانلود Excel",
                    data=excel_buffer.getvalue(),
                    file_name="نتایج_PDF_به_متن.xlsx",
                    mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                )
        
        else:
            st.warning("⚠️ هنوز فایلی پردازش نشده است! لطفا ابتدا یک فایل PDF آپلود و پردازش کنید.")
    
    elif selected == "آمار و گزارش":
        if 'processed_df' in st.session_state and not st.session_state['processed_df'].empty:
            df = st.session_state['processed_df']
            
            st.markdown("### 📈 تحلیل آماری نتایج")
            
            col1, col2 = st.columns(2)
            
            with col1:
                # نمودار توزیع کلمات در صفحات
                fig1 = px.bar(
                    df, 
                    x='صفحه', 
                    y='تعداد_کلمات',
                    title="توزیع تعداد کلمات در صفحات",
                    color='کیفیت_تشخیص',
                    color_discrete_map={
                        'بالا': '#2ecc71',
                        'متوسط': '#f39c12', 
                        'پایین': '#e74c3c'
                    }
                )
                fig1.update_layout(xaxis_title="شماره صفحه", yaxis_title="تعداد کلمات")
                st.plotly_chart(fig1, use_container_width=True)
            
            with col2:
                # نمودار دایره‌ای کیفیت تشخیص
                quality_counts = df['کیفیت_تشخیص'].value_counts()
                fig2 = px.pie(
                    values=quality_counts.values,
                    names=quality_counts.index,
                    title="توزیع کیفیت تشخیص متن",
                    color_discrete_map={
                        'بالا': '#2ecc71',
                        'متوسط': '#f39c12', 
                        'پایین': '#e74c3c'
                    }
                )
                st.plotly_chart(fig2, use_container_width=True)
            
            # آمار تفصیلی
            st.markdown("### 📊 آمار تفصیلی")
            
            col1, col2, col3 = st.columns(3)
            
            with col1:
                st.markdown("**آمار کلمات:**")
                st.write(f"• حداکثر کلمات در یک صفحه: {df['تعداد_کلمات'].max()}")
                st.write(f"• حداقل کلمات در یک صفحه: {df['تعداد_کلمات'].min()}")
                st.write(f"• میانه تعداد کلمات: {df['تعداد_کلمات'].median()}")
            
            with col2:
                st.markdown("**آمار خطوط:**")
                st.write(f"• حداکثر خطوط در یک صفحه: {df['تعداد_خطوط'].max()}")
                st.write(f"• حداقل خطوط در یک صفحه: {df['تعداد_خطوط'].min()}")
                st.write(f"• متوسط خطوط در صفحه: {df['تعداد_خطوط'].mean():.1f}")
            
            with col3:
                st.markdown("**کیفیت کلی:**")
                high_quality_percent = (len(df[df['کیفیت_تشخیص'] == 'بالا']) / len(df)) * 100
                st.write(f"• درصد صفحات با کیفیت بالا: {high_quality_percent:.1f}%")
                total_chars = sum(len(text) for text in df['متن_استخراج_شده'])
                st.write(f"• کل کاراکترهای تشخیص داده شده: {total_chars:,}")
        
        else:
            st.warning("⚠️ هنوز فایلی پردازش نشده است! لطفا ابتدا یک فایل PDF آپلود و پردازش کنید.")

    # فوتر
    st.markdown("---")
    st.markdown("""
    <div style="text-align: center; color: #666; padding: 20px;">
        <p>🔧 ساخته شده با استفاده از Python، OpenCV، Tesseract OCR و Streamlit</p>
        <p>💡 برای بهترین نتایج، از فایل‌های PDF با کیفیت بالا استفاده کنید</p>
    </div>
    """, unsafe_allow_html=True)

if __name__ == "__main__":
    main()

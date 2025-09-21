@echo off
chcp 65001 > nul
title Deploy پلتفرم PDF به متن فارسی - ویندوز سرور

echo.
echo =============================================
echo    Deploy ویندوز سرور - حرفه‌ای
echo =============================================
echo.

REM بررسی دسترسی مدیر
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ لطفا این فایل را با دسترسی Administrator اجرا کنید
    echo راست کلیک کنید و "Run as administrator" را انتخاب کنید
    pause
    exit /b 1
)

echo ✅ دسترسی مدیر تایید شد

REM بررسی Python
echo 📋 بررسی Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python نصب نشده است!
    echo لطفا Python 3.8+ را از python.org نصب کنید
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo ✅ %PYTHON_VERSION%

REM ایجاد پوشه سرویس
set SERVICE_DIR=C:\PDFToText
if not exist "%SERVICE_DIR%" (
    echo 📁 ایجاد پوشه سرویس...
    mkdir "%SERVICE_DIR%"
)

REM کپی فایل‌ها
echo 📋 کپی فایل‌های پروژه...
xcopy /E /Y /I /Q "." "%SERVICE_DIR%" >nul
cd /d "%SERVICE_DIR%"

REM ایجاد محیط مجازی
if not exist "venv" (
    echo 🔧 ایجاد محیط مجازی...
    python -m venv venv
)

REM فعال‌سازی محیط مجازی
echo 🔄 فعال‌سازی محیط مجازی...
call venv\Scripts\activate.bat

REM به‌روزرسانی pip
echo 📦 به‌روزرسانی pip...
python -m pip install --upgrade pip >nul

REM نصب پکیج‌ها
echo 🔧 نصب پکیج‌های مورد نیاز...
pip uninstall pandas numpy -y >nul 2>&1
pip install numpy==1.24.3 --only-binary=all --no-cache-dir >nul
pip install pandas==2.0.3 --only-binary=all --no-cache-dir >nul

if exist "requirements_windows.txt" (
    pip install -r requirements_windows.txt --only-binary=all --no-cache-dir >nul
) else (
    pip install -r requirements.txt --only-binary=all --no-cache-dir >nul
)

REM تست نصب
echo 🧪 تست پکیج‌ها...
python -c "import pandas, numpy, streamlit, cv2; print('✅ همه پکیج‌ها آماده!')" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ خطا در نصب پکیج‌ها
    pause
    exit /b 1
)

REM ایجاد Windows Service
echo 🔧 ایجاد Windows Service...

REM ایجاد فایل service
echo import win32serviceutil > service.py
echo import win32service >> service.py
echo import win32event >> service.py
echo import servicemanager >> service.py
echo import subprocess >> service.py
echo import sys >> service.py
echo import os >> service.py
echo import time >> service.py
echo. >> service.py
echo class PDFToTextService(win32serviceutil.ServiceFramework): >> service.py
echo     _svc_name_ = "PDFToTextService" >> service.py
echo     _svc_display_name_ = "PDF to Persian Text Platform" >> service.py
echo     _svc_description_ = "پلتفرم تبدیل PDF به متن فارسی" >> service.py
echo. >> service.py
echo     def __init__(self, args): >> service.py
echo         win32serviceutil.ServiceFramework.__init__(self, args) >> service.py
echo         self.hWaitStop = win32event.CreateEvent(None, 0, 0, None) >> service.py
echo         self.process = None >> service.py
echo. >> service.py
echo     def SvcStop(self): >> service.py
echo         self.ReportServiceStatus(win32service.SERVICE_STOP_PENDING) >> service.py
echo         if self.process: >> service.py
echo             self.process.terminate() >> service.py
echo         win32event.SetEvent(self.hWaitStop) >> service.py
echo. >> service.py
echo     def SvcDoRun(self): >> service.py
echo         servicemanager.LogMsg(servicemanager.EVENTLOG_INFORMATION_TYPE, >> service.py
echo                              servicemanager.PYS_SERVICE_STARTED, >> service.py
echo                              (self._svc_name_, '')) >> service.py
echo         self.main() >> service.py
echo. >> service.py
echo     def main(self): >> service.py
echo         os.chdir(r'%SERVICE_DIR%') >> service.py
echo         python_exe = r'%SERVICE_DIR%\venv\Scripts\python.exe' >> service.py
echo         cmd = [python_exe, '-m', 'streamlit', 'run', 'app.py', >> service.py
echo                '--server.port=8501', '--server.address=0.0.0.0', >> service.py
echo                '--server.headless=true'] >> service.py
echo         self.process = subprocess.Popen(cmd) >> service.py
echo         while True: >> service.py
echo             if win32event.WaitForSingleObject(self.hWaitStop, 5000) == win32event.WAIT_OBJECT_0: >> service.py
echo                 break >> service.py
echo. >> service.py
echo if __name__ == '__main__': >> service.py
echo     win32serviceutil.HandleCommandLine(PDFToTextService) >> service.py

REM نصب pywin32 برای service
echo 📦 نصب پکیج service...
pip install pywin32 >nul 2>&1

REM نصب service
echo 🔧 نصب Windows Service...
python service.py install >nul 2>&1

REM شروع service
echo 🚀 شروع سرویس...
python service.py start >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ سرویس با موفقیت شروع شد
) else (
    echo ⚠️ سرویس نصب شد اما ممکن است نیاز به شروع دستی داشته باشد
)

REM تنظیم فایروال (اختیاری)
echo 🔒 تنظیم فایروال...
netsh advfirewall firewall add rule name="PDF to Text Platform" dir=in action=allow protocol=TCP localport=8501 >nul 2>&1

REM نمایش اطلاعات
echo.
echo ========================================
echo 🎉 Deploy با موفقیت تکمیل شد!
echo ========================================
echo.
echo 📍 مسیر نصب: %SERVICE_DIR%
echo 🌐 آدرس دسترسی: http://localhost:8501
echo 🌐 دسترسی از خارج: http://YOUR_SERVER_IP:8501
echo.
echo 🔧 مدیریت سرویس:
echo   - شروع: sc start PDFToTextService
echo   - توقف: sc stop PDFToTextService  
echo   - وضعیت: sc query PDFToTextService
echo   - حذف: python "%SERVICE_DIR%\service.py" remove
echo.
echo 📋 لاگ سرویس در Windows Event Viewer قابل مشاهده است
echo.

pause

#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Deploy پلتفرم PDF به متن فارسی روی ویندوز سرور
.DESCRIPTION
    اسکریپت کامل deploy برای ویندوز سرور شامل:
    - نصب خودکار پکیج‌ها
    - ایجاد Windows Service
    - تنظیم IIS reverse proxy
    - تنظیم فایروال
.PARAMETER Port
    پورت سرویس (پیش‌فرض: 8501)
.PARAMETER ServicePath
    مسیر نصب سرویس (پیش‌فرض: C:\PDFToText)
.PARAMETER SetupIIS
    تنظیم IIS به عنوان reverse proxy
#>

param(
    [int]$Port = 8501,
    [string]$ServicePath = "C:\PDFToText",
    [switch]$SetupIIS
)

# تنظیمات
$ErrorActionPreference = "Stop"
$ServiceName = "PDFToTextService"
$ServiceDisplayName = "PDF to Persian Text Platform"

# توابع کمکی
function Write-ColoredOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Prerequisites {
    Write-ColoredOutput "📦 بررسی پیش‌نیازها..." "Blue"
    
    # بررسی Python
    try {
        $pythonVersion = python --version 2>&1
        Write-ColoredOutput "✅ $pythonVersion" "Green"
    }
    catch {
        Write-ColoredOutput "❌ Python نصب نشده است!" "Red"
        Write-ColoredOutput "لطفا Python 3.8+ را از python.org نصب کنید" "Yellow"
        exit 1
    }
    
    # بررسی pip
    try {
        pip --version | Out-Null
        Write-ColoredOutput "✅ pip موجود است" "Green"
    }
    catch {
        Write-ColoredOutput "❌ pip یافت نشد!" "Red"
        exit 1
    }
}

function Setup-Project {
    Write-ColoredOutput "📁 تنظیم پروژه..." "Blue"
    
    # ایجاد پوشه سرویس
    if (-not (Test-Path $ServicePath)) {
        New-Item -ItemType Directory -Path $ServicePath -Force | Out-Null
        Write-ColoredOutput "✅ پوشه سرویس ایجاد شد: $ServicePath" "Green"
    }
    
    # کپی فایل‌ها
    Write-ColoredOutput "📋 کپی فایل‌های پروژه..." "Blue"
    $excludePatterns = @("venv", ".venv", "__pycache__", "*.pyc", ".git")
    Get-ChildItem -Path "." | Where-Object { 
        $item = $_
        -not ($excludePatterns | Where-Object { $item.Name -like $_ })
    } | Copy-Item -Destination $ServicePath -Recurse -Force
    
    Set-Location $ServicePath
}

function Setup-VirtualEnvironment {
    Write-ColoredOutput "🔧 تنظیم محیط مجازی..." "Blue"
    
    if (-not (Test-Path "venv")) {
        python -m venv venv
        Write-ColoredOutput "✅ محیط مجازی ایجاد شد" "Green"
    }
    
    # فعال‌سازی محیط مجازی
    & ".\venv\Scripts\Activate.ps1"
    
    # به‌روزرسانی pip
    python -m pip install --upgrade pip | Out-Null
    
    # حل مشکل pandas/numpy
    Write-ColoredOutput "🔧 نصب numpy و pandas..." "Blue"
    pip uninstall pandas numpy -y | Out-Null
    pip install numpy==1.24.3 --only-binary=all --no-cache-dir | Out-Null
    pip install pandas==2.0.3 --only-binary=all --no-cache-dir | Out-Null
    
    # نصب سایر پکیج‌ها
    if (Test-Path "requirements_windows.txt") {
        pip install -r requirements_windows.txt --only-binary=all --no-cache-dir | Out-Null
    } else {
        pip install -r requirements.txt --only-binary=all --no-cache-dir | Out-Null
    }
    
    # نصب pywin32 برای سرویس
    pip install pywin32 | Out-Null
    
    Write-ColoredOutput "✅ تمام پکیج‌ها نصب شدند" "Green"
}

function Test-Installation {
    Write-ColoredOutput "🧪 تست نصب..." "Blue"
    try {
        python -c "import pandas, numpy, streamlit, cv2; print('همه پکیج‌ها آماده!')" | Out-Null
        Write-ColoredOutput "✅ تست موفقیت‌آمیز" "Green"
    }
    catch {
        Write-ColoredOutput "❌ خطا در تست پکیج‌ها" "Red"
        exit 1
    }
}

function Create-WindowsService {
    Write-ColoredOutput "🔧 ایجاد Windows Service..." "Blue"
    
    $serviceScript = @"
import win32serviceutil
import win32service
import win32event
import servicemanager
import subprocess
import sys
import os
import time
import logging

# تنظیم لاگ
logging.basicConfig(
    filename=r'$ServicePath\service.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

class PDFToTextService(win32serviceutil.ServiceFramework):
    _svc_name_ = '$ServiceName'
    _svc_display_name_ = '$ServiceDisplayName'
    _svc_description_ = 'پلتفرم تبدیل PDF به متن فارسی - سرویس ویندوز'

    def __init__(self, args):
        win32serviceutil.ServiceFramework.__init__(self, args)
        self.hWaitStop = win32event.CreateEvent(None, 0, 0, None)
        self.process = None

    def SvcStop(self):
        logging.info('Service stopping...')
        self.ReportServiceStatus(win32service.SERVICE_STOP_PENDING)
        if self.process:
            self.process.terminate()
            self.process.wait()
        win32event.SetEvent(self.hWaitStop)

    def SvcDoRun(self):
        logging.info('Service starting...')
        servicemanager.LogMsg(servicemanager.EVENTLOG_INFORMATION_TYPE,
                             servicemanager.PYS_SERVICE_STARTED,
                             (self._svc_name_, ''))
        self.main()

    def main(self):
        try:
            os.chdir(r'$ServicePath')
            python_exe = r'$ServicePath\venv\Scripts\python.exe'
            cmd = [python_exe, '-m', 'streamlit', 'run', 'app.py',
                   '--server.port=$Port', '--server.address=0.0.0.0',
                   '--server.headless=true', '--server.runOnSave=false']
            
            logging.info(f'Starting: {" ".join(cmd)}')
            self.process = subprocess.Popen(
                cmd, 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE,
                cwd=r'$ServicePath'
            )
            
            while True:
                if win32event.WaitForSingleObject(self.hWaitStop, 5000) == win32event.WAIT_OBJECT_0:
                    break
                    
                # بررسی وضعیت process
                if self.process.poll() is not None:
                    logging.error('Streamlit process died, restarting...')
                    self.process = subprocess.Popen(
                        cmd, 
                        stdout=subprocess.PIPE, 
                        stderr=subprocess.PIPE,
                        cwd=r'$ServicePath'
                    )
                    
        except Exception as e:
            logging.error(f'Service error: {e}')
            
if __name__ == '__main__':
    win32serviceutil.HandleCommandLine(PDFToTextService)
"@

    $serviceScript | Out-File -FilePath "service.py" -Encoding utf8 -Force
    
    # نصب سرویس
    try {
        python service.py install | Out-Null
        Write-ColoredOutput "✅ سرویس Windows ایجاد شد" "Green"
        
        # تنظیم سرویس برای شروع خودکار
        Set-Service -Name $ServiceName -StartupType Automatic
        
        # شروع سرویس
        Start-Service -Name $ServiceName
        Write-ColoredOutput "✅ سرویس شروع شد" "Green"
        
    }
    catch {
        Write-ColoredOutput "⚠️ خطا در ایجاد سرویس: $_" "Yellow"
    }
}

function Setup-Firewall {
    Write-ColoredOutput "🔒 تنظیم فایروال..." "Blue"
    
    try {
        New-NetFirewallRule -DisplayName "PDF to Text Platform" -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow | Out-Null
        Write-ColoredOutput "✅ قانون فایروال اضافه شد" "Green"
    }
    catch {
        Write-ColoredOutput "⚠️ نتوانستم فایروال را تنظیم کنم: $_" "Yellow"
    }
}

function Setup-IIS {
    if (-not $SetupIIS) { return }
    
    Write-ColoredOutput "🌐 تنظیم IIS..." "Blue"
    
    try {
        # نصب IIS و Application Request Routing
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole, IIS-WebServer, IIS-CommonHttpFeatures, IIS-HttpRedirection -All | Out-Null
        
        # تنظیم reverse proxy
        $configPath = "$env:systemroot\system32\inetsrv\config\applicationHost.config"
        Write-ColoredOutput "⚠️ برای تنظیم کامل IIS، لطفاً به صورت دستی Application Request Routing را نصب کنید" "Yellow"
        Write-ColoredOutput "آدرس: https://www.iis.net/downloads/microsoft/application-request-routing" "Yellow"
    }
    catch {
        Write-ColoredOutput "⚠️ خطا در تنظیم IIS: $_" "Yellow"
    }
}

# اجرای اصلی
try {
    Write-ColoredOutput "🚀 شروع Deploy ویندوز سرور" "Blue"
    Write-ColoredOutput "=================================" "Blue"
    
    if (-not (Test-Administrator)) {
        Write-ColoredOutput "❌ لطفاً PowerShell را با دسترسی Administrator اجرا کنید" "Red"
        exit 1
    }
    
    Install-Prerequisites
    Setup-Project
    Setup-VirtualEnvironment
    Test-Installation
    Create-WindowsService
    Setup-Firewall
    Setup-IIS
    
    Write-ColoredOutput "" "White"
    Write-ColoredOutput "========================================" "Green"
    Write-ColoredOutput "🎉 Deploy با موفقیت تکمیل شد!" "Green"
    Write-ColoredOutput "========================================" "Green"
    Write-ColoredOutput "" "White"
    Write-ColoredOutput "📍 مسیر نصب: $ServicePath" "Cyan"
    Write-ColoredOutput "🌐 آدرس دسترسی: http://localhost:$Port" "Cyan"
    Write-ColoredOutput "🌐 دسترسی خارجی: http://YOUR_SERVER_IP:$Port" "Cyan"
    Write-ColoredOutput "" "White"
    Write-ColoredOutput "🔧 مدیریت سرویس:" "Blue"
    Write-ColoredOutput "  Start-Service '$ServiceName'" "White"
    Write-ColoredOutput "  Stop-Service '$ServiceName'" "White"
    Write-ColoredOutput "  Restart-Service '$ServiceName'" "White"
    Write-ColoredOutput "  Get-Service '$ServiceName'" "White"
    Write-ColoredOutput "" "White"
    Write-ColoredOutput "📋 لاگ سرویس: $ServicePath\service.log" "Cyan"
    Write-ColoredOutput "📋 لاگ Windows: Event Viewer > Windows Logs > System" "Cyan"
    
}
catch {
    Write-ColoredOutput "❌ خطا در deploy: $_" "Red"
    exit 1
}

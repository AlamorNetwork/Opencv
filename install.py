#!/usr/bin/env python3
"""
اسکریپت نصب خودکار پلتفرم تبدیل PDF به متن فارسی
"""
import os
import sys
import subprocess
import platform
import shutil
from pathlib import Path

def print_colored(text, color='blue'):
    """چاپ رنگی متن"""
    colors = {
        'red': '\033[91m',
        'green': '\033[92m',
        'yellow': '\033[93m',
        'blue': '\033[94m',
        'purple': '\033[95m',
        'cyan': '\033[96m',
        'white': '\033[97m',
        'end': '\033[0m'
    }
    
    if platform.system() == 'Windows':
        # در ویندوز از colorama استفاده کنیم
        try:
            import colorama
            colorama.init()
            print(f"{colors.get(color, '')}{text}{colors['end']}")
        except ImportError:
            print(text)
    else:
        print(f"{colors.get(color, '')}{text}{colors['end']}")

def run_command(command, description=""):
    """اجرای دستور سیستم"""
    try:
        print_colored(f"🔄 {description}", 'blue')
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print_colored(f"✅ {description} با موفقیت انجام شد", 'green')
        return True
    except subprocess.CalledProcessError as e:
        print_colored(f"❌ خطا در {description}: {e}", 'red')
        print(f"خروجی خطا: {e.stderr}")
        return False

def check_python():
    """بررسی نصب Python"""
    print_colored("📋 بررسی نسخه Python...", 'blue')
    
    try:
        version = sys.version_info
        if version.major >= 3 and version.minor >= 8:
            print_colored(f"✅ Python {version.major}.{version.minor}.{version.micro} نصب است", 'green')
            return True
        else:
            print_colored(f"❌ نسخه Python ({version.major}.{version.minor}) قدیمی است. حداقل Python 3.8 نیاز است", 'red')
            return False
    except Exception as e:
        print_colored(f"❌ خطا در بررسی Python: {e}", 'red')
        return False

def check_pip():
    """بررسی نصب pip"""
    print_colored("📋 بررسی pip...", 'blue')
    
    try:
        import pip
        print_colored("✅ pip موجود است", 'green')
        return True
    except ImportError:
        print_colored("❌ pip نصب نشده است", 'red')
        return False

def create_virtual_environment():
    """ایجاد محیط مجازی"""
    if Path('venv').exists():
        print_colored("✅ محیط مجازی از قبل موجود است", 'green')
        return True
    
    print_colored("🔧 ایجاد محیط مجازی...", 'blue')
    
    try:
        subprocess.run([sys.executable, '-m', 'venv', 'venv'], check=True)
        print_colored("✅ محیط مجازی ایجاد شد", 'green')
        return True
    except subprocess.CalledProcessError:
        print_colored("❌ خطا در ایجاد محیط مجازی", 'red')
        return False

def install_requirements():
    """نصب وابستگی‌ها"""
    print_colored("📦 نصب وابستگی‌ها...", 'blue')
    
    # تشخیص سیستم‌عامل و مسیر python در محیط مجازی
    if platform.system() == 'Windows':
        python_path = Path('venv/Scripts/python.exe')
        pip_path = Path('venv/Scripts/pip.exe')
    else:
        python_path = Path('venv/bin/python')
        pip_path = Path('venv/bin/pip')
    
    if not python_path.exists():
        print_colored("❌ محیط مجازی به درستی ایجاد نشده", 'red')
        return False
    
    try:
        # به‌روزرسانی pip
        subprocess.run([str(pip_path), 'install', '--upgrade', 'pip'], check=True)
        
        # نصب وابستگی‌ها
        subprocess.run([str(pip_path), 'install', '-r', 'requirements.txt'], check=True)
        
        print_colored("✅ تمام وابستگی‌ها نصب شدند", 'green')
        return True
    except subprocess.CalledProcessError as e:
        print_colored(f"❌ خطا در نصب وابستگی‌ها: {e}", 'red')
        return False

def check_tesseract():
    """بررسی نصب Tesseract"""
    print_colored("🔍 بررسی Tesseract OCR...", 'blue')
    
    tesseract_path = shutil.which('tesseract')
    if tesseract_path:
        print_colored(f"✅ Tesseract در مسیر {tesseract_path} یافت شد", 'green')
        
        # بررسی پشتیبانی زبان فارسی
        try:
            result = subprocess.run(['tesseract', '--list-langs'], capture_output=True, text=True)
            if 'fas' in result.stdout:
                print_colored("✅ پشتیبانی زبان فارسی موجود است", 'green')
            else:
                print_colored("⚠️  بسته زبان فارسی نصب نشده است", 'yellow')
                print_installation_guide_tesseract()
        except Exception:
            print_colored("⚠️  نمی‌تونم زبان‌های پشتیبانی شده را بررسی کنم", 'yellow')
        
        return True
    else:
        print_colored("❌ Tesseract OCR نصب نشده است", 'red')
        print_installation_guide_tesseract()
        return False

def print_installation_guide_tesseract():
    """راهنمای نصب Tesseract"""
    system = platform.system()
    print_colored("\n📖 راهنمای نصب Tesseract OCR:", 'cyan')
    
    if system == 'Windows':
        print("1. از لینک زیر دانلود کنید:")
        print("   https://github.com/UB-Mannheim/tesseract/wiki")
        print("2. یا با Chocolatey: choco install tesseract")
        print("3. یا با Scoop: scoop install tesseract")
    elif system == 'Linux':
        print("Ubuntu/Debian:")
        print("  sudo apt-get update")
        print("  sudo apt-get install tesseract-ocr tesseract-ocr-fas")
        print("\nCentOS/RHEL:")
        print("  sudo yum install tesseract tesseract-langpack-fas")
    elif system == 'Darwin':  # macOS
        print("با Homebrew:")
        print("  brew install tesseract")
        print("  brew install tesseract-lang")
    
    print()

def create_desktop_shortcut():
    """ایجاد میانبر روی دسکتاپ (فقط ویندوز)"""
    if platform.system() != 'Windows':
        return
    
    try:
        import winshell
        from win32com.client import Dispatch
        
        desktop = winshell.desktop()
        path = os.path.join(desktop, "PDF to Persian Text.lnk")
        target = os.path.join(os.getcwd(), "run.bat")
        wDir = os.getcwd()
        icon = target
        
        shell = Dispatch('WScript.Shell')
        shortcut = shell.CreateShortCut(path)
        shortcut.Targetpath = target
        shortcut.WorkingDirectory = wDir
        shortcut.IconLocation = icon
        shortcut.save()
        
        print_colored("✅ میانبر روی دسکتاپ ایجاد شد", 'green')
    except ImportError:
        print_colored("⚠️  برای ایجاد میانبر، pywin32 نیاز است", 'yellow')
    except Exception as e:
        print_colored(f"⚠️  نمی‌تونم میانبر ایجاد کنم: {e}", 'yellow')

def main():
    """تابع اصلی"""
    print_colored("="*50, 'purple')
    print_colored("   نصب خودکار پلتفرم تبدیل PDF به متن فارسی", 'purple')
    print_colored("="*50, 'purple')
    print()
    
    # بررسی سیستم
    checks_passed = 0
    total_checks = 4
    
    if check_python():
        checks_passed += 1
    else:
        print_colored("❌ لطفا Python 3.8+ را نصب کنید و دوباره تلاش کنید", 'red')
        return False
    
    if check_pip():
        checks_passed += 1
    else:
        print_colored("❌ لطفا pip را نصب کنید و دوباره تلاش کنید", 'red')
        return False
    
    if create_virtual_environment():
        checks_passed += 1
    else:
        print_colored("❌ نمی‌تونم محیط مجازی ایجاد کنم", 'red')
        return False
    
    if install_requirements():
        checks_passed += 1
    else:
        print_colored("❌ نمی‌تونم وابستگی‌ها رو نصب کنم", 'red')
        return False
    
    # بررسی Tesseract (اختیاری)
    tesseract_ok = check_tesseract()
    
    print()
    print_colored("="*50, 'green')
    print_colored("📊 خلاصه نصب:", 'green')
    print_colored(f"✅ بررسی‌های اصلی: {checks_passed}/{total_checks}", 'green')
    if tesseract_ok:
        print_colored("✅ Tesseract OCR: نصب شده", 'green')
    else:
        print_colored("⚠️  Tesseract OCR: نصب نشده (اختیاری)", 'yellow')
    
    print_colored("="*50, 'green')
    print()
    
    if checks_passed == total_checks:
        print_colored("🎉 نصب با موفقیت تکمیل شد!", 'green')
        print()
        print_colored("🚀 برای اجرای برنامه:", 'cyan')
        
        if platform.system() == 'Windows':
            print("  دوبل کلیک روی فایل run.bat")
            print("  یا در terminal: run.bat")
            create_desktop_shortcut()
        else:
            print("  ./run.sh")
            print("  یا: bash run.sh")
        
        print()
        print_colored("🌐 برنامه در آدرس http://localhost:8501 اجرا خواهد شد", 'cyan')
        
        # سؤال برای اجرای فوری
        try:
            response = input("\nآیا می‌خواهید همین الان برنامه را اجرا کنید؟ (y/N): ")
            if response.lower() in ['y', 'yes', 'بله']:
                print_colored("🚀 اجرای برنامه...", 'blue')
                if platform.system() == 'Windows':
                    os.system('run.bat')
                else:
                    os.system('./run.sh')
        except KeyboardInterrupt:
            print_colored("\n👋 خروج از نصب", 'yellow')
        
        return True
    else:
        print_colored("❌ نصب ناقص! لطفا خطاها را برطرف کنید و دوباره تلاش کنید", 'red')
        return False

if __name__ == '__main__':
    try:
        success = main()
        if success:
            sys.exit(0)
        else:
            sys.exit(1)
    except KeyboardInterrupt:
        print_colored("\n👋 نصب لغو شد", 'yellow')
        sys.exit(1)
    except Exception as e:
        print_colored(f"❌ خطای غیرمنتظره: {e}", 'red')
        sys.exit(1)

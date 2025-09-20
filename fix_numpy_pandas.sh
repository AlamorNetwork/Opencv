#!/bin/bash

# اسکریپت حل مشکل ناسازگاری numpy/pandas

set -e

# رنگ‌ها
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 حل مشکل ناسازگاری numpy/pandas${NC}"
echo "======================================="

# بررسی وجود محیط مجازی
if [ -d "venv" ]; then
    echo -e "${BLUE}🔄 فعال‌سازی محیط مجازی...${NC}"
    source venv/bin/activate
fi

# حذف کش pip
echo -e "${BLUE}🗑️  پاک کردن کش pip...${NC}"
pip cache purge

echo -e "${BLUE}📦 حذف numpy و pandas...${NC}"
pip uninstall numpy pandas -y

echo -e "${BLUE}📦 حذف سایر پکیج‌های وابسته...${NC}"
pip uninstall streamlit plotly scipy scikit-learn -y 2>/dev/null || true

echo -e "${BLUE}🔄 به‌روزرسانی pip...${NC}"
pip install --upgrade pip

echo -e "${BLUE}📦 نصب numpy نسخه سازگار...${NC}"
pip install numpy==1.24.3

echo -e "${BLUE}📦 نصب pandas نسخه سازگار...${NC}"
pip install pandas==2.0.3

echo -e "${BLUE}📦 نصب مجدد سایر پکیج‌ها...${NC}"
pip install -r requirements.txt

echo -e "${GREEN}✅ مشکل ناسازگاری numpy/pandas حل شد!${NC}"

echo -e "${BLUE}🧪 تست سریع...${NC}"
python3 -c "
import numpy as np
import pandas as pd
print(f'✅ numpy version: {np.__version__}')
print(f'✅ pandas version: {pd.__version__}')
print('✅ هر دو پکیج به درستی کار می‌کنند!')
"

echo -e "${GREEN}🎉 حالا می‌توانید برنامه را اجرا کنید:${NC}"
echo -e "${BLUE}   streamlit run app.py${NC}"


#!/data/data/com.termux/files/usr/bin/bash

GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

banner() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}     WarpScanner ترموکس هوشمند ⚡️         ${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
}

install_dependencies() {
    echo -e "${YELLOW}⏳ در حال بررسی ابزارهای مورد نیاز...${NC}"
    for pkg in python git curl wget; do
        if ! command -v $pkg >/dev/null 2>&1; then
            echo -e "${BLUE}📦 نصب $pkg ...${NC}"
            pkg install -y $pkg || { echo -e "${RED}❌ نصب $pkg شکست خورد. خروج.${NC}"; exit 1; }
        fi
    done
}

install_python_modules() {
    modules=("rich" "cryptography" "requests")
    for module in "${modules[@]}"; do
        echo -e "${YELLOW}🔍 بررسی ماژول $module ...${NC}"
        python -c "import $module" 2>/dev/null || {
            echo -e "${BLUE}📦 نصب ماژول $module ...${NC}"
            pip install --break-system-packages $module || {
                echo -e "${RED}❌ نصب ماژول $module شکست خورد.${NC}"
                exit 1
            }
        }
    done
}

fetch_warp_scanner() {
    if [ -f WarpScanner.py ]; then
        echo -e "${GREEN}✅ فایل WarpScanner.py موجود است.${NC}"
    else
        echo -e "${YELLOW}⬇️ دریافت WarpScanner.py ...${NC}"
        curl -fsSL -o WarpScanner.py https://raw.githubusercontent.com/mjjku/WarpScanner/main/WarpScanner.py || {
            echo -e "${RED}❌ دریافت فایل ناموفق بود.${NC}"
            exit 1
        }
    fi
}

patch_imports() {
    grep -q "X25519PrivateKey" WarpScanner.py || {
        echo -e "${YELLOW}⚙️ افزودن ایمپورت X25519PrivateKey ...${NC}"
        sed -i '1i from cryptography.hazmat.primitives.asymmetric.x25519 import X25519PrivateKey' WarpScanner.py
        sed -i '2i from cryptography.hazmat.primitives import serialization' WarpScanner.py
    }
}

run_warp_scanner() {
    echo -e "${GREEN}🚀 اجرای WarpScanner...${NC}"
    python WarpScanner.py
}

banner
install_dependencies
install_python_modules
fetch_warp_scanner
patch_imports
run_warp_scanner

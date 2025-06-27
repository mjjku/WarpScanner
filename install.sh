#!/data/data/com.termux/files/usr/bin/bash
set -e

# 🎨 Colors
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

clear

# 🎯 Startup Banner
banner() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}     ⚡️ Smart Termux WarpScanner          ${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
}

# 📦 Install Required Packages
install_dependencies() {
    echo -e "${YELLOW}⏳ Checking and installing required packages...${NC}"
    for pkg in python git curl wget; do
        if ! command -v $pkg >/dev/null 2>&1; then
            echo -e "${BLUE}📦 Installing $pkg ...${NC}"
            yes | pkg install $pkg > /dev/null || {
                echo -e "${RED}❌ Failed to install $pkg.${NC}"
                exit 1
            }
        fi
    done

    if ! command -v pip >/dev/null 2>&1; then
        echo -e "${BLUE}📦 Installing pip ...${NC}"
        yes | pkg install python-pip > /dev/null || {
            echo -e "${RED}❌ Failed to install pip.${NC}"
            exit 1
        }
    fi
}

# 🧰 Install Required Python Modules
install_python_modules() {
    echo -e "${YELLOW}⏳ Checking required Python modules...${NC}"
    modules=("rich" "cryptography" "requests")
    for module in "${modules[@]}"; do
        python -c "import $module" 2>/dev/null || {
            echo -e "${BLUE}📦 Installing Python module: $module ...${NC}"
            pip install --break-system-packages $module > /dev/null || {
                echo -e "${RED}❌ Failed to install Python module: $module.${NC}"
                exit 1
            }
        }
    done
}

# 🔍 Check and Download WarpScanner.py
check_and_download_warp_scanner() {
    local file="WarpScanner.py"
    local url="https://raw.githubusercontent.com/mjjku/WarpScanner/main/WarpScanner.py"

    if [ -f "$file" ]; then
        local first_line=$(head -n 1 "$file")
        if [[ "$first_line" != "V=76" && "$first_line" != "import urllib.request" ]]; then
            echo -e "${YELLOW}🔁 Outdated or unrecognized file found. Removing...${NC}"
            rm -f "$file"
        elif [[ "$first_line" == "import urllib.request" ]]; then
            echo -e "${YELLOW}⚠️ Legacy format detected. Removing...${NC}"
            rm -f "$file"
        else
            echo -e "${GREEN}✅ WarpScanner.py is valid.${NC}"
        fi
    fi

    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}⬇️ Downloading the latest WarpScanner.py ...${NC}"
        curl -fsSL -o "$file" "$url" || {
            echo -e "${RED}❌ Failed to download WarpScanner.py. Exiting.${NC}"
            exit 1
        }
        echo -e "${GREEN}✅ Latest version downloaded successfully.${NC}"
    fi
}

# ⚙️ Patch Required Imports if Missing
patch_imports() {
    grep -q "X25519PrivateKey" WarpScanner.py || {
        echo -e "${YELLOW}⚙️ Adding required import statements...${NC}"
        sed -i '1i from cryptography.hazmat.primitives.asymmetric.x25519 import X25519PrivateKey' WarpScanner.py
        sed -i '2i from cryptography.hazmat.primitives import serialization' WarpScanner.py
    }
}

# 🚀 Execute the Main Script
run_warp_scanner() {
    echo -e "${GREEN}🚀 Launching WarpScanner...${NC}"
    python WarpScanner.py || {
        echo -e "${RED}❌ WarpScanner execution failed.${NC}"
        exit 1
    }
}

# 🧠 Main Execution
main() {
    banner
    install_dependencies
    install_python_modules
    check_and_download_warp_scanner
    patch_imports
    run_warp_scanner
    echo -e "${GREEN}[✓] All operations completed successfully. Ready to go! 💥${NC}"
}

main

#!/bin/bash

set -e

# ========= Functions =========
install_python() {
    echo "[+] Installing Python and pip..."
    pkg update -y || { echo "[-] Failed to update packages."; exit 1; }
    pkg install python python-pip -y || { echo "[-] Failed to install Python."; exit 1; }
}

install_git() {
    echo "[+] Installing Git..."
    pkg install git -y || { echo "[-] Failed to install Git."; exit 1; }
}

install_wget() {
    echo "[+] Installing wget..."
    pkg install wget -y || { echo "[-] Failed to install wget."; exit 1; }
}

install_curl() {
    echo "[+] Installing curl..."
    pkg install curl -y || { echo "[-] Failed to install curl."; exit 1; }
}

download_warpscanner() {
    echo "[+] Downloading latest WarpScanner.py..."
    curl -fsSL -o WarpScanner.py https://raw.githubusercontent.com/mjjku/WarpScanner/main/WarpScanner.py || {
        echo "[-] Failed to download WarpScanner.py."
        exit 1
    }
}

run_warpscanner() {
    echo "[+] Running WarpScanner.py..."
    python WarpScanner.py || { echo "[-] Failed to run WarpScanner.py."; exit 1; }
}

download_and_run_termux_installer() {
    echo "[+] Downloading and running warp_termux_installer.sh..."
    curl -fsSL -o warp_termux_installer.sh https://raw.githubusercontent.com/mjjku/WarpScanner/main/warp_termux_installer.sh || {
        echo "[-] Failed to download warp_termux_installer.sh."
        exit 1
    }
    chmod +x warp_termux_installer.sh
    ./warp_termux_installer.sh || { echo "[-] Failed to run warp_termux_installer.sh."; exit 1; }
}

# ========= Start =========
echo "[+] Starting Warp Installer..."

# Dependency Check
command -v python >/dev/null 2>&1 || install_python
command -v pip >/dev/null 2>&1 || install_python
command -v git >/dev/null 2>&1 || install_git
command -v wget >/dev/null 2>&1 || install_wget
command -v curl >/dev/null 2>&1 || install_curl

# WarpScanner Logic
if [ -f WarpScanner.py ]; then
    first_line=$(head -n 1 WarpScanner.py)
    if [[ "$first_line" != "V=76" && "$first_line" != "import urllib.request" ]]; then
        echo "[+] Old version detected. Replacing WarpScanner.py..."
        rm -f WarpScanner.py
        download_warpscanner
    elif [[ "$first_line" == "import urllib.request" ]]; then
        echo "[+] Detected outdated format. Replacing WarpScanner.py..."
        rm -f WarpScanner.py
        download_warpscanner
    fi
else
    download_warpscanner
fi

run_warpscanner

# Optional: Run extra Termux installer if needed
download_and_run_termux_installer

echo "[✓] All done. WarpScanner and installer executed successfully."

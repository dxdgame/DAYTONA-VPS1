#!/bin/bash

# Clear screen for professional terminal look
clear

echo "=========================================================="
echo "  ____  _____ _   _ ____     ____    _    __  __ ___ _   _  ____ "
echo " |  _ \| ____| | | |  _ \   / ___|  / \  |  \/  |_ _| \ | |/ ___|"
echo " | | | |  _| | | | | |_) | | |  _  / _ \ | |\/| || ||  \| | |  _ "
echo " | |_| | |___| |_| |  __/  | |_| |/ ___ \| |  | || || |\  | |_| |"
echo " |____/|_____|\___/|_|      \____/_/   \_\_|  |_|___|_| \_|\____|"
echo "                                                                 "
echo "                ____  __  ____     _        _     ____  ____     "
echo "               |  _ \ \ \/ /  _ \  | |      / \   | __ )/ ___|    "
echo "               | | | | \  /| | | | | |     / _ \  |  _ \\___ \    "
echo "               | |_| | /  \| |_| | | |___ / ___ \ | |_) |___) |   "
echo "               |____/ /_/\_\____/  |_____/_/   \_\____/|____/    "
echo "=========================================================="
echo "          WELCOME TO DEUP GAMING & DXD LABS VPS            "
echo "=========================================================="
echo ""

# 1. User Configurations Input
read -p "🔹 Enter RAM Size in GB (e.g., 4, 8, 16, 32): " RAM_GB
read -p "🔹 Enter CPU Cores (e.g., 2, 4, 8): " CPU_CORES
read -p "🔹 Enter Disk Space to ADD in GB (e.g., 10, 20, 40): " DISK_ADD
read -p "🔹 Create Username (Default: ubuntu): " USER_NAME
USER_NAME=${USER_NAME:-ubuntu}
read -p "🔹 Create Password (Default: 1234): " USER_PASS
USER_PASS=${USER_PASS:-1234}

echo ""
echo "⏳ Background dependencies install ho rahi hain... Please wait."
echo ""

# Automated requirement checking (Handles root/sudo dynamically)
if [ "$(id -u)" -eq 0 ]; then
    SUDO_CMD=""
else
    SUDO_CMD="sudo"
fi

$SUDO_CMD apt-get update -y > /dev/null 2>&1
$SUDO_CMD apt-get install -y qemu-system-x86 qemu-utils wget cloud-image-utils > /dev/null 2>&1

# Check and download Ubuntu Image
if [ ! -f "ubuntu22.qcow2" ]; then
    echo "📥 Downloading Ubuntu 22.04 Cloud Image..."
    wget -q --show-progress https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img -O ubuntu22.qcow2
fi

# Create Cloud-Init Dynamic Configuration
cat <<EOF > user-data
#cloud-config
ssh_pwauth: True
chpasswd:
  list: |
    ${USER_NAME}:${USER_PASS}
  expire: False
EOF

cloud-localds seed.img user-data > /dev/null 2>&1

# Resize Disk Image dynamically
echo "💽 Resizing Virtual Disk..."
qemu-img resize ubuntu22.qcow2 +${DISK_ADD}G > /dev/null 2>&1

clear
echo "=========================================================="
echo "🎉 DEUP GAMING & DXD LABS - VM READY TO BOOT!"
echo "=========================================================="
echo "👤 Username : $USER_NAME"
echo "🔑 Password : $USER_PASS"
echo "⚙️ Resources: ${RAM_GB}GB RAM | ${CPU_CORES} Cores | +${DISK_ADD}GB Disk"
echo "🚀 Connection Port: 2223"
echo "👉 Login Command  : ssh $USER_NAME@localhost -p 2223"
echo "=========================================================="
echo ""

# Booting QEMU System
qemu-system-x86_64 \
    -m ${RAM_GB}G \
    -smp ${CPU_CORES} \
    -hda ubuntu22.qcow2 \
    -drive file=seed.img,format=raw \
    -nographic \
    -net nic \
    -net user,hostfwd=tcp::2223-:22

#!/bin/bash

# Clear terminal for clean dashboard view
clear

# ==========================================
# 🌟 PREMIUM COLOR CODES & FX
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# FUNCTION: TYPING EFFECT ANIMATION
type_effect() {
    local text="$1"
    local delay="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

# FUNCTION: LOADING BAR ANIMATION
loading_bar() {
    local title="$1"
    echo -ne "${YELLOW}⏳ $title ${NC}[          ]"
    sleep 0.3
    echo -ne "\b\b\b\b\b\b\b\b\b\b\b[===       ]"
    sleep 0.3
    echo -ne "\b\b\b\b\b\b\b\b\b\b\b[======     ]"
    sleep 0.3
    echo -ne "\b\b\b\b\b\b\b\b\b\b\b[=========  ]"
    sleep 0.3
    echo -ne "\b\b\b\b\b\b\b\b\b\b\b[==========]"
    echo -e " ${GREEN}DONE!${NC}"
}

# AUTOMATED ROOT/SUDO PRIVILEGE CHECK
if [ "$(id -u)" -eq 0 ]; then
    SUDO_CMD=""
else
    SUDO_CMD="sudo"
fi

# ==========================================
# MAIN INTERACTIVE LIST MENU
# ==========================================
show_menu() {
    clear
    echo -e "${RED}==========================================================${NC}"
    echo -e "${WHITE}          [👹 DXD LABS PREMIUM VPS DASHBOARD 👹]          ${NC}"
    echo -e "${RED}==========================================================${NC}"
    echo -e "${WHITE}                ┌─────────────────────────┐               ${NC}"
    echo -e "${WHITE}                │   ${RED}█▀▀█ █──█ █▄─▄█ █▀▀█${WHITE}  │  <[SUKUNA V2] ${NC}"
    echo -e "${WHITE}                │   ${RED}█▄▄█ █▄▄█ █ █ █ █▄▄█${WHITE}  │               ${NC}"
    echo -e "${WHITE}                └─────────────────────────┘               ${NC}"
    echo -e "${PURPLE}                   (█)─(█)     (█)─(█)                   ${NC}"
    echo -e "${PURPLE}                  █████████   █████████                  ${NC}"
    echo -e "${RED}                 ███████████████████████                 ${NC}"
    echo -e "${RED}==========================================================${NC}"
    echo -e "${CYAN}  ____  _____ _   _ ____     ____    _    __  __ ___ _   _  ____ ${NC}"
    echo -e "${CYAN} |  _ \| ____| | | |  _ \   / ___|  / \  |  \/  |_ _| \ | |/ ___|${NC}"
    echo -e "${CYAN} | | | |  _| | | | | |_) | | |  _  / _ \ | |\/| || ||  \| | |  _ ${NC}"
    echo -e "${CYAN} | |_| | |___| |_| |  __/  | |_| |/ ___ \| |  | || || |\  | |_| |${NC}"
    echo -e "${CYAN} |____/|_____|\___/|_|      \____/_/   \_\_|  |_|___|_| \_|\____|${NC}"
    echo -e "${RED}==========================================================${NC}"
    echo ""
    echo -e "${YELLOW}👉 SELECT AN OPTION TO PROCEED FROM LIST:${NC}"
    echo ""
    echo -e "  ${CYAN}[1]${NC} Create & Boot New Ubuntu VPS Instance"
    echo -e "  ${CYAN}[2]${NC} Restart Existing VPS Instance"
    echo -e "  ${CYAN}[3]${NC} Modify TCP Port Forward Rules (Default: 2222)"
    echo -e "  ${CYAN}[4]${NC} Remove/Clean VPS Cache Files"
    echo -e "  ${CYAN}[5]${NC} Exit Dashboard"
    echo ""
    echo -e "${RED}==========================================================${NC}"
    echo -ne "${WHITE}🔹 Enter Choice [1-5]: ${NC}"
    read CHOICE
    
    case $CHOICE in
        1) create_vps ;;
        2) restart_vps ;;
        3) configure_tcp ;;
        4) clean_vps ;;
        5) exit 0 ;;
        *) echo -e "${RED}❌ Invalid Choice! Please select 1-5.${NC}"; sleep 2; show_menu ;;
    esac
}

# CONFIGURATION FOR NEW VPS
create_vps() {
    clear
    echo -e "${RED}==========================================================${NC}"
    echo -e "${WHITE}⚙️  CONFIGURE YOUR VIRTUAL MACHINE SPECIFICATIONS${NC}"
    echo -e "${RED}==========================================================${NC}"
    echo ""
    
    echo -ne "${BLUE}🔹 Enter RAM Size in GB (e.g., 4, 8, 16, 32): ${NC}"
    read RAM_GB
    echo -ne "${BLUE}🔹 Enter CPU Cores (e.g., 2, 4, 8): ${NC}"
    read CPU_CORES
    echo -ne "${BLUE}🔹 Enter Disk Space to ADD in GB (e.g., 10, 20): ${NC}"
    read DISK_ADD
    echo -ne "${BLUE}🔹 Create Username (Default: ubuntu): ${NC}"
    read USER_NAME
    USER_NAME=${USER_NAME:-ubuntu}
    echo -ne "${BLUE}🔹 Create Password (Default: 1234): ${NC}"
    read USER_PASS
    USER_PASS=${USER_PASS:-1234}
    
    # Setting up standard default port 2222 rule initializations
    TCP_HOST_PORT=${TCP_HOST_PORT:-2222}
    TCP_GUEST_PORT=22

    echo ""
    echo -e "${YELLOW}⏳ Background dependencies aur SSHX setup ho raha hai... Please wait.${NC}"
    echo ""
    
    $SUDO_CMD apt-get update -y > /dev/null 2>&1
    $SUDO_CMD apt-get install -y qemu-system-x86 qemu-utils wget cloud-image-utils curl > /dev/null 2>&1
    
    if ! command -v sshx &> /dev/null; then
        loading_bar "Installing SSHX Web Terminal Engine"
        curl -sSf https://sshx.io/get | sh > /dev/null 2>&1
    fi
    
    if [ ! -f "ubuntu22.qcow2" ]; then
        echo -e "${YELLOW}📥 Downloading Ubuntu 22.04 Cloud Image...${NC}"
        wget -q --show-progress https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img -O ubuntu22.qcow2
    else
        echo -e "${GREEN}✅ Existing Ubuntu Image Cache Detected.${NC}"
    fi
    
    loading_bar "Generating Cloud-Init Matrix"
    cat <<EOF > user-data
#cloud-config
ssh_pwauth: True
chpasswd:
  list: |
    ${USER_NAME}:${USER_PASS}
  expire: False
EOF

    cloud-localds seed.img user-data > /dev/null 2>&1
    loading_bar "Expanding Server Hard Disk Allocation"
    qemu-img resize ubuntu22.qcow2 +${DISK_ADD}G > /dev/null 2>&1
    
    # Save parameters block
    save_env
    boot_qemu
}

# TCP RULE MODIFIER FUNCTION
configure_tcp() {
    clear
    echo -e "${YELLOW}==========================================================${NC}"
    echo -e "${WHITE}🔄⚙️  MANAGE CUSTOM TCP PORT FORWARDING RULES ${NC}"
    echo -e "${YELLOW}==========================================================${NC}"
    echo ""
    if [ -f ".vps_env" ]; then
        source .vps_env
    fi
    echo -e "Current Target Host Port  : ${CYAN}${TCP_HOST_PORT:-2222}${NC}"
    echo -e "Current Guest VM Port     : ${CYAN}${TCP_GUEST_PORT:-22}${NC}"
    echo ""
    echo -ne "${BLUE}🔹 Enter NEW External Host Port (Default base: 2222): ${NC}"
    read NEW_HOST_PORT
    TCP_HOST_PORT=${NEW_HOST_PORT:-2222}
    
    echo -ne "${BLUE}🔹 Enter Internal Guest Port (Default SSH: 22): ${NC}"
    read NEW_GUEST_PORT
    TCP_GUEST_PORT=${NEW_GUEST_PORT:-22}
    
    save_env
    echo ""
    echo -e "${GREEN}✅ TCP Rule Updated Successfully! New Rule: hostfwd=tcp::${TCP_HOST_PORT}-:${TCP_GUEST_PORT}${NC}"
    sleep 2
    show_menu
}

save_env() {
    echo "RAM_GB=${RAM_GB:-8}" > .vps_env
    echo "CPU_CORES=${CPU_CORES:-4}" >> .vps_env
    echo "USER_NAME=${USER_NAME:-ubuntu}" >> .vps_env
    echo "USER_PASS=${USER_PASS:-1234}" >> .vps_env
    echo "TCP_HOST_PORT=${TCP_HOST_PORT:-2222}" >> .vps_env
    echo "TCP_GUEST_PORT=${TCP_GUEST_PORT:-22}" >> .vps_env
}

# VPS BOOT SYSTEM (INTEGRATED WITH SHHX + CUSTOM 2222 TCP PORT RULES)
boot_qemu() {
    if [ -f ".vps_env" ]; then
        source .vps_env
    fi

    # Ensuring dynamic variables default structures
    TCP_HOST_PORT=${TCP_HOST_PORT:-2222}
    TCP_GUEST_PORT=${TCP_GUEST_PORT:-22}

    clear
    echo -e "${GREEN}==========================================================${NC}"
    type_effect "👹 DATA SYSTEM SYNCHRONIZED! STARTING EXTENDED CHANNELS..." 0.02
    echo -e "${GREEN}==========================================================${NC}"
    echo ""
    
    echo -e "${YELLOW}🔗 Generating Live SSHX Web Terminal Link...${NC}"
    sshx_log=$(mktemp)
    sshx --quiet > "$sshx_log" 2>&1 &
    
    sleep 4
    SSHX_URL=$(grep -o 'https://sshx.io/s/[a-zA-Z0-9]*' "$sshx_log" | head -n 1)
    rm -f "$sshx_log"

    clear
    echo -e "${GREEN}==========================================================${NC}"
    echo -e "🎉       DEUP GAMING & DXD LABS - VIRTUAL HUB            "
    echo -e "${GREEN}==========================================================${NC}"
    echo -e "${WHITE}👤 Username : ${CYAN}${USER_NAME:-ubuntu}${NC}"
    echo -e "${WHITE}🔑 Password : ${CYAN}${USER_PASS:-1234}${NC}"
    echo -e "${WHITE}⚙️  Resources: ${CYAN}${RAM_GB:-8}GB RAM | ${CPU_CORES:-4} Cores${NC}"
    echo -e "${WHITE}🚀 Active TCP Rule: ${YELLOW}Host Port ${TCP_HOST_PORT} -> VM Port ${TCP_GUEST_PORT}${NC}"
    echo -e "${RED}----------------------------------------------------------${NC}"
    if [ ! -z "$SSHX_URL" ]; then
        echo -e "${YELLOW}🔥 LIVE WEB TERMINAL ACCESS LINK (Copy & Paste in Browser):${NC}"
        echo -e "${GREEN}👉 $SSHX_URL 👈${NC}"
    else
        echo -e "${RED}⚠️ SSHX proxy link timed out. Direct port lines remain active.${NC}"
    fi
    echo -e "${RED}----------------------------------------------------------${NC}"
    echo -e "${WHITE}👉 Manual Connection Command : ssh ${USER_NAME:-ubuntu}@localhost -p ${TCP_HOST_PORT}${NC}"
    echo -e "${GREEN}==========================================================${NC}"
    echo ""
    
    # Dynamic QEMU Execution Engine with customized TCP forwarding properties
    qemu-system-x86_64 \
        -m ${RAM_GB:-8}G \
        -smp ${CPU_CORES:-4} \
        -hda ubuntu22.qcow2 \
        -drive file=seed.img,format=raw \
        -nographic \
        -net nic \
        -net user,hostfwd=tcp::${TCP_HOST_PORT}-:${TCP_GUEST_PORT}
}

# RESTART EXISTING SYSTEM
restart_vps() {
    if [ -f "ubuntu22.qcow2" ] && [ -f "seed.img" ]; then
        echo -e "${GREEN}🔄 Restarting existing server architecture...${NC}"
        sleep 1
        boot_qemu
    else
        echo -e "${RED}❌ No active configuration found! Build a fresh module using Option 1.${NC}"
        sleep 3
        show_menu
    fi
}

# WIPE INSTANCE REPO CLEAN
clean_vps() {
    echo -e "${RED}⚠️ Purging system infrastructure blocks and rules...${NC}"
    rm -rf user-data seed.img ubuntu22.qcow2 .vps_env
    pkill sshx > /dev/null 2>&1
    sleep 1
    echo -e "${GREEN}✅ Workspace successfully wiped fresh!${NC}"
    sleep 2
    show_menu
}

# START EXECUTION TRIGGER
show_menu

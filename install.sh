#!/usr/bin/env bash

# =========================================
# Claude Code Auto Installer
# UI Version
# =========================================

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m'

line() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

logo() {
    clear
    echo -e "${CYAN}"
    echo " ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗"
    echo "██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝"
    echo "██║     ██║     ███████║██║   ██║██║  ██║█████╗  "
    echo "██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝  "
    echo "╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗"
    echo " ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝"
    echo -e "${NC}"

    echo -e "${WHITE}         Claude Code CLI Auto Installer${NC}"
    echo -e "${YELLOW}                Node.js 21 - 26${NC}"
    echo ""
    line
}

success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

error() {
    echo -e "${RED}[✗] $1${NC}"
}

info() {
    echo -e "${CYAN}[•] $1${NC}"
}

# =========================================

logo

# cek root
if [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
else
    SUDO=""
fi

# =========================================
# PILIH NODEJS
# =========================================

echo -e "${WHITE}Pilih versi Node.js:${NC}"
echo ""
echo -e "${GREEN}[1]${NC} Node.js 21"
echo -e "${GREEN}[2]${NC} Node.js 22"
echo -e "${GREEN}[3]${NC} Node.js 23"
echo -e "${GREEN}[4]${NC} Node.js 24"
echo -e "${GREEN}[5]${NC} Node.js 25"
echo -e "${GREEN}[6]${NC} Node.js 26"
echo ""

while true; do
    printf "${YELLOW}Masukkan pilihan [1-6]: ${NC}"

    read pilihan

    case "$pilihan" in
        1) NODE_VER=21; break ;;
        2) NODE_VER=22; break ;;
        3) NODE_VER=23; break ;;
        4) NODE_VER=24; break ;;
        5) NODE_VER=25; break ;;
        6) NODE_VER=26; break ;;
        *)
            error "Pilihan tidak valid!"
            ;;
    esac
done

line

info "Installing Node.js v$NODE_VER ..."
sleep 1

# =========================================
# DETECT DISTRO
# =========================================

if [ -f /etc/debian_version ]; then

    info "Detected Debian/Ubuntu"

    curl -fsSL https://deb.nodesource.com/setup_${NODE_VER}.x | $SUDO -E bash -
    $SUDO apt-get update -y
    $SUDO apt-get install -y nodejs

elif [ -f /etc/redhat-release ]; then

    info "Detected CentOS/RHEL/Fedora"

    curl -fsSL https://rpm.nodesource.com/setup_${NODE_VER}.x | $SUDO bash -

    if command -v dnf >/dev/null 2>&1; then
        $SUDO dnf install -y nodejs
    else
        $SUDO yum install -y nodejs
    fi

elif [ -f /etc/arch-release ]; then

    info "Detected Arch Linux"

    $SUDO pacman -Sy --noconfirm nodejs npm

elif grep -qi suse /etc/os-release 2>/dev/null; then

    info "Detected openSUSE"

    $SUDO zypper install -y nodejs npm

else
    error "Distro tidak didukung!"
    exit 1
fi

line

NODE_VERSION=$(node --version 2>/dev/null)

if [[ -n "$NODE_VERSION" ]]; then
    success "Node.js installed: $NODE_VERSION"
else
    error "Gagal install Node.js"
    exit 1
fi

# =========================================
# INSTALL CLAUDE
# =========================================

line
info "Installing Claude Code CLI ..."
echo ""

npm install -g @anthropic-ai/claude-code

if [ $? -ne 0 ]; then

    error "Install utama gagal, mencoba mirror..."

    npm install -g @anthropic-ai/claude-code \
    --registry https://registry.npmmirror.com

    if [ $? -ne 0 ]; then
        error "Install Claude Code gagal!"
        exit 1
    fi
fi

success "Claude Code berhasil diinstall"

# =========================================
# API KEY
# =========================================

line

echo -e "${WHITE}Ambil API key di:${NC}"
echo -e "${CYAN}https://freemodel.dev/invite/FRE-c0ca4c8e${NC}"
echo ""

printf "${YELLOW}Masukkan API KEY: ${NC}"
read API_KEY

mkdir -p ~/.claude

cat > ~/.claude/settings.json <<EOF
{
    "env": {
        "ANTHROPIC_API_KEY": "$API_KEY",
        "ANTHROPIC_BASE_URL": "https://cc.freemodel.dev",
        "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
    },
    "permissions": {
        "allow": [],
        "deny": []
    },
    "apiKeyHelper": "echo '$API_KEY'"
}
EOF

success "API Key berhasil disimpan"

# =========================================
# FINAL
# =========================================

line

CLAUDE_VERSION=$(claude --version 2>/dev/null)

success "Setup selesai!"
echo ""

echo -e "${GREEN}Node.js:${NC} $NODE_VERSION"
echo -e "${GREEN}Claude:${NC}  $CLAUDE_VERSION"

echo ""
echo -e "${CYAN}Jalankan:${NC}"
echo -e "${WHITE}claude${NC}"
echo ""

line

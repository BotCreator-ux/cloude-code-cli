#!/bin/bash

clear

echo "======================================"
echo " Claude Code Auto Installer"
echo " Node.js 21 - 26"
echo "======================================"
echo ""

# Cek root
if [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
else
    SUDO=""
fi

# Pilih versi Node.js
echo "Pilih versi Node.js:"
echo "1) Node.js 21"
echo "2) Node.js 22"
echo "3) Node.js 23"
echo "4) Node.js 24"
echo "5) Node.js 25"
echo "6) Node.js 26"
echo ""

read -p "Masukkan pilihan [1-6]: " pilihan

case $pilihan in
    1) NODE_VER=21 ;;
    2) NODE_VER=22 ;;
    3) NODE_VER=23 ;;
    4) NODE_VER=24 ;;
    5) NODE_VER=25 ;;
    6) NODE_VER=26 ;;
    *)
        echo "Pilihan tidak valid!"
        exit 1
        ;;
esac

echo ""
echo "Installing Node.js v$NODE_VER ..."
sleep 1

# Detect distro
if [ -f /etc/debian_version ]; then
    DISTRO="debian"

    curl -fsSL https://deb.nodesource.com/setup_${NODE_VER}.x | $SUDO -E bash -
    $SUDO apt-get update
    $SUDO apt-get install -y nodejs

elif [ -f /etc/redhat-release ]; then
    DISTRO="rhel"

    curl -fsSL https://rpm.nodesource.com/setup_${NODE_VER}.x | $SUDO bash -

    if command -v dnf >/dev/null 2>&1; then
        $SUDO dnf install -y nodejs
    else
        $SUDO yum install -y nodejs
    fi

elif [ -f /etc/arch-release ]; then
    DISTRO="arch"

    $SUDO pacman -Sy --noconfirm nodejs npm

elif [ -f /etc/SuSE-release ] || [ -f /etc/os-release ] && grep -qi suse /etc/os-release; then
    DISTRO="suse"

    $SUDO zypper install -y nodejs npm

else
    echo "Distro tidak didukung otomatis."
    exit 1
fi

echo ""
echo "Node.js berhasil diinstall:"
node --version

echo ""
echo "======================================"
echo " Install Claude Code"
echo "======================================"

npm install -g @anthropic-ai/claude-code

if [ $? -ne 0 ]; then
    echo ""
    echo "Install gagal, mencoba pakai registry mirror..."

    npm install -g @anthropic-ai/claude-code \
        --registry https://registry.npmmirror.com
fi

echo ""
echo "======================================"
echo " Setup API Key"
echo "======================================"

read -p "Masukkan API KEY: " API_KEY

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

echo ""
echo "======================================"
echo " Setup selesai!"
echo "======================================"

echo ""
echo "Versi Node:"
node --version

echo ""
echo "Claude Code version:"
claude --version

echo ""
echo "File config:"
echo "~/.claude/settings.json"

echo ""
echo "Jalankan dengan command:"
echo "claude"
echo ""

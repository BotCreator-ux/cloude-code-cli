#!/bin/bash

clear

echo "======================================"
echo " Claude Code Auto Installer"
echo " Node.js 21 - 26"
echo "======================================"
echo ""

# cek sudo
if [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
else
    SUDO=""
fi

# pilih nodejs
echo "Pilih versi Node.js:"
echo "1) Node.js 21"
echo "2) Node.js 22"
echo "3) Node.js 23"
echo "4) Node.js 24"
echo "5) Node.js 25"
echo "6) Node.js 26"
echo ""

read -r -p "Masukkan pilihan [1-6]: " pilihan < /dev/tty

case "$pilihan" in
    1) NODE_VER=21 ;;
    2) NODE_VER=22 ;;
    3) NODE_VER=23 ;;
    4) NODE_VER=24 ;;
    5) NODE_VER=25 ;;
    6) NODE_VER=26 ;;
    *)
        echo ""
        echo "Pilihan tidak valid!"
        exit 1
        ;;
esac

echo ""
echo "Installing Node.js v$NODE_VER ..."
sleep 1

# detect distro
if [ -f /etc/debian_version ]; then

    curl -fsSL https://deb.nodesource.com/setup_${NODE_VER}.x | $SUDO -E bash -
    $SUDO apt-get update
    $SUDO apt-get install -y nodejs

elif [ -f /etc/redhat-release ]; then

    curl -fsSL https://rpm.nodesource.com/setup_${NODE_VER}.x | $SUDO bash -

    if command -v dnf >/dev/null 2>&1; then
        $SUDO dnf install -y nodejs
    else
        $SUDO yum install -y nodejs
    fi

elif [ -f /etc/arch-release ]; then

    $SUDO pacman -Sy --noconfirm nodejs npm

elif grep -qi suse /etc/os-release 2>/dev/null; then

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
    echo "Install gagal, mencoba mirror..."

    npm install -g @anthropic-ai/claude-code \
        --registry https://registry.npmmirror.com
fi

echo ""
echo "======================================"
echo " Setup API Key"
echo "======================================"

read -r -p "Masukkan API KEY: " API_KEY < /dev/tty

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
echo "Node Version:"
node --version

echo ""
echo "Claude Version:"
claude --version

echo ""
echo "Jalankan command:"
echo "claude"
echo ""

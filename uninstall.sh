#!/bin/bash

# ================================================
#   Ubuntu 22.04 LTS Uninstaller for Termux
# ================================================

UBUNTU_DIR="$HOME/.ubuntu22"
ROOTFS_FILE="$HOME/.ubuntu-base-arm64.tar.gz"
START_SCRIPT="$HOME/.start-ubuntu.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[x]${NC} $1"; exit 1; }

echo ""
echo -e "${BOLD}================================================${NC}"
echo -e "${BOLD}   Ubuntu 22.04 LTS Uninstaller for Termux${NC}"
echo -e "${BOLD}================================================${NC}"
echo ""

# Cek apakah Ubuntu terinstall
if [ ! -d "$UBUNTU_DIR" ]; then
  warning "Ubuntu tidak ditemukan di $UBUNTU_DIR"
  exit 0
fi

echo -e "${YELLOW}Semua data Ubuntu akan dihapus permanen!${NC}"
echo ""
read -p "Lanjutkan? (y/n): " confirm
if [ "$confirm" != "y" ]; then
  info "Uninstall dibatalkan"
  exit 0
fi

echo ""

# Hapus folder Ubuntu
if [ -d "$UBUNTU_DIR" ]; then
  echo -n "Menghapus folder Ubuntu... "
  rm -rf "$UBUNTU_DIR"
  echo -e "${GREEN}selesai${NC}"
fi

# Hapus file rootfs
if [ -f "$ROOTFS_FILE" ]; then
  echo -n "Menghapus file rootfs... "
  rm -f "$ROOTFS_FILE"
  echo -e "${GREEN}selesai${NC}"
fi

# Hapus semua start script
echo -n "Menghapus start script... "
rm -f "$HOME"/.start-ubuntu*.sh
echo -e "${GREEN}selesai${NC}"

# Hapus alias dari .bashrc dan .zshrc
echo -n "Menghapus alias dari shell config... "
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [ -f "$RC" ]; then
    sed -i '/alias ubuntu/d' "$RC"
  fi
done
echo -e "${GREEN}selesai${NC}"

echo ""
echo -e "${GREEN}Ubuntu berhasil diuninstall!${NC}"
echo ""

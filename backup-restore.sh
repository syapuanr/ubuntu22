#!/bin/bash

# ================================================
#   Ubuntu 22.04 LTS Backup & Restore for Termux
# ================================================

UBUNTU_DIR="$HOME/.ubuntu22"
BACKUP_DIR="$HOME/storage/downloads"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[x]${NC} $1"; exit 1; }
step()    { echo -e "${BLUE}[*]${NC} $1"; }

echo ""
echo -e "${BOLD}================================================${NC}"
echo -e "${BOLD}   Ubuntu 22.04 LTS Backup & Restore${NC}"
echo -e "${BOLD}================================================${NC}"
echo ""
echo " 1) Backup Ubuntu"
echo " 2) Restore Ubuntu"
echo " 3) Keluar"
echo ""
read -p "Pilihan (1-3): " choice

case "$choice" in
  1)
    # BACKUP
    if [ ! -d "$UBUNTU_DIR" ]; then
      error "Ubuntu tidak ditemukan, tidak ada yang di-backup"
    fi

    BACKUP_FILE="ubuntu22-backup-$(date +%Y%m%d-%H%M%S).tar.gz"

    # Cek apakah storage tersedia
    if [ -d "$HOME/storage/downloads" ]; then
      BACKUP_PATH="$HOME/storage/downloads/$BACKUP_FILE"
    else
      BACKUP_PATH="$HOME/$BACKUP_FILE"
      warning "Storage tidak tersedia, backup disimpan di home Termux"
    fi

    step "Membuat backup ke $BACKUP_PATH..."
    step "Ini mungkin memakan waktu beberapa menit..."
    tar --exclude='proc' --exclude='sys' --exclude='dev' \
      -czf "$BACKUP_PATH" -C "$HOME" .ubuntu22 2>/dev/null
    info "Backup selesai: $BACKUP_PATH"
    ;;

  2)
    # RESTORE
    echo ""
    echo "Masukkan path file backup:"
    echo "Contoh: /sdcard/Download/ubuntu22-backup-20260228.tar.gz"
    echo ""
    read -p "Path: " RESTORE_FILE

    if [ ! -f "$RESTORE_FILE" ]; then
      error "File tidak ditemukan: $RESTORE_FILE"
    fi

    if [ -d "$UBUNTU_DIR" ]; then
      warning "Ubuntu sudah ada, akan ditimpa!"
      read -p "Lanjutkan? (y/n): " confirm
      [ "$confirm" = "y" ] || { info "Dibatalkan"; exit 0; }
      rm -rf "$UBUNTU_DIR"
    fi

    step "Merestore backup..."
    tar -xzf "$RESTORE_FILE" -C "$HOME" 2>/dev/null || error "Gagal restore"
    info "Restore selesai! Jalankan: ubuntu"
    ;;

  *)
    info "Keluar"
    exit 0
    ;;
esac

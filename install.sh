#!/bin/bash

# ================================================
#   Ubuntu 22.04 LTS Manual Installer for Termux
#   Tanpa proot-distro
# ================================================

# Konfigurasi
UBUNTU_DIR="$HOME/.ubuntu22"
ROOTFS_FILE="$HOME/.ubuntu-base-arm64.tar.gz"
START_SCRIPT="$HOME/.start-ubuntu.sh"

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[x]${NC} $1"; exit 1; }
step()    { echo -e "${BLUE}[*]${NC} $1"; }
title()   { echo -e "\n${BOLD}${CYAN}$1${NC}"; }

# ------------------------------------------------
# Deteksi arsitektur
# ------------------------------------------------
detect_arch() {
  ARCH=$(uname -m)
  case "$ARCH" in
    aarch64|arm64)
      ROOTFS_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-arm64.tar.gz"
      ARCH_NAME="arm64"
      ;;
    x86_64)
      ROOTFS_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-amd64.tar.gz"
      ARCH_NAME="amd64"
      ;;
    armv7l|armv8l)
      ROOTFS_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-armhf.tar.gz"
      ARCH_NAME="armhf"
      ;;
    *)
      error "Arsitektur $ARCH tidak didukung"
      ;;
  esac
  info "Arsitektur terdeteksi: $ARCH_NAME"
}

# ------------------------------------------------
# Banner
# ------------------------------------------------
echo ""
echo -e "${BOLD}================================================${NC}"
echo -e "${BOLD}   Ubuntu 22.04 LTS Installer for Termux${NC}"
echo -e "${BOLD}================================================${NC}"
echo ""

# ------------------------------------------------
# Cek instalasi sebelumnya
# ------------------------------------------------
if [ -d "$UBUNTU_DIR" ]; then
  warning "Ubuntu sudah terinstall di $UBUNTU_DIR"
  echo ""
  echo " 1) Install ulang (hapus yang lama)"
  echo " 2) Batalkan"
  echo ""
  read -p "Pilihan (1/2): " choice
  case "$choice" in
    1)
      step "Menghapus instalasi lama..."
      rm -rf "$UBUNTU_DIR"
      info "Instalasi lama dihapus"
      ;;
    *)
      info "Instalasi dibatalkan"
      exit 0
      ;;
  esac
fi

# ------------------------------------------------
# Step 1: Deteksi arsitektur
# ------------------------------------------------
title "[ Step 1/6 ] Deteksi Arsitektur"
detect_arch

# ------------------------------------------------
# Step 2: Install dependencies
# ------------------------------------------------
title "[ Step 2/6 ] Install Dependencies"
step "Mengupdate package Termux..."
apt-get update -y > /dev/null 2>&1
apt-get install proot wget tar -y > /dev/null 2>&1
info "Dependencies terinstall"

# ------------------------------------------------
# Step 3: Download rootfs dengan progress bar
# ------------------------------------------------
title "[ Step 3/6 ] Download Rootfs Ubuntu 22.04"
if [ -f "$ROOTFS_FILE" ]; then
  warning "File rootfs sudah ada, skip download"
else
  step "Mendownload Ubuntu 22.04 LTS ($ARCH_NAME)..."
  wget --progress=bar:force "$ROOTFS_URL" -O "$ROOTFS_FILE" 2>&1 \
    || error "Gagal download rootfs"
fi
info "Download selesai"

# ------------------------------------------------
# Step 4: Ekstrak rootfs
# ------------------------------------------------
title "[ Step 4/6 ] Ekstrak Rootfs"
step "Mengekstrak rootfs..."
mkdir -p "$UBUNTU_DIR"
proot --link2symlink tar -xzf "$ROOTFS_FILE" \
  --exclude='dev' -C "$UBUNTU_DIR" 2>/dev/null || true
info "Ekstraksi selesai"

# ------------------------------------------------
# Step 5: Konfigurasi dasar
# ------------------------------------------------
title "[ Step 5/6 ] Konfigurasi Dasar"

# DNS
step "Mengkonfigurasi DNS..."
echo "nameserver 8.8.8.8" > "$UBUNTU_DIR/etc/resolv.conf"
echo "nameserver 1.1.1.1" >> "$UBUNTU_DIR/etc/resolv.conf"
info "DNS dikonfigurasi"

# Fix group ID otomatis
step "Memperbaiki group ID..."
for GID in $(id -G); do
  if ! grep -q ":$GID:" "$UBUNTU_DIR/etc/group" 2>/dev/null; then
    echo "group$GID:x:$GID:" >> "$UBUNTU_DIR/etc/group"
  fi
done
info "Group ID diperbaiki"



# Support storage Termux
step "Mengkonfigurasi akses storage..."
mkdir -p "$UBUNTU_DIR/sdcard"
info "Mount point /sdcard disiapkan"

# Rapikan prompt
cat >> "$UBUNTU_DIR/root/.bashrc" << 'EOF'

# Custom prompt
PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
EOF

# ------------------------------------------------
# Step 6: Buat start script & alias
# ------------------------------------------------
title "[ Step 6/6 ] Buat Start Script & Alias"

cat > "$START_SCRIPT" << 'EOF'
#!/bin/bash
unset LD_PRELOAD
proot \
  --link2symlink \
  -0 \
  -r ~/.ubuntu22 \
  -w /root \
  -b /dev \
  -b /proc \
  -b /sys \
  -b /data/data/com.termux/files/usr/tmp:/dev/shm \
  -b /sdcard:/sdcard \
  /usr/bin/env -i \
  HOME=/root \
  TERM="$TERM" \
  LANG=C.UTF-8 \
  PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin \
  /bin/bash --login
EOF
chmod +x "$START_SCRIPT"
info "Start script dibuat"

for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$RC" ] || touch "$RC"
  if ! grep -q "alias ubuntu=" "$RC" 2>/dev/null; then
    echo "alias ubuntu='~/.start-ubuntu.sh'" >> "$RC"
    info "Alias 'ubuntu' ditambahkan ke $RC"
  else
    warning "Alias 'ubuntu' sudah ada di $RC, skip"
  fi
done

# ------------------------------------------------
# Selesai
# ------------------------------------------------
echo ""
echo -e "${BOLD}${GREEN}================================================${NC}"
echo -e "${BOLD}${GREEN}   Instalasi selesai!${NC}"
echo -e "${BOLD}${GREEN}================================================${NC}"
echo ""
echo -e " ${BOLD}Cara masuk Ubuntu:${NC}"
echo "   ubuntu  (setelah source ~/.bashrc)"
echo "   atau: ~/.start-ubuntu.sh"
echo ""
echo -e " ${BOLD}Akses storage HP dari Ubuntu:${NC}"
echo "   cd /sdcard"
echo ""
echo " Jalankan: source ~/.bashrc"
echo ""

# Ubuntu 22.04 LTS di Termux

Install Ubuntu 22.04 LTS secara manual di Termux tanpa proot-distro.

## Fitur

- Ubuntu **22.04 LTS (Jammy)** — stabil & didukung jangka panjang
- Deteksi arsitektur otomatis (arm64, amd64, armhf)
- Progress bar saat download
- Semua file tersembunyi, home Termux tetap bersih
- Fix group ID otomatis (universal, semua HP)
- Akses storage HP dari Ubuntu (`/sdcard`)
- Alias `ubuntu` otomatis (support bash & zsh)
- Script backup & restore
- Script uninstall bersih
- Tidak perlu root
- Tidak menggunakan proot-distro

## Cara Install

```bash
# Clone repo
git clone https://github.com/USERNAME/REPO_NAME.git
cd REPO_NAME

# Beri izin execute
chmod +x install.sh uninstall.sh backup-restore.sh

# Jalankan installer
./install.sh
```

## Cara Masuk Ubuntu

Setelah install selesai:
```bash
source ~/.bashrc

# Masuk Ubuntu
ubuntu
```

## Akses Storage HP

Di dalam Ubuntu, storage HP bisa diakses di `/sdcard`:
```bash
cd /sdcard
ls
```

## Backup & Restore

```bash
./backup-restore.sh
```

Pilih 1 untuk backup, 2 untuk restore. File backup disimpan di folder Downloads HP.

## Uninstall

```bash
./uninstall.sh
```

## Lokasi File

Semua file tersimpan tersembunyi di home Termux:

| File | Lokasi |
|---|---|
| Rootfs Ubuntu | `~/.ubuntu22` |
| Start script | `~/.start-ubuntu.sh` |
| Rootfs tarball | `~/.ubuntu-base-arm64.tar.gz` |

## Arsitektur yang Didukung

| Arsitektur | Keterangan |
|---|---|
| arm64 / aarch64 | HP Android modern (paling umum) |
| armhf / armv7 | HP Android lama |
| amd64 / x86_64 | Emulator atau PC |

## Info

- Ubuntu versi: **22.04 LTS (Jammy Jellyfish)**
- Diuji di: Termux (F-Droid)

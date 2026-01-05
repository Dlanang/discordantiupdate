#!/bin/bash

echo "Memulai update Discord..."

# 1. Download versi terbaru langsung dari endpoint API Discord
# Menggunakan -O untuk menamai file output agar konsisten
echo "Mengunduh paket .deb terbaru..."
wget -O /tmp/discord-latest.deb "https://discord.com/api/download?platform=linux&format=deb"

# Cek apakah download berhasil
if [ $? -ne 0 ]; then
    echo "Gagal mengunduh. Periksa koneksi internet Anda."
    exit 1
fi

# 2. Install paket
echo "Menginstall paket..."
# Menggunakan apt-get install agar dependensi otomatis diperbaiki jika ada yang kurang
sudo apt-get install /tmp/discord-latest.deb -y

# 3. Bersihkan file sampah
rm /tmp/discord-latest.deb

echo "Update selesai! Silakan restart Discord."
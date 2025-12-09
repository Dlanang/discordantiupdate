#!/bin/bash

# Script anti-update Discord untuk Debian/Ubuntu
# Mendukung instalasi dari .deb atau flatpak

# Cek root
if [[ $EUID -ne 0 ]]; then
   echo "[!] Jalankan sebagai root! (sudo ./discorddebian.sh)"
   exit 1
fi

# Deteksi lokasi instalasi Discord
DISCORD_PATH=""
if [[ -d "/usr/share/discord" ]]; then
    DISCORD_PATH="/usr/share/discord"
    echo "[*] Discord ditemukan di: /usr/share/discord (instalasi .deb)"
elif [[ -d "/opt/discord" ]]; then
    DISCORD_PATH="/opt/discord"
    echo "[*] Discord ditemukan di: /opt/discord"
else
    echo "[!] Discord tidak ditemukan!"
    echo "[!] Pastikan Discord sudah terinstal melalui:"
    echo "    - Package .deb dari discord.com"
    echo "    - apt install discord"
    exit 1
fi

RESOURCE_PATH="$DISCORD_PATH/resources"
ASAR="$RESOURCE_PATH/app.asar"
ASAR_BAK="$RESOURCE_PATH/app.asar.bak"
UNPACKED="$RESOURCE_PATH/app-unpacked"
SPLASH_JS="$UNPACKED/app_bootstrap/splashScreen.js"

# Cek dependensi Node.js dan npm
if ! command -v npx &> /dev/null; then
    echo "[!] npx tidak ditemukan. Menginstall Node.js..."
    echo "[*] Apakah Anda ingin menginstall nodejs dan npm? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        apt update
        apt install -y nodejs npm
        if ! command -v npx &> /dev/null; then
            echo "[!] Instalasi nodejs gagal. Install manual dengan:"
            echo "    sudo apt install nodejs npm"
            exit 1
        fi
    else
        echo "[!] npx diperlukan. Install dengan: sudo apt install nodejs npm"
        exit 1
    fi
fi

# Cek apakah asar tersedia
if ! command -v asar &> /dev/null && ! npx asar --version &> /dev/null 2>&1; then
    echo "[!] asar tidak ditemukan. Menginstall..."
    npm install -g asar || {
        echo "[!] Gagal menginstall asar. Coba manual: sudo npm install -g asar"
        exit 1
    }
fi

# Cek apakah file asar ada
if [[ ! -f "$ASAR" ]]; then
    echo "[!] File app.asar tidak ditemukan di: $ASAR"
    exit 1
fi

# Buat backup
if [[ ! -f "$ASAR_BAK" ]]; then
    echo "[+] Membuat backup app.asar -> app.asar.bak..."
    cp "$ASAR" "$ASAR_BAK"
else
    echo "[*] Backup sudah ada: $ASAR_BAK"
    echo "[*] Apakah ingin menggunakan backup yang ada? (y/n)"
    read -r use_backup
    if [[ "$use_backup" =~ ^[Yy]$ ]]; then
        echo "[+] Menggunakan backup lama..."
    else
        echo "[+] Membuat backup baru..."
        cp "$ASAR" "$ASAR_BAK"
    fi
fi

echo "[+] Extracting app.asar..."
rm -rf "$UNPACKED"
npx asar extract "$ASAR" "$UNPACKED" || exit 1

# Cek apakah file splashScreen.js ada
if [[ ! -f "$SPLASH_JS" ]]; then
    echo "[!] File splashScreen.js tidak ditemukan di: $SPLASH_JS"
    echo "[!] Struktur Discord mungkin berubah. Periksa secara manual."
    exit 1
fi

echo "[+] Patching splashScreen.js..."
# Tambahkan patch sebelum baris terakhir fungsi initSplash
sed -i '/_ipcMain\.default\.on.*UPDATED_QUOTES.*/a \
  setTimeout(() => {\n    console.log("[FORCE PATCH] Forcing Discord to launch main window.");\n    launchMainWindow();\n  }, 500);' "$SPLASH_JS"

# Verifikasi patch berhasil
if grep -q "FORCE PATCH" "$SPLASH_JS"; then
    echo "[+] Patch berhasil diterapkan!"
else
    echo "[!] Patch mungkin gagal. Periksa file secara manual."
fi

echo "[+] Repacking app.asar..."
mv "$ASAR" "$ASAR.tmp"
npx asar pack "$UNPACKED" "$ASAR" || { 
    echo "[!] Repack gagal, restore backup..."
    mv "$ASAR.tmp" "$ASAR"
    exit 1
}
rm "$ASAR.tmp"

# Set permission yang benar
chmod 644 "$ASAR"
chown root:root "$ASAR"

echo ""
echo "[+] =========================================="
echo "[+] Patch selesai! Anti-update telah aktif."
echo "[+] =========================================="
echo ""
echo "[+] Jalankan Discord dengan:"
echo "    discord"
echo ""
echo "[*] Untuk restore backup:"
echo "    sudo cp $ASAR_BAK $ASAR"
echo ""
echo "[*] Untuk mencegah update otomatis, Anda juga bisa:"
echo "    - Disable auto-update di Discord settings"
echo "    - Hold package: sudo apt-mark hold discord"
echo ""

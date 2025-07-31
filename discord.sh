#!/bin/bash

DISCORD_PATH="/opt/discord"
RESOURCE_PATH="$DISCORD_PATH/resources"
ASAR="$RESOURCE_PATH/app.asar"
UNPACKED="$RESOURCE_PATH/app-unpacked"
SPLASH_JS="$UNPACKED/app_bootstrap/splashScreen.js"

# Cek root
if [[ $EUID -ne 0 ]]; then
   echo "[!] Jalankan sebagai root!"
   exit 1
fi

# Cek dependensi
if ! command -v npx &> /dev/null; then
    echo "[!] npx tidak ditemukan. Install Node.js terlebih dahulu."
    exit 1
fi

echo "[+] Extracting app.asar..."
rm -rf "$UNPACKED"
npx asar extract "$ASAR" "$UNPACKED" || exit 1

echo "[+] Patching splashScreen.js..."
# Tambahkan patch sebelum baris terakhir fungsi initSplash
sed -i '/_ipcMain\.default\.on.*UPDATED_QUOTES.*/a \
  setTimeout(() => {\n    console.log("[FORCE PATCH] Forcing Discord to launch main window.");\n    launchMainWindow();\n  }, 500);' "$SPLASH_JS"

echo "[+] Repacking app.asar..."
mv "$ASAR" "$ASAR.bak"
npx asar pack "$UNPACKED" "$ASAR" || { echo "[!] Repack gagal, restore backup..."; mv "$ASAR.bak" "$ASAR"; exit 1; }
rm "$ASAR.bak"

echo "[+] Patch selesai! Jalankan Discord dengan:"
echo "    discord"

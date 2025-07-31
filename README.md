# 🚫 Discord Anti Update (for Arch Linux)

Script shell untuk **memblokir auto-update Discord** pada Arch Linux. Cocok digunakan jika kamu ingin mempertahankan versi tertentu dari Discord (misalnya karena modifikasi, kompatibilitas plugin, atau kestabilan).

---

## 📦 Fitur

* Menghapus updater bawaan Discord.
* Modifikasi app.asar/splashupdate.js
* Otomatis backup sebelum modifikasi.
* Sederhana dan cepat dijalankan.

---

## 📁 Struktur File

File utama:

* `discord.sh` — script bash utama untuk melakukan patch.

---

## ⚙️ Cara Penggunaan

### 1. **Pastikan Discord sudah terinstal**

Pastikan kamu menginstal Discord dari `pacman`, `yay`, atau `flatpak`. Script ini ditujukan untuk **versi dari AUR atau repo** (bukan Flatpak/Snap/AppImage).

### 2. **Jalankan script**

```bash
chmod +x discord.sh
sudo ./discord.sh
```

Script akan:

* Memastikan direktori Discord terdeteksi.
* Menghapus updater.
  
### 3. **Jalankan Discord seperti biasa**

```bash
discord
```

---

## 🛠️ Contoh Output

```bash
[+] Extracting app.asar...
[+] Patching splashScreen.js...
[+] Repacking app.asar...
[+] Patch selesai! Jalankan Discord dengan:
    discord
```

---

## 🧼 Revert (Restore)

Jika kamu ingin **mengembalikan fungsi update**, cukup hapus symlink dan restore backup:

```bash
cd /opt/discord/resources/
ls
app.asar.bak
# restore dari backup jika ada
```

---

## ⚠️ Disclaimer

* Script ini **tidak didukung oleh Discord Inc.** Gunakan atas tanggung jawab sendiri.
* Update manual harus dilakukan melalui AUR atau rebuild Discord.
* Jika kamu menggunakan mod seperti **BetterDiscord**, hindari update otomatis untuk menjaga kompatibilitas.

---

## 💻 Tested On

* ✅ Arch Linux (latest, July 2025)
* ✅ Discord dari AUR (`discord`)

---

## 📜 License

MIT License

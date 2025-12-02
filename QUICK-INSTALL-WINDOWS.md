# ⚡ SCHNELL-ANLEITUNG: Windows App installieren

## 🎯 **3 SCHRITTE**

### **1️⃣ Auf Mac: Installer erstellen**

```bash
# Terminal öffnen
cd /Users/maxjacob/Documents/focus-coach

# Web-App bauen
npm run build

# Windows Installer erstellen
cd windows-desktop
npm install  # Falls noch nicht gemacht
npm run build
```

**Ergebnis:** `windows-desktop/dist/FocusCoach-Setup-1.0.0.exe` (~100-150 MB)

**Dauer:** ~5-10 Minuten

---

### **2️⃣ Installer auf Windows PC übertragen**

**Einfachste Methode:**
- USB-Stick einstecken
- `FocusCoach-Setup-1.0.0.exe` drauf kopieren
- Auf Windows PC kopieren

**Oder:**
- Cloud (Dropbox, Google Drive, iCloud)
- AirDrop (wenn beide Geräte im gleichen Netzwerk)

---

### **3️⃣ Auf Windows PC: Installieren**

1. **Rechtsklick** auf `FocusCoach-Setup-1.0.0.exe`
2. **"Als Administrator ausführen"** ⚠️ **WICHTIG!**
3. **Windows Warnung:** 
   - "Weitere Informationen" → "Trotzdem ausführen"
   - (Kommt weil kein Code-Signing)
4. **Installation folgen**
5. **Fertig!** ✅

---

## 🚀 **App starten**

- Desktop Shortcut doppelklicken
- ODER Startmenü → "FocusCoach"

**Wichtig:** Immer als Administrator starten für Blockierung!

---

## ⚠️ **TROUBLESHOOTING**

**Installer startet nicht?**
- ✅ Als Administrator ausführen
- ✅ Windows Defender temporär deaktivieren

**Blockierung funktioniert nicht?**
- ✅ App als Administrator starten
- ✅ Admin-Rechte testen: CMD öffnen → `net session`

---

## 📝 **DETAILLIERTE ANLEITUNG**

Siehe: `WINDOWS-INSTALLATION-GUIDE.md`


# 🪟 WINDOWS APP INSTALLATION - KOMPLETTE ANLEITUNG

## 🎯 **SCHRITT-FÜR-SCHRITT**

### **Schritt 1: Auf deinem Mac - Web-App bauen**

```bash
# Terminal öffnen
cd /Users/maxjacob/Documents/focus-coach

# Web-App bauen
npm run build
```

**Erwartung:** `dist/` Ordner wird erstellt mit gebauter Web-App

---

### **Schritt 2: Auf deinem Mac - Windows Installer erstellen**

```bash
# In windows-desktop Ordner wechseln
cd windows-desktop

# Dependencies installieren (falls noch nicht gemacht)
npm install

# Windows Installer bauen
npm run build
```

**Erwartung:** 
- `windows-desktop/dist/FocusCoach-Setup-1.0.0.exe` wird erstellt
- Dateigröße: ~100-150 MB

**Wichtig:** 
- Das kann 5-10 Minuten dauern
- Du musst auf Mac sein (oder Windows PC mit Node.js)

---

### **Schritt 3: Installer auf Windows PC übertragen**

**Option A: USB-Stick**
1. USB-Stick einstecken
2. `FocusCoach-Setup-1.0.0.exe` auf USB kopieren
3. USB auf Windows PC einstecken
4. Datei kopieren

**Option B: Cloud (Dropbox, Google Drive, iCloud)**
1. `FocusCoach-Setup-1.0.0.exe` in Cloud hochladen
2. Auf Windows PC herunterladen

**Option C: AirDrop (wenn beide Geräte Mac/Windows in gleichem Netzwerk)**
1. AirDrop öffnen
2. Datei senden

**Option D: GitHub Releases (für später)**
1. GitHub Release erstellen
2. Installer hochladen
3. Von Windows PC herunterladen

---

### **Schritt 4: Auf Windows PC - Installer ausführen**

1. **Datei finden:** `FocusCoach-Setup-1.0.0.exe`
2. **Rechtsklick** → **"Als Administrator ausführen"** ⚠️ **WICHTIG!**
   - Warum? Blockierung benötigt Admin-Rechte
3. **Windows Warnung:** 
   - "Windows hat den PC geschützt"
   - Klicke auf **"Weitere Informationen"**
   - Dann **"Trotzdem ausführen"**
   - (Das kommt, weil wir noch kein Code-Signing haben)
4. **Installation folgen:**
   - Installationspfad wählen (Standard: `C:\Program Files\FocusCoach`)
   - Desktop Shortcut erstellen? ✅ Ja
   - Startmenü Eintrag? ✅ Ja
5. **Fertig!** ✅

---

### **Schritt 5: App starten**

1. **Desktop Shortcut** doppelklicken
   - ODER
2. **Startmenü** → "FocusCoach" suchen
3. **App öffnet sich**
4. **Einloggen** mit deinem Firebase Account

---

## ⚠️ **WICHTIGE HINWEISE**

### **Admin-Rechte**
- **Immer als Administrator starten** für Blockierung
- Oder: Rechtsklick auf Shortcut → "Als Administrator ausführen"

### **Windows Defender / Antivirus**
- Mögliche Warnung beim Installieren (kein Code-Signing)
- Das ist normal - einfach "Trotzdem ausführen" wählen

### **Firewall**
- Windows Firewall kann fragen, ob App erlaubt werden soll
- **"Zugriff erlauben"** wählen

---

## 🔧 **TROUBLESHOOTING**

### **Problem: Installer startet nicht**
- ✅ Als Administrator ausführen
- ✅ Windows Defender deaktivieren (temporär)
- ✅ Antivirus prüfen

### **Problem: App startet nicht**
- ✅ Als Administrator starten
- ✅ Windows Event Viewer prüfen (Fehler-Logs)
- ✅ `%APPDATA%\FocusCoach\logs` prüfen

### **Problem: Blockierung funktioniert nicht**
- ✅ App als Administrator starten
- ✅ Windows Firewall prüfen
- ✅ Admin-Rechte testen: `net session` im CMD

### **Problem: Web-App lädt nicht**
- ✅ Internet-Verbindung prüfen
- ✅ Firebase Config prüfen
- ✅ DevTools öffnen (F12) → Console prüfen

---

## 📦 **INSTALLER-DATEIEN**

### **Was wird installiert:**
```
C:\Program Files\FocusCoach\
├── FocusCoach.exe          # Haupt-App
├── resources\
│   ├── app.asar            # Deine Web-App (gepackt)
│   └── electron.asar        # Electron Runtime
└── ...
```

### **User-Daten:**
```
%APPDATA%\FocusCoach\
├── logs\                    # Log-Dateien
└── ...
```

---

## 🚀 **SCHNELLSTART (ZUSAMMENFASSUNG)**

```bash
# 1. Auf Mac: Web-App bauen
cd /Users/maxjacob/Documents/focus-coach
npm run build

# 2. Auf Mac: Installer erstellen
cd windows-desktop
npm run build

# 3. Installer übertragen (USB/Cloud)

# 4. Auf Windows: Als Administrator installieren
# 5. App starten & einloggen
```

---

## 📝 **NÄCHSTE SCHRITTE NACH INSTALLATION**

1. ✅ **Einloggen** mit Firebase Account
2. ✅ **Blocklisten erstellen** (Settings → Blockierung)
3. ✅ **Task mit Blockliste erstellen**
4. ✅ **Task starten** → Blockierung sollte aktiviert werden
5. ✅ **Testen** ob Apps/URLs blockiert werden

---

## 🎉 **FERTIG!**

Die App sollte jetzt auf deinem Windows PC laufen!

**Features die jetzt funktionieren:**
- ✅ Task-Management
- ✅ Windows Firewall Blockierung
- ✅ URL-Blockierung (Hosts-Datei)
- ✅ System Tray Integration
- ✅ Desktop Notifications
- ✅ Firebase Synchronisation


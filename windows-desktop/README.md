# 🪟 FOCUSCOACH WINDOWS DESKTOP APP

## 🚀 **QUICK START**

### **Voraussetzungen**
- Node.js 18+ installiert
- Windows 10/11
- Admin-Rechte für Blockierung (wird beim Start abgefragt)

### **Entwicklung**

```bash
# 1. Installiere Dependencies
npm install

# 2. Starte Web-App (in separatem Terminal)
cd ..
npm run dev

# 3. Starte Electron App
cd windows-desktop
npm run dev
```

### **Build für Distribution**

```bash
# Build Web-App
cd ..
npm run build

# Build Electron App
cd windows-desktop
npm run build
npm run dist
```

---

## 📦 **STRUKTUR**

```
windows-desktop/
├── main/                    # Electron Main Process
│   ├── main.js             # App Entry Point
│   └── preload.js          # Preload Script (Bridge)
├── native/                  # Native Windows Modules
│   └── blocking/
│       └── firewall.js     # Windows Firewall Integration
├── assets/                  # Icons, Images
└── package.json            # Electron Config
```

---

## 🔒 **BLOCKIERUNG**

Die Windows App nutzt:
- **Windows Firewall** für App-Blockierung
- **Hosts-Datei** für URL-Blockierung

### **Features**
- ✅ App-Blockierung über Firewall
- ✅ URL-Blockierung über Hosts-Datei
- ✅ Synchronisiert mit iPhone/Mac über Firebase
- ✅ System Tray Integration
- ✅ Desktop Notifications
- ✅ Auto-Updater

---

## 🔧 **INTEGRATION MIT WEB-APP**

Die Windows App nutzt die **bestehende Web-App** als Renderer:
- Web-App läuft auf `http://localhost:3000` (Development)
- Oder als gebaute Version (Production)
- Electron lädt die Web-App in einem BrowserWindow

---

## 📋 **NÄCHSTE SCHRITTE**

1. ✅ Electron-Projekt Setup
2. ⏳ Windows Blockierung implementieren
3. ⏳ System Tray & Notifications
4. ⏳ Installer erstellen
5. ⏳ Analytics-System hinzufügen

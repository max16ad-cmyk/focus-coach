# 📥 DOWNLOAD-SETUP FÜR WINDOWS APP

## ✅ **WAS WURDE IMPLEMENTIERT**

### **1. Download-Button im Header** ✅
- Erscheint nur wenn **NICHT** in Electron (also im Browser)
- Zeigt "Windows App" Button
- Direkter Download-Link

### **2. Download-Banner** ✅ (Optional)
- Banner am unteren Bildschirmrand
- Nur auf Windows sichtbar
- Kann in Welcome Screen eingebaut werden

---

## 🔧 **SETUP**

### **Schritt 1: Download-URL konfigurieren**

**Datei:** `components/WindowsDownload.tsx`

**Option A: GitHub Releases (Empfohlen)**
```typescript
const downloadUrl = 'https://github.com/DEIN-USERNAME/focus-coach/releases/latest/download/FocusCoach-Setup-1.0.0.exe';
```

**Option B: Firebase Storage**
```typescript
const downloadUrl = 'https://firebasestorage.googleapis.com/v0/b/get-shit-done-c422f.appspot.com/o/FocusCoach-Setup-1.0.0.exe?alt=media';
```

**Option C: Eigener Server**
```typescript
const downloadUrl = 'https://deine-domain.com/downloads/FocusCoach-Setup-1.0.0.exe';
```

---

### **Schritt 2: Installer hochladen**

#### **Option A: GitHub Releases**

1. **GitHub Release erstellen:**
   ```bash
   # Auf GitHub:
   # 1. Repository öffnen
   # 2. "Releases" → "Draft a new release"
   # 3. Tag: v1.0.0
   # 4. Title: FocusCoach Windows Desktop App v1.0.0
   # 5. Upload: FocusCoach-Setup-1.0.0.exe
   # 6. "Publish release"
   ```

2. **Download-URL:**
   ```
   https://github.com/DEIN-USERNAME/focus-coach/releases/latest/download/FocusCoach-Setup-1.0.0.exe
   ```

#### **Option B: Firebase Storage**

1. **Firebase Console öffnen:**
   - https://console.firebase.google.com
   - Projekt: `get-shit-done-c422f`
   - Storage → Files

2. **Installer hochladen:**
   ```bash
   # Via Firebase CLI
   firebase storage:upload FocusCoach-Setup-1.0.0.exe downloads/
   
   # Oder manuell in Console
   # Upload → FocusCoach-Setup-1.0.0.exe
   ```

3. **Download-URL kopieren:**
   - Rechtsklick auf Datei → "Get download URL"
   - URL in `WindowsDownload.tsx` eintragen

#### **Option C: Eigener Server**

1. **Installer auf Server hochladen:**
   ```bash
   scp FocusCoach-Setup-1.0.0.exe user@server:/var/www/downloads/
   ```

2. **Download-URL:**
   ```
   https://deine-domain.com/downloads/FocusCoach-Setup-1.0.0.exe
   ```

---

### **Schritt 3: URL in Komponente eintragen**

**Datei:** `components/WindowsDownload.tsx`

```typescript
// Zeile 18 - Download URL aktualisieren
const downloadUrl = 'DEINE-DOWNLOAD-URL-HIER';
```

---

## 🎨 **ANPASSUNGEN**

### **Download-Button ausblenden**

Wenn du den Button nicht anzeigen willst:

```typescript
// In Dashboard.tsx - Zeile entfernen:
<WindowsDownload />
```

### **Banner hinzufügen**

Wenn du den Banner am unteren Rand willst:

```typescript
// In Dashboard.tsx oder PremiumWelcome.tsx
import { WindowsDownloadBanner } from './WindowsDownload';

// Im JSX:
<WindowsDownloadBanner />
```

### **Button-Text ändern**

```typescript
// In WindowsDownload.tsx
<span className="hidden sm:inline">Dein Text</span>
```

---

## 📊 **DOWNLOAD-TRACKING**

### **Google Analytics (Optional)**

Wenn du Google Analytics nutzt, wird automatisch getrackt:

```typescript
// Automatisch in handleDownload()
gtag('event', 'download', {
  'event_category': 'Windows App',
  'event_label': 'Desktop App Download'
});
```

### **Firebase Analytics (Optional)**

```typescript
// In handleDownload() hinzufügen:
import { logActivity } from '../services/analytics';

const handleDownload = async () => {
  window.open(downloadUrl, '_blank');
  
  // Track download
  const userId = getCurrentUserId(); // Aus Firebase Auth
  if (userId) {
    await logActivity(userId, 'web', 'app_downloaded', {
      platform: 'windows',
      source: 'web_app'
    });
  }
};
```

---

## ✅ **TESTEN**

1. **Web-App öffnen** (im Browser, nicht Electron)
2. **Download-Button sollte im Header erscheinen**
3. **Klick auf Button** → Download startet
4. **Installer testen** → Auf Windows PC installieren

---

## 🚀 **AUTOMATISIERUNG**

### **GitHub Actions (Optional)**

Automatischer Upload bei Release:

```yaml
# .github/workflows/release.yml
name: Release Windows App

on:
  release:
    types: [created]

jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
      - run: npm install
      - run: npm run build
      - run: cd windows-desktop && npm install && npm run build
      - uses: softprops/action-gh-release@v1
        with:
          files: windows-desktop/dist/FocusCoach-Setup-*.exe
```

---

## 📝 **ZUSAMMENFASSUNG**

**Was wurde gemacht:**
- ✅ Download-Button im Header
- ✅ Automatische Erkennung (nur im Browser, nicht Electron)
- ✅ Windows-Erkennung für Banner
- ✅ Download-Tracking vorbereitet

**Was du tun musst:**
1. ✅ Installer bauen (`npm run build` in `windows-desktop`)
2. ✅ Installer hochladen (GitHub/Firebase/Eigener Server)
3. ✅ URL in `WindowsDownload.tsx` eintragen
4. ✅ Web-App deployen

**Fertig!** 🎉


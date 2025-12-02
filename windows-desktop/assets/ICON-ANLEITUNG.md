# 🎨 ICON ERSTELLUNG FÜR WINDOWS APP

## 📋 **BENÖTIGTE ICONS**

Für die Windows Desktop App werden folgende Icons benötigt:

1. **icon.ico** - Windows Icon (256x256, mehrere Größen enthalten)
2. **icon.png** - PNG Version (512x512 für Tray)

---

## 🛠️ **ICON ERSTELLEN**

### **Option 1: Online Tool**
1. Gehe zu https://convertio.co/png-ico/ oder https://www.icoconverter.com/
2. Lade dein Logo hoch (mindestens 512x512 PNG)
3. Konvertiere zu `.ico` Format
4. Speichere als `icon.ico` in `windows-desktop/assets/`

### **Option 2: Photoshop/GIMP**
1. Erstelle 512x512 PNG
2. Exportiere als ICO mit folgenden Größen:
   - 16x16
   - 32x32
   - 48x48
   - 256x256

### **Option 3: macOS Iconutil**
```bash
# Erstelle iconset
mkdir FocusCoach.iconset
# Füge verschiedene Größen hinzu
# Dann konvertiere:
iconutil -c icns FocusCoach.iconset
```

---

## 📁 **PLATZIERUNG**

Speichere die Icons hier:
```
windows-desktop/assets/
├── icon.ico    # Windows Icon (für Installer)
└── icon.png   # PNG Version (für Tray)
```

---

## ✅ **TEMPORÄRER PLACEHOLDER**

Bis du ein richtiges Icon hast, kannst du:
1. Ein einfaches Icon erstellen (z.B. mit Text "FC")
2. Oder ein bestehendes Logo verwenden
3. Die App funktioniert auch ohne Icon (nutzt Standard-Electron-Icon)

---

## 🎯 **EMPFEHLUNGEN**

- **Größe:** Mindestens 512x512 Pixel
- **Format:** PNG mit transparentem Hintergrund
- **Design:** Einfach, erkennbar, repräsentiert FocusCoach
- **Farben:** Passend zum App-Design (#0a0a0a Background)





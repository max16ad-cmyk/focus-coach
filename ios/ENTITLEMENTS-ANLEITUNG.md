# 📝 ENTITLEMENTS-DATEI IN XCODE ERSTELLEN

## 🎯 **SCHRITT-FÜR-SCHRITT**

### **Schritt 1: Neue Datei erstellen**

1. **In Xcode:**
   - Rechtsklick auf den **`FocusCoach`** Ordner (der blaue Ordner, nicht der gelbe!)
   - Wähle **"New File..."** (oder Cmd+N)

2. **Dateityp wählen:**
   - Suche nach **"Property List"** oder **"plist"**
   - Wähle **"Property List"** → **"Next"**

3. **Datei benennen:**
   - Name: **`FocusCoach`**
   - Stelle sicher, dass **"Also create FocusCoach.entitlements"** NICHT aktiviert ist
   - Wichtig: Der Dateiname sollte **ohne** `.entitlements` sein!
   - Klicke **"Next"**

4. **Speicherort:**
   - Stelle sicher, dass der Speicherort **`FocusCoach`** Ordner ist
   - Klicke **"Create"**

### **Schritt 2: Datei umbenennen**

1. **Im Project Navigator:**
   - Rechtsklick auf die neu erstellte `.plist` Datei
   - Wähle **"Rename"**
   - Benenne um zu: **`FocusCoach.entitlements`**

### **Schritt 3: Inhalt hinzufügen**

1. **Datei öffnen:**
   - Klicke auf `FocusCoach.entitlements` im Project Navigator

2. **Inhalt hinzufügen:**
   - Rechtsklick in die Datei → **"Open As"** → **"Source Code"**
   - Ersetze den gesamten Inhalt mit:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.developer.family-controls</key>
	<true/>
</dict>
</plist>
```

3. **Speichern:** Cmd+S

---

## 🔧 **ALTERNATIVE: Über Terminal**

Falls die Xcode-Methode nicht funktioniert:

1. **Terminal öffnen**
2. **Navigiere zum Projekt:**
   ```bash
   cd /Users/maxjacob/Documents/focus-coach/ios/FocusCoach/FocusCoach
   ```

3. **Erstelle die Datei:**
   ```bash
   cat > FocusCoach.entitlements << 'EOF'
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
   	<key>com.apple.developer.family-controls</key>
   	<true/>
   </dict>
   </plist>
   EOF
   ```

4. **In Xcode:**
   - Rechtsklick auf `FocusCoach` Ordner
   - "Add Files to FocusCoach..."
   - Wähle die `FocusCoach.entitlements` Datei
   - Wichtig: **NICHT** "Copy items if needed" aktivieren
   - Klicke **"Add"**

---

## ✅ **VERIFIKATION**

Nach dem Hinzufügen:

1. **Datei sollte im Project Navigator sichtbar sein**
2. **Build Settings prüfen:**
   - Target → Build Settings
   - Suche nach "Code Signing Entitlements"
   - Wert sollte sein: `FocusCoach/FocusCoach.entitlements`

3. **Falls nicht automatisch:**
   - Setze den Wert manuell auf: `FocusCoach/FocusCoach.entitlements`

---

## 🚨 **WICHTIG**

- Die Datei muss **im `FocusCoach` Ordner** sein (nicht im Root)
- Der Dateiname muss genau **`FocusCoach.entitlements`** sein
- Die Datei muss **im Xcode-Projekt** referenziert sein (nicht nur im Dateisystem)






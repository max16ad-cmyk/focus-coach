# 🔐 XCODE ENTITLEMENTS SETUP - SCREEN TIME API

## 📋 **ÜBERSICHT**

Um die Screen Time API zu nutzen, müssen bestimmte **Entitlements** im Xcode-Projekt konfiguriert werden.

---

## 🔧 **SCHRITT-FÜR-SCHRITT ANLEITUNG**

### **1. Entitlements-Datei erstellen**

1. Öffne Xcode
2. Rechtsklick auf `FocusCoach` Ordner im Project Navigator
3. Wähle **"New File..."**
4. Wähle **"Property List"** → **"Next"**
5. Name: `FocusCoach.entitlements`
6. Speichere im `FocusCoach` Ordner

---

### **2. Entitlements konfigurieren**

Öffne `FocusCoach.entitlements` und füge folgende Keys hinzu:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Family Controls Entitlement -->
    <key>com.apple.developer.family-controls</key>
    <true/>
    
    <!-- Managed Settings Entitlement -->
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.focuscoach.blocking</string>
    </array>
</dict>
</plist>
```

---

### **3. Entitlements im Build Settings verknüpfen**

1. Wähle das **FocusCoach** Projekt im Project Navigator
2. Wähle das **FocusCoach** Target
3. Gehe zu **"Signing & Capabilities"** Tab
4. Unter **"App Groups"** → **"+ Capability"** hinzufügen
5. Erstelle eine neue App Group: `group.com.focuscoach.blocking`
6. Gehe zu **"Build Settings"** Tab
7. Suche nach **"Code Signing Entitlements"**
8. Setze den Wert auf: `FocusCoach/FocusCoach.entitlements`

---

### **4. Frameworks hinzufügen**

1. Wähle das **FocusCoach** Target
2. Gehe zu **"General"** Tab
3. Unter **"Frameworks, Libraries, and Embedded Content"**
4. Klicke **"+"**
5. Füge hinzu:
   - `FamilyControls.framework`
   - `ManagedSettings.framework`

---

### **5. Info.plist konfigurieren**

Öffne `Info.plist` und füge hinzu:

```xml
<key>NSFamilyControlsUsageDescription</key>
<string>Focus Coach benötigt Zugriff auf Screen Time, um Apps und Websites während deiner Tasks zu blockieren.</string>
```

---

## ✅ **VERIFIKATION**

Nach der Konfiguration sollte:

1. ✅ `FocusCoach.entitlements` existieren
2. ✅ Entitlements im Build Settings verknüpft sein
3. ✅ Frameworks hinzugefügt sein
4. ✅ Info.plist Usage Description vorhanden sein

---

## 🚨 **WICHTIGE HINWEISE**

### **App Groups:**
- Die App Group `group.com.focuscoach.blocking` wird für die Synchronisation zwischen App und möglichen Extensions verwendet
- Muss eindeutig sein (z.B. `group.com.deine-domain.appname`)

### **Entitlements:**
- `com.apple.developer.family-controls` ist **erforderlich** für Screen Time API
- Wird von Apple beim App Review geprüft

### **Frameworks:**
- `FamilyControls` → Für App-Auswahl und Authorization
- `ManagedSettings` → Für tatsächliche Blockierung

---

## 📚 **QUELLEN**

- [Apple Family Controls Documentation](https://developer.apple.com/documentation/familycontrols)
- [ManagedSettings Documentation](https://developer.apple.com/documentation/managedsettings)
- [Entitlements Guide](https://developer.apple.com/documentation/bundleresources/entitlements)

---

## 🎯 **NÄCHSTE SCHRITTE**

Nach der Konfiguration:

1. ✅ Projekt neu bauen
2. ✅ Authorization testen
3. ✅ App-Auswahl testen
4. ✅ Blockierung testen






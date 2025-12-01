# 🧪 BLOCKIERUNG TESTEN - SCHRITT-FÜR-SCHRITT

## ⚠️ **WICHTIG: Voraussetzungen**

Bevor du die Blockierung testen kannst, müssen die **Entitlements** in Xcode konfiguriert sein. Siehe `XCODE-ENTITLEMENTS-SETUP.md` für Details.

---

## 📱 **TEST-ANLEITUNG**

### **Schritt 1: Entitlements konfigurieren** (Einmalig)

1. **Entitlements-Datei erstellen:**
   - In Xcode: Rechtsklick auf `FocusCoach` Ordner → "New File..."
   - Wähle "Property List" → Name: `FocusCoach.entitlements`
   - Speichere im `FocusCoach` Ordner

2. **Entitlements konfigurieren:**
   - Öffne `FocusCoach.entitlements`
   - Füge hinzu:
     ```xml
     <key>com.apple.developer.family-controls</key>
     <true/>
     ```

3. **Im Build Settings verknüpfen:**
   - Wähle das **FocusCoach** Target
   - Gehe zu **"Signing & Capabilities"**
   - Klicke **"+ Capability"** → Wähle **"App Groups"**
   - Erstelle: `group.com.focuscoach.blocking`
   - Gehe zu **"Build Settings"**
   - Suche nach **"Code Signing Entitlements"**
   - Setze: `FocusCoach/FocusCoach.entitlements`

4. **Frameworks hinzufügen:**
   - Target → **"General"** Tab
   - Unter **"Frameworks, Libraries, and Embedded Content"**
   - Klicke **"+"** → Füge hinzu:
     - `FamilyControls.framework`
     - `ManagedSettings.framework`

5. **Info.plist erweitern:**
   - Öffne `Info.plist`
   - Füge hinzu:
     ```xml
     <key>NSFamilyControlsUsageDescription</key>
     <string>Focus Coach benötigt Zugriff auf Screen Time, um Apps und Websites während deiner Tasks zu blockieren.</string>
     ```

---

### **Schritt 2: App neu bauen**

1. **Clean Build:**
   - In Xcode: **Product → Clean Build Folder** (Shift+Cmd+K)

2. **Neu bauen:**
   - **Product → Build** (Cmd+B)
   - Warte bis Build erfolgreich ist

3. **App im Simulator starten:**
   - **Product → Run** (Cmd+R)

---

### **Schritt 3: Blockierung einrichten**

1. **Einstellungen öffnen:**
   - In der App: Unten rechts auf **"Einstellungen"** Tab tippen
   - Du siehst die SettingsMainView

2. **Blockierung öffnen:**
   - Tippe auf **"App- & Website-Blockierung"** Card
   - Die BlockingSettingsView öffnet sich

3. **Authorization anfordern:**
   - Tippe auf **"Authorization anfordern"** Button
   - Ein iOS-Dialog erscheint: **"Focus Coach möchte auf Screen Time zugreifen"**
   - Tippe auf **"Erlauben"**
   - ✅ Wenn erfolgreich: Die gelbe Karte verschwindet

---

### **Schritt 4: Apps auswählen**

1. **Apps auswählen:**
   - Tippe auf **"Apps auswählen"** Button
   - Der **FamilyActivityPicker** öffnet sich
   - Wähle Apps aus (z.B. Instagram, TikTok, YouTube)
   - Tippe oben rechts auf **"Fertig"**

2. **Blockierung aktivieren:**
   - Der Toggle **"App-Blockierung"** sollte automatisch aktiviert werden
   - Falls nicht: Aktiviere den Toggle manuell

---

### **Schritt 5: Blockierung testen**

1. **App wechseln:**
   - Verlasse die Focus Coach App (Home-Button oder Swipe)
   - Versuche eine blockierte App zu öffnen (z.B. Instagram)

2. **Erwartetes Verhalten:**
   - ✅ Die App öffnet sich **NICHT**
   - ✅ Stattdessen erscheint ein **Screen Time Shield** mit:
     - App-Icon
     - "Diese App ist blockiert"
     - "Focus Coach blockiert diese App"

3. **Blockierung deaktivieren:**
   - Gehe zurück zu Focus Coach
   - Einstellungen → Blockierung
   - Deaktiviere den Toggle
   - ✅ Die Apps sollten jetzt wieder funktionieren

---

## 🔍 **TROUBLESHOOTING**

### **Problem: "Authorization anfordern" Button funktioniert nicht**

**Lösung:**
- Prüfe, ob Entitlements korrekt konfiguriert sind
- Prüfe, ob Frameworks hinzugefügt wurden
- App neu bauen und neu starten

### **Problem: FamilyActivityPicker öffnet sich nicht**

**Lösung:**
- Prüfe, ob Authorization erfolgreich war
- Prüfe, ob `FamilyControls.framework` hinzugefügt wurde
- Simulator neu starten

### **Problem: Apps werden nicht blockiert**

**Lösung:**
- Prüfe, ob Apps ausgewählt wurden
- Prüfe, ob Toggle aktiviert ist
- Prüfe iOS-Einstellungen: **Einstellungen → Bildschirmzeit → App-Limits**

### **Problem: "Screen Time Authorization erforderlich" bleibt sichtbar**

**Lösung:**
- Authorization wurde verweigert
- Gehe zu: **iOS Einstellungen → Bildschirmzeit → App-Limits**
- Prüfe, ob Focus Coach dort aufgelistet ist
- Falls nicht: App neu installieren und Authorization erneut anfordern

---

## ✅ **ERFOLGS-KRITERIEN**

Die Blockierung funktioniert, wenn:

1. ✅ Authorization erfolgreich erteilt wurde
2. ✅ Apps ausgewählt wurden
3. ✅ Toggle aktiviert ist
4. ✅ Blockierte Apps können nicht geöffnet werden
5. ✅ Screen Time Shield erscheint bei Versuch, App zu öffnen

---

## 📝 **HINWEISE**

- **Simulator:** Blockierung funktioniert auch im Simulator
- **Echte Geräte:** Funktioniert identisch auf echten iPhones
- **Screen Time:** Muss in iOS-Einstellungen aktiviert sein
- **iOS Version:** Benötigt iOS 15+ für Screen Time API

---

## 🎯 **NÄCHSTE SCHRITTE**

Nach erfolgreichem Test:

1. ✅ Zeitbasierte Blockierung implementieren (nur während Tasks)
2. ✅ Firebase Sync für blockierte Apps
3. ✅ Emergency Unlock Funktion





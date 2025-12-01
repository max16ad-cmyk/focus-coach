# 🚀 Xcode Setup Guide - Focus Coach iOS App

## Schritt 1: Xcode Projekt erstellen

1. **Xcode öffnen**
2. **File → New → Project** (oder Cmd+Shift+N)
3. **iOS → App** auswählen
4. **Next** klicken
5. **Projekt-Details eingeben:**
   - Product Name: `FocusCoach`
   - Team: Dein Apple Developer Team (oder "None" für Entwicklung)
   - Organization Identifier: z.B. `com.deinname`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None** (Firebase wird später hinzugefügt)
6. **Next** klicken
7. **Speicherort wählen:** `/Users/maxjacob/Documents/focus-coach/ios/`
8. **Create** klicken

---


## Schritt 2: Swift-Dateien hinzufügen

### Option A: Dateien manuell kopieren

1. **Im Finder:** Öffne `/Users/maxjacob/Documents/focus-coach/ios/FocusCoach/`
2. **Alle Swift-Dateien** in Xcode ziehen:
   - Rechtsklick auf `FocusCoach` (gelber Ordner) im Project Navigator
   - **Add Files to "FocusCoach"...**
   - Navigiere zu `/Users/maxjacob/Documents/focus-coach/ios/FocusCoach/`
   - Wähle alle Ordner aus:
     - `Models/`
     - `Services/`
     - `Utils/`
   - ✅ **"Copy items if needed"** aktivieren
   - ✅ **"Create groups"** auswählen
   - **Add** klicken

### Option B: Dateien direkt in Xcode erstellen

1. **Models erstellen:**
   - Rechtsklick auf `FocusCoach` → **New Group** → Name: `Models`
   - Rechtsklick auf `Models` → **New File** → **Swift File**
   - Namen: `Task.swift`, `DayPlan.swift`, `UserSettings.swift`, `User.swift`
   - Inhalt aus den entsprechenden Dateien kopieren

2. **Services erstellen:**
   - Rechtsklick auf `FocusCoach` → **New Group** → Name: `Services`
   - Rechtsklick auf `Services` → **New File** → **Swift File**
   - Name: `FirebaseService.swift`
   - Inhalt kopieren

3. **Utils erstellen:**
   - Rechtsklick auf `FocusCoach` → **New Group** → Name: `Utils`
   - Rechtsklick auf `Utils` → **New File** → **Swift File**
   - Name: `Theme.swift`
   - Inhalt kopieren

4. **App-Dateien ersetzen:**
   - `FocusCoachApp.swift` und `ContentView.swift` existieren bereits
   - Inhalt durch die neuen Versionen ersetzen

---

## Schritt 3: Firebase SDK hinzufügen

### Swift Package Manager

1. **Xcode öffnen**
2. **File → Add Package Dependencies...**
3. **URL eingeben:** `https://github.com/firebase/firebase-ios-sdk`
4. **Add Package** klicken
5. **Version:** Latest (oder eine spezifische Version)
6. **Products auswählen:**
   - ✅ FirebaseAuth
   - ✅ FirebaseFirestore
   - ✅ FirebaseStorage
   - ✅ FirebaseCore
7. **Add Package** klicken

### GoogleService-Info.plist hinzufügen

1. **Firebase Console öffnen:** https://console.firebase.google.com
2. **Projekt auswählen:** `get-shit-done-c422f`
3. **iOS App hinzufügen** (falls noch nicht geschehen):
   - App Icon klicken → **Add App** → **iOS**
   - Bundle ID: `com.deinname.FocusCoach` (muss mit deinem Organization Identifier übereinstimmen)
   - App Name: `FocusCoach`
   - **Register App** klicken
4. **GoogleService-Info.plist herunterladen**
5. **In Xcode:**
   - Rechtsklick auf `FocusCoach` (gelber Ordner)
   - **Add Files to "FocusCoach"...**
   - `GoogleService-Info.plist` auswählen
   - ✅ **"Copy items if needed"** aktivieren
   - ✅ **"Add to targets: FocusCoach"** aktivieren
   - **Add** klicken

---

## Schritt 4: Family Controls Framework (Screen Time API)

### Framework hinzufügen

1. **Projekt auswählen** (blauer Ordner oben)
2. **Target "FocusCoach"** auswählen
3. **General Tab** → **Frameworks, Libraries, and Embedded Content**
4. **+** klicken
5. **FamilyControls** auswählen
6. **Add** klicken

### Capabilities aktivieren

1. **Signing & Capabilities Tab**
2. **+ Capability** klicken
3. **Family Controls** auswählen
4. **Managed Settings Extension** wird automatisch hinzugefügt

### Info.plist Permissions

1. **Info.plist** öffnen (im Project Navigator)
2. **Rechtsklick** → **Add Row**
3. **Key:** `NSFamilyControlsUsageDescription`
4. **Value:** `Focus Coach needs access to Screen Time to block distracting apps.`

---

## Schritt 5: Build Settings anpassen

1. **Projekt auswählen** (blauer Ordner)
2. **Target "FocusCoach"** auswählen
3. **Build Settings Tab**
4. **iOS Deployment Target:** `15.0` oder höher (für Family Controls)

---

## Schritt 6: Playfair Display Font hinzufügen (Optional)

1. **Font herunterladen:** https://fonts.google.com/specimen/Playfair+Display
2. **Font-Dateien** (.ttf) in Xcode ziehen:
   - Rechtsklick auf `FocusCoach` → **Add Files to "FocusCoach"...**
   - Font-Dateien auswählen
   - ✅ **"Copy items if needed"**
   - ✅ **"Add to targets: FocusCoach"**
3. **Info.plist** öffnen
4. **Fonts provided by application** hinzufügen:
   - Key: `UIAppFonts` (Array)
   - Item 0: `PlayfairDisplay-Regular.ttf`
   - Item 1: `PlayfairDisplay-Italic.ttf` (falls vorhanden)

---

## Schritt 7: Testen

1. **Cmd+B** (Build)
2. **Cmd+R** (Run) - Wähle einen Simulator oder dein iPhone
3. **App sollte starten** und Auth-Screen zeigen

---

## ✅ Checkliste

- [ ] Xcode Projekt erstellt
- [ ] Swift-Dateien hinzugefügt
- [ ] Firebase SDK installiert
- [ ] GoogleService-Info.plist hinzugefügt
- [ ] Family Controls Framework hinzugefügt
- [ ] Capabilities aktiviert
- [ ] Info.plist Permissions gesetzt
- [ ] iOS Deployment Target: 15.0+
- [ ] Build erfolgreich
- [ ] App läuft im Simulator/iPhone

---

## 🐛 Troubleshooting

### "GoogleService-Info.plist not found"
- Stelle sicher, dass die Datei im Projekt ist
- Prüfe, ob sie im "Copy Bundle Resources" Build Phase ist

### "No such module 'Firebase'"
- Stelle sicher, dass Firebase SDK über Swift Package Manager hinzugefügt wurde
- **File → Packages → Reset Package Caches**
- **File → Packages → Resolve Package Versions**

### "Family Controls not available"
- iOS Deployment Target muss 15.0+ sein
- Family Controls Framework muss hinzugefügt sein
- Capability muss aktiviert sein

### Build Errors
- Prüfe, ob alle Swift-Dateien im richtigen Target sind
- Prüfe, ob alle Imports korrekt sind
- **Product → Clean Build Folder** (Cmd+Shift+K)

---

## 📱 Nächste Schritte

Nach erfolgreichem Setup:
1. ✅ **BlockingService** erstellen (Screen Time API)
2. ✅ **Alle Views** implementieren (Morning Lock, Plan Review, etc.)
3. ✅ **Gemini API Integration** hinzufügen
4. ✅ **Testing** auf echtem iPhone

---

**Viel Erfolg! 🚀**





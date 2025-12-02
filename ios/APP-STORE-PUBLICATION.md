# 📱 APP STORE VERÖFFENTLICHUNG - SCHRITT-FÜR-SCHRITT

## 🎯 **VORBEREITUNG:**

### **1. Apple Developer Account** (ERFORDERLICH)

**Kosten:** $99/Jahr

**Schritte:**
1. Gehe zu: https://developer.apple.com/programs/
2. Klicke "Enroll"
3. Melde dich mit deiner Apple ID an
4. Bezahle $99/Jahr
5. Warte auf Bestätigung (kann 24-48h dauern)

**Wichtig:**
- Benötigt gültige Kreditkarte
- Apple ID muss existieren
- Kann auch als Organisation registriert werden

---

## 📋 **SCHRITT 1: APP STORE CONNECT SETUP**

### **1.1 App Store Connect öffnen:**
- Gehe zu: https://appstoreconnect.apple.com
- Melde dich mit deiner Apple Developer Account an

### **1.2 Neue App erstellen:**
1. Klicke "Meine Apps" → "+"
2. Wähle "Neue App"
3. **Fülle aus:**
   - **Plattform:** iOS
   - **Name:** Focus Coach (oder dein gewünschter Name)
   - **Primäre Sprache:** Deutsch
   - **Bundle ID:** Wähle oder erstelle eine (z.B. `com.MaxJacob.FocusCoach`)
   - **SKU:** Eindeutige ID (z.B. `focus-coach-001`)
   - **User Access:** Vollzugriff (oder Limited Access)

4. Klicke "Erstellen"

---

## 🔧 **SCHRITT 2: XCODE KONFIGURATION**

### **2.1 Bundle Identifier prüfen:**
1. Öffne Xcode
2. Wähle dein Projekt
3. Target → General Tab
4. **Bundle Identifier:** Muss mit App Store Connect übereinstimmen
   - Beispiel: `com.MaxJacob.FocusCoach`

### **2.2 Signing & Capabilities:**
1. Target → Signing & Capabilities
2. **Team:** Wähle dein Apple Developer Team
3. **Automatically manage signing:** ✅ Aktivieren
4. Xcode erstellt automatisch:
   - Provisioning Profile
   - Signing Certificate

### **2.3 Version & Build Number:**
1. Target → General Tab
2. **Version:** `1.0.0` (erste Version)
3. **Build:** `1` (erhöht sich bei jedem Upload)

---

## 📝 **SCHRITT 3: APP STORE LISTING VORBEREITEN**

### **3.1 App-Informationen:**

**In App Store Connect:**

1. **App-Name:** Focus Coach (max. 30 Zeichen)
2. **Untertitel:** Produktivitäts-App für fokussiertes Arbeiten (max. 30 Zeichen)
3. **Kategorie:**
   - Primär: Produktivität
   - Sekundär: Bildung (optional)

4. **Beschreibung:** (max. 4000 Zeichen)
   ```
   Focus Coach hilft dir, produktiver zu werden und deine Ziele zu erreichen.
   
   FEATURES:
   - Tagesplanung mit intelligenten Aufgaben
   - App- und Website-Blockierung
   - KI-gestützte Produktivitätsanalyse
   - Notizen und Checklisten
   
   Perfekt für Studenten, Berufstätige und alle, die ihre Produktivität steigern wollen.
   ```

5. **Schlüsselwörter:** (max. 100 Zeichen)
   ```
   Produktivität,Focus,Blockierung,Aufgaben,Planung,Notizen
   ```

6. **Support-URL:** (erforderlich)
   - Beispiel: `https://focuscoach.app/support`
   - Oder: GitHub Issues Seite

7. **Marketing-URL:** (optional)
   - Beispiel: `https://focuscoach.app`

8. **Datenschutzrichtlinie:** (ERFORDERLICH!)
   - URL zu deiner Privacy Policy
   - Beispiel: `https://focuscoach.app/privacy`
   - **Wichtig:** Muss existieren, bevor du einreichst!

---

## 📸 **SCHRITT 4: SCREENSHOTS & ASSETS**

### **4.1 Screenshots erstellen:**

**Benötigte Größen:**
- **iPhone 6.7" (iPhone 14 Pro Max):** 1290 x 2796 px
- **iPhone 6.5" (iPhone 11 Pro Max):** 1242 x 2688 px
- **iPhone 5.5" (iPhone 8 Plus):** 1242 x 2208 px

**Mindestens 3 Screenshots erforderlich!**

**Tipps:**
- Zeige die wichtigsten Features
- Erste Screenshots sollten die Hauptfunktionen zeigen
- Nutze echte Screenshots aus der App
- Keine Platzhalter!

### **4.2 App Icon:**
- **Größe:** 1024 x 1024 px
- **Format:** PNG oder JPEG
- **Keine Transparenz**
- **Keine abgerundeten Ecken** (Apple macht das automatisch)

### **4.3 Weitere Assets:**
- **App Preview Video:** (optional, aber empfohlen)
  - Max. 30 Sekunden
  - Zeigt App in Aktion

---

## 🏗️ **SCHRITT 5: BUILD ERSTELLEN & HOCHLADEN**

### **5.1 Archive erstellen:**

1. **In Xcode:**
   - Wähle "Any iOS Device" oder ein echtes Gerät (nicht Simulator!)
   - Product → Archive
   - Warte bis Archive fertig ist

2. **Organizer öffnet sich automatisch**

### **5.2 Build validieren:**

1. Im Organizer:
   - Wähle dein Archive
   - Klicke "Validate App"
   - Folge den Anweisungen
   - Prüfe auf Fehler

### **5.3 Build hochladen:**

1. Im Organizer:
   - Wähle dein Archive
   - Klicke "Distribute App"
   - Wähle "App Store Connect"
   - Wähle "Upload"
   - Folge den Anweisungen
   - Warte bis Upload fertig ist

**Alternativ:** Xcode → Product → Archive → Distribute App

---

## 📤 **SCHRITT 6: APP STORE CONNECT - FINALISIERUNG**

### **6.1 Build zuweisen:**

1. In App Store Connect:
   - Gehe zu deiner App
   - Version → Build
   - Wähle deinen hochgeladenen Build
   - **Wichtig:** Build kann 10-30 Minuten brauchen, bis er sichtbar ist!

### **6.2 App Store Listing vervollständigen:**

1. **Screenshots hochladen:**
   - Gehe zu "App Store" Tab
   - Lade Screenshots hoch
   - Für alle benötigten Gerätegrößen

2. **App Icon hochladen:**
   - 1024 x 1024 px

3. **Beschreibung & Keywords:**
   - Alle Felder ausfüllen

4. **Kontaktinformationen:**
   - E-Mail-Adresse
   - Telefonnummer (optional)

5. **Preis & Verfügbarkeit:**
   - Wähle Preis (kostenlos oder kostenpflichtig)
   - Verfügbarkeit: Alle Länder (oder auswählen)

---

## ✅ **SCHRITT 7: EINREICHEN FÜR REVIEW**

### **7.1 Export Compliance:**

**Fragen:**
- **Verwendet deine App Verschlüsselung?**
  - Wenn ja: Details angeben
  - Wenn nein: "Nein" wählen

- **Verwendet deine App US-Export-Compliance?**
  - Meistens: "Nein" (wenn keine spezielle Verschlüsselung)

### **7.2 Content Rights:**

- **Hast du die Rechte für alle Inhalte?**
  - ✅ Ja (wenn alles selbst erstellt)

### **7.3 Advertising Identifier:**

- **Verwendet deine App Advertising Identifier?**
  - Wenn nein: "Nein" wählen

### **7.4 App einreichen:**

1. Klicke "Für Review einreichen"
2. Prüfe alle Informationen nochmal
3. Bestätige
4. **Fertig!** 🎉

---

## ⏱️ **REVIEW-PROZESS:**

### **Timeline:**
- **Upload:** 10-30 Minuten (bis Build sichtbar)
- **Review:** 1-3 Tage (meist 24-48h)
- **Veröffentlichung:** Sofort nach Approval oder zu geplantem Datum

### **Status:**
- **In Review:** Apple prüft deine App
- **Pending Developer Release:** Approved, wartet auf dich
- **Ready for Sale:** Live im App Store! 🎉

---

## 🐛 **HÄUFIGE FEHLER:**

### **1. "Invalid Bundle Identifier"**
- **Lösung:** Bundle ID muss mit App Store Connect übereinstimmen

### **2. "Missing Compliance"**
- **Lösung:** Export Compliance Fragen beantworten

### **3. "Missing Privacy Policy"**
- **Lösung:** Privacy Policy URL hinzufügen

### **4. "Missing Screenshots"**
- **Lösung:** Mindestens 3 Screenshots hochladen

### **5. "Build nicht sichtbar"**
- **Lösung:** 10-30 Minuten warten, dann Seite neu laden

---

## 📋 **CHECKLISTE:**

### **Vor dem Upload:**
- [ ] Apple Developer Account aktiv ($99/Jahr)
- [ ] App Store Connect App erstellt
- [ ] Bundle Identifier konfiguriert
- [ ] Signing & Capabilities eingerichtet
- [ ] Version & Build Number gesetzt
- [ ] Privacy Policy erstellt & online
- [ ] Screenshots erstellt (mind. 3)
- [ ] App Icon erstellt (1024x1024)
- [ ] Beschreibung & Keywords geschrieben

### **Nach dem Upload:**
- [ ] Build zugewiesen
- [ ] Screenshots hochgeladen
- [ ] App Icon hochgeladen
- [ ] Alle Informationen ausgefüllt
- [ ] Export Compliance beantwortet
- [ ] Für Review eingereicht

---

## 🚀 **TIPS:**

1. **TestFlight nutzen:**
   - Beta-Testing vor Veröffentlichung
   - Teste mit echten Usern
   - Finde Bugs vor Release

2. **Privacy Policy:**
   - Erforderlich für App Store
   - Kann einfach sein (Template nutzen)
   - Muss online verfügbar sein

3. **Screenshots:**
   - Zeige die besten Features
   - Erste Screenshots sind wichtig
   - Nutze echte Screenshots

4. **Beschreibung:**
   - Erste 2-3 Zeilen sind wichtig (werden immer angezeigt)
   - Nutze Keywords natürlich
   - Zeige Features klar auf

---

## 🎯 **FERTIG!**

Nach dem Review ist deine App live im App Store! 🎉

**Zeitplan:**
- Setup: 1-2 Stunden
- Upload: 10-30 Minuten
- Review: 1-3 Tage
- **Total: ~2-4 Tage bis Live**

Viel Erfolg! 🚀






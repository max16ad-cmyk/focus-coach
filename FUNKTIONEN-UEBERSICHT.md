# 🎯 FOCUS COACH - VOLLSTÄNDIGE FUNKTIONSÜBERSICHT

## 📱 **HAUPTFEATURES**

### 1. **Dashboard-System**
- ✅ **Desktop-Ansicht**: Sidebar-Navigation links, Hauptbereich rechts
- ✅ **Mobile-Ansicht**: Hamburger-Menü, kompakte Ansicht
- ✅ **Direkter Start**: App öffnet direkt ins Dashboard (kein Morning Lock mehr standardmäßig)
- ✅ **Navigation**: Wechsel zwischen verschiedenen Ansichten über Sidebar

### 2. **Tagesplan-Erstellung**
- ✅ **Manuelle Eingabe**: Textfeld für Aufgaben eingeben
- ✅ **Spracheingabe**: 🎤 Mikrofon-Button für Diktat (Web Speech API)
- ✅ **KI-Analyse**: Google Gemini analysiert Eingabe und strukturiert automatisch:
  - Erkennt einzelne Aufgaben
  - Weist Kategorien zu (Lernen, Haushalt, Erledigung, Arbeit, Sport, Kreativ)
  - Schätzt Dauer
  - Bestimmt Zeitblöcke
  - Entscheidet, ob Nachweis nötig ist
- ✅ **Plan-Review**: Strukturierten Plan prüfen und anpassen vor Bestätigung

### 3. **Aufgaben-Management**
- ✅ **Zeitblöcke**: Aufgaben werden in Zeitfenster eingeteilt (z.B. 09:00-11:00)
- ✅ **Kategorien**: Automatische Zuordnung (Lernen, Haushalt, etc.)
- ✅ **Status-Tracking**: 
  - ⬜ Wartet
  - 🔄 In Bearbeitung
  - ⏳ Wartet auf Nachweis
  - ✅ Erledigt
- ✅ **Fortschrittsanzeige**: Visualisierung wie viel Zeit bereits vergangen ist
- ✅ **Tagesübersicht**: Liste aller Aufgaben mit Status

### 4. **Foto-Nachweis & KI-Verifikation**
- ✅ **Nachweis-Pflicht**: Bestimmte Aufgaben erfordern Foto-Beweis
- ✅ **Foto-Upload**: Einfaches Hochladen von Bildern
- ✅ **KI-Prüfung**: Google Gemini Vision analysiert Foto:
  - Prüft ob Foto zur Aufgabe passt
  - Erkennt relevante Inhalte
  - Entscheidet ob Nachweis ausreicht
- ✅ **Feedback**: Detaillierte Begründung bei Akzeptanz/Ablehnung
- ✅ **Retry**: Möglichkeit neuen Nachweis hochzuladen bei Ablehnung

### 5. **Coach-System**
- ✅ **4 Persönlichkeiten**:
  - 🎖️ **Sergeant**: Militärisch, direkt, keine Ausreden
  - 🎓 **Professor**: Sachlich, analytisch, erklärend
  - 🧭 **Mentor**: Bestimmt aber unterstützend
  - ⚡ **Minimalist**: Wenige Worte, auf den Punkt
- ✅ **Dynamische Messages**: Coach gibt kontextbezogene Anweisungen
- ✅ **Avatar**: Visueller Coach-Avatar (○_○)

### 6. **Modi & Ansichten**

#### **Übersicht (Dashboard)**
- Zeigt Status des Tages
- "Plan erstellen"-Button wenn kein Plan existiert
- Stats-Anzeige (erledigte/offene Aufgaben)

#### **Aktueller Tag**
- Zeigt aktuelle Aufgabe
- Fortschrittsbalken
- Tagesübersicht aller Aufgaben
- Nachweis-Upload-Button
- "Als erledigt markieren"-Button

#### **Freedom Mode**
- Erscheint wenn alle Aufgaben erledigt sind
- Zeigt freigegebene Ablenkungen
- Liste aller erledigten Aufgaben
- Nachtmodus-Warnung

#### **Night Mode**
- Aktiviert sich automatisch zu konfigurierbarer Zeit (Standard: 23:00-06:00)
- Blockiert alle Ablenkungen
- Kein Notfall-Unlock möglich (wenn aktiviert)
- Erlaubt nur wichtige Dienste (Maps, Wikipedia, E-Mail, Banking)

### 7. **Einstellungen**
- ✅ **Coach-Persönlichkeit**: Auswahl zwischen 4 Typen
- ✅ **Nachtmodus**:
  - Aktivieren/Deaktivieren
  - Start- und Endzeit einstellen
  - Notfall-Unlock erlauben/verbieten
- ✅ **Morgen-Planung**:
  - Aktivieren/Deaktivieren (Standard: deaktiviert)
  - Zeitfenster konfigurieren (z.B. 06:00-12:00)
- ✅ **Nachweis-Einstellungen**:
  - Standardmäßig aktivieren
  - Strenge-Level (Niedrig/Mittel/Hoch)
- ✅ **Notfall-Zugriff**:
  - Aktivieren/Deaktivieren
  - Dauer einstellen (Minuten)
  - Cooldown einstellen (Stunden)

### 8. **Multi-Device Synchronisation**
- ✅ **Firebase Firestore**: Cloud-Speicherung aller Daten
- ✅ **Real-time Sync**: Änderungen erscheinen < 1 Sekunde auf allen Geräten
- ✅ **Synchronisiert**:
  - Tagespläne (Aufgaben, Status, Zeitblöcke)
  - Einstellungen (Coach, Nachtmodus, etc.)
  - User Stats (XP, Level, Streak)
- ✅ **Funktioniert auf**:
  - MacBook (alle Browser)
  - iPad (Safari)
  - iPhone (Safari)
  - Windows PC (alle Browser)
  - Android (Chrome, Firefox)

### 9. **Authentifizierung**
- ✅ **Firebase Auth**: Sichere Login/Registrierung
- ✅ **Email/Passwort**: Standard-Authentifizierung
- ✅ **Automatische Initialisierung**: User-Daten werden beim ersten Login erstellt

## 🎨 **DESIGN-FEATURES**

### **Desktop**
- ✅ Sidebar-Navigation (256px breit)
- ✅ Breite Container (max-w-7xl)
- ✅ Größere Schrift auf großen Screens
- ✅ Mehr Padding für bessere Lesbarkeit
- ✅ Stats-Anzeige in Sidebar

### **Mobile**
- ✅ Hamburger-Menü
- ✅ Kompakte Ansicht
- ✅ Touch-optimierte Buttons
- ✅ Responsive Breakpoints

### **Design-System**
- ✅ Dark Theme (slate-950 Hintergrund)
- ✅ Gradient-Akzente
- ✅ Smooth Transitions
- ✅ Lucide Icons
- ✅ Tailwind CSS

## 🤖 **KI-FEATURES (Google Gemini)**

### **1. Task-Analyse**
```
Input: "Ich muss Mathe lernen, Zimmer aufräumen und einkaufen gehen"
Output: Strukturierter Plan mit:
- 3 Aufgaben
- Kategorien (Lernen, Haushalt, Erledigung)
- Geschätzte Dauer
- Zeitblöcke
- Nachweis-Anforderungen
```

### **2. Foto-Verifikation**
```
Input: Aufgabe + Foto
Output: {
  accepted: true/false,
  confidence: 0.0-1.0,
  reason: "Begründung",
  detectedElements: ["Was erkannt wurde"],
  coachMessage: "Nachricht an User"
}
```

## 📊 **STATISTIKEN & TRACKING**

- ✅ **Aufgaben-Status**: Erledigt/Offen
- ✅ **Fortschrittsbalken**: Visuelle Darstellung
- ✅ **Tagesübersicht**: Alle Aufgaben auf einen Blick
- ✅ **Stats in Sidebar**: Erledigte/Total Aufgaben

## 🔒 **BLOCKING-FEATURES** (Geplant, noch nicht implementiert)

- ⏳ Browser Extension für Website-Blocking
- ⏳ YouTube Content-Filter (KI-basiert)
- ⏳ Notfall-Unlock mit Hürden
- ⏳ Block-Screen auf blockierten Seiten

## 🚀 **TECHNISCHE FEATURES**

- ✅ **React 18 + TypeScript**
- ✅ **Firebase Firestore** (Real-time Database)
- ✅ **Firebase Authentication**
- ✅ **Google Gemini API** (Vision + Text)
- ✅ **Web Speech API** (Spracheingabe)
- ✅ **Responsive Design** (Mobile + Desktop)
- ✅ **PWA-ready** (Progressive Web App)

## 📝 **WORKFLOW**

### **Standard-Workflow:**
1. App öffnen → Dashboard
2. Falls kein Plan: "Plan erstellen" klicken
3. Aufgaben eingeben (Text oder Spracheingabe)
4. KI analysiert und strukturiert
5. Plan prüfen und bestätigen
6. Aufgaben während des Tages erledigen
7. Bei Nachweis-Pflicht: Foto hochladen
8. KI prüft Nachweis
9. Bei Akzeptanz: Aufgabe als erledigt markiert
10. Alle erledigt → Freedom Mode

### **Mit Morning Lock (optional):**
1. App öffnen morgens (6:00-12:00)
2. Morning Lock Screen erscheint
3. Plan MUSS erstellt werden
4. Danach: Normaler Workflow

## ⚙️ **KONFIGURIERBARE OPTIONEN**

- ✅ Coach-Persönlichkeit
- ✅ Nachtmodus-Zeiten
- ✅ Morgen-Planung (aktivieren + Zeiten)
- ✅ Nachweis-Strenge
- ✅ Notfall-Unlock-Einstellungen
- ✅ Alle Einstellungen synchronisieren zwischen Geräten

---

## 🎯 **ZUSAMMENFASSUNG**

**Focus Coach** ist ein KI-basierter Produktivitäts-Coach, der:

1. ✅ **Tagespläne strukturiert** - KI analysiert und organisiert Aufgaben
2. ✅ **Nachweise prüft** - Foto-Verifikation mit KI
3. ✅ **Coacht** - 4 verschiedene Persönlichkeiten
4. ✅ **Synchronisiert** - Multi-Device Support über Firebase
5. ✅ **Anpassbar ist** - Viele Einstellungen konfigurierbar
6. ✅ **Responsive ist** - Funktioniert auf Desktop und Mobile

**Kern-Philosophie**: Zugriff auf Ablenkung ist BELOHNUNG für echte Produktivität, nicht für leere Versprechen.


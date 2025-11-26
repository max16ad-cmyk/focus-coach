# 📱 FOCUS VAULT - FEATURE-ÜBERSICHT

## 🎯 KONZEPT
Ein gamifizierter **digitaler Tresor** für Produktivität:
- Ablenkende Websites (YouTube, Instagram) werden gesperrt 🔒
- Erst wenn ALLE Tasks erledigt sind, öffnet sich der Tresor
- AI unterstützt bei Planung & Verifikation
- Gamification motiviert zum Durchhalten

---

## ⭐ HAUPTFUNKTIONEN

### 1️⃣ **AUTHENTICATION**
- Firebase Login/Register mit Email/Password
- Automatische Session-Speicherung
- Responsive Auth-Screen mit Gradients

### 2️⃣ **TASK MANAGEMENT**

**3 Task-Typen:**

**A) Normale Tasks:**
- Einfache Checkbox
- +50 XP bei Completion

**B) AI-Generated Tasks:**
- User gibt Ziel ein: "Website erstellen"
- Gemini AI zerlegt in 3-5 Sub-Tasks
- Markiert mit ✨ Sparkles Icon
- +50 XP pro Task

**C) Verified Tasks (mit Foto-Beweis):**
- Toggle "Proof Required" aktivieren
- User MUSS Foto machen zum Abhaken
- AI analysiert Foto (z.B. "Gym" → sucht Fitnessgeräte)
- ✅ Verified: +150 XP (Triple!)
- ❌ Rejected: "This looks like a cat, not a gym!"

### 3️⃣ **DISTRACTION VAULT**

**Der digitale Tresor:**
- 4 vorinstallierte Distractions (Instagram, YouTube, etc.)
- **Locked:** Verschwommen + Schloss-Icon
- **Unlocked:** Nur wenn ALLE Tasks erledigt
- Klick öffnet Website in neuem Tab

### 4️⃣ **LINK ANALYZER (AI)**

**Smart URL-Prüfung:**
- User fügt beliebige URL ein
- Gemini AI analysiert: Produktiv vs. Ablenkend?
- ✅ Produktiv (z.B. Coding-Tutorial) → Öffnet sofort
- ❌ Ablenkend (z.B. Gaming-Video) → Wird zum Vault hinzugefügt

### 5️⃣ **GAMIFICATION**

**Stats:**
- 🏆 **Level:** 1-7+ (basierend auf XP)
- ⚡ **XP Bar:** Visueller Progress bis nächstes Level
- 🔥 **Streak:** Tages-Streak Counter
- ✅ **Tasks Completed:** Gesamtzähler

**XP System:**
- Normale Task: +50 XP
- Verified Task: +150 XP
- Emergency Unlock: -100 XP (Strafe!)

**Level Thresholds:**
```
Level 1: 0 XP → Level 2: 100 XP → Level 3: 300 XP
→ Level 4: 600 XP → Level 5: 1000 XP → Level 6: 2000 XP
→ Level 7: 5000 XP
```

### 6️⃣ **EMERGENCY UNLOCK**

**Der "Aufgabe"-Button:**
- User will trotz offener Tasks auf YouTube
- Klickt "Emergency Override"
- **Modal mit AI-Message:**
  - Gemini generiert personalisierten Motivations-Spruch
  - z.B. "Disziplin ist wie Muskeln - wächst nicht durchs Aufgeben!"
  - Kennt Anzahl bisheriger Aufgaben
- Bei Bestätigung:
  - Alle Tasks → Erledigt
  - -100 XP Strafe
  - Penalty Counter +1
  - Vault öffnet sich

---

## 🤖 AI-FUNKTIONEN (Gemini 2.5 Flash)

### **1. Goal Breakdown**
```
Input:  "Build portfolio website"
Output: ["Choose tech stack", "Design homepage", 
         "Create about section", "Deploy to hosting"]
```

### **2. Photo Verification**
```
Input:  Task: "Go to gym" + Photo von Handy
Output: { verified: true, feedback: "Gym equipment visible!" }
```

### **3. Motivational Messages**
```
Input:  penaltyCount: 3
Output: "Das ist bereits dein 3. Versuch aufzugeben. 
         Discipline equals freedom!"
```

### **4. URL Analysis**
```
Input:  "youtube.com/watch?v=gaming123"
Output: { isProductive: false, category: "Gaming", 
          reason: "Gaming content detected" }
```

---

## 🎨 DESIGN

**UI/UX:**
- 🌑 Dark Theme (minimiert Ablenkung)
- 🎨 Gradient Accents (Modern, Premium)
- 🔀 Smooth Animations
- 📱 Responsive (Desktop + Mobile)
- 🖼️ Blur Effects für gesperrte Inhalte

**Layout:**
- **Desktop:** 2-Spalten (Tasks links, Vault rechts)
- **Mobile:** Single Column mit Hamburger-Menü

---

## 🏗️ TECH STACK

**Frontend:**
- React 18 + TypeScript
- Tailwind CSS (CDN)
- Vite Build Tool
- Lucide Icons

**Backend:**
- Firebase Authentication

**AI:**
- Google Gemini API (2.5 Flash)

**Dependencies (via Import Maps):**
```javascript
react@18.3.1
react-dom@18.3.1
firebase@10.7.1
@google/genai
lucide-react@0.460.0
```

---

## 📂 DATEI-STRUKTUR

```
Focus Vault/
├── App.tsx                 # Hauptlogik (500+ Zeilen)
├── components/
│   ├── AuthScreen.tsx      # Login/Register (135 Zeilen)
│   ├── TaskCard.tsx        # Task mit Foto-Upload (130 Zeilen)
│   ├── DistractionVault.tsx # Gesperrte Links (44 Zeilen)
│   ├── StatsDisplay.tsx    # XP/Level UI (62 Zeilen)
│   └── LinkAnalyzer.tsx    # AI URL-Check (88 Zeilen)
├── services/
│   ├── firebase.ts         # Auth Functions (60 Zeilen)
│   └── geminiService.ts    # 4 AI Functions (170 Zeilen)
├── types.ts                # TypeScript Interfaces
├── constants.ts            # Initial Data & Thresholds
└── index.html              # Entry Point + Import Maps
```

---

## 🎯 WORKFLOW BEISPIEL

**1. Anmeldung:**
- User registriert sich mit Email/Password

**2. Tasks erstellen:**
- Manual: "Write report" + "Proof Required" an
- AI: "Launch online shop" → Gemini erstellt 5 Sub-Tasks

**3. Tasks erledigen:**
- Normale Tasks: Checkbox abhaken → +50 XP
- Verified Task: Foto machen → AI prüft → +150 XP
- Level Up! 🎉

**4. Vault entsperrt:**
- Alle Tasks erledigt → 🔓 Vault öffnet sich
- User kann jetzt YouTube/Instagram besuchen

**5. Link Analyzer:**
- User fügt "youtube.com/coding-tutorial" ein
- AI: "Educational content" → Öffnet sofort
- User fügt "twitch.tv/gaming" ein
- AI: "Gaming content" → Wird zum Vault hinzugefügt

**6. Notfall:**
- User hat noch 3 offene Tasks, will aber YouTube
- Klickt "Emergency Override"
- AI warnt: "Das ist bereits dein 2. Aufgabe-Versuch..."
- Bestätigt → -100 XP, Vault öffnet sich

---

## ⚠️ WICHTIGE HINWEISE

**Daten-Speicherung:**
- ✅ User-Account: Firebase (persistent)
- ❌ Tasks: Nur React State (verloren bei Reload!)
- ❌ Stats: Nur React State (verloren bei Reload!)

**Fehlende Features:**
- Keine Firestore-Integration
- Keine Task-History
- Keine Notifications
- Keine Leaderboards

**Für Produktion nötig:**
- Firestore für Daten-Persistenz
- Push Notifications für Reminders
- Analytics für User-Tracking

---

## 🎉 ZUSAMMENFASSUNG

**Focus Vault = Produktivitäts-App mit Gamification + AI**

**Kernidee:**
"Finish your work first, THEN you can have fun!" 🎯

**Unique Features:**
- 📸 Foto-Verifikation für ehrliche Task-Completion
- 🤖 AI-powered Goal Breakdown
- 🔍 Smart URL-Filtering mit AI
- 🎮 Gamified mit echter Konsequenz (Vault bleibt zu!)

**Zielgruppe:**
- Studenten mit Prokrastination
- Remote Workers
- Jeder der mehr Disziplin will

**USP:**
Die einzige Produktivitäts-App, die dich zwingt ehrlich zu sein - 
mit Foto-Beweis und AI-Verifikation! 💪

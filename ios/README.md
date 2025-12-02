# 📱 Focus Coach - iOS App

Native iOS App für Focus Coach mit **100% App-Blockierung** via Screen Time API.

## ✅ Was ist bereits fertig:

- ✅ **Swift Models** - Task, DayPlan, UserSettings, User
- ✅ **Firebase Service** - Real-time Sync mit PWA
- ✅ **Premium Theme** - Glassmorphism Design (wie PWA)
- ✅ **Auth Screen** - Login/Register
- ✅ **Basic App Structure** - FocusCoachApp, ContentView

## 🚀 Nächste Schritte:

1. **Xcode Projekt erstellen** (siehe `XCODE-SETUP.md`)
2. **Firebase SDK hinzufügen** via Swift Package Manager
3. **GoogleService-Info.plist** von Firebase Console herunterladen
4. **Family Controls Framework** hinzufügen (für App-Blockierung)
5. **Build & Test** im Simulator oder auf iPhone

## 📁 Projektstruktur:

```
ios/
├── FocusCoach/
│   ├── Models/
│   │   ├── Task.swift
│   │   ├── DayPlan.swift
│   │   ├── UserSettings.swift
│   │   └── User.swift
│   ├── Services/
│   │   └── FirebaseService.swift
│   ├── Utils/
│   │   └── Theme.swift
│   ├── FocusCoachApp.swift
│   └── ContentView.swift
└── XCODE-SETUP.md
```

## 🔗 Synchronisation:

Die iOS App synchronisiert automatisch mit:
- ✅ **PWA (Web App)** - Gleiche Firebase-Datenbank
- ✅ **Firebase Firestore** - Echtzeit-Sync
- ✅ **Firebase Auth** - Gleiche User Accounts
- ✅ **Firebase Storage** - Gemeinsame Fotos

## 🛡️ App-Blockierung:

Die iOS App nutzt die **Screen Time API** für 100% Blockierung:
- ✅ Apps können **nicht geöffnet** werden
- ✅ System-Level Blockierung (kann nicht umgangen werden)
- ✅ Website-Blockierung in Safari
- ✅ App Store approved (wie Opal & One Sec)

## 📖 Setup-Anleitung:

Siehe **`XCODE-SETUP.md`** für detaillierte Anleitung.

---

**Viel Erfolg! 🚀**






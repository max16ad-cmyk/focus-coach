# 🚀 FOCUS VAULT - MULTI-DEVICE DEPLOYMENT GUIDE

Diese Anleitung zeigt dir, wie du Focus Vault auf **allen deinen Geräten** (MacBook, iPad, iPhone) synchronisiert nutzen kannst.

---

## 📋 ÜBERSICHT

**Was wir machen:**
1. ✅ Firestore Datenbank aktivieren (Cloud-Sync)
2. ✅ App auf Firebase Hosting deployen
3. ✅ Als PWA auf iPhone/iPad installieren

**Endergebnis:**
- App läuft auf https://get-shit-done-c422f.web.app
- Tasks & Stats synchronisieren in Echtzeit
- Funktioniert wie eine native App auf iPhone/iPad

---

## 🔥 SCHRITT 1: FIRESTORE AKTIVIEREN

### 1.1 Firebase Console öffnen

1. Gehe zu: https://console.firebase.google.com
2. Wähle dein Projekt: **get-shit-done-c422f**

### 1.2 Firestore Database erstellen

1. Im linken Menü: **Build** → **Firestore Database**
2. Klicke **"Create database"**
3. Wähle **"Start in production mode"**
4. Wähle Location: **europe-west3 (Frankfurt)** (oder die nächste zu dir)
5. Klicke **"Enable"**

### 1.3 Firestore Security Rules setzen

1. Im Firestore Dashboard → Tab **"Rules"**
2. Ersetze den Inhalt durch:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Subcollections (tasks, distractions)
      match /{subcollection}/{docId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

3. Klicke **"Publish"**

**Diese Rules stellen sicher:**
- Nur eingeloggte User können Daten lesen/schreiben
- Jeder User kann NUR seine eigenen Daten sehen

---

## 🌐 SCHRITT 2: APP DEPLOYEN (Firebase Hosting)

### 2.1 Firebase CLI installieren

Öffne das Terminal auf deinem Mac:

```bash
# Node.js muss installiert sein (https://nodejs.org)
npm install -g firebase-tools
```

### 2.2 Firebase Login

```bash
firebase login
```
→ Browser öffnet sich, mit Google-Account einloggen

### 2.3 Projekt vorbereiten

```bash
# In deinen Projektordner wechseln
cd /pfad/zu/focus-vault

# Firebase initialisieren
firebase init
```

**Bei den Fragen:**
1. **Which Firebase features?** → Wähle: `Hosting: Configure files for Firebase Hosting`
2. **Select a project** → `Use an existing project` → `get-shit-done-c422f`
3. **Public directory?** → `dist` (oder `.` wenn du keinen Build machst)
4. **Single-page app?** → `Yes`
5. **Set up GitHub Actions?** → `No`

### 2.4 App bauen

```bash
# Dependencies installieren
npm install

# App bauen
npm run build
```

### 2.5 Deployen!

```bash
firebase deploy
```

**Fertig!** 🎉 Deine App ist jetzt live unter:
- https://get-shit-done-c422f.web.app
- https://get-shit-done-c422f.firebaseapp.com

---

## 📱 SCHRITT 3: ALS APP AUF iPHONE/iPAD INSTALLIEREN

### 3.1 Safari öffnen

1. Öffne **Safari** auf deinem iPhone/iPad
2. Gehe zu: `https://get-shit-done-c422f.web.app`

### 3.2 Zum Home-Bildschirm hinzufügen

1. Tippe auf das **Teilen-Symbol** (Quadrat mit Pfeil nach oben)
2. Scrolle nach unten
3. Tippe auf **"Zum Home-Bildschirm"**
4. Benenne die App (z.B. "FocusVault")
5. Tippe **"Hinzufügen"**

**Die App erscheint jetzt als Icon auf deinem Home-Bildschirm!**

### 3.3 Vorteile der PWA

- ✅ Vollbild-Modus (keine Safari-Leiste)
- ✅ Eigenes App-Icon
- ✅ Schneller Start
- ✅ Funktioniert offline (für bereits geladene Daten)

---

## 💻 SCHRITT 4: AUF MacBook NUTZEN

### Option A: Im Browser

1. Öffne Chrome/Safari/Firefox
2. Gehe zu: `https://get-shit-done-c422f.web.app`
3. Logge dich ein

### Option B: Als Chrome-App installieren

1. Öffne **Chrome**
2. Gehe zu: `https://get-shit-done-c422f.web.app`
3. Klicke auf die **drei Punkte** (⋮) oben rechts
4. Wähle **"Focus Vault installieren"** oder **"App installieren"**
5. Die App erscheint im Launchpad/Applications

---

## 🔄 SO FUNKTIONIERT DIE SYNCHRONISATION

### Real-time Sync

```
MacBook                    Firebase Cloud                   iPhone
   │                            │                              │
   │──── Task erstellen ───────►│                              │
   │                            │◄──── Sync ─────────────────►│
   │                            │                              │
   │◄─── Task erscheint ────────│                              │
   │                            │                              │
```

**Was synchronisiert wird:**
- ✅ Tasks (erstellen, abhaken, löschen)
- ✅ Stats (XP, Level, Streak)
- ✅ Distractions (neue Links aus Link Analyzer)

**Wie schnell?**
- Änderungen erscheinen **sofort** (< 1 Sekunde) auf allen Geräten!

---

## 🔧 TROUBLESHOOTING

### Problem: "Permission denied" beim Firestore-Zugriff

**Lösung:**
1. Prüfe die Firestore Rules (Schritt 1.3)
2. Stelle sicher, dass du eingeloggt bist
3. Leere den Browser-Cache

### Problem: App lädt nicht auf iPhone

**Lösung:**
1. Prüfe die Internetverbindung
2. Lösche die App vom Home-Bildschirm
3. Füge sie neu hinzu (Safari → Teilen → Zum Home-Bildschirm)

### Problem: Daten synchronisieren nicht

**Lösung:**
1. Prüfe ob Firestore aktiviert ist
2. Prüfe die Firebase Console auf Fehler
3. Logge aus und wieder ein

### Problem: "Firebase Initialization Error"

**Lösung:**
Die Firebase-Config in `services/firebase.ts` prüfen. Die Config sollte so aussehen:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyCB3dLNsU27k0PH6rtt_Wt_7G-i80ColTc",
  authDomain: "get-shit-done-c422f.firebaseapp.com",
  projectId: "get-shit-done-c422f",
  // ... etc
};
```

---

## 📊 FIREBASE CONSOLE ÜBERSICHT

### Wo finde ich was?

**Authentication (User-Verwaltung):**
https://console.firebase.google.com/project/get-shit-done-c422f/authentication/users

**Firestore (Datenbank):**
https://console.firebase.google.com/project/get-shit-done-c422f/firestore

**Hosting (Deployment):**
https://console.firebase.google.com/project/get-shit-done-c422f/hosting

### Datenstruktur in Firestore

```
users/
  └── {userId}/
      ├── stats: { xp, level, streak, tasksCompleted, penalties }
      ├── createdAt: "2024-..."
      ├── lastActive: "2024-..."
      │
      ├── tasks/
      │   ├── {taskId}/
      │   │   ├── title: "..."
      │   │   ├── completed: false
      │   │   ├── isAiGenerated: true
      │   │   └── createdAt: 1234567890
      │   └── ...
      │
      └── distractions/
          ├── {distractionId}/
          │   ├── name: "YouTube"
          │   ├── url: "https://..."
          │   └── icon: "📺"
          └── ...
```

---

## 💰 KOSTEN

### Firebase Free Tier (Spark Plan)

**Firestore:**
- 1 GB Speicher: KOSTENLOS
- 50.000 Reads/Tag: KOSTENLOS
- 20.000 Writes/Tag: KOSTENLOS

**Authentication:**
- Unbegrenzte User: KOSTENLOS

**Hosting:**
- 10 GB Speicher: KOSTENLOS
- 360 MB/Tag Transfer: KOSTENLOS

**Für eine persönliche Produktivitäts-App = 100% KOSTENLOS!** 🎉

---

## ✅ CHECKLISTE

- [ ] Firestore Database erstellt
- [ ] Firestore Rules gesetzt
- [ ] Firebase CLI installiert
- [ ] `firebase init` ausgeführt
- [ ] `npm run build` erfolgreich
- [ ] `firebase deploy` erfolgreich
- [ ] App im Browser getestet
- [ ] App auf iPhone installiert
- [ ] App auf iPad installiert
- [ ] Sync zwischen Geräten getestet

---

## 🎉 FERTIG!

Deine Focus Vault App läuft jetzt auf:

- 💻 **MacBook:** Browser oder Chrome-App
- 📱 **iPhone:** PWA vom Home-Bildschirm
- 📱 **iPad:** PWA vom Home-Bildschirm

**Alle Geräte synchronisieren in Echtzeit!**

---

## 🔮 NÄCHSTE SCHRITTE (Optional)

### Custom Domain

Du kannst eine eigene Domain verbinden:
1. Firebase Console → Hosting → "Add custom domain"
2. z.B. `focusvault.de` oder `vault.deinedomain.de`

### Push Notifications

Für Erinnerungen könntest du Firebase Cloud Messaging hinzufügen.

### Analytics

Firebase Analytics ist kostenlos und zeigt dir Nutzungsstatistiken.

---

**Viel Erfolg mit deiner Focus Vault App!** 🚀

# ⚡ QUICK FIX - 3 Änderungen

## 1️⃣ index.html (Zeile 51-63)

**ERSETZE diesen kompletten Block:**

```html
<script type="importmap">
{
  "imports": {
    "react": "https://esm.sh/react@18.3.1",
    "react/jsx-runtime": "https://esm.sh/react@18.3.1/jsx-runtime",
    "react-dom": "https://esm.sh/react-dom@18.3.1?deps=react@18.3.1",
    "react-dom/client": "https://esm.sh/react-dom@18.3.1/client?deps=react@18.3.1",
    "@google/genai": "https://esm.sh/@google/genai",
    "lucide-react": "https://esm.sh/lucide-react@0.460.0?deps=react@18.3.1",
    "firebase/app": "https://esm.sh/firebase@10.7.1/app",
    "firebase/auth": "https://esm.sh/firebase@10.7.1/auth?deps=firebase@10.7.1",
    "react-dom/": "https://aistudiocdn.com/react-dom@^19.2.0/",
    "react/": "https://aistudiocdn.com/react@^19.2.0/",
    "firebase/": "https://aistudiocdn.com/firebase@^12.6.0/"
  }
}
</script>
```

**DURCH:**

```html
<script type="importmap">
{
  "imports": {
    "react": "https://esm.sh/react@18.3.1",
    "react/jsx-runtime": "https://esm.sh/react@18.3.1/jsx-runtime",
    "react-dom": "https://esm.sh/react-dom@18.3.1?deps=react@18.3.1",
    "react-dom/client": "https://esm.sh/react-dom@18.3.1/client?deps=react@18.3.1",
    "@google/genai": "https://esm.sh/@google/genai",
    "lucide-react": "https://esm.sh/lucide-react@0.460.0?deps=react@18.3.1",
    "firebase/app": "https://esm.sh/firebase@10.7.1/app",
    "firebase/auth": "https://esm.sh/firebase@10.7.1/auth?deps=firebase@10.7.1"
  }
}
</script>
```

**❌ WICHTIG: Lösche die letzten 3 Zeilen:**
- `"react-dom/": ...`
- `"react/": ...`
- `"firebase/": ...`

---

## 2️⃣ index.html (Zeile 12)

**ÄNDERE:**
```javascript
window.process = { env: { API_KEY: '' } };
```

**ZU:**
```javascript
window.process = { env: { GEMINI_API_KEY: '' } };
```

---

## 3️⃣ services/geminiService.ts (Zeile 9)

**ÄNDERE:**
```javascript
if (process.env.API_KEY) {
  ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
```

**ZU:**
```javascript
if (process.env.GEMINI_API_KEY) {
  ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });
```

---

## 🚀 DANACH

1. **Gemini API Key holen:** https://aistudio.google.com/app/apikey
2. **In .env.local eintragen:**
   ```bash
   GEMINI_API_KEY=dein_echter_key_hier
   ```
3. **Starten:**
   ```bash
   npm install
   npm run dev
   ```

**FERTIG!** 🎉

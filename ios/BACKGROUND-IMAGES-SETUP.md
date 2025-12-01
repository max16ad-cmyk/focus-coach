# 🖼️ HINTERGRUNDBILDER FÜR BLOCKIERUNGS-SEITE

## 📸 **BILDER INTEGRIEREN:**

Die folgenden Hintergrundbilder müssen als Assets hinzugefügt werden:

1. **sunset** - Sonnenuntergang in der Wüste
2. **mountains** - Schneebedeckte Berge
3. **riceTerraces** - Reisterrassen mit Nebel
4. **pyramid** - Pyramide gegen blauen Himmel
5. **desertDog** - Hund in der Wüste
6. **zebra** - Zebra in der Savanne
7. **alpineForest** - Alpenwald mit Bergen
8. **almHut** - Almhütte auf grünem Hang

---

## 🔧 **SCHRITTE ZUR INTEGRATION:**

### **1. Bilder zu Xcode Assets hinzufügen:**

1. **Xcode öffnen**
2. **Assets.xcassets** öffnen (oder erstellen falls nicht vorhanden)
3. **Rechtsklick → New Image Set**
4. **Für jedes Bild:**
   - Name: `sunset`, `mountains`, `riceTerraces`, etc.
   - Bild hinzufügen (drag & drop)
   - Für @2x und @3x Versionen (optional)

### **2. Bilder verwenden:**

Die Bilder werden dann über `Image("sunset")` etc. verwendet.

---

## 💡 **HINWEIS:**

**WICHTIG:** Die Blockierungsseite wird von iOS gerendert. Wir können die Bilder möglicherweise **nicht direkt** auf der Blockierungsseite anzeigen, ABER:

1. ✅ **Bilder werden in der App gespeichert**
2. ✅ **User kann Hintergrundbild auswählen**
3. ✅ **Custom Messages werden mit Bildern verknüpft**
4. ❓ **Ob Bilder auf Blockierungsseite erscheinen:** Muss getestet werden

**Falls die API es nicht erlaubt:**
- Bilder können als **Vorschau** in der App verwendet werden
- Custom Messages werden trotzdem gesetzt
- Bilder können für andere Features genutzt werden

---

## 🎯 **NÄCHSTE SCHRITTE:**

1. **Bilder zu Assets hinzufügen** (manuell in Xcode)
2. **Code ist bereits vorbereitet** für die Verwendung
3. **Testen** ob Bilder auf Blockierungsseite erscheinen
4. **Falls nicht:** Bilder als Vorschau in App verwenden





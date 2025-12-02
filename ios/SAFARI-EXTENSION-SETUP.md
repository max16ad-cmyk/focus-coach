# 🦁 SAFARI CONTENT BLOCKER EXTENSION - SETUP GUIDE

## 📋 **WAS WIR BRAUCHEN:**

1. ✅ Content Blocker Extension Target in Xcode
2. ✅ App Group für UserDefaults-Sharing
3. ✅ Extension aktivieren in Safari-Einstellungen

---

## 🔧 **SCHRITT 1: EXTENSION TARGET ERSTELLEN**

### **In Xcode:**

1. **File → New → Target**
2. **iOS → Safari Extension → Content Blocker Extension**
3. **Name:** `FocusCoachContentBlocker`
4. **Bundle Identifier:** `com.MaxJacob.FocusCoach.ContentBlocker`
5. **Language:** Swift
6. **✅ Include UI Extension:** Nein

---

## 🔧 **SCHRITT 2: APP GROUP EINRICHTEN**

### **Für Main App:**

1. **Target → Signing & Capabilities**
2. **+ Capability → App Groups**
3. **Group Name:** `group.com.focuscoach.blocking`
4. **✅ Aktivieren**

### **Für Extension:**

1. **Extension Target → Signing & Capabilities**
2. **+ Capability → App Groups**
3. **Gleiche Group:** `group.com.focuscoach.blocking`
4. **✅ Aktivieren**

---

## 🔧 **SCHRITT 3: CONTENT BLOCKER CODE**

### **Datei:** `ContentBlockerExtension.swift`

```swift
import SafariServices
import SwiftUI

class ContentBlockerExtension: NSObject, NSExtensionRequestHandling {
    
    func beginRequest(with context: NSExtensionContext) {
        // Load blocked URLs from App Group
        let blockedURLs = loadBlockedURLs()
        
        // Create block rules
        let rules = createBlockRules(for: blockedURLs)
        
        // Create attachment
        let attachment = NSItemProvider(contentsOf: createRulesFile(rules: rules))!
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
    
    private func loadBlockedURLs() -> [String] {
        if let sharedDefaults = UserDefaults(suiteName: "group.com.focuscoach.blocking"),
           let urls = sharedDefaults.array(forKey: "blockedURLs") as? [String] {
            return urls
        }
        return []
    }
    
    private func createBlockRules(for urls: [String]) -> [[String: Any]] {
        var rules: [[String: Any]] = []
        
        for url in urls {
            let urlFilter = createURLFilter(for: url)
            
            let rule: [String: Any] = [
                "action": ["type": "block"],
                "trigger": ["url-filter": urlFilter]
            ]
            
            rules.append(rule)
        }
        
        return rules
    }
    
    private func createURLFilter(for url: String) -> String {
        var urlString = url.lowercased()
        
        // Remove protocol
        if let protocolRange = urlString.range(of: "://") {
            urlString = String(urlString[protocolRange.upperBound...])
        }
        
        // Remove www.
        urlString = urlString.replacingOccurrences(of: "www.", with: "")
        urlString = urlString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        // Create regex pattern
        let pattern = ".*\(NSRegularExpression.escapedPattern(for: urlString)).*"
        
        return pattern
    }
    
    private func createRulesFile(rules: [[String: Any]]) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let rulesFile = tempDir.appendingPathComponent("blockerRules.json")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: rules, options: .prettyPrinted)
            try jsonData.write(to: rulesFile)
            return rulesFile
        } catch {
            print("Error creating rules file: \(error)")
            return nil
        }
    }
}
```

---

## 🔧 **SCHRITT 4: INFO.PLIST**

### **Extension Target → Info.plist:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Focus Coach Blocker</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.Safari.content-blocker</string>
        <key>NSExtensionPrincipalClass</key>
        <string>$(PRODUCT_MODULE_NAME).ContentBlockerExtension</string>
    </dict>
</dict>
</plist>
```

---

## 🔧 **SCHRITT 5: EXTENSION IN SAFARI AKTIVIEREN**

### **Auf dem iPhone:**

1. **Einstellungen → Safari → Erweiterungen**
2. **Focus Coach Blocker** aktivieren
3. **✅ Aktiviert**

---

## ✅ **TESTEN:**

1. **App starten**
2. **Einstellungen → Blockierung → URL-Blockierung**
3. **URL hinzufügen** (z.B. `youtube.com`)
4. **Safari öffnen**
5. **youtube.com aufrufen**
6. **✅ Sollte blockiert sein**

---

## 🐛 **TROUBLESHOOTING:**

### **Extension wird nicht angezeigt:**
- ✅ App Group korrekt eingerichtet?
- ✅ Extension Target korrekt erstellt?
- ✅ Build erfolgreich?

### **URLs werden nicht blockiert:**
- ✅ Extension in Safari aktiviert?
- ✅ App Group UserDefaults funktioniert?
- ✅ Rules File korrekt erstellt?

### **Build Fehler:**
- ✅ `SafariServices` Framework hinzugefügt?
- ✅ Extension Target korrekt verlinkt?

---

## 📝 **NOTIZEN:**

- **Nur Safari:** Content Blocker funktioniert nur in Safari
- **App Group:** Benötigt für Daten-Sharing zwischen App und Extension
- **Rules Limit:** Max. 50.000 Rules (für uns kein Problem)
- **Performance:** Sehr schnell, läuft im Hintergrund

---

## 🎯 **FERTIG!**

Die Extension ist jetzt eingerichtet und kann spezifische URLs in Safari blockieren! 🎉






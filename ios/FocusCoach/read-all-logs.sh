#!/bin/bash

echo "🔍 Reading Focus Coach logs..."
echo ""

# Find log files
LOG_FILE=$(find ~/Library/Developer/CoreSimulator/Devices -name "focus-coach-debug.log" -type f 2>/dev/null | head -1)
CRASH_FILE=$(find ~/Library/Developer/CoreSimulator/Devices -name "focus-coach-crash.log" -type f 2>/dev/null | head -1)

if [ -n "$LOG_FILE" ]; then
    echo "✅ Found debug log: $LOG_FILE"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "📋 LAST 100 LINES OF DEBUG LOG"
    echo "═══════════════════════════════════════════════════════════"
    tail -100 "$LOG_FILE"
    echo ""
else
    echo "❌ Debug log file not found"
fi

if [ -n "$CRASH_FILE" ]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "💥 CRASH LOG"
    echo "═══════════════════════════════════════════════════════════"
    cat "$CRASH_FILE"
    echo ""
fi

# Also try to get Xcode console logs
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📱 XCODE CONSOLE LOGS (last 50 lines)"
echo "═══════════════════════════════════════════════════════════"
log show --predicate 'subsystem == "com.focuscoach"' --last 1m --style compact 2>/dev/null | tail -50 || echo "Could not read system logs"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ Log reading complete"
echo "═══════════════════════════════════════════════════════════"

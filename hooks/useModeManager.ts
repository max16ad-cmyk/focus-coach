import { useMemo } from 'react';
import { DayPlan, UserSettings } from '../types';

export type AppMode = 
  | 'overview'       // Kein Plan vorhanden
  | 'create-plan'    // Plan wird erstellt
  | 'active-day'     // Plan vorhanden, Tasks aktiv
  | 'verification'   // Nachweis-Prüfung läuft
  | 'freedom'        // Alle Tasks erledigt
  | 'night'          // Nachtmodus aktiv
  | 'morning-lock';  // Morgen-Sperre aktiv

interface ModeManagerOptions {
  settings: UserSettings;
  dayPlan: DayPlan | null;
  userOverride?: AppMode | null;
}

interface ModeManagerResult {
  currentMode: AppMode;
  canNavigateTo: (mode: AppMode) => boolean;
  isAutoMode: boolean;
}

/**
 * Zentrale Mode-Management-Logik
 * 
 * Diese Hook entscheidet automatisch den korrekten App-Mode basierend auf:
 * - Tageszeit (Night Mode, Morning Lock)
 * - Day Plan Status (vorhanden, bestätigt, erledigt)
 * - User Settings (Modi aktiviert/deaktiviert)
 * - User Override (manuelle Navigation)
 * 
 * @example
 * const { currentMode, canNavigateTo } = useModeManager({ settings, dayPlan });
 */
export const useModeManager = ({
  settings,
  dayPlan,
  userOverride = null,
}: ModeManagerOptions): ModeManagerResult => {
  
  const autoMode = useMemo((): AppMode => {
    const now = new Date();
    const hours = now.getHours();
    const minutes = now.getMinutes();
    const currentTime = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;

    // ========================================
    // 1. NIGHT MODE (Höchste Priorität)
    // ========================================
    if (settings.nightModeEnabled) {
      const [startH, startM] = settings.nightModeStart.split(':').map(Number);
      const [endH, endM] = settings.nightModeEnd.split(':').map(Number);
      
      const nightStart = startH * 60 + startM;
      const nightEnd = endH * 60 + endM;
      const current = hours * 60 + minutes;
      
      // Handle overnight (z.B. 23:00 - 06:00)
      const isNightTime = nightStart > nightEnd
        ? current >= nightStart || current < nightEnd
        : current >= nightStart && current < nightEnd;
      
      if (isNightTime) {
        return 'night';
      }
    }

    // ========================================
    // 2. MORNING LOCK (wenn kein Plan)
    // ========================================
    if (settings.morningLockEnabled && !dayPlan) {
      const [startH, startM] = settings.morningLockStart.split(':').map(Number);
      const [endH, endM] = settings.morningLockEnd.split(':').map(Number);
      
      const morningStart = startH * 60 + startM;
      const morningEnd = endH * 60 + endM;
      const current = hours * 60 + minutes;
      
      const isMorningTime = current >= morningStart && current < morningEnd;
      
      if (isMorningTime) {
        return 'morning-lock';
      }
    }

    // ========================================
    // 3. PLAN-BASIERTE MODI
    // ========================================
    
    // Kein Plan vorhanden
    if (!dayPlan) {
      return 'overview';
    }

    // Plan existiert aber nicht bestätigt (Review)
    if (!dayPlan.confirmed) {
      return 'create-plan';
    }

    // Alle Tasks erledigt → Freedom Mode
    const allCompleted = dayPlan.tasks.every(t => t.completed);
    if (allCompleted) {
      return 'freedom';
    }

    // Standard: Active Day
    return 'active-day';
  }, [settings, dayPlan]);

  // ========================================
  // USER OVERRIDE LOGIC
  // ========================================
  
  const currentMode = userOverride || autoMode;
  const isAutoMode = !userOverride;

  // ========================================
  // NAVIGATION VALIDATION
  // ========================================
  
  const canNavigateTo = (targetMode: AppMode): boolean => {
    // Night Mode blockiert alles (außer Settings)
    if (autoMode === 'night' && settings.nightModeNoUnlock) {
      return false;
    }

    // Morning Lock blockiert Navigation (außer zu create-plan)
    if (autoMode === 'morning-lock') {
      return targetMode === 'create-plan';
    }

    // Verification kann nur von active-day aus erreicht werden
    if (targetMode === 'verification') {
      return currentMode === 'active-day';
    }

    // Freedom kann nur automatisch erreicht werden
    if (targetMode === 'freedom') {
      return false;
    }

    // Alle anderen Modi sind frei navigierbar
    return true;
  };

  return {
    currentMode,
    canNavigateTo,
    isAutoMode,
  };
};

/**
 * Helper: Get Mode Display Name
 */
export const getModeName = (mode: AppMode): string => {
  const names: Record<AppMode, string> = {
    'overview': 'Übersicht',
    'create-plan': 'Plan erstellen',
    'active-day': 'Aktueller Tag',
    'verification': 'Nachweis prüfen',
    'freedom': 'Freizeit-Modus',
    'night': 'Nachtmodus',
    'morning-lock': 'Morgen-Planung',
  };
  return names[mode];
};

/**
 * Helper: Check if mode allows distractions
 */
export const isDistractionsUnlocked = (mode: AppMode): boolean => {
  return mode === 'freedom';
};


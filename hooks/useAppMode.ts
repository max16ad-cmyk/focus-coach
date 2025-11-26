import { useState, useEffect } from 'react';
import { AppMode } from '../types';

export const useAppMode = () => {
  const [mode, setMode] = useState<AppMode>(AppMode.MORNING_LOCK);
  const [currentDate, setCurrentDate] = useState<string>('');

  useEffect(() => {
    // Get current date in YYYY-MM-DD format
    const today = new Date().toISOString().split('T')[0];
    setCurrentDate(today);

    // Check if we're in night mode
    const now = new Date();
    const hours = now.getHours();
    const nightModeStart = 23; // 23:00
    const nightModeEnd = 6; // 06:00

    if (hours >= nightModeStart || hours < nightModeEnd) {
      setMode(AppMode.NIGHT_MODE);
      return;
    }

    // Check if plan exists for today
    // This will be handled by the parent component checking Firestore
    // For now, default to MORNING_LOCK
  }, []);

  return { mode, setMode, currentDate };
};


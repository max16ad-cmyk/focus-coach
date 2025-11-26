import React, { useState, useEffect } from 'react';
import { DayPlan, User, UserSettings } from './types';
import {
  subscribeToAuthChanges,
  logoutUser,
  initializeUserData,
  subscribeToDayPlan,
  subscribeToSettings,
  updateSettingsInFirestore,
} from './services/firebase';
import { AuthScreen } from './components/AuthScreen';
import { Dashboard } from './components/Dashboard';

const DEFAULT_SETTINGS: UserSettings = {
  coachPersonality: 'sergeant',
  nightModeStart: '23:00',
  nightModeEnd: '06:00',
  blockedSites: [],
  allowedSites: [],
  requirePhotoProof: true,
  proofStrictness: 'medium',
  emergencyUnlockEnabled: true,
  emergencyUnlockDuration: 5,
  emergencyUnlockCooldown: 24,
  nightModeEnabled: true,
  nightModeNoUnlock: true,
  morningLockEnabled: false,
  morningLockStart: '06:00',
  morningLockEnd: '12:00',
};

const App: React.FC = () => {
  const [user, setUser] = useState<User | null>(null);
  const [authInitialized, setAuthInitialized] = useState(false);
  const [currentDate, setCurrentDate] = useState<string>('');
  const [dayPlan, setDayPlan] = useState<DayPlan | null>(null);
  const [settings, setSettings] = useState<UserSettings>(DEFAULT_SETTINGS);

  // Initialize date
  useEffect(() => {
    const today = new Date().toISOString().split('T')[0];
    setCurrentDate(today);
  }, []);

  // Auth listener
  useEffect(() => {
    const unsubscribe = subscribeToAuthChanges(async (firebaseUser) => {
      if (firebaseUser) {
        await initializeUserData(firebaseUser.uid);
        setUser({
          uid: firebaseUser.uid,
          email: firebaseUser.email || '',
          name: firebaseUser.email?.split('@')[0] || 'User',
        });
      } else {
        setUser(null);
        setDayPlan(null);
      }
      setAuthInitialized(true);
    });
    return () => unsubscribe();
  }, []);

  // Subscribe to settings (Multi-Device Sync)
  useEffect(() => {
    if (!user?.uid) return;

    const unsubscribe = subscribeToSettings(user.uid, (firestoreSettings) => {
      setSettings(firestoreSettings);
    });

    return () => unsubscribe();
  }, [user?.uid]);

  // Subscribe to day plan
  useEffect(() => {
    if (!user?.uid || !currentDate) return;

    const unsubscribe = subscribeToDayPlan(user.uid, currentDate, (plan) => {
      setDayPlan(plan);
    });

    return () => unsubscribe();
  }, [user?.uid, currentDate]);

  const handleSettingsUpdate = async (newSettings: UserSettings) => {
    if (!user?.uid) return;
    await updateSettingsInFirestore(user.uid, newSettings);
    setSettings(newSettings);
  };

  if (!authInitialized) {
    return (
      <div className="min-h-screen bg-slate-950 flex items-center justify-center">
        <div className="text-center text-slate-400">
          <div className="w-12 h-12 border-4 border-slate-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p>Loading Focus Coach...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return <AuthScreen onLogin={() => {}} />;
  }

  return (
    <Dashboard
      user={user}
      settings={settings}
      dayPlan={dayPlan}
      currentDate={currentDate}
      onSettingsUpdate={handleSettingsUpdate}
      onDayPlanUpdate={setDayPlan}
    />
  );
};

export default App;

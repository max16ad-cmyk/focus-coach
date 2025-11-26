import React, { useState } from 'react';
import { CoachPersonality, UserSettings } from '../types';
import { CoachMessage } from './coach/CoachMessage';
import { Settings, X, Moon, Lock, Shield, Clock } from 'lucide-react';

interface SettingsScreenProps {
  settings: UserSettings;
  onUpdate: (settings: UserSettings) => void;
  onClose: () => void;
}

const personalityOptions: { value: CoachPersonality; label: string; icon: string; description: string }[] = [
  { value: 'sergeant', label: 'Sergeant', icon: '🎖️', description: 'Militärisch, direkt, keine Ausreden' },
  { value: 'professor', label: 'Professor', icon: '🎓', description: 'Sachlich, analytisch, erklärend' },
  { value: 'mentor', label: 'Mentor', icon: '🧭', description: 'Bestimmt aber unterstützend' },
  { value: 'minimalist', label: 'Minimalist', icon: '⚡', description: 'Wenige Worte, auf den Punkt' },
];

export const SettingsScreen: React.FC<SettingsScreenProps> = ({ settings, onUpdate, onClose }) => {
  const [localSettings, setLocalSettings] = useState<UserSettings>(settings);

  const handleSave = () => {
    onUpdate(localSettings);
    onClose();
  };

  const updateSetting = <K extends keyof UserSettings>(key: K, value: UserSettings[K]) => {
    setLocalSettings(prev => ({ ...prev, [key]: value }));
  };

  return (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-50 overflow-y-auto">
      <div className="min-h-screen p-4 md:p-8">
        <div className="max-w-3xl mx-auto bg-slate-900 border border-slate-800 rounded-2xl p-6 md:p-8 space-y-8">
          {/* Header */}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Settings size={24} className="text-slate-400" />
              <h2 className="text-2xl font-bold text-white">Einstellungen</h2>
            </div>
            <button
              onClick={onClose}
              className="text-slate-400 hover:text-white transition-colors"
            >
              <X size={24} />
            </button>
          </div>

          {/* Divider */}
          <div className="border-t border-slate-800"></div>

          {/* Coach Personality */}
          <div>
            <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
              <Shield size={20} />
              Coach-Persönlichkeit
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              {personalityOptions.map((option) => (
                <button
                  key={option.value}
                  onClick={() => updateSetting('coachPersonality', option.value)}
                  className={`p-4 rounded-xl border-2 transition-all ${
                    localSettings.coachPersonality === option.value
                      ? 'border-blue-500 bg-blue-950/30'
                      : 'border-slate-700 bg-slate-800/50 hover:border-slate-600'
                  }`}
                >
                  <div className="text-3xl mb-2">{option.icon}</div>
                  <div className="text-sm font-medium text-white mb-1">{option.label}</div>
                  <div className="text-xs text-slate-400">{option.description}</div>
                  {localSettings.coachPersonality === option.value && (
                    <div className="mt-2 text-xs text-blue-400">✓ Aktiv</div>
                  )}
                </button>
              ))}
            </div>
          </div>

          {/* Divider */}
          <div className="border-t border-slate-800"></div>

          {/* Morning Lock */}
          <div>
            <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
              <span>🌅</span>
              Morgen-Planung
            </h3>
            <div className="space-y-4">
              <div className="flex items-center gap-4">
                <label className="flex items-center gap-2 text-slate-300">
                  <input
                    type="checkbox"
                    checked={localSettings.morningLockEnabled}
                    onChange={(e) => updateSetting('morningLockEnabled', e.target.checked)}
                    className="w-4 h-4 rounded border-slate-600 bg-slate-800 text-blue-500 focus:ring-blue-500"
                  />
                  <span>Morgen-Planung aktivieren</span>
                </label>
              </div>

              {localSettings.morningLockEnabled && (
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm text-slate-400 mb-2">Start</label>
                    <input
                      type="time"
                      value={localSettings.morningLockStart}
                      onChange={(e) => updateSetting('morningLockStart', e.target.value)}
                      className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-2 text-white"
                    />
                  </div>
                  <div>
                    <label className="block text-sm text-slate-400 mb-2">Ende</label>
                    <input
                      type="time"
                      value={localSettings.morningLockEnd}
                      onChange={(e) => updateSetting('morningLockEnd', e.target.value)}
                      className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-2 text-white"
                    />
                  </div>
                </div>
              )}
              <p className="text-xs text-slate-500">
                Wenn aktiviert, erscheint die Planungsansicht nur in diesem Zeitfenster, wenn noch kein Plan erstellt wurde.
              </p>
            </div>
          </div>

          {/* Divider */}
          <div className="border-t border-slate-800"></div>

          {/* Night Mode */}
          <div>
            <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
              <Moon size={20} />
              Nachtmodus
            </h3>
            <div className="space-y-4">
              <div className="flex items-center gap-4">
                <label className="flex items-center gap-2 text-slate-300">
                  <input
                    type="checkbox"
                    checked={localSettings.nightModeEnabled}
                    onChange={(e) => updateSetting('nightModeEnabled', e.target.checked)}
                    className="w-4 h-4 rounded border-slate-600 bg-slate-800 text-blue-500 focus:ring-blue-500"
                  />
                  <span>Nachtmodus aktivieren</span>
                </label>
              </div>

              {localSettings.nightModeEnabled && (
                <>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm text-slate-400 mb-2">Start</label>
                      <input
                        type="time"
                        value={localSettings.nightModeStart}
                        onChange={(e) => updateSetting('nightModeStart', e.target.value)}
                        className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-2 text-white"
                      />
                    </div>
                    <div>
                      <label className="block text-sm text-slate-400 mb-2">Ende</label>
                      <input
                        type="time"
                        value={localSettings.nightModeEnd}
                        onChange={(e) => updateSetting('nightModeEnd', e.target.value)}
                        className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-2 text-white"
                      />
                    </div>
                  </div>

                  <div className="flex items-center gap-2 text-slate-300">
                    <input
                      type="checkbox"
                      checked={localSettings.nightModeNoUnlock}
                      onChange={(e) => updateSetting('nightModeNoUnlock', e.target.checked)}
                      className="w-4 h-4 rounded border-slate-600 bg-slate-800 text-blue-500 focus:ring-blue-500"
                    />
                    <span>Kein Notfall-Unlock im Nachtmodus</span>
                  </div>
                </>
              )}
            </div>
          </div>

          {/* Divider */}
          <div className="border-t border-slate-800"></div>

          {/* Proof Settings */}
          <div>
            <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
              <Lock size={20} />
              Nachweis-Einstellungen
            </h3>
            <div className="space-y-4">
              <div className="flex items-center gap-2 text-slate-300">
                <input
                  type="checkbox"
                  checked={localSettings.requirePhotoProof}
                  onChange={(e) => updateSetting('requirePhotoProof', e.target.checked)}
                  className="w-4 h-4 rounded border-slate-600 bg-slate-800 text-blue-500 focus:ring-blue-500"
                />
                <span>Foto-Nachweis standardmäßig aktivieren</span>
              </div>

              <div>
                <label className="block text-sm text-slate-400 mb-2">Nachweis-Strenge</label>
                <select
                  value={localSettings.proofStrictness}
                  onChange={(e) => updateSetting('proofStrictness', e.target.value as 'low' | 'medium' | 'high')}
                  className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-2 text-white"
                >
                  <option value="low">Niedrig (meist akzeptiert)</option>
                  <option value="medium">Mittel (ausgewogen)</option>
                  <option value="high">Hoch (sehr streng)</option>
                </select>
              </div>
            </div>
          </div>

          {/* Divider */}
          <div className="border-t border-slate-800"></div>

          {/* Emergency Unlock */}
          <div>
            <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
              <Clock size={20} />
              Notfall-Zugriff
            </h3>
            <div className="space-y-4">
              <div className="flex items-center gap-2 text-slate-300">
                <input
                  type="checkbox"
                  checked={localSettings.emergencyUnlockEnabled}
                  onChange={(e) => updateSetting('emergencyUnlockEnabled', e.target.checked)}
                  className="w-4 h-4 rounded border-slate-600 bg-slate-800 text-blue-500 focus:ring-blue-500"
                />
                <span>Notfall-Zugriff aktivieren</span>
              </div>

              {localSettings.emergencyUnlockEnabled && (
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm text-slate-400 mb-2">Dauer (Minuten)</label>
                    <input
                      type="number"
                      min="1"
                      max="60"
                      value={localSettings.emergencyUnlockDuration}
                      onChange={(e) => updateSetting('emergencyUnlockDuration', parseInt(e.target.value))}
                      className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-2 text-white"
                    />
                  </div>
                  <div>
                    <label className="block text-sm text-slate-400 mb-2">Cooldown (Stunden)</label>
                    <input
                      type="number"
                      min="1"
                      max="168"
                      value={localSettings.emergencyUnlockCooldown}
                      onChange={(e) => updateSetting('emergencyUnlockCooldown', parseInt(e.target.value))}
                      className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-2 text-white"
                    />
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Divider */}
          <div className="border-t border-slate-800"></div>

          {/* Save Button */}
          <div className="flex gap-4">
            <button
              onClick={onClose}
              className="flex-1 bg-slate-700 hover:bg-slate-600 text-white font-medium py-3 px-6 rounded-xl transition-colors"
            >
              Abbrechen
            </button>
            <button
              onClick={handleSave}
              className="flex-1 bg-white text-slate-900 font-semibold py-3 px-6 rounded-xl hover:bg-slate-100 transition-colors"
            >
              Speichern
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};


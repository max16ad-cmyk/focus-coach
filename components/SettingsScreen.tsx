import React, { useState } from 'react';
import { CoachPersonality, UserSettings } from '../types';
import { Settings, X, Moon, Lock, Shield, Clock } from 'lucide-react';
import { buildHeadline, buildBodyText, GLASS_EFFECTS, PREMIUM_LAYOUT, PREMIUM_COMPONENTS } from '../theme-premium';

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
    <div className="fixed inset-0 bg-black/60 backdrop-blur-2xl z-50 overflow-y-auto" style={{ paddingTop: 'env(safe-area-inset-top)' }}>
      <div className="min-h-screen p-4 md:p-8 lg:p-12">
        <div className={`${PREMIUM_LAYOUT.container.medium} relative z-10`}>
          <div className={`${GLASS_EFFECTS.modal.content} rounded-3xl p-6 md:p-8 lg:p-10 space-y-8`}>
            
            {/* Header */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className={`${GLASS_EFFECTS.card.base} rounded-xl p-2`}>
                  <Settings size={24} className="text-white/80" />
                </div>
                <h2 className={buildHeadline('md', false)}>
                  Einstellungen
                </h2>
              </div>
              <button
                onClick={onClose}
                className={`${GLASS_EFFECTS.card.base} rounded-xl p-2 text-white/60 hover:text-white hover:bg-white/[0.08] transition-all`}
              >
                <X size={24} />
              </button>
            </div>

            {/* Divider */}
            <div className="border-t border-white/[0.08]"></div>

            {/* Coach Personality */}
            <div>
              <h3 className={`${buildBodyText('md', 'semibold')} mb-4 flex items-center gap-2`}>
                <Shield size={20} className="text-blue-400" />
                Coach-Persönlichkeit
              </h3>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                {personalityOptions.map((option) => (
                  <button
                    key={option.value}
                    onClick={() => updateSetting('coachPersonality', option.value)}
                    className={`${GLASS_EFFECTS.card.base} ${GLASS_EFFECTS.card.hover} rounded-2xl p-5 transition-all ${
                      localSettings.coachPersonality === option.value
                        ? 'border-l-4 border-l-blue-400/70 shadow-[0_0_30px_rgba(96,165,250,0.2)]'
                        : ''
                    }`}
                  >
                    <div className="text-4xl mb-3">{option.icon}</div>
                    <div className={`${buildBodyText('sm', 'semibold')} mb-1`}>{option.label}</div>
                    <div className="text-xs text-white/50 leading-relaxed">{option.description}</div>
                    {localSettings.coachPersonality === option.value && (
                      <div className="mt-3 text-xs text-blue-400 flex items-center gap-1">
                        <span>✓</span>
                        <span>Aktiv</span>
                      </div>
                    )}
                  </button>
                ))}
              </div>
            </div>

            {/* Divider */}
            <div className="border-t border-white/[0.08]"></div>

            {/* Morning Lock */}
            <div>
              <h3 className={`${buildBodyText('md', 'semibold')} mb-4 flex items-center gap-2`}>
                <span className="text-2xl">🌅</span>
                Morgen-Planung
              </h3>
              <div className={`${GLASS_EFFECTS.card.base} rounded-2xl p-6 space-y-4`}>
                <div className="flex items-center gap-4">
                  <label className="flex items-center gap-3 text-white/80 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={localSettings.morningLockEnabled}
                      onChange={(e) => updateSetting('morningLockEnabled', e.target.checked)}
                      className="w-5 h-5 rounded border-white/20 bg-white/[0.05] text-blue-500 focus:ring-blue-500 focus:ring-2"
                    />
                    <span>Morgen-Planung aktivieren</span>
                  </label>
                </div>

                {localSettings.morningLockEnabled && (
                  <div className="grid grid-cols-2 gap-4 pt-4 border-t border-white/[0.05]">
                    <div>
                      <label className={`${buildBodyText('xs', 'medium')} block mb-2 text-white/60`}>Start</label>
                      <input
                        type="time"
                        value={localSettings.morningLockStart}
                        onChange={(e) => updateSetting('morningLockStart', e.target.value)}
                        className={`${GLASS_EFFECTS.input.base} w-full rounded-xl px-4 py-3 text-white`}
                      />
                    </div>
                    <div>
                      <label className={`${buildBodyText('xs', 'medium')} block mb-2 text-white/60`}>Ende</label>
                      <input
                        type="time"
                        value={localSettings.morningLockEnd}
                        onChange={(e) => updateSetting('morningLockEnd', e.target.value)}
                        className={`${GLASS_EFFECTS.input.base} w-full rounded-xl px-4 py-3 text-white`}
                      />
                    </div>
                  </div>
                )}
                <p className="text-xs text-white/40 pt-2">
                  Wenn aktiviert, erscheint die Planungsansicht nur in diesem Zeitfenster, wenn noch kein Plan erstellt wurde.
                </p>
              </div>
            </div>

            {/* Divider */}
            <div className="border-t border-white/[0.08]"></div>

            {/* Night Mode */}
            <div>
              <h3 className={`${buildBodyText('md', 'semibold')} mb-4 flex items-center gap-2`}>
                <Moon size={20} className="text-indigo-400" />
                Nachtmodus
              </h3>
              <div className={`${GLASS_EFFECTS.card.base} rounded-2xl p-6 space-y-4`}>
                <div className="flex items-center gap-4">
                  <label className="flex items-center gap-3 text-white/80 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={localSettings.nightModeEnabled}
                      onChange={(e) => updateSetting('nightModeEnabled', e.target.checked)}
                      className="w-5 h-5 rounded border-white/20 bg-white/[0.05] text-blue-500 focus:ring-blue-500 focus:ring-2"
                    />
                    <span>Nachtmodus aktivieren</span>
                  </label>
                </div>

                {localSettings.nightModeEnabled && (
                  <>
                    <div className="grid grid-cols-2 gap-4 pt-4 border-t border-white/[0.05]">
                      <div>
                        <label className={`${buildBodyText('xs', 'medium')} block mb-2 text-white/60`}>Start</label>
                        <input
                          type="time"
                          value={localSettings.nightModeStart}
                          onChange={(e) => updateSetting('nightModeStart', e.target.value)}
                          className={`${GLASS_EFFECTS.input.base} w-full rounded-xl px-4 py-3 text-white`}
                        />
                      </div>
                      <div>
                        <label className={`${buildBodyText('xs', 'medium')} block mb-2 text-white/60`}>Ende</label>
                        <input
                          type="time"
                          value={localSettings.nightModeEnd}
                          onChange={(e) => updateSetting('nightModeEnd', e.target.value)}
                          className={`${GLASS_EFFECTS.input.base} w-full rounded-xl px-4 py-3 text-white`}
                        />
                      </div>
                    </div>

                    <div className="flex items-center gap-3 pt-4 border-t border-white/[0.05]">
                      <input
                        type="checkbox"
                        checked={localSettings.nightModeNoUnlock}
                        onChange={(e) => updateSetting('nightModeNoUnlock', e.target.checked)}
                        className="w-5 h-5 rounded border-white/20 bg-white/[0.05] text-blue-500 focus:ring-blue-500 focus:ring-2"
                      />
                      <span className="text-white/80">Kein Notfall-Unlock im Nachtmodus</span>
                    </div>
                  </>
                )}
              </div>
            </div>

            {/* Divider */}
            <div className="border-t border-white/[0.08]"></div>

            {/* Proof Settings */}
            <div>
              <h3 className={`${buildBodyText('md', 'semibold')} mb-4 flex items-center gap-2`}>
                <Lock size={20} className="text-amber-400" />
                Nachweis-Einstellungen
              </h3>
              <div className={`${GLASS_EFFECTS.card.base} rounded-2xl p-6 space-y-4`}>
                <div className="flex items-center gap-3">
                  <input
                    type="checkbox"
                    checked={localSettings.requirePhotoProof}
                    onChange={(e) => updateSetting('requirePhotoProof', e.target.checked)}
                    className="w-5 h-5 rounded border-white/20 bg-white/[0.05] text-blue-500 focus:ring-blue-500 focus:ring-2"
                  />
                  <span className="text-white/80">Foto-Nachweis standardmäßig aktivieren</span>
                </div>

                <div className="pt-4 border-t border-white/[0.05]">
                  <label className={`${buildBodyText('xs', 'medium')} block mb-2 text-white/60`}>Nachweis-Strenge</label>
                  <select
                    value={localSettings.proofStrictness}
                    onChange={(e) => updateSetting('proofStrictness', e.target.value as 'low' | 'medium' | 'high')}
                    className={`${GLASS_EFFECTS.input.base} w-full rounded-xl px-4 py-3 text-white`}
                  >
                    <option value="low">Niedrig (meist akzeptiert)</option>
                    <option value="medium">Mittel (ausgewogen)</option>
                    <option value="high">Hoch (sehr streng)</option>
                  </select>
                </div>
              </div>
            </div>

            {/* Divider */}
            <div className="border-t border-white/[0.08]"></div>

            {/* Emergency Unlock */}
            <div>
              <h3 className={`${buildBodyText('md', 'semibold')} mb-4 flex items-center gap-2`}>
                <Clock size={20} className="text-red-400" />
                Notfall-Zugriff
              </h3>
              <div className={`${GLASS_EFFECTS.card.base} rounded-2xl p-6 space-y-4`}>
                <div className="flex items-center gap-3">
                  <input
                    type="checkbox"
                    checked={localSettings.emergencyUnlockEnabled}
                    onChange={(e) => updateSetting('emergencyUnlockEnabled', e.target.checked)}
                    className="w-5 h-5 rounded border-white/20 bg-white/[0.05] text-blue-500 focus:ring-blue-500 focus:ring-2"
                  />
                  <span className="text-white/80">Notfall-Zugriff aktivieren</span>
                </div>

                {localSettings.emergencyUnlockEnabled && (
                  <div className="grid grid-cols-2 gap-4 pt-4 border-t border-white/[0.05]">
                    <div>
                      <label className={`${buildBodyText('xs', 'medium')} block mb-2 text-white/60`}>Dauer (Minuten)</label>
                      <input
                        type="number"
                        min="1"
                        max="60"
                        value={localSettings.emergencyUnlockDuration}
                        onChange={(e) => updateSetting('emergencyUnlockDuration', parseInt(e.target.value))}
                        className={`${GLASS_EFFECTS.input.base} w-full rounded-xl px-4 py-3 text-white`}
                      />
                    </div>
                    <div>
                      <label className={`${buildBodyText('xs', 'medium')} block mb-2 text-white/60`}>Cooldown (Stunden)</label>
                      <input
                        type="number"
                        min="1"
                        max="168"
                        value={localSettings.emergencyUnlockCooldown}
                        onChange={(e) => updateSetting('emergencyUnlockCooldown', parseInt(e.target.value))}
                        className={`${GLASS_EFFECTS.input.base} w-full rounded-xl px-4 py-3 text-white`}
                      />
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* Divider */}
            <div className="border-t border-white/[0.08]"></div>

            {/* Save Button */}
            <div className="flex flex-col sm:flex-row gap-4">
              <button
                onClick={onClose}
                className={`${PREMIUM_COMPONENTS.button.secondary} flex-1`}
              >
                Abbrechen
              </button>
              <button
                onClick={handleSave}
                className={`${PREMIUM_COMPONENTS.button.primary} flex-1`}
              >
                Speichern
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

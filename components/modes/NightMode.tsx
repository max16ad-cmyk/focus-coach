import React from 'react';
import { CoachMessage } from '../coach/CoachMessage';
import { CoachPersonality } from '../../types';
import { Moon, Lock, CheckCircle2 } from 'lucide-react';

interface NightModeProps {
  personality: CoachPersonality;
  nightModeEnd: string; // "06:00"
}

export const NightMode: React.FC<NightModeProps> = ({
  personality,
  nightModeEnd,
}) => {
  const now = new Date();
  const timeStr = now.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });

  return (
    <div className="w-full flex items-center justify-center min-h-[80vh] p-4">
      <div className="max-w-xl lg:max-w-3xl w-full space-y-8">
        {/* Moon Icon */}
        <div className="text-center">
          <Moon size={64} className="text-indigo-400 mx-auto mb-4" />
          <h1 className="text-4xl font-bold text-white mb-2">🌙 NACHTMODUS</h1>
          <div className="text-5xl font-mono text-slate-400">{timeStr}</div>
        </div>

        {/* Coach Message */}
        <CoachMessage
          personality={personality}
          message="Es ist spät. Alle Ablenkungen sind gesperrt bis morgen früh. Keine Ausnahmen. Geh schlafen."
        />

        {/* Divider */}
        <div className="border-t border-slate-800"></div>

        {/* Blocked Notice */}
        <div className="text-center space-y-4">
          <div className="flex items-center justify-center gap-2 text-red-500 text-xl font-semibold">
            <Lock size={24} />
            <span>⛔ BLOCKIERT BIS {nightModeEnd}</span>
          </div>
          <div className="text-slate-400 space-y-2">
            <p>YouTube, Instagram, Twitter, TikTok,</p>
            <p>Reddit, Twitch, Netflix, Gaming...</p>
          </div>
        </div>

        {/* Divider */}
        <div className="border-t border-slate-800"></div>

        {/* Allowed Sites */}
        <div>
          <h3 className="text-lg font-semibold text-white mb-4">ERLAUBT:</h3>
          <div className="space-y-2">
            {[
              'Notfall-Kontakte (Telefon, WhatsApp)',
              'Google Maps / Navigation',
              'Wikipedia / Lernseiten',
              'E-Mail',
              'Banking / Wichtige Dienste',
            ].map((item) => (
              <div
                key={item}
                className="flex items-center gap-3 p-3 bg-slate-900/50 border border-slate-800 rounded-lg"
              >
                <CheckCircle2 size={16} className="text-green-400" />
                <span className="text-slate-300">✅ {item}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Divider */}
        <div className="border-t border-slate-800"></div>

        {/* No Emergency Unlock */}
        <div className="text-center">
          <div className="inline-flex items-center gap-2 text-slate-600 text-sm">
            <Lock size={16} />
            <span>🔒 Kein Notfall-Unlock im Nachtmodus</span>
          </div>
        </div>
      </div>
    </div>
  );
};


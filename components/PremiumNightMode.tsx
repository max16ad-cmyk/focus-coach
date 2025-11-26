import React from 'react';
import { Moon, Lock } from 'lucide-react';
import { buildHeadline, buildBodyText, PREMIUM_LAYOUT, GLASS_EFFECTS } from '../theme-premium';

interface PremiumNightModeProps {
  nightModeEnd: string; // "06:00"
}

/**
 * Premium Night Mode - Lockdown screen
 */
export const PremiumNightMode: React.FC<PremiumNightModeProps> = ({
  nightModeEnd
}) => {
  const now = new Date();
  const timeStr = now.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });

  return (
    <div className="min-h-screen flex items-center justify-center px-6 lg:px-12">
      {/* Background - Darker for night */}
      <div className="absolute inset-0 bg-gradient-to-br from-indigo-950/30 via-[#0a0a0a] to-purple-950/30"></div>
      <div className="absolute top-1/3 right-1/3 w-[500px] h-[500px] bg-indigo-500/10 rounded-full blur-3xl"></div>
      
      <div className={`${PREMIUM_LAYOUT.container.medium} relative z-10`}>
        <div className="text-center space-y-12">
          
          {/* Moon Icon */}
          <div className="relative inline-block">
            <div className="absolute inset-0 bg-indigo-500/20 rounded-full blur-2xl"></div>
            <Moon size={80} className="text-indigo-400 relative z-10" />
          </div>

          {/* Current Time */}
          <div className="text-7xl font-mono text-white/80">
            {timeStr}
          </div>

          {/* Headline */}
          <div className="space-y-4">
            <h1 className={buildHeadline('lg', true)}>
              Nachtmodus aktiv
            </h1>
            <p className={`${buildBodyText('lg', 'normal')} max-w-lg mx-auto`}>
              Es ist Zeit zu schlafen. Alle Ablenkungen sind gesperrt bis {nightModeEnd}.
            </p>
          </div>

          {/* Lockdown Info Card */}
          <div className={`${GLASS_EFFECTS.card.base} rounded-3xl p-8 lg:p-10 max-w-md mx-auto border-l-4 border-l-indigo-400/50`}>
            <div className="flex items-center gap-3 mb-4">
              <Lock size={24} className="text-indigo-400" />
              <h3 className="text-lg font-light text-white">
                Komplett gesperrt
              </h3>
            </div>
            <p className="text-white/60 text-sm leading-relaxed">
              Im Nachtmodus gibt es keine Ausnahmen. Kein Notfall-Unlock, keine Ablenkungen.
              Dein Schlaf ist wichtiger.
            </p>
          </div>

          {/* Tips */}
          <div className="space-y-3 max-w-lg mx-auto">
            <div className={`${GLASS_EFFECTS.card.base} rounded-xl p-4 backdrop-blur-md bg-white/[0.02]`}>
              <p className="text-white/50 text-sm">
                💤 Leg dein Gerät weg und schlafe gut
              </p>
            </div>
            <div className={`${GLASS_EFFECTS.card.base} rounded-xl p-4 backdrop-blur-md bg-white/[0.02]`}>
              <p className="text-white/50 text-sm">
                ☀️ Entsperrt automatisch um {nightModeEnd} Uhr
              </p>
            </div>
          </div>

          {/* Footer */}
          <div className="pt-8">
            <p className="text-white/20 text-xs">
              Gute Nacht 🌙
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};


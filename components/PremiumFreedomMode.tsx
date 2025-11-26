import React from 'react';
import { Task } from '../types';
import { CheckCircle2, Sparkles, Trophy } from 'lucide-react';
import { buildHeadline, buildBodyText, PREMIUM_LAYOUT, GLASS_EFFECTS } from '../theme-premium';

interface PremiumFreedomModeProps {
  completedTasks: Task[];
}

/**
 * Premium Freedom Mode - Celebration screen
 */
export const PremiumFreedomMode: React.FC<PremiumFreedomModeProps> = ({
  completedTasks
}) => {
  const now = new Date();
  const nightModeStart = 23;
  const hoursUntilNight = nightModeStart - now.getHours();

  return (
    <div className="min-h-screen flex items-center justify-center px-6 lg:px-12">
      {/* Background Glow Effects */}
      <div className="absolute top-1/4 right-1/4 w-[600px] h-[600px] bg-green-500/10 rounded-full blur-3xl"></div>
      <div className="absolute bottom-1/4 left-1/4 w-[500px] h-[500px] bg-blue-500/10 rounded-full blur-3xl"></div>
      
      <div className={`${PREMIUM_LAYOUT.container.medium} relative z-10`}>
        <div className="text-center space-y-12">
          
          {/* Celebration Badge */}
          <div className="inline-flex items-center gap-2 backdrop-blur-md bg-white/[0.05] border border-white/[0.1] rounded-full px-5 py-2">
            <Trophy size={16} className="text-yellow-400" />
            <span className="text-sm text-white/70">Alle Aufgaben erledigt</span>
          </div>

          {/* Main Headline */}
          <div className="space-y-6">
            <div className="text-7xl mb-4">🎉</div>
            <h1 className={buildHeadline('xl', true)}>
              Perfekt gemacht!
            </h1>
            <p className={`${buildBodyText('lg', 'normal')} max-w-xl mx-auto`}>
              Du hast alle Aufgaben für heute erledigt.
              <br />
              Zeit für eine wohlverdiente Pause.
            </p>
          </div>

          {/* Completed Tasks Summary Card */}
          <div className={`${GLASS_EFFECTS.card.base} rounded-3xl p-8 lg:p-10 max-w-2xl mx-auto`}>
            <div className="flex items-center gap-3 mb-6">
              <Sparkles size={24} className="text-green-400" />
              <h3 className="text-xl font-serif italic text-white">
                Heute erledigt
              </h3>
            </div>
            
            <div className="space-y-3">
              {completedTasks.map((task) => (
                <div
                  key={task.id}
                  className="flex items-center gap-3 p-4 backdrop-blur-md bg-white/[0.03] rounded-xl border border-white/[0.05]"
                >
                  <CheckCircle2 size={20} className="text-green-400 flex-shrink-0" />
                  <span className="text-white/80 flex-1 text-left">{task.title}</span>
                  {task.verified && (
                    <span className="text-xs bg-green-500/20 border border-green-500/30 rounded-full px-2 py-1 text-green-400">
                      Verifiziert
                    </span>
                  )}
                </div>
              ))}
            </div>
          </div>

          {/* Night Mode Warning */}
          {hoursUntilNight > 0 && hoursUntilNight <= 6 && (
            <div className={`${GLASS_EFFECTS.card.base} rounded-2xl p-6 max-w-md mx-auto border-l-4 border-l-purple-400/50`}>
              <p className="text-white/60 text-sm">
                🌙 Nachtmodus aktiviert sich in {hoursUntilNight} Stunden
              </p>
            </div>
          )}

          {/* Footer */}
          <div className="pt-8">
            <p className="text-white/30 text-sm">
              Genieße deine Freizeit 😊
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};


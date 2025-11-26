import React from 'react';
import { CoachMessage } from '../coach/CoachMessage';
import { CoachPersonality, Task } from '../../types';
import { CheckCircle2, Lock, Moon } from 'lucide-react';

interface FreedomModeProps {
  personality: CoachPersonality;
  completedTasks: Task[];
}

export const FreedomMode: React.FC<FreedomModeProps> = ({
  personality,
  completedTasks,
}) => {
  const now = new Date();
  const hours = now.getHours();
  const nightModeStart = 23; // 23:00
  const timeUntilNight = nightModeStart - hours;

  return (
    <div className="w-full">
      <div className="space-y-6">
        {/* Coach Message */}
        <CoachMessage
          personality={personality}
          message={`Du hast deine Aufgaben erledigt. Ablenkungen sind freigegeben bis ${nightModeStart}:00.`}
        />

        {/* Divider */}
        <div className="border-t border-slate-800"></div>

        {/* Freedom Header */}
        <div className="text-center space-y-4">
          <div className="text-6xl mb-4">🔓</div>
          <h2 className="text-3xl font-bold text-white">FREIGEGEBEN</h2>
        </div>

        {/* Allowed Sites */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {[
            { name: 'YouTube', icon: '📺', allowed: true },
            { name: 'Instagram', icon: '📸', allowed: true },
            { name: 'Gaming', icon: '🎮', allowed: true },
            { name: 'Twitter', icon: '🐦', allowed: true },
          ].map((site) => (
            <div
              key={site.name}
              className="bg-slate-900/50 border border-slate-700 rounded-xl p-4 text-center"
            >
              <div className="text-3xl mb-2">{site.icon}</div>
              <div className="text-sm text-slate-400 mb-1">{site.name}</div>
              <div className="text-green-500 text-xs">✓</div>
            </div>
          ))}
        </div>

        {/* Divider */}
        <div className="border-t border-slate-800"></div>

        {/* Completed Tasks */}
        <div>
          <h3 className="text-lg font-semibold text-white mb-4">HEUTE ERLEDIGT:</h3>
          <div className="space-y-2">
            {completedTasks.map((task) => (
              <div
                key={task.id}
                className="flex items-center gap-3 p-3 bg-slate-900/50 border border-slate-800 rounded-lg"
              >
                <CheckCircle2 size={20} className="text-green-400" />
                <span className="flex-1 text-slate-300">{task.title}</span>
                {task.duration && (
                  <span className="text-sm text-slate-500">
                    ({Math.floor(task.duration / 60)}h {task.duration % 60}m)
                  </span>
                )}
                {task.verified && (
                  <span className="text-xs text-green-400 bg-green-900/30 px-2 py-1 rounded">
                    Verifiziert
                  </span>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Divider */}
        <div className="border-t border-slate-800"></div>

        {/* Night Mode Warning */}
        <div className="bg-slate-900/50 border border-slate-800 rounded-xl p-4">
          <div className="flex items-center gap-3 mb-2">
            <Moon size={20} className="text-indigo-400" />
            <span className="text-white font-medium">⏰ Nachtmodus aktiviert sich um {nightModeStart}:00</span>
          </div>
          <p className="text-sm text-slate-400">
            Ab dann: Keine Ablenkungen mehr möglich
          </p>
        </div>
      </div>
    </div>
  );
};


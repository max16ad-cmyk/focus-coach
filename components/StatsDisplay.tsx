import React from 'react';
import { UserStats } from '../types';
import { Trophy, Flame, Zap, AlertTriangle } from 'lucide-react';
import { LEVEL_THRESHOLDS } from '../constants';

interface StatsDisplayProps {
  stats: UserStats;
}

export const StatsDisplay: React.FC<StatsDisplayProps> = ({ stats }) => {
  const nextLevelXP = LEVEL_THRESHOLDS[stats.level] || 10000;
  const progress = Math.min(100, (stats.xp / nextLevelXP) * 100);

  return (
    <div className="bg-vault-800 rounded-xl p-6 border border-vault-700 shadow-lg mb-8">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-full bg-gradient-to-br from-vault-accent to-purple-600 flex items-center justify-center text-xl font-bold shadow-lg shadow-vault-accent/20">
                {stats.level}
            </div>
            <div>
                <h2 className="font-bold text-lg text-white">Focus Master</h2>
                <p className="text-xs text-gray-400">Level {stats.level}</p>
            </div>
        </div>
        <div className="flex gap-4">
            <div className="text-center">
                <div className="flex items-center gap-1 text-vault-gold text-sm font-bold">
                    <Flame size={16} /> {stats.streak}
                </div>
                <span className="text-[10px] text-gray-500 uppercase tracking-wider">Streak</span>
            </div>
            <div className="text-center">
                <div className="flex items-center gap-1 text-vault-success text-sm font-bold">
                    <Zap size={16} /> {stats.tasksCompleted}
                </div>
                <span className="text-[10px] text-gray-500 uppercase tracking-wider">Done</span>
            </div>
        </div>
      </div>

      {/* XP Bar */}
      <div className="w-full bg-vault-900 rounded-full h-2.5 mb-2 overflow-hidden border border-vault-800">
        <div 
            className="bg-gradient-to-r from-vault-accent to-purple-500 h-2.5 rounded-full transition-all duration-500" 
            style={{ width: `${progress}%` }}
        ></div>
      </div>
      <div className="flex justify-between text-xs text-gray-400">
        <span>{stats.xp} XP</span>
        <span>{nextLevelXP} XP</span>
      </div>

      {stats.penalties > 0 && (
          <div className="mt-4 bg-red-900/20 border border-red-900/50 rounded px-3 py-2 flex items-center gap-2 text-xs text-red-400">
              <AlertTriangle size={14} />
              <span>{stats.penalties} Emergency Unlocks used (XP Penalty Applied)</span>
          </div>
      )}
    </div>
  );
};
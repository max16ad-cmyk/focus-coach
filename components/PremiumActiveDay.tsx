import React from 'react';
import { Task } from '../types';
import { PremiumTaskCard } from './PremiumTaskCard';
import { Sparkles, TrendingUp, Plus } from 'lucide-react';
import { buildHeadline, buildBodyText, PREMIUM_LAYOUT, GLASS_EFFECTS } from '../theme-premium';

interface PremiumActiveDayProps {
  currentTask: Task | null;
  allTasks: Task[];
  onUploadProof: (taskId: string) => void;
  onMarkComplete: (taskId: string) => void;
  onAddTask?: () => void;
}

/**
 * Premium Active Day View - Current task + All tasks with glassmorphism
 */
export const PremiumActiveDay: React.FC<PremiumActiveDayProps> = ({
  currentTask,
  allTasks,
  onUploadProof,
  onMarkComplete,
  onAddTask
}) => {
  const now = new Date();
  const timeStr = now.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
  const dateStr = now.toLocaleDateString('de-DE', { weekday: 'long', day: 'numeric', month: 'long' });

  const pendingTasks = allTasks.filter(t => !t.completed).length;
  const completedTasks = allTasks.filter(t => t.completed).length;
  const totalTasks = allTasks.length;
  const progress = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

  return (
    <div className="min-h-screen py-24 px-6 lg:px-12">
      <div className={PREMIUM_LAYOUT.container.full}>
        
        {/* Header with Stats */}
        <div className="mb-16">
          <div className="flex flex-col lg:flex-row items-start lg:items-center justify-between gap-6 mb-8">
            <div>
              <h1 className={buildHeadline('lg', true)}>
                Dein Tag läuft
              </h1>
              <p className={`${buildBodyText('lg')} mt-2`}>
                {dateStr} · {timeStr}
              </p>
            </div>

            {/* Progress Card */}
            <div className={`${GLASS_EFFECTS.card.base} rounded-2xl p-6 min-w-[280px]`}>
              <div className="flex items-center gap-3 mb-3">
                <TrendingUp size={20} className="text-green-400" />
                <span className="text-white/60 text-sm uppercase tracking-wider">Fortschritt</span>
              </div>
              <div className="text-3xl font-light text-white mb-2">
                {completedTasks}/{totalTasks}
              </div>
              <div className="w-full bg-white/[0.1] rounded-full h-2 mb-2">
                <div
                  className="bg-gradient-to-r from-green-400 to-blue-400 h-2 rounded-full transition-all duration-500"
                  style={{ width: `${progress}%` }}
                />
              </div>
              <div className="text-white/40 text-xs">
                {Math.round(progress)}% erledigt
              </div>
            </div>
          </div>
        </div>

        {/* Current Task - Highlighted */}
        {currentTask && !currentTask.completed && (
          <div className="mb-16">
            <div className="inline-flex items-center gap-2 backdrop-blur-md bg-white/[0.05] border border-white/[0.1] rounded-full px-5 py-2 mb-6">
              <Sparkles size={16} className="text-blue-400" />
              <span className="text-sm text-white/70">Aktuell</span>
            </div>
            
            <PremiumTaskCard
              task={currentTask}
              isCurrent={true}
              onMarkComplete={() => onMarkComplete(currentTask.id)}
              onUploadProof={() => onUploadProof(currentTask.id)}
            />
          </div>
        )}

        {/* All Tasks */}
        <div>
          <div className="flex items-center justify-between mb-8">
            <h2 className="text-2xl font-serif italic text-white">
              Tagesübersicht
            </h2>
            
            {onAddTask && (
              <button
                onClick={onAddTask}
                className="backdrop-blur-xl bg-white/[0.08] hover:bg-white/[0.15] border border-white/[0.15] hover:border-blue-400/70 text-white font-medium py-3 px-8 rounded-full transition-all duration-300 flex items-center gap-2 shadow-[0_0_30px_rgba(96,165,250,0.15)] hover:shadow-[0_0_40px_rgba(96,165,250,0.4)] group"
              >
                <Plus size={20} className="group-hover:rotate-90 transition-transform duration-300" />
                <span>Aufgabe hinzufügen</span>
              </button>
            )}
          </div>
          
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {allTasks.map((task) => (
              <PremiumTaskCard
                key={task.id}
                task={task}
                isCurrent={task.id === currentTask?.id}
                onMarkComplete={() => onMarkComplete(task.id)}
                onUploadProof={() => onUploadProof(task.id)}
              />
            ))}
          </div>
        </div>

        {/* Motivational Footer */}
        {pendingTasks > 0 && (
          <div className="mt-16 text-center">
            <p className="text-white/40 text-sm">
              Noch {pendingTasks} {pendingTasks === 1 ? 'Aufgabe' : 'Aufgaben'} bis zur Freiheit 🚀
            </p>
          </div>
        )}
      </div>
    </div>
  );
};


import React from 'react';
import { CoachMessage } from '../coach/CoachMessage';
import { CoachPersonality, AnalyzedTask, TaskCategory } from '../../types';
import { Edit2, Check } from 'lucide-react';

interface PlanReviewProps {
  personality: CoachPersonality;
  tasks: AnalyzedTask[];
  coachMessage: string;
  onTaskEdit?: (taskId: string) => void;
  onConfirm: () => void;
  isLoading?: boolean;
}

const categoryColors: Record<TaskCategory, string> = {
  'Lernen': 'bg-blue-900/50 text-blue-400 border-blue-800',
  'Haushalt': 'bg-green-900/50 text-green-400 border-green-800',
  'Erledigung': 'bg-purple-900/50 text-purple-400 border-purple-800',
  'Arbeit': 'bg-orange-900/50 text-orange-400 border-orange-800',
  'Sport': 'bg-red-900/50 text-red-400 border-red-800',
  'Kreativ': 'bg-pink-900/50 text-pink-400 border-pink-800',
};

const categoryIcons: Record<TaskCategory, string> = {
  'Lernen': '📚',
  'Haushalt': '🏠',
  'Erledigung': '🛒',
  'Arbeit': '💼',
  'Sport': '🏃',
  'Kreativ': '🎨',
};

export const PlanReview: React.FC<PlanReviewProps> = ({
  personality,
  tasks,
  coachMessage,
  onTaskEdit,
  onConfirm,
  isLoading = false,
}) => {
  const today = new Date();
  const dateStr = today.toLocaleDateString('de-DE', { 
    weekday: 'long', 
    day: 'numeric', 
    month: 'long', 
    year: 'numeric' 
  });

  return (
    <div className="w-full">
      <div className="space-y-6">
        {/* Coach Message */}
        <CoachMessage personality={personality} message={coachMessage} />

        {/* Divider */}
        <div className="border-t border-slate-800"></div>

        {/* Header */}
        <div>
          <h2 className="text-2xl font-semibold text-white mb-1">
            DEIN TAGESPLAN FÜR HEUTE
          </h2>
          <p className="text-slate-400 capitalize">{dateStr}</p>
        </div>

        {/* Tasks */}
        <div className="space-y-4 lg:grid lg:grid-cols-2 lg:gap-4 lg:space-y-0">
          {tasks.map((task) => (
            <div
              key={task.id}
              className="bg-slate-900/30 border border-slate-800 rounded-xl p-4"
            >
              {/* Time Block */}
              <div className="text-sm text-slate-500 font-mono mb-3">
                {task.suggestedStartTime} - {task.suggestedEndTime}
              </div>

              {/* Task Card */}
              <div className="bg-slate-800 border border-slate-700 rounded-lg p-4">
                <div className="flex items-start justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <span className="text-xl">{categoryIcons[task.category]}</span>
                    <h3 className="text-lg font-medium text-white">{task.title}</h3>
                  </div>
                  {onTaskEdit && (
                    <button
                      onClick={() => onTaskEdit(task.id)}
                      className="text-slate-400 hover:text-white transition-colors"
                    >
                      <Edit2 size={16} />
                    </button>
                  )}
                </div>

                {/* Category Badge */}
                <div className="mb-3">
                  <span className={`inline-block px-3 py-1 rounded-full text-xs font-medium border ${categoryColors[task.category]}`}>
                    {task.category}
                  </span>
                </div>

                {/* Details */}
                <div className="space-y-2 text-sm">
                  <div className="text-slate-400">
                    Dauer: {Math.floor(task.duration / 60)}h {task.duration % 60}m
                  </div>
                  {task.requiresProof ? (
                    <div className="text-amber-500 flex items-center gap-2">
                      <span>📸</span>
                      <span>{task.proofDescription || 'Nachweis erforderlich'}</span>
                    </div>
                  ) : (
                    <div className="text-slate-500">Nachweis: Kein Nachweis nötig</div>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Add Task Button */}
        <button className="w-full border-2 border-dashed border-slate-700 rounded-xl py-4 text-slate-400 hover:text-white hover:border-slate-600 transition-colors">
          + Aufgabe hinzufügen
        </button>

        {/* Divider */}
        <div className="border-t border-slate-800"></div>

        {/* Confirm Button */}
        <button
          onClick={onConfirm}
          disabled={isLoading}
          className="w-full bg-white text-slate-900 font-semibold py-4 rounded-xl hover:bg-slate-100 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
        >
          {isLoading ? (
            <>
              <div className="w-5 h-5 border-2 border-slate-900 border-t-transparent rounded-full animate-spin" />
              <span>Wird gespeichert...</span>
            </>
          ) : (
            <>
              <Check size={20} />
              <span>Plan bestätigen und Tag starten</span>
            </>
          )}
        </button>
      </div>
    </div>
  );
};


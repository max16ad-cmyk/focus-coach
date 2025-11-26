import React from 'react';
import { Task } from '../types';
import { Calendar, Clock, CheckCircle2 } from 'lucide-react';
import { GLASS_EFFECTS, buildHeadline, buildBodyText } from '../theme-premium';
import { CATEGORY_STYLES } from '../theme';

interface PremiumCalendarProps {
  currentDate: string; // YYYY-MM-DD
  tasks: Task[];
  onAddTask?: () => void;
}

/**
 * Premium Calendar View - Shows current day with all tasks
 */
export const PremiumCalendar: React.FC<PremiumCalendarProps> = ({
  currentDate,
  tasks,
  onAddTask
}) => {
  const now = new Date();
  const dateObj = new Date(currentDate);
  
  const dayName = dateObj.toLocaleDateString('de-DE', { weekday: 'long' });
  const dayNumber = dateObj.getDate();
  const monthName = dateObj.toLocaleDateString('de-DE', { month: 'long' });
  const year = dateObj.getFullYear();
  
  const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
  
  // Group tasks by time
  const sortedTasks = [...tasks].sort((a, b) => {
    if (!a.suggestedStartTime || !b.suggestedStartTime) return 0;
    return a.suggestedStartTime.localeCompare(b.suggestedStartTime);
  });
  
  const completedCount = tasks.filter(t => t.completed).length;
  const totalCount = tasks.length;
  const progress = totalCount > 0 ? (completedCount / totalCount) * 100 : 0;

  return (
    <div className="w-full">
      {/* Calendar Header Card */}
      <div className={`${GLASS_EFFECTS.card.base} rounded-3xl p-8 lg:p-10 mb-8`}>
        <div className="flex flex-col lg:flex-row items-start lg:items-center gap-8">
          
          {/* Left: Big Date Display */}
          <div className="flex-shrink-0">
            <div className="text-center">
              <div className="text-7xl lg:text-8xl font-serif italic text-white mb-2">
                {dayNumber}
              </div>
              <div className="text-xl text-white/60 capitalize">
                {dayName}
              </div>
              <div className="text-sm text-white/40">
                {monthName} {year}
              </div>
            </div>
          </div>

          {/* Divider */}
          <div className="hidden lg:block w-px h-32 bg-white/[0.08]"></div>

          {/* Right: Summary */}
          <div className="flex-1 space-y-6">
            {/* Current Time */}
            <div className="flex items-center gap-3">
              <Clock size={20} className="text-blue-400" />
              <div>
                <div className="text-3xl font-mono text-white">
                  {currentTime}
                </div>
                <div className="text-sm text-white/40">
                  Aktuelle Uhrzeit
                </div>
              </div>
            </div>

            {/* Progress */}
            <div>
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <CheckCircle2 size={18} className="text-green-400" />
                  <span className="text-white/60 text-sm uppercase tracking-wider">
                    Fortschritt
                  </span>
                </div>
                <span className="text-white text-sm font-mono">
                  {completedCount}/{totalCount}
                </span>
              </div>
              <div className="w-full bg-white/[0.1] rounded-full h-2">
                <div
                  className="bg-gradient-to-r from-green-400 to-blue-400 h-2 rounded-full transition-all duration-500"
                  style={{ width: `${progress}%` }}
                />
              </div>
              <div className="text-white/40 text-xs mt-1">
                {Math.round(progress)}% erledigt
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Timeline View */}
      {tasks.length > 0 ? (
        <div className="space-y-4">
          <div className="mb-6">
            <h3 className="text-2xl font-serif italic text-white flex items-center gap-3">
              <Calendar size={24} />
              <span>Tagesplan</span>
            </h3>
          </div>
          
          <div className="space-y-3">
            {sortedTasks.map((task) => {
              const categoryStyle = task.category ? CATEGORY_STYLES[task.category] : null;
              const isCompleted = task.completed;
              const isCurrent = task.suggestedStartTime && task.suggestedEndTime && 
                currentTime >= task.suggestedStartTime && currentTime <= task.suggestedEndTime;
              
              return (
                <div
                  key={task.id}
                  className={`
                    ${GLASS_EFFECTS.card.base}
                    rounded-2xl p-5
                    border-l-4
                    ${isCompleted ? 'border-l-green-400/50 opacity-60' : isCurrent ? 'border-l-blue-400/70 shadow-[0_0_30px_rgba(96,165,250,0.3)]' : 'border-l-slate-400/30'}
                    transition-all duration-300
                    relative overflow-hidden
                    group
                  `}
                >
                  {/* Background gradient */}
                  <div className={`absolute inset-0 bg-gradient-to-r ${isCurrent ? 'from-blue-500/10' : 'from-white/[0.02]'} to-transparent opacity-0 group-hover:opacity-100 transition-opacity`}></div>
                  
                  <div className="relative z-10 flex items-center gap-4">
                    {/* Time */}
                    <div className="flex-shrink-0 text-center min-w-[80px]">
                      {task.suggestedStartTime && task.suggestedEndTime ? (
                        <>
                          <div className="text-white font-mono text-sm">
                            {task.suggestedStartTime}
                          </div>
                          <div className="text-white/40 text-xs">
                            {task.suggestedEndTime}
                          </div>
                        </>
                      ) : (
                        <div className="text-white/40 text-xs">
                          Keine Zeit
                        </div>
                      )}
                    </div>

                    {/* Divider */}
                    <div className="w-px h-12 bg-white/[0.08]"></div>

                    {/* Task Info */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <h4 className={`text-white font-light ${isCompleted ? 'line-through opacity-60' : ''}`}>
                          {task.title}
                        </h4>
                        {isCurrent && !isCompleted && (
                          <span className="relative flex h-2 w-2">
                            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-blue-400 opacity-75"></span>
                            <span className="relative inline-flex rounded-full h-2 w-2 bg-blue-400"></span>
                          </span>
                        )}
                      </div>
                      
                      <div className="flex items-center gap-3 flex-wrap">
                        {categoryStyle && (
                          <div className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs ${categoryStyle.bg} ${categoryStyle.text} border ${categoryStyle.border}`}>
                            <span>{categoryStyle.icon}</span>
                            <span className="uppercase tracking-wide">{task.category}</span>
                          </div>
                        )}
                        
                        {task.duration && (
                          <span className="text-xs text-white/40">
                            {Math.floor(task.duration / 60)}h {task.duration % 60}m
                          </span>
                        )}
                        
                        {task.requiresProof && (
                          <span className="text-xs text-amber-400 flex items-center gap-1">
                            <span>📸</span>
                            <span>Nachweis</span>
                          </span>
                        )}
                      </div>
                    </div>

                    {/* Status Icon */}
                    <div className="flex-shrink-0">
                      {isCompleted ? (
                        <div className="w-8 h-8 rounded-full bg-green-500/20 flex items-center justify-center">
                          <CheckCircle2 size={18} className="text-green-400" />
                        </div>
                      ) : isCurrent ? (
                        <div className="w-8 h-8 rounded-full bg-blue-500/20 flex items-center justify-center">
                          <Clock size={18} className="text-blue-400" />
                        </div>
                      ) : (
                        <div className="w-8 h-8 rounded-full bg-white/[0.05] flex items-center justify-center">
                          <div className="w-2 h-2 rounded-full bg-white/40"></div>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      ) : (
        <div className={`${GLASS_EFFECTS.card.base} rounded-3xl p-12 text-center`}>
          <div className="text-5xl mb-4">📋</div>
          <h3 className="text-xl font-serif italic text-white mb-2">
            Keine Aufgaben für heute
          </h3>
          <p className="text-white/50 text-sm">
            Erstelle einen Tagesplan, um produktiv zu bleiben
          </p>
        </div>
      )}
    </div>
  );
};


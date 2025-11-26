import React from 'react';
import { CoachMessage } from '../coach/CoachMessage';
import { CoachPersonality, Task, TaskStatus } from '../../types';
import { Camera, CheckCircle2, Clock, Lock } from 'lucide-react';

interface ActiveDayProps {
  personality: CoachPersonality;
  currentTask: Task | null;
  allTasks: Task[];
  onUploadProof: (taskId: string) => void;
  onMarkComplete: (taskId: string) => void;
  onEmergencyUnlock: () => void;
  onCreatePlan?: () => void;
}

const statusStyles: Record<TaskStatus, string> = {
  'pending': 'text-slate-400',
  'in_progress': 'text-blue-400',
  'waiting_proof': 'text-amber-400',
  'completed': 'text-green-400',
  'skipped': 'text-red-400',
};

const statusLabels: Record<TaskStatus, string> = {
  'pending': 'Wartet',
  'in_progress': 'In Bearbeitung',
  'waiting_proof': 'Wartet auf Nachweis',
  'completed': 'Erledigt',
  'skipped': 'Übersprungen',
};

export const ActiveDay: React.FC<ActiveDayProps> = ({
  personality,
  currentTask,
  allTasks,
  onUploadProof,
  onMarkComplete,
  onEmergencyUnlock,
  onCreatePlan,
}) => {
  const now = new Date();
  const timeStr = now.toLocaleTimeString('de-DE', { hour: '2-digit', minute: '2-digit' });
  const dateStr = now.toLocaleDateString('de-DE', { weekday: 'short', day: 'numeric' });

  const pendingTasks = allTasks.filter(t => !t.completed).length;
  const isLocked = pendingTasks > 0;
  const hasNoPlan = allTasks.length === 0;

  // Calculate progress for current task
  const getTaskProgress = (task: Task): number => {
    if (!task.suggestedStartTime || !task.suggestedEndTime) return 0;
    
    const [startH, startM] = task.suggestedStartTime.split(':').map(Number);
    const [endH, endM] = task.suggestedEndTime.split(':').map(Number);
    
    const start = new Date();
    start.setHours(startH, startM, 0, 0);
    
    const end = new Date();
    end.setHours(endH, endM, 0, 0);
    
    const total = end.getTime() - start.getTime();
    const elapsed = now.getTime() - start.getTime();
    
    return Math.min(100, Math.max(0, (elapsed / total) * 100));
  };

  const getTaskStatus = (task: Task): TaskStatus => {
    if (task.completed) return 'completed';
    if (task.verified === false && task.requiresProof) return 'waiting_proof';
    if (task === currentTask) return 'in_progress';
    return 'pending';
  };

  const getStatusIcon = (status: TaskStatus) => {
    switch (status) {
      case 'completed':
        return <CheckCircle2 size={16} className="text-green-400" />;
      case 'in_progress':
        return <Clock size={16} className="text-blue-400 animate-pulse" />;
      default:
        return <div className="w-4 h-4 border-2 border-slate-600 rounded-full" />;
    }
  };

  // Show create plan prompt if no plan exists
  if (hasNoPlan && onCreatePlan) {
    return (
      <div className="min-h-screen bg-slate-950 p-4 md:p-8 lg:p-12 flex items-center justify-center">
        <div className="max-w-2xl md:max-w-3xl lg:max-w-4xl w-full space-y-6 text-center">
          <div className="text-6xl md:text-7xl lg:text-8xl mb-4">📋</div>
          <h2 className="text-2xl md:text-3xl lg:text-4xl font-semibold text-white mb-2">
            Noch kein Tagesplan erstellt
          </h2>
          <p className="text-slate-400 mb-6 text-lg md:text-xl">
            Erstelle einen Plan, um produktiv zu bleiben.
          </p>
          <button
            onClick={onCreatePlan}
            className="bg-gradient-to-r from-blue-600 to-blue-500 text-white font-semibold py-4 md:py-5 px-8 md:px-12 rounded-xl hover:from-blue-500 hover:to-blue-400 transition-all shadow-lg shadow-blue-500/30 text-lg md:text-xl"
          >
            ✨ Plan erstellen
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="w-full">
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <CoachMessage
              personality={personality}
              message={
                currentTask
                  ? `Du solltest jetzt ${currentTask.title}. Noch ${Math.floor((currentTask.duration || 60) * (1 - getTaskProgress(currentTask) / 100))} Minuten in diesem Block.`
                  : 'Keine aktuelle Aufgabe.'
              }
            />
          </div>
          <div className="text-right ml-4">
            <div className="text-3xl font-mono text-white">{timeStr}</div>
            <div className="text-sm text-slate-500">{dateStr}</div>
          </div>
        </div>

        {/* Divider */}
        <div className="border-t border-slate-800"></div>

        {/* Current Block */}
        {currentTask && (
          <div className="bg-slate-800 border-2 border-blue-500/50 rounded-2xl p-6">
            <div className="mb-4">
              <div className="text-sm text-slate-500 font-mono mb-2">
                AKTUELLER BLOCK: {currentTask.suggestedStartTime} - {currentTask.suggestedEndTime}
              </div>
              <h2 className="text-2xl font-semibold text-white mb-4">
                {currentTask.title}
              </h2>
            </div>

            {/* Progress Bar */}
            <div className="mb-4">
              <div className="flex justify-between text-sm text-slate-400 mb-2">
                <span>{Math.round(getTaskProgress(currentTask))}% der Zeit</span>
              </div>
              <div className="h-2 rounded-full bg-slate-700 overflow-hidden">
                <div
                  className="h-full bg-blue-500 transition-all duration-300"
                  style={{ width: `${getTaskProgress(currentTask)}%` }}
                />
              </div>
            </div>

            {/* Status */}
            <div className="mb-4">
              <div className={`inline-flex items-center gap-2 ${statusStyles[getTaskStatus(currentTask)]}`}>
                <Clock size={16} />
                <span>Status: {statusLabels[getTaskStatus(currentTask)]}</span>
              </div>
            </div>

            {/* Divider */}
            <div className="border-t border-slate-700 my-4"></div>

            {/* Proof Requirement */}
            {currentTask.requiresProof && (
              <div className="mb-4">
                <div className="text-slate-400 mb-2">Nachweis erforderlich:</div>
                <div className="text-amber-500 flex items-center gap-2 mb-4">
                  <Camera size={16} />
                  <span>{currentTask.proofDescription || 'Foto erforderlich'}</span>
                </div>
                <button
                  onClick={() => onUploadProof(currentTask.id)}
                  className="w-full bg-amber-600 hover:bg-amber-500 text-white font-medium py-3 px-6 rounded-xl flex items-center justify-center gap-2 transition-colors"
                >
                  <Camera size={20} />
                  Nachweis hochladen
                </button>
              </div>
            )}

            {/* Mark Complete Button */}
            <button
              onClick={() => onMarkComplete(currentTask.id)}
              className="w-full bg-green-600 hover:bg-green-500 text-white font-medium py-3 px-6 rounded-xl flex items-center justify-center gap-2 transition-colors"
            >
              <CheckCircle2 size={20} />
              Als erledigt markieren
            </button>
          </div>
        )}

        {/* Divider */}
        <div className="border-t border-slate-800"></div>

        {/* Day Overview */}
        <div>
          <h3 className="text-lg font-semibold text-white mb-4">TAGESÜBERSICHT</h3>
          <div className="space-y-2 lg:grid lg:grid-cols-2 lg:gap-3 lg:space-y-0">
            {allTasks.map((task) => {
              const status = getTaskStatus(task);
              const isCurrent = task === currentTask;
              return (
                <div
                  key={task.id}
                  className={`flex items-center gap-3 p-3 rounded-lg ${
                    isCurrent ? 'bg-slate-800' : 'bg-slate-900/50'
                  }`}
                >
                  {getStatusIcon(status)}
                  <span className="text-sm font-mono text-slate-500 w-20">
                    {task.suggestedStartTime}
                  </span>
                  <span
                    className={`flex-1 ${
                      status === 'completed'
                        ? 'text-slate-500 line-through'
                        : isCurrent
                        ? 'text-blue-400 font-medium'
                        : 'text-slate-400'
                    }`}
                  >
                    {task.title}
                    {isCurrent && ' ← JETZT'}
                  </span>
                </div>
              );
            })}
          </div>
        </div>

        {/* Divider */}
        <div className="border-t border-slate-800"></div>

        {/* Lock Status */}
        <div className="bg-slate-900/50 border border-slate-800 rounded-xl p-4">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <Lock size={20} className={isLocked ? 'text-red-500' : 'text-green-500'} />
              <span className="text-white font-medium">
                Ablenkungen: {isLocked ? '🔒 Blockiert' : '🔓 Freigegeben'}
              </span>
            </div>
            {isLocked && (
              <span className="text-sm text-slate-400">
                ({pendingTasks} {pendingTasks === 1 ? 'Aufgabe' : 'Aufgaben'} offen)
              </span>
            )}
          </div>
          {isLocked && (
            <button
              onClick={onEmergencyUnlock}
              className="text-sm text-slate-600 hover:text-slate-400 transition-colors"
            >
              🚨 Notfall-Zugriff
            </button>
          )}
        </div>
      </div>
    </div>
  );
};


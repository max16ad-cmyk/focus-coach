import React from 'react';
import { Task, TaskStatus } from '../types';
import { Clock, CheckCircle2, Camera, AlertCircle } from 'lucide-react';
import { GLASS_EFFECTS, PREMIUM_TYPOGRAPHY, buildBodyText } from '../theme-premium';
import { CATEGORY_STYLES } from '../theme';

interface PremiumTaskCardProps {
  task: Task;
  isCurrent?: boolean;
  onMarkComplete?: () => void;
  onUploadProof?: () => void;
}

/**
 * Premium Task Card with Glassmorphism
 * Inspired by the 3-card feature layout from screenshot
 */
export const PremiumTaskCard: React.FC<PremiumTaskCardProps> = ({
  task,
  isCurrent = false,
  onMarkComplete,
  onUploadProof
}) => {
  // Status-based border colors
  const borderColor = {
    pending: 'border-l-slate-400/50',
    in_progress: 'border-l-blue-400/50',
    waiting_proof: 'border-l-amber-400/50',
    completed: 'border-l-green-400/50',
    skipped: 'border-l-red-400/50',
  }[task.status || 'pending'];

  // Accent glow for current task
  const glowEffect = isCurrent
    ? 'shadow-[0_0_40px_rgba(96,165,250,0.3)] border-blue-400/70'
    : '';

  // Category color
  const categoryStyle = task.category ? CATEGORY_STYLES[task.category] : null;

  return (
    <div
      className={`
        ${GLASS_EFFECTS.card.base} 
        ${GLASS_EFFECTS.card.hover}
        rounded-2xl p-6
        border-l-4 ${borderColor}
        ${glowEffect}
        relative overflow-hidden
        group
        transition-all duration-300
      `}
    >
      {/* Background gradient on hover */}
      <div className="absolute inset-0 bg-gradient-to-br from-white/[0.02] to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
      
      <div className="relative z-10 space-y-4">
        
        {/* Header: Time + Category */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            {task.suggestedStartTime && task.suggestedEndTime && (
              <div className="flex items-center gap-1 text-white/60 text-sm font-mono">
                <Clock size={14} />
                <span>{task.suggestedStartTime} - {task.suggestedEndTime}</span>
              </div>
            )}
          </div>
          
          {categoryStyle && (
            <div className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs ${categoryStyle.bg} ${categoryStyle.text} border ${categoryStyle.border}`}>
              <span>{categoryStyle.icon}</span>
              <span className="uppercase tracking-wide">{task.category}</span>
            </div>
          )}
        </div>

        {/* Title */}
        <div>
          <h3 className="text-white text-lg font-medium leading-snug">
            {task.title}
          </h3>
          {isCurrent && (
            <p className="text-blue-400 text-sm mt-2 flex items-center gap-2">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-blue-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-blue-400"></span>
              </span>
              Aktuell aktiv
            </p>
          )}
        </div>

        {/* Duration */}
        {task.duration && (
          <div className="text-white/50 text-sm">
            Dauer: {Math.floor(task.duration / 60)}h {task.duration % 60}m
          </div>
        )}

        {/* Proof Requirements */}
        {task.requiresProof && (
          <div className="flex items-center gap-2 text-amber-400 text-sm bg-amber-500/10 rounded-lg px-3 py-2">
            <Camera size={16} />
            <span>{task.proofDescription || 'Foto-Nachweis erforderlich'}</span>
          </div>
        )}

        {/* Actions */}
        {!task.completed && (
          <div className="flex items-center gap-3 pt-2">
            {task.requiresProof && !task.verified && onUploadProof && (
              <button
                onClick={onUploadProof}
                className={`
                  flex-1 backdrop-blur-md bg-white/[0.05] hover:bg-white/[0.1]
                  border border-white/[0.1] hover:border-white/[0.2]
                  text-white text-sm font-medium
                  py-2.5 px-4 rounded-lg
                  transition-all duration-200
                  flex items-center justify-center gap-2
                `}
              >
                <Camera size={16} />
                <span>Nachweis hochladen</span>
              </button>
            )}
            
            {onMarkComplete && (!task.requiresProof || task.verified) && (
              <button
                onClick={onMarkComplete}
                className={`
                  flex-1 backdrop-blur-md bg-green-500/20 hover:bg-green-500/30
                  border border-green-500/30 hover:border-green-500/50
                  text-green-400 text-sm font-medium
                  py-2.5 px-4 rounded-lg
                  transition-all duration-200
                  flex items-center justify-center gap-2
                `}
              >
                <CheckCircle2 size={16} />
                <span>Als erledigt markieren</span>
              </button>
            )}
          </div>
        )}

        {/* Completed Badge */}
        {task.completed && (
          <div className="flex items-center gap-2 text-green-400 text-sm">
            <CheckCircle2 size={18} />
            <span className="font-medium">Erledigt</span>
            {task.verified && (
              <span className="ml-auto text-xs bg-green-500/20 border border-green-500/30 rounded-full px-2 py-1">
                Verifiziert
              </span>
            )}
          </div>
        )}
      </div>
    </div>
  );
};


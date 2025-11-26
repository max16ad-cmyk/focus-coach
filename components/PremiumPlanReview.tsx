import React from 'react';
import { AnalyzedTask } from '../types';
import { Check, Edit2, Sparkles } from 'lucide-react';
import { buildHeadline, buildBodyText, GLASS_EFFECTS, PREMIUM_LAYOUT, PREMIUM_COMPONENTS } from '../theme-premium';
import { CATEGORY_STYLES } from '../theme';

interface PremiumPlanReviewProps {
  tasks: AnalyzedTask[];
  onConfirm: () => void;
  isLoading?: boolean;
}

/**
 * Premium Plan Review - Glassmorphism Task Cards
 */
export const PremiumPlanReview: React.FC<PremiumPlanReviewProps> = ({
  tasks,
  onConfirm,
  isLoading = false
}) => {
  const today = new Date();
  const dateStr = today.toLocaleDateString('de-DE', { 
    weekday: 'long', 
    day: 'numeric', 
    month: 'long' 
  });

  return (
    <div className="min-h-screen py-24 px-6 lg:px-12">
      <div className={PREMIUM_LAYOUT.container.full}>
        
        {/* Header */}
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 backdrop-blur-md bg-white/[0.05] border border-white/[0.1] rounded-full px-5 py-2 mb-6">
            <Sparkles size={16} className="text-blue-400" />
            <span className="text-sm text-white/70">KI-Analyse abgeschlossen</span>
          </div>
          
          <h1 className={buildHeadline('lg', true)}>
            Dein Tagesplan
          </h1>
          <p className={`${buildBodyText('lg')} mt-4`}>
            {dateStr}
          </p>
        </div>

        {/* Tasks Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-12">
          {tasks.map((task) => {
            const categoryStyle = CATEGORY_STYLES[task.category];
            
            return (
              <div
                key={task.id}
                className={`${GLASS_EFFECTS.card.base} ${GLASS_EFFECTS.card.hover} rounded-2xl p-6 border-l-4 border-l-blue-400/50 relative overflow-hidden group`}
              >
                <div className="absolute inset-0 bg-gradient-to-br from-blue-500/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
                
                <div className="relative z-10 space-y-4">
                  {/* Time Badge */}
                  <div className="flex items-center justify-between">
                    <div className="text-white/60 text-sm font-mono">
                      {task.suggestedStartTime} - {task.suggestedEndTime}
                    </div>
                    {categoryStyle && (
                      <div className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs ${categoryStyle.bg} ${categoryStyle.text} border ${categoryStyle.border}`}>
                        <span>{categoryStyle.icon}</span>
                        <span className="uppercase tracking-wide">{task.category}</span>
                      </div>
                    )}
                  </div>

                  {/* Title */}
                  <h3 className="text-white text-xl font-light">
                    {task.title}
                  </h3>

                  {/* Duration */}
                  <div className="text-white/50 text-sm">
                    Dauer: {Math.floor(task.duration / 60)}h {task.duration % 60}m
                  </div>

                  {/* Proof */}
                  {task.requiresProof && (
                    <div className="flex items-center gap-2 text-amber-400 text-sm bg-amber-500/10 rounded-lg px-3 py-2">
                      <span>📸</span>
                      <span>{task.proofDescription || 'Nachweis erforderlich'}</span>
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>

        {/* CTA */}
        <div className="text-center">
          <button
            onClick={onConfirm}
            disabled={isLoading}
            className={`${PREMIUM_COMPONENTS.button.primary} group inline-flex items-center gap-2 min-w-[280px]`}
          >
            {isLoading ? (
              <>
                <div className="w-5 h-5 border-2 border-black border-t-transparent rounded-full animate-spin" />
                <span>Wird gespeichert...</span>
              </>
            ) : (
              <>
                <Check size={20} />
                <span>Plan bestätigen und starten</span>
              </>
            )}
          </button>
          <p className="text-white/40 text-sm mt-4">
            Du kannst deinen Plan später jederzeit anpassen
          </p>
        </div>
      </div>
    </div>
  );
};


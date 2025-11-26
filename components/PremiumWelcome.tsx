import React, { useState } from 'react';
import { Sparkles, ArrowRight, TrendingUp, Calendar, Target } from 'lucide-react';
import { PREMIUM_COLORS, PREMIUM_TYPOGRAPHY, GLASS_EFFECTS, PREMIUM_COMPONENTS, PREMIUM_LAYOUT, buildHeadline, buildBodyText } from '../theme-premium';
import { PremiumCalendar } from './PremiumCalendar';
import { Task } from '../types';

interface PremiumWelcomeProps {
  userName: string;
  currentDate: string;
  tasks?: Task[];
  onCreatePlan: () => void;
  onAddTask?: () => void;
}

/**
 * Premium Welcome Screen - Inspired by "Own your wealth" hero section
 * Features: Large serif headline, glassmorphism, hero background, elegant spacing
 */
export const PremiumWelcome: React.FC<PremiumWelcomeProps> = ({
  userName,
  currentDate,
  tasks = [],
  onCreatePlan,
  onAddTask
}) => {
  const [planInput, setPlanInput] = useState('');
  const hasTasks = tasks.length > 0;

  return (
    <div className="min-h-screen relative overflow-hidden">
      {/* Background - Dark gradient (similar to hero image) */}
      <div className="absolute inset-0 bg-gradient-to-br from-slate-900 via-[#0a0a0a] to-blue-950/20"></div>
      
      {/* Ambient glow effects */}
      <div className="absolute top-0 right-0 w-[800px] h-[800px] bg-blue-500/10 rounded-full blur-3xl"></div>
      <div className="absolute bottom-0 left-0 w-[600px] h-[600px] bg-purple-500/10 rounded-full blur-3xl"></div>
      
      {/* Content */}
      <div className={`relative z-10 ${PREMIUM_LAYOUT.container.wide} ${PREMIUM_LAYOUT.spacing.section}`}>
        
        {/* Header */}
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 backdrop-blur-md bg-white/[0.05] border border-white/[0.1] rounded-full px-5 py-2 mb-6">
            <Sparkles size={16} className="text-blue-400" />
            <span className="text-sm text-white/70">Willkommen zurück, {userName}</span>
          </div>

          <h1 className={buildHeadline('xl', true)}>
            Own your{' '}
            <span className="bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
              productivity
            </span>
          </h1>
          
          <p className={`${buildBodyText('lg', 'normal')} max-w-2xl mx-auto mt-6`}>
            Dein persönlicher AI Productivity Coach.
            <br />
            Strukturiere deinen Tag, erreiche deine Ziele und übernimm die Kontrolle.
          </p>
        </div>

        {/* Calendar Section - Shows if tasks exist */}
        {hasTasks ? (
          <div className="mb-16">
            <PremiumCalendar
              currentDate={currentDate}
              tasks={tasks}
              onAddTask={onAddTask}
            />
          </div>
        ) : (
          <div className="text-center mb-16">
            <button
              onClick={onCreatePlan}
              className={`${PREMIUM_COMPONENTS.button.primary} group inline-flex items-center gap-2`}
            >
              <span>Tagesplan erstellen</span>
              <ArrowRight size={20} className="group-hover:translate-x-1 transition-transform" />
            </button>
          </div>
        )}

          {/* Feature Highlights - 3 Cards like in screenshot */}
          <div className={`${PREMIUM_LAYOUT.grid.features} mt-24`}>
            {/* Card 1 - Blue (like "SPEND THIS MONTH") */}
            <div className={`${GLASS_EFFECTS.card.base} ${GLASS_EFFECTS.card.hover} rounded-3xl p-8 border-l-4 border-l-blue-400/50 relative overflow-hidden group`}>
              <div className="absolute inset-0 bg-gradient-to-br from-blue-500/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
              <div className="relative z-10">
                <div className="text-3xl mb-4">
                  <TrendingUp size={32} className="text-blue-400" />
                </div>
                <h3 className={`${PREMIUM_TYPOGRAPHY.label.base} ${PREMIUM_TYPOGRAPHY.label.color} mb-3`}>
                  KI-ANALYSE
                </h3>
                <p className="text-white text-lg font-light mb-2">
                  Automatische Strukturierung
                </p>
                <p className="text-white/50 text-sm">
                  Unsere KI analysiert deine Aufgaben und erstellt den optimalen Tagesplan
                </p>
              </div>
            </div>

            {/* Card 2 - Orange (like "BUDGET") */}
            <div className={`${GLASS_EFFECTS.card.base} ${GLASS_EFFECTS.card.hover} rounded-3xl p-8 border-l-4 border-l-orange-400/50 relative overflow-hidden group`}>
              <div className="absolute inset-0 bg-gradient-to-br from-orange-500/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
              <div className="relative z-10">
                <div className="text-3xl mb-4">
                  <Calendar size={32} className="text-orange-400" />
                </div>
                <h3 className={`${PREMIUM_TYPOGRAPHY.label.base} ${PREMIUM_TYPOGRAPHY.label.color} mb-3`}>
                  FOTO-NACHWEIS
                </h3>
                <p className="text-white text-lg font-light mb-2">
                  KI-Verifikation
                </p>
                <p className="text-white/50 text-sm">
                  Lade Beweise hoch - unsere KI prüft automatisch, ob Tasks erledigt wurden
                </p>
              </div>
            </div>

            {/* Card 3 - Teal (like "UPCOMING TRANSACTIONS") */}
            <div className={`${GLASS_EFFECTS.card.base} ${GLASS_EFFECTS.card.hover} rounded-3xl p-8 border-l-4 border-l-teal-400/50 relative overflow-hidden group`}>
              <div className="absolute inset-0 bg-gradient-to-br from-teal-500/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
              <div className="relative z-10">
                <div className="text-3xl mb-4">
                  <Target size={32} className="text-teal-400" />
                </div>
                <h3 className={`${PREMIUM_TYPOGRAPHY.label.base} ${PREMIUM_TYPOGRAPHY.label.color} mb-3`}>
                  MULTI-DEVICE SYNC
                </h3>
                <p className="text-white text-lg font-light mb-2">
                  Überall synchron
                </p>
                <p className="text-white/50 text-sm">
                  Dein Plan, deine Fortschritte - synchronisiert auf allen deinen Geräten
                </p>
              </div>
            </div>
          </div>

        {/* Footer note */}
        <div className="mt-16 pt-8 border-t border-white/[0.05]">
          <p className="text-white/40 text-sm">
            Erstelle deinen ersten Plan in unter 2 Minuten
          </p>
        </div>
      </div>
    </div>
  );
};


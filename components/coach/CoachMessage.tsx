import React from 'react';
import { CoachPersonality } from '../../types';
import { CoachAvatar } from './CoachAvatar';
import { COACH_STYLES } from '../../theme';
import { buildClassName } from '../../theme';

interface CoachMessageProps {
  personality: CoachPersonality;
  message: string;
  className?: string;
}

export const CoachMessage: React.FC<CoachMessageProps> = ({ 
  personality, 
  message, 
  className = '' 
}) => {
  const coachStyle = COACH_STYLES[personality];
  
  const boxClasses = buildClassName(
    'bg-slate-900/50 border border-slate-800 rounded-2xl p-6',
    coachStyle.border,
    coachStyle.bg,
    className
  );
  
  return (
    <div className={boxClasses}>
      <div className="flex items-start gap-4">
        <CoachAvatar personality={personality} size="md" />
        <div className="flex-1">
          <p className="text-base text-slate-300 leading-relaxed">
            {message}
          </p>
        </div>
      </div>
    </div>
  );
};


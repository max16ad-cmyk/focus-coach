import React from 'react';
import { CoachPersonality } from '../../types';
import { CoachAvatar } from './CoachAvatar';
import { GLASS_EFFECTS, buildBodyText } from '../../theme-premium';
import { COACH_STYLES } from '../../theme';

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
  
  return (
    <div className={`${GLASS_EFFECTS.card.base} rounded-2xl p-6 border-l-4 ${coachStyle.border} ${className}`}>
      <div className="flex items-start gap-4">
        <CoachAvatar personality={personality} size="md" />
        <div className="flex-1">
          <p className={`${buildBodyText('md')} leading-relaxed`}>
            {message}
          </p>
        </div>
      </div>
    </div>
  );
};

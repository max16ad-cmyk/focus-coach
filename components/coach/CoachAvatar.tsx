import React from 'react';
import { CoachPersonality } from '../../types';

interface CoachAvatarProps {
  personality: CoachPersonality;
  size?: 'sm' | 'md' | 'lg';
}

const avatarStyles = {
  sergeant: 'text-red-500',
  professor: 'text-blue-500',
  mentor: 'text-green-500',
  minimalist: 'text-slate-400',
};

export const CoachAvatar: React.FC<CoachAvatarProps> = ({ personality, size = 'md' }) => {
  const sizeClasses = {
    sm: 'text-2xl',
    md: 'text-4xl',
    lg: 'text-6xl',
  };

  return (
    <div className={`${sizeClasses[size]} ${avatarStyles[personality]} select-none`}>
      (○_○)
    </div>
  );
};


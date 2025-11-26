import React from 'react';
import { Distraction } from '../types';
import { Lock, ExternalLink } from 'lucide-react';

interface DistractionVaultProps {
  distractions: Distraction[];
  isLocked: boolean;
}

export const DistractionVault: React.FC<DistractionVaultProps> = ({ distractions, isLocked }) => {
  return (
    <div className="grid grid-cols-2 gap-4">
      {distractions.map((item) => (
        <div 
          key={item.id}
          className={`relative p-6 rounded-xl border flex flex-col items-center justify-center text-center h-32 transition-all duration-500 ${
            isLocked 
              ? 'bg-vault-900 border-vault-800 cursor-not-allowed' 
              : 'bg-vault-800 border-vault-700 hover:border-vault-success cursor-pointer hover:bg-vault-700'
          }`}
          onClick={() => {
            if (!isLocked) window.open(item.url, '_blank');
          }}
        >
          {isLocked ? (
            <div className="absolute inset-0 bg-vault-900/80 backdrop-blur-sm z-10 flex flex-col items-center justify-center rounded-xl">
               <Lock className="text-vault-danger mb-2 animate-bounce" size={24} />
               <span className="text-xs font-bold text-vault-danger tracking-widest uppercase">Locked</span>
            </div>
          ) : (
            <div className="absolute top-2 right-2">
              <ExternalLink size={14} className="text-vault-success opacity-50" />
            </div>
          )}
          
          <div className={`text-4xl mb-2 ${isLocked ? 'blur-sm opacity-30' : ''}`}>{item.icon}</div>
          <h3 className={`font-semibold text-sm ${isLocked ? 'blur-sm opacity-30' : 'text-white'}`}>
            {item.name}
          </h3>
        </div>
      ))}
    </div>
  );
};
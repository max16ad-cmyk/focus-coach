import React, { useState } from 'react';
import { CoachPersonality } from '../../types';
import { Mic, X, AlertCircle, Sparkles } from 'lucide-react';
import { buildHeadline, buildBodyText, GLASS_EFFECTS, PREMIUM_LAYOUT, PREMIUM_COMPONENTS } from '../../theme-premium';
import { useSpeechRecognition } from '../../hooks/useSpeechRecognition';

interface MorningLockProps {
  personality: CoachPersonality;
  onPlanSubmit: (input: string) => void;
  isLoading?: boolean;
}

export const MorningLock: React.FC<MorningLockProps> = ({ 
  personality, 
  onPlanSubmit,
  isLoading = false 
}) => {
  const [inputText, setInputText] = useState('');
  const { transcript, isListening, startListening, stopListening, error, isSupported } = useSpeechRecognition();

  // Update input when transcript changes
  React.useEffect(() => {
    if (transcript) {
      setInputText(transcript);
    }
  }, [transcript]);

  const handleSubmit = () => {
    if (inputText.trim()) {
      onPlanSubmit(inputText.trim());
    }
  };

  const handleMicClick = () => {
    if (isListening) {
      stopListening();
    } else {
      startListening();
    }
  };

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Guten Morgen';
    if (hour < 18) return 'Guten Tag';
    return 'Guten Abend';
  };

  return (
    <div className="min-h-screen bg-[#0a0a0a] flex items-center justify-center px-6 lg:px-12 py-24">
      <div className={`${PREMIUM_LAYOUT.container.medium} w-full space-y-8`}>
        
        {/* Welcome Header */}
        <div className="text-center space-y-6">
          <div className="inline-flex items-center gap-2 backdrop-blur-md bg-white/[0.05] border border-white/[0.1] rounded-full px-5 py-2">
            <span className="text-2xl">🌅</span>
            <span className="text-sm text-white/70">Morgen-Planung</span>
          </div>
          
          <h1 className={buildHeadline('xl', true)}>
            {getGreeting()}!
          </h1>
          <p className={buildBodyText('lg')}>
            Lass uns deinen Tag strukturieren
          </p>
        </div>

        {/* Coach Message - Premium Style */}
        <div className={`${GLASS_EFFECTS.card.base} rounded-3xl p-8 border-l-4 border-l-blue-400/50`}>
          <div className="flex items-start gap-4">
            <div className="text-4xl">👋</div>
            <div className="flex-1">
              <p className={`${buildBodyText('md')} leading-relaxed`}>
                Bevor wir starten, erstelle bitte deinen Tagesplan. Das hilft dir, fokussiert zu bleiben.
              </p>
            </div>
          </div>
        </div>

        {/* Title */}
        <div className="text-center">
          <h2 className={`${buildBodyText('lg', 'semibold')} mb-2`}>
            Was steht heute an?
          </h2>
          <p className="text-white/50 text-sm">
            Tippe oder diktiere deine Aufgaben
          </p>
        </div>

        {/* Input Area */}
        <div className={`${GLASS_EFFECTS.input.base} rounded-2xl p-6 focus-within:border-white/[0.2] focus-within:bg-white/[0.08] transition-all relative`}>
          <textarea
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            placeholder="Zum Beispiel:&#10;Mathe lernen, Zimmer aufräumen, einkaufen gehen..."
            className="w-full bg-transparent border-none outline-none text-white placeholder-white/40 min-h-[180px] resize-none text-base leading-relaxed"
            disabled={isLoading}
          />
          
          {/* Voice Input Button */}
          {isSupported && (
            <button
              onClick={handleMicClick}
              disabled={isLoading}
              className={`
                absolute bottom-4 right-4
                w-12 h-12 rounded-full
                flex items-center justify-center
                transition-all duration-200
                ${isListening 
                  ? 'bg-red-500 hover:bg-red-600 animate-pulse shadow-lg shadow-red-500/30' 
                  : 'bg-blue-600 hover:bg-blue-500 shadow-lg shadow-blue-500/20'
                }
                disabled:opacity-50 disabled:cursor-not-allowed
              `}
              title={isListening ? 'Aufnahme stoppen' : 'Spracheingabe starten'}
            >
              <Mic size={20} className="text-white" />
            </button>
          )}
        </div>

        {/* Error Message */}
        {error && (
          <div className={`${GLASS_EFFECTS.card.base} rounded-xl p-4 border-l-4 border-l-red-400/50`}>
            <div className="flex items-center gap-2 text-red-400">
              <AlertCircle size={18} />
              <span className="text-sm">{error}</span>
            </div>
          </div>
        )}

        {/* Voice Status */}
        {isListening && (
          <div className="flex items-center gap-2 text-red-400 text-sm">
            <div className="relative flex h-3 w-3">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-3 w-3 bg-red-400"></span>
            </div>
            <span>Höre zu...</span>
          </div>
        )}

        {/* Action Buttons */}
        <div className="flex gap-4">
          {inputText && (
            <button
              onClick={() => setInputText('')}
              disabled={isLoading}
              className={`${PREMIUM_COMPONENTS.button.secondary} px-6`}
            >
              <X size={20} />
            </button>
          )}
        </div>

        {/* Submit Button */}
        <button
          onClick={handleSubmit}
          disabled={!inputText.trim() || isLoading}
          className={`${PREMIUM_COMPONENTS.button.primary} w-full flex items-center justify-center gap-2`}
        >
          {isLoading ? (
            <>
              <div className="w-5 h-5 border-2 border-black border-t-transparent rounded-full animate-spin" />
              <span>Plan wird erstellt...</span>
            </>
          ) : (
            <>
              <Sparkles size={20} />
              <span>Plan erstellen</span>
            </>
          )}
        </button>

        {/* Friendly Notice */}
        <div className="text-center">
          <div className={`inline-flex items-center gap-2 text-white/50 text-xs ${GLASS_EFFECTS.card.base} px-4 py-2 rounded-full`}>
            <span>🔒</span>
            <span>Ablenkungen sind gesperrt, bis dein Plan erstellt ist</span>
          </div>
        </div>
      </div>
    </div>
  );
};

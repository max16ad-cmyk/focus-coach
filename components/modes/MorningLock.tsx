import React, { useState } from 'react';
import { CoachMessage } from '../coach/CoachMessage';
import { CoachPersonality } from '../../types';
import { useSpeechRecognition } from '../../hooks/useSpeechRecognition';
import { Mic, X, AlertCircle } from 'lucide-react';

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
  const { transcript, isListening, startListening, stopListening, error } = useSpeechRecognition();

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
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-950 to-slate-900 flex items-center justify-center p-4 md:p-8">
      <div className="max-w-2xl md:max-w-3xl lg:max-w-4xl w-full space-y-6">
        {/* Welcome Header */}
        <div className="text-center space-y-2 mb-6">
          <div className="text-5xl md:text-6xl mb-2">🌅</div>
          <h1 className="text-3xl md:text-4xl lg:text-5xl font-bold text-white">
            {getGreeting()}!
          </h1>
          <p className="text-slate-400 text-lg md:text-xl">
            Lass uns deinen Tag strukturieren
          </p>
        </div>

        {/* Coach Message - freundlicher */}
        <div className="bg-slate-800/50 border border-slate-700/50 rounded-2xl p-6 backdrop-blur-sm">
          <div className="flex items-start gap-4">
            <div className="text-3xl">👋</div>
            <div className="flex-1">
              <p className="text-slate-200 leading-relaxed">
                Bevor wir starten, erstelle bitte deinen Tagesplan. Das hilft dir, fokussiert zu bleiben.
              </p>
            </div>
          </div>
        </div>

        {/* Title */}
        <div className="text-center">
          <h2 className="text-xl font-semibold text-slate-300 mb-1">
            Was steht heute an?
          </h2>
          <p className="text-sm text-slate-500">
            Tippe oder diktiere deine Aufgaben
          </p>
        </div>

        {/* Input Area */}
        <div className="bg-slate-800/30 border border-slate-700/50 rounded-xl p-5 md:p-6 focus-within:border-blue-500/50 focus-within:bg-slate-800/50 transition-all">
          <textarea
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            placeholder="Zum Beispiel:&#10;Mathe lernen, Zimmer aufräumen, einkaufen gehen..."
            className="w-full bg-transparent border-none outline-none text-white placeholder-slate-500 min-h-[140px] md:min-h-[180px] resize-none text-base md:text-lg leading-relaxed"
            disabled={isLoading}
          />
        </div>

        {/* Error Message */}
        {error && (
          <div className="flex items-center gap-2 text-red-500 text-sm bg-red-950/20 border border-red-800/50 rounded-lg p-3">
            <AlertCircle size={16} />
            <span>{error}</span>
          </div>
        )}

        {/* Action Buttons */}
        <div className="flex gap-3">
          <button
            onClick={handleMicClick}
            disabled={isLoading}
            className={`flex-1 flex items-center justify-center gap-2 px-6 py-3 rounded-xl font-medium transition-all ${
              isListening
                ? 'bg-blue-600 hover:bg-blue-500 text-white animate-pulse shadow-lg shadow-blue-500/30'
                : 'bg-blue-600 hover:bg-blue-500 text-white shadow-lg shadow-blue-500/20'
            } disabled:opacity-50 disabled:cursor-not-allowed`}
          >
            <Mic size={20} />
            {isListening ? 'Aufnahme läuft...' : 'Spracheingabe'}
          </button>
          {inputText && (
            <button
              onClick={() => setInputText('')}
              disabled={isLoading}
              className="px-4 py-3 rounded-xl font-medium bg-slate-700/50 hover:bg-slate-700 text-slate-300 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
              title="Löschen"
            >
              <X size={20} />
            </button>
          )}
        </div>

        {/* Submit Button */}
        <button
          onClick={handleSubmit}
          disabled={!inputText.trim() || isLoading}
          className="w-full bg-gradient-to-r from-blue-600 to-blue-500 text-white font-semibold py-4 rounded-xl hover:from-blue-500 hover:to-blue-400 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 shadow-lg shadow-blue-500/30"
        >
          {isLoading ? (
            <>
              <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
              <span>Plan wird erstellt...</span>
            </>
          ) : (
            <>
              <span>✨</span>
              <span>Plan erstellen</span>
            </>
          )}
        </button>

        {/* Friendly Notice */}
        <div className="text-center">
          <div className="inline-flex items-center gap-2 text-slate-500 text-xs bg-slate-800/30 px-4 py-2 rounded-full">
            <span>🔒</span>
            <span>Ablenkungen sind gesperrt, bis dein Plan erstellt ist</span>
          </div>
        </div>
      </div>
    </div>
  );
};


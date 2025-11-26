import React, { useState } from 'react';
import { X, Plus, Mic, MicOff, Sparkles } from 'lucide-react';
import { GLASS_EFFECTS, PREMIUM_COMPONENTS, buildHeadline, buildBodyText } from '../theme-premium';
import { useSpeechRecognition } from '../hooks/useSpeechRecognition';

interface PremiumAddTaskProps {
  onClose: () => void;
  onAddTask: (taskDescription: string) => void;
  isProcessing?: boolean;
}

/**
 * Premium Add Task Modal - Text & Voice Input
 */
export const PremiumAddTask: React.FC<PremiumAddTaskProps> = ({
  onClose,
  onAddTask,
  isProcessing = false
}) => {
  const [taskInput, setTaskInput] = useState('');
  const { 
    isListening, 
    transcript, 
    startListening, 
    stopListening, 
    isSupported 
  } = useSpeechRecognition();

  // Update input when speech transcript changes
  React.useEffect(() => {
    if (transcript) {
      setTaskInput(transcript);
    }
  }, [transcript]);

  const handleSubmit = () => {
    if (taskInput.trim() && !isProcessing) {
      onAddTask(taskInput.trim());
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit();
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md">
      <div className={`${GLASS_EFFECTS.card.base} rounded-3xl max-w-2xl w-full p-8 lg:p-10 relative`}>
        
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-6 right-6 text-white/60 hover:text-white transition-colors"
        >
          <X size={24} />
        </button>

        {/* Header */}
        <div className="mb-8">
          <div className="inline-flex items-center gap-2 backdrop-blur-md bg-white/[0.05] border border-white/[0.1] rounded-full px-4 py-2 mb-4">
            <Plus size={16} className="text-blue-400" />
            <span className="text-sm text-white/70">Neue Aufgabe</span>
          </div>
          
          <h2 className={buildHeadline('md', true)}>
            Aufgabe hinzufügen
          </h2>
          <p className={`${buildBodyText('md')} mt-2`}>
            Beschreibe deine Aufgabe per Text oder Sprache
          </p>
        </div>

        {/* Input Area */}
        <div className="space-y-4">
          <div className="relative">
            <textarea
              value={taskInput}
              onChange={(e) => setTaskInput(e.target.value)}
              onKeyPress={handleKeyPress}
              placeholder="z.B. Mathe lernen (1 Stunde), Sport machen, Einkaufen gehen..."
              className={`
                w-full
                ${GLASS_EFFECTS.input.base}
                rounded-2xl
                p-4 pr-16
                text-white
                placeholder-white/40
                min-h-[120px]
                resize-none
                text-base
              `}
              autoFocus
            />
            
            {/* Voice Input Button */}
            {isSupported && (
              <button
                onClick={isListening ? stopListening : startListening}
                className={`
                  absolute bottom-4 right-4
                  w-12 h-12 rounded-full
                  flex items-center justify-center
                  transition-all duration-200
                  ${isListening 
                    ? 'bg-red-500 hover:bg-red-600 animate-pulse' 
                    : 'bg-blue-600 hover:bg-blue-500'
                  }
                `}
                title={isListening ? 'Aufnahme stoppen' : 'Spracheingabe starten'}
              >
                {isListening ? (
                  <MicOff size={20} className="text-white" />
                ) : (
                  <Mic size={20} className="text-white" />
                )}
              </button>
            )}
          </div>

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

          {/* Tips */}
          <div className={`${GLASS_EFFECTS.card.base} rounded-xl p-4 backdrop-blur-md bg-white/[0.02]`}>
            <p className="text-white/40 text-xs mb-2">
              💡 <span className="font-semibold text-white/60">Tipps:</span>
            </p>
            <ul className="text-white/40 text-xs space-y-1 ml-4">
              <li>• Gib Zeiten an für bessere Planung (z.B. "1 Stunde")</li>
              <li>• Sei spezifisch für bessere KI-Analyse</li>
              <li>• Klicke 🎤 für Spracheingabe (Chrome, Edge, Safari)</li>
            </ul>
          </div>
        </div>

        {/* Actions */}
        <div className="flex gap-4 mt-8">
          <button
            onClick={onClose}
            className={`${PREMIUM_COMPONENTS.button.secondary} flex-1`}
          >
            Abbrechen
          </button>
          <button
            onClick={handleSubmit}
            disabled={!taskInput.trim() || isProcessing}
            className={`${PREMIUM_COMPONENTS.button.primary} flex-1 flex items-center justify-center gap-2`}
          >
            {isProcessing ? (
              <>
                <div className="w-5 h-5 border-2 border-black border-t-transparent rounded-full animate-spin" />
                <span>Wird hinzugefügt...</span>
              </>
            ) : (
              <>
                <Sparkles size={20} />
                <span>KI analysieren & hinzufügen</span>
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
};


import React from 'react';
import { Camera, CheckCircle2, XCircle, Loader2 } from 'lucide-react';
import { buildHeadline, buildBodyText, GLASS_EFFECTS, PREMIUM_LAYOUT, PREMIUM_COMPONENTS } from '../theme-premium';

interface PremiumVerificationProps {
  taskTitle: string;
  proofImageUrl?: string;
  isVerifying?: boolean;
  verificationResult?: {
    accepted: boolean;
    reason: string;
    confidence: number;
  } | null;
  onRetry: () => void;
  onContinue: () => void;
  onMarkCompleteAnyway: () => void;
}

/**
 * Premium Verification Screen - Photo proof checking
 */
export const PremiumVerification: React.FC<PremiumVerificationProps> = ({
  taskTitle,
  proofImageUrl,
  isVerifying = false,
  verificationResult,
  onRetry,
  onContinue,
  onMarkCompleteAnyway
}) => {
  return (
    <div className="min-h-screen flex items-center justify-center px-6 lg:px-12">
      <div className={`${PREMIUM_LAYOUT.container.medium} relative z-10`}>
        <div className="space-y-8">
          
          {/* Header */}
          <div className="text-center">
            <div className="text-5xl mb-6">
              {isVerifying && '🔍'}
              {!isVerifying && verificationResult?.accepted && '✅'}
              {!isVerifying && verificationResult && !verificationResult.accepted && '❌'}
              {!isVerifying && !verificationResult && '📸'}
            </div>
            <h1 className={buildHeadline('md', true)}>
              Nachweis-Prüfung
            </h1>
            <p className={`${buildBodyText('lg')} mt-4`}>
              {taskTitle}
            </p>
          </div>

          {/* Image Preview */}
          {proofImageUrl && (
            <div className={`${GLASS_EFFECTS.card.base} rounded-3xl p-6 lg:p-8`}>
              <div className="aspect-video bg-black/30 rounded-xl flex items-center justify-center overflow-hidden">
                <img
                  src={proofImageUrl}
                  alt="Nachweis"
                  className="max-w-full max-h-full object-contain"
                />
              </div>
            </div>
          )}

          {/* Verification Status */}
          {isVerifying && (
            <div className={`${GLASS_EFFECTS.card.base} rounded-2xl p-8 text-center`}>
              <Loader2 size={48} className="text-blue-400 mx-auto mb-4 animate-spin" />
              <p className="text-white text-lg">
                KI prüft deinen Nachweis...
              </p>
              <p className="text-white/50 text-sm mt-2">
                Das dauert nur wenige Sekunden
              </p>
            </div>
          )}

          {/* Result - Accepted */}
          {!isVerifying && verificationResult?.accepted && (
            <div className={`${GLASS_EFFECTS.card.base} rounded-2xl p-8 border-l-4 border-l-green-400/50`}>
              <div className="flex items-center gap-4 mb-4">
                <div className="w-12 h-12 rounded-full bg-green-500/20 flex items-center justify-center">
                  <CheckCircle2 size={24} className="text-green-400" />
                </div>
                <div>
                  <h3 className="text-white text-xl font-light">Nachweis akzeptiert!</h3>
                  <p className="text-white/60 text-sm">Aufgabe wird als erledigt markiert</p>
                </div>
              </div>
              <p className="text-white/70 text-sm mb-4">
                {verificationResult.reason}
              </p>
              <div className="flex items-center gap-2 text-white/40 text-xs">
                <span>Confidence:</span>
                <div className="flex-1 bg-white/[0.1] rounded-full h-1.5">
                  <div
                    className="bg-green-400 h-1.5 rounded-full"
                    style={{ width: `${verificationResult.confidence * 100}%` }}
                  />
                </div>
                <span>{Math.round(verificationResult.confidence * 100)}%</span>
              </div>
            </div>
          )}

          {/* Result - Rejected */}
          {!isVerifying && verificationResult && !verificationResult.accepted && (
            <div className={`${GLASS_EFFECTS.card.base} rounded-2xl p-8 border-l-4 border-l-red-400/50`}>
              <div className="flex items-center gap-4 mb-4">
                <div className="w-12 h-12 rounded-full bg-red-500/20 flex items-center justify-center">
                  <XCircle size={24} className="text-red-400" />
                </div>
                <div>
                  <h3 className="text-white text-xl font-light">Nachweis nicht akzeptiert</h3>
                  <p className="text-white/60 text-sm">Bitte versuche es erneut</p>
                </div>
              </div>
              <p className="text-white/70 text-sm">
                {verificationResult.reason}
              </p>
            </div>
          )}

          {/* Actions */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            {!isVerifying && verificationResult?.accepted && (
              <button
                onClick={onContinue}
                className={`${PREMIUM_COMPONENTS.button.primary} flex items-center gap-2`}
              >
                <CheckCircle2 size={20} />
                <span>Weiter</span>
              </button>
            )}
            
            {!isVerifying && verificationResult && !verificationResult.accepted && (
              <>
                <button
                  onClick={onRetry}
                  className={`${PREMIUM_COMPONENTS.button.primary} flex items-center gap-2`}
                >
                  <Camera size={20} />
                  <span>Neues Foto hochladen</span>
                </button>
                <button
                  onClick={onMarkCompleteAnyway}
                  className={`${PREMIUM_COMPONENTS.button.secondary} flex items-center gap-2`}
                >
                  <span>Trotzdem als erledigt markieren</span>
                </button>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};


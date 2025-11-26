import React, { useState } from 'react';
import { CoachMessage } from '../coach/CoachMessage';
import { CoachPersonality, VerificationResult } from '../../types';
import { Camera, CheckCircle2, XCircle, Loader2 } from 'lucide-react';

interface VerificationProps {
  personality: CoachPersonality;
  taskTitle: string;
  proofImageUrl?: string;
  verificationResult?: VerificationResult | null;
  isVerifying?: boolean;
  onRetry: () => void;
  onContinue: () => void;
  onMarkCompleteAnyway: () => void;
}

export const Verification: React.FC<VerificationProps> = ({
  personality,
  taskTitle,
  proofImageUrl,
  verificationResult,
  isVerifying = false,
  onRetry,
  onContinue,
  onMarkCompleteAnyway,
}) => {
  return (
    <div className="w-full flex items-center justify-center min-h-[80vh] p-4">
      <div className="max-w-xl lg:max-w-3xl w-full space-y-6">
        {/* Coach Message */}
        <CoachMessage
          personality={personality}
          message={
            isVerifying
              ? 'Ich prüfe deinen Nachweis...'
              : verificationResult?.coachMessage || 'Nachweis wird geprüft.'
          }
        />

        {/* Divider */}
        <div className="border-t border-slate-800"></div>

        {/* Title */}
        <div className="text-center">
          <h2 className="text-2xl font-semibold text-white mb-2">NACHWEIS-PRÜFUNG</h2>
          <p className="text-lg text-slate-400">{taskTitle}</p>
        </div>

        {/* Image Preview */}
        {proofImageUrl && (
          <div className="bg-slate-900/50 border border-slate-700 rounded-xl p-6">
            <div className="aspect-video bg-slate-800 rounded-lg flex items-center justify-center overflow-hidden">
              <img
                src={proofImageUrl}
                alt="Nachweis"
                className="max-w-full max-h-full object-contain"
              />
            </div>
          </div>
        )}

        {/* Loading State */}
        {isVerifying && (
          <div className="text-center space-y-4">
            <div className="flex justify-center">
              <Loader2 size={32} className="text-blue-500 animate-spin" />
            </div>
            <div className="text-slate-400">⏳ KI analysiert...</div>
            <div className="w-full bg-slate-800 rounded-full h-2 overflow-hidden">
              <div className="h-full bg-blue-500 animate-pulse" style={{ width: '60%' }} />
            </div>
          </div>
        )}

        {/* Verification Result */}
        {verificationResult && !isVerifying && (
          <div className="space-y-6">
            {verificationResult.accepted ? (
              <>
                {/* Accepted */}
                <div className="text-center space-y-4">
                  <div className="flex justify-center">
                    <CheckCircle2 size={64} className="text-green-500" />
                  </div>
                  <h3 className="text-3xl font-bold text-green-500">✅ AKZEPTIERT</h3>
                </div>

                {/* Detected Elements */}
                {verificationResult.detectedElements.length > 0 && (
                  <div className="bg-slate-900/50 border border-slate-700 rounded-xl p-4">
                    <div className="text-sm font-medium text-slate-400 mb-2">Erkannt:</div>
                    <ul className="space-y-1">
                      {verificationResult.detectedElements.map((element, i) => (
                        <li key={i} className="text-slate-300 flex items-center gap-2">
                          <span className="text-green-500">•</span>
                          {element}
                        </li>
                      ))}
                    </ul>
                  </div>
                )}

                {/* Continue Button */}
                <button
                  onClick={onContinue}
                  className="w-full bg-white text-slate-900 font-semibold py-4 rounded-xl hover:bg-slate-100 transition-all"
                >
                  Weiter zur nächsten Aufgabe
                </button>
              </>
            ) : (
              <>
                {/* Rejected */}
                <div className="text-center space-y-4">
                  <div className="flex justify-center">
                    <XCircle size={64} className="text-red-500" />
                  </div>
                  <h3 className="text-3xl font-bold text-red-500">❌ ABGELEHNT</h3>
                </div>

                {/* Reason */}
                <div className="bg-slate-900/50 border border-slate-700 rounded-xl p-4">
                  <div className="text-sm font-medium text-slate-400 mb-2">Problem:</div>
                  <p className="text-slate-300">{verificationResult.reason}</p>
                </div>

                {/* Actions */}
                <div className="space-y-3">
                  <button
                    onClick={onRetry}
                    className="w-full bg-amber-600 hover:bg-amber-500 text-white font-medium py-3 px-6 rounded-xl flex items-center justify-center gap-2 transition-colors"
                  >
                    <Camera size={20} />
                    Neuen Nachweis hochladen
                  </button>
                  <button
                    onClick={onMarkCompleteAnyway}
                    className="w-full bg-red-600/20 hover:bg-red-600/40 text-red-400 border border-red-600/50 py-3 px-6 rounded-xl transition-colors"
                  >
                    Aufgabe trotzdem als erledigt markieren
                  </button>
                  <p className="text-xs text-red-400 text-center">
                    ⚠️ Warnung: Ablenkungen bleiben für 2h länger blockiert
                  </p>
                </div>
              </>
            )}
          </div>
        )}
      </div>
    </div>
  );
};


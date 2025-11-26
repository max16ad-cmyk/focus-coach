import React, { useState } from 'react';
import { User } from '../types';
import { ShieldCheck, Sparkles, ArrowRight, Loader2 } from 'lucide-react';
import { loginUser, registerUser } from '../services/firebase';
import { PREMIUM_COLORS, PREMIUM_TYPOGRAPHY, GLASS_EFFECTS, buildHeadline, buildBodyText } from '../theme-premium';

interface AuthScreenProps {
  onLogin: (user: User) => void;
}

export const AuthScreen: React.FC<AuthScreenProps> = ({ onLogin }) => {
  const [isRegistering, setIsRegistering] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
        setError("Bitte gib Email und Passwort ein.");
        return;
    }
    
    setIsLoading(true);
    setError(null);

    try {
        let firebaseUser;
        if (isRegistering) {
            firebaseUser = await registerUser(email, password);
        } else {
            firebaseUser = await loginUser(email, password);
        }
        
        // Convert Firebase user to App User
        onLogin({
            uid: firebaseUser.uid,
            email: firebaseUser.email || "",
            name: firebaseUser.email?.split('@')[0] || "User"
        });

    } catch (err: any) {
        console.error(err);
        if (err.message.includes("auth/invalid-credential")) {
            setError("Ungültige Email oder Passwort.");
        } else if (err.message.includes("auth/email-already-in-use")) {
            setError("Email bereits registriert. Versuche dich anzumelden.");
        } else if (err.message.includes("Firebase not configured")) {
             setError("Setup Required: Configure API Keys in services/firebase.ts");
        } else {
            setError(err.message || "Ein Fehler ist aufgetreten.");
        }
    } finally {
        setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-6 relative overflow-hidden" style={{ background: PREMIUM_COLORS.background }}>
        {/* Ambient Background Glow */}
        <div className="absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none">
          <div className="absolute top-1/4 -left-1/4 w-96 h-96 bg-blue-500/10 rounded-full blur-3xl"></div>
          <div className="absolute bottom-1/4 -right-1/4 w-96 h-96 bg-purple-500/10 rounded-full blur-3xl"></div>
        </div>

        <div className={`w-full max-w-md ${GLASS_EFFECTS.card.base} rounded-3xl p-10 shadow-2xl z-10 relative`}>
            {/* Header */}
            <div className="text-center mb-10">
                <div className="inline-flex items-center justify-center w-20 h-20 rounded-2xl bg-gradient-to-br from-blue-500/20 to-purple-500/20 backdrop-blur-sm border border-white/[0.1] mb-6 shadow-xl">
                    <Sparkles size={40} className="text-white" />
                </div>
                <h1 className={`${buildHeadline('lg', true)} text-white mb-3`}>
                    {isRegistering ? 'Create Account' : 'Welcome back'}
                </h1>
                <p className={`${buildBodyText('md', 'normal')} text-white/50`}>
                    {isRegistering 
                        ? "Starte deine produktive Reise" 
                        : "Melde dich an und bleib fokussiert"}
                </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-6">
                {error && (
                    <div className={`${GLASS_EFFECTS.card.base} border-red-400/50 bg-red-500/10 text-red-200 text-sm p-4 rounded-xl text-center`}>
                        {error}
                    </div>
                )}

                <div>
                    <label className={`${PREMIUM_TYPOGRAPHY.label.base} text-white/50 mb-2 block`}>
                        Email
                    </label>
                    <input 
                        type="email" 
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        className={`w-full ${GLASS_EFFECTS.card.base} rounded-xl px-4 py-3 text-white placeholder-white/30 focus:outline-none focus:border-blue-400/50 focus:shadow-blue-500/20 transition-all`}
                        placeholder="deine@email.com"
                    />
                </div>

                <div>
                    <label className={`${PREMIUM_TYPOGRAPHY.label.base} text-white/50 mb-2 block`}>
                        Passwort
                    </label>
                    <input 
                        type="password" 
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        className={`w-full ${GLASS_EFFECTS.card.base} rounded-xl px-4 py-3 text-white placeholder-white/30 focus:outline-none focus:border-blue-400/50 focus:shadow-blue-500/20 transition-all`}
                        placeholder="••••••••"
                    />
                </div>
                
                <button 
                    type="submit"
                    disabled={isLoading}
                    className={`w-full ${GLASS_EFFECTS.button.primary} text-white font-semibold py-4 rounded-xl transition-all transform hover:scale-[1.02] active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-3 mt-8`}
                >
                    {isLoading ? (
                        <Loader2 size={20} className="animate-spin" />
                    ) : (
                        <>
                            {isRegistering ? 'Account erstellen' : 'Anmelden'}
                            {!isRegistering && <ArrowRight size={20} />}
                        </>
                    )}
                </button>
            </form>
            
            <div className="mt-8 pt-6 border-t border-white/[0.08] text-center">
                <button 
                    onClick={() => { setError(null); setIsRegistering(!isRegistering); }}
                    className={`${buildBodyText('sm', 'normal')} text-white/50 hover:text-white transition-colors`}
                >
                    {isRegistering ? (
                        "Bereits ein Account? Anmelden"
                    ) : (
                        <>
                            Noch kein Account? <span className="text-blue-400 font-semibold">Jetzt registrieren</span>
                        </>
                    )}
                </button>
            </div>

            {/* Decorative Elements */}
            <div className="absolute -top-20 -right-20 w-40 h-40 bg-blue-500/5 rounded-full blur-2xl pointer-events-none"></div>
            <div className="absolute -bottom-20 -left-20 w-40 h-40 bg-purple-500/5 rounded-full blur-2xl pointer-events-none"></div>
        </div>

        {/* Footer */}
        <p className={`${buildBodyText('sm', 'normal')} text-white/30 mt-8 text-center`}>
            Deine Daten sind sicher verschlüsselt und synchronisiert
        </p>
    </div>
  );
};
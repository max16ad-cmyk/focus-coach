import React, { useState } from 'react';
import { User } from '../types';
import { ShieldCheck, Smartphone, Monitor, Tablet, ArrowRight, UserPlus } from 'lucide-react';
import { loginUser, registerUser } from '../services/firebase';

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
        setError("Please enter both email and password.");
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
            setError("Invalid email or password.");
        } else if (err.message.includes("auth/email-already-in-use")) {
            setError("Email already exists. Try logging in.");
        } else if (err.message.includes("Firebase not configured")) {
             setError("Setup Required: Configure API Keys in services/firebase.ts");
        } else {
            setError(err.message || "An error occurred.");
        }
    } finally {
        setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-vault-900 flex flex-col items-center justify-center p-6 relative overflow-hidden">
        {/* Background Decorations */}
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-vault-accent/10 rounded-full blur-3xl pointer-events-none"></div>
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-purple-600/10 rounded-full blur-3xl pointer-events-none"></div>

        <div className="w-full max-w-md bg-vault-800/50 backdrop-blur-xl border border-vault-700 rounded-2xl p-8 shadow-2xl z-10 transition-all duration-300">
            <div className="text-center mb-8">
                <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-br from-vault-accent to-purple-600 mb-4 shadow-lg shadow-vault-accent/20">
                    <ShieldCheck size={32} className="text-white" />
                </div>
                <h1 className="text-3xl font-bold text-white mb-2">Focus Vault</h1>
                <p className="text-gray-400 text-sm">
                    {isRegistering ? "Create your secure account" : "Sync your focus across all devices."}
                </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
                {error && (
                    <div className="bg-red-900/20 border border-red-500/50 text-red-200 text-xs p-3 rounded-lg text-center">
                        {error}
                    </div>
                )}

                <div>
                    <label className="block text-xs font-medium text-gray-400 mb-1 uppercase tracking-wider">Email</label>
                    <input 
                        type="email" 
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        className="w-full bg-vault-900 border border-vault-700 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-vault-accent focus:ring-1 focus:ring-vault-accent transition-all"
                        placeholder="user@example.com"
                    />
                </div>
                <div>
                    <label className="block text-xs font-medium text-gray-400 mb-1 uppercase tracking-wider">Password</label>
                    <input 
                        type="password" 
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        className="w-full bg-vault-900 border border-vault-700 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-vault-accent focus:ring-1 focus:ring-vault-accent transition-all"
                        placeholder="••••••••"
                    />
                </div>
                
                <button 
                    type="submit"
                    disabled={isLoading}
                    className="w-full bg-gradient-to-r from-vault-accent to-purple-600 hover:from-blue-600 hover:to-purple-700 text-white font-bold py-3 rounded-lg transition-all transform hover:scale-[1.02] active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 shadow-lg shadow-purple-900/20"
                >
                    {isLoading ? (
                        <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    ) : (
                        <>
                            {isRegistering ? 'Create Account' : 'Access Vault'}
                            {!isRegistering && <ArrowRight size={18} />}
                        </>
                    )}
                </button>
            </form>
            
            <div className="mt-6 pt-6 border-t border-vault-700 text-center">
                <button 
                    onClick={() => { setError(null); setIsRegistering(!isRegistering); }}
                    className="text-gray-400 hover:text-white text-sm transition-colors flex items-center justify-center gap-2 w-full"
                >
                    {isRegistering ? (
                        "Already have an account? Log In"
                    ) : (
                        <>
                            New here? <span className="text-vault-accent font-medium">Create Account</span>
                        </>
                    )}
                </button>
            </div>
        </div>
    </div>
  );
};
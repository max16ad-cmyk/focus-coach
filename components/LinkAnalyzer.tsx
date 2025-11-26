import React, { useState } from 'react';
import { analyzeUrlContent } from '../services/geminiService';
import { Distraction } from '../types';
import { ScanSearch, PlayCircle, Briefcase, CheckCircle, XCircle } from 'lucide-react';

interface LinkAnalyzerProps {
  onAddDistraction: (d: Distraction) => void;
}

export const LinkAnalyzer: React.FC<LinkAnalyzerProps> = ({ onAddDistraction }) => {
  const [url, setUrl] = useState('');
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [result, setResult] = useState<{isProductive: boolean, message: string} | null>(null);

  const handleAnalyze = async () => {
    if (!url) return;
    setIsAnalyzing(true);
    setResult(null);
    
    try {
        const analysis = await analyzeUrlContent(url);
        
        if (analysis.isProductive) {
            setResult({ isProductive: true, message: `Allowed: ${analysis.reason}` });
            // In a real app, this would whitelist the URL. For now, we open it.
            window.open(url, '_blank');
        } else {
            setResult({ isProductive: false, message: `Blocked: ${analysis.reason}` });
            // Add to vault
            onAddDistraction({
                id: Date.now().toString(),
                name: analysis.suggestedName,
                url: url,
                icon: analysis.category === 'Gaming' ? '🎮' : '📺',
                category: 'social'
            });
        }
    } catch (error) {
        console.error(error);
    } finally {
        setIsAnalyzing(false);
        setUrl('');
    }
  };

  return (
    <div className="bg-vault-800 p-4 rounded-xl border border-vault-700 mb-6">
        <h3 className="text-sm font-semibold text-gray-300 mb-3 flex items-center gap-2">
            <ScanSearch size={16} className="text-vault-accent" />
            Smart Link Audit
        </h3>
        <div className="flex gap-2">
            <input 
                type="text" 
                value={url}
                onChange={(e) => setUrl(e.target.value)}
                placeholder="Paste URL (YouTube, Articles...)"
                className="flex-1 bg-vault-900 border border-vault-700 rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-vault-accent"
            />
            <button 
                onClick={handleAnalyze}
                disabled={isAnalyzing || !url}
                className="bg-vault-700 hover:bg-vault-600 text-white px-3 rounded-lg flex items-center justify-center transition-colors disabled:opacity-50"
            >
                {isAnalyzing ? (
                    <div className="w-4 h-4 border-2 border-current border-t-transparent rounded-full animate-spin" />
                ) : (
                    <span className="text-xs font-bold">Check</span>
                )}
            </button>
        </div>
        
        {result && (
            <div className={`mt-3 text-xs p-2 rounded border flex items-center gap-2 ${
                result.isProductive 
                ? 'bg-emerald-900/20 border-emerald-800 text-emerald-400' 
                : 'bg-red-900/20 border-red-800 text-red-400'
            }`}>
                {result.isProductive ? <CheckCircle size={14} /> : <XCircle size={14} />}
                {result.message}
            </div>
        )}
        <p className="text-[10px] text-gray-500 mt-2">
            AI analyzes if content is Work (Allowed) or Fun (Vaulted).
        </p>
    </div>
  );
};
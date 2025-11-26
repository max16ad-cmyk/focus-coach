import React, { useState, useEffect } from 'react';
import { X, AlertTriangle, Copy, Check } from 'lucide-react';

interface ErrorLog {
  timestamp: string;
  message: string;
  stack?: string;
  type: 'error' | 'warning' | 'info';
}

export const ErrorLogger: React.FC = () => {
  const [errors, setErrors] = useState<ErrorLog[]>([]);
  const [isVisible, setIsVisible] = useState(false);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    // Capture console errors
    const originalError = console.error;
    const originalWarn = console.warn;

    console.error = (...args: any[]) => {
      const message = args.map(arg => 
        typeof arg === 'object' ? JSON.stringify(arg) : String(arg)
      ).join(' ');
      
      // Don't log API errors as critical errors (they have fallbacks)
      const isApiError = message.includes('ApiError') || 
                        message.includes('status') && message.includes('400') ||
                        message.includes('Task analysis failed') ||
                        message.includes('Gemini');
      
      setErrors(prev => [...prev, {
        timestamp: new Date().toLocaleTimeString(),
        message,
        type: isApiError ? 'warning' : 'error'
      }]);
      
      originalError.apply(console, args);
    };

    console.warn = (...args: any[]) => {
      const message = args.map(arg => 
        typeof arg === 'object' ? JSON.stringify(arg) : String(arg)
      ).join(' ');
      
      setErrors(prev => [...prev, {
        timestamp: new Date().toLocaleTimeString(),
        message,
        type: 'warning'
      }]);
      
      originalWarn.apply(console, args);
    };

    // Capture unhandled errors
    const handleError = (event: ErrorEvent) => {
      setErrors(prev => [...prev, {
        timestamp: new Date().toLocaleTimeString(),
        message: event.message,
        stack: event.error?.stack,
        type: 'error'
      }]);
      setIsVisible(true); // Auto-show on error
    };

    // Capture unhandled promise rejections
    const handleRejection = (event: PromiseRejectionEvent) => {
      setErrors(prev => [...prev, {
        timestamp: new Date().toLocaleTimeString(),
        message: `Unhandled Promise Rejection: ${event.reason}`,
        type: 'error'
      }]);
      setIsVisible(true); // Auto-show on error
    };

    window.addEventListener('error', handleError);
    window.addEventListener('unhandledrejection', handleRejection);

    // Log initial info
    setErrors([{
      timestamp: new Date().toLocaleTimeString(),
      message: '🟢 Error Logger initialized',
      type: 'info'
    }]);

    return () => {
      console.error = originalError;
      console.warn = originalWarn;
      window.removeEventListener('error', handleError);
      window.removeEventListener('unhandledrejection', handleRejection);
    };
  }, []);

  const copyAllErrors = () => {
    const errorText = errors.map(e => 
      `[${e.timestamp}] ${e.type.toUpperCase()}: ${e.message}${e.stack ? '\n' + e.stack : ''}`
    ).join('\n\n');
    
    navigator.clipboard.writeText(errorText).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    });
  };

  const clearErrors = () => {
    setErrors([{
      timestamp: new Date().toLocaleTimeString(),
      message: '🟢 Errors cleared',
      type: 'info'
    }]);
  };

  if (!isVisible && errors.length <= 1) return null;

  return (
    <>
      {/* Floating Error Button (if collapsed) */}
      {!isVisible && errors.filter(e => e.type === 'error').length > 0 && (
        <button
          onClick={() => setIsVisible(true)}
          className="fixed bottom-4 right-4 z-[9999] bg-red-600 text-white p-3 rounded-full shadow-lg animate-pulse"
          title="Fehler anzeigen"
        >
          <AlertTriangle size={24} />
          <span className="absolute -top-2 -right-2 bg-white text-red-600 text-xs font-bold w-6 h-6 rounded-full flex items-center justify-center">
            {errors.filter(e => e.type === 'error').length}
          </span>
        </button>
      )}

      {/* Error Logger Panel */}
      {isVisible && (
        <div className="fixed inset-0 z-[9999] bg-black/80 backdrop-blur-md flex items-end sm:items-center justify-center p-4">
          <div className="bg-[#0a0a0a] border border-white/[0.1] rounded-2xl w-full max-w-2xl max-h-[80vh] flex flex-col shadow-2xl">
            {/* Header */}
            <div className="flex items-center justify-between p-4 border-b border-white/[0.1]">
              <div className="flex items-center gap-3">
                <AlertTriangle size={24} className="text-yellow-500" />
                <div>
                  <h3 className="text-white font-semibold">Error Logger</h3>
                  <p className="text-white/50 text-xs">
                    {errors.filter(e => e.type === 'error').length} Fehler, {errors.filter(e => e.type === 'warning').length} Warnungen
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={copyAllErrors}
                  className="px-3 py-1.5 bg-white/[0.05] hover:bg-white/[0.1] text-white text-sm rounded-lg border border-white/[0.1] flex items-center gap-2 transition-colors"
                >
                  {copied ? <Check size={16} /> : <Copy size={16} />}
                  {copied ? 'Kopiert!' : 'Kopieren'}
                </button>
                <button
                  onClick={clearErrors}
                  className="px-3 py-1.5 bg-white/[0.05] hover:bg-white/[0.1] text-white text-sm rounded-lg border border-white/[0.1] transition-colors"
                >
                  Löschen
                </button>
                <button
                  onClick={() => setIsVisible(false)}
                  className="p-2 hover:bg-white/[0.05] rounded-lg transition-colors text-white/70 hover:text-white"
                >
                  <X size={20} />
                </button>
              </div>
            </div>

            {/* Error List */}
            <div className="flex-1 overflow-y-auto p-4 space-y-2">
              {errors.map((error, i) => (
                <div
                  key={i}
                  className={`p-3 rounded-lg border ${
                    error.type === 'error'
                      ? 'bg-red-500/10 border-red-500/30'
                      : error.type === 'warning'
                      ? 'bg-yellow-500/10 border-yellow-500/30'
                      : 'bg-blue-500/10 border-blue-500/30'
                  }`}
                >
                  <div className="flex items-start gap-2">
                    <span className="text-white/50 text-xs font-mono whitespace-nowrap">
                      {error.timestamp}
                    </span>
                    <div className="flex-1 min-w-0">
                      <p className={`text-sm font-mono break-words ${
                        error.type === 'error'
                          ? 'text-red-300'
                          : error.type === 'warning'
                          ? 'text-yellow-300'
                          : 'text-blue-300'
                      }`}>
                        {error.message}
                      </p>
                      {error.stack && (
                        <details className="mt-2">
                          <summary className="text-xs text-white/50 cursor-pointer hover:text-white/70">
                            Stack Trace
                          </summary>
                          <pre className="text-xs text-white/50 mt-2 overflow-x-auto">
                            {error.stack}
                          </pre>
                        </details>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* Footer Info */}
            <div className="p-3 border-t border-white/[0.1] bg-white/[0.02]">
              <p className="text-xs text-white/50 text-center">
                💡 Tipp: Kopiere die Fehler und sende sie an den Support
              </p>
            </div>
          </div>
        </div>
      )}
    </>
  );
};


import React from 'react';
import { Download, Windows } from 'lucide-react';
import { electronService } from '../services/electronService';

interface WindowsDownloadProps {
  className?: string;
}

/**
 * Windows Download Component
 * 
 * Shows download button for Windows Desktop App
 * Only visible when NOT running in Electron
 */
export const WindowsDownload: React.FC<WindowsDownloadProps> = ({ className = '' }) => {
  // Don't show if already running in Electron
  if (electronService.isElectron) {
    return null;
  }

  // Detect if user is on Windows
  const isWindows = navigator.platform.toLowerCase().includes('win') || 
                    navigator.userAgent.toLowerCase().includes('windows');

  // Download URL - Update this to your actual download location
  const downloadUrl = 'https://github.com/yourusername/focus-coach/releases/latest/download/FocusCoach-Setup-1.0.0.exe';
  
  // Alternative: Firebase Storage URL
  // const downloadUrl = 'https://firebasestorage.googleapis.com/v0/b/your-project.appspot.com/o/FocusCoach-Setup-1.0.0.exe?alt=media';

  const handleDownload = () => {
    window.open(downloadUrl, '_blank');
    
    // Optional: Track download event
    if (typeof window !== 'undefined' && (window as any).gtag) {
      (window as any).gtag('event', 'download', {
        'event_category': 'Windows App',
        'event_label': 'Desktop App Download'
      });
    }
  };

  return (
    <button
      onClick={handleDownload}
      className={`inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-gradient-to-r from-blue-600 to-blue-500 hover:from-blue-500 hover:to-blue-400 rounded-lg transition-all shadow-lg shadow-blue-500/30 hover:shadow-blue-500/50 ${className}`}
      title="Windows Desktop App herunterladen"
    >
      <Download size={16} />
      <Windows size={16} />
      <span className="hidden sm:inline">Windows App</span>
      <span className="sm:hidden">Download</span>
    </button>
  );
};

/**
 * Windows Download Banner
 * 
 * Shows a banner promoting the Windows Desktop App
 */
export const WindowsDownloadBanner: React.FC = () => {
  if (electronService.isElectron) {
    return null;
  }

  const isWindows = navigator.platform.toLowerCase().includes('win') || 
                    navigator.userAgent.toLowerCase().includes('windows');

  if (!isWindows) {
    return null; // Only show on Windows
  }

  const downloadUrl = 'https://github.com/yourusername/focus-coach/releases/latest/download/FocusCoach-Setup-1.0.0.exe';

  return (
    <div className="fixed bottom-4 left-1/2 transform -translate-x-1/2 z-50 max-w-md w-full mx-4">
      <div className="bg-gradient-to-r from-blue-600/90 to-blue-500/90 backdrop-blur-xl border border-blue-400/30 rounded-2xl p-4 shadow-2xl">
        <div className="flex items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="bg-white/20 rounded-lg p-2">
              <Windows size={24} className="text-white" />
            </div>
            <div>
              <p className="text-white font-semibold text-sm">
                Windows Desktop App verfügbar
              </p>
              <p className="text-white/80 text-xs">
                System-Level Blockierung & mehr Features
              </p>
            </div>
          </div>
          <button
            onClick={() => window.open(downloadUrl, '_blank')}
            className="bg-white text-blue-600 px-4 py-2 rounded-lg font-semibold text-sm hover:bg-white/90 transition-colors whitespace-nowrap"
          >
            Download
          </button>
        </div>
      </div>
    </div>
  );
};


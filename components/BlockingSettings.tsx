import React, { useState, useEffect } from 'react';
import { Blocklist } from '../types';
import { useElectronBlocking } from '../hooks/useElectronBlocking';
import { electronService } from '../services/electronService';
import { Shield, Plus, X, Trash2, AlertCircle, CheckCircle2, Loader } from 'lucide-react';
import { buildHeadline, buildBodyText, GLASS_EFFECTS, PREMIUM_LAYOUT } from '../theme-premium';

interface BlockingSettingsProps {
  blocklists: Blocklist[];
  onUpdate: (blocklists: Blocklist[]) => void;
  defaultBlocklistId?: string;
  onDefaultChange?: (blocklistId: string | undefined) => void;
  onClose?: () => void;
}

/**
 * Blocking Settings Component
 * 
 * Manages blocklists for Windows blocking feature
 */
export const BlockingSettings: React.FC<BlockingSettingsProps> = ({
  blocklists,
  onUpdate,
  defaultBlocklistId,
  onDefaultChange,
  onClose,
}) => {
  const blocking = useElectronBlocking();
  const [localBlocklists, setLocalBlocklists] = useState<Blocklist[]>(blocklists);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [newAppPath, setNewAppPath] = useState('');
  const [newURL, setNewURL] = useState('');
  const [showAddBlocklist, setShowAddBlocklist] = useState(false);
  const [newBlocklistName, setNewBlocklistName] = useState('');

  // Only show on Windows
  if (!electronService.isElectron || !electronService.isWindows) {
    return (
      <div className={`${GLASS_EFFECTS.card.base} rounded-2xl p-6`}>
        <div className="flex items-center gap-3 text-white/60">
          <AlertCircle size={20} />
          <p>Blockierung ist nur auf Windows verfügbar.</p>
        </div>
      </div>
    );
  }

  const handleAddBlocklist = () => {
    if (!newBlocklistName.trim()) return;

    const newBlocklist: Blocklist = {
      id: `blocklist-${Date.now()}`,
      name: newBlocklistName.trim(),
      apps: [],
      urls: [],
      createdAt: Date.now(),
    };

    const updated = [...localBlocklists, newBlocklist];
    setLocalBlocklists(updated);
    onUpdate(updated);
    setNewBlocklistName('');
    setShowAddBlocklist(false);
  };

  const handleDeleteBlocklist = (id: string) => {
    const updated = localBlocklists.filter(b => b.id !== id);
    setLocalBlocklists(updated);
    onUpdate(updated);
    if (defaultBlocklistId === id) {
      onDefaultChange?.(undefined);
    }
  };

  const handleAddApp = (blocklistId: string) => {
    if (!newAppPath.trim()) return;

    const updated = localBlocklists.map(b => {
      if (b.id === blocklistId) {
        return { ...b, apps: [...b.apps, newAppPath.trim()] };
      }
      return b;
    });

    setLocalBlocklists(updated);
    onUpdate(updated);
    setNewAppPath('');
  };

  const handleRemoveApp = (blocklistId: string, appIndex: number) => {
    const updated = localBlocklists.map(b => {
      if (b.id === blocklistId) {
        return { ...b, apps: b.apps.filter((_, i) => i !== appIndex) };
      }
      return b;
    });

    setLocalBlocklists(updated);
    onUpdate(updated);
  };

  const handleAddURL = (blocklistId: string) => {
    if (!newURL.trim()) return;

    const updated = localBlocklists.map(b => {
      if (b.id === blocklistId) {
        return { ...b, urls: [...b.urls, newURL.trim()] };
      }
      return b;
    });

    setLocalBlocklists(updated);
    onUpdate(updated);
    setNewURL('');
  };

  const handleRemoveURL = (blocklistId: string, urlIndex: number) => {
    const updated = localBlocklists.map(b => {
      if (b.id === blocklistId) {
        return { ...b, urls: b.urls.filter((_, i) => i !== urlIndex) };
      }
      return b;
    });

    setLocalBlocklists(updated);
    onUpdate(updated);
  };

  const handleTestBlocking = async (blocklist: Blocklist) => {
    const result = await blocking.applyBlocklist(blocklist);
    if (result.success) {
      alert(`Blockierung aktiviert für "${blocklist.name}"`);
    } else {
      alert(`Fehler: ${blocking.error || 'Unbekannter Fehler'}`);
    }
  };

  return (
    <div className={`${PREMIUM_LAYOUT.container.medium} space-y-6`}>
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className={`${GLASS_EFFECTS.card.base} rounded-xl p-2`}>
            <Shield size={24} className="text-white/80" />
          </div>
          <h2 className={buildHeadline('md', false)}>
            Blockierung
          </h2>
        </div>
        {onClose && (
          <button
            onClick={onClose}
            className={`${GLASS_EFFECTS.card.base} rounded-xl p-2 text-white/60 hover:text-white transition-all`}
          >
            <X size={24} />
          </button>
        )}
      </div>

      {/* Admin Rights Warning */}
      {!blocking.hasAdminRights && (
        <div className={`${GLASS_EFFECTS.card.base} rounded-2xl p-4 border border-amber-500/30 bg-amber-500/10`}>
          <div className="flex items-center gap-3 text-amber-400">
            <AlertCircle size={20} />
            <p className="text-sm">
              Admin-Rechte erforderlich für Blockierung. Bitte App als Administrator starten.
            </p>
          </div>
        </div>
      )}

      {/* Add Blocklist */}
      {showAddBlocklist ? (
        <div className={`${GLASS_EFFECTS.card.base} rounded-2xl p-6 space-y-4`}>
          <input
            type="text"
            value={newBlocklistName}
            onChange={(e) => setNewBlocklistName(e.target.value)}
            placeholder="Blockliste Name (z.B. 'Social Media')"
            className="w-full bg-white/[0.05] border border-white/[0.1] rounded-xl p-3 text-white placeholder-white/40"
            autoFocus
            onKeyPress={(e) => {
              if (e.key === 'Enter') handleAddBlocklist();
              if (e.key === 'Escape') {
                setShowAddBlocklist(false);
                setNewBlocklistName('');
              }
            }}
          />
          <div className="flex gap-3">
            <button
              onClick={() => {
                setShowAddBlocklist(false);
                setNewBlocklistName('');
              }}
              className="flex-1 bg-white/[0.05] hover:bg-white/[0.08] text-white rounded-xl p-3 transition-all"
            >
              Abbrechen
            </button>
            <button
              onClick={handleAddBlocklist}
              className="flex-1 bg-blue-600 hover:bg-blue-500 text-white rounded-xl p-3 transition-all"
            >
              Erstellen
            </button>
          </div>
        </div>
      ) : (
        <button
          onClick={() => setShowAddBlocklist(true)}
          className={`${GLASS_EFFECTS.card.base} ${GLASS_EFFECTS.card.hover} rounded-2xl p-4 w-full flex items-center justify-center gap-3 transition-all`}
        >
          <Plus size={20} className="text-blue-400" />
          <span className="text-white/80">Neue Blockliste</span>
        </button>
      )}

      {/* Blocklists */}
      <div className="space-y-4">
        {localBlocklists.map((blocklist) => (
          <div key={blocklist.id} className={`${GLASS_EFFECTS.card.base} rounded-2xl p-6 space-y-4`}>
            {/* Blocklist Header */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <h3 className={buildBodyText('md', 'semibold')}>{blocklist.name}</h3>
                {defaultBlocklistId === blocklist.id && (
                  <span className="text-xs bg-blue-500/20 text-blue-400 px-2 py-1 rounded-full">
                    Standard
                  </span>
                )}
              </div>
              <div className="flex items-center gap-2">
                {defaultBlocklistId !== blocklist.id && (
                  <button
                    onClick={() => onDefaultChange?.(blocklist.id)}
                    className="text-xs text-white/60 hover:text-white px-3 py-1 rounded-lg hover:bg-white/[0.05] transition-all"
                  >
                    Als Standard setzen
                  </button>
                )}
                <button
                  onClick={() => handleTestBlocking(blocklist)}
                  disabled={blocking.isBlocking || !blocking.hasAdminRights}
                  className="text-xs bg-green-600 hover:bg-green-500 disabled:opacity-50 disabled:cursor-not-allowed text-white px-3 py-1 rounded-lg transition-all"
                >
                  {blocking.isBlocking ? 'Blockiert...' : 'Testen'}
                </button>
                <button
                  onClick={() => handleDeleteBlocklist(blocklist.id)}
                  className="text-white/40 hover:text-red-400 transition-colors"
                >
                  <Trash2 size={18} />
                </button>
              </div>
            </div>

            {/* Apps */}
            <div>
              <label className={`${buildBodyText('sm', 'semibold')} mb-2 block`}>
                Apps ({blocklist.apps.length})
              </label>
              <div className="space-y-2 mb-3">
                {blocklist.apps.map((app, index) => (
                  <div
                    key={index}
                    className="flex items-center gap-2 bg-white/[0.03] border border-white/[0.05] rounded-lg p-2"
                  >
                    <span className="flex-1 text-sm text-white/70 font-mono truncate">
                      {app.split('\\').pop() || app.split('/').pop() || app}
                    </span>
                    <button
                      onClick={() => handleRemoveApp(blocklist.id, index)}
                      className="text-white/40 hover:text-red-400 transition-colors"
                    >
                      <X size={16} />
                    </button>
                  </div>
                ))}
              </div>
              <div className="flex gap-2">
                <input
                  type="text"
                  value={newAppPath}
                  onChange={(e) => setNewAppPath(e.target.value)}
                  placeholder="App-Pfad (z.B. C:\\Program Files\\App\\app.exe)"
                  className="flex-1 bg-white/[0.05] border border-white/[0.1] rounded-lg p-2 text-sm text-white placeholder-white/40"
                  onKeyPress={(e) => {
                    if (e.key === 'Enter' && editingId === blocklist.id) {
                      handleAddApp(blocklist.id);
                    }
                  }}
                />
                <button
                  onClick={() => {
                    setEditingId(blocklist.id);
                    handleAddApp(blocklist.id);
                  }}
                  className="bg-blue-600 hover:bg-blue-500 text-white px-4 py-2 rounded-lg transition-all text-sm"
                >
                  Hinzufügen
                </button>
              </div>
            </div>

            {/* URLs */}
            <div>
              <label className={`${buildBodyText('sm', 'semibold')} mb-2 block`}>
                URLs ({blocklist.urls.length})
              </label>
              <div className="space-y-2 mb-3">
                {blocklist.urls.map((url, index) => (
                  <div
                    key={index}
                    className="flex items-center gap-2 bg-white/[0.03] border border-white/[0.05] rounded-lg p-2"
                  >
                    <span className="flex-1 text-sm text-white/70 truncate">{url}</span>
                    <button
                      onClick={() => handleRemoveURL(blocklist.id, index)}
                      className="text-white/40 hover:text-red-400 transition-colors"
                    >
                      <X size={16} />
                    </button>
                  </div>
                ))}
              </div>
              <div className="flex gap-2">
                <input
                  type="text"
                  value={newURL}
                  onChange={(e) => setNewURL(e.target.value)}
                  placeholder="Domain (z.B. instagram.com)"
                  className="flex-1 bg-white/[0.05] border border-white/[0.1] rounded-lg p-2 text-sm text-white placeholder-white/40"
                  onKeyPress={(e) => {
                    if (e.key === 'Enter' && editingId === blocklist.id) {
                      handleAddURL(blocklist.id);
                    }
                  }}
                />
                <button
                  onClick={() => {
                    setEditingId(blocklist.id);
                    handleAddURL(blocklist.id);
                  }}
                  className="bg-blue-600 hover:bg-blue-500 text-white px-4 py-2 rounded-lg transition-all text-sm"
                >
                  Hinzufügen
                </button>
              </div>
            </div>
          </div>
        ))}

        {localBlocklists.length === 0 && (
          <div className={`${GLASS_EFFECTS.card.base} rounded-2xl p-8 text-center`}>
            <Shield size={48} className="text-white/20 mx-auto mb-4" />
            <p className="text-white/60 mb-4">Noch keine Blocklisten erstellt</p>
            <button
              onClick={() => setShowAddBlocklist(true)}
              className="bg-blue-600 hover:bg-blue-500 text-white px-6 py-3 rounded-xl transition-all"
            >
              Erste Blockliste erstellen
            </button>
          </div>
        )}
      </div>
    </div>
  );
};


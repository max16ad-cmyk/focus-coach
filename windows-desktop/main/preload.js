const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electronAPI', {
  // Blocking API
  blockApp: (appPath, appName) => ipcRenderer.invoke('block-app', appPath, appName),
  unblockApp: (appName) => ipcRenderer.invoke('unblock-app', appName),
  blockURL: (domain) => ipcRenderer.invoke('block-url', domain),
  unblockURL: (domain) => ipcRenderer.invoke('unblock-url', domain),
  getBlockedApps: () => ipcRenderer.invoke('get-blocked-apps'),
  
  // Activity logging
  logActivity: (activity) => ipcRenderer.invoke('log-activity', activity),
  
  // Admin rights check
  checkAdminRights: () => ipcRenderer.invoke('check-admin-rights'),
  
  // Platform info
  platform: process.platform,
  isWindows: process.platform === 'win32'
});




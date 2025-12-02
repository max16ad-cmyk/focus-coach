/**
 * Electron Service - Wrapper für Electron API
 * 
 * Bietet eine einheitliche Schnittstelle für Electron-Features
 * Funktioniert sowohl in Electron als auch im Browser (mit Fallbacks)
 */

// Type definitions for Electron API
declare global {
  interface Window {
    electronAPI?: {
      // Blocking API
      blockApp: (appPath: string, appName: string) => Promise<{ success: boolean; error?: string }>;
      unblockApp: (appName: string) => Promise<{ success: boolean; error?: string }>;
      blockURL: (domain: string) => Promise<{ success: boolean; error?: string }>;
      unblockURL: (domain: string) => Promise<{ success: boolean; error?: string }>;
      getBlockedApps: () => Promise<{ success: boolean; apps?: string[]; error?: string }>;
      
      // Activity logging
      logActivity: (activity: {
        platform: string;
        event: string;
        data?: any;
      }) => Promise<{ success: boolean }>;
      
      // Admin rights check
      checkAdminRights: () => Promise<{ hasAdmin: boolean }>;
      
      // Platform info
      platform: string;
      isWindows: boolean;
    };
  }
}

export interface BlockingResult {
  success: boolean;
  error?: string;
}

export interface BlockedAppsResult {
  success: boolean;
  apps?: string[];
  error?: string;
}

export interface AdminRightsResult {
  hasAdmin: boolean;
}

/**
 * Electron Service
 * 
 * Wrapper für Electron API mit Fallbacks für Browser-Umgebung
 */
export const electronService = {
  /**
   * Check if running in Electron
   */
  get isElectron(): boolean {
    return typeof window !== 'undefined' && !!window.electronAPI;
  },

  /**
   * Check if running on Windows
   */
  get isWindows(): boolean {
    if (!this.isElectron) return false;
    return window.electronAPI?.isWindows || false;
  },

  /**
   * Get platform name
   */
  get platform(): string {
    if (!this.isElectron) return 'web';
    return window.electronAPI?.platform || 'web';
  },

  /**
   * Block an app using Windows Firewall
   */
  async blockApp(appPath: string, appName: string): Promise<BlockingResult> {
    if (!this.isElectron || !window.electronAPI) {
      console.warn('Electron API not available - blocking skipped');
      return { success: false, error: 'Not running in Electron' };
    }

    try {
      return await window.electronAPI.blockApp(appPath, appName);
    } catch (error) {
      console.error('Error blocking app:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' };
    }
  },

  /**
   * Unblock an app
   */
  async unblockApp(appName: string): Promise<BlockingResult> {
    if (!this.isElectron || !window.electronAPI) {
      return { success: false, error: 'Not running in Electron' };
    }

    try {
      return await window.electronAPI.unblockApp(appName);
    } catch (error) {
      console.error('Error unblocking app:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' };
    }
  },

  /**
   * Block a URL/domain using Hosts file
   */
  async blockURL(domain: string): Promise<BlockingResult> {
    if (!this.isElectron || !window.electronAPI) {
      return { success: false, error: 'Not running in Electron' };
    }

    try {
      return await window.electronAPI.blockURL(domain);
    } catch (error) {
      console.error('Error blocking URL:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' };
    }
  },

  /**
   * Unblock a URL
   */
  async unblockURL(domain: string): Promise<BlockingResult> {
    if (!this.isElectron || !window.electronAPI) {
      return { success: false, error: 'Not running in Electron' };
    }

    try {
      return await window.electronAPI.unblockURL(domain);
    } catch (error) {
      console.error('Error unblocking URL:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' };
    }
  },

  /**
   * Get list of currently blocked apps
   */
  async getBlockedApps(): Promise<BlockedAppsResult> {
    if (!this.isElectron || !window.electronAPI) {
      return { success: false, apps: [], error: 'Not running in Electron' };
    }

    try {
      return await window.electronAPI.getBlockedApps();
    } catch (error) {
      console.error('Error getting blocked apps:', error);
      return { success: false, apps: [], error: error instanceof Error ? error.message : 'Unknown error' };
    }
  },

  /**
   * Check if app has admin rights
   */
  async checkAdminRights(): Promise<AdminRightsResult> {
    if (!this.isElectron || !window.electronAPI) {
      return { hasAdmin: false };
    }

    try {
      return await window.electronAPI.checkAdminRights();
    } catch (error) {
      console.error('Error checking admin rights:', error);
      return { hasAdmin: false };
    }
  },

  /**
   * Log activity to analytics
   */
  async logActivity(activity: {
    platform: string;
    event: string;
    data?: any;
  }): Promise<{ success: boolean }> {
    if (!this.isElectron || !window.electronAPI) {
      // Fallback: Log to console in browser
      console.log('Activity logged (browser):', activity);
      return { success: true };
    }

    try {
      return await window.electronAPI.logActivity(activity);
    } catch (error) {
      console.error('Error logging activity:', error);
      return { success: false };
    }
  },
};


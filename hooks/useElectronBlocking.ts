import { useState, useEffect, useCallback } from 'react';
import { electronService } from '../services/electronService';

export interface Blocklist {
  id: string;
  name: string;
  apps: string[]; // App paths or names
  urls: string[]; // Domains to block
}

export interface BlockingState {
  isBlocking: boolean;
  blockedApps: string[];
  blockedURLs: string[];
  hasAdminRights: boolean;
  error: string | null;
}

/**
 * Hook for managing Electron-based blocking
 * 
 * Provides functions to block/unblock apps and URLs,
 * and automatically manages blocking state
 */
export function useElectronBlocking() {
  const [state, setState] = useState<BlockingState>({
    isBlocking: false,
    blockedApps: [],
    blockedURLs: [],
    hasAdminRights: false,
    error: null,
  });

  // Check admin rights on mount
  useEffect(() => {
    if (electronService.isElectron && electronService.isWindows) {
      checkAdminRights();
      loadBlockedItems();
    }
  }, []);

  /**
   * Check if app has admin rights
   */
  const checkAdminRights = useCallback(async () => {
    const result = await electronService.checkAdminRights();
    setState(prev => ({ ...prev, hasAdminRights: result.hasAdmin }));
  }, []);

  /**
   * Load currently blocked apps and URLs
   */
  const loadBlockedItems = useCallback(async () => {
    if (!electronService.isElectron) return;

    const appsResult = await electronService.getBlockedApps();
    if (appsResult.success && appsResult.apps) {
      setState(prev => ({ ...prev, blockedApps: appsResult.apps || [] }));
    }
  }, []);

  /**
   * Block multiple apps
   */
  const blockApps = useCallback(async (apps: Array<{ path: string; name: string }>) => {
    if (!electronService.isElectron || !electronService.isWindows) {
      setState(prev => ({ ...prev, error: 'Not running on Windows' }));
      return { success: false };
    }

    setState(prev => ({ ...prev, error: null, isBlocking: true }));

    const results = await Promise.all(
      apps.map(app => electronService.blockApp(app.path, app.name))
    );

    const failed = results.filter(r => !r.success);
    if (failed.length > 0) {
      setState(prev => ({
        ...prev,
        error: `Failed to block ${failed.length} app(s)`,
        isBlocking: false,
      }));
      return { success: false, error: failed[0].error };
    }

    // Reload blocked apps
    await loadBlockedItems();

    setState(prev => ({ ...prev, isBlocking: false }));
    return { success: true };
  }, [loadBlockedItems]);

  /**
   * Unblock multiple apps
   */
  const unblockApps = useCallback(async (appNames: string[]) => {
    if (!electronService.isElectron) {
      return { success: false };
    }

    setState(prev => ({ ...prev, error: null }));

    const results = await Promise.all(
      appNames.map(name => electronService.unblockApp(name))
    );

    const failed = results.filter(r => !r.success);
    if (failed.length > 0) {
      setState(prev => ({
        ...prev,
        error: `Failed to unblock ${failed.length} app(s)`,
      }));
      return { success: false };
    }

    // Reload blocked apps
    await loadBlockedItems();

    return { success: true };
  }, [loadBlockedItems]);

  /**
   * Block multiple URLs
   */
  const blockURLs = useCallback(async (domains: string[]) => {
    if (!electronService.isElectron || !electronService.isWindows) {
      setState(prev => ({ ...prev, error: 'Not running on Windows' }));
      return { success: false };
    }

    setState(prev => ({ ...prev, error: null, isBlocking: true }));

    const results = await Promise.all(
      domains.map(domain => electronService.blockURL(domain))
    );

    const failed = results.filter(r => !r.success);
    if (failed.length > 0) {
      setState(prev => ({
        ...prev,
        error: `Failed to block ${failed.length} URL(s)`,
        isBlocking: false,
      }));
      return { success: false, error: failed[0].error };
    }

    setState(prev => ({
      ...prev,
      blockedURLs: [...prev.blockedURLs, ...domains],
      isBlocking: false,
    }));

    return { success: true };
  }, []);

  /**
   * Unblock multiple URLs
   */
  const unblockURLs = useCallback(async (domains: string[]) => {
    if (!electronService.isElectron) {
      return { success: false };
    }

    setState(prev => ({ ...prev, error: null }));

    const results = await Promise.all(
      domains.map(domain => electronService.unblockURL(domain))
    );

    const failed = results.filter(r => !r.success);
    if (failed.length > 0) {
      setState(prev => ({
        ...prev,
        error: `Failed to unblock ${failed.length} URL(s)`,
      }));
      return { success: false };
    }

    setState(prev => ({
      ...prev,
      blockedURLs: prev.blockedURLs.filter(url => !domains.includes(url)),
    }));

    return { success: true };
  }, []);

  /**
   * Apply a blocklist (block all apps and URLs in it)
   */
  const applyBlocklist = useCallback(async (blocklist: Blocklist) => {
    const appResults = await blockApps(
      blocklist.apps.map(app => ({ path: app, name: app.split('\\').pop() || app }))
    );
    const urlResults = await blockURLs(blocklist.urls);

    return {
      success: appResults.success && urlResults.success,
      appsBlocked: appResults.success,
      urlsBlocked: urlResults.success,
    };
  }, [blockApps, blockURLs]);

  /**
   * Clear all blocks
   */
  const clearAllBlocks = useCallback(async () => {
    if (!electronService.isElectron) return { success: false };

    const appsResult = await unblockApps(state.blockedApps);
    const urlsResult = await unblockURLs(state.blockedURLs);

    setState(prev => ({
      ...prev,
      blockedApps: [],
      blockedURLs: [],
      isBlocking: false,
    }));

    return {
      success: appsResult.success && urlsResult.success,
    };
  }, [state.blockedApps, state.blockedURLs, unblockApps, unblockURLs]);

  return {
    ...state,
    blockApps,
    unblockApps,
    blockURLs,
    unblockURLs,
    applyBlocklist,
    clearAllBlocks,
    checkAdminRights,
    loadBlockedItems,
    isElectron: electronService.isElectron,
    isWindows: electronService.isWindows,
  };
}


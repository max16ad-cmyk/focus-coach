import { useEffect, useCallback } from 'react';
import { Task, Blocklist } from '../types';
import { useElectronBlocking } from './useElectronBlocking';
import { electronService } from '../services/electronService';

interface UseTaskBlockingOptions {
  currentTask: Task | null;
  blocklists: Blocklist[];
  settings: { defaultBlocklistId?: string };
}

/**
 * Hook for automatic task-based blocking
 * 
 * Automatically blocks apps/URLs when a task starts
 * and unblocks them when the task ends
 */
export function useTaskBlocking({
  currentTask,
  blocklists,
  settings,
}: UseTaskBlockingOptions) {
  const blocking = useElectronBlocking();

  /**
   * Get blocklist for current task
   */
  const getTaskBlocklist = useCallback((): Blocklist | null => {
    if (!currentTask) return null;

    // Use task-specific blocklist if set
    if (currentTask.blocklistId) {
      const blocklist = blocklists.find(b => b.id === currentTask.blocklistId);
      if (blocklist) return blocklist;
    }

    // Fallback to default blocklist
    if (settings.defaultBlocklistId) {
      const blocklist = blocklists.find(b => b.id === settings.defaultBlocklistId);
      if (blocklist) return blocklist;
    }

    return null;
  }, [currentTask, blocklists, settings]);

  /**
   * Check if task is currently active based on time
   */
  const isTaskActive = useCallback((task: Task | null): boolean => {
    if (!task || task.completed) return false;
    if (!task.suggestedStartTime || !task.suggestedEndTime) return false;

    const now = new Date();
    const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;

    return currentTime >= task.suggestedStartTime && currentTime <= task.suggestedEndTime;
  }, []);

  /**
   * Apply blocking for a task
   */
  const applyTaskBlocking = useCallback(async (task: Task, blocklist: Blocklist) => {
    if (!electronService.isElectron || !electronService.isWindows) {
      return { success: false, error: 'Not running on Windows' };
    }

    // Block apps
    if (blocklist.apps.length > 0) {
      const appResults = await blocking.blockApps(
        blocklist.apps.map(app => ({
          path: app,
          name: app.split('\\').pop() || app.split('/').pop() || app,
        }))
      );
      if (!appResults.success) {
        console.error('Failed to block apps:', appResults);
      }
    }

    // Block URLs
    if (blocklist.urls.length > 0) {
      const urlResults = await blocking.blockURLs(blocklist.urls);
      if (!urlResults.success) {
        console.error('Failed to block URLs:', urlResults);
      }
    }

    // Log activity
    await electronService.logActivity({
      platform: 'windows',
      event: 'task_blocking_started',
      data: {
        taskId: task.id,
        taskTitle: task.title,
        blocklistId: blocklist.id,
        appsCount: blocklist.apps.length,
        urlsCount: blocklist.urls.length,
      },
    });

    // Show notification
    await electronService.showNotification({
      title: 'Blockierung aktiviert',
      body: `Apps und Websites werden während "${task.title}" blockiert`,
      silent: false,
    });

    return { success: true };
  }, [blocking]);

  /**
   * Remove blocking for a task
   */
  const removeTaskBlocking = useCallback(async (task: Task, blocklist: Blocklist) => {
    if (!electronService.isElectron) {
      return { success: false };
    }

    // Unblock apps
    if (blocklist.apps.length > 0) {
      const appNames = blocklist.apps.map(app => 
        app.split('\\').pop() || app.split('/').pop() || app
      );
      await blocking.unblockApps(appNames);
    }

    // Unblock URLs
    if (blocklist.urls.length > 0) {
      await blocking.unblockURLs(blocklist.urls);
    }

    // Log activity
    await electronService.logActivity({
      platform: 'windows',
      event: 'task_blocking_ended',
      data: {
        taskId: task.id,
        taskTitle: task.title,
        blocklistId: blocklist.id,
      },
    });

    // Show notification
    await electronService.showNotification({
      title: 'Blockierung beendet',
      body: `Blockierung für "${task.title}" wurde entfernt`,
      silent: false,
    });

    return { success: true };
  }, [blocking]);

  /**
   * Monitor task and apply/remove blocking automatically
   */
  useEffect(() => {
    if (!electronService.isElectron || !electronService.isWindows) {
      return;
    }

    const taskBlocklist = getTaskBlocklist();
    if (!currentTask || !taskBlocklist) {
      return;
    }

    const checkInterval = setInterval(() => {
      const active = isTaskActive(currentTask);

      if (active && currentTask.status === 'in_progress') {
        // Task is active - ensure blocking is applied
        applyTaskBlocking(currentTask, taskBlocklist).catch(err => {
          console.error('Error applying task blocking:', err);
        });
      } else if (!active || currentTask.completed) {
        // Task is not active or completed - remove blocking
        removeTaskBlocking(currentTask, taskBlocklist).catch(err => {
          console.error('Error removing task blocking:', err);
        });
      }
    }, 5000); // Check every 5 seconds

    return () => clearInterval(checkInterval);
  }, [currentTask, getTaskBlocklist, isTaskActive, applyTaskBlocking, removeTaskBlocking]);

  /**
   * Manually trigger blocking for current task
   */
  const triggerBlocking = useCallback(async () => {
    if (!currentTask) return { success: false };

    const blocklist = getTaskBlocklist();
    if (!blocklist) {
      return { success: false, error: 'No blocklist found for task' };
    }

    return await applyTaskBlocking(currentTask, blocklist);
  }, [currentTask, getTaskBlocklist, applyTaskBlocking]);

  /**
   * Manually remove blocking for current task
   */
  const triggerUnblocking = useCallback(async () => {
    if (!currentTask) return { success: false };

    const blocklist = getTaskBlocklist();
    if (!blocklist) {
      return { success: false, error: 'No blocklist found for task' };
    }

    return await removeTaskBlocking(currentTask, blocklist);
  }, [currentTask, getTaskBlocklist, removeTaskBlocking]);

  return {
    isBlocking: blocking.isBlocking,
    triggerBlocking,
    triggerUnblocking,
    currentBlocklist: getTaskBlocklist(),
    isTaskActive: isTaskActive(currentTask),
  };
}


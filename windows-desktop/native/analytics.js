const { logActivity } = require('../../services/analytics');

/**
 * Windows-specific analytics logging
 * Integrates with Firebase Analytics Service
 */

class WindowsAnalytics {
    constructor() {
        this.platform = 'windows';
    }

    /**
     * Log app blocking event
     */
    async logAppBlocked(appName, appPath, duration = 0) {
        if (typeof window !== 'undefined' && window.electronAPI) {
            // Running in Electron renderer
            await window.electronAPI.logActivity({
                platform: this.platform,
                event: 'app_blocked',
                data: {
                    appName,
                    appPath,
                    duration
                }
            });
        } else {
            // Running in web context
            const { logActivity } = require('../../services/analytics');
            const userId = getCurrentUserId(); // Get from Firebase auth
            if (userId) {
                await logActivity(userId, this.platform, 'app_blocked', {
                    appName,
                    appPath,
                    duration
                });
            }
        }
    }

    /**
     * Log app unblocking event
     */
    async logAppUnblocked(appName) {
        if (typeof window !== 'undefined' && window.electronAPI) {
            await window.electronAPI.logActivity({
                platform: this.platform,
                event: 'app_unblocked',
                data: { appName }
            });
        }
    }

    /**
     * Log URL blocking event
     */
    async logURLBlocked(domain) {
        if (typeof window !== 'undefined' && window.electronAPI) {
            await window.electronAPI.logActivity({
                platform: this.platform,
                event: 'url_blocked',
                data: { domain }
            });
        }
    }

    /**
     * Log URL unblocking event
     */
    async logURLUnblocked(domain) {
        if (typeof window !== 'undefined' && window.electronAPI) {
            await window.electronAPI.logActivity({
                platform: this.platform,
                event: 'url_unblocked',
                data: { domain }
            });
        }
    }

    /**
     * Log task completion
     */
    async logTaskCompleted(taskId, taskTitle, duration = 0) {
        if (typeof window !== 'undefined' && window.electronAPI) {
            await window.electronAPI.logActivity({
                platform: this.platform,
                event: 'task_completed',
                data: {
                    taskId,
                    taskTitle,
                    duration
                }
            });
        }
    }
}

module.exports = {
    WindowsAnalytics: new WindowsAnalytics()
};





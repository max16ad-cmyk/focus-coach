const { exec } = require('child_process');
const fs = require('fs').promises;
const path = require('path');
const { WindowsAnalytics } = require('../analytics');

/**
 * Windows Firewall Blocking Service
 * Blocks apps and URLs using Windows Firewall and Hosts file
 */
class WindowsFirewallBlocker {
  constructor() {
    this.hostsPath = 'C:\\Windows\\System32\\drivers\\etc\\hosts';
    this.blockedApps = new Set();
    this.blockedURLs = new Set();
  }

  /**
   * Block an app using Windows Firewall
   * @param {string} appPath - Full path to the executable
   * @param {string} appName - Name of the app (for rule name)
   */
  async blockApp(appPath, appName) {
    return new Promise((resolve, reject) => {
      const ruleName = `FocusCoach-Block-${appName.replace(/[^a-zA-Z0-9]/g, '-')}`;
      
      // Check if rule already exists
      const checkCommand = `netsh advfirewall firewall show rule name="${ruleName}"`;
      
      exec(checkCommand, (error) => {
        if (!error) {
          // Rule already exists
          console.log(`Rule ${ruleName} already exists`);
          this.blockedApps.add(appName);
          resolve();
          return;
        }

        // Create new firewall rule
        const command = `netsh advfirewall firewall add rule name="${ruleName}" dir=out action=block program="${appPath}" enable=yes`;
        
        exec(command, { shell: true }, (err, stdout, stderr) => {
          if (err) {
            console.error(`Error blocking app ${appName}:`, err);
            reject(new Error(`Failed to block app: ${err.message}`));
            return;
          }
          
          console.log(`Successfully blocked app: ${appName}`);
          this.blockedApps.add(appName);
          
          // Log analytics
          WindowsAnalytics.logAppBlocked(appName, appPath, 0).catch(err => {
            console.error('Error logging analytics:', err);
          });
          
          resolve();
        });
      });
    });
  }

  /**
   * Unblock an app by removing the firewall rule
   * @param {string} appName - Name of the app
   */
  async unblockApp(appName) {
    return new Promise((resolve, reject) => {
      const ruleName = `FocusCoach-Block-${appName.replace(/[^a-zA-Z0-9]/g, '-')}`;
      const command = `netsh advfirewall firewall delete rule name="${ruleName}"`;
      
      exec(command, { shell: true }, (err, stdout, stderr) => {
        if (err) {
          // Rule might not exist, which is okay
          console.log(`Rule ${ruleName} not found or already deleted`);
        }
        
        this.blockedApps.delete(appName);
        resolve();
      });
    });
  }

  /**
   * Block a URL/domain using the Hosts file
   * @param {string} domain - Domain to block (e.g., "instagram.com")
   */
  async blockURL(domain) {
    try {
      // Read current hosts file
      let hostsContent = await fs.readFile(this.hostsPath, 'utf8');
      
      // Check if domain is already blocked
      const blockEntry = `127.0.0.1 ${domain}`;
      const wwwEntry = `127.0.0.1 www.${domain}`;
      
      if (hostsContent.includes(blockEntry)) {
        console.log(`Domain ${domain} is already blocked`);
        this.blockedURLs.add(domain);
        return;
      }

      // Add FocusCoach marker if not present
      if (!hostsContent.includes('# FocusCoach Blocking')) {
        hostsContent += '\n# FocusCoach Blocking\n';
      }

      // Add domain entries
      hostsContent += `${blockEntry}\n`;
      hostsContent += `${wwwEntry}\n`;

      // Write back to hosts file
      await fs.writeFile(this.hostsPath, hostsContent, 'utf8');
      
      console.log(`Successfully blocked URL: ${domain}`);
      this.blockedURLs.add(domain);
      
      // Log analytics
      WindowsAnalytics.logURLBlocked(domain).catch(err => {
        console.error('Error logging analytics:', err);
      });
    } catch (error) {
      console.error(`Error blocking URL ${domain}:`, error);
      throw new Error(`Failed to block URL: ${error.message}. Make sure the app is running with administrator rights.`);
    }
  }

  /**
   * Unblock a URL by removing it from the Hosts file
   * @param {string} domain - Domain to unblock
   */
  async unblockURL(domain) {
    try {
      // Read current hosts file
      let hostsContent = await fs.readFile(this.hostsPath, 'utf8');
      
      // Remove domain entries
      const blockEntry = `127.0.0.1 ${domain}`;
      const wwwEntry = `127.0.0.1 www.${domain}`;
      
      hostsContent = hostsContent
        .split('\n')
        .filter(line => !line.includes(blockEntry) && !line.includes(wwwEntry))
        .join('\n');

      // Write back to hosts file
      await fs.writeFile(this.hostsPath, hostsContent, 'utf8');
      
      console.log(`Successfully unblocked URL: ${domain}`);
      this.blockedURLs.delete(domain);
    } catch (error) {
      console.error(`Error unblocking URL ${domain}:`, error);
      throw new Error(`Failed to unblock URL: ${error.message}`);
    }
  }

  /**
   * Get list of currently blocked apps
   * @returns {Promise<string[]>}
   */
  async getBlockedApps() {
    return new Promise((resolve, reject) => {
      const command = 'netsh advfirewall firewall show rule name=all | findstr "FocusCoach-Block"';
      
      exec(command, { shell: true }, (err, stdout) => {
        if (err) {
          resolve([]);
          return;
        }

        const rules = stdout
          .split('\n')
          .filter(line => line.includes('FocusCoach-Block'))
          .map(line => {
            const match = line.match(/FocusCoach-Block-(.+)/);
            return match ? match[1].replace(/-/g, ' ') : null;
          })
          .filter(Boolean);

        resolve(rules);
      });
    });
  }

  /**
   * Get list of currently blocked URLs
   * @returns {Promise<string[]>}
   */
  async getBlockedURLs() {
    try {
      const hostsContent = await fs.readFile(this.hostsPath, 'utf8');
      const lines = hostsContent.split('\n');
      
      const blocked = [];
      let inFocusCoachSection = false;

      for (const line of lines) {
        if (line.includes('# FocusCoach Blocking')) {
          inFocusCoachSection = true;
          continue;
        }

        if (inFocusCoachSection && line.trim().startsWith('127.0.0.1')) {
          const domain = line.trim().replace('127.0.0.1', '').trim();
          if (domain && !domain.startsWith('www.')) {
            blocked.push(domain);
          }
        }

        if (inFocusCoachSection && line.trim() === '' && blocked.length > 0) {
          break;
        }
      }

      return blocked;
    } catch (error) {
      console.error('Error reading blocked URLs:', error);
      return [];
    }
  }

  /**
   * Clear all FocusCoach blocks
   */
  async clearAllBlocks() {
    // Unblock all apps
    const apps = await this.getBlockedApps();
    for (const app of apps) {
      await this.unblockApp(app);
    }

    // Unblock all URLs
    const urls = await this.getBlockedURLs();
    for (const url of urls) {
      await this.unblockURL(url);
    }
  }
}

module.exports = {
  WindowsFirewallBlocker: new WindowsFirewallBlocker()
};


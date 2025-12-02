const { app, BrowserWindow, ipcMain, Tray, Menu, nativeImage, shell, Notification } = require('electron');
const path = require('path');
const { autoUpdater } = require('electron-updater');
const { WindowsFirewallBlocker } = require('../native/blocking/firewall');

// Keep a global reference of the window object
let mainWindow = null;
let tray = null;
let isQuitting = false;

// Check if we're in development
const isDev = process.env.NODE_ENV === 'development' || !app.isPackaged;

// App URL (development or production)
const appURL = isDev 
  ? 'http://localhost:3000' 
  : `file://${path.join(__dirname, '../../dist/index.html')}`;

function createWindow() {
  // Create the browser window
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    backgroundColor: '#0a0a0a',
    icon: path.join(__dirname, '../assets/icon.png'),
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false,
      preload: path.join(__dirname, 'preload.js')
    },
    show: false, // Don't show until ready
    titleBarStyle: 'default',
    frame: true
  });

  // Load the app
  mainWindow.loadURL(appURL);

  // Show window when ready
  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
    
    // Focus window
    if (isDev) {
      mainWindow.webContents.openDevTools();
    }
  });

  // Handle window closed
  mainWindow.on('closed', () => {
    mainWindow = null;
  });

  // Handle external links
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });
}

function createTray() {
  // Create system tray icon
  const iconPath = path.join(__dirname, '../assets/icon.png');
  const trayIcon = nativeImage.createFromPath(iconPath);
  
  tray = new Tray(trayIcon.resize({ width: 16, height: 16 }));
  
  const contextMenu = Menu.buildFromTemplate([
    {
      label: 'FocusCoach öffnen',
      click: () => {
        if (mainWindow) {
          mainWindow.show();
          mainWindow.focus();
        } else {
          createWindow();
        }
      }
    },
    {
      label: 'Blockierung aktivieren',
      type: 'checkbox',
      checked: false,
      click: (item) => {
        // Toggle blocking
        if (item.checked) {
          // Activate blocking
          ipcMain.emit('activate-blocking');
        } else {
          // Deactivate blocking
          ipcMain.emit('deactivate-blocking');
        }
      }
    },
    { type: 'separator' },
    {
      label: 'Beenden',
      click: () => {
        isQuitting = true;
        app.quit();
      }
    }
  ]);

  tray.setToolTip('FocusCoach');
  tray.setContextMenu(contextMenu);

  // Double-click to show window
  tray.on('double-click', () => {
    if (mainWindow) {
      mainWindow.show();
      mainWindow.focus();
    } else {
      createWindow();
    }
  });
}

// App event handlers
app.whenReady().then(() => {
  createWindow();
  createTray();

  // Auto-updater (only in production)
  if (!isDev) {
    autoUpdater.checkForUpdatesAndNotify();
  }

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    } else if (mainWindow) {
      mainWindow.show();
      mainWindow.focus();
    }
  });
});

app.on('window-all-closed', (e) => {
  // On macOS, keep app running even when all windows are closed
  // On Windows/Linux, quit when all windows are closed (unless we have a tray)
  if (process.platform !== 'darwin') {
    if (tray) {
      // Keep running in tray
      e.preventDefault();
    } else {
      app.quit();
    }
  }
});

app.on('before-quit', (e) => {
  if (!isQuitting) {
    e.preventDefault();
    if (mainWindow) {
      mainWindow.hide();
    }
  }
});

// IPC Handlers for blocking
ipcMain.handle('block-app', async (event, appPath, appName) => {
  try {
    await WindowsFirewallBlocker.blockApp(appPath, appName);
    return { success: true };
  } catch (error) {
    console.error('Error blocking app:', error);
    return { success: false, error: error.message };
  }
});

ipcMain.handle('unblock-app', async (event, appName) => {
  try {
    await WindowsFirewallBlocker.unblockApp(appName);
    return { success: true };
  } catch (error) {
    console.error('Error unblocking app:', error);
    return { success: false, error: error.message };
  }
});

ipcMain.handle('block-url', async (event, domain) => {
  try {
    await WindowsFirewallBlocker.blockURL(domain);
    return { success: true };
  } catch (error) {
    console.error('Error blocking URL:', error);
    return { success: false, error: error.message };
  }
});

ipcMain.handle('unblock-url', async (event, domain) => {
  try {
    await WindowsFirewallBlocker.unblockURL(domain);
    return { success: true };
  } catch (error) {
    console.error('Error unblocking URL:', error);
    return { success: false, error: error.message };
  }
});

ipcMain.handle('get-blocked-apps', async () => {
  try {
    const apps = await WindowsFirewallBlocker.getBlockedApps();
    return { success: true, apps };
  } catch (error) {
    console.error('Error getting blocked apps:', error);
    return { success: false, error: error.message };
  }
});

// Log activity to Firebase
ipcMain.handle('log-activity', async (event, activity) => {
  // This will be handled by the renderer process (React app)
  // which has access to Firebase
  return { success: true };
});

// Check admin rights
ipcMain.handle('check-admin-rights', async () => {
  try {
    const { exec } = require('child_process');
    return new Promise((resolve) => {
      exec('net session', (error) => {
        resolve({ hasAdmin: !error });
      });
    });
  } catch (error) {
    return { hasAdmin: false };
  }
});

// Show notification
ipcMain.handle('show-notification', async (event, { title, body, silent = false }) => {
  if (!Notification.isSupported()) {
    return { success: false, error: 'Notifications not supported' };
  }

  try {
    const notification = new Notification({
      title: title || 'FocusCoach',
      body: body || '',
      silent: silent,
      icon: path.join(__dirname, '../assets/icon.png'),
    });

    notification.show();
    return { success: true };
  } catch (error) {
    console.error('Error showing notification:', error);
    return { success: false, error: error.message };
  }
});

// Get installed apps (Windows Registry)
ipcMain.handle('get-installed-apps', async () => {
  try {
    const { exec } = require('child_process');
    const { promisify } = require('util');
    const execAsync = promisify(exec);

    // Read from Windows Registry
    const command = `reg query "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" /s /v DisplayName 2>nul | findstr /i "DisplayName"`;
    
    const { stdout } = await execAsync(command, { shell: true, maxBuffer: 10 * 1024 * 1024 });
    
    const apps: Array<{ name: string; path?: string }> = [];
    const lines = stdout.split('\n').filter(line => line.trim());
    
    for (const line of lines) {
      const match = line.match(/DisplayName\s+REG_SZ\s+(.+)/i);
      if (match && match[1]) {
        apps.push({ name: match[1].trim() });
      }
    }

    // Also check common app locations
    const commonPaths = [
      'C:\\Program Files',
      'C:\\Program Files (x86)',
      process.env.LOCALAPPDATA + '\\Programs',
    ];

    return { success: true, apps: apps.slice(0, 100) }; // Limit to 100 apps
  } catch (error) {
    console.error('Error getting installed apps:', error);
    return { success: false, apps: [], error: error.message };
  }
});





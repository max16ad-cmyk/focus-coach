import { Distraction, Task, UserStats } from "./types";

export const INITIAL_TASKS: Task[] = [
  { id: '1', title: 'Review project requirements', completed: false },
  { id: '2', title: 'Drink 500ml water', completed: false },
];

export const INITIAL_DISTRACTIONS: Distraction[] = [
  { id: '1', name: 'Social Media', url: 'https://instagram.com', icon: '📸', category: 'social' },
  { id: '2', name: 'News Feed', url: 'https://news.google.com', icon: '📰', category: 'news' },
  { id: '3', name: 'Video Streaming', url: 'https://youtube.com', icon: '📺', category: 'video' },
  { id: '4', name: 'Gaming', url: 'https://twitch.tv', icon: '🎮', category: 'game' },
];

export const INITIAL_STATS: UserStats = {
  xp: 0,
  level: 1,
  streak: 1,
  tasksCompleted: 0,
  penalties: 0
};

export const LEVEL_THRESHOLDS = [0, 100, 300, 600, 1000, 2000, 5000];

// =============================================
// LAYOUT SYSTEM - RESPONSIVE CONSTANTS
// =============================================

/**
 * Zentrale Layout-Konstanten für konsistentes Responsive Design
 * Verwendung: <div className={LAYOUT.container.wide}>
 */
export const LAYOUT = {
  // Container Widths
  container: {
    narrow: 'max-w-xl lg:max-w-2xl mx-auto',      // Schmale Inhalte (Formulare, Login)
    medium: 'max-w-2xl lg:max-w-4xl mx-auto',     // Mittlere Inhalte (Settings, Modals)
    wide: 'max-w-2xl lg:max-w-6xl mx-auto',       // Breite Inhalte (Dashboards)
    full: 'max-w-2xl lg:max-w-7xl mx-auto',       // Maximale Breite (Main Content)
  },
  
  // Padding
  padding: {
    none: '',
    small: 'p-4',
    medium: 'p-4 sm:p-6',
    large: 'p-4 sm:p-6 lg:p-12',
  },
  
  // Spacing
  spacing: {
    section: 'space-y-6',
    items: 'space-y-4',
    tight: 'space-y-2',
  },
  
  // Grid Layouts
  grid: {
    twoCol: 'space-y-4 lg:grid lg:grid-cols-2 lg:gap-4 lg:space-y-0',
    threeCol: 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4',
    fourCol: 'grid grid-cols-2 lg:grid-cols-4 gap-4',
  },
  
  // Common Patterns
  centerContent: 'flex items-center justify-center min-h-[80vh]',
  fullHeight: 'h-full',
  scrollable: 'overflow-y-auto',
};
// =============================================
// FOCUS COACH THEME SYSTEM
// =============================================

/**
 * Zentrales Theme-System für konsistente Farben und Styles
 * Macht Rebranding und Dark Mode einfach
 */

// =============================================
// COLORS
// =============================================

export const COLORS = {
  // Primary Brand Colors
  primary: {
    DEFAULT: 'blue-600',
    hover: 'blue-500',
    light: 'blue-400',
    dark: 'blue-800',
    bg: 'blue-950/30',
  },
  
  // Background Colors
  background: {
    main: 'slate-950',
    elevated: 'slate-900',
    card: 'slate-900/50',
    hover: 'slate-800',
  },
  
  // Border Colors
  border: {
    DEFAULT: 'slate-800',
    light: 'slate-700',
    dark: 'slate-900',
  },
  
  // Text Colors
  text: {
    primary: 'white',
    secondary: 'slate-300',
    muted: 'slate-400',
    disabled: 'slate-500',
  },
  
  // Status Colors
  status: {
    success: {
      DEFAULT: 'green-500',
      light: 'green-400',
      dark: 'green-600',
      bg: 'green-950/30',
    },
    warning: {
      DEFAULT: 'amber-500',
      light: 'amber-400',
      dark: 'amber-600',
      bg: 'amber-950/30',
    },
    error: {
      DEFAULT: 'red-500',
      light: 'red-400',
      dark: 'red-600',
      bg: 'red-950/30',
    },
    info: {
      DEFAULT: 'blue-500',
      light: 'blue-400',
      dark: 'blue-600',
      bg: 'blue-950/30',
    },
  },
};

// =============================================
// COACH PERSONALITIES
// =============================================

export const COACH_STYLES = {
  sergeant: {
    border: 'border-red-800/50',
    bg: 'bg-red-950/20',
    text: 'text-red-400',
    accent: 'red-500',
  },
  professor: {
    border: 'border-blue-800/50',
    bg: 'bg-blue-950/20',
    text: 'text-blue-400',
    accent: 'blue-500',
  },
  mentor: {
    border: 'border-green-800/50',
    bg: 'bg-green-950/20',
    text: 'text-green-400',
    accent: 'green-500',
  },
  minimalist: {
    border: 'border-slate-800',
    bg: 'bg-slate-900/50',
    text: 'text-slate-300',
    accent: 'slate-500',
  },
} as const;

// =============================================
// TASK CATEGORIES
// =============================================

export const CATEGORY_STYLES = {
  Lernen: {
    bg: 'bg-blue-900/50',
    text: 'text-blue-400',
    border: 'border-blue-800',
    icon: '📚',
  },
  Haushalt: {
    bg: 'bg-green-900/50',
    text: 'text-green-400',
    border: 'border-green-800',
    icon: '🏠',
  },
  Erledigung: {
    bg: 'bg-purple-900/50',
    text: 'text-purple-400',
    border: 'border-purple-800',
    icon: '🛒',
  },
  Arbeit: {
    bg: 'bg-orange-900/50',
    text: 'text-orange-400',
    border: 'border-orange-800',
    icon: '💼',
  },
  Sport: {
    bg: 'bg-red-900/50',
    text: 'text-red-400',
    border: 'border-red-800',
    icon: '🏃',
  },
  Kreativ: {
    bg: 'bg-pink-900/50',
    text: 'text-pink-400',
    border: 'border-pink-800',
    icon: '🎨',
  },
} as const;

// =============================================
// TASK STATUS
// =============================================

export const STATUS_STYLES = {
  pending: {
    text: 'text-slate-400',
    label: 'Wartet',
  },
  in_progress: {
    text: 'text-blue-400',
    label: 'In Bearbeitung',
  },
  waiting_proof: {
    text: 'text-amber-400',
    label: 'Wartet auf Nachweis',
  },
  completed: {
    text: 'text-green-400',
    label: 'Erledigt',
  },
  skipped: {
    text: 'text-red-400',
    label: 'Übersprungen',
  },
} as const;

// =============================================
// COMPONENT STYLES (Reusable Classes)
// =============================================

export const COMPONENT_STYLES = {
  // Cards
  card: {
    base: 'bg-slate-900/50 border border-slate-800 rounded-xl',
    elevated: 'bg-slate-900 border border-slate-800 rounded-xl shadow-lg',
    interactive: 'bg-slate-900/50 border border-slate-800 rounded-xl hover:border-slate-700 transition-colors cursor-pointer',
  },
  
  // Buttons (Base classes, use with button variants)
  button: {
    base: 'font-semibold rounded-xl transition-colors disabled:opacity-50 disabled:cursor-not-allowed',
    size: {
      sm: 'py-2 px-4 text-sm',
      md: 'py-3 px-6 text-base',
      lg: 'py-4 px-8 text-lg',
    },
  },
  
  // Inputs
  input: {
    base: 'w-full bg-slate-800 border border-slate-700 rounded-xl p-4 text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 transition-colors',
    error: 'border-red-500 focus:border-red-400',
  },
  
  // Dividers
  divider: 'border-t border-slate-800',
  
  // Badges
  badge: {
    base: 'inline-flex items-center px-3 py-1 rounded-full text-xs font-medium',
  },
};

// =============================================
// HELPER FUNCTIONS
// =============================================

/**
 * Get coach-specific styles
 */
export const getCoachStyles = (personality: keyof typeof COACH_STYLES) => {
  return COACH_STYLES[personality];
};

/**
 * Get category-specific styles
 */
export const getCategoryStyles = (category: keyof typeof CATEGORY_STYLES) => {
  return CATEGORY_STYLES[category];
};

/**
 * Get status-specific styles
 */
export const getStatusStyles = (status: keyof typeof STATUS_STYLES) => {
  return STATUS_STYLES[status];
};

/**
 * Build className string from theme parts
 */
export const buildClassName = (...classes: (string | boolean | undefined | null)[]) => {
  return classes.filter(Boolean).join(' ');
};


// =============================================
// PREMIUM FINTECH-INSPIRED THEME
// Based on design analysis from provided screenshot
// =============================================

/**
 * Premium Dark Theme inspired by modern fintech applications
 * Features: Glassmorphism, Serif headlines, 3D effects, elegant spacing
 */

// =============================================
// COLORS - PREMIUM DARK PALETTE
// =============================================

export const PREMIUM_COLORS = {
  // Background - Almost Black
  background: {
    main: '#0a0a0a',        // Deep black
    elevated: '#141414',    // Slightly lighter
    card: '#1a1a1a',        // Card background
    glass: 'rgba(255, 255, 255, 0.05)', // Glassmorphism overlay
  },
  
  // Text - High Contrast
  text: {
    primary: '#ffffff',
    secondary: '#a8a8a8',
    muted: '#6b6b6b',
    accent: '#f5f5f5',
  },
  
  // Primary Brand - Similar to screenshot's blue card
  primary: {
    DEFAULT: '#7a94a8',
    light: '#8ea8ba',
    dark: '#5d7488',
    glass: 'rgba(122, 148, 168, 0.15)',
  },
  
  // Feature Cards - Matching the 3-card layout
  features: {
    blue: {
      bg: 'rgba(122, 148, 168, 0.2)',
      border: 'rgba(122, 148, 168, 0.3)',
      accent: '#7a94a8',
    },
    orange: {
      bg: 'rgba(196, 131, 95, 0.2)',
      border: 'rgba(196, 131, 95, 0.3)',
      accent: '#c4835f',
    },
    teal: {
      bg: 'rgba(74, 123, 143, 0.2)',
      border: 'rgba(74, 123, 143, 0.3)',
      accent: '#4a7b8f',
    },
    purple: {
      bg: 'rgba(138, 99, 168, 0.2)',
      border: 'rgba(138, 99, 168, 0.3)',
      accent: '#8a63a8',
    },
  },
  
  // Status Colors - Subtle and elegant
  status: {
    success: '#4ade80',
    warning: '#fbbf24',
    error: '#f87171',
    info: '#60a5fa',
  },
  
  // Borders & Dividers
  border: {
    DEFAULT: 'rgba(255, 255, 255, 0.08)',
    light: 'rgba(255, 255, 255, 0.05)',
    strong: 'rgba(255, 255, 255, 0.12)',
  },
};

// =============================================
// TYPOGRAPHY - SERIF HEADLINES
// =============================================

export const PREMIUM_TYPOGRAPHY = {
  // Headlines - Serif (elegant, authoritative)
  headline: {
    font: 'font-serif', // Will use system serif or custom (Playfair Display, Lora)
    size: {
      xl: 'text-5xl lg:text-6xl xl:text-7xl',  // "Track everything" size
      lg: 'text-4xl lg:text-5xl',              // Main headlines
      md: 'text-3xl lg:text-4xl',              // Section headlines
      sm: 'text-2xl lg:text-3xl',              // Sub-headlines
    },
    weight: 'font-normal',  // Serif looks elegant at normal weight
    italic: 'italic',       // Many headlines are italic in the design
  },
  
  // Body Text - Sans Serif (readable)
  body: {
    font: 'font-sans',
    size: {
      lg: 'text-lg',
      md: 'text-base',
      sm: 'text-sm',
      xs: 'text-xs',
    },
    weight: {
      normal: 'font-normal',
      medium: 'font-medium',
      semibold: 'font-semibold',
    },
  },
  
  // Labels - Uppercase, spaced
  label: {
    base: 'uppercase tracking-wider text-xs font-medium',
    color: 'text-white/60',
  },
};

// =============================================
// GLASSMORPHISM EFFECTS
// =============================================

export const GLASS_EFFECTS = {
  card: {
    base: 'backdrop-blur-xl bg-white/[0.03] border border-white/[0.08]',
    hover: 'hover:bg-white/[0.05] hover:border-white/[0.12] transition-all duration-300',
  },
  
  input: {
    base: 'backdrop-blur-md bg-white/[0.05] border border-white/[0.1] focus:border-white/[0.2] focus:bg-white/[0.08]',
  },
  
  button: {
    primary: 'backdrop-blur-md bg-white/[0.08] border border-white/[0.15] shadow-lg hover:shadow-blue-500/20 hover:border-blue-400/50 transition-all duration-300',
    secondary: 'backdrop-blur-md bg-transparent border border-white/[0.1] hover:bg-white/[0.05] transition-all duration-300',
  },
  
  modal: {
    backdrop: 'backdrop-blur-2xl bg-black/60',
    content: 'backdrop-blur-xl bg-white/[0.05] border border-white/[0.1]',
  },
};

// =============================================
// 3D EFFECTS & SHADOWS
// =============================================

export const DEPTH_EFFECTS = {
  // Subtle 3D card elevation
  card: {
    shadow: 'shadow-2xl shadow-black/20',
    transform: 'transform hover:translate-y-[-4px] transition-transform duration-300',
  },
  
  // Premium shadow for elevated elements
  elevated: {
    shadow: 'shadow-[0_20px_70px_rgba(0,0,0,0.4)]',
  },
  
  // Glow effect for accents
  glow: {
    blue: 'shadow-[0_0_40px_rgba(122,148,168,0.3)]',
    orange: 'shadow-[0_0_40px_rgba(196,131,95,0.3)]',
    teal: 'shadow-[0_0_40px_rgba(74,123,143,0.3)]',
  },
};

// =============================================
// LAYOUT - PREMIUM SPACING
// =============================================

export const PREMIUM_LAYOUT = {
  container: {
    narrow: 'max-w-2xl mx-auto',
    medium: 'max-w-4xl mx-auto',
    wide: 'max-w-6xl mx-auto',
    full: 'max-w-7xl mx-auto',
  },
  
  // Generous spacing like in the design
  spacing: {
    section: 'py-24 lg:py-32',      // Between major sections
    component: 'space-y-12',         // Between components
    items: 'space-y-6',              // Between items
    tight: 'space-y-3',              // Tight spacing
  },
  
  // Card layouts (like the 3-card feature section)
  grid: {
    features: 'grid grid-cols-1 lg:grid-cols-3 gap-6 lg:gap-8',
    twoCol: 'grid grid-cols-1 lg:grid-cols-2 gap-6 lg:gap-8',
  },
  
  padding: {
    card: 'p-8 lg:p-10',
    section: 'px-6 lg:px-12',
  },
};

// =============================================
// COMPONENT PRESETS - READY TO USE
// =============================================

export const PREMIUM_COMPONENTS = {
  // Hero Section (like "Own your wealth")
  hero: {
    container: 'relative min-h-screen flex items-center justify-center',
    background: 'absolute inset-0 bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900',
    overlay: 'absolute inset-0 bg-black/30',
    content: 'relative z-10 text-center space-y-8',
  },
  
  // Feature Card (like the 3 cards)
  featureCard: {
    base: `${GLASS_EFFECTS.card.base} ${GLASS_EFFECTS.card.hover} ${DEPTH_EFFECTS.card.shadow} rounded-3xl p-8 lg:p-10`,
    transform: DEPTH_EFFECTS.card.transform,
  },
  
  // Button (like "GET STARTED")
  button: {
    primary: 'bg-white text-black hover:bg-white/90 font-semibold py-4 px-8 rounded-full transition-all duration-200 shadow-lg hover:shadow-xl',
    secondary: `${GLASS_EFFECTS.card.base} text-white hover:bg-white/[0.08] font-medium py-4 px-8 rounded-full transition-all duration-200`,
  },
  
  // Input (like "Where am I overspending...")
  input: {
    base: `${GLASS_EFFECTS.input.base} rounded-full px-6 py-4 text-white placeholder-white/40 transition-all duration-200`,
  },
  
  // Task Card (glassmorphism style)
  taskCard: {
    base: `${GLASS_EFFECTS.card.base} ${GLASS_EFFECTS.card.hover} rounded-2xl p-6 border-l-4`,
    pending: 'border-l-blue-400/50',
    inProgress: 'border-l-orange-400/50',
    completed: 'border-l-green-400/50',
  },
};

// =============================================
// ANIMATIONS
// =============================================

export const PREMIUM_ANIMATIONS = {
  fadeIn: 'animate-in fade-in duration-500',
  slideUp: 'animate-in slide-in-from-bottom-4 duration-500',
  slideDown: 'animate-in slide-in-from-top-4 duration-500',
  scale: 'animate-in zoom-in-95 duration-300',
  
  // Smooth transitions
  transition: {
    fast: 'transition-all duration-150 ease-out',
    normal: 'transition-all duration-300 ease-out',
    slow: 'transition-all duration-500 ease-out',
  },
};

// =============================================
// HELPER FUNCTIONS
// =============================================

/**
 * Build glassmorphism card classes
 */
export const buildGlassCard = (accent?: 'blue' | 'orange' | 'teal' | 'purple') => {
  const base = PREMIUM_COMPONENTS.featureCard.base;
  
  if (!accent) return base;
  
  const accentBorder = PREMIUM_COLORS.features[accent].border;
  return `${base} border-[${accentBorder}]`;
};

/**
 * Build headline classes (serif, large, elegant)
 */
export const buildHeadline = (size: 'xl' | 'lg' | 'md' | 'sm' = 'lg', italic = true) => {
  return `${PREMIUM_TYPOGRAPHY.headline.font} ${PREMIUM_TYPOGRAPHY.headline.size[size]} ${PREMIUM_TYPOGRAPHY.headline.weight} ${italic ? PREMIUM_TYPOGRAPHY.headline.italic : ''} text-white`;
};

/**
 * Build body text classes
 */
export const buildBodyText = (size: 'lg' | 'md' | 'sm' | 'xs' = 'md', weight: 'normal' | 'medium' | 'semibold' = 'normal') => {
  return `${PREMIUM_TYPOGRAPHY.body.font} ${PREMIUM_TYPOGRAPHY.body.size[size]} ${PREMIUM_TYPOGRAPHY.body.weight[weight]} text-white/80`;
};


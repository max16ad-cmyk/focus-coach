// =============================================
// FOCUS COACH TYPES
// =============================================

export enum AppMode {
  MORNING_LOCK = 'MORNING_LOCK',
  PLAN_REVIEW = 'PLAN_REVIEW',
  ACTIVE_DAY = 'ACTIVE_DAY',
  VERIFICATION = 'VERIFICATION',
  FREEDOM_MODE = 'FREEDOM_MODE',
  NIGHT_MODE = 'NIGHT_MODE',
}

export type CoachPersonality = 'sergeant' | 'professor' | 'mentor' | 'minimalist';

export interface Task {
  id: string;
  title: string;
  completed: boolean;
  isAiGenerated?: boolean;
  verificationRequired?: boolean;
  // Focus Coach fields
  category?: TaskCategory;
  duration?: number; // in minutes
  requiresProof?: boolean;
  proofType?: 'photo' | 'document' | 'screenshot' | null;
  proofDescription?: string;
  suggestedStartTime?: string; // HH:mm format
  suggestedEndTime?: string; // HH:mm format
  status?: TaskStatus;
  proofImageUrl?: string;
  verified?: boolean;
  createdAt?: number;
}

export type TaskCategory = 'Lernen' | 'Haushalt' | 'Erledigung' | 'Arbeit' | 'Sport' | 'Kreativ';
export type TaskStatus = 'pending' | 'in_progress' | 'waiting_proof' | 'completed' | 'skipped';

export interface DayPlan {
  id: string;
  userId: string;
  date: string; // YYYY-MM-DD format
  tasks: Task[];
  createdAt: number;
  confirmed: boolean;
}

export interface Distraction {
  id: string;
  name: string;
  url: string;
  icon: string; // Emoji or URL
  category: 'social' | 'video' | 'news' | 'game' | 'other';
}

export interface UserStats {
  xp: number;
  level: number;
  streak: number;
  tasksCompleted: number;
  penalties: number;
}

export interface User {
  uid: string; // Firebase ID
  email: string;
  name: string;
}

export enum AppView {
  AUTH = 'AUTH',
  DASHBOARD = 'DASHBOARD',
}

export interface LinkAnalysisResult {
  isProductive: boolean;
  category: string;
  reason: string;
  suggestedName: string;
}

// Focus Coach Settings
export interface UserSettings {
  coachPersonality: CoachPersonality;
  nightModeStart: string; // "23:00"
  nightModeEnd: string;   // "06:00"
  blockedSites: string[];
  allowedSites: string[];
  requirePhotoProof: boolean;
  proofStrictness: 'low' | 'medium' | 'high';
  emergencyUnlockEnabled: boolean;
  emergencyUnlockDuration: number; // minutes
  emergencyUnlockCooldown: number; // hours
  nightModeEnabled: boolean;
  nightModeNoUnlock: boolean;
  // Morning Lock Settings
  morningLockEnabled: boolean;
  morningLockStart: string; // "06:00"
  morningLockEnd: string;   // "12:00"
}

// Task Analysis Result from AI
export interface TaskAnalysisResult {
  tasks: AnalyzedTask[];
  coachMessage: string;
}

export interface AnalyzedTask {
  id: string;
  title: string;
  category: TaskCategory;
  duration: number;
  requiresProof: boolean;
  proofType: 'photo' | 'document' | 'screenshot' | null;
  proofDescription: string;
  suggestedStartTime: string;
  suggestedEndTime: string;
}

// Verification Result
export interface VerificationResult {
  accepted: boolean;
  confidence: number;
  reason: string;
  detectedElements: string[];
  coachMessage: string;
}
import React, { useState } from 'react';
import { CoachPersonality, Task, DayPlan, UserSettings } from '../types';
import { MorningLock } from './modes/MorningLock';
import { SettingsScreen } from './SettingsScreen';
import { PhotoUpload } from './shared/PhotoUpload';
import { PremiumWelcome } from './PremiumWelcome';
import { PremiumTaskCard } from './PremiumTaskCard';
import { PremiumPlanReview } from './PremiumPlanReview';
import { PremiumActiveDay } from './PremiumActiveDay';
import { PremiumFreedomMode } from './PremiumFreedomMode';
import { PremiumVerification } from './PremiumVerification';
import { PremiumNightMode } from './PremiumNightMode';
import { PremiumAddTask } from './PremiumAddTask';
import { analyzeTasks, verifyProof } from '../services/geminiService';
import { saveDayPlan } from '../services/firebase';
import { LAYOUT } from './constants';
import { useModeManager, usePlanHandlers, useTaskHandlers, useTaskBlocking } from '../hooks';
import { 
  Calendar, 
  Settings, 
  Plus, 
  CheckCircle2, 
  Clock,
  Moon,
  Menu,
  X
} from 'lucide-react';

interface DashboardProps {
  user: { uid: string; email: string; name: string };
  settings: UserSettings;
  dayPlan: DayPlan | null;
  currentDate: string;
  onSettingsUpdate: (settings: UserSettings) => void;
  onDayPlanUpdate: (plan: DayPlan) => void;
}

type DashboardView = 'overview' | 'create-plan' | 'active-day' | 'verification' | 'freedom' | 'night';

export const Dashboard: React.FC<DashboardProps> = ({
  user,
  settings,
  dayPlan,
  currentDate,
  onSettingsUpdate,
  onDayPlanUpdate,
}) => {
  const [view, setView] = useState<DashboardView>('overview');
  const [showSettings, setShowSettings] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  
  // Plan creation state
  const [planInput, setPlanInput] = useState('');
  const [analyzedTasks, setAnalyzedTasks] = useState<any[]>([]);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  
  // Verification state
  const [verifyingTask, setVerifyingTask] = useState<Task | null>(null);
  const [proofImage, setProofImage] = useState<string | null>(null);
  const [verificationResult, setVerificationResult] = useState<any>(null);
  const [isVerifying, setIsVerifying] = useState(false);
  
  // Add task state
  const [showAddTask, setShowAddTask] = useState(false);
  const [isAddingTask, setIsAddingTask] = useState(false);

  // Check current mode
  const getCurrentMode = (): DashboardView => {
    const now = new Date();
    const hours = now.getHours();
    
    // Night mode check
    if (settings.nightModeEnabled) {
      const [startH] = settings.nightModeStart.split(':').map(Number);
      const [endH] = settings.nightModeEnd.split(':').map(Number);
      if (hours >= startH || hours < endH) {
        return 'night';
      }
    }

    if (!dayPlan) {
      return 'overview';
    }

    if (!dayPlan.confirmed) {
      return 'create-plan';
    }

    const allCompleted = dayPlan.tasks.every(t => t.completed);
    if (allCompleted) {
      return 'freedom';
    }

    return 'active-day';
  };

  const currentMode = getCurrentMode();
  const activeView = view === 'overview' ? currentMode : view;

  // Handle plan creation
  const handleCreatePlan = async () => {
    if (!planInput.trim()) return;
    
    setIsAnalyzing(true);
    try {
      const analysis = await analyzeTasks(planInput);
      setAnalyzedTasks(analysis.tasks);
      setView('create-plan');
    } catch (error) {
      console.error('Task analysis failed:', error);
    } finally {
      setIsAnalyzing(false);
    }
  };

  const handlePlanConfirm = async () => {
    const tasks: Task[] = analyzedTasks.map((at) => ({
      id: at.id,
      title: at.title,
      completed: false,
      category: at.category,
      duration: at.duration,
      requiresProof: at.requiresProof,
      proofType: at.proofType,
      proofDescription: at.proofDescription,
      suggestedStartTime: at.suggestedStartTime,
      suggestedEndTime: at.suggestedEndTime,
      status: 'pending',
      createdAt: Date.now(),
    }));

    const plan: DayPlan = {
      id: currentDate,
      userId: user.uid,
      date: currentDate,
      tasks,
      createdAt: Date.now(),
      confirmed: true,
    };

    await saveDayPlan(user.uid, plan);
    onDayPlanUpdate(plan);
    setView('overview');
    setPlanInput('');
    setAnalyzedTasks([]);
  };

  // Get current task
  const getCurrentTask = (): Task | null => {
    if (!dayPlan) return null;
    const now = new Date();
    const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
    
    return (
      dayPlan.tasks.find((task) => {
        if (task.completed) return false;
        if (!task.suggestedStartTime || !task.suggestedEndTime) return false;
        return currentTime >= task.suggestedStartTime && currentTime <= task.suggestedEndTime;
      }) || dayPlan.tasks.find((t) => !t.completed) || null
    );
  };

  const pendingTasks = dayPlan?.tasks.filter(t => !t.completed).length || 0;
  const completedTasks = dayPlan?.tasks.filter(t => t.completed).length || 0;
  const totalTasks = dayPlan?.tasks.length || 0;

  // Handle adding a new task
  const handleAddTask = async (taskDescription: string) => {
    if (!dayPlan) return;
    
    setIsAddingTask(true);
    try {
      // Analyze the new task with AI (falls back automatically if API fails)
      const analysis = await analyzeTasks(taskDescription);
      
      if (analysis.tasks.length > 0) {
        const newTask = analysis.tasks[0];
        
        // Add to existing plan
        const task: Task = {
          id: `task-${Date.now()}`,
          title: newTask.title,
          completed: false,
          category: newTask.category,
          duration: newTask.duration,
          requiresProof: newTask.requiresProof,
          proofType: newTask.proofType,
          proofDescription: newTask.proofDescription,
          suggestedStartTime: newTask.suggestedStartTime,
          suggestedEndTime: newTask.suggestedEndTime,
          status: 'pending',
          createdAt: Date.now(),
        };
        
        const updatedTasks = [...dayPlan.tasks, task];
        const updatedPlan: DayPlan = { ...dayPlan, tasks: updatedTasks };
        
        await saveDayPlan(user.uid, updatedPlan);
        onDayPlanUpdate(updatedPlan);
        setShowAddTask(false);
      } else {
        // Fallback: Create simple task if analysis returned no tasks
        const task: Task = {
          id: `task-${Date.now()}`,
          title: taskDescription.trim(),
          completed: false,
          category: 'Erledigung',
          duration: 60,
          requiresProof: false,
          proofType: null,
          proofDescription: '',
          suggestedStartTime: '09:00',
          suggestedEndTime: '10:00',
          status: 'pending',
          createdAt: Date.now(),
        };
        
        const updatedTasks = [...dayPlan.tasks, task];
        const updatedPlan: DayPlan = { ...dayPlan, tasks: updatedTasks };
        
        await saveDayPlan(user.uid, updatedPlan);
        onDayPlanUpdate(updatedPlan);
        setShowAddTask(false);
      }
    } catch (error) {
      // This should rarely happen now since analyzeTasks has fallback
      console.warn('Failed to add task (using fallback):', error);
      
      // Ultimate fallback: Create task directly
      const task: Task = {
        id: `task-${Date.now()}`,
        title: taskDescription.trim() || 'Neue Aufgabe',
        completed: false,
        category: 'Erledigung',
        duration: 60,
        requiresProof: false,
        proofType: null,
        proofDescription: '',
        suggestedStartTime: '09:00',
        suggestedEndTime: '10:00',
        status: 'pending',
        createdAt: Date.now(),
      };
      
      const updatedTasks = [...dayPlan.tasks, task];
      const updatedPlan: DayPlan = { ...dayPlan, tasks: updatedTasks };
      
      try {
        await saveDayPlan(user.uid, updatedPlan);
        onDayPlanUpdate(updatedPlan);
        setShowAddTask(false);
      } catch (saveError) {
        console.error('Failed to save task:', saveError);
      }
    } finally {
      setIsAddingTask(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#0a0a0a]">
      {/* Header - Minimalist (wie im Screenshot) - mit iPhone Safe Area */}
      <header className="fixed top-0 left-0 right-0 z-50 backdrop-blur-xl bg-black/40 border-b border-white/[0.08]" style={{ paddingTop: 'env(safe-area-inset-top)' }}>
        <div className="max-w-7xl mx-auto px-6 lg:px-12">
          <div className="flex items-center justify-between h-16">
            {/* Logo */}
            <div className="flex items-center gap-8">
              <h1 className="text-xl font-serif italic text-white">
                Focus<span className="text-white/60">Coach</span>
              </h1>
              
              {/* Navigation - Desktop */}
              <nav className="hidden lg:flex items-center gap-1">
                <button
                  onClick={() => setView('overview')}
                  className={`px-4 py-2 text-sm transition-colors rounded-lg ${
                    view === 'overview'
                      ? 'text-white bg-white/[0.08]'
                      : 'text-white/60 hover:text-white hover:bg-white/[0.05]'
                  }`}
                >
                  Übersicht
                </button>
                
                {!dayPlan && (
                  <button
                    onClick={() => setView('create-plan')}
                    className={`px-4 py-2 text-sm transition-colors rounded-lg ${
                      view === 'create-plan'
                        ? 'text-white bg-white/[0.08]'
                        : 'text-white/60 hover:text-white hover:bg-white/[0.05]'
                    }`}
                  >
                    Plan erstellen
                  </button>
                )}
                
                {dayPlan && (
                  <button
                    onClick={() => setView('active-day')}
                    className={`px-4 py-2 text-sm transition-colors rounded-lg ${
                      view === 'active-day'
                        ? 'text-white bg-white/[0.08]'
                        : 'text-white/60 hover:text-white hover:bg-white/[0.05]'
                    }`}
                  >
                    Aktueller Tag
                  </button>
                )}
              </nav>
            </div>

            {/* Right Side */}
            <div className="flex items-center gap-4">
              {/* Progress (if plan exists) */}
              {dayPlan && (
                <div className="hidden lg:flex items-center gap-3">
                  <div className="text-sm text-white/60">
                    {completedTasks}/{totalTasks}
                  </div>
                  <div className="w-24 bg-white/[0.1] rounded-full h-1.5">
                    <div
                      className="bg-white/80 h-1.5 rounded-full transition-all"
                      style={{ width: `${totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0}%` }}
                    />
                  </div>
                </div>
              )}
              
              {/* User Name */}
              <div className="hidden lg:block text-sm text-white/60">
                {user.name}
              </div>
              
              {/* Settings Button */}
              <button
                onClick={() => setShowSettings(true)}
                className="px-4 py-2 text-sm text-white/60 hover:text-white hover:bg-white/[0.05] transition-colors rounded-lg"
              >
                Einstellungen
              </button>
              
              {/* Mobile Menu */}
              <button
                onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                className="lg:hidden text-white"
              >
                {mobileMenuOpen ? <X size={20} /> : <Menu size={20} />}
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Mobile Menu Dropdown */}
      {mobileMenuOpen && (
        <div className="lg:hidden fixed inset-0 bg-black/80 backdrop-blur-md z-40" onClick={() => setMobileMenuOpen(false)}>
          <div className="absolute left-0 right-0 bg-[#0a0a0a] border-b border-white/[0.08] p-6" style={{ top: 'calc(4rem + env(safe-area-inset-top))' }}>
            <nav className="space-y-2">
              <button
                onClick={() => { setView('overview'); setMobileMenuOpen(false); }}
                className="w-full text-left px-4 py-3 text-white/80 hover:bg-white/[0.05] rounded-lg transition-colors"
              >
                Übersicht
              </button>
              {!dayPlan && (
                <button
                  onClick={() => { setView('create-plan'); setMobileMenuOpen(false); }}
                  className="w-full text-left px-4 py-3 text-white/80 hover:bg-white/[0.05] rounded-lg transition-colors"
                >
                  Plan erstellen
                </button>
              )}
              {dayPlan && (
                <>
                  <button
                    onClick={() => { setView('active-day'); setMobileMenuOpen(false); }}
                    className="w-full text-left px-4 py-3 text-white/80 hover:bg-white/[0.05] rounded-lg transition-colors"
                  >
                    Aktueller Tag
                  </button>
                  <button
                    onClick={() => { setShowAddTask(true); setMobileMenuOpen(false); }}
                    className="w-full text-left px-4 py-3 text-white/80 hover:bg-white/[0.05] rounded-lg transition-colors flex items-center gap-2"
                  >
                    <Plus size={18} />
                    <span>Aufgabe hinzufügen</span>
                  </button>
                </>
              )}
            </nav>
          </div>
        </div>
      )}

      {/* Floating Action Button (FAB) - Only when plan exists */}
      {dayPlan && (
        <button
          onClick={() => setShowAddTask(true)}
          className="fixed z-40 w-14 h-14 rounded-full backdrop-blur-xl bg-white/[0.12] hover:bg-white/[0.18] border border-white/[0.2] hover:border-blue-400/60 text-white shadow-2xl shadow-blue-500/30 hover:shadow-[0_0_40px_rgba(96,165,250,0.5)] transition-all duration-300 flex items-center justify-center group hover:scale-110 active:scale-95"
          style={{ 
            bottom: 'max(1rem, calc(1rem + env(safe-area-inset-bottom)))',
            right: 'max(1rem, calc(1rem + env(safe-area-inset-right)))'
          }}
        >
          <Plus size={24} className="group-hover:rotate-90 transition-transform duration-300" />
        </button>
      )}

      {/* Main Content - mit Padding für Header + Safe Area */}
      <main className="min-h-screen overflow-y-auto" style={{ paddingTop: 'calc(4rem + env(safe-area-inset-top))' }}>
        {/* Overview - PREMIUM Welcome Screen with Calendar */}
        {activeView === 'overview' && (
          <PremiumWelcome
            userName={user.name}
            currentDate={currentDate}
            tasks={dayPlan?.tasks || []}
            onCreatePlan={() => setView('create-plan')}
            onAddTask={dayPlan ? () => setShowAddTask(true) : undefined}
          />
        )}

        {/* Create Plan (clicked button, but no tasks yet) - Show only form */}
        {activeView === 'create-plan' && !dayPlan && analyzedTasks.length === 0 && (
          <div className="h-full p-4 sm:p-6 lg:p-12 flex items-center justify-center">
            <div className="max-w-2xl lg:max-w-4xl w-full">
              <div className="text-center mb-8">
                <div className="text-6xl mb-4">✨</div>
                <h2 className="text-3xl font-bold text-white mb-2">
                  Tagesplan erstellen
                </h2>
                <p className="text-slate-400">
                  Beschreibe deine Aufgaben und ich strukturiere sie für dich.
                </p>
              </div>
              <div className="bg-slate-900 border border-slate-800 rounded-2xl p-8">
                <textarea
                  value={planInput}
                  onChange={(e) => setPlanInput(e.target.value)}
                  placeholder="Zum Beispiel:&#10;&#10;Mathe lernen (1 Stunde)&#10;Zimmer aufräumen&#10;Einkaufen gehen&#10;Sport machen"
                  className="w-full bg-slate-800 border border-slate-700 rounded-xl p-4 text-white placeholder-slate-500 min-h-[240px] resize-none mb-6 text-base"
                  autoFocus
                />
                <div className="flex gap-3">
                  <button
                    onClick={() => setView('overview')}
                    className="px-6 py-3 bg-slate-800 hover:bg-slate-700 text-white rounded-xl transition-colors"
                  >
                    Abbrechen
                  </button>
                  <button
                    onClick={handleCreatePlan}
                    disabled={!planInput.trim() || isAnalyzing}
                    className="flex-1 bg-blue-600 hover:bg-blue-500 text-white font-semibold py-3 px-6 rounded-xl transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isAnalyzing ? '🤖 KI analysiert...' : '✨ Plan erstellen'}
                  </button>
                </div>
                <div className="mt-6 p-4 bg-slate-800/50 border border-slate-700 rounded-lg">
                  <p className="text-xs text-slate-400 mb-2">
                    💡 <span className="font-semibold text-slate-300">Tipps für bessere Ergebnisse:</span>
                  </p>
                  <ul className="text-xs text-slate-400 space-y-1 ml-4">
                    <li>• Gib ungefähre Zeiten an (z.B. "1 Stunde", "30 Minuten")</li>
                    <li>• Sei spezifisch (z.B. "Mathe Kapitel 5 lernen" statt nur "lernen")</li>
                    <li>• Eine Zeile pro Aufgabe für bessere Struktur</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Plan Review (after AI analysis) - PREMIUM */}
        {activeView === 'create-plan' && analyzedTasks.length > 0 && (
          <PremiumPlanReview
            tasks={analyzedTasks}
            onConfirm={handlePlanConfirm}
            isLoading={false}
          />
        )}

        {activeView === 'active-day' && dayPlan && (
          <PremiumActiveDay
            currentTask={getCurrentTask()}
            allTasks={dayPlan.tasks}
            onUploadProof={(taskId) => {
              const task = dayPlan.tasks.find(t => t.id === taskId);
              if (task) {
                setVerifyingTask(task);
                setView('verification');
              }
            }}
            onMarkComplete={async (taskId) => {
              const task = dayPlan.tasks.find(t => t.id === taskId);
              if (!task) return;

              if (task.requiresProof && !task.verified) {
                setVerifyingTask(task);
                setView('verification');
                return;
              }

              const updatedTasks = dayPlan.tasks.map(t =>
                t.id === taskId ? { ...t, completed: true, status: 'completed' as const } : t
              );
              const updatedPlan: DayPlan = { ...dayPlan, tasks: updatedTasks };
              await saveDayPlan(user.uid, updatedPlan);
              onDayPlanUpdate(updatedPlan);
            }}
            onAddTask={() => setShowAddTask(true)}
          />
        )}

        {activeView === 'freedom' && dayPlan && (
          <PremiumFreedomMode
            completedTasks={dayPlan.tasks.filter(t => t.completed)}
          />
        )}

        {activeView === 'night' && (
          <PremiumNightMode
            nightModeEnd={settings.nightModeEnd}
          />
        )}
      </main>

      {/* Settings Modal */}
      {showSettings && (
        <SettingsScreen
          settings={settings}
          onUpdate={onSettingsUpdate}
          onClose={() => setShowSettings(false)}
        />
      )}

      {/* Verification Modal */}
      {view === 'verification' && verifyingTask && (
        <div className="fixed inset-0 bg-black/80 z-50 flex items-center justify-center p-4">
          {!proofImage ? (
            <div className="bg-slate-900 border border-slate-700 rounded-2xl p-6 max-w-md w-full">
              <h3 className="text-xl font-semibold text-white mb-4">Nachweis hochladen</h3>
              <PhotoUpload
                onImageSelect={async (file) => {
                  const reader = new FileReader();
                  reader.onloadend = async () => {
                    const base64 = reader.result as string;
                    setProofImage(base64);
                    setIsVerifying(true);
                    try {
                      const result = await verifyProof(
                        verifyingTask.title,
                        verifyingTask.category || 'Erledigung',
                        verifyingTask.proofDescription || 'Nachweis erforderlich',
                        base64
                      );
                      setVerificationResult(result);
                    } catch (error) {
                      console.error('Verification failed:', error);
                    } finally {
                      setIsVerifying(false);
                    }
                  };
                  reader.readAsDataURL(file);
                }}
                disabled={isVerifying}
              />
              <button
                onClick={() => {
                  setView('active-day');
                  setVerifyingTask(null);
                  setProofImage(null);
                }}
                className="mt-4 w-full bg-slate-700 hover:bg-slate-600 text-white py-2 rounded-xl"
              >
                Zurück
              </button>
            </div>
          ) : (
            <PremiumVerification
              taskTitle={verifyingTask.title}
              proofImageUrl={proofImage || undefined}
              verificationResult={verificationResult}
              isVerifying={isVerifying}
              onRetry={() => {
                setProofImage(null);
                setVerificationResult(null);
              }}
              onContinue={async () => {
                if (verifyingTask && dayPlan) {
                  const updatedTasks = dayPlan.tasks.map(t =>
                    t.id === verifyingTask.id
                      ? { ...t, completed: true, verified: true, status: 'completed' as const }
                      : t
                  );
                  const updatedPlan: DayPlan = { ...dayPlan, tasks: updatedTasks };
                  await saveDayPlan(user.uid, updatedPlan);
                  onDayPlanUpdate(updatedPlan);
                }
                setVerifyingTask(null);
                setProofImage(null);
                setVerificationResult(null);
              }}
              onMarkCompleteAnyway={async () => {
                if (verifyingTask && dayPlan) {
                  const updatedTasks = dayPlan.tasks.map(t =>
                    t.id === verifyingTask.id
                      ? { ...t, completed: true, verified: false, status: 'completed' as const }
                      : t
                  );
                  const updatedPlan: DayPlan = { ...dayPlan, tasks: updatedTasks };
                  await saveDayPlan(user.uid, updatedPlan);
                  onDayPlanUpdate(updatedPlan);
                }
                setVerifyingTask(null);
                setProofImage(null);
                setVerificationResult(null);
              }}
            />
          )}
        </div>
      )}

      {/* Add Task Modal */}
      {showAddTask && (
        <PremiumAddTask
          onClose={() => setShowAddTask(false)}
          onAddTask={handleAddTask}
          isProcessing={isAddingTask}
        />
      )}
    </div>
  );
};


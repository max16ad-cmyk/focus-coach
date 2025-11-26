import { useCallback, useState } from 'react';
import { Task, DayPlan, AnalyzedTask } from '../types';
import { analyzeTasks } from '../services/geminiService';
import { saveDayPlan } from '../services/firebase';

interface PlanHandlersOptions {
  userId: string;
  currentDate: string;
  onPlanUpdate: (plan: DayPlan) => void;
}

/**
 * Centralized Plan Creation Handlers
 * 
 * Verwaltet den gesamten Plan-Erstellungs-Workflow:
 * - AI-Analyse
 * - Task-Bearbeitung
 * - Plan-Bestätigung
 * 
 * @example
 * const { createPlan, confirmPlan, isAnalyzing } = usePlanHandlers({
 *   userId: user.uid,
 *   currentDate,
 *   onPlanUpdate: setDayPlan,
 * });
 */
export const usePlanHandlers = ({
  userId,
  currentDate,
  onPlanUpdate,
}: PlanHandlersOptions) => {
  
  const [planInput, setPlanInput] = useState('');
  const [analyzedTasks, setAnalyzedTasks] = useState<AnalyzedTask[]>([]);
  const [isAnalyzing, setIsAnalyzing] = useState(false);

  /**
   * Create plan from user input using AI
   */
  const createPlan = useCallback(async (input?: string) => {
    const textToAnalyze = input || planInput;
    if (!textToAnalyze.trim()) return;
    
    setIsAnalyzing(true);
    try {
      const analysis = await analyzeTasks(textToAnalyze);
      setAnalyzedTasks(analysis.tasks);
      return analysis;
    } catch (error) {
      console.error('Task analysis failed:', error);
      throw error;
    } finally {
      setIsAnalyzing(false);
    }
  }, [planInput]);

  /**
   * Confirm and save the analyzed plan
   */
  const confirmPlan = useCallback(async (tasks?: AnalyzedTask[]) => {
    const tasksToSave = tasks || analyzedTasks;
    if (tasksToSave.length === 0) return;

    const mappedTasks: Task[] = tasksToSave.map((at) => ({
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
      userId,
      date: currentDate,
      tasks: mappedTasks,
      createdAt: Date.now(),
      confirmed: true,
    };

    try {
      await saveDayPlan(userId, plan);
      onPlanUpdate(plan);
      
      // Reset state
      setPlanInput('');
      setAnalyzedTasks([]);
      
      return plan;
    } catch (error) {
      console.error('Failed to save plan:', error);
      throw error;
    }
  }, [userId, currentDate, analyzedTasks, onPlanUpdate]);

  /**
   * Edit an analyzed task before confirming
   */
  const editTask = useCallback((taskId: string, updates: Partial<AnalyzedTask>) => {
    setAnalyzedTasks(prev =>
      prev.map(t => (t.id === taskId ? { ...t, ...updates } : t))
    );
  }, []);

  /**
   * Add a new task to analyzed tasks
   */
  const addTask = useCallback((task: AnalyzedTask) => {
    setAnalyzedTasks(prev => [...prev, task]);
  }, []);

  /**
   * Remove a task from analyzed tasks
   */
  const removeTask = useCallback((taskId: string) => {
    setAnalyzedTasks(prev => prev.filter(t => t.id !== taskId));
  }, []);

  /**
   * Reset plan creation state
   */
  const reset = useCallback(() => {
    setPlanInput('');
    setAnalyzedTasks([]);
    setIsAnalyzing(false);
  }, []);

  return {
    // State
    planInput,
    setPlanInput,
    analyzedTasks,
    isAnalyzing,
    
    // Actions
    createPlan,
    confirmPlan,
    editTask,
    addTask,
    removeTask,
    reset,
  };
};


import { useCallback } from 'react';
import { Task, DayPlan } from '../types';
import { saveDayPlan } from '../services/firebase';

interface TaskHandlersOptions {
  userId: string;
  dayPlan: DayPlan | null;
  onPlanUpdate: (plan: DayPlan) => void;
  onVerificationRequired?: (task: Task) => void;
}

/**
 * Centralized Task Event Handlers
 * 
 * Extrahiert alle Task-bezogenen Event-Handler aus den Komponenten
 * für bessere Testbarkeit und Wiederverwendbarkeit
 * 
 * @example
 * const { handleMarkComplete, handleSkipTask } = useTaskHandlers({
 *   userId: user.uid,
 *   dayPlan,
 *   onPlanUpdate: setDayPlan,
 * });
 */
export const useTaskHandlers = ({
  userId,
  dayPlan,
  onPlanUpdate,
  onVerificationRequired,
}: TaskHandlersOptions) => {

  /**
   * Mark a task as completed
   * - Checks if proof is required
   * - Triggers verification flow if needed
   * - Updates task status in Firestore
   */
  const handleMarkComplete = useCallback(async (taskId: string) => {
    if (!dayPlan) return;

    const task = dayPlan.tasks.find(t => t.id === taskId);
    if (!task) return;

    // Nachweis erforderlich aber nicht verifiziert
    if (task.requiresProof && !task.verified) {
      onVerificationRequired?.(task);
      return;
    }

    // Task als erledigt markieren
    const updatedTasks = dayPlan.tasks.map(t =>
      t.id === taskId
        ? { ...t, completed: true, status: 'completed' as const }
        : t
    );

    const updatedPlan: DayPlan = { ...dayPlan, tasks: updatedTasks };
    
    try {
      await saveDayPlan(userId, updatedPlan);
      onPlanUpdate(updatedPlan);
    } catch (error) {
      console.error('Failed to mark task as complete:', error);
      throw error;
    }
  }, [userId, dayPlan, onPlanUpdate, onVerificationRequired]);

  /**
   * Skip a task (mark as skipped)
   */
  const handleSkipTask = useCallback(async (taskId: string) => {
    if (!dayPlan) return;

    const updatedTasks = dayPlan.tasks.map(t =>
      t.id === taskId
        ? { ...t, completed: false, status: 'skipped' as const }
        : t
    );

    const updatedPlan: DayPlan = { ...dayPlan, tasks: updatedTasks };
    
    try {
      await saveDayPlan(userId, updatedPlan);
      onPlanUpdate(updatedPlan);
    } catch (error) {
      console.error('Failed to skip task:', error);
      throw error;
    }
  }, [userId, dayPlan, onPlanUpdate]);

  /**
   * Mark task as in progress
   */
  const handleStartTask = useCallback(async (taskId: string) => {
    if (!dayPlan) return;

    const updatedTasks = dayPlan.tasks.map(t => ({
      ...t,
      status: t.id === taskId ? ('in_progress' as const) : t.status,
    }));

    const updatedPlan: DayPlan = { ...dayPlan, tasks: updatedTasks };
    
    try {
      await saveDayPlan(userId, updatedPlan);
      onPlanUpdate(updatedPlan);
    } catch (error) {
      console.error('Failed to start task:', error);
      throw error;
    }
  }, [userId, dayPlan, onPlanUpdate]);

  /**
   * Update proof image for task
   */
  const handleUpdateProofImage = useCallback(async (taskId: string, imageUrl: string) => {
    if (!dayPlan) return;

    const updatedTasks = dayPlan.tasks.map(t =>
      t.id === taskId
        ? { ...t, proofImageUrl: imageUrl, status: 'waiting_proof' as const }
        : t
    );

    const updatedPlan: DayPlan = { ...dayPlan, tasks: updatedTasks };
    
    try {
      await saveDayPlan(userId, updatedPlan);
      onPlanUpdate(updatedPlan);
    } catch (error) {
      console.error('Failed to update proof image:', error);
      throw error;
    }
  }, [userId, dayPlan, onPlanUpdate]);

  /**
   * Mark task as verified after successful proof check
   */
  const handleMarkVerified = useCallback(async (taskId: string) => {
    if (!dayPlan) return;

    const updatedTasks = dayPlan.tasks.map(t =>
      t.id === taskId
        ? { ...t, verified: true, completed: true, status: 'completed' as const }
        : t
    );

    const updatedPlan: DayPlan = { ...dayPlan, tasks: updatedTasks };
    
    try {
      await saveDayPlan(userId, updatedPlan);
      onPlanUpdate(updatedPlan);
    } catch (error) {
      console.error('Failed to mark task as verified:', error);
      throw error;
    }
  }, [userId, dayPlan, onPlanUpdate]);

  /**
   * Delete a task from the plan
   */
  const handleDeleteTask = useCallback(async (taskId: string) => {
    if (!dayPlan) return;

    const updatedTasks = dayPlan.tasks.filter(t => t.id !== taskId);
    const updatedPlan: DayPlan = { ...dayPlan, tasks: updatedTasks };
    
    try {
      await saveDayPlan(userId, updatedPlan);
      onPlanUpdate(updatedPlan);
    } catch (error) {
      console.error('Failed to delete task:', error);
      throw error;
    }
  }, [userId, dayPlan, onPlanUpdate]);

  /**
   * Update task details
   */
  const handleUpdateTask = useCallback(async (taskId: string, updates: Partial<Task>) => {
    if (!dayPlan) return;

    const updatedTasks = dayPlan.tasks.map(t =>
      t.id === taskId ? { ...t, ...updates } : t
    );

    const updatedPlan: DayPlan = { ...dayPlan, tasks: updatedTasks };
    
    try {
      await saveDayPlan(userId, updatedPlan);
      onPlanUpdate(updatedPlan);
    } catch (error) {
      console.error('Failed to update task:', error);
      throw error;
    }
  }, [userId, dayPlan, onPlanUpdate]);

  return {
    handleMarkComplete,
    handleSkipTask,
    handleStartTask,
    handleUpdateProofImage,
    handleMarkVerified,
    handleDeleteTask,
    handleUpdateTask,
  };
};

/**
 * Get current task based on time
 */
export const useCurrentTask = (dayPlan: DayPlan | null): Task | null => {
  if (!dayPlan) return null;

  const now = new Date();
  const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
  
  // Try to find task matching current time
  const timeBasedTask = dayPlan.tasks.find((task) => {
    if (task.completed) return false;
    if (!task.suggestedStartTime || !task.suggestedEndTime) return false;
    return currentTime >= task.suggestedStartTime && currentTime <= task.suggestedEndTime;
  });

  if (timeBasedTask) return timeBasedTask;

  // Fallback: First uncompleted task
  return dayPlan.tasks.find(t => !t.completed) || null;
};


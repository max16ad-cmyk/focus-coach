import { 
    getFirestore, 
    collection, 
    addDoc, 
    query, 
    where, 
    getDocs, 
    Timestamp,
    onSnapshot 
} from 'firebase/firestore';
import { db } from './firebase';

// Platform types
export type Platform = 'ios' | 'macos' | 'windows' | 'web';

// Activity event types
export type ActivityEvent = 
    | 'app_blocked'
    | 'app_unblocked'
    | 'url_blocked'
    | 'url_unblocked'
    | 'task_completed'
    | 'task_created'
    | 'task_started'
    | 'routine_completed'
    | 'screen_time_analyzed'
    | 'blocklist_updated';

// Activity log entry
export interface ActivityLog {
    id?: string;
    platform: Platform;
    timestamp: Date;
    event: ActivityEvent;
    data: {
        appName?: string;
        appPath?: string;
        domain?: string;
        taskId?: string;
        taskTitle?: string;
        routineId?: string;
        blockListId?: string;
        duration?: number; // in seconds
        [key: string]: any; // Additional data
    };
}

// Analytics summary
export interface AnalyticsSummary {
    totalScreenTime: number; // in seconds
    blockedApps: {
        ios: string[];
        macos: string[];
        windows: string[];
    };
    completedTasks: number;
    productivityScore: number;
    timeDistribution: {
        productive: number;
        distracted: number;
    };
    byPlatform: {
        ios: ActivityLog[];
        macos: ActivityLog[];
        windows: ActivityLog[];
    };
}

/**
 * Log an activity to Firebase
 */
export async function logActivity(
    userId: string,
    platform: Platform,
    event: ActivityEvent,
    data: ActivityLog['data'] = {}
): Promise<void> {
    if (!db) {
        console.error('Firebase not initialized');
        return;
    }

    try {
        const activity: Omit<ActivityLog, 'id'> = {
            platform,
            timestamp: new Date(),
            event,
            data
        };

        await addDoc(
            collection(db, 'users', userId, 'activities'),
            {
                ...activity,
                timestamp: Timestamp.fromDate(activity.timestamp)
            }
        );

        console.log(`✅ Activity logged: ${event} on ${platform}`);
    } catch (error) {
        console.error('Error logging activity:', error);
    }
}

/**
 * Get activities for a specific date range
 */
export async function getActivitiesForDateRange(
    userId: string,
    startDate: Date,
    endDate: Date
): Promise<ActivityLog[]> {
    if (!db) {
        console.error('Firebase not initialized');
        return [];
    }

    try {
        const activitiesRef = collection(db, 'users', userId, 'activities');
        const q = query(
            activitiesRef,
            where('timestamp', '>=', Timestamp.fromDate(startDate)),
            where('timestamp', '<=', Timestamp.fromDate(endDate))
        );

        const snapshot = await getDocs(q);
        const activities: ActivityLog[] = [];

        snapshot.forEach((doc) => {
            const data = doc.data();
            activities.push({
                id: doc.id,
                platform: data.platform,
                timestamp: data.timestamp.toDate(),
                event: data.event,
                data: data.data || {}
            });
        });

        return activities.sort((a, b) => 
            b.timestamp.getTime() - a.timestamp.getTime()
        );
    } catch (error) {
        console.error('Error fetching activities:', error);
        return [];
    }
}

/**
 * Get daily analytics summary
 */
export async function getDailyAnalytics(
    userId: string,
    date: Date = new Date()
): Promise<AnalyticsSummary> {
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    
    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    const activities = await getActivitiesForDateRange(
        userId,
        startOfDay,
        endOfDay
    );

    return calculateAnalyticsSummary(activities);
}

/**
 * Calculate analytics summary from activities
 */
function calculateAnalyticsSummary(activities: ActivityLog[]): AnalyticsSummary {
    // Group by platform
    const byPlatform = {
        ios: activities.filter(a => a.platform === 'ios'),
        macos: activities.filter(a => a.platform === 'macos'),
        windows: activities.filter(a => a.platform === 'windows')
    };

    // Calculate total screen time (from blocked apps)
    const blockedAppEvents = activities.filter(a => 
        a.event === 'app_blocked' && a.data.duration
    );
    const totalScreenTime = blockedAppEvents.reduce(
        (sum, event) => sum + (event.data.duration || 0),
        0
    );

    // Get blocked apps by platform
    const blockedApps = {
        ios: Array.from(new Set(
            byPlatform.ios
                .filter(a => a.event === 'app_blocked')
                .map(a => a.data.appName)
                .filter(Boolean) as string[]
        )),
        macos: Array.from(new Set(
            byPlatform.macos
                .filter(a => a.event === 'app_blocked')
                .map(a => a.data.appName)
                .filter(Boolean) as string[]
        )),
        windows: Array.from(new Set(
            byPlatform.windows
                .filter(a => a.event === 'app_blocked')
                .map(a => a.data.appName)
                .filter(Boolean) as string[]
        ))
    };

    // Count completed tasks
    const completedTasks = activities.filter(
        a => a.event === 'task_completed'
    ).length;

    // Calculate productivity score (0-100)
    const productiveTime = activities
        .filter(a => a.event === 'task_completed')
        .reduce((sum, a) => sum + (a.data.duration || 0), 0);
    
    const distractedTime = totalScreenTime - productiveTime;
    const productivityScore = totalScreenTime > 0
        ? Math.round((productiveTime / totalScreenTime) * 100)
        : 0;

    return {
        totalScreenTime,
        blockedApps,
        completedTasks,
        productivityScore,
        timeDistribution: {
            productive: productiveTime,
            distracted: distractedTime
        },
        byPlatform
    };
}

/**
 * Subscribe to real-time activities
 */
export function subscribeToActivities(
    userId: string,
    callback: (activities: ActivityLog[]) => void
): () => void {
    if (!db) {
        console.error('Firebase not initialized');
        return () => {};
    }

    const activitiesRef = collection(db, 'users', userId, 'activities');
    const q = query(activitiesRef);

    const unsubscribe = onSnapshot(q, (snapshot) => {
        const activities: ActivityLog[] = [];

        snapshot.forEach((doc) => {
            const data = doc.data();
            activities.push({
                id: doc.id,
                platform: data.platform,
                timestamp: data.timestamp.toDate(),
                event: data.event,
                data: data.data || {}
            });
        });

        callback(activities.sort((a, b) => 
            b.timestamp.getTime() - a.timestamp.getTime()
        ));
    }, (error) => {
        console.error('Error subscribing to activities:', error);
        callback([]);
    });

    return unsubscribe;
}

/**
 * Get combined analytics across all platforms
 */
export async function getCombinedAnalytics(
    userId: string,
    startDate: Date,
    endDate: Date
): Promise<AnalyticsSummary> {
    const activities = await getActivitiesForDateRange(
        userId,
        startDate,
        endDate
    );

    return calculateAnalyticsSummary(activities);
}





import { initializeApp } from "firebase/app";
import { 
    getAuth, 
    signInWithEmailAndPassword, 
    createUserWithEmailAndPassword, 
    signOut as firebaseSignOut,
    onAuthStateChanged,
    User as FirebaseUser 
} from "firebase/auth";
import {
    getFirestore,
    doc,
    setDoc,
    getDoc,
    updateDoc,
    collection,
    query,
    onSnapshot,
    deleteDoc,
    writeBatch,
    getDocs
} from "firebase/firestore";
import { Task, UserStats, Distraction, DayPlan, UserSettings } from "../types";

// --- KONFIGURATION ---
const firebaseConfig = {
  apiKey: "AIzaSyCB3dLNsU27k0PH6rtt_Wt_7G-i80ColTc",
  authDomain: "get-shit-done-c422f.firebaseapp.com",
  projectId: "get-shit-done-c422f",
  storageBucket: "get-shit-done-c422f.firebasestorage.app",
  messagingSenderId: "946092629012",
  appId: "1:946092629012:web:157887d8270cff31cc9b01",
  measurementId: "G-9E9H1JRFJB"
};

// --- INITIALIZATION ---
let auth: any;
let db: any;

try {
    const app = initializeApp(firebaseConfig);
    auth = getAuth(app);
    db = getFirestore(app);
} catch (e) {
    console.error("Firebase Initialization Error:", e);
}

// =============================================
// AUTH FUNCTIONS
// =============================================

export const loginUser = async (email: string, pass: string) => {
    if (!auth) throw new Error("Firebase failed to initialize");
    const userCredential = await signInWithEmailAndPassword(auth, email, pass);
    return userCredential.user;
};

export const registerUser = async (email: string, pass: string) => {
    if (!auth) throw new Error("Firebase failed to initialize");
    const userCredential = await createUserWithEmailAndPassword(auth, email, pass);
    
    // Create initial user data in Firestore
    await initializeUserData(userCredential.user.uid);
    
    return userCredential.user;
};

export const logoutUser = async () => {
    if (!auth) return;
    await firebaseSignOut(auth);
};

export const subscribeToAuthChanges = (callback: (user: FirebaseUser | null) => void) => {
    if (!auth) {
        callback(null);
        return () => {};
    }
    return onAuthStateChanged(auth, callback);
};

// =============================================
// FIRESTORE: USER DATA INITIALIZATION
// =============================================

const INITIAL_STATS: UserStats = {
    xp: 0,
    level: 1,
    streak: 1,
    tasksCompleted: 0,
    penalties: 0
};

const INITIAL_DISTRACTIONS: Distraction[] = [
    { id: '1', name: 'Social Media', url: 'https://instagram.com', icon: '📸', category: 'social' },
    { id: '2', name: 'News Feed', url: 'https://news.google.com', icon: '📰', category: 'news' },
    { id: '3', name: 'Video Streaming', url: 'https://youtube.com', icon: '📺', category: 'video' },
    { id: '4', name: 'Gaming', url: 'https://twitch.tv', icon: '🎮', category: 'game' },
];

export const initializeUserData = async (userId: string) => {
    if (!db) return;
    
    try {
        const userDocRef = doc(db, "users", userId);
        const userDoc = await getDoc(userDocRef);
        
        if (!userDoc.exists()) {
            // Create new user document with initial stats
            await setDoc(userDocRef, {
                stats: INITIAL_STATS,
                createdAt: new Date().toISOString(),
                lastActive: new Date().toISOString()
            });
            
            // Create initial distractions
            const batch = writeBatch(db);
            INITIAL_DISTRACTIONS.forEach(distraction => {
                const distractionRef = doc(db, "users", userId, "distractions", distraction.id);
                batch.set(distractionRef, distraction);
            });
            await batch.commit();
            
            console.log("User data initialized in Firestore");
        }
    } catch (error) {
        console.error("Error initializing user data:", error);
    }
};

// =============================================
// FIRESTORE: TASKS (Real-time Sync)
// =============================================

export const subscribeToTasks = (
    userId: string, 
    callback: (tasks: Task[]) => void
) => {
    if (!db) {
        callback([]);
        return () => {};
    }
    
    const tasksRef = collection(db, "users", userId, "tasks");
    const q = query(tasksRef);
    
    return onSnapshot(q, (snapshot) => {
        const tasks: Task[] = [];
        snapshot.forEach((docSnap) => {
            tasks.push({ id: docSnap.id, ...docSnap.data() } as Task);
        });
        // Sort by creation date (oldest first so new tasks appear at bottom)
        tasks.sort((a: any, b: any) => (a.createdAt || 0) - (b.createdAt || 0));
        callback(tasks);
    }, (error) => {
        console.error("Error listening to tasks:", error);
        callback([]);
    });
};

export const addTaskToFirestore = async (userId: string, task: Task) => {
    if (!db) return;
    
    try {
        const taskRef = doc(db, "users", userId, "tasks", task.id);
        await setDoc(taskRef, {
            ...task,
            createdAt: Date.now()
        });
    } catch (error) {
        console.error("Error adding task:", error);
    }
};

export const updateTaskInFirestore = async (userId: string, taskId: string, updates: Partial<Task>) => {
    if (!db) return;
    
    try {
        const taskRef = doc(db, "users", userId, "tasks", taskId);
        await updateDoc(taskRef, updates);
    } catch (error) {
        console.error("Error updating task:", error);
    }
};

export const deleteTaskFromFirestore = async (userId: string, taskId: string) => {
    if (!db) return;
    
    try {
        const taskRef = doc(db, "users", userId, "tasks", taskId);
        await deleteDoc(taskRef);
    } catch (error) {
        console.error("Error deleting task:", error);
    }
};

export const markAllTasksComplete = async (userId: string) => {
    if (!db) return;
    
    try {
        const tasksRef = collection(db, "users", userId, "tasks");
        const snapshot = await getDocs(tasksRef);
        
        const batch = writeBatch(db);
        snapshot.forEach((docSnap) => {
            batch.update(docSnap.ref, { completed: true });
        });
        await batch.commit();
    } catch (error) {
        console.error("Error marking all tasks complete:", error);
    }
};

// =============================================
// FIRESTORE: USER STATS (Real-time Sync)
// =============================================

export const subscribeToStats = (
    userId: string, 
    callback: (stats: UserStats) => void
) => {
    if (!db) {
        callback(INITIAL_STATS);
        return () => {};
    }
    
    const userDocRef = doc(db, "users", userId);
    
    return onSnapshot(userDocRef, (snapshot) => {
        if (snapshot.exists()) {
            const data = snapshot.data();
            callback(data.stats || INITIAL_STATS);
        } else {
            callback(INITIAL_STATS);
        }
    }, (error) => {
        console.error("Error listening to stats:", error);
        callback(INITIAL_STATS);
    });
};

export const updateStatsInFirestore = async (userId: string, stats: UserStats) => {
    if (!db) return;
    
    try {
        const userDocRef = doc(db, "users", userId);
        await updateDoc(userDocRef, { 
            stats,
            lastActive: new Date().toISOString()
        });
    } catch (error) {
        console.error("Error updating stats:", error);
    }
};

// =============================================
// FIRESTORE: DISTRACTIONS (Real-time Sync)
// =============================================

export const subscribeToDistractions = (
    userId: string, 
    callback: (distractions: Distraction[]) => void
) => {
    if (!db) {
        callback(INITIAL_DISTRACTIONS);
        return () => {};
    }
    
    const distractionsRef = collection(db, "users", userId, "distractions");
    const q = query(distractionsRef);
    
    return onSnapshot(q, (snapshot) => {
        const distractions: Distraction[] = [];
        snapshot.forEach((docSnap) => {
            distractions.push({ id: docSnap.id, ...docSnap.data() } as Distraction);
        });
        callback(distractions);
    }, (error) => {
        console.error("Error listening to distractions:", error);
        callback(INITIAL_DISTRACTIONS);
    });
};

export const addDistractionToFirestore = async (userId: string, distraction: Distraction) => {
    if (!db) return;
    
    try {
        const distractionRef = doc(db, "users", userId, "distractions", distraction.id);
        await setDoc(distractionRef, distraction);
    } catch (error) {
        console.error("Error adding distraction:", error);
    }
};

export const deleteDistractionFromFirestore = async (userId: string, distractionId: string) => {
    if (!db) return;
    
    try {
        const distractionRef = doc(db, "users", userId, "distractions", distractionId);
        await deleteDoc(distractionRef);
    } catch (error) {
        console.error("Error deleting distraction:", error);
    }
};

// =============================================
// FIRESTORE: DAY PLANS (Focus Coach)
// =============================================

export const getDayPlan = async (userId: string, date: string): Promise<DayPlan | null> => {
    if (!db) return null;
    
    try {
        const planRef = doc(db, "users", userId, "dayPlans", date);
        const planDoc = await getDoc(planRef);
        
        if (planDoc.exists()) {
            return { id: planDoc.id, ...planDoc.data() } as DayPlan;
        }
        return null;
    } catch (error) {
        console.error("Error getting day plan:", error);
        return null;
    }
};

export const saveDayPlan = async (userId: string, plan: DayPlan) => {
    if (!db) return;
    
    try {
        const planRef = doc(db, "users", userId, "dayPlans", plan.date);
        await setDoc(planRef, {
            ...plan,
            updatedAt: Date.now()
        });
    } catch (error) {
        console.error("Error saving day plan:", error);
    }
};

export const subscribeToDayPlan = (
    userId: string,
    date: string,
    callback: (plan: DayPlan | null) => void
) => {
    if (!db) {
        callback(null);
        return () => {};
    }
    
    const planRef = doc(db, "users", userId, "dayPlans", date);
    
    return onSnapshot(planRef, (snapshot) => {
        if (snapshot.exists()) {
            callback({ id: snapshot.id, ...snapshot.data() } as DayPlan);
        } else {
            callback(null);
        }
    }, (error) => {
        console.error("Error listening to day plan:", error);
        callback(null);
    });
};

// =============================================
// FIRESTORE: USER SETTINGS (Multi-Device Sync)
// =============================================

const DEFAULT_SETTINGS: UserSettings = {
    coachPersonality: 'sergeant',
    nightModeStart: '23:00',
    nightModeEnd: '06:00',
    blockedSites: [],
    allowedSites: [],
    requirePhotoProof: true,
    proofStrictness: 'medium',
    emergencyUnlockEnabled: true,
    emergencyUnlockDuration: 5,
    emergencyUnlockCooldown: 24,
    nightModeEnabled: true,
    nightModeNoUnlock: true,
    morningLockEnabled: false,
    morningLockStart: '06:00',
    morningLockEnd: '12:00',
};

export const subscribeToSettings = (
    userId: string,
    callback: (settings: UserSettings) => void
) => {
    if (!db) {
        callback(DEFAULT_SETTINGS);
        return () => {};
    }
    
    const userDocRef = doc(db, "users", userId);
    
    return onSnapshot(userDocRef, (snapshot) => {
        if (snapshot.exists()) {
            const data = snapshot.data();
            callback(data.settings || DEFAULT_SETTINGS);
        } else {
            callback(DEFAULT_SETTINGS);
        }
    }, (error) => {
        console.error("Error listening to settings:", error);
        callback(DEFAULT_SETTINGS);
    });
};

export const updateSettingsInFirestore = async (userId: string, settings: UserSettings) => {
    if (!db) return;
    
    try {
        const userDocRef = doc(db, "users", userId);
        await updateDoc(userDocRef, { 
            settings,
            lastActive: new Date().toISOString()
        });
    } catch (error) {
        console.error("Error updating settings:", error);
    }
};

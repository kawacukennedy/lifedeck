import { createSlice, PayloadAction } from '@reduxjs/toolkit';

export interface Achievement {
    id: string;
    title: string;
    description: string;
    icon: string;
    category: 'STREAKS' | 'MILESTONES' | 'DOMAINS';
    unlockedAt?: string;
}

export interface UserState {
    id: string;
    email: string;
    name: string;
    hasCompletedOnboarding: boolean;
    subscriptionTier: 'free' | 'premium';
    progress: {
        currentStreak: number;
        lifePoints: number;
        healthScore: number;
        financeScore: number;
        productivityScore: number;
        mindfulnessScore: number;
    };
    settings: {
        healthKitEnabled: boolean;
        calendarEnabled: boolean;
        financeEnabled: boolean;
        quizAnswers: Record<string, string>;
        notificationsEnabled: boolean;
        dailyReminderTime: string;
    };
    preferences: {
        language: string;
        theme: 'light' | 'dark';
    };
    achievements: Achievement[];
    joinDate: string;
}

const initialState: UserState = {
    id: '',
    email: '',
    name: '',
    hasCompletedOnboarding: false,
    subscriptionTier: 'free',
    progress: {
        currentStreak: 0,
        lifePoints: 0,
        healthScore: 50,
        financeScore: 50,
        productivityScore: 50,
        mindfulnessScore: 50,
    },
    settings: {
        healthKitEnabled: false,
        calendarEnabled: false,
        financeEnabled: false,
        quizAnswers: {},
        notificationsEnabled: true,
        dailyReminderTime: '09:00',
    },
    preferences: {
        language: 'en',
        theme: 'dark',
    },
    achievements: [
        { id: '1', title: 'First Step', description: 'Complete your first card', icon: '🎯', category: 'MILESTONES' },
        { id: '2', title: 'Streak Starter', description: 'Maintain a 3-day streak', icon: '🔥', category: 'STREAKS' },
    ],
    joinDate: new Date().toISOString(),
};

const userSlice = createSlice({
    name: 'user',
    initialState,
    reducers: {
        setUser: (state, action: PayloadAction<UserState>) => {
            return { ...state, ...action.payload };
        },
        updateProfile: (state, action: PayloadAction<{ name?: string; email?: string }>) => {
            if (action.payload.name) state.name = action.payload.name;
            if (action.payload.email) state.email = action.payload.email;
        },
        completeOnboarding: (state) => {
            state.hasCompletedOnboarding = true;
        },
        updateSettings: (state, action: PayloadAction<Partial<UserState['settings']>>) => {
            state.settings = { ...state.settings, ...action.payload };
        },
        updateProgress: (state, action: PayloadAction<{ domain: string; points: number }>) => {
            const { domain, points } = action.payload;
            state.progress.lifePoints += points;
            if (domain === 'HEALTH') state.progress.healthScore += 5;
            if (domain === 'FINANCE') state.progress.financeScore += 5;
            if (domain === 'PRODUCTIVITY') state.progress.productivityScore += 5;
            if (domain === 'MINDFULNESS') state.progress.mindfulnessScore += 5;
        },
        unlockAchievement: (state, action: PayloadAction<string>) => {
            const achievement = state.achievements.find(a => a.id === action.payload);
            if (achievement && !achievement.unlockedAt) {
                achievement.unlockedAt = new Date().toISOString();
            }
        },
    },
});

export const { setUser, updateProfile, completeOnboarding, updateSettings, updateProgress, unlockAchievement } = userSlice.actions;
export default userSlice.reducer;

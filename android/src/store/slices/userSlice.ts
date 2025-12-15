import {createSlice, PayloadAction} from '@reduxjs/toolkit';

export interface UserProgress {
  healthScore: number;
  financeScore: number;
  productivityScore: number;
  mindfulnessScore: number;
  lifeScore: number;
  currentStreak: number;
  longestStreak: number;
  lifePoints: number;
  totalCardsCompleted: number;
  lastActiveDate?: string;
}

export interface User {
  id: string;
  email: string;
  name?: string;
  avatar?: string;
  hasCompletedOnboarding: boolean;
  subscriptionTier: 'free' | 'premium';
  subscriptionExpiryDate?: string;
  progress: UserProgress;
  joinDate: string;
}

const initialProgress: UserProgress = {
  healthScore: 0,
  financeScore: 0,
  productivityScore: 0,
  mindfulnessScore: 0,
  lifeScore: 0,
  currentStreak: 0,
  longestStreak: 0,
  lifePoints: 0,
  totalCardsCompleted: 0,
};

const initialState: User | null = null;

const userSlice = createSlice({
  name: 'user',
  initialState,
  reducers: {
    setUser: (state, action: PayloadAction<User>) => {
      return action.payload;
    },
    updateProgress: (
      state,
      action: PayloadAction<Partial<UserProgress>>,
    ) => {
      if (state) {
        state.progress = {...state.progress, ...action.payload};
        // Recalculate life score
        state.progress.lifeScore =
          (state.progress.healthScore +
            state.progress.financeScore +
            state.progress.productivityScore +
            state.progress.mindfulnessScore) /
          4;
      }
    },
    completeCard: state => {
      if (state) {
        state.progress.totalCardsCompleted += 1;
        state.progress.lifePoints += 10;
        state.progress.lastActiveDate = new Date().toISOString();
      }
    },
    updateStreak: (state, action: PayloadAction<number>) => {
      if (state) {
        state.progress.currentStreak = action.payload;
        state.progress.longestStreak = Math.max(
          state.progress.longestStreak,
          action.payload,
        );
      }
    },
    clearUser: () => null,
  },
});

export const {setUser, updateProgress, completeCard, updateStreak, clearUser} =
  userSlice.actions;
export default userSlice.reducer;
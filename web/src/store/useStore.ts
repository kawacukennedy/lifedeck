import { create } from 'zustand';
import { persist } from 'zustand/middleware';

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

export interface CoachingCard {
  id: string;
  title: string;
  description: string;
  actionText: string;
  domain: 'health' | 'finance' | 'productivity' | 'mindfulness';
  actionType: 'quick' | 'standard' | 'extended' | 'habit' | 'reflection';
  priority: 'low' | 'medium' | 'high' | 'urgent';
  icon: string;
  backgroundColor?: string;
  tips: string[];
  benefits: string[];
  status: 'pending' | 'completed' | 'dismissed' | 'snoozed' | 'expired';
  createdAt: string;
  completedAt?: string;
  dismissedAt?: string;
  snoozedUntil?: string;
  aiGenerated: boolean;
}

interface UIState {
  theme: 'light' | 'dark';
  sidebarOpen: boolean;
  loading: boolean;
}

interface AppState extends UIState {
  user: User | null;
  dailyCards: CoachingCard[];
  completedCards: CoachingCard[];

  // Actions
  setUser: (user: User | null) => void;
  updateProgress: (progress: Partial<UserProgress>) => void;
  completeCard: (cardId: string) => void;
  setDailyCards: (cards: CoachingCard[]) => void;
  setTheme: (theme: 'light' | 'dark') => void;
  setSidebarOpen: (open: boolean) => void;
  setLoading: (loading: boolean) => void;
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

export const useStore = create<AppState>()(
  persist(
    (set, get) => ({
      // Initial state
      user: null,
      dailyCards: [],
      completedCards: [],
      theme: 'dark',
      sidebarOpen: false,
      loading: false,

      // Actions
      setUser: (user) => set({ user }),

      updateProgress: (progressUpdate) => {
        const { user } = get();
        if (user) {
          const updatedProgress = { ...user.progress, ...progressUpdate };
          // Recalculate life score
          updatedProgress.lifeScore =
            (updatedProgress.healthScore +
              updatedProgress.financeScore +
              updatedProgress.productivityScore +
              updatedProgress.mindfulnessScore) /
            4;

          set({
            user: {
              ...user,
              progress: updatedProgress,
            },
          });
        }
      },

      completeCard: (cardId) => {
        const { dailyCards, completedCards, user } = get();

        const cardIndex = dailyCards.findIndex((card) => card.id === cardId);
        if (cardIndex !== -1) {
          const completedCard = {
            ...dailyCards[cardIndex],
            status: 'completed' as const,
            completedAt: new Date().toISOString(),
          };

          set({
            dailyCards: dailyCards.filter((_, index) => index !== cardIndex),
            completedCards: [completedCard, ...completedCards],
          });

          // Update user progress
          if (user) {
            const updatedProgress = {
              ...user.progress,
              totalCardsCompleted: user.progress.totalCardsCompleted + 1,
              lifePoints: user.progress.lifePoints + 10,
              lastActiveDate: new Date().toISOString(),
            };

            set({
              user: {
                ...user,
                progress: updatedProgress,
              },
            });
          }
        }
      },

      setDailyCards: (cards) => set({ dailyCards: cards }),

      setTheme: (theme) => set({ theme }),

      setSidebarOpen: (sidebarOpen) => set({ sidebarOpen }),

      setLoading: (loading) => set({ loading }),
    }),
    {
      name: 'lifedeck-storage',
      partialize: (state) => ({
        user: state.user,
        theme: state.theme,
      }),
    },
  ),
);
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { apiService } from '../lib/api';

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
  preferredDomains?: string[];
  goals?: string;
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
  error: string | null;
}

interface AppState extends UIState {
  user: User | null;
  dailyCards: CoachingCard[];
  completedCards: CoachingCard[];

  // Actions
  setUser: (user: User | null) => void;
  updateProgress: (progress: Partial<UserProgress>) => void;
  completeCard: (cardId: string) => Promise<void>;
  dismissCard: (cardId: string) => Promise<void>;
  snoozeCard: (cardId: string, until: string) => Promise<void>;
  loadDailyCards: () => Promise<void>;
  setDailyCards: (cards: CoachingCard[]) => void;
  setTheme: (theme: 'light' | 'dark') => void;
  setSidebarOpen: (open: boolean) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
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
      error: null,

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

      completeCard: async (cardId) => {
        try {
          set({ loading: true, error: null });
          await apiService.completeCard(cardId);

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
        } catch (error) {
          console.error('Failed to complete card:', error);
          set({ error: 'Failed to complete card. Please try again.' });
        } finally {
          set({ loading: false });
        }
      },

      dismissCard: async (cardId) => {
        try {
          set({ loading: true, error: null });
          await apiService.dismissCard(cardId);

          const { dailyCards } = get();
          set({
            dailyCards: dailyCards.filter((card) => card.id !== cardId),
          });
        } catch (error) {
          console.error('Failed to dismiss card:', error);
          set({ error: 'Failed to dismiss card. Please try again.' });
        } finally {
          set({ loading: false });
        }
      },

      snoozeCard: async (cardId, until) => {
        try {
          set({ loading: true, error: null });
          await apiService.snoozeCard(cardId, until);

          const { dailyCards } = get();
          const updatedCards = dailyCards.map((card) =>
            card.id === cardId
              ? { ...card, status: 'snoozed' as const, snoozedUntil: until }
              : card
          );
          set({ dailyCards: updatedCards });
        } catch (error) {
          console.error('Failed to snooze card:', error);
          set({ error: 'Failed to snooze card. Please try again.' });
        } finally {
          set({ loading: false });
        }
      },

      loadDailyCards: async () => {
        try {
          set({ loading: true, error: null });
          const response = await apiService.getDailyCards();
          set({ dailyCards: response });
        } catch (error) {
          console.error('Failed to load daily cards:', error);
          set({ error: 'Failed to load daily cards. Using sample data.' });
          // Fallback to sample data
          const sampleCards = [
            {
              id: '1',
              title: 'Take a Mindful Walk',
              description: 'Step outside for a 10-minute walk and focus on your breathing',
              actionText: 'Walk for 10 minutes outside',
              domain: 'health' as const,
              actionType: 'standard' as const,
              priority: 'medium' as const,
              icon: 'heart',
              tips: ['Leave your phone behind', 'Focus on your breathing'],
              benefits: ['Improves cardiovascular health', 'Reduces stress'],
              status: 'pending' as const,
              createdAt: new Date().toISOString(),
              aiGenerated: false,
            },
          ];
          set({ dailyCards: sampleCards });
        } finally {
          set({ loading: false });
        }
      },

      setDailyCards: (cards) => set({ dailyCards: cards }),

      setTheme: (theme) => set({ theme }),

      setSidebarOpen: (sidebarOpen) => set({ sidebarOpen }),

      setLoading: (loading) => set({ loading }),

      setError: (error) => set({ error }),
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
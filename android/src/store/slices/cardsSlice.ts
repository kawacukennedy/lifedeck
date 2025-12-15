import {createSlice, PayloadAction} from '@reduxjs/toolkit';

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

interface CardsState {
  dailyCards: CoachingCard[];
  completedCards: CoachingCard[];
  isLoading: boolean;
  error: string | null;
}

const initialState: CardsState = {
  dailyCards: [],
  completedCards: [],
  isLoading: false,
  error: null,
};

const cardsSlice = createSlice({
  name: 'cards',
  initialState,
  reducers: {
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setDailyCards: (state, action: PayloadAction<CoachingCard[]>) => {
      state.dailyCards = action.payload;
    },
    completeCard: (state, action: PayloadAction<string>) => {
      const cardIndex = state.dailyCards.findIndex(
        card => card.id === action.payload,
      );
      if (cardIndex !== -1) {
        const completedCard = {
          ...state.dailyCards[cardIndex],
          status: 'completed' as const,
          completedAt: new Date().toISOString(),
        };
        state.completedCards.unshift(completedCard);
        state.dailyCards.splice(cardIndex, 1);
      }
    },
    dismissCard: (state, action: PayloadAction<string>) => {
      const cardIndex = state.dailyCards.findIndex(
        card => card.id === action.payload,
      );
      if (cardIndex !== -1) {
        state.dailyCards[cardIndex].status = 'dismissed';
        state.dailyCards[cardIndex].dismissedAt = new Date().toISOString();
      }
    },
    snoozeCard: (state, action: PayloadAction<{id: string; until: string}>) => {
      const cardIndex = state.dailyCards.findIndex(
        card => card.id === action.payload.id,
      );
      if (cardIndex !== -1) {
        state.dailyCards[cardIndex].status = 'snoozed';
        state.dailyCards[cardIndex].snoozedUntil = action.payload.until;
      }
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
    },
    clearError: state => {
      state.error = null;
    },
  },
});

export const {
  setLoading,
  setDailyCards,
  completeCard,
  dismissCard,
  snoozeCard,
  setError,
  clearError,
} = cardsSlice.actions;
export default cardsSlice.reducer;
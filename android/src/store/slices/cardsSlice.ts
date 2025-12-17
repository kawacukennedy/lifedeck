import {createSlice, PayloadAction, createAsyncThunk} from '@reduxjs/toolkit';
import {cardsAPI} from '../../services/api';

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

// Async thunks
export const loadDailyCards = createAsyncThunk(
  'cards/loadDailyCards',
  async (_, { rejectWithValue }) => {
    try {
      const response = await cardsAPI.getDailyCards();
      return response.data;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to load cards');
    }
  },
);

export const completeCardAsync = createAsyncThunk(
  'cards/completeCard',
  async (cardId: string, { rejectWithValue }) => {
    try {
      const response = await cardsAPI.completeCard(cardId);
      return { cardId, card: response.data };
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to complete card');
    }
  },
);

export const dismissCardAsync = createAsyncThunk(
  'cards/dismissCard',
  async (cardId: string, { rejectWithValue }) => {
    try {
      await cardsAPI.dismissCard(cardId);
      return cardId;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to dismiss card');
    }
  },
);

export const snoozeCardAsync = createAsyncThunk(
  'cards/snoozeCard',
  async ({ id, until }: { id: string; until: string }, { rejectWithValue }) => {
    try {
      await cardsAPI.snoozeCard(id, until);
      return { id, until };
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || 'Failed to snooze card');
    }
  },
);

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
      state.error = null;
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
        state.dailyCards.splice(cardIndex, 1); // Remove dismissed cards
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
  extraReducers: (builder) => {
    builder
      .addCase(loadDailyCards.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(loadDailyCards.fulfilled, (state, action) => {
        state.isLoading = false;
        state.dailyCards = action.payload;
        state.error = null;
      })
      .addCase(loadDailyCards.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      })
      .addCase(completeCardAsync.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(completeCardAsync.fulfilled, (state, action) => {
        state.isLoading = false;
        // The card completion is handled by the fulfilled action
        const cardIndex = state.dailyCards.findIndex(
          card => card.id === action.payload.cardId,
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
      })
      .addCase(completeCardAsync.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      })
      .addCase(dismissCardAsync.fulfilled, (state, action) => {
        state.dailyCards = state.dailyCards.filter(card => card.id !== action.payload);
      })
      .addCase(snoozeCardAsync.fulfilled, (state, action) => {
        const cardIndex = state.dailyCards.findIndex(
          card => card.id === action.payload.id,
        );
        if (cardIndex !== -1) {
          state.dailyCards[cardIndex].status = 'snoozed';
          state.dailyCards[cardIndex].snoozedUntil = action.payload.until;
        }
      });
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

export { loadDailyCards, completeCardAsync, dismissCardAsync, snoozeCardAsync };
export default cardsSlice.reducer;
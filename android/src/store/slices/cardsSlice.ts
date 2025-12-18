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
  async (cardId: string, { getState, dispatch, rejectWithValue }) => {
    const state = getState() as any;
    const isOnline = state.cards.isOnline;

    if (!isOnline) {
      // Add to pending actions for offline sync
      dispatch(addPendingAction({
        id: `complete-${cardId}-${Date.now()}`,
        type: 'complete',
        cardId,
        timestamp: Date.now(),
      }));
      // Still update local state immediately
      return { cardId, offline: true };
    }

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

export const syncPendingActions = createAsyncThunk(
  'cards/syncPendingActions',
  async (_, { getState, dispatch, rejectWithValue }) => {
    const state = getState() as any;
    const pendingActions = state.cards.pendingActions;

    if (pendingActions.length === 0) return;

    const results = [];

    for (const action of pendingActions) {
      try {
        switch (action.type) {
          case 'complete':
            await cardsAPI.completeCard(action.cardId);
            break;
          case 'dismiss':
            await cardsAPI.dismissCard(action.cardId);
            break;
          case 'snooze':
            await cardsAPI.snoozeCard(action.cardId, action.data.until);
            break;
        }
        results.push({ id: action.id, success: true });
        dispatch(removePendingAction(action.id));
      } catch (error) {
        results.push({ id: action.id, success: false, error });
      }
    }

    return results;
  },
);

interface PendingAction {
  id: string;
  type: 'complete' | 'dismiss' | 'snooze';
  cardId: string;
  data?: any;
  timestamp: number;
}

interface CardsState {
  dailyCards: CoachingCard[];
  completedCards: CoachingCard[];
  isLoading: boolean;
  error: string | null;
  isOnline: boolean;
  pendingActions: PendingAction[];
}

const initialState: CardsState = {
  dailyCards: [],
  completedCards: [],
  isLoading: false,
  error: null,
  isOnline: true,
  pendingActions: [],
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
    setOnlineStatus: (state, action: PayloadAction<boolean>) => {
      state.isOnline = action.payload;
      if (action.payload) {
        // Trigger sync when coming back online
        // This will be handled by middleware
      }
    },
    addPendingAction: (state, action: PayloadAction<PendingAction>) => {
      state.pendingActions.push(action.payload);
    },
    removePendingAction: (state, action: PayloadAction<string>) => {
      state.pendingActions = state.pendingActions.filter(
        pending => pending.id !== action.payload
      );
    },
    clearPendingActions: state => {
      state.pendingActions = [];
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
      })
      .addCase(syncPendingActions.fulfilled, (state, action) => {
        // Handle sync results if needed
        console.log('Sync completed:', action.payload);
      })
      .addCase(syncPendingActions.rejected, (state, action) => {
        console.error('Sync failed:', action.payload);
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
  setOnlineStatus,
  addPendingAction,
  removePendingAction,
  clearPendingActions,
} = cardsSlice.actions;

export { loadDailyCards, completeCardAsync, dismissCardAsync, snoozeCardAsync, syncPendingActions };
export default cardsSlice.reducer;
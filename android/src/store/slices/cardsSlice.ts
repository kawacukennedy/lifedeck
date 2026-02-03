import { createSlice, PayloadAction, createAsyncThunk } from '@reduxjs/toolkit';

export interface Card {
    id: string;
    title: string;
    subtitle: string;
    domain: 'HEALTH' | 'FINANCE' | 'PRODUCTIVITY' | 'MINDFULNESS';
    action: string;
    points: number;
    isPremium: boolean;
    isCompleted: boolean;
    isDismissed: boolean;
}

interface CardsState {
    dailyCards: Card[];
    isLoading: boolean;
    error: string | null;
}

const initialState: CardsState = {
    dailyCards: [],
    isLoading: false,
    error: null,
};

// Mock async thunk for loading cards
export const loadDailyCards = createAsyncThunk('cards/loadDailyCards', async () => {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 2000));

    const mockCards: Card[] = [
        {
            id: '1',
            title: 'Morning Hydration',
            subtitle: 'Health & Vitality',
            domain: 'HEALTH',
            action: 'Drink 500ml of water right now',
            points: 10,
            isPremium: false,
            isCompleted: false,
            isDismissed: false,
        },
        {
            id: '2',
            title: 'Mindful Minute',
            subtitle: 'Mental Clarity',
            domain: 'MINDFULNESS',
            action: 'Take 10 deep breaths',
            points: 15,
            isPremium: false,
            isCompleted: false,
            isDismissed: false,
        },
        {
            id: '3',
            title: 'Subscription Check',
            subtitle: 'Financial Discipline',
            domain: 'FINANCE',
            action: 'Review your recurring subscriptions',
            points: 20,
            isPremium: true,
            isCompleted: false,
            isDismissed: false,
        },
    ];
    return mockCards;
});

const cardsSlice = createSlice({
    name: 'cards',
    initialState,
    reducers: {
        completeCard: (state, action: PayloadAction<string>) => {
            const card = state.dailyCards.find(c => c.id === action.payload);
            if (card) card.isCompleted = true;
        },
        dismissCard: (state, action: PayloadAction<string>) => {
            const card = state.dailyCards.find(c => c.id === action.payload);
            if (card) card.isDismissed = true;
        },
        snoozeCard: (state, action: PayloadAction<{ id: string; until: string }>) => {
            state.dailyCards = state.dailyCards.filter(c => c.id !== action.payload.id);
        },
    },
    extraReducers: (builder) => {
        builder
            .addCase(loadDailyCards.pending, (state) => {
                state.isLoading = true;
            })
            .addCase(loadDailyCards.fulfilled, (state, action) => {
                state.isLoading = false;
                state.dailyCards = action.payload;
            })
            .addCase(loadDailyCards.rejected, (state, action) => {
                state.isLoading = false;
                state.error = action.error.message || 'Failed to load cards';
            });
    },
});

export const { completeCard, dismissCard, snoozeCard } = cardsSlice.actions;
export default cardsSlice.reducer;

import {createSlice, PayloadAction} from '@reduxjs/toolkit';

interface UiState {
  theme: 'light' | 'dark';
  language: string;
  notificationsEnabled: boolean;
  hapticEnabled: boolean;
  soundEnabled: boolean;
}

const initialState: UiState = {
  theme: 'dark', // LifeDeck uses dark theme by default
  language: 'en',
  notificationsEnabled: true,
  hapticEnabled: true,
  soundEnabled: true,
};

const uiSlice = createSlice({
  name: 'ui',
  initialState,
  reducers: {
    setTheme: (state, action: PayloadAction<'light' | 'dark'>) => {
      state.theme = action.payload;
    },
    setLanguage: (state, action: PayloadAction<string>) => {
      state.language = action.payload;
    },
    setNotificationsEnabled: (state, action: PayloadAction<boolean>) => {
      state.notificationsEnabled = action.payload;
    },
    setHapticEnabled: (state, action: PayloadAction<boolean>) => {
      state.hapticEnabled = action.payload;
    },
    setSoundEnabled: (state, action: PayloadAction<boolean>) => {
      state.soundEnabled = action.payload;
    },
  },
});

export const {
  setTheme,
  setLanguage,
  setNotificationsEnabled,
  setHapticEnabled,
  setSoundEnabled,
} = uiSlice.actions;
export default uiSlice.reducer;
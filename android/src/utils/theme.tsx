import React, {createContext, useContext} from 'react';
import {useSelector} from 'react-redux';
import {RootState} from '../store';

interface Theme {
  colors: {
    background: string;
    surface: string;
    primary: string;
    secondary: string;
    text: string;
    textSecondary: string;
    border: string;
  };
}

const lightTheme: Theme = {
  colors: {
    background: '#ffffff',
    surface: '#f5f5f5',
    primary: '#2196F3',
    secondary: '#4CAF50',
    text: '#212121',
    textSecondary: '#757575',
    border: '#e0e0e0',
  },
};

const darkTheme: Theme = {
  colors: {
    background: '#121212',
    surface: '#1e1e1e',
    primary: '#2196F3',
    secondary: '#4CAF50',
    text: '#ffffff',
    textSecondary: '#bbbbbb',
    border: '#333333',
  },
};

const ThemeContext = createContext<Theme>(darkTheme);

export const useTheme = () => useContext(ThemeContext);

interface ThemeProviderProps {
  children: React.ReactNode;
}

export const ThemeProvider: React.FC<ThemeProviderProps> = ({children}) => {
  const themeType = useSelector((state: RootState) => state.ui.theme);
  const theme = themeType === 'dark' ? darkTheme : lightTheme;

  return (
    <ThemeContext.Provider value={theme}>{children}</ThemeContext.Provider>
  );
};
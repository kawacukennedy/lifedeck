import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

const API_BASE_URL = __DEV__ ? 'http://localhost:3000/v1' : 'https://api.lifedeck.app/v1';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  async config => {
    try {
      const token = await AsyncStorage.getItem('auth_token');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    } catch (error) {
      console.error('Failed to get auth token:', error);
    }
    return config;
  },
  error => {
    return Promise.reject(error);
  },
);

// Response interceptor for error handling
api.interceptors.response.use(
  response => response,
  async error => {
    if (error.response?.status === 401) {
      // Token expired or invalid, clear it
      await AsyncStorage.removeItem('auth_token');
      // Could dispatch logout action here
      console.log('Unauthorized access - token cleared');
    }
    return Promise.reject(error);
  },
);

export const authAPI = {
  login: (email: string, password: string) =>
    api.post('/auth/login', {email, password}),

  register: (email: string, password: string, name?: string) =>
    api.post('/auth/register', {email, password, name}),

  getProfile: () => api.get('/auth/profile'),

  // OAuth endpoints
  googleAuth: () => api.get('/auth/google'),
  appleAuth: () => api.get('/auth/apple'),
};

export const cardsAPI = {
  getDailyCards: () => api.get('/cards/daily'),
  completeCard: (cardId: string) => api.patch(`/cards/${cardId}/complete`),
  dismissCard: (cardId: string) => api.patch(`/cards/${cardId}`, { status: 'DISMISSED' }),
  snoozeCard: (cardId: string, snoozeUntil: string) =>
    api.patch(`/cards/${cardId}`, { status: 'SNOOZED', snoozedUntil: snoozeUntil }),
};

export const analyticsAPI = {
  getAnalytics: (timeframe: 'week' | 'month' | 'year' = 'month') =>
    api.get(`/analytics?timeframe=${timeframe}`),
  getLifeScore: () => api.get('/analytics/life-score'),
  getTrends: (timeframe: 'week' | 'month' | 'year' = 'month') =>
    api.get(`/analytics/trends?timeframe=${timeframe}`),
  getInsights: (timeframe: 'week' | 'month' | 'year' = 'month') =>
    api.get(`/analytics/insights?timeframe=${timeframe}`),
};

export const usersAPI = {
  updateProfile: (profileData: any) => api.patch('/users/profile', profileData),
  updateSettings: (settings: any) => api.patch('/users/settings', settings),
};

export const subscriptionsAPI = {
  getStatus: () => api.get('/subscriptions/status'),
  createSubscription: (subscriptionData: any) => api.post('/subscriptions', subscriptionData),
};

export const notificationsAPI = {
  registerDevice: (token: string, platform: string) =>
    api.post('/notifications/register-device', { token, platform }),
  updateSettings: (settings: any) => api.patch('/notifications/settings', settings),
};

export default api;
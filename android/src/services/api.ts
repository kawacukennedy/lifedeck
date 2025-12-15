import axios from 'axios';

const API_BASE_URL = 'http://localhost:3000/v1'; // Change to production URL

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  config => {
    // Add auth token if available
    // const token = await AsyncStorage.getItem('auth_token');
    // if (token) {
    //   config.headers.Authorization = `Bearer ${token}`;
    // }
    return config;
  },
  error => {
    return Promise.reject(error);
  },
);

// Response interceptor for error handling
api.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      // Handle unauthorized access
      console.log('Unauthorized access');
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
};

export const cardsAPI = {
  getDailyCards: () => api.get('/cards/daily'),
  completeCard: (cardId: string) => api.patch(`/cards/${cardId}/complete`),
};

export const analyticsAPI = {
  getAnalytics: () => api.get('/analytics'),
  getLifeScore: () => api.get('/analytics/life-score'),
};

export default api;
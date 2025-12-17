import axios from 'axios';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/v1';

class ApiService {
  private axiosInstance;

  constructor() {
    this.axiosInstance = axios.create({
      baseURL: API_BASE_URL,
      timeout: 10000,
    });

    // Add request interceptor to include auth token
    this.axiosInstance.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem('auth_token');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => {
        return Promise.reject(error);
      }
    );

    // Add response interceptor for error handling
    this.axiosInstance.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response?.status === 401) {
          // Token expired, redirect to login
          localStorage.removeItem('auth_token');
          window.location.href = '/login';
        }
        return Promise.reject(error);
      }
    );
  }

  // Auth endpoints
  async login(email: string, password: string) {
    const response = await this.axiosInstance.post('/auth/login', { email, password });
    return response.data;
  }

  async register(email: string, password: string, name?: string) {
    const response = await this.axiosInstance.post('/auth/register', { email, password, name });
    return response.data;
  }

  async getProfile() {
    const response = await this.axiosInstance.get('/auth/profile');
    return response.data;
  }

  // Cards endpoints
  async getDailyCards() {
    const response = await this.axiosInstance.get('/cards/daily');
    return response.data;
  }

  async completeCard(cardId: string) {
    const response = await this.axiosInstance.patch(`/cards/${cardId}/complete`);
    return response.data;
  }

  async dismissCard(cardId: string) {
    const response = await this.axiosInstance.patch(`/cards/${cardId}`, { status: 'DISMISSED' });
    return response.data;
  }

  async snoozeCard(cardId: string, snoozeUntil: string) {
    const response = await this.axiosInstance.patch(`/cards/${cardId}`, {
      status: 'SNOOZED',
      snoozedUntil
    });
    return response.data;
  }

  // Analytics endpoints
  async getAnalytics() {
    const response = await this.axiosInstance.get('/analytics');
    return response.data;
  }

  async getLifeScore() {
    const response = await this.axiosInstance.get('/analytics/life-score');
    return response.data;
  }

  // User endpoints
  async updateProfile(profileData: any) {
    const response = await this.axiosInstance.patch('/users/profile', profileData);
    return response.data;
  }

  async updateSettings(settings: any) {
    const response = await this.axiosInstance.patch('/users/settings', settings);
    return response.data;
  }

  // Subscription endpoints
  async getSubscriptionStatus() {
    const response = await this.axiosInstance.get('/subscriptions/status');
    return response.data;
  }

  async createSubscription(subscriptionData: any) {
    const response = await this.axiosInstance.post('/subscriptions', subscriptionData);
    return response.data;
  }
}

export const apiService = new ApiService();
export default apiService;
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
  async getAnalytics(timeframe?: 'week' | 'month' | 'year') {
    const params = timeframe ? { timeframe } : {};
    const response = await this.axiosInstance.get('/analytics', { params });
    return response.data;
  }

  async getLifeScore() {
    const response = await this.axiosInstance.get('/analytics/life-score');
    return response.data;
  }

  async getDomainAnalytics(domain: string) {
    const response = await this.axiosInstance.get(`/analytics/domain/${domain}`);
    return response.data;
  }

  async getInsights(timeframe?: 'week' | 'month' | 'year') {
    const params = timeframe ? { timeframe } : {};
    const response = await this.axiosInstance.get('/analytics/insights', { params });
    return response.data;
  }

  async getTrends(timeframe?: 'week' | 'month' | 'year') {
    const params = timeframe ? { timeframe } : {};
    const response = await this.axiosInstance.get('/analytics/trends', { params });
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
    const response = await this.axiosInstance.get('/subscriptions');
    return response.data;
  }

  async createSubscription(subscriptionData: any) {
    const response = await this.axiosInstance.post('/subscriptions/upgrade', subscriptionData);
    return response.data;
  }

  async cancelSubscription() {
    const response = await this.axiosInstance.post('/subscriptions/cancel');
    return response.data;
  }

  async getPremiumFeatures() {
    const response = await this.axiosInstance.get('/subscriptions/features');
    return response.data;
  }

  // Stripe-specific subscription endpoints
  async createStripeCustomer(paymentMethodId: string) {
    const response = await this.axiosInstance.post('/subscriptions/stripe/create-customer', { paymentMethodId });
    return response.data;
  }

  async createStripeSubscription(customerId: string, priceId: string) {
    const response = await this.axiosInstance.post('/subscriptions/stripe/create-subscription', { customerId, priceId });
    return response.data;
  }

  async getStripeProducts() {
    const response = await this.axiosInstance.get('/subscriptions/stripe/products');
    return response.data;
  }

  async cancelStripeSubscription(subscriptionId: string) {
    const response = await this.axiosInstance.post('/subscriptions/stripe/cancel', { subscriptionId });
    return response.data;
  }

  // Achievement endpoints
  async getUserAchievements() {
    const response = await this.axiosInstance.get('/achievements');
    return response.data;
  }

  async getAvailableAchievements() {
    const response = await this.axiosInstance.get('/achievements/available');
    return response.data;
  }

  async getAchievementStats() {
    const response = await this.axiosInstance.get('/achievements/stats');
    return response.data;
  }

  async checkAchievements() {
    const response = await this.axiosInstance.get('/achievements/check');
    return response.data;
  }
}

export const apiService = new ApiService();
export default apiService;
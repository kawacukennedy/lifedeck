import { getMessaging, getToken, onMessage } from 'firebase/messaging';
import { initializeApp } from 'firebase/app';
import toast from 'react-hot-toast';

// Firebase configuration (replace with your actual config)
const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY || 'your-api-key',
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN || 'your-project.firebaseapp.com',
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID || 'your-project-id',
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET || 'your-project.appspot.com',
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID || '123456789',
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID || 'your-app-id',
};

class WebNotificationService {
  private messaging: any = null;
  private isInitialized = false;

  async initialize() {
    if (this.isInitialized || typeof window === 'undefined') return;

    try {
      const app = initializeApp(firebaseConfig);
      this.messaging = getMessaging(app);

      // Request permission and get token
      const permission = await Notification.requestPermission();
      if (permission === 'granted') {
        const token = await getToken(this.messaging, {
          vapidKey: process.env.NEXT_PUBLIC_FIREBASE_VAPID_KEY,
        });

        if (token) {
          await this.registerDeviceToken(token);
        }
      }

      // Handle incoming messages
      onMessage(this.messaging, (payload) => {
        this.handleIncomingMessage(payload);
      });

      this.isInitialized = true;
    } catch (error) {
      console.error('Failed to initialize notifications:', error);
    }
  }

  async registerDeviceToken(token: string) {
    try {
      const { apiService } = await import('./api');
      await apiService.registerDevice(token, 'web');
      console.log('Web device token registered successfully');
    } catch (error) {
      console.error('Failed to register web device token:', error);
    }
  }

  scheduleDailyReminder(hour: number = 9, minute: number = 0) {
    // For web, we can't schedule local notifications like native apps
    // Instead, we'll show a toast reminder
    this.scheduleReminder(hour, minute, 'Daily LifeDeck Reminder', 'Time for your coaching cards! 🃏');
  }

  scheduleCardReminder(cardTitle: string, delayMinutes: number = 60) {
    const reminderTime = new Date();
    reminderTime.setMinutes(reminderTime.getMinutes() + delayMinutes);

    // In a real implementation, you'd use service workers for background notifications
    // For now, just show a toast
    setTimeout(() => {
      toast(`Don't forget: ${cardTitle}`, {
        icon: '🃏',
        duration: 5000,
      });
    }, delayMinutes * 60 * 1000);
  }

  sendStreakCelebration(streakCount: number) {
    const messages = {
      3: 'Great start! You\'re building momentum! 🔥',
      7: 'One week strong! You\'re unstoppable! 💪',
      14: 'Two weeks! Your habits are becoming second nature! 🌟',
      30: '30 days! You\'re a habit master! 🏆',
      50: '50 days! Legendary commitment! 👑',
      100: '100 days! You\'re absolutely incredible! 🎉',
    };

    const message = messages[streakCount] || `${streakCount} day streak! Keep it up! 🚀`;

    toast(message, {
      duration: 6000,
      icon: '🔥',
      style: {
        background: '#4CAF50',
        color: '#fff',
      },
    });
  }

  sendAchievementNotification(achievementTitle: string) {
    toast(`🏆 Achievement Unlocked: ${achievementTitle}`, {
      duration: 6000,
      icon: '🏆',
      style: {
        background: '#FFD700',
        color: '#000',
      },
    });
  }

  sendContextAwareNotification(context: {
    location?: string;
    timeOfDay?: string;
    activity?: string;
    weather?: string;
  }) {
    let title = 'LifeDeck Moment';
    let body = 'A timely reminder for your well-being';

    // Customize based on context
    if (context.timeOfDay === 'morning' && context.weather === 'sunny') {
      title = 'Good Morning! ☀️';
      body = 'Perfect weather for a mindful walk. Ready to start your day?';
    } else if (context.location === 'work' && context.timeOfDay === 'afternoon') {
      title = 'Afternoon Break';
      body = 'Take 5 minutes for a quick mindfulness exercise at your desk.';
    } else if (context.activity === 'commuting') {
      title = 'Commute Time';
      body = 'Use this time for a breathing exercise or gratitude reflection.';
    }

    toast(body, {
      duration: 8000,
      icon: '💡',
      style: {
        background: '#3B6BA5',
        color: '#fff',
      },
    });
  }

  sendWeeklySummary(summary: {
    lifeScore: number;
    cardsCompleted: number;
    currentStreak: number;
  }) {
    const { lifeScore, cardsCompleted, currentStreak } = summary;
    const message = `This week: ${cardsCompleted} cards completed, ${currentStreak} day streak, Life Score: ${lifeScore}%`;

    toast(message, {
      duration: 10000,
      icon: '📊',
      style: {
        background: '#2196F3',
        color: '#fff',
      },
    });
  }

  showCardCompletedToast(cardTitle: string) {
    toast.success(`Completed: ${cardTitle}`, {
      duration: 3000,
    });
  }

  showWelcomeToast() {
    toast('Welcome to LifeDeck! 🃏', {
      duration: 4000,
    });
  }

  private scheduleReminder(hour: number, minute: number, title: string, body: string) {
    // This is a simplified implementation
    // In production, you'd use a service worker for background notifications
    const now = new Date();
    const reminderTime = new Date();
    reminderTime.setHours(hour, minute, 0, 0);

    if (reminderTime <= now) {
      reminderTime.setDate(reminderTime.getDate() + 1);
    }

    const delay = reminderTime.getTime() - now.getTime();

    setTimeout(() => {
      if ('Notification' in window && Notification.permission === 'granted') {
        new Notification(title, {
          body,
          icon: '/icon-192x192.png',
        });
      } else {
        toast(body, {
          icon: '🃏',
          duration: 5000,
        });
      }
    }, delay);
  }

  private handleIncomingMessage(payload: any) {
    const { notification, data } = payload;

    if (notification) {
      toast(notification.body || 'New notification', {
        title: notification.title,
        duration: 5000,
      });
    }

    // Handle specific notification types
    if (data?.type === 'card_reminder') {
      // Could navigate to deck or show special UI
    } else if (data?.type === 'achievement') {
      // Show achievement celebration
    }
  }
}

export const webNotificationService = new WebNotificationService();
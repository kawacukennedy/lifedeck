import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import * as admin from 'firebase-admin';

@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService) {
    // Initialize Firebase Admin SDK
    if (!admin.apps.length) {
      const serviceAccount = require(process.env.FIREBASE_SERVICE_ACCOUNT_KEY || './firebase-service-account.json');
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    }
  }

  async scheduleDailyReminder(userId: string) {
    // Get user's notification settings
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { settings: true },
    });

    if (!user?.settings?.notificationsEnabled) return;

    const reminderTime = user.settings.dailyReminderTime || new Date('09:00:00');
    const reminderDate = new Date();
    reminderDate.setHours(reminderTime.getHours(), reminderTime.getMinutes(), 0, 0);

    // If reminder time has passed today, schedule for tomorrow
    if (reminderDate <= new Date()) {
      reminderDate.setDate(reminderDate.getDate() + 1);
    }

    // Schedule the notification (in production, use a job queue)
    console.log(`Scheduling daily reminder for user ${userId} at ${reminderDate}`);

    // For now, send immediately for testing
    await this.sendPushNotification(
      userId,
      'Daily LifeDeck Reminder',
      'Time for your daily coaching cards! 🃏',
      { type: 'daily_reminder', scheduledTime: reminderDate.toISOString() }
    );
  }

  async sendCardReminder(userId: string, cardTitle: string) {
    await this.sendPushNotification(
      userId,
      'Card Reminder',
      `Don't forget: "${cardTitle}"`,
      { type: 'card_reminder', cardTitle }
    );
  }

  async sendStreakCelebration(userId: string, streakCount: number) {
    const messages = {
      3: 'Great start! You\'re building momentum! 🔥',
      7: 'One week strong! You\'re unstoppable! 💪',
      14: 'Two weeks! Your habits are becoming second nature! 🌟',
      30: '30 days! You\'re a habit master! 🏆',
      50: '50 days! Legendary commitment! 👑',
      100: '100 days! You\'re absolutely incredible! 🎉',
    };

    const message = messages[streakCount] || `${streakCount} day streak! Keep it up! 🚀`;

    await this.sendPushNotification(
      userId,
      `${streakCount} Day Streak!`,
      message,
      { type: 'streak_celebration', streakCount: streakCount.toString() }
    );
  }

  async sendWeeklySummary(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { progress: true },
    });

    if (!user?.progress) return;

    const { lifeScore, totalCardsCompleted, currentStreak } = user.progress;
    const summary = `This week: ${totalCardsCompleted} cards completed, ${currentStreak} day streak, Life Score: ${lifeScore}%`;

    await this.sendPushNotification(
      userId,
      'Weekly Progress Summary',
      summary,
      {
        type: 'weekly_summary',
        lifeScore: lifeScore.toString(),
        cardsCompleted: totalCardsCompleted.toString(),
        currentStreak: currentStreak.toString()
      }
    );
  }

  async registerDeviceToken(userId: string, token: string, platform: 'ios' | 'android' | 'web') {
    try {
      const platformEnum = platform.toUpperCase() as 'IOS' | 'ANDROID' | 'WEB';

      // Upsert device token
      await this.prisma.deviceToken.upsert({
        where: {
          token: token,
        },
        update: {
          userId,
          platform: platformEnum,
          updatedAt: new Date(),
        },
        create: {
          userId,
          token,
          platform: platformEnum,
        },
      });

      console.log(`Registered ${platform} device token for user ${userId}`);
    } catch (error) {
      console.error('Error registering device token:', error);
      throw error;
    }
  }

  async sendPushNotification(userId: string, title: string, body: string, data?: any) {
    try {
      // Get user's device tokens
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
        include: { settings: true },
      });

      if (!user?.settings?.notificationsEnabled) return;

      // In a real implementation, you'd have a DeviceToken model
      // For now, we'll assume tokens are stored elsewhere or use a mock
      const deviceTokens = await this.getUserDeviceTokens(userId);

      if (deviceTokens.length === 0) {
        console.log(`No device tokens found for user ${userId}`);
        return;
      }

      const message = {
        notification: {
          title,
          body,
        },
        data: data ? Object.fromEntries(
          Object.entries(data).map(([key, value]) => [key, String(value)])
        ) : {},
        tokens: deviceTokens,
      };

      const response = await admin.messaging().sendMulticast(message);
      console.log(`Sent notification to ${response.successCount} devices, ${response.failureCount} failures`);

      // Handle failures
      if (response.failureCount > 0) {
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            console.error(`Failed to send to token ${deviceTokens[idx]}:`, resp.error);
            // In production, remove invalid tokens
          }
        });
      }
    } catch (error) {
      console.error('Error sending push notification:', error);
    }
  }

  private async getUserDeviceTokens(userId: string): Promise<string[]> {
    try {
      const deviceTokens = await this.prisma.deviceToken.findMany({
        where: { userId },
        select: { token: true },
      });

      return deviceTokens.map(dt => dt.token);
    } catch (error) {
      console.error('Error fetching device tokens:', error);
      return [];
    }
  }

  async sendContextAwareNotification(userId: string, context: {
    location?: string;
    timeOfDay?: string;
    activity?: string;
    weather?: string;
  }) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { progress: true, settings: true },
    });

    if (!user?.settings?.notificationsEnabled || !user.settings.locationEnabled) return;

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

    await this.sendPushNotification(userId, title, body, {
      type: 'context_aware',
      context: JSON.stringify(context)
    });
  }
}
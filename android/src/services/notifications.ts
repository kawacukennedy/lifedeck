import PushNotification from 'react-native-push-notification';
import { Platform } from 'react-native';

class NotificationService {
  private isInitialized = false;

  initialize() {
    if (this.isInitialized) return;

    PushNotification.configure({
      onRegister: (token) => {
        console.log('Device token:', token);
        // Send token to backend
        this.registerDeviceToken(token.token);
      },

      onNotification: (notification) => {
        console.log('Notification received:', notification);

        // Handle notification tap
        if (notification.userInteraction) {
          this.handleNotificationTap(notification);
        }
      },

      permissions: {
        alert: true,
        badge: true,
        sound: true,
      },

      popInitialNotification: true,
      requestPermissions: Platform.OS === 'ios',
    });

    // Create notification channel for Android
    if (Platform.OS === 'android') {
      PushNotification.createChannel(
        {
          channelId: 'lifedeck-reminders',
          channelName: 'LifeDeck Reminders',
          channelDescription: 'Daily coaching card reminders',
          soundName: 'default',
          importance: 4,
          vibrate: true,
        },
        (created) => console.log(`Channel created: ${created}`),
      );

      PushNotification.createChannel(
        {
          channelId: 'lifedeck-achievements',
          channelName: 'LifeDeck Achievements',
          channelDescription: 'Achievement notifications',
          soundName: 'default',
          importance: 3,
          vibrate: true,
        },
        (created) => console.log(`Channel created: ${created}`),
      );
    }

    this.isInitialized = true;
  }

  scheduleDailyReminder(hour: number = 9, minute: number = 0) {
    PushNotification.localNotificationSchedule({
      channelId: 'lifedeck-reminders',
      title: 'LifeDeck Reminder',
      message: 'Time for your daily coaching cards! 🃏',
      date: this.getNextNotificationTime(hour, minute),
      repeatType: 'day',
      id: 1,
    });
  }

  scheduleCardReminder(cardTitle: string, delayMinutes: number = 60) {
    const reminderTime = new Date();
    reminderTime.setMinutes(reminderTime.getMinutes() + delayMinutes);

    PushNotification.localNotificationSchedule({
      channelId: 'lifedeck-reminders',
      title: 'Card Reminder',
      message: `Don't forget: ${cardTitle}`,
      date: reminderTime,
      id: Date.now(), // Unique ID
    });
  }

  sendStreakCelebration(streakCount: number) {
    PushNotification.localNotification({
      channelId: 'lifedeck-achievements',
      title: '🎉 Streak Celebration!',
      message: `Amazing! You've maintained a ${streakCount}-day streak!`,
      id: Date.now(),
    });
  }

  sendAchievementNotification(achievementTitle: string) {
    PushNotification.localNotification({
      channelId: 'lifedeck-achievements',
      title: '🏆 Achievement Unlocked!',
      message: `Congratulations! You unlocked: ${achievementTitle}`,
      id: Date.now(),
    });
  }

  cancelAllNotifications() {
    PushNotification.cancelAllLocalNotifications();
  }

  private getNextNotificationTime(hour: number, minute: number): Date {
    const now = new Date();
    const notificationTime = new Date();

    notificationTime.setHours(hour, minute, 0, 0);

    // If the time has already passed today, schedule for tomorrow
    if (notificationTime <= now) {
      notificationTime.setDate(notificationTime.getDate() + 1);
    }

    return notificationTime;
  }

  private async registerDeviceToken(token: string) {
    try {
      // Send token to backend
      const response = await fetch('http://localhost:3000/v1/notifications/register-device', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          // Add auth token
        },
        body: JSON.stringify({
          token,
          platform: Platform.OS,
        }),
      });

      if (response.ok) {
        console.log('Device token registered successfully');
      }
    } catch (error) {
      console.error('Failed to register device token:', error);
    }
  }

  private handleNotificationTap(notification: any) {
    // Handle different notification types
    const { data } = notification;

    if (data?.type === 'card_reminder') {
      // Navigate to deck screen
      console.log('Navigate to deck screen');
    } else if (data?.type === 'achievement') {
      // Navigate to profile/achievements
      console.log('Navigate to achievements');
    }
  }
}

export const notificationService = new NotificationService();
import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';

Notifications.setNotificationHandler({
    handleNotification: async () => ({
        shouldShowAlert: true,
        shouldPlaySound: true,
        shouldSetBadge: true,
    }),
});

export const requestNotificationPermissions = async () => {
    const { status: existingStatus } = await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;
    if (existingStatus !== 'granted') {
        const { status } = await Notifications.requestPermissionsAsync();
        finalStatus = status;
    }
    return finalStatus === 'granted';
};

export const scheduleDailyReminder = async (time: string) => {
    const [hours, minutes] = time.split(':').map(Number);

    await Notifications.cancelAllScheduledNotificationsAsync();

    await Notifications.scheduleNotificationAsync({
        content: {
            title: "Your Daily Deck is Ready! 🃏",
            body: "Take a moment to optimize your day with curated micro-actions.",
            data: { screen: 'Deck' },
        },
        trigger: {
            hour: hours,
            minute: minutes,
            repeats: true,
        },
    });
};

export const scheduleMotivationalPing = async () => {
    await Notifications.scheduleNotificationAsync({
        content: {
            title: "Sticking to it! 🔥",
            body: "You're doing great. Complete one more card to keep your streak alive.",
        },
        trigger: {
            seconds: 3600 * 4, // 4 hours later
        },
    });
};

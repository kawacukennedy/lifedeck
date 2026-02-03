import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useSelector } from 'react-redux';
import { RootState } from '../store';
import { theme } from '../utils/theme';

// Screens
import OnboardingScreen from '../screens/OnboardingScreen';
import DeckScreen from '../screens/DeckScreen';
import DashboardScreen from '../screens/DashboardScreen';
import ProfileScreen from '../screens/ProfileScreen';
import AchievementsScreen from '../screens/AchievementsScreen';

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

const MainTabs = () => (
    <Tab.Navigator
        screenOptions={{
            tabBarStyle: { backgroundColor: theme.colors.surface, borderTopColor: theme.colors.border },
            tabBarActiveTintColor: theme.colors.primary,
            tabBarInactiveTintColor: theme.colors.textDim,
            headerStyle: { backgroundColor: theme.colors.surface },
            headerTintColor: theme.colors.text,
        }}
    >
        <Tab.Screen name="Deck" component={DeckScreen} options={{ title: '🃏 Deck' }} />
        <Tab.Screen name="Dashboard" component={DashboardScreen} options={{ title: '📊 Progress' }} />
        <Tab.Screen name="Profile" component={ProfileScreen} options={{ title: '👤 Profile' }} />
    </Tab.Navigator>
);

const AppNavigator = () => {
    const hasCompletedOnboarding = useSelector((state: RootState) => state.user.hasCompletedOnboarding);

    return (
        <Stack.Navigator
            screenOptions={{
                headerShown: false,
                contentStyle: { backgroundColor: theme.colors.background },
            }}
        >
            {!hasCompletedOnboarding ? (
                <Stack.Screen name="Onboarding" component={OnboardingScreen} />
            ) : (
                <>
                    <Stack.Screen name="Main" component={MainTabs} />
                    <Stack.Screen name="Achievements" component={AchievementsScreen} options={{ headerShown: true, title: '🏆 Achievements', headerStyle: { backgroundColor: theme.colors.surface }, headerTintColor: theme.colors.text }} />
                </>
            )}
        </Stack.Navigator>
    );
};

export default AppNavigator;

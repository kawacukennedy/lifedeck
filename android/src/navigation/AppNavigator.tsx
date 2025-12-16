import React from 'react';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import {useSelector} from 'react-redux';
import Icon from 'react-native-vector-icons/MaterialIcons';

import DeckScreen from '../screens/DeckScreen';
import DashboardScreen from '../screens/DashboardScreen';
import ProfileScreen from '../screens/ProfileScreen';
import PremiumScreen from '../screens/PremiumScreen';
import DesignShowcaseScreen from '../screens/DesignShowcaseScreen';
import HelpScreen from '../screens/HelpScreen';
import OnboardingScreen from '../screens/OnboardingScreen';
import {RootState} from '../store';

const Tab = createBottomTabNavigator();
const Stack = createNativeStackNavigator();

const MainTabNavigator = () => {
  return (
    <Tab.Navigator
      screenOptions={({route}) => ({
        tabBarIcon: ({focused, color, size}) => {
          let iconName: string;

          if (route.name === 'Deck') {
            iconName = 'style';
          } else if (route.name === 'Dashboard') {
            iconName = 'analytics';
          } else if (route.name === 'Premium') {
            iconName = 'star';
          } else if (route.name === 'Design') {
            iconName = 'palette';
          } else if (route.name === 'Profile') {
            iconName = 'person';
          } else if (route.name === 'Help') {
            iconName = 'help';
          } else {
            iconName = 'circle';
          }

          return <Icon name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: '#2196F3',
        tabBarInactiveTintColor: '#888',
        tabBarStyle: {
          backgroundColor: '#1a1a1a',
          borderTopColor: '#333',
        },
        headerStyle: {
          backgroundColor: '#1a1a1a',
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
      })}>
      <Tab.Screen
        name="Deck"
        component={DeckScreen}
        options={{title: 'Daily Deck'}}
      />
      <Tab.Screen
        name="Dashboard"
        component={DashboardScreen}
        options={{title: 'Progress'}}
      />
      <Tab.Screen
        name="Premium"
        component={PremiumScreen}
        options={{title: 'Premium'}}
      />
      <Tab.Screen
        name="Design"
        component={DesignShowcaseScreen}
        options={{title: 'Design'}}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{title: 'Profile'}}
      />
      <Tab.Screen
        name="Help"
        component={HelpScreen}
        options={{title: 'Help'}}
      />
    </Tab.Navigator>
  );
};

const AppNavigator = () => {
  const user = useSelector((state: RootState) => state.user);

  return (
    <Stack.Navigator
      screenOptions={{
        headerStyle: {
          backgroundColor: '#1a1a1a',
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
      }}>
      {user?.hasCompletedOnboarding ? (
        <Stack.Screen
          name="Main"
          component={MainTabNavigator}
          options={{headerShown: false}}
        />
      ) : (
        <Stack.Screen
          name="Onboarding"
          component={OnboardingScreen}
          options={{headerShown: false}}
        />
      )}
    </Stack.Navigator>
  );
};

export default AppNavigator;
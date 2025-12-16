import React, {useEffect} from 'react';
import {Provider} from 'react-redux';
import {PersistGate} from 'react-redux/persist/integration/react';
import {NavigationContainer} from '@react-navigation/native';
import {SafeAreaProvider} from 'react-native-safe-area-context';

import {store, persistor} from './src/store';
import AppNavigator from './src/navigation/AppNavigator';
import {ThemeProvider} from './src/utils/theme';
import {notificationService} from './src/services/notifications';
import {locationService} from './src/services/LocationService';

const App = () => {
  useEffect(() => {
    // Initialize push notifications
    notificationService.initialize();

    // Schedule daily reminder
    notificationService.scheduleDailyReminder(9, 0); // 9 AM daily

    // Initialize location services
    initializeLocationServices();
  }, []);

  const initializeLocationServices = async () => {
    const hasPermission = await locationService.requestPermissions();
    if (hasPermission) {
      // Start location tracking for context-aware notifications
      locationService.startLocationTracking(
        async (location) => {
          // Send location update to backend for processing
          try {
            const contexts = locationService.getLocationContext(location);
            // TODO: Send to backend API
            console.log('Location update:', location, 'Contexts:', contexts);
          } catch (error) {
            console.error('Failed to process location update:', error);
          }
        },
        (error) => {
          console.error('Location tracking error:', error);
        },
      );
    }
  };

  return (
    <Provider store={store}>
      <PersistGate loading={null} persistor={persistor}>
        <SafeAreaProvider>
          <ThemeProvider>
            <NavigationContainer>
              <AppNavigator />
            </NavigationContainer>
          </ThemeProvider>
        </SafeAreaProvider>
      </PersistGate>
    </Provider>
  );
};

export default App;
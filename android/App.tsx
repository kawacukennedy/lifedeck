import React, {useEffect} from 'react';
import {Provider} from 'react-redux';
import {PersistGate} from 'react-redux/persist/integration/react';
import {NavigationContainer} from '@react-navigation/native';
import {SafeAreaProvider} from 'react-native-safe-area-context';

import {store, persistor} from './src/store';
import AppNavigator from './src/navigation/AppNavigator';
import {ThemeProvider} from './src/utils/theme';
import {notificationService} from './src/services/notifications';

const App = () => {
  useEffect(() => {
    // Initialize push notifications
    notificationService.initialize();

    // Schedule daily reminder
    notificationService.scheduleDailyReminder(9, 0); // 9 AM daily
  }, []);

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
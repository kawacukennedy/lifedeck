import React, { useState, useEffect, useCallback } from 'react';
import { Image } from 'react-native';
import { Provider } from 'react-redux';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { store, persistor } from './src/store';
import AppNavigator from './src/navigation/AppNavigator';
import { NavigationContainer } from '@react-navigation/native';
import { PersistGate } from 'redux-persist/integration/react';
import * as SplashScreen from 'expo-splash-screen';
import * as Font from 'expo-font';
import { Asset } from 'expo-asset';
import './src/utils/i18n';

// Keep the splash screen visible while we fetch resources
SplashScreen.preventAutoHideAsync();

export default function App() {
  const [appIsReady, setAppIsReady] = useState(false);

  useEffect(() => {
    async function prepare() {
      try {
        // Preload fonts, images, etc.
        const imageAssets = [
          require('./assets/icon.png'),
          require('./assets/splash.png'),
          require('./assets/adaptive-icon.png'),
        ];

        const fontAssets = {
          // Add custom fonts if needed
        };

        // Do not let asset failure block the app from starting
        await Promise.allSettled([
          ...cacheImages(imageAssets),
          Font.loadAsync(fontAssets)
        ]);
      } catch (e) {
        console.warn('Initialization error:', e);
      } finally {
        setAppIsReady(true);
      }
    }

    prepare();
  }, []);

  const onLayoutRootView = useCallback(async () => {
    if (appIsReady) {
      // This tells the splash screen to hide immediately!
      await SplashScreen.hideAsync();
    }
  }, [appIsReady]);

  if (!appIsReady) {
    return null;
  }

  return (
    <Provider store={store}>
      <PersistGate loading={null} persistor={persistor}>
        <SafeAreaProvider onLayout={onLayoutRootView}>
          <NavigationContainer>
            <AppNavigator />
            <StatusBar style="light" />
          </NavigationContainer>
        </SafeAreaProvider>
      </PersistGate>
    </Provider>
  );
}

function cacheImages(images: any[]) {
  return images.map(image => {
    if (typeof image === 'string') {
      return Image.prefetch(image);
    } else {
      return Asset.fromModule(image).downloadAsync();
    }
  });
}

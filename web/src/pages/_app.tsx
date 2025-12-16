import type { AppProps } from 'next/app';
import Head from 'next/head';
import '../styles/globals.css';
import { useEffect } from 'react';
import { useStore } from '../store/useStore';
import { webNotificationService } from '../lib/notifications';
import { Toaster } from 'react-hot-toast';

export default function App({ Component, pageProps }: AppProps) {
  const { setUser } = useStore();

  useEffect(() => {
    // Initialize with sample user data
    const sampleUser = {
      id: '1',
      email: 'user@lifedeck.app',
      name: 'Alex Johnson',
      hasCompletedOnboarding: true,
      subscriptionTier: 'free' as const,
      progress: {
        healthScore: 65,
        financeScore: 45,
        productivityScore: 70,
        mindfulnessScore: 55,
        lifeScore: 58.75,
        currentStreak: 5,
        longestStreak: 12,
        lifePoints: 245,
        totalCardsCompleted: 24,
        lastActiveDate: new Date().toISOString(),
      },
      joinDate: new Date().toISOString(),
    };

    setUser(sampleUser);

    // Initialize notifications
    webNotificationService.initialize();
    webNotificationService.showWelcomeToast();
  }, [setUser]);

  return (
    <>
      <Head>
        <title>LifeDeck - AI Life Coach</title>
        <meta name="description" content="AI-powered life optimization through personalized coaching cards" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="theme-color" content="#2196F3" />
        <link rel="manifest" href="/manifest.json" />
        <link rel="icon" href="/favicon.ico" />
        <link rel="apple-touch-icon" href="/icon-192x192.png" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="default" />
        <meta name="apple-mobile-web-app-title" content="LifeDeck" />
      </Head>
      <Component {...pageProps} />
      <Toaster
        position="bottom-right"
        toastOptions={{
          style: {
            background: '#1e1e1e',
            color: '#fff',
            border: '1px solid #333',
          },
        }}
      />
    </>
  );
}
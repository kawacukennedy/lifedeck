# LifeDeck Android App

React Native Android application for the LifeDeck life optimization platform.

## Features

- **Native Android Experience**: Built with React Native for smooth performance
- **Redux State Management**: Redux Toolkit with Redux Persist for state management
- **Navigation**: React Navigation with bottom tabs and stack navigation
- **Card Interface**: Swipeable coaching cards with gesture handling
- **Offline Support**: AsyncStorage for local data persistence
- **Dark Theme**: LifeDeck-branded dark theme by default

## Tech Stack

- **Framework**: React Native 0.73
- **Language**: TypeScript
- **State Management**: Redux Toolkit + Redux Persist
- **Navigation**: React Navigation 6
- **Icons**: React Native Vector Icons
- **HTTP Client**: Axios
- **Storage**: AsyncStorage

## Getting Started

### Prerequisites

- Node.js 18+
- React Native development environment
- Android Studio / Android SDK
- Physical Android device or emulator

### Installation

1. Install dependencies:
```bash
npm install
```

2. Install iOS dependencies (if building for iOS):
```bash
cd ios && pod install
```

3. Start Metro bundler:
```bash
npm start
```

4. Run on Android:
```bash
npm run android
```

## Project Structure

```
android/
├── src/
│   ├── components/          # Reusable UI components
│   ├── screens/            # Screen components
│   ├── navigation/         # Navigation configuration
│   ├── store/              # Redux store and slices
│   ├── services/           # API services
│   ├── utils/              # Utilities and helpers
│   └── types/              # TypeScript type definitions
├── android/                # Android native code
├── ios/                    # iOS native code
├── App.tsx                 # Main app component
└── package.json
```

## Key Components

### State Management

The app uses Redux Toolkit with the following slices:
- **userSlice**: User profile and progress
- **cardsSlice**: Daily cards and card actions
- **uiSlice**: Theme and app preferences

### Navigation

Bottom tab navigation with:
- Deck: Daily coaching cards
- Dashboard: Progress analytics
- Premium: Subscription features
- Design: Component showcase
- Profile: User settings

### Cards System

Swipeable card interface with actions:
- Complete: Mark card as done
- Dismiss: Remove card
- Snooze: Postpone for later

## Development

### Adding New Features

1. Create components in `src/components/`
2. Add screens in `src/screens/`
3. Update Redux slices for state management
4. Add API calls in `src/services/`
5. Update navigation if needed

### Testing

```bash
npm test
```

### Building for Production

```bash
npm run build:android
```

## API Integration

The app integrates with the LifeDeck backend API:
- Authentication (login/register)
- Daily cards fetching
- Card completion tracking
- Analytics and progress

## Contributing

1. Follow the existing TypeScript patterns
2. Use Redux for state management
3. Test on both Android and iOS
4. Follow React Native best practices

## License

© 2024 LifeDeck. All rights reserved.
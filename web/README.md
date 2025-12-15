# LifeDeck Web App

Next.js web application for the LifeDeck life optimization platform.

## Features

- **Modern Web App**: Built with Next.js 14 and App Router
- **Zustand State Management**: Lightweight and efficient state management
- **Tailwind CSS**: Utility-first CSS framework with custom LifeDeck theme
- **Responsive Design**: Mobile-first design that works on all devices
- **Framer Motion**: Smooth animations and transitions
- **Dark Theme**: LifeDeck-branded dark theme by default

## Tech Stack

- **Framework**: Next.js 14 with App Router
- **Language**: TypeScript
- **State Management**: Zustand with persistence
- **Styling**: Tailwind CSS
- **Animations**: Framer Motion
- **Icons**: Lucide React
- **Charts**: Chart.js with react-chartjs-2
- **Notifications**: React Hot Toast

## Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn

### Installation

1. Install dependencies:
```bash
npm install
```

2. Start the development server:
```bash
npm run dev
```

The app will be available at `http://localhost:3000`

### Build for Production

```bash
npm run build
npm start
```

## Project Structure

```
web/
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── Layout.tsx       # Main layout with sidebar and header
│   │   ├── Sidebar.tsx      # Navigation sidebar
│   │   ├── Header.tsx       # Top header bar
│   │   └── Card.tsx         # Coaching card component
│   ├── pages/               # Next.js pages
│   │   ├── index.tsx        # Dashboard/home page
│   │   ├── deck.tsx         # Daily deck page
│   │   └── _app.tsx         # App wrapper
│   ├── store/               # Zustand store
│   │   └── useStore.ts      # Main store with user, cards, UI state
│   ├── styles/              # Global styles
│   │   └── globals.css      # Tailwind and custom styles
│   └── lib/                 # Utility functions
├── public/                  # Static assets
├── tailwind.config.js       # Tailwind configuration
├── next.config.js          # Next.js configuration
└── package.json
```

## Key Features

### State Management

The app uses Zustand for state management with the following structure:
- **User State**: Profile, progress, subscription info
- **Cards State**: Daily cards, completed cards
- **UI State**: Theme, sidebar, loading states

State is persisted using Zustand's persist middleware.

### Theming

Custom Tailwind theme with LifeDeck colors:
- Dark background (`#121212`)
- Surface colors (`#1e1e1e`)
- Primary blue (`#2196F3`)
- Domain-specific colors for health, finance, productivity, mindfulness

### Components

- **Layout**: Responsive layout with collapsible sidebar
- **Card**: Interactive coaching card with actions
- **Sidebar**: Navigation with active state indicators
- **Header**: User info and notifications

### Pages

- **Dashboard (/)**: Overview with life score and quick stats
- **Deck (/deck)**: Daily coaching cards interface

## Development

### Adding New Features

1. Create components in `src/components/`
2. Add pages in `src/pages/`
3. Update Zustand store for new state
4. Add API calls using the existing patterns

### Styling

Use Tailwind classes with the custom LifeDeck theme. Add new styles to `globals.css` if needed.

### State Management

Use the `useStore` hook to access and update state:

```typescript
const { user, setUser, completeCard } = useStore();
```

## API Integration

The web app is designed to integrate with the LifeDeck backend API. API calls are proxied through Next.js in development.

## Contributing

1. Follow the existing TypeScript and component patterns
2. Use Zustand for state management
3. Test on multiple screen sizes
4. Follow the dark theme design system

## License

© 2024 LifeDeck. All rights reserved.
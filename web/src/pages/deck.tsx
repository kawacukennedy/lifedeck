import { useEffect } from 'react';
import { useStore } from '../store/useStore';
import Layout from '../components/Layout';
import Card from '../components/Card';

export default function DeckPage() {
  const { dailyCards, setDailyCards, completeCard } = useStore();

  useEffect(() => {
    // Load daily cards if not already loaded
    if (dailyCards.length === 0) {
      loadCards();
    }
  }, []);

  const loadCards = () => {
    // Sample cards for demonstration
    const sampleCards = [
      {
        id: '1',
        title: 'Take a Mindful Walk',
        description: 'Step outside for a 10-minute walk and focus on your breathing',
        actionText: 'Walk for 10 minutes outside',
        domain: 'health' as const,
        actionType: 'standard' as const,
        priority: 'medium' as const,
        icon: 'heart',
        tips: ['Leave your phone behind', 'Focus on your breathing'],
        benefits: ['Improves cardiovascular health', 'Reduces stress'],
        status: 'pending' as const,
        createdAt: new Date().toISOString(),
        aiGenerated: false,
      },
      {
        id: '2',
        title: 'Review Yesterday\'s Expenses',
        description: 'Take 5 minutes to review what you spent money on yesterday',
        actionText: 'Review and categorize yesterday\'s spending',
        domain: 'finance' as const,
        actionType: 'standard' as const,
        priority: 'medium' as const,
        icon: 'dollar-sign',
        tips: ['Use your banking app', 'Look for unnecessary purchases'],
        benefits: ['Increases spending awareness', 'Helps identify waste'],
        status: 'pending' as const,
        createdAt: new Date().toISOString(),
        aiGenerated: false,
      },
    ];

    setDailyCards(sampleCards);
  };

  const handleCardAction = (cardId: string, action: 'complete' | 'dismiss' | 'snooze') => {
    switch (action) {
      case 'complete':
        completeCard(cardId);
        break;
      case 'dismiss':
        // Handle dismiss - remove from daily cards
        setDailyCards(dailyCards.filter(card => card.id !== cardId));
        break;
      case 'snooze':
        // Handle snooze - could move to later or hide temporarily
        break;
    }
  };

  return (
    <Layout>
      <div className="max-w-4xl mx-auto">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-lifedeck-text mb-2">
            🃏 Daily Deck
          </h1>
          <p className="text-lifedeck-textSecondary">
            Your personalized coaching cards for today
          </p>
        </div>

        {dailyCards.length > 0 ? (
          <div className="space-y-6">
            {dailyCards.map((card) => (
              <Card
                key={card.id}
                card={card}
                onAction={handleCardAction}
              />
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <div className="text-lifedeck-textSecondary mb-4">
              No cards in your deck right now
            </div>
            <button
              onClick={loadCards}
              className="bg-lifedeck-primary hover:bg-lifedeck-primary/80 text-white font-medium py-3 px-6 rounded-lg transition-colors duration-200"
            >
              Load New Cards
            </button>
          </div>
        )}
      </div>
    </Layout>
  );
}
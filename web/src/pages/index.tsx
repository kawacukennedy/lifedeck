import { useEffect } from 'react';
import { useStore } from '../store/useStore';
import Layout from '../components/Layout';
import Card from '../components/Card';
import { motion } from 'framer-motion';

export default function Home() {
  const {
    user,
    dailyCards,
    setDailyCards,
    completeCard,
    setLoading,
    loading,
  } = useStore();

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    setLoading(true);
    try {
      // Load sample data for now
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
    } catch (error) {
      console.error('Failed to load dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCardAction = (cardId: string, action: 'complete' | 'dismiss' | 'snooze') => {
    switch (action) {
      case 'complete':
        completeCard(cardId);
        break;
      case 'dismiss':
        // Handle dismiss
        break;
      case 'snooze':
        // Handle snooze
        break;
    }
  };

  return (
    <Layout>
      <div className="max-w-7xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-8"
        >
          <h1 className="text-3xl font-bold text-lifedeck-text mb-2">
            Welcome to LifeDeck
          </h1>
          <p className="text-lifedeck-textSecondary">
            Your AI-powered life optimization platform
          </p>
        </motion.div>

        {/* Life Score Overview */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="bg-lifedeck-surface rounded-xl p-6 mb-8 border border-lifedeck-border"
        >
          <div className="text-center">
            <div className="text-6xl font-bold text-lifedeck-primary mb-2">
              {user?.progress.lifeScore.toFixed(1) || '0.0'}
            </div>
            <div className="text-lifedeck-textSecondary mb-4">Life Score</div>
            <div className="w-full bg-lifedeck-background rounded-full h-3">
              <div
                className="bg-lifedeck-primary h-3 rounded-full transition-all duration-500"
                style={{ width: `${user?.progress.lifeScore || 0}%` }}
              />
            </div>
          </div>
        </motion.div>

        {/* Quick Stats */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8"
        >
          <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
            <div className="text-2xl font-bold text-lifedeck-success mb-1">
              {user?.progress.currentStreak || 0}
            </div>
            <div className="text-lifedeck-textSecondary">Current Streak</div>
          </div>

          <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
            <div className="text-2xl font-bold text-lifedeck-premium mb-1">
              {user?.progress.lifePoints || 0}
            </div>
            <div className="text-lifedeck-textSecondary">Life Points</div>
          </div>

          <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
            <div className="text-2xl font-bold text-lifedeck-primary mb-1">
              {user?.progress.totalCardsCompleted || 0}
            </div>
            <div className="text-lifedeck-textSecondary">Cards Completed</div>
          </div>
        </motion.div>

        {/* Daily Cards */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <h2 className="text-2xl font-bold text-lifedeck-text mb-6">
            Today's Coaching Cards
          </h2>

          {loading ? (
            <div className="text-center py-12">
              <div className="text-lifedeck-textSecondary">Loading your cards...</div>
            </div>
          ) : dailyCards.length > 0 ? (
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
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
                No cards available right now
              </div>
              <button
                onClick={loadDashboardData}
                className="bg-lifedeck-primary hover:bg-lifedeck-primary/80 text-white font-medium py-3 px-6 rounded-lg transition-colors duration-200"
              >
                Refresh Cards
              </button>
            </div>
          )}
        </motion.div>
      </div>
    </Layout>
  );
}
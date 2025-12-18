import { useEffect } from 'react';
import { useStore } from '../store/useStore';
import Layout from '../components/Layout';
import Card from '../components/Card';

export default function DeckPage() {
  const { dailyCards, loadDailyCards, completeCard, user } = useStore();

  useEffect(() => {
    // Load daily cards if not already loaded
    if (dailyCards.length === 0) {
      loadDailyCards();
    }
  }, []);

  const isPremium = user?.subscriptionTier === 'premium';
  const maxFreeCards = 3;
  const visibleCards = isPremium ? dailyCards : dailyCards.slice(0, maxFreeCards);

  const handleCardAction = async (cardId: string, action: 'complete' | 'dismiss' | 'snooze') => {
    switch (action) {
      case 'complete':
        await completeCard(cardId);
        break;
      case 'dismiss':
        // Handle dismiss - will be implemented
        break;
      case 'snooze':
        // Handle snooze - will be implemented
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

        {visibleCards.length > 0 ? (
           <div className="space-y-6">
             {visibleCards.map((card) => (
               <Card
                 key={card.id}
                 card={card}
                 onAction={handleCardAction}
               />
             ))}
             {!isPremium && dailyCards.length > maxFreeCards && (
               <div className="bg-gradient-to-r from-lifedeck-primary/10 to-lifedeck-primary/5 border border-lifedeck-primary/20 rounded-xl p-6 text-center">
                 <div className="mb-4">
                   <div className="text-2xl mb-2">🔒</div>
                   <h3 className="text-lg font-semibold text-lifedeck-text mb-2">
                     Unlock More Cards
                   </h3>
                   <p className="text-lifedeck-textSecondary text-sm mb-4">
                     You have {dailyCards.length - maxFreeCards} more personalized cards waiting for you
                   </p>
                 </div>
                 <button className="bg-lifedeck-primary hover:bg-lifedeck-primary/80 text-white font-medium py-3 px-6 rounded-lg transition-colors duration-200">
                   Upgrade to Premium
                 </button>
               </div>
             )}
           </div>
         ) : (
          <div className="text-center py-12">
            <div className="text-lifedeck-textSecondary mb-4">
              No cards in your deck right now
            </div>
             <button
               onClick={loadDailyCards}
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
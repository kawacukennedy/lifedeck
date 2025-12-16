import React, {useEffect, useRef} from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  Alert,
  Animated,
  PanResponder,
  Dimensions,
} from 'react-native';
import {useDispatch, useSelector} from 'react-redux';
import {RootState} from '../store';
import {completeCard, dismissCard, snoozeCard} from '../store/slices/cardsSlice';
import CardComponent from '../components/CardComponent';
import SwipeableCard from '../components/SwipeableCard';

const DeckScreen = () => {
  const dispatch = useDispatch();
  const {dailyCards, isLoading} = useSelector(
    (state: RootState) => state.cards,
  );
  const user = useSelector((state: RootState) => state.user);

  useEffect(() => {
    // Load daily cards on mount
    loadDailyCards();
  }, []);

  const loadDailyCards = () => {
    // TODO: Implement API call to load daily cards
    // For now, use sample data
    const sampleCards = [
      {
        id: '1',
        title: 'Take a Mindful Walk',
        description: 'Step outside for a 10-minute walk and focus on your breathing',
        actionText: 'Walk for 10 minutes outside',
        domain: 'health' as const,
        actionType: 'standard' as const,
        priority: 'medium' as const,
        icon: 'directions_walk',
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
        icon: 'account_balance_wallet',
        tips: ['Use your banking app', 'Look for unnecessary purchases'],
        benefits: ['Increases spending awareness', 'Helps identify waste'],
        status: 'pending' as const,
        createdAt: new Date().toISOString(),
        aiGenerated: false,
      },
    ];

    dispatch({type: 'cards/setDailyCards', payload: sampleCards});
  };

  const handleCardAction = (cardId: string, action: 'complete' | 'dismiss' | 'snooze') => {
    switch (action) {
      case 'complete':
        dispatch(completeCard(cardId));
        dispatch({type: 'user/completeCard'});
        break;
      case 'dismiss':
        dispatch(dismissCard(cardId));
        break;
      case 'snooze':
        const snoozeUntil = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
        dispatch(snoozeCard({id: cardId, until: snoozeUntil}));
        break;
    }
  };

  const handleCardSwipe = (cardId: string, direction: 'left' | 'right') => {
    if (direction === 'right') {
      // Swipe right = complete
      handleCardAction(cardId, 'complete');
    } else {
      // Swipe left = dismiss
      handleCardAction(cardId, 'dismiss');
    }
  };

  const renderCard = ({item}: {item: any}) => (
    <SwipeableCard
      card={item}
      onAction={handleCardAction}
      onSwipe={(direction) => handleCardSwipe(item.id, direction)}
    />
  );

  if (isLoading) {
    return (
      <View style={styles.container}>
        <Text style={styles.loadingText}>Loading your daily cards...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>🃏 LifeDeck</Text>
        <Text style={styles.subtitle}>AI-Powered Micro-Coach</Text>
        <View style={styles.stats}>
          <Text style={styles.statText}>Streak: {user?.progress.currentStreak || 0}</Text>
          <Text style={styles.statText}>Points: {user?.progress.lifePoints || 0}</Text>
        </View>
      </View>

      <FlatList
        data={dailyCards}
        renderItem={renderCard}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.cardList}
        showsVerticalScrollIndicator={false}
      />

      <TouchableOpacity style={styles.refreshButton} onPress={loadDailyCards}>
        <Text style={styles.refreshButtonText}>Refresh Cards</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#121212',
    padding: 16,
  },
  header: {
    alignItems: 'center',
    marginBottom: 24,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#888',
    marginBottom: 16,
  },
  stats: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    width: '100%',
  },
  statText: {
    fontSize: 14,
    color: '#2196F3',
    fontWeight: '600',
  },
  cardList: {
    paddingBottom: 80,
  },
  loadingText: {
    fontSize: 18,
    color: '#fff',
    textAlign: 'center',
    marginTop: 50,
  },
  refreshButton: {
    backgroundColor: '#2196F3',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 16,
  },
  refreshButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});

export default DeckScreen;
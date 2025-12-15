import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Alert,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import {CoachingCard} from '../store/slices/cardsSlice';

interface CardComponentProps {
  card: CoachingCard;
  onAction: (cardId: string, action: 'complete' | 'dismiss' | 'snooze') => void;
}

const CardComponent: React.FC<CardComponentProps> = ({card, onAction}) => {
  const getDomainColor = (domain: string) => {
    switch (domain) {
      case 'health':
        return '#FF6B6B';
      case 'finance':
        return '#4ECDC4';
      case 'productivity':
        return '#45B7D1';
      case 'mindfulness':
        return '#96CEB4';
      default:
        return '#2196F3';
    }
  };

  const getActionTypeIcon = (actionType: string) => {
    switch (actionType) {
      case 'quick':
        return 'bolt';
      case 'standard':
        return 'schedule';
      case 'extended':
        return 'timer';
      case 'habit':
        return 'repeat';
      case 'reflection':
        return 'psychology';
      default:
        return 'task_alt';
    }
  };

  return (
    <View style={[styles.card, {borderLeftColor: getDomainColor(card.domain)}]}>
      <View style={styles.cardHeader}>
        <View style={styles.domainIndicator}>
          <Icon name={card.icon} size={24} color={getDomainColor(card.domain)} />
        </View>
        <View style={styles.actionType}>
          <Icon
            name={getActionTypeIcon(card.actionType)}
            size={16}
            color="#888"
          />
          <Text style={styles.actionTypeText}>
            {card.actionType.charAt(0).toUpperCase() + card.actionType.slice(1)}
          </Text>
        </View>
      </View>

      <Text style={styles.cardTitle}>{card.title}</Text>
      <Text style={styles.cardDescription}>{card.description}</Text>

      <View style={styles.actionSection}>
        <Text style={styles.actionText}>{card.actionText}</Text>
      </View>

      {card.tips.length > 0 && (
        <View style={styles.tipsSection}>
          <Text style={styles.sectionTitle}>💡 Tips:</Text>
          {card.tips.map((tip, index) => (
            <Text key={index} style={styles.tipText}>
              • {tip}
            </Text>
          ))}
        </View>
      )}

      {card.benefits.length > 0 && (
        <View style={styles.benefitsSection}>
          <Text style={styles.sectionTitle}>🎯 Benefits:</Text>
          {card.benefits.map((benefit, index) => (
            <Text key={index} style={styles.benefitText}>
              • {benefit}
            </Text>
          ))}
        </View>
      )}

      <View style={styles.cardActions}>
        <TouchableOpacity
          style={[styles.actionButton, styles.completeButton]}
          onPress={() => onAction(card.id, 'complete')}>
          <Icon name="check_circle" size={20} color="#fff" />
          <Text style={styles.completeButtonText}>Complete</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.actionButton, styles.secondaryButton]}
          onPress={() => onAction(card.id, 'snooze')}>
          <Icon name="snooze" size={20} color="#888" />
          <Text style={styles.secondaryButtonText}>Snooze</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.actionButton, styles.secondaryButton]}
          onPress={() => onAction(card.id, 'dismiss')}>
          <Icon name="close" size={20} color="#888" />
          <Text style={styles.secondaryButtonText}>Dismiss</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#1e1e1e',
    borderRadius: 16,
    padding: 20,
    marginBottom: 16,
    borderLeftWidth: 4,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  domainIndicator: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#2a2a2a',
    justifyContent: 'center',
    alignItems: 'center',
  },
  actionType: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#2a2a2a',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  actionTypeText: {
    fontSize: 12,
    color: '#888',
    marginLeft: 4,
  },
  cardTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 8,
  },
  cardDescription: {
    fontSize: 14,
    color: '#ccc',
    marginBottom: 16,
    lineHeight: 20,
  },
  actionSection: {
    backgroundColor: '#2a2a2a',
    padding: 12,
    borderRadius: 8,
    marginBottom: 16,
  },
  actionText: {
    fontSize: 16,
    color: '#fff',
    fontWeight: '600',
  },
  tipsSection: {
    marginBottom: 12,
  },
  benefitsSection: {
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#2196F3',
    marginBottom: 8,
  },
  tipText: {
    fontSize: 13,
    color: '#ccc',
    marginBottom: 4,
    lineHeight: 18,
  },
  benefitText: {
    fontSize: 13,
    color: '#ccc',
    marginBottom: 4,
    lineHeight: 18,
  },
  cardActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderRadius: 8,
    flex: 1,
    justifyContent: 'center',
    marginHorizontal: 4,
  },
  completeButton: {
    backgroundColor: '#4CAF50',
  },
  secondaryButton: {
    backgroundColor: '#2a2a2a',
  },
  completeButtonText: {
    color: '#fff',
    fontWeight: '600',
    marginLeft: 6,
  },
  secondaryButtonText: {
    color: '#888',
    fontWeight: '600',
    marginLeft: 6,
  },
});

export default CardComponent;
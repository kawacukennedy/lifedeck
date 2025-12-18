import React, {useRef} from 'react';
import {
  View,
  Text,
  StyleSheet,
  Animated,
  PanResponder,
  Dimensions,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import CardComponent from './CardComponent';
import {CoachingCard} from '../store/slices/cardsSlice';
// import ReactNativeHapticFeedback from 'react-native-haptic-feedback';

const {width} = Dimensions.get('window');
const SWIPE_THRESHOLD = width * 0.3;

interface SwipeableCardProps {
  card: CoachingCard;
  onAction: (cardId: string, action: 'complete' | 'dismiss' | 'snooze') => void;
  onSwipe: (direction: 'left' | 'right') => void;
}

const SwipeableCard: React.FC<SwipeableCardProps> = ({card, onAction, onSwipe}) => {
  const pan = useRef(new Animated.ValueXY()).current;

  const panResponder = useRef(
    PanResponder.create({
      onMoveShouldSetPanResponder: (evt, gestureState) => {
        return Math.abs(gestureState.dx) > 20;
      },
      onPanResponderGrant: () => {
        pan.setOffset({
          x: pan.x._value,
          y: pan.y._value,
        });
      },
      onPanResponderMove: Animated.event([null, {dx: pan.x, dy: pan.y}], {
        useNativeDriver: false,
      }),
       onPanResponderRelease: (evt, gestureState) => {
         pan.flattenOffset();

         if (Math.abs(gestureState.dx) > SWIPE_THRESHOLD) {
           const direction = gestureState.dx > 0 ? 'right' : 'left';
           onSwipe(direction);

           // Haptic feedback for successful swipe
           // ReactNativeHapticFeedback.trigger('impactLight');

           // Animate card off screen with bounce effect
           Animated.sequence([
             Animated.timing(pan, {
               toValue: {x: direction === 'right' ? width * 0.8 : -width * 0.8, y: 0},
               duration: 200,
               useNativeDriver: false,
             }),
             Animated.timing(pan, {
               toValue: {x: direction === 'right' ? width : -width, y: 0},
               duration: 150,
               useNativeDriver: false,
             }),
           ]).start(() => {
             // Reset position after animation
             pan.setValue({x: 0, y: 0});
           });
         } else {
           // Snap back to center with spring animation
           Animated.spring(pan, {
             toValue: {x: 0, y: 0},
             friction: 5,
             tension: 40,
             useNativeDriver: false,
           }).start();
         }
       },
    }),
  ).current;

  const getCardStyle = () => {
    const rotate = pan.x.interpolate({
      inputRange: [-width, 0, width],
      outputRange: ['-8deg', '0deg', '8deg'],
    });

    const scale = pan.x.interpolate({
      inputRange: [-width, -SWIPE_THRESHOLD, 0, SWIPE_THRESHOLD, width],
      outputRange: [0.95, 0.98, 1, 0.98, 0.95],
    });

    const opacity = pan.x.interpolate({
      inputRange: [-width, -SWIPE_THRESHOLD, 0, SWIPE_THRESHOLD, width],
      outputRange: [0.7, 0.9, 1, 0.9, 0.7],
    });

    return {
      transform: [{translateX: pan.x}, {rotate}, {scale}],
      opacity,
    };
  };

  const getActionIndicator = () => {
    const translateX = pan.x.interpolate({
      inputRange: [-width, -SWIPE_THRESHOLD, 0, SWIPE_THRESHOLD, width],
      outputRange: [-120, -60, 0, 60, 120],
    });

    const opacity = pan.x.interpolate({
      inputRange: [-width, -SWIPE_THRESHOLD, 0, SWIPE_THRESHOLD, width],
      outputRange: [1, 0.7, 0, 0.7, 1],
    });

    const scale = pan.x.interpolate({
      inputRange: [-width, -SWIPE_THRESHOLD, 0, SWIPE_THRESHOLD, width],
      outputRange: [1.2, 1.1, 1, 1.1, 1.2],
    });

    return {
      transform: [{translateX}, {scale}],
      opacity,
    };
  };

  return (
    <View style={styles.container}>
      {/* Action indicators */}
      <Animated.View style={[styles.actionIndicator, styles.leftIndicator, getActionIndicator()]}>
        <Icon name="close" size={30} color="#FF6B6B" />
        <Text style={[styles.actionText, {color: '#FF6B6B'}]}>Dismiss</Text>
      </Animated.View>

      <Animated.View style={[styles.actionIndicator, styles.rightIndicator, getActionIndicator()]}>
        <Icon name="check_circle" size={30} color="#4CAF50" />
        <Text style={[styles.actionText, {color: '#4CAF50'}]}>Complete</Text>
      </Animated.View>

      {/* Swipeable card */}
      <Animated.View
        style={[styles.cardContainer, getCardStyle()]}
        {...panResponder.panHandlers}>
        <CardComponent card={card} onAction={onAction} />
      </Animated.View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'relative',
    alignItems: 'center',
    justifyContent: 'center',
  },
  cardContainer: {
    width: '100%',
  },
  actionIndicator: {
    position: 'absolute',
    top: '50%',
    transform: [{translateY: -30}],
    alignItems: 'center',
    zIndex: -1,
  },
  leftIndicator: {
    left: 20,
  },
  rightIndicator: {
    right: 20,
  },
  actionText: {
    fontSize: 12,
    fontWeight: 'bold',
    marginTop: 4,
  },
});

export default SwipeableCard;
import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated, Easing, Dimensions } from 'react-native';
import { theme } from '../utils/theme';

const { width } = Dimensions.get('window');
const CARD_WIDTH = width * 0.7;
const CARD_HEIGHT = CARD_WIDTH * 1.4;

const CardShuffleLoader = () => {
    const animValue = useRef(new Animated.Value(0)).current;

    useEffect(() => {
        Animated.loop(
            Animated.timing(animValue, {
                toValue: 1,
                duration: 2000,
                easing: Easing.bezier(0.4, 0, 0.2, 1),
                useNativeDriver: true,
            })
        ).start();
    }, [animValue]);

    const renderCard = (index: number) => {
        const rotate = animValue.interpolate({
            inputRange: [0, 0.5, 1],
            outputRange: [
                '${(index - 1) * 5}deg',
                '${(index - 1) * -5 - 10}deg',
                '${(index - 1) * 5}deg'
            ],
        });

        const translateX = animValue.interpolate({
            inputRange: [0, 0.5, 1],
            outputRange: [0, -40, 0],
        });

        const scale = animValue.interpolate({
            inputRange: [0, 0.5, 1],
            outputRange: [1 - index * 0.05, 1.05 - index * 0.05, 1 - index * 0.05],
        });

        return (
            <Animated.View
                key={index}
                style={[
                    styles.card,
                    {
                        transform: [
                            { translateX },
                            { rotate },
                            { scale },
                            { translateY: index * 10 },
                        ],
                        zIndex: 3 - index,
                        opacity: 1 - (index * 0.3),
                    },
                ]}
            />
        );
    };

    return (
        <View style={styles.container}>
            {[0, 1, 2].map((_, i) => renderCard(i))}
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        height: CARD_HEIGHT + 60,
        width: '100%',
        justifyContent: 'center',
        alignItems: 'center',
    },
    card: {
        position: 'absolute',
        width: CARD_WIDTH,
        height: CARD_HEIGHT,
        backgroundColor: theme.colors.primary,
        borderRadius: theme.borderRadius.lg,
        borderWidth: 1,
        borderColor: 'rgba(255,255,255,0.1)',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 10 },
        shadowOpacity: 0.3,
        shadowRadius: 15,
        elevation: 10,
    },
});

export default CardShuffleLoader;

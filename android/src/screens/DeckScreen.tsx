import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, SafeAreaView, Dimensions } from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { RootState, AppDispatch } from '../store';
import { loadDailyCards, completeCard, dismissCard } from '../store/slices/cardsSlice';
import { updateProgress } from '../store/slices/userSlice';
import CardShuffleLoader from '../components/CardShuffleLoader';
import { theme } from '../utils/theme';
import { requestNotificationPermissions } from '../utils/NotificationService';
import { CheckCircle2, Zap } from 'lucide-react-native';
import Animated, {
    useSharedValue,
    useAnimatedStyle,
    withSpring,
    withTiming,
    useAnimatedGestureHandler,
    runOnJS,
    interpolate,
    interpolateColor,
    Extrapolate
} from 'react-native-reanimated';
import { PanGestureHandler } from 'react-native-gesture-handler';

const { width } = Dimensions.get('window');
const SWIPE_THRESHOLD = width * 0.25;

const DeckScreen = () => {
    const dispatch = useDispatch<AppDispatch>();
    const { dailyCards, isLoading } = useSelector((state: RootState) => state.cards);

    const translateX = useSharedValue(0);
    const translateY = useSharedValue(0);
    const rotation = useSharedValue(0);
    const opacity = useSharedValue(1);

    useEffect(() => {
        dispatch(loadDailyCards());
        requestNotificationPermissions();
    }, [dispatch]);

    const activeCards = dailyCards.filter(c => !c.isCompleted && !c.isDismissed);
    const currentCard = activeCards[0];

    const onSwipeComplete = (direction: 'left' | 'right' | 'down') => {
        if (!currentCard) return;

        if (direction === 'right') {
            dispatch(completeCard(currentCard.id));
            dispatch(updateProgress({ domain: currentCard.domain, points: currentCard.points }));
        } else if (direction === 'left' || direction === 'down') {
            dispatch(dismissCard(currentCard.id));
        }

        // Reset animations for next card
        translateX.value = 0;
        translateY.value = 0;
        rotation.value = 0;
        opacity.value = withTiming(1);
    };

    const gestureHandler = useAnimatedGestureHandler({
        onStart: (_, ctx: any) => {
            ctx.startX = translateX.value;
            ctx.startY = translateY.value;
        },
        onActive: (event, ctx: any) => {
            translateX.value = ctx.startX + event.translationX;
            translateY.value = ctx.startY + event.translationY;
            rotation.value = interpolate(
                translateX.value,
                [-width / 2, 0, width / 2],
                [-10, 0, 10],
                Extrapolate.CLAMP
            );
        },
        onEnd: (event) => {
            if (Math.abs(event.translationX) > SWIPE_THRESHOLD) {
                translateX.value = withSpring(
                    event.translationX > 0 ? width * 1.5 : -width * 1.5,
                    {},
                    () => runOnJS(onSwipeComplete)(event.translationX > 0 ? 'right' : 'left')
                );
            } else if (event.translationY > SWIPE_THRESHOLD) {
                translateY.value = withSpring(
                    width * 2,
                    {},
                    () => runOnJS(onSwipeComplete)('down')
                );
            } else {
                translateX.value = withSpring(0);
                translateY.value = withSpring(0);
                rotation.value = withSpring(0);
            }
        },
    });

    const animatedStyle = useAnimatedStyle(() => {
        const scale = interpolate(
            translateX.value,
            [-width / 2, 0, width / 2],
            [1.05, 1, 1.05],
            Extrapolate.CLAMP
        );

        return {
            transform: [
                { translateX: translateX.value },
                { translateY: translateY.value },
                { rotate: `${rotation.value}deg` },
                { scale },
            ],
            opacity: opacity.value,
            borderWidth: interpolate(
                translateX.value,
                [-width / 2, 0, width / 2],
                [2, 1, 2],
                Extrapolate.CLAMP
            ),
            borderColor: interpolateColor(
                translateX.value,
                [-width / 2, 0, width / 2],
                [theme.colors.error, theme.colors.border, theme.colors.primary]
            ),
        };
    });

    if (isLoading) {
        return (
            <SafeAreaView style={styles.container}>
                <View style={styles.loadingContainer}>
                    <CardShuffleLoader />
                    <Text style={styles.loadingText}>Curating your daily deck...</Text>
                </View>
            </SafeAreaView>
        );
    }

    if (activeCards.length === 0) {
        return (
            <SafeAreaView style={styles.container}>
                <View style={styles.emptyContainer}>
                    <CheckCircle2 color={theme.colors.success} size={64} />
                    <Text style={[styles.emptyTitle, theme.typography.h2]}>All caught up!</Text>
                    <Text style={[styles.emptySubtitle, theme.typography.body]}>
                        You've completed all your daily actions. Come back tomorrow for a fresh deck.
                    </Text>
                </View>
            </SafeAreaView>
        );
    }

    return (
        <SafeAreaView style={styles.container}>
            <View style={styles.header}>
                <Text style={[styles.title, theme.typography.h1]}>Daily Deck</Text>
                <Text style={[styles.subtitle, theme.typography.caption]}>{activeCards.length} cards remaining</Text>
            </View>

            <View style={styles.cardContainer}>
                <PanGestureHandler onGestureEvent={gestureHandler}>
                    <Animated.View style={[styles.card, animatedStyle]}>
                        <View style={[styles.domainTag, { backgroundColor: theme.colors.primary + '33' }]}>
                            <Text style={[styles.domainText, { color: theme.colors.primary }]}>{currentCard.domain}</Text>
                        </View>
                        <Text style={[styles.cardTitle, theme.typography.h2]}>{currentCard.title}</Text>
                        <Text style={[styles.cardSubtitle, theme.typography.body, { color: theme.colors.textDim }]}>{currentCard.subtitle}</Text>
                        <View style={styles.divider} />
                        <Text style={[styles.actionText, theme.typography.body]}>{currentCard.action}</Text>

                        <View style={styles.pointsBadge}>
                            <Zap size={14} color="#fff" fill="#fff" />
                            <Text style={styles.pointsText}>+{currentCard.points} LifePoints</Text>
                        </View>
                    </Animated.View>
                </PanGestureHandler>
            </View>

            <View style={styles.instructions}>
                <Text style={[styles.instructionText, theme.typography.caption]}>
                    Swipe Left/Down to Dismiss • Swipe Right to Complete
                </Text>
            </View>
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: theme.colors.background,
    },
    loadingContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
    loadingText: {
        color: theme.colors.text,
        marginTop: 20,
        fontSize: 18,
        fontWeight: '500',
        opacity: 0.8,
    },
    header: {
        padding: theme.spacing.lg,
    },
    title: {
        color: theme.colors.text,
    },
    subtitle: {
        color: theme.colors.textDim,
        marginTop: 4,
    },
    cardContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        padding: theme.spacing.lg,
    },
    card: {
        width: '100%',
        aspectRatio: 0.7,
        backgroundColor: theme.colors.surface,
        borderRadius: theme.borderRadius.xl,
        padding: theme.spacing.xl,
        justifyContent: 'center',
        alignItems: 'center',
        borderWidth: 1,
        borderColor: theme.colors.border,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 10 },
        shadowOpacity: 0.3,
        shadowRadius: 15,
        elevation: 10,
    },
    domainTag: {
        paddingHorizontal: 12,
        paddingVertical: 4,
        borderRadius: 20,
        marginBottom: 20,
    },
    domainText: {
        fontSize: 12,
        fontWeight: 'bold',
        letterSpacing: 1,
    },
    cardTitle: {
        color: theme.colors.text,
        textAlign: 'center',
    },
    cardSubtitle: {
        marginTop: 8,
        textAlign: 'center',
    },
    divider: {
        width: 60,
        height: 4,
        backgroundColor: theme.colors.primary,
        borderRadius: 2,
        marginVertical: 30,
    },
    actionText: {
        color: theme.colors.text,
        textAlign: 'center',
        lineHeight: 28,
    },
    pointsBadge: {
        position: 'absolute',
        bottom: -15,
        backgroundColor: theme.colors.secondary,
        paddingHorizontal: 16,
        paddingVertical: 8,
        borderRadius: 20,
        flexDirection: 'row',
        alignItems: 'center',
        gap: 6,
    },
    pointsText: {
        color: '#fff',
        fontWeight: 'bold',
    },
    instructions: {
        padding: theme.spacing.xl,
        alignItems: 'center',
    },
    instructionText: {
        color: theme.colors.textDim,
    },
    emptyContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        padding: 40,
    },
    emptyTitle: {
        color: theme.colors.text,
        marginTop: 20,
    },
    emptySubtitle: {
        color: theme.colors.textDim,
        textAlign: 'center',
        marginTop: 10,
        lineHeight: 24,
    },
});

export default DeckScreen;

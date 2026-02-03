import React from 'react';
import { View, Text, StyleSheet, SafeAreaView, ScrollView, FlatList } from 'react-native';
import { useSelector } from 'react-redux';
import { RootState } from '../store';
import { theme } from '../utils/theme';
import { Lock, Check } from 'lucide-react-native';

const AchievementsScreen = () => {
    const achievements = useSelector((state: RootState) => state.user.achievements);

    const renderAchievement = ({ item }: any) => {
        const isUnlocked = !!item.unlockedAt;

        return (
            <View style={[styles.card, !isUnlocked && styles.cardLocked]}>
                <View style={[styles.iconContainer, isUnlocked ? styles.iconUnlocked : styles.iconLocked]}>
                    {isUnlocked ? (
                        <Text style={styles.emoji}>{item.icon}</Text>
                    ) : (
                        <Lock color={theme.colors.textDim} size={24} />
                    )}
                </View>
                <View style={styles.info}>
                    <Text style={[styles.title, !isUnlocked && styles.textDim]}>{item.title}</Text>
                    <Text style={styles.description}>{item.description}</Text>
                    {isUnlocked && (
                        <View style={styles.unlockedBadge}>
                            <Check color={theme.colors.success} size={12} />
                            <Text style={styles.unlockedText}>Unlocked {new Date(item.unlockedAt!).toLocaleDateString()}</Text>
                        </View>
                    )}
                </View>
            </View>
        );
    };

    return (
        <SafeAreaView style={styles.container}>
            <FlatList
                data={achievements}
                renderItem={renderAchievement}
                keyExtractor={item => item.id}
                contentContainerStyle={styles.list}
                ListHeaderComponent={() => (
                    <View style={styles.header}>
                        <Text style={styles.headerText}>Your Rewards</Text>
                        <Text style={styles.headerSub}>Complete coaching actions to unlock exclusive achievements and badges.</Text>
                    </View>
                )}
            />
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: theme.colors.background,
    },
    list: {
        padding: theme.spacing.lg,
    },
    header: {
        marginBottom: 24,
    },
    headerText: {
        fontSize: 24,
        fontWeight: 'bold',
        color: theme.colors.text,
    },
    headerSub: {
        fontSize: 14,
        color: theme.colors.textDim,
        marginTop: 4,
        lineHeight: 20,
    },
    card: {
        flexDirection: 'row',
        backgroundColor: theme.colors.surface,
        borderRadius: theme.borderRadius.lg,
        padding: 16,
        marginBottom: 16,
        alignItems: 'center',
        borderWidth: 1,
        borderColor: theme.colors.border,
    },
    cardLocked: {
        opacity: 0.7,
        borderStyle: 'dashed',
    },
    iconContainer: {
        width: 60,
        height: 60,
        borderRadius: 30,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: 16,
    },
    iconUnlocked: {
        backgroundColor: theme.colors.primary + '22',
    },
    iconLocked: {
        backgroundColor: 'rgba(255,255,255,0.05)',
    },
    emoji: {
        fontSize: 30,
    },
    info: {
        flex: 1,
    },
    title: {
        fontSize: 18,
        fontWeight: 'bold',
        color: theme.colors.text,
    },
    textDim: {
        color: theme.colors.textDim,
    },
    description: {
        fontSize: 14,
        color: theme.colors.textDim,
        marginTop: 2,
        lineHeight: 20,
    },
    unlockedBadge: {
        flexDirection: 'row',
        alignItems: 'center',
        marginTop: 8,
        gap: 4,
    },
    unlockedText: {
        fontSize: 12,
        color: theme.colors.success,
        fontWeight: '500',
    },
});

export default AchievementsScreen;

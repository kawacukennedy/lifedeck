import React from 'react';
import { View, Text, StyleSheet, SafeAreaView, ScrollView, Dimensions } from 'react-native';
import { useSelector } from 'react-redux';
import { RootState } from '../store';
import { theme } from '../utils/theme';
import { TrendingUp, Award, Zap, Heart, PieChart, Activity, Sparkles } from 'lucide-react-native';
import Svg, { Path, Circle } from 'react-native-svg';

const { width } = Dimensions.get('window');

const StatCard = ({ title, value, icon: Icon, color }: any) => (
    <View style={styles.statCard}>
        <View style={[styles.statIcon, { backgroundColor: color + '22' }]}>
            <Icon color={color} size={20} />
        </View>
        <View>
            <Text style={[styles.statValue, theme.typography.body, { fontWeight: '700' }]}>{value}</Text>
            <Text style={[styles.statTitle, theme.typography.caption]}>{title}</Text>
        </View>
    </View>
);

const LifeScoreChart = ({ score }: { score: number }) => {
    const radius = 80;
    const strokeWidth = 12;
    const circumference = 2 * Math.PI * radius;
    const strokeDashoffset = circumference - (score / 100) * circumference;

    return (
        <View style={styles.chartContainer}>
            <Svg height="180" width="180" viewBox="0 0 200 200">
                <Circle
                    cx="100"
                    cy="100"
                    r={radius}
                    stroke="rgba(255,255,255,0.05)"
                    strokeWidth={strokeWidth}
                    fill="none"
                />
                <Circle
                    cx="100"
                    cy="100"
                    r={radius}
                    stroke={theme.colors.primary}
                    strokeWidth={strokeWidth}
                    strokeDasharray={circumference}
                    strokeDashoffset={strokeDashoffset}
                    strokeLinecap="round"
                    fill="none"
                    transform="rotate(-90 100 100)"
                />
            </Svg>
            <View style={styles.scoreTextContainer}>
                <Text style={styles.scoreValue}>{score}</Text>
                <Text style={styles.scoreLabel}>Life Score</Text>
            </View>
        </View>
    );
};

const DashboardScreen = () => {
    const { progress, name } = useSelector((state: RootState) => state.user);

    // Calculate average life score
    const lifeScore = Math.round(
        (progress.healthScore + progress.financeScore + progress.productivityScore + progress.mindfulnessScore) / 4
    );

    return (
        <SafeAreaView style={styles.container}>
            <ScrollView contentContainerStyle={styles.content}>
                <View style={styles.header}>
                    <View>
                        <Text style={[styles.greeting, theme.typography.h2]}>Hey {name || 'there'}!</Text>
                        <Text style={[styles.overview, theme.typography.body]}>Your daily growth summary</Text>
                    </View>
                    <View style={styles.premiumBadge}>
                        <Sparkles color={theme.colors.secondary} size={16} fill={theme.colors.secondary} />
                        <Text style={styles.premiumText}>LEVEL 4</Text>
                    </View>
                </View>

                <View style={styles.mainDashboard}>
                    <LifeScoreChart score={lifeScore} />
                    <View style={styles.summaryStats}>
                        <View style={styles.summaryItem}>
                            <Zap color={theme.colors.warning} size={20} fill={theme.colors.warning} />
                            <Text style={styles.summaryValue}>{progress.currentStreak}</Text>
                            <Text style={styles.summaryLabel}>Streak</Text>
                        </View>
                        <View style={styles.dividerVertical} />
                        <View style={styles.summaryItem}>
                            <Award color={theme.colors.primary} size={20} />
                            <Text style={styles.summaryValue}>{progress.lifePoints}</Text>
                            <Text style={styles.summaryLabel}>Points</Text>
                        </View>
                    </View>
                </View>

                <View style={styles.statsGrid}>
                    <StatCard title="Health" value={`${progress.healthScore}% `} icon={Heart} color="#E57373" />
                    <StatCard title="Finance" value={`${progress.financeScore}% `} icon={PieChart} color="#3AA79D" />
                    <StatCard title="Productivity" value={`${progress.productivityScore}% `} icon={Activity} color="#3B6BA5" />
                    <StatCard title="Mindfulness" value={`${progress.mindfulnessScore}% `} icon={TrendingUp} color="#9C27B0" />
                </View>

                <View style={styles.section}>
                    <Text style={[styles.sectionTitle, theme.typography.h2]}>Daily Insights</Text>
                    <View style={styles.insightCard}>
                        <TrendingUp color={theme.colors.secondary} size={24} />
                        <Text style={styles.insightText}>
                            You're 15% more productive this week! Keep completing those productivity cards.
                        </Text>
                    </View>
                </View>
            </ScrollView>
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: theme.colors.background,
    },
    content: {
        padding: theme.spacing.lg,
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 30,
    },
    greeting: {
        color: theme.colors.text,
    },
    overview: {
        color: theme.colors.textDim,
        marginTop: 4,
    },
    premiumBadge: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: 'rgba(58,167,157,0.1)',
        paddingHorizontal: 12,
        paddingVertical: 6,
        borderRadius: 20,
        gap: 6,
    },
    premiumText: {
        color: theme.colors.secondary,
        fontWeight: 'bold',
        fontSize: 12,
    },
    mainDashboard: {
        backgroundColor: theme.colors.surface,
        borderRadius: theme.borderRadius.xl,
        padding: 24,
        alignItems: 'center',
        marginBottom: 24,
        borderWidth: 1,
        borderColor: theme.colors.border,
    },
    chartContainer: {
        justifyContent: 'center',
        alignItems: 'center',
        position: 'relative',
    },
    scoreTextContainer: {
        position: 'absolute',
        alignItems: 'center',
    },
    scoreValue: {
        fontSize: 48,
        fontWeight: 'bold',
        color: theme.colors.text,
    },
    scoreLabel: {
        fontSize: 14,
        color: theme.colors.textDim,
    },
    summaryStats: {
        flexDirection: 'row',
        width: '100%',
        justifyContent: 'space-evenly',
        marginTop: 24,
        paddingTop: 24,
        borderTopWidth: 1,
        borderTopColor: 'rgba(255,255,255,0.05)',
    },
    summaryItem: {
        alignItems: 'center',
    },
    summaryValue: {
        fontSize: 20,
        fontWeight: 'bold',
        color: theme.colors.text,
        marginTop: 4,
    },
    summaryLabel: {
        fontSize: 12,
        color: theme.colors.textDim,
    },
    dividerVertical: {
        width: 1,
        height: 40,
        backgroundColor: 'rgba(255,255,255,0.05)',
    },
    statsGrid: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: 16,
        marginBottom: 24,
    },
    statCard: {
        width: (width - 48 - 16) / 2,
        backgroundColor: theme.colors.surface,
        padding: 16,
        borderRadius: theme.borderRadius.lg,
        flexDirection: 'row',
        alignItems: 'center',
        gap: 12,
        borderWidth: 1,
        borderColor: theme.colors.border,
    },
    statIcon: {
        width: 36,
        height: 36,
        borderRadius: 18,
        justifyContent: 'center',
        alignItems: 'center',
    },
    statValue: {
        color: theme.colors.text,
    },
    statTitle: {
        color: theme.colors.textDim,
    },
    section: {
        marginTop: 10,
    },
    sectionTitle: {
        color: theme.colors.text,
        marginBottom: 16,
    },
    insightCard: {
        backgroundColor: theme.colors.surface,
        padding: 20,
        borderRadius: theme.borderRadius.lg,
        flexDirection: 'row',
        alignItems: 'center',
        gap: 16,
        borderWidth: 1,
        borderColor: theme.colors.border,
    },
    insightText: {
        flex: 1,
        color: theme.colors.text,
        lineHeight: 20,
        fontSize: 14,
    },
});

export default DashboardScreen;

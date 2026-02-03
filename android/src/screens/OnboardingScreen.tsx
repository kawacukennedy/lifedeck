import React, { useState } from 'react';
import { View, Text, StyleSheet, SafeAreaView, TouchableOpacity, TextInput, ScrollView, Dimensions, Switch } from 'react-native';
import { useDispatch } from 'react-redux';
import { completeOnboarding, updateProfile, updateSettings } from '../store/slices/userSlice';
import { theme } from '../utils/theme';
import { ArrowRight, CheckCircle2, Circle, Heart, PieChart, Activity, TrendingUp } from 'lucide-react-native';

const { width } = Dimensions.get('window');

const OnboardingScreen = () => {
    const dispatch = useDispatch();
    const [step, setStep] = useState(1);
    const [name, setName] = useState('');
    const [focusAreas, setFocusAreas] = useState<string[]>([]);
    const [integrations, setIntegrations] = useState({
        health: false,
        calendar: false,
        finance: false,
    });

    const domains = [
        { id: 'HEALTH', icon: Heart, color: '#E57373' },
        { id: 'FINANCE', icon: PieChart, color: '#3AA79D' },
        { id: 'PRODUCTIVITY', icon: Activity, color: '#3B6BA5' },
        { id: 'MINDFULNESS', icon: TrendingUp, color: '#9C27B0' },
    ];

    const toggleFocus = (domain: string) => {
        if (focusAreas.includes(domain)) {
            setFocusAreas(focusAreas.filter(f => f !== domain));
        } else {
            setFocusAreas([...focusAreas, domain]);
        }
    };

    const nextStep = () => {
        if (step === 1 && name) {
            dispatch(updateProfile({ name }));
            setStep(2);
        } else if (step === 2 && focusAreas.length > 0) {
            setStep(3);
        } else if (step === 3) {
            dispatch(updateSettings({
                healthKitEnabled: integrations.health,
                calendarEnabled: integrations.calendar,
                financeEnabled: integrations.finance
            }));
            setStep(4);
        } else if (step === 4) {
            dispatch(completeOnboarding());
        }
    };

    return (
        <SafeAreaView style={styles.container}>
            <View style={styles.progressContainer}>
                {[1, 2, 3, 4].map(i => (
                    <View key={i} style={[styles.progressDot, { backgroundColor: i <= step ? theme.colors.primary : theme.colors.surface }]} />
                ))}
            </View>

            <ScrollView contentContainerStyle={styles.content}>
                {step === 1 && (
                    <View style={styles.stepContainer}>
                        <Text style={styles.heroText}>What should we call you?</Text>
                        <Text style={styles.subHeroText}>Personalizing your coaching experience leads to 2x better results.</Text>
                        <TextInput
                            style={styles.input}
                            placeholder="Your name"
                            placeholderTextColor={theme.colors.textDim}
                            value={name}
                            onChangeText={setName}
                            autoFocus
                        />
                    </View>
                )}

                {step === 2 && (
                    <View style={styles.stepContainer}>
                        <Text style={styles.heroText}>Choose your focus</Text>
                        <Text style={styles.subHeroText}>LifeDeck will curate cards based on your primary growth areas.</Text>
                        <View style={styles.domainGrid}>
                            {domains.map(domain => (
                                <TouchableOpacity
                                    key={domain.id}
                                    style={[styles.domainCard, focusAreas.includes(domain.id) && styles.domainCardActive]}
                                    onPress={() => toggleFocus(domain.id)}
                                >
                                    <domain.icon color={focusAreas.includes(domain.id) ? domain.color : theme.colors.textDim} size={32} />
                                    <Text style={[styles.domainLabel, focusAreas.includes(domain.id) && styles.domainLabelActive]}>{domain.id}</Text>
                                </TouchableOpacity>
                            ))}
                        </View>
                    </View>
                )}

                {step === 3 && (
                    <View style={styles.stepContainer}>
                        <Text style={styles.heroText}>Power up with Data</Text>
                        <Text style={styles.subHeroText}>Sync your apps to unlock context-aware actions.</Text>

                        <View style={styles.integrationList}>
                            <View style={styles.integrationItem}>
                                <View>
                                    <Text style={styles.integrationTitle}>Health & Fitness</Text>
                                    <Text style={styles.integrationDesc}>Sync steps, sleep, and activity.</Text>
                                </View>
                                <Switch
                                    value={integrations.health}
                                    onValueChange={(val) => setIntegrations({ ...integrations, health: val })}
                                    trackColor={{ false: theme.colors.surface, true: theme.colors.primary }}
                                />
                            </View>

                            <View style={styles.integrationItem}>
                                <View>
                                    <Text style={styles.integrationTitle}>Calendar</Text>
                                    <Text style={styles.integrationDesc}>Plan actions around your schedule.</Text>
                                </View>
                                <Switch
                                    value={integrations.calendar}
                                    onValueChange={(val) => setIntegrations({ ...integrations, calendar: val })}
                                    trackColor={{ false: theme.colors.surface, true: theme.colors.primary }}
                                />
                            </View>
                        </View>
                    </View>
                )}

                {step === 4 && (
                    <View style={styles.stepContainer}>
                        <Text style={styles.heroText}>Ready to launch?</Text>
                        <Text style={styles.subHeroText}>Your personalized deck is waiting. Let's start building your best self.</Text>
                        <View style={styles.readyCard}>
                            <CheckCircle2 color={theme.colors.primary} size={64} />
                            <Text style={styles.readyText}>Structure is Freedom.</Text>
                        </View>
                    </View>
                )}
            </ScrollView>

            <View style={styles.footer}>
                <TouchableOpacity
                    style={[styles.nextButton, (!name && step === 1) || (focusAreas.length === 0 && step === 2) ? styles.buttonDisabled : null]}
                    onPress={nextStep}
                    disabled={(!name && step === 1) || (focusAreas.length === 0 && step === 2)}
                >
                    <Text style={styles.nextButtonText}>{step === 4 ? "Enter LifeDeck" : "Next"}</Text>
                    <ArrowRight color="#fff" size={20} />
                </TouchableOpacity>
            </View>
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: theme.colors.background,
    },
    progressContainer: {
        flexDirection: 'row',
        justifyContent: 'center',
        padding: theme.spacing.lg,
        gap: 10,
    },
    progressDot: {
        width: 30,
        height: 6,
        borderRadius: 3,
    },
    content: {
        padding: theme.spacing.xl,
    },
    stepContainer: {
        flex: 1,
    },
    heroText: {
        fontSize: 34,
        fontWeight: 'bold',
        color: theme.colors.text,
        marginBottom: 12,
    },
    subHeroText: {
        fontSize: 18,
        color: theme.colors.textDim,
        lineHeight: 26,
        marginBottom: 40,
    },
    input: {
        backgroundColor: theme.colors.surface,
        padding: 20,
        borderRadius: theme.borderRadius.md,
        color: theme.colors.text,
        fontSize: 20,
        borderWidth: 1,
        borderColor: theme.colors.border,
    },
    domainGrid: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        gap: 16,
    },
    domainCard: {
        width: (width - 64 - 16) / 2,
        aspectRatio: 1,
        backgroundColor: theme.colors.surface,
        borderRadius: theme.borderRadius.lg,
        padding: 20,
        justifyContent: 'center',
        alignItems: 'center',
        borderWidth: 1,
        borderColor: theme.colors.border,
    },
    domainCardActive: {
        borderColor: theme.colors.primary,
        backgroundColor: 'rgba(59, 107, 165, 0.1)',
    },
    domainLabel: {
        marginTop: 12,
        color: theme.colors.textDim,
        fontWeight: 'bold',
        fontSize: 14,
    },
    domainLabelActive: {
        color: theme.colors.text,
    },
    integrationList: {
        gap: 16,
    },
    integrationItem: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        backgroundColor: theme.colors.surface,
        padding: 20,
        borderRadius: theme.borderRadius.lg,
        borderWidth: 1,
        borderColor: theme.colors.border,
    },
    integrationTitle: {
        color: theme.colors.text,
        fontSize: 18,
        fontWeight: 'bold',
    },
    integrationDesc: {
        color: theme.colors.textDim,
        fontSize: 14,
        marginTop: 4,
    },
    readyCard: {
        backgroundColor: theme.colors.surface,
        padding: 40,
        borderRadius: theme.borderRadius.xl,
        alignItems: 'center',
        borderWidth: 1,
        borderColor: theme.colors.border,
        marginTop: 20,
    },
    readyText: {
        color: theme.colors.text,
        fontSize: 24,
        fontWeight: 'bold',
        marginTop: 20,
        fontStyle: 'italic',
        opacity: 0.8,
    },
    footer: {
        padding: theme.spacing.xl,
    },
    nextButton: {
        backgroundColor: theme.colors.primary,
        height: 64,
        borderRadius: 32,
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        gap: 10,
    },
    buttonDisabled: {
        opacity: 0.5,
    },
    nextButtonText: {
        color: '#fff',
        fontSize: 20,
        fontWeight: 'bold',
    },
});

export default OnboardingScreen;

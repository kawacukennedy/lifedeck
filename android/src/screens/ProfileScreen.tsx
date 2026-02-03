import React from 'react';
import { View, Text, StyleSheet, SafeAreaView, TouchableOpacity, ScrollView, Switch } from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { RootState } from '../store';
import { updateSettings } from '../store/slices/userSlice';
import { theme } from '../utils/theme';
import { User, Bell, Shield, CreditCard, ChevronRight, LogOut } from 'lucide-react-native';
import { useNavigation } from '@react-navigation/native';

const SettingItem = ({ icon: Icon, title, subtitle, value, onValueChange, isSwitch, onPress }: any) => (
    <TouchableOpacity style={styles.settingItem} onPress={onPress} disabled={isSwitch}>
        <View style={styles.settingIcon}>
            <Icon color={theme.colors.text} size={22} />
        </View>
        <View style={styles.settingInfo}>
            <Text style={styles.settingTitle}>{title}</Text>
            {subtitle && <Text style={styles.settingSubtitle}>{subtitle}</Text>}
        </View>
        {isSwitch ? (
            <Switch
                value={value}
                onValueChange={onValueChange}
                trackColor={{ false: theme.colors.surface, true: theme.colors.primary }}
                thumbColor="#fff"
            />
        ) : (
            <ChevronRight color={theme.colors.textDim} size={20} />
        )}
    </TouchableOpacity>
);

const ProfileScreen = () => {
    const dispatch = useDispatch();
    const navigation = useNavigation<any>();
    const { name, email, settings, subscriptionTier } = useSelector((state: RootState) => state.user);

    return (
        <SafeAreaView style={styles.container}>
            <ScrollView contentContainerStyle={styles.content}>
                <View style={styles.profileHeader}>
                    <View style={styles.avatar}>
                        <Text style={styles.avatarText}>{name ? name[0].toUpperCase() : 'U'}</Text>
                    </View>
                    <Text style={styles.profileName}>{name || 'LifeDeck User'}</Text>
                    <Text style={styles.profileEmail}>{email || 'No email provided'}</Text>

                    <View style={styles.premiumCard}>
                        <Text style={styles.premiumTitle}>LifeDeck Premium</Text>
                        <Text style={styles.premiumSubtitle}>Unlock AI-personalized cards and deep analytics.</Text>
                        <TouchableOpacity style={styles.upgradeButton}>
                            <Text style={styles.upgradeButtonText}>Upgrade Now</Text>
                        </TouchableOpacity>
                    </View>

                    <View style={styles.section}>
                        <Text style={styles.sectionTitle}>Account</Text>
                        <SettingItem icon={User} title="Edit Profile" />
                        <SettingItem icon={CreditCard} title="Subscription" subtitle={subscriptionTier === 'free' ? 'Upgrade for AI personalized cards' : 'Manage your premium plan'} />
                    </View>

                    <View style={styles.section}>
                        <Text style={styles.sectionTitle}>Preferences</Text>
                        <SettingItem
                            icon={Bell}
                            title="Notifications"
                            isSwitch
                            value={settings.notificationsEnabled}
                            onValueChange={(val: boolean) => dispatch(updateSettings({ notificationsEnabled: val }))}
                        />
                        <SettingItem icon={Shield} title="Privacy & Security" />
                    </View>

                    <View style={styles.section}>
                        <Text style={styles.sectionTitle}>Achievements</Text>
                        <TouchableOpacity style={styles.achievementsCard} onPress={() => navigation.navigate('Achievements')}>
                            <View style={styles.achievementPreview}>
                                <Text style={styles.achievementEmoji}>🏆</Text>
                                <Text style={styles.achievementEmoji}>🔥</Text>
                                <Text style={styles.achievementEmoji}>🎯</Text>
                            </View>
                            <Text style={styles.viewAchievementsLink}>View all achievements</Text>
                            <ChevronRight color={theme.colors.primary} size={20} />
                        </TouchableOpacity>
                    </View>

                    <TouchableOpacity style={styles.logoutButton}>
                        <LogOut color={theme.colors.error} size={20} />
                        <Text style={styles.logoutText}>Log Out</Text>
                    </TouchableOpacity>

                    <Text style={styles.versionText}>LifeDeck v1.0.0 (Building with Expo)</Text>
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
    profileHeader: {
        alignItems: 'center',
        marginBottom: 40,
        marginTop: 20,
    },
    avatar: {
        width: 100,
        height: 100,
        borderRadius: 50,
        backgroundColor: theme.colors.primary,
        justifyContent: 'center',
        alignItems: 'center',
        marginBottom: 16,
        shadowColor: theme.colors.primary,
        shadowOffset: { width: 0, height: 8 },
        shadowOpacity: 0.3,
        shadowRadius: 12,
        elevation: 8,
    },
    avatarText: {
        fontSize: 40,
        fontWeight: 'bold',
        color: '#fff',
    },
    profileName: {
        fontSize: 24,
        fontWeight: 'bold',
        color: theme.colors.text,
    },
    profileEmail: {
        fontSize: 14,
        color: theme.colors.textDim,
        marginTop: 4,
    },
    tierBadge: {
        marginTop: 16,
        paddingHorizontal: 16,
        paddingVertical: 6,
        borderRadius: 20,
        borderWidth: 1,
        borderColor: theme.colors.border,
    },
    tierText: {
        fontSize: 12,
        fontWeight: 'bold',
        color: theme.colors.text,
        letterSpacing: 1,
    },
    section: {
        marginBottom: 32,
    },
    sectionTitle: {
        fontSize: 14,
        fontWeight: 'bold',
        color: theme.colors.textDim,
        textTransform: 'uppercase',
        letterSpacing: 1.5,
        marginBottom: 12,
        marginLeft: 4,
    },
    settingItem: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: theme.colors.surface,
        padding: 16,
        borderRadius: theme.borderRadius.md,
        marginBottom: 8,
        borderWidth: 1,
        borderColor: theme.colors.border,
    },
    settingIcon: {
        width: 40,
        height: 40,
        borderRadius: 10,
        backgroundColor: 'rgba(255,255,255,0.05)',
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: 16,
    },
    settingInfo: {
        flex: 1,
    },
    settingTitle: {
        fontSize: 16,
        fontWeight: '600',
        color: theme.colors.text,
    },
    settingSubtitle: {
        fontSize: 12,
        color: theme.colors.textDim,
        marginTop: 2,
    },
    achievementsCard: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: theme.colors.surface,
        padding: 20,
        borderRadius: theme.borderRadius.lg,
        borderWidth: 1,
        borderColor: theme.colors.border,
    },
    achievementPreview: {
        flexDirection: 'row',
        marginRight: 16,
        gap: 4,
    },
    achievementEmoji: {
        fontSize: 24,
    },
    viewAchievementsLink: {
        flex: 1,
        fontSize: 16,
        fontWeight: '600',
        color: theme.colors.text,
    },
    logoutButton: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 16,
        gap: 10,
        marginTop: 20,
    },
    logoutText: {
        color: theme.colors.error,
        fontSize: 16,
        fontWeight: 'bold',
    },
    versionText: {
        textAlign: 'center',
        color: theme.colors.textDim,
        fontSize: 12,
        marginTop: 40,
        marginBottom: 20,
    },
    premiumCard: {
        backgroundColor: theme.colors.surface,
        padding: 24,
        borderRadius: theme.borderRadius.xl,
        marginBottom: 32,
        borderWidth: 1,
        borderColor: theme.colors.primary,
        shadowColor: theme.colors.primary,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.1,
        shadowRadius: 10,
    },
    premiumTitle: {
        fontSize: 20,
        fontWeight: 'bold',
        color: theme.colors.text,
        marginBottom: 8,
    },
    premiumSubtitle: {
        fontSize: 14,
        color: theme.colors.textDim,
        lineHeight: 20,
        marginBottom: 20,
    },
    upgradeButton: {
        backgroundColor: theme.colors.primary,
        paddingVertical: 12,
        borderRadius: theme.borderRadius.md,
        alignItems: 'center',
    },
    upgradeButtonText: {
        color: '#fff',
        fontWeight: 'bold',
        fontSize: 16,
    },
});

export default ProfileScreen;

import { useEffect, useState } from 'react';
import { useStore } from '../store/useStore';
import { apiService } from '../lib/api';
import Layout from '../components/Layout';
import { motion } from 'framer-motion';
import {
  User,
  Settings,
  Bell,
  Moon,
  Sun,
  Save,
  Edit,
  Camera,
  Mail,
  Calendar,
  Trophy,
  Target,
  Clock,
  Heart,
  DollarSign,
  Leaf,
} from 'lucide-react';

interface UserProfile {
  id: string;
  email: string;
  name?: string;
  avatar?: string;
  subscriptionTier: string;
  progress: {
    healthScore: number;
    financeScore: number;
    productivityScore: number;
    mindfulnessScore: number;
    lifeScore: number;
    currentStreak: number;
    lifePoints: number;
    totalCardsCompleted: number;
    lastActiveDate?: string;
  };
  joinDate: string;
  preferredDomains?: string[];
  goals?: string;
}

interface UserSettings {
  notificationsEnabled: boolean;
  dailyReminderTime: string;
  preferredDomains: string[];
  maxDailyCards: number;
  soundEnabled: boolean;
  hapticEnabled: boolean;
  dataShareEnabled: boolean;
  healthKitEnabled: boolean;
  calendarEnabled: boolean;
  locationEnabled: boolean;
}

export default function ProfilePage() {
  const { user, setUser } = useStore();
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [settings, setSettings] = useState<UserSettings | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [activeTab, setActiveTab] = useState<'profile' | 'settings'>('profile');

  useEffect(() => {
    loadProfileData();
  }, []);

  const loadProfileData = async () => {
    setLoading(true);
    try {
      const [profileResponse, settingsResponse] = await Promise.all([
        apiService.getProfile(),
        apiService.getUserSettings?.() || Promise.resolve(null),
      ]);

      setProfile(profileResponse);
      setSettings(settingsResponse || {
        notificationsEnabled: true,
        dailyReminderTime: '09:00',
        preferredDomains: ['health', 'productivity'],
        maxDailyCards: 5,
        soundEnabled: true,
        hapticEnabled: true,
        dataShareEnabled: false,
        healthKitEnabled: false,
        calendarEnabled: false,
        locationEnabled: false,
      });
    } catch (error) {
      console.error('Failed to load profile:', error);
      // Use store data as fallback
      setProfile(user as UserProfile);
      setSettings({
        notificationsEnabled: true,
        dailyReminderTime: '09:00',
        preferredDomains: ['health', 'productivity'],
        maxDailyCards: 5,
        soundEnabled: true,
        hapticEnabled: true,
        dataShareEnabled: false,
        healthKitEnabled: false,
        calendarEnabled: false,
        locationEnabled: false,
      });
    } finally {
      setLoading(false);
    }
  };

  const handleSaveProfile = async () => {
    if (!profile) return;

    setSaving(true);
    try {
      await apiService.updateProfile({
        name: profile.name,
        goals: profile.goals,
        preferredDomains: profile.preferredDomains,
      });

      setUser({
        ...user!,
        name: profile.name,
        goals: profile.goals,
        preferredDomains: profile.preferredDomains,
      });

      setIsEditing(false);
    } catch (error) {
      console.error('Failed to save profile:', error);
    } finally {
      setSaving(false);
    }
  };

  const handleSaveSettings = async () => {
    if (!settings) return;

    setSaving(true);
    try {
      await apiService.updateSettings(settings);
      // Settings saved successfully
    } catch (error) {
      console.error('Failed to save settings:', error);
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <Layout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-lifedeck-textSecondary">Loading profile...</div>
        </div>
      </Layout>
    );
  }

  if (!profile) {
    return (
      <Layout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-lifedeck-textSecondary">Failed to load profile</div>
        </div>
      </Layout>
    );
  }

  const domainIcons = {
    health: Heart,
    finance: DollarSign,
    productivity: Clock,
    mindfulness: Leaf,
  };

  const domainColors = {
    health: 'text-red-400',
    finance: 'text-green-400',
    productivity: 'text-blue-400',
    mindfulness: 'text-purple-400',
  };

  return (
    <Layout>
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-8"
        >
          <h1 className="text-3xl font-bold text-lifedeck-text mb-2">
            👤 Profile & Settings
          </h1>
          <p className="text-lifedeck-textSecondary">
            Manage your account and customize your LifeDeck experience
          </p>
        </motion.div>

        {/* Tabs */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="mb-8"
        >
          <div className="flex space-x-1 bg-lifedeck-surface rounded-lg p-1 border border-lifedeck-border">
            <button
              onClick={() => setActiveTab('profile')}
              className={`flex-1 py-3 px-6 rounded-md font-medium transition-colors flex items-center justify-center space-x-2 ${
                activeTab === 'profile'
                  ? 'bg-lifedeck-primary text-white'
                  : 'text-lifedeck-textSecondary hover:text-lifedeck-text'
              }`}
            >
              <User className="w-4 h-4" />
              <span>Profile</span>
            </button>
            <button
              onClick={() => setActiveTab('settings')}
              className={`flex-1 py-3 px-6 rounded-md font-medium transition-colors flex items-center justify-center space-x-2 ${
                activeTab === 'settings'
                  ? 'bg-lifedeck-primary text-white'
                  : 'text-lifedeck-textSecondary hover:text-lifedeck-text'
              }`}
            >
              <Settings className="w-4 h-4" />
              <span>Settings</span>
            </button>
          </div>
        </motion.div>

        {activeTab === 'profile' && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="space-y-8"
          >
            {/* Profile Info */}
            <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl font-semibold text-lifedeck-text">Profile Information</h2>
                <button
                  onClick={() => setIsEditing(!isEditing)}
                  className="flex items-center space-x-2 px-4 py-2 bg-lifedeck-background hover:bg-lifedeck-border rounded-lg transition-colors"
                >
                  <Edit className="w-4 h-4" />
                  <span>{isEditing ? 'Cancel' : 'Edit'}</span>
                </button>
              </div>

              <div className="space-y-6">
                {/* Avatar */}
                <div className="flex items-center space-x-6">
                  <div className="w-20 h-20 bg-lifedeck-primary rounded-full flex items-center justify-center">
                    {profile.avatar ? (
                      <img src={profile.avatar} alt="Avatar" className="w-full h-full rounded-full" />
                    ) : (
                      <User className="w-10 h-10 text-white" />
                    )}
                  </div>
                  {isEditing && (
                    <button className="flex items-center space-x-2 px-4 py-2 bg-lifedeck-background hover:bg-lifedeck-border rounded-lg transition-colors">
                      <Camera className="w-4 h-4" />
                      <span>Change Photo</span>
                    </button>
                  )}
                </div>

                {/* Basic Info */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-lifedeck-text mb-2">
                      Full Name
                    </label>
                    {isEditing ? (
                      <input
                        type="text"
                        value={profile.name || ''}
                        onChange={(e) => setProfile({ ...profile, name: e.target.value })}
                        className="w-full px-4 py-3 bg-lifedeck-background border border-lifedeck-border rounded-lg focus:outline-none focus:ring-2 focus:ring-lifedeck-primary text-lifedeck-text"
                      />
                    ) : (
                      <div className="px-4 py-3 bg-lifedeck-background border border-lifedeck-border rounded-lg text-lifedeck-text">
                        {profile.name || 'Not set'}
                      </div>
                    )}
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-lifedeck-text mb-2">
                      Email
                    </label>
                    <div className="px-4 py-3 bg-lifedeck-background border border-lifedeck-border rounded-lg text-lifedeck-text flex items-center space-x-2">
                      <Mail className="w-4 h-4 text-lifedeck-textSecondary" />
                      <span>{profile.email}</span>
                    </div>
                  </div>
                </div>

                {/* Goals */}
                <div>
                  <label className="block text-sm font-medium text-lifedeck-text mb-2">
                    Personal Goals
                  </label>
                  {isEditing ? (
                    <textarea
                      value={profile.goals || ''}
                      onChange={(e) => setProfile({ ...profile, goals: e.target.value })}
                      className="w-full px-4 py-3 bg-lifedeck-background border border-lifedeck-border rounded-lg focus:outline-none focus:ring-2 focus:ring-lifedeck-primary text-lifedeck-text h-32 resize-none"
                      placeholder="What are your main goals for using LifeDeck?"
                    />
                  ) : (
                    <div className="px-4 py-3 bg-lifedeck-background border border-lifedeck-border rounded-lg text-lifedeck-text min-h-[80px]">
                      {profile.goals || 'No goals set yet'}
                    </div>
                  )}
                </div>

                {/* Preferred Domains */}
                <div>
                  <label className="block text-sm font-medium text-lifedeck-text mb-4">
                    Preferred Life Domains
                  </label>
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    {['health', 'finance', 'productivity', 'mindfulness'].map((domain) => {
                      const Icon = domainIcons[domain as keyof typeof domainIcons];
                      const isSelected = profile.preferredDomains?.includes(domain) || false;

                      return (
                        <button
                          key={domain}
                          disabled={!isEditing}
                          onClick={() => {
                            if (!isEditing) return;
                            const current = profile.preferredDomains || [];
                            const updated = isSelected
                              ? current.filter(d => d !== domain)
                              : [...current, domain];
                            setProfile({ ...profile, preferredDomains: updated });
                          }}
                          className={`p-4 rounded-lg border-2 transition-all ${
                            isSelected
                              ? 'border-lifedeck-primary bg-lifedeck-primary/5'
                              : 'border-lifedeck-border bg-lifedeck-background'
                          } ${!isEditing ? 'cursor-default' : 'hover:border-lifedeck-primary/50'}`}
                        >
                          <div className="flex flex-col items-center space-y-2">
                            <Icon className={`w-6 h-6 ${isSelected ? 'text-lifedeck-primary' : domainColors[domain as keyof typeof domainColors]}`} />
                            <span className={`text-sm font-medium capitalize ${isSelected ? 'text-lifedeck-primary' : 'text-lifedeck-text'}`}>
                              {domain}
                            </span>
                          </div>
                        </button>
                      );
                    })}
                  </div>
                </div>

                {isEditing && (
                  <div className="flex justify-end space-x-4">
                    <button
                      onClick={() => setIsEditing(false)}
                      className="px-6 py-3 bg-lifedeck-background hover:bg-lifedeck-border text-lifedeck-text rounded-lg transition-colors"
                    >
                      Cancel
                    </button>
                    <button
                      onClick={handleSaveProfile}
                      disabled={saving}
                      className="px-6 py-3 bg-lifedeck-primary hover:bg-lifedeck-primary/80 text-white rounded-lg transition-colors flex items-center space-x-2"
                    >
                      <Save className="w-4 h-4" />
                      <span>{saving ? 'Saving...' : 'Save Changes'}</span>
                    </button>
                  </div>
                )}
              </div>
            </div>

            {/* Stats Overview */}
            <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
              <h2 className="text-xl font-semibold text-lifedeck-text mb-6">Your Progress</h2>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
                <div className="text-center">
                  <div className="text-2xl font-bold text-lifedeck-primary mb-1">
                    {profile.progress.lifeScore.toFixed(1)}
                  </div>
                  <div className="text-sm text-lifedeck-textSecondary">Life Score</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-green-400 mb-1">
                    {profile.progress.currentStreak}
                  </div>
                  <div className="text-sm text-lifedeck-textSecondary">Current Streak</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-yellow-400 mb-1">
                    {profile.progress.lifePoints}
                  </div>
                  <div className="text-sm text-lifedeck-textSecondary">Life Points</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-purple-400 mb-1">
                    {profile.progress.totalCardsCompleted}
                  </div>
                  <div className="text-sm text-lifedeck-textSecondary">Cards Completed</div>
                </div>
              </div>
            </div>
          </motion.div>
        )}

        {activeTab === 'settings' && settings && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="space-y-8"
          >
            {/* Notifications */}
            <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
              <h2 className="text-xl font-semibold text-lifedeck-text mb-6 flex items-center space-x-2">
                <Bell className="w-5 h-5" />
                <span>Notifications</span>
              </h2>

              <div className="space-y-6">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-medium text-lifedeck-text">Push Notifications</h3>
                    <p className="text-sm text-lifedeck-textSecondary">Receive notifications about your cards and progress</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      checked={settings.notificationsEnabled}
                      onChange={(e) => setSettings({ ...settings, notificationsEnabled: e.target.checked })}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-lifedeck-border peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-lifedeck-primary/25 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-lifedeck-primary"></div>
                  </label>
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-medium text-lifedeck-text">Daily Reminders</h3>
                    <p className="text-sm text-lifedeck-textSecondary">Get reminded to complete your daily cards</p>
                  </div>
                  <input
                    type="time"
                    value={settings.dailyReminderTime}
                    onChange={(e) => setSettings({ ...settings, dailyReminderTime: e.target.value })}
                    className="px-3 py-2 bg-lifedeck-background border border-lifedeck-border rounded-lg focus:outline-none focus:ring-2 focus:ring-lifedeck-primary text-lifedeck-text"
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-medium text-lifedeck-text">Sound Effects</h3>
                    <p className="text-sm text-lifedeck-textSecondary">Play sounds for interactions</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      checked={settings.soundEnabled}
                      onChange={(e) => setSettings({ ...settings, soundEnabled: e.target.checked })}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-lifedeck-border peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-lifedeck-primary/25 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-lifedeck-primary"></div>
                  </label>
                </div>
              </div>
            </div>

            {/* Integrations */}
            <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
              <h2 className="text-xl font-semibold text-lifedeck-text mb-6">Integrations</h2>

              <div className="space-y-6">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-medium text-lifedeck-text">Health Data</h3>
                    <p className="text-sm text-lifedeck-textSecondary">Sync with Apple Health or Google Fit</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      checked={settings.healthKitEnabled}
                      onChange={(e) => setSettings({ ...settings, healthKitEnabled: e.target.checked })}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-lifedeck-border peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-lifedeck-primary/25 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-lifedeck-primary"></div>
                  </label>
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-medium text-lifedeck-text">Calendar Sync</h3>
                    <p className="text-sm text-lifedeck-textSecondary">Sync habits with your calendar</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      checked={settings.calendarEnabled}
                      onChange={(e) => setSettings({ ...settings, calendarEnabled: e.target.checked })}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-lifedeck-border peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-lifedeck-primary/25 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-lifedeck-primary"></div>
                  </label>
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-medium text-lifedeck-text">Location Services</h3>
                    <p className="text-sm text-lifedeck-textSecondary">Enable location-based reminders</p>
                  </div>
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      checked={settings.locationEnabled}
                      onChange={(e) => setSettings({ ...settings, locationEnabled: e.target.checked })}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-lifedeck-border peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-lifedeck-primary/25 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-lifedeck-primary"></div>
                  </label>
                </div>
              </div>
            </div>

            {/* Preferences */}
            <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border">
              <h2 className="text-xl font-semibold text-lifedeck-text mb-6">Preferences</h2>

              <div className="space-y-6">
                <div>
                  <label className="block text-sm font-medium text-lifedeck-text mb-2">
                    Max Daily Cards
                  </label>
                  <select
                    value={settings.maxDailyCards}
                    onChange={(e) => setSettings({ ...settings, maxDailyCards: parseInt(e.target.value) })}
                    className="px-4 py-3 bg-lifedeck-background border border-lifedeck-border rounded-lg focus:outline-none focus:ring-2 focus:ring-lifedeck-primary text-lifedeck-text"
                  >
                    <option value={3}>3 cards</option>
                    <option value={5}>5 cards</option>
                    <option value={7}>7 cards</option>
                    <option value={10}>10 cards</option>
                  </select>
                </div>
              </div>
            </div>

            <div className="flex justify-end">
              <button
                onClick={handleSaveSettings}
                disabled={saving}
                className="px-6 py-3 bg-lifedeck-primary hover:bg-lifedeck-primary/80 text-white rounded-lg transition-colors flex items-center space-x-2"
              >
                <Save className="w-4 h-4" />
                <span>{saving ? 'Saving...' : 'Save Settings'}</span>
              </button>
            </div>
          </motion.div>
        )}
      </div>
    </Layout>
  );
}
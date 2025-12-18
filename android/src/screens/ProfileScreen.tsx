import React, {useState} from 'react';
import {View, Text, StyleSheet, ScrollView, Switch, TouchableOpacity, TextInput} from 'react-native';
import {useSelector} from 'react-redux';
import {RootState} from '../store';

const ProfileScreen = () => {
  const user = useSelector((state: RootState) => state.user);
  const [settings, setSettings] = useState({
    notificationsEnabled: true,
    dailyReminderTime: '09:00',
    contextAwareEnabled: false,
    morningReminders: false,
    workBreakReminders: false,
    commuteReminders: false,
    locationBasedReminders: false,
  });
  const [integrationStatus, setIntegrationStatus] = useState({
    googleCalendar: false,
    googleFit: false,
    plaid: false,
  });

  const updateSetting = (key: string, value: boolean | string) => {
    setSettings(prev => ({ ...prev, [key]: value }));
  };

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Profile & Settings</Text>

      {/* Basic Notifications */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>🔔 Notifications</Text>

        <View style={styles.settingRow}>
          <View style={styles.settingInfo}>
            <Text style={styles.settingTitle}>Push Notifications</Text>
            <Text style={styles.settingDescription}>Receive notifications about your cards and progress</Text>
          </View>
          <Switch
            value={settings.notificationsEnabled}
            onValueChange={(value) => updateSetting('notificationsEnabled', value)}
            trackColor={{ false: '#767577', true: '#2196F3' }}
            thumbColor={settings.notificationsEnabled ? '#fff' : '#f4f3f4'}
          />
        </View>

        <View style={styles.settingRow}>
          <View style={styles.settingInfo}>
            <Text style={styles.settingTitle}>Daily Reminders</Text>
            <Text style={styles.settingDescription}>Get reminded to complete your daily cards</Text>
          </View>
          <TextInput
            style={styles.timeInput}
            value={settings.dailyReminderTime}
            onChangeText={(value) => updateSetting('dailyReminderTime', value)}
            placeholder="09:00"
          />
        </View>
      </View>

      {/* Context-Aware Notifications */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>🧠 Smart Notifications</Text>

        <View style={styles.settingRow}>
          <View style={styles.settingInfo}>
            <Text style={styles.settingTitle}>Context-Aware Reminders</Text>
            <Text style={styles.settingDescription}>Get personalized notifications based on your location, time, and activity</Text>
          </View>
          <Switch
            value={settings.contextAwareEnabled}
            onValueChange={(value) => updateSetting('contextAwareEnabled', value)}
            trackColor={{ false: '#767577', true: '#2196F3' }}
            thumbColor={settings.contextAwareEnabled ? '#fff' : '#f4f3f4'}
          />
        </View>

        {settings.contextAwareEnabled && (
          <View style={styles.subSettings}>
            <View style={styles.settingRow}>
              <View style={styles.settingInfo}>
                <Text style={styles.settingTitle}>Morning Motivation</Text>
                <Text style={styles.settingDescription}>Remind me to start my day with a mindful activity when it's sunny</Text>
              </View>
              <Switch
                value={settings.morningReminders}
                onValueChange={(value) => updateSetting('morningReminders', value)}
                trackColor={{ false: '#767577', true: '#2196F3' }}
                thumbColor={settings.morningReminders ? '#fff' : '#f4f3f4'}
              />
            </View>

            <View style={styles.settingRow}>
              <View style={styles.settingInfo}>
                <Text style={styles.settingTitle}>Work Break Reminders</Text>
                <Text style={styles.settingDescription}>Suggest quick mindfulness exercises during work hours</Text>
              </View>
              <Switch
                value={settings.workBreakReminders}
                onValueChange={(value) => updateSetting('workBreakReminders', value)}
                trackColor={{ false: '#767577', true: '#2196F3' }}
                thumbColor={settings.workBreakReminders ? '#fff' : '#f4f3f4'}
              />
            </View>

            <View style={styles.settingRow}>
              <View style={styles.settingInfo}>
                <Text style={styles.settingTitle}>Commute Time</Text>
                <Text style={styles.settingDescription}>Use travel time for breathing exercises or reflection</Text>
              </View>
              <Switch
                value={settings.commuteReminders}
                onValueChange={(value) => updateSetting('commuteReminders', value)}
                trackColor={{ false: '#767577', true: '#2196F3' }}
                thumbColor={settings.commuteReminders ? '#fff' : '#f4f3f4'}
              />
            </View>

            <View style={styles.settingRow}>
              <View style={styles.settingInfo}>
                <Text style={styles.settingTitle}>Location-Based</Text>
                <Text style={styles.settingDescription}>Contextual reminders based on your current location</Text>
              </View>
              <Switch
                value={settings.locationBasedReminders}
                onValueChange={(value) => updateSetting('locationBasedReminders', value)}
                trackColor={{ false: '#767577', true: '#2196F3' }}
                thumbColor={settings.locationBasedReminders ? '#fff' : '#f4f3f4'}
              />
            </View>
          </View>
        )}
      </View>

      {/* Integrations */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>🔗 Integrations</Text>

        <View style={styles.integrationRow}>
          <View style={styles.integrationInfo}>
            <View style={styles.integrationHeader}>
              <Text style={styles.integrationTitle}>Google Calendar</Text>
              {integrationStatus.googleCalendar ? (
                <View style={styles.statusBadge}>
                  <Text style={styles.statusTextConnected}>Connected</Text>
                </View>
              ) : (
                <View style={styles.statusBadgeDisconnected}>
                  <Text style={styles.statusTextDisconnected}>Not Connected</Text>
                </View>
              )}
            </View>
            <Text style={styles.integrationDescription}>Sync habits and schedule reminders</Text>
          </View>
          <TouchableOpacity
            style={[
              styles.connectButton,
              integrationStatus.googleCalendar ? styles.disconnectButton : styles.connectButtonPrimary
            ]}
            onPress={() => {
              // Handle OAuth flow
              console.log('Connect Google Calendar');
            }}
          >
            <Text style={[
              styles.connectButtonText,
              integrationStatus.googleCalendar ? styles.disconnectButtonText : styles.connectButtonTextPrimary
            ]}>
              {integrationStatus.googleCalendar ? 'Disconnect' : 'Connect'}
            </Text>
          </TouchableOpacity>
        </View>

        <View style={styles.integrationRow}>
          <View style={styles.integrationInfo}>
            <View style={styles.integrationHeader}>
              <Text style={styles.integrationTitle}>Google Fit</Text>
              {integrationStatus.googleFit ? (
                <View style={styles.statusBadge}>
                  <Text style={styles.statusTextConnected}>Connected</Text>
                </View>
              ) : (
                <View style={styles.statusBadgeDisconnected}>
                  <Text style={styles.statusTextDisconnected}>Not Connected</Text>
                </View>
              )}
            </View>
            <Text style={styles.integrationDescription}>Sync health and fitness data</Text>
          </View>
          <TouchableOpacity
            style={[
              styles.connectButton,
              integrationStatus.googleFit ? styles.disconnectButton : styles.connectButtonPrimary
            ]}
            onPress={() => {
              // Handle OAuth flow
              console.log('Connect Google Fit');
            }}
          >
            <Text style={[
              styles.connectButtonText,
              integrationStatus.googleFit ? styles.disconnectButtonText : styles.connectButtonTextPrimary
            ]}>
              {integrationStatus.googleFit ? 'Disconnect' : 'Connect'}
            </Text>
          </TouchableOpacity>
        </View>

        <View style={styles.integrationRow}>
          <View style={styles.integrationInfo}>
            <View style={styles.integrationHeader}>
              <Text style={styles.integrationTitle}>Plaid (Finance)</Text>
              {integrationStatus.plaid ? (
                <View style={styles.statusBadge}>
                  <Text style={styles.statusTextConnected}>Connected</Text>
                </View>
              ) : (
                <View style={styles.statusBadgeDisconnected}>
                  <Text style={styles.statusTextDisconnected}>Not Connected</Text>
                </View>
              )}
            </View>
            <Text style={styles.integrationDescription}>Connect bank accounts for spending insights</Text>
          </View>
          <TouchableOpacity
            style={[
              styles.connectButton,
              integrationStatus.plaid ? styles.disconnectButton : styles.connectButtonPrimary
            ]}
            onPress={() => {
              // Handle Plaid Link flow
              console.log('Connect Plaid');
            }}
          >
            <Text style={[
              styles.connectButtonText,
              integrationStatus.plaid ? styles.disconnectButtonText : styles.connectButtonTextPrimary
            ]}>
              {integrationStatus.plaid ? 'Disconnect' : 'Connect'}
            </Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* User Progress */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>📊 Your Progress</Text>
        <View style={styles.progressGrid}>
          <View style={styles.progressItem}>
            <Text style={styles.progressValue}>{user?.progress.lifeScore.toFixed(1) || '0.0'}</Text>
            <Text style={styles.progressLabel}>Life Score</Text>
          </View>
          <View style={styles.progressItem}>
            <Text style={styles.progressValue}>{user?.progress.currentStreak || 0}</Text>
            <Text style={styles.progressLabel}>Current Streak</Text>
          </View>
          <View style={styles.progressItem}>
            <Text style={styles.progressValue}>{user?.progress.lifePoints || 0}</Text>
            <Text style={styles.progressLabel}>Life Points</Text>
          </View>
          <View style={styles.progressItem}>
            <Text style={styles.progressValue}>{user?.progress.totalCardsCompleted || 0}</Text>
            <Text style={styles.progressLabel}>Cards Completed</Text>
          </View>
        </View>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#121212',
    padding: 20,
  },
  title: {
    fontSize: 24,
    color: '#fff',
    marginBottom: 30,
    textAlign: 'center',
  },
  section: {
    backgroundColor: '#1E1E1E',
    borderRadius: 12,
    padding: 20,
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 18,
    color: '#fff',
    fontWeight: 'bold',
    marginBottom: 15,
  },
  settingRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#333',
  },
  settingInfo: {
    flex: 1,
    marginRight: 15,
  },
  settingTitle: {
    fontSize: 16,
    color: '#fff',
    fontWeight: '500',
  },
  settingDescription: {
    fontSize: 12,
    color: '#888',
    marginTop: 2,
  },
  timeInput: {
    backgroundColor: '#333',
    color: '#fff',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 6,
    width: 80,
    textAlign: 'center',
  },
  subSettings: {
    marginLeft: 20,
    marginTop: 10,
    paddingLeft: 15,
    borderLeftWidth: 2,
    borderLeftColor: '#2196F3',
  },
  progressGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  progressItem: {
    width: '48%',
    backgroundColor: '#2A2A2A',
    borderRadius: 8,
    padding: 15,
    alignItems: 'center',
    marginBottom: 10,
  },
  progressValue: {
    fontSize: 24,
    color: '#2196F3',
    fontWeight: 'bold',
  },
  progressLabel: {
    fontSize: 12,
    color: '#888',
    marginTop: 5,
  },
  integrationRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#333',
  },
  integrationInfo: {
    flex: 1,
    marginRight: 15,
  },
  integrationHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 5,
  },
  integrationTitle: {
    fontSize: 16,
    color: '#fff',
    fontWeight: '500',
    marginRight: 10,
  },
  statusBadge: {
    backgroundColor: '#4CAF50',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 10,
  },
  statusBadgeDisconnected: {
    backgroundColor: '#666',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 10,
  },
  statusTextConnected: {
    color: '#fff',
    fontSize: 10,
    fontWeight: 'bold',
  },
  statusTextDisconnected: {
    color: '#fff',
    fontSize: 10,
    fontWeight: 'bold',
  },
  integrationDescription: {
    fontSize: 12,
    color: '#888',
  },
  connectButton: {
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 6,
  },
  connectButtonPrimary: {
    backgroundColor: '#2196F3',
  },
  disconnectButton: {
    backgroundColor: 'rgba(244, 67, 54, 0.2)',
    borderWidth: 1,
    borderColor: '#F44336',
  },
  connectButtonText: {
    fontSize: 12,
    fontWeight: 'bold',
  },
  connectButtonTextPrimary: {
    color: '#fff',
  },
  disconnectButtonText: {
    color: '#F44336',
  },
});

export default ProfileScreen;
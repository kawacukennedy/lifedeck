import React, {useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Alert,
} from 'react-native';
import {useDispatch} from 'react-redux';
import {setUser} from '../store/slices/userSlice';
import {api} from '../services/api';

const OnboardingScreen = ({navigation}: any) => {
  const [currentStep, setCurrentStep] = useState(0);
  const [selectedDomains, setSelectedDomains] = useState<string[]>([]);
  const [userName, setUserName] = useState('');
  const [loading, setLoading] = useState(false);
  const dispatch = useDispatch();

  const domains = [
    {id: 'HEALTH', name: 'Health', icon: '🏃', description: 'Physical wellness'},
    {id: 'FINANCE', name: 'Finance', icon: '💰', description: 'Money management'},
    {id: 'PRODUCTIVITY', name: 'Productivity', icon: '⚡', description: 'Getting things done'},
    {id: 'MINDFULNESS', name: 'Mindfulness', icon: '🧘', description: 'Mental wellness'},
  ];

  const steps = [
    {
      title: 'Welcome to LifeDeck',
      subtitle: 'Your AI-powered life coach',
      content: (
        <View style={styles.welcomeContent}>
          <View style={styles.logoContainer}>
            <Text style={styles.logo}>🃏</Text>
          </View>
          <Text style={styles.welcomeText}>
            Small daily steps. Big life change.
          </Text>
        </View>
      ),
    },
    {
      title: 'Choose Your Focus Areas',
      subtitle: 'Select domains to improve',
      content: (
        <View style={styles.domainsContent}>
          {domains.map(domain => (
            <TouchableOpacity
              key={domain.id}
              style={[
                styles.domainCard,
                selectedDomains.includes(domain.id) && styles.domainCardSelected,
              ]}
              onPress={() => {
                setSelectedDomains(prev =>
                  prev.includes(domain.id)
                    ? prev.filter(d => d !== domain.id)
                    : [...prev, domain.id]
                );
              }}>
              <Text style={styles.domainIcon}>{domain.icon}</Text>
              <Text style={styles.domainName}>{domain.name}</Text>
              <Text style={styles.domainDesc}>{domain.description}</Text>
            </TouchableOpacity>
          ))}
        </View>
      ),
    },
    {
      title: 'Personalize Your Experience',
      subtitle: 'Tell us a bit about yourself',
      content: (
        <View style={styles.personalizationContent}>
          <Text style={styles.inputLabel}>What should we call you?</Text>
          <TextInput
            style={styles.textInput}
            value={userName}
            onChangeText={setUserName}
            placeholder="Enter your name"
            placeholderTextColor="#666"
          />
        </View>
      ),
    },
    {
      title: 'Ready to Begin!',
      subtitle: 'Your personalized deck awaits',
      content: (
        <View style={styles.readyContent}>
          <Text style={styles.readyText}>
            🎉 Your LifeDeck is ready! Let's start building better habits together.
          </Text>
        </View>
      ),
    },
  ];

  const handleNext = async () => {
    if (currentStep === 1 && selectedDomains.length === 0) {
      Alert.alert('Please select at least one domain');
      return;
    }

    if (currentStep === steps.length - 1) {
      await completeOnboarding();
    } else {
      setCurrentStep(currentStep + 1);
    }
  };

  const handleBack = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    }
  };

  const completeOnboarding = async () => {
    setLoading(true);
    try {
      // Set goals
      await api.post('/users/onboarding/goals', {
        goals: selectedDomains.map(domain => ({
          domain,
          description: `Improve my ${domain.toLowerCase()}`,
          targetValue: 100,
          currentValue: 0,
        })),
      });

      // Set preferences
      await api.post('/users/onboarding/preferences', {
        domains: selectedDomains,
        maxDailyCards: 5,
      });

      // Complete onboarding
      await api.post('/users/onboarding/complete');

      // Update local user state
      dispatch(setUser({
        name: userName,
        hasCompletedOnboarding: true,
        goals: selectedDomains.map(domain => ({
          domain,
          description: `Improve my ${domain.toLowerCase()}`,
          targetValue: 100,
          currentValue: 0,
        })),
      }));

      navigation.replace('Main');
    } catch (error) {
      Alert.alert('Error', 'Failed to complete onboarding. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const currentStepData = steps[currentStep];

  return (
    <View style={styles.container}>
      {/* Progress Bar */}
      <View style={styles.progressContainer}>
        {steps.map((_, index) => (
          <View
            key={index}
            style={[
              styles.progressBar,
              index <= currentStep && styles.progressBarActive,
            ]}
          />
        ))}
      </View>

      {/* Content */}
      <ScrollView style={styles.contentContainer} showsVerticalScrollIndicator={false}>
        <View style={styles.stepContainer}>
          <Text style={styles.stepTitle}>{currentStepData.title}</Text>
          <Text style={styles.stepSubtitle}>{currentStepData.subtitle}</Text>
          {currentStepData.content}
        </View>
      </ScrollView>

      {/* Navigation */}
      <View style={styles.navigationContainer}>
        {currentStep > 0 && (
          <TouchableOpacity style={styles.backButton} onPress={handleBack}>
            <Text style={styles.backButtonText}>Back</Text>
          </TouchableOpacity>
        )}

        <TouchableOpacity
          style={[
            styles.nextButton,
            currentStep === 1 && selectedDomains.length === 0 && styles.nextButtonDisabled,
          ]}
          onPress={handleNext}
          disabled={currentStep === 1 && selectedDomains.length === 0}>
          <Text style={styles.nextButtonText}>
            {loading ? 'Setting up...' : currentStep === steps.length - 1 ? 'Get Started' : 'Continue'}
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#121212',
  },
  progressContainer: {
    flexDirection: 'row',
    paddingHorizontal: 20,
    paddingTop: 20,
    paddingBottom: 10,
  },
  progressBar: {
    flex: 1,
    height: 4,
    backgroundColor: '#333',
    borderRadius: 2,
    marginHorizontal: 2,
  },
  progressBarActive: {
    backgroundColor: '#2196F3',
  },
  contentContainer: {
    flex: 1,
    paddingHorizontal: 20,
  },
  stepContainer: {
    flex: 1,
    justifyContent: 'center',
    minHeight: 400,
  },
  stepTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#fff',
    textAlign: 'center',
    marginBottom: 8,
  },
  stepSubtitle: {
    fontSize: 16,
    color: '#888',
    textAlign: 'center',
    marginBottom: 40,
  },
  welcomeContent: {
    alignItems: 'center',
  },
  logoContainer: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: 'rgba(33, 150, 243, 0.1)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 40,
  },
  logo: {
    fontSize: 60,
  },
  welcomeText: {
    fontSize: 18,
    color: '#ccc',
    textAlign: 'center',
  },
  domainsContent: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  domainCard: {
    width: '48%',
    backgroundColor: '#1e1e1e',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#333',
    alignItems: 'center',
  },
  domainCardSelected: {
    borderColor: '#2196F3',
    backgroundColor: 'rgba(33, 150, 243, 0.1)',
  },
  domainIcon: {
    fontSize: 32,
    marginBottom: 8,
  },
  domainName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 4,
  },
  domainDesc: {
    fontSize: 12,
    color: '#888',
    textAlign: 'center',
  },
  personalizationContent: {
    paddingHorizontal: 20,
  },
  inputLabel: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 12,
  },
  textInput: {
    backgroundColor: '#1e1e1e',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#333',
    padding: 16,
    fontSize: 16,
    color: '#fff',
  },
  readyContent: {
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  readyText: {
    fontSize: 18,
    color: '#ccc',
    textAlign: 'center',
    lineHeight: 24,
  },
  navigationContainer: {
    flexDirection: 'row',
    padding: 20,
    justifyContent: 'space-between',
  },
  backButton: {
    paddingVertical: 12,
    paddingHorizontal: 24,
  },
  backButtonText: {
    fontSize: 16,
    color: '#888',
  },
  nextButton: {
    backgroundColor: '#2196F3',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
    minWidth: 120,
    alignItems: 'center',
  },
  nextButtonDisabled: {
    backgroundColor: '#333',
  },
  nextButtonText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#fff',
  },
});

export default OnboardingScreen;
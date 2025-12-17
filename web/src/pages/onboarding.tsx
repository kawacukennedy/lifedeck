import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import { useStore } from '../store/useStore';
import { apiService } from '../lib/api';
import Layout from '../components/Layout';
import { motion, AnimatePresence } from 'framer-motion';
import {
  User,
  Target,
  Heart,
  DollarSign,
  Clock,
  Leaf,
  Check,
  ArrowRight,
  ArrowLeft,
} from 'lucide-react';

interface OnboardingStep {
  id: string;
  title: string;
  description: string;
  component: React.ComponentType<any>;
}

const lifeDomains = [
  { id: 'health', name: 'Health', icon: Heart, color: 'text-red-400', description: 'Physical wellness and fitness' },
  { id: 'finance', name: 'Finance', icon: DollarSign, color: 'text-green-400', description: 'Money management and wealth' },
  { id: 'productivity', name: 'Productivity', icon: Clock, color: 'text-blue-400', description: 'Time management and efficiency' },
  { id: 'mindfulness', name: 'Mindfulness', icon: Leaf, color: 'text-purple-400', description: 'Mental wellness and presence' },
];

const WelcomeStep = ({ onNext }: { onNext: () => void }) => (
  <motion.div
    initial={{ opacity: 0, y: 20 }}
    animate={{ opacity: 1, y: 0 }}
    className="text-center max-w-2xl mx-auto"
  >
    <div className="w-20 h-20 bg-lifedeck-primary rounded-full flex items-center justify-center mx-auto mb-8">
      <User className="w-10 h-10 text-white" />
    </div>
    <h1 className="text-4xl font-bold text-lifedeck-text mb-4">
      Welcome to LifeDeck! 🎉
    </h1>
    <p className="text-xl text-lifedeck-textSecondary mb-8">
      Let's personalize your experience to help you achieve your life optimization goals.
      This will only take a few minutes.
    </p>
    <button
      onClick={onNext}
      className="bg-lifedeck-primary hover:bg-lifedeck-primary/80 text-white font-semibold py-4 px-8 rounded-lg transition-colors duration-200 flex items-center space-x-2 mx-auto"
    >
      <span>Get Started</span>
      <ArrowRight className="w-5 h-5" />
    </button>
  </motion.div>
);

const ProfileStep = ({ onNext, onPrev }: { onNext: (data: any) => void; onPrev: () => void }) => {
  const [formData, setFormData] = useState({
    name: '',
    goals: '',
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onNext(formData);
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="max-w-2xl mx-auto"
    >
      <div className="text-center mb-8">
        <h2 className="text-3xl font-bold text-lifedeck-text mb-4">
          Tell us about yourself
        </h2>
        <p className="text-lifedeck-textSecondary">
          This helps us personalize your coaching experience
        </p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div>
          <label className="block text-sm font-medium text-lifedeck-text mb-2">
            What's your name?
          </label>
          <input
            type="text"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            className="w-full px-4 py-3 bg-lifedeck-background border border-lifedeck-border rounded-lg focus:outline-none focus:ring-2 focus:ring-lifedeck-primary text-lifedeck-text"
            placeholder="Enter your name"
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-lifedeck-text mb-2">
            What are your main goals? (Optional)
          </label>
          <textarea
            value={formData.goals}
            onChange={(e) => setFormData({ ...formData, goals: e.target.value })}
            className="w-full px-4 py-3 bg-lifedeck-background border border-lifedeck-border rounded-lg focus:outline-none focus:ring-2 focus:ring-lifedeck-primary text-lifedeck-text h-32 resize-none"
            placeholder="e.g., Get in shape, save money, be more productive..."
          />
        </div>

        <div className="flex space-x-4">
          <button
            type="button"
            onClick={onPrev}
            className="flex-1 bg-lifedeck-background hover:bg-lifedeck-border text-lifedeck-text font-medium py-3 px-6 rounded-lg transition-colors duration-200 flex items-center justify-center space-x-2"
          >
            <ArrowLeft className="w-4 h-4" />
            <span>Back</span>
          </button>
          <button
            type="submit"
            className="flex-1 bg-lifedeck-primary hover:bg-lifedeck-primary/80 text-white font-semibold py-3 px-6 rounded-lg transition-colors duration-200 flex items-center justify-center space-x-2"
          >
            <span>Continue</span>
            <ArrowRight className="w-4 h-4" />
          </button>
        </div>
      </form>
    </motion.div>
  );
};

const DomainsStep = ({ onNext, onPrev }: { onNext: (data: any) => void; onPrev: () => void }) => {
  const [selectedDomains, setSelectedDomains] = useState<string[]>([]);

  const toggleDomain = (domainId: string) => {
    setSelectedDomains(prev =>
      prev.includes(domainId)
        ? prev.filter(id => id !== domainId)
        : [...prev, domainId]
    );
  };

  const handleSubmit = () => {
    if (selectedDomains.length === 0) return;
    onNext({ preferredDomains: selectedDomains });
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="max-w-4xl mx-auto"
    >
      <div className="text-center mb-8">
        <h2 className="text-3xl font-bold text-lifedeck-text mb-4">
          Which areas interest you most?
        </h2>
        <p className="text-lifedeck-textSecondary">
          Select the life domains you'd like to focus on. You can change this later.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        {lifeDomains.map((domain) => {
          const Icon = domain.icon;
          const isSelected = selectedDomains.includes(domain.id);

          return (
            <motion.button
              key={domain.id}
              onClick={() => toggleDomain(domain.id)}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className={`p-6 rounded-xl border-2 transition-all duration-200 text-left ${
                isSelected
                  ? 'border-lifedeck-primary bg-lifedeck-primary/5'
                  : 'border-lifedeck-border bg-lifedeck-surface hover:border-lifedeck-primary/50'
              }`}
            >
              <div className="flex items-start space-x-4">
                <div className={`p-3 rounded-lg ${isSelected ? 'bg-lifedeck-primary/20' : 'bg-lifedeck-background'}`}>
                  <Icon className={`w-6 h-6 ${isSelected ? 'text-lifedeck-primary' : domain.color}`} />
                </div>
                <div className="flex-1">
                  <h3 className={`font-semibold mb-1 ${isSelected ? 'text-lifedeck-primary' : 'text-lifedeck-text'}`}>
                    {domain.name}
                  </h3>
                  <p className="text-sm text-lifedeck-textSecondary mb-3">
                    {domain.description}
                  </p>
                  {isSelected && (
                    <div className="flex items-center space-x-1">
                      <Check className="w-4 h-4 text-lifedeck-primary" />
                      <span className="text-sm text-lifedeck-primary font-medium">Selected</span>
                    </div>
                  )}
                </div>
              </div>
            </motion.button>
          );
        })}
      </div>

      <div className="flex space-x-4">
        <button
          onClick={onPrev}
          className="flex-1 bg-lifedeck-background hover:bg-lifedeck-border text-lifedeck-text font-medium py-3 px-6 rounded-lg transition-colors duration-200 flex items-center justify-center space-x-2"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Back</span>
        </button>
        <button
          onClick={handleSubmit}
          disabled={selectedDomains.length === 0}
          className={`flex-1 font-semibold py-3 px-6 rounded-lg transition-colors duration-200 flex items-center justify-center space-x-2 ${
            selectedDomains.length === 0
              ? 'bg-gray-500 text-gray-300 cursor-not-allowed'
              : 'bg-lifedeck-primary hover:bg-lifedeck-primary/80 text-white'
          }`}
        >
          <span>Continue</span>
          <ArrowRight className="w-4 h-4" />
        </button>
      </div>
    </motion.div>
  );
};

const GoalsStep = ({ onNext, onPrev }: { onNext: (data: any) => void; onPrev: () => void }) => {
  const [goals, setGoals] = useState([
    { domain: 'health', target: '', unit: 'hours/week' },
    { domain: 'finance', target: '', unit: '$/month' },
    { domain: 'productivity', target: '', unit: 'hours/day' },
    { domain: 'mindfulness', target: '', unit: 'minutes/day' },
  ]);

  const handleGoalChange = (domain: string, target: string) => {
    setGoals(prev =>
      prev.map(goal =>
        goal.domain === domain ? { ...goal, target } : goal
      )
    );
  };

  const handleSubmit = () => {
    const goalsData = goals.filter(goal => goal.target.trim() !== '');
    onNext({ goals: goalsData });
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="max-w-2xl mx-auto"
    >
      <div className="text-center mb-8">
        <h2 className="text-3xl font-bold text-lifedeck-text mb-4">
          Set some initial goals
        </h2>
        <p className="text-lifedeck-textSecondary">
          These will help us track your progress. You can always adjust them later.
        </p>
      </div>

      <div className="space-y-4 mb-8">
        {goals.map((goal) => {
          const domainInfo = lifeDomains.find(d => d.id === goal.domain);
          const Icon = domainInfo?.icon || Target;

          return (
            <div key={goal.domain} className="flex items-center space-x-4 p-4 bg-lifedeck-surface rounded-lg border border-lifedeck-border">
              <div className={`p-2 rounded-lg bg-lifedeck-background ${domainInfo?.color}`}>
                <Icon className="w-5 h-5" />
              </div>
              <div className="flex-1">
                <label className="block text-sm font-medium text-lifedeck-text mb-1 capitalize">
                  {goal.domain} Goal
                </label>
                <div className="flex items-center space-x-2">
                  <input
                    type="text"
                    value={goal.target}
                    onChange={(e) => handleGoalChange(goal.domain, e.target.value)}
                    className="flex-1 px-3 py-2 bg-lifedeck-background border border-lifedeck-border rounded focus:outline-none focus:ring-2 focus:ring-lifedeck-primary text-lifedeck-text"
                    placeholder={`e.g., 5 ${goal.unit}`}
                  />
                  <span className="text-lifedeck-textSecondary text-sm">{goal.unit}</span>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      <div className="text-center mb-6">
        <p className="text-sm text-lifedeck-textSecondary">
          💡 Tip: Start with achievable goals. You can always increase them as you progress!
        </p>
      </div>

      <div className="flex space-x-4">
        <button
          onClick={onPrev}
          className="flex-1 bg-lifedeck-background hover:bg-lifedeck-border text-lifedeck-text font-medium py-3 px-6 rounded-lg transition-colors duration-200 flex items-center justify-center space-x-2"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Back</span>
        </button>
        <button
          onClick={handleSubmit}
          className="flex-1 bg-lifedeck-primary hover:bg-lifedeck-primary/80 text-white font-semibold py-3 px-6 rounded-lg transition-colors duration-200 flex items-center justify-center space-x-2"
        >
          <span>Complete Setup</span>
          <Check className="w-4 h-4" />
        </button>
      </div>
    </motion.div>
  );
};

const CompletionStep = ({ onComplete }: { onComplete: () => void }) => (
  <motion.div
    initial={{ opacity: 0, y: 20 }}
    animate={{ opacity: 1, y: 0 }}
    className="text-center max-w-2xl mx-auto"
  >
    <div className="w-20 h-20 bg-green-500 rounded-full flex items-center justify-center mx-auto mb-8">
      <Check className="w-10 h-10 text-white" />
    </div>
    <h1 className="text-4xl font-bold text-lifedeck-text mb-4">
      You're all set! 🎉
    </h1>
    <p className="text-xl text-lifedeck-textSecondary mb-8">
      Your personalized LifeDeck experience is ready. Let's start your journey toward a better life!
    </p>
    <button
      onClick={onComplete}
      className="bg-lifedeck-primary hover:bg-lifedeck-primary/80 text-white font-semibold py-4 px-8 rounded-lg transition-colors duration-200"
    >
      Start My Journey
    </button>
  </motion.div>
);

const steps: OnboardingStep[] = [
  { id: 'welcome', title: 'Welcome', description: 'Get started', component: WelcomeStep },
  { id: 'profile', title: 'Profile', description: 'Tell us about yourself', component: ProfileStep },
  { id: 'domains', title: 'Domains', description: 'Choose focus areas', component: DomainsStep },
  { id: 'goals', title: 'Goals', description: 'Set initial targets', component: GoalsStep },
  { id: 'complete', title: 'Complete', description: 'Ready to start', component: CompletionStep },
];

export default function OnboardingPage() {
  const router = useRouter();
  const { user, setUser } = useStore();
  const [currentStep, setCurrentStep] = useState(0);
  const [onboardingData, setOnboardingData] = useState<any>({});

  useEffect(() => {
    // Redirect if already completed onboarding
    if (user?.hasCompletedOnboarding) {
      router.push('/');
    }
  }, [user, router]);

  const handleStepComplete = (stepData: any) => {
    setOnboardingData({ ...onboardingData, ...stepData });
    if (currentStep < steps.length - 1) {
      setCurrentStep(currentStep + 1);
    }
  };

  const handleStepBack = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    }
  };

  const handleOnboardingComplete = async () => {
    try {
      // Update user profile with onboarding data
      await apiService.updateProfile({
        name: onboardingData.name,
        goals: onboardingData.goals,
        preferredDomains: onboardingData.preferredDomains,
        hasCompletedOnboarding: true,
      });

      // Update local user state
      setUser({
        ...user!,
        name: onboardingData.name,
        hasCompletedOnboarding: true,
      });

      // Redirect to main app
      router.push('/');
    } catch (error) {
      console.error('Failed to complete onboarding:', error);
    }
  };

  const CurrentStepComponent = steps[currentStep].component;

  return (
    <Layout>
      <div className="min-h-screen flex items-center justify-center p-6">
        <div className="w-full max-w-4xl">
          {/* Progress Indicator */}
          <div className="mb-8">
            <div className="flex items-center justify-center space-x-2 mb-4">
              {steps.map((step, index) => (
                <div
                  key={step.id}
                  className={`w-3 h-3 rounded-full transition-colors ${
                    index <= currentStep ? 'bg-lifedeck-primary' : 'bg-lifedeck-border'
                  }`}
                />
              ))}
            </div>
            <div className="text-center">
              <h2 className="text-lg font-semibold text-lifedeck-text">
                Step {currentStep + 1} of {steps.length}
              </h2>
              <p className="text-lifedeck-textSecondary">
                {steps[currentStep].description}
              </p>
            </div>
          </div>

          {/* Step Content */}
          <AnimatePresence mode="wait">
            <motion.div
              key={currentStep}
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              transition={{ duration: 0.3 }}
            >
              {currentStep === 0 && (
                <WelcomeStep onNext={() => handleStepComplete({})} />
              )}
              {currentStep === 1 && (
                <ProfileStep
                  onNext={handleStepComplete}
                  onPrev={handleStepBack}
                />
              )}
              {currentStep === 2 && (
                <DomainsStep
                  onNext={handleStepComplete}
                  onPrev={handleStepBack}
                />
              )}
              {currentStep === 3 && (
                <GoalsStep
                  onNext={handleStepComplete}
                  onPrev={handleStepBack}
                />
              )}
              {currentStep === 4 && (
                <CompletionStep onComplete={handleOnboardingComplete} />
              )}
            </motion.div>
          </AnimatePresence>
        </div>
      </div>
    </Layout>
  );
}
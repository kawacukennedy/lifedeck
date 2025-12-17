import { useEffect, useState } from 'react';
import { useStore } from '../store/useStore';
import { apiService } from '../lib/api';
import Layout from '../components/Layout';
import StripePaymentForm from '../components/StripePaymentForm';
import { motion } from 'framer-motion';
import { loadStripe } from '@stripe/stripe-js';
import { Elements } from '@stripe/react-stripe-js';
import {
  Crown,
  Check,
  Star,
  Zap,
  BarChart3,
  Download,
  Headphones,
  Target,
  Shield,
  Sparkles,
  X,
} from 'lucide-react';

interface SubscriptionPlan {
  id: string;
  name: string;
  price: number;
  interval: 'month' | 'year';
  description: string;
  features: string[];
  popular?: boolean;
}

const plans: SubscriptionPlan[] = [
  {
    id: 'monthly',
    name: 'Monthly',
    price: 9.99,
    interval: 'month',
    description: 'Perfect for trying LifeDeck Premium',
    features: [
      'Unlimited daily coaching cards',
      'Advanced analytics dashboard',
      'Priority customer support',
      'Export your data',
      'Custom goal tracking',
      'Streak protection',
      'AI-powered insights',
    ],
  },
  {
    id: 'yearly',
    name: 'Yearly',
    price: 79.99,
    interval: 'year',
    description: 'Best value for committed life optimizers',
    features: [
      'Everything in Monthly',
      '2 months free ($20 savings)',
      'Early access to new features',
      'Personalized coaching sessions',
      'Advanced AI recommendations',
      'Custom integrations',
    ],
    popular: true,
  },
];

const premiumFeatures = [
  {
    icon: Zap,
    title: 'Unlimited Cards',
    description: 'Get unlimited AI-generated coaching cards instead of the free tier limit of 3 per day.',
  },
  {
    icon: BarChart3,
    title: 'Advanced Analytics',
    description: 'Deep insights into your progress with detailed charts, trends, and personalized recommendations.',
  },
  {
    icon: Sparkles,
    title: 'AI-Powered Insights',
    description: 'Receive personalized insights and recommendations based on your unique patterns and goals.',
  },
  {
    icon: Target,
    title: 'Custom Goals',
    description: 'Set and track unlimited custom goals across all life domains with advanced progress tracking.',
  },
  {
    icon: Shield,
    title: 'Streak Protection',
    description: 'Never lose your streak due to unexpected life events with our flexible protection system.',
  },
  {
    icon: Download,
    title: 'Data Export',
    description: 'Export all your data for backup, analysis, or migration to other platforms.',
  },
  {
    icon: Headphones,
    title: 'Priority Support',
    description: 'Get faster response times and direct access to our life optimization experts.',
  },
  {
    icon: Star,
    title: 'Early Access',
    description: 'Be the first to try new features and provide feedback on upcoming improvements.',
  },
];

// Initialize Stripe
const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY || '');

export default function PremiumPage() {
  const { user } = useStore();
  const [loading, setLoading] = useState(false);
  const [subscription, setSubscription] = useState<any>(null);
  const [showPaymentModal, setShowPaymentModal] = useState(false);
  const [selectedPlan, setSelectedPlan] = useState<SubscriptionPlan | null>(null);
  const [paymentError, setPaymentError] = useState<string | null>(null);
  const [stripeProducts, setStripeProducts] = useState<any>(null);
  const [showSuccessMessage, setShowSuccessMessage] = useState(false);

  useEffect(() => {
    loadSubscriptionStatus();
  }, []);

  const loadSubscriptionStatus = async () => {
    try {
      const [subscriptionResponse, productsResponse] = await Promise.all([
        apiService.getSubscriptionStatus(),
        apiService.getStripeProducts(),
      ]);
      setSubscription(subscriptionResponse);
      setStripeProducts(productsResponse.products);
    } catch (error) {
      console.error('Failed to load subscription data:', error);
    }
  };

  const handleSubscribe = (plan: SubscriptionPlan) => {
    if (isPremium) return;
    setSelectedPlan(plan);
    setShowPaymentModal(true);
    setPaymentError(null);
  };

  const handlePaymentSuccess = async (stripeSubscription: any) => {
    setShowPaymentModal(false);
    setSelectedPlan(null);
    // Reload subscription status to reflect the new premium status
    await loadSubscriptionStatus();
    // Show success message
    setShowSuccessMessage(true);
    // Hide success message after 5 seconds
    setTimeout(() => setShowSuccessMessage(false), 5000);
  };

  const handlePaymentError = (error: string) => {
    setPaymentError(error);
  };

  const isPremium = user?.subscriptionTier === 'premium' || subscription?.tier === 'PREMIUM';

  return (
    <Layout>
      <div className="max-w-7xl mx-auto">
        {/* Hero Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-16"
        >
          <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-yellow-400 to-orange-500 rounded-full mb-6">
            <Crown className="w-8 h-8 text-white" />
          </div>
          <h1 className="text-4xl font-bold text-lifedeck-text mb-4">
            Unlock Your Full Potential
          </h1>
          <p className="text-xl text-lifedeck-textSecondary max-w-3xl mx-auto">
            Take your life optimization journey to the next level with LifeDeck Premium.
            Get unlimited access to AI-powered coaching, advanced analytics, and exclusive features.
          </p>
        </motion.div>

        {/* Success Message */}
        {showSuccessMessage && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="bg-gradient-to-r from-green-500/10 to-emerald-500/10 border border-green-500/20 rounded-xl p-6 mb-12"
          >
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-green-500 rounded-full flex items-center justify-center">
                <Check className="w-6 h-6 text-white" />
              </div>
              <div>
                <h3 className="text-lg font-semibold text-green-400">Welcome to LifeDeck Premium!</h3>
                <p className="text-lifedeck-textSecondary">
                  Your subscription has been activated. Enjoy all premium features!
                </p>
              </div>
            </div>
          </motion.div>
        )}

        {/* Current Status */}
        {isPremium && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-gradient-to-r from-green-500/10 to-emerald-500/10 border border-green-500/20 rounded-xl p-6 mb-12"
          >
            <div className="flex items-center space-x-3 mb-4">
              <div className="w-10 h-10 bg-green-500 rounded-full flex items-center justify-center">
                <Check className="w-6 h-6 text-white" />
              </div>
              <div>
                <h3 className="text-lg font-semibold text-green-400">Premium Member</h3>
                <p className="text-lifedeck-textSecondary">
                  You're enjoying all premium features!
                </p>
              </div>
            </div>
            {subscription && (
              <div className="text-sm text-lifedeck-textSecondary">
                {subscription.status === 'ACTIVE' && subscription.expiryDate && (
                  <p>Renews on {new Date(subscription.expiryDate).toLocaleDateString()}</p>
                )}
              </div>
            )}
          </motion.div>
        )}

        {/* Pricing Plans */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-16 max-w-4xl mx-auto"
        >
          {plans.map((plan) => (
            <div
              key={plan.id}
              className={`relative bg-lifedeck-surface rounded-xl border p-8 ${
                plan.popular
                  ? 'border-lifedeck-primary shadow-lg'
                  : 'border-lifedeck-border'
              }`}
            >
              {plan.popular && (
                <div className="absolute -top-3 left-1/2 transform -translate-x-1/2">
                  <div className="bg-lifedeck-primary text-white px-4 py-1 rounded-full text-sm font-medium">
                    Most Popular
                  </div>
                </div>
              )}

              <div className="text-center mb-6">
                <h3 className="text-2xl font-bold text-lifedeck-text mb-2">
                  {plan.name}
                </h3>
                <div className="mb-4">
                  <span className="text-4xl font-bold text-lifedeck-primary">
                    ${plan.price}
                  </span>
                  <span className="text-lifedeck-textSecondary">
                    /{plan.interval}
                  </span>
                </div>
                <p className="text-lifedeck-textSecondary">{plan.description}</p>
              </div>

              <ul className="space-y-3 mb-8">
                {plan.features.map((feature, index) => (
                  <li key={index} className="flex items-center space-x-3">
                    <Check className="w-5 h-5 text-green-400 flex-shrink-0" />
                    <span className="text-lifedeck-textSecondary">{feature}</span>
                  </li>
                ))}
              </ul>

               <button
                 onClick={() => handleSubscribe(plan)}
                 disabled={loading || isPremium}
                 className={`w-full py-3 px-6 rounded-lg font-semibold transition-colors ${
                   isPremium
                     ? 'bg-gray-500 text-gray-300 cursor-not-allowed'
                     : plan.popular
                     ? 'bg-lifedeck-primary hover:bg-lifedeck-primary/80 text-white'
                     : 'bg-lifedeck-background hover:bg-lifedeck-border text-lifedeck-text'
                 }`}
               >
                 {isPremium ? 'Current Plan' : loading ? 'Processing...' : 'Subscribe Now'}
               </button>
            </div>
          ))}
        </motion.div>

        {/* Features Grid */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="mb-16"
        >
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-lifedeck-text mb-4">
              Why Go Premium?
            </h2>
            <p className="text-lifedeck-textSecondary max-w-2xl mx-auto">
              Unlock the full potential of LifeDeck with features designed to accelerate your personal growth journey.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {premiumFeatures.map((feature, index) => (
              <motion.div
                key={feature.title}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 * index }}
                className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border hover:border-lifedeck-primary/50 transition-colors"
              >
                <div className="w-12 h-12 bg-lifedeck-primary/10 rounded-lg flex items-center justify-center mb-4">
                  <feature.icon className="w-6 h-6 text-lifedeck-primary" />
                </div>
                <h3 className="text-lg font-semibold text-lifedeck-text mb-2">
                  {feature.title}
                </h3>
                <p className="text-lifedeck-textSecondary text-sm">
                  {feature.description}
                </p>
              </motion.div>
            ))}
          </div>
        </motion.div>

        {/* FAQ Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="bg-lifedeck-surface rounded-xl p-8 border border-lifedeck-border"
        >
          <h2 className="text-2xl font-bold text-lifedeck-text mb-6 text-center">
            Frequently Asked Questions
          </h2>
          <div className="space-y-6 max-w-3xl mx-auto">
            <div>
              <h3 className="text-lg font-semibold text-lifedeck-text mb-2">
                Can I cancel anytime?
              </h3>
              <p className="text-lifedeck-textSecondary">
                Yes, you can cancel your subscription at any time. You'll continue to have access to premium features until the end of your billing period.
              </p>
            </div>
            <div>
              <h3 className="text-lg font-semibold text-lifedeck-text mb-2">
                What happens to my data if I cancel?
              </h3>
              <p className="text-lifedeck-textSecondary">
                Your data is always yours. You can export all your data before canceling, and you'll retain access to your basic account and any free-tier features.
              </p>
            </div>
            <div>
              <h3 className="text-lg font-semibold text-lifedeck-text mb-2">
                Is there a free trial?
              </h3>
              <p className="text-lifedeck-textSecondary">
                We offer a 7-day free trial for new premium subscribers. No credit card required to start your trial.
              </p>
            </div>
            <div>
              <h3 className="text-lg font-semibold text-lifedeck-text mb-2">
                Do you offer refunds?
              </h3>
              <p className="text-lifedeck-textSecondary">
                We offer a 30-day money-back guarantee. If you're not satisfied with Premium, contact our support team for a full refund.
              </p>
            </div>
          </div>
        </motion.div>

        {/* Payment Modal */}
        {showPaymentModal && selectedPlan && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="bg-lifedeck-surface rounded-xl max-w-md w-full p-6 border border-lifedeck-border"
            >
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-lifedeck-text">
                  Subscribe to {selectedPlan.name}
                </h3>
                <button
                  onClick={() => setShowPaymentModal(false)}
                  className="text-lifedeck-textSecondary hover:text-lifedeck-text"
                >
                  <X className="w-6 h-6" />
                </button>
              </div>

              <div className="mb-6">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-lifedeck-textSecondary">Plan</span>
                  <span className="font-semibold text-lifedeck-text">{selectedPlan.name}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-lifedeck-textSecondary">Price</span>
                  <span className="font-semibold text-lifedeck-text">
                    ${selectedPlan.price}/{selectedPlan.interval}
                  </span>
                </div>
              </div>

              {paymentError && (
                <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
                  <p className="text-red-600 text-sm">{paymentError}</p>
                </div>
              )}

              <Elements stripe={stripePromise}>
                <StripePaymentForm
                  priceId={stripeProducts?.[selectedPlan.id]?.id || ''}
                  onSuccess={handlePaymentSuccess}
                  onError={handlePaymentError}
                />
              </Elements>
            </motion.div>
          </div>
        )}
      </div>
    </Layout>
  );
}
import React, { useState } from 'react';
import Layout from '../components/Layout';
import { motion } from 'framer-motion';
import {
  HelpCircle,
  Book,
  MessageCircle,
  ChevronDown,
  ChevronRight,
  Play,
  FileText,
  Users,
  Target,
} from 'lucide-react';

interface FAQ {
  question: string;
  answer: string;
}

interface Tutorial {
  title: string;
  description: string;
  duration: string;
  videoId?: string;
  steps?: string[];
}

const HelpPage = () => {
  const [expandedFAQ, setExpandedFAQ] = useState<number | null>(null);

  const faqs: FAQ[] = [
    {
      question: "What is LifeDeck?",
      answer: "LifeDeck is an AI-powered life optimization platform that provides personalized coaching cards to help you build better habits across four key life domains: Health, Finance, Productivity, and Mindfulness."
    },
    {
      question: "How do coaching cards work?",
      answer: "Each day, LifeDeck generates personalized coaching cards based on your progress and goals. Cards contain specific, actionable steps that take 5-15 minutes to complete. Swipe right to complete, left to dismiss, or tap the snooze button to save for later."
    },
    {
      question: "What's the difference between free and premium?",
      answer: "Free users receive up to 3 coaching cards per day. Premium users get unlimited cards, advanced analytics, priority AI personalization, and access to exclusive content."
    },
    {
      question: "How does LifeDeck personalize cards?",
      answer: "Our AI analyzes your activity patterns, progress scores, and preferences to create cards that match your current needs and goals. The more you use LifeDeck, the better it gets at understanding what motivates you."
    },
    {
      question: "Can I track my progress?",
      answer: "Yes! LifeDeck provides comprehensive analytics including life scores, domain-specific progress, streaks, achievements, and trend analysis to help you see your improvement over time."
    },
    {
      question: "Is my data secure?",
      answer: "Absolutely. We use industry-standard encryption, secure authentication, and never share your personal data with third parties. Your privacy and data security are our top priorities."
    }
  ];

  const tutorials: Tutorial[] = [
    {
      title: "Getting Started with LifeDeck",
      description: "Learn the basics of using LifeDeck and setting up your profile",
      duration: "3 min",
      steps: [
        "Create your account and complete onboarding",
        "Set your goals and preferences",
        "Explore your first coaching cards",
        "Complete cards and track your progress"
      ]
    },
    {
      title: "Understanding Your Life Score",
      description: "How to interpret your life score and domain progress",
      duration: "4 min",
      steps: [
        "Overview of the four life domains",
        "How scores are calculated",
        "Setting realistic goals",
        "Using analytics to improve"
      ]
    },
    {
      title: "Mastering Card Interactions",
      description: "Tips for getting the most out of your coaching cards",
      duration: "2 min",
      steps: [
        "How to complete, dismiss, and snooze cards",
        "Reading card tips and benefits",
        "When to use different card types",
        "Building consistent habits"
      ]
    },
    {
      title: "Premium Features Guide",
      description: "Unlock the full potential of LifeDeck with premium features",
      duration: "5 min",
      steps: [
        "Unlimited daily cards",
        "Advanced analytics dashboard",
        "Priority AI personalization",
        "Achievement system and rewards"
      ]
    }
  ];

  const toggleFAQ = (index: number) => {
    setExpandedFAQ(expandedFAQ === index ? null : index);
  };

  return (
    <Layout>
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-12"
        >
          <div className="flex items-center justify-center mb-4">
            <HelpCircle className="w-12 h-12 text-lifedeck-primary mr-4" />
            <h1 className="text-4xl font-bold text-lifedeck-text">Help Center</h1>
          </div>
          <p className="text-xl text-lifedeck-textSecondary">
            Everything you need to get the most out of LifeDeck
          </p>
        </motion.div>

        {/* Quick Actions */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12"
        >
          <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border text-center">
            <Book className="w-8 h-8 text-lifedeck-primary mx-auto mb-3" />
            <h3 className="font-semibold text-lifedeck-text mb-2">User Guide</h3>
            <p className="text-sm text-lifedeck-textSecondary mb-4">
              Step-by-step guides to master LifeDeck
            </p>
            <button className="text-lifedeck-primary hover:underline text-sm font-medium">
              View Guide →
            </button>
          </div>

          <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border text-center">
            <MessageCircle className="w-8 h-8 text-lifedeck-primary mx-auto mb-3" />
            <h3 className="font-semibold text-lifedeck-text mb-2">Contact Support</h3>
            <p className="text-sm text-lifedeck-textSecondary mb-4">
              Get help from our support team
            </p>
            <button className="text-lifedeck-primary hover:underline text-sm font-medium">
              Contact Us →
            </button>
          </div>

          <div className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border text-center">
            <Users className="w-8 h-8 text-lifedeck-primary mx-auto mb-3" />
            <h3 className="font-semibold text-lifedeck-text mb-2">Community</h3>
            <p className="text-sm text-lifedeck-textSecondary mb-4">
              Connect with other LifeDeck users
            </p>
            <button className="text-lifedeck-primary hover:underline text-sm font-medium">
              Join Community →
            </button>
          </div>
        </motion.div>

        {/* Video Tutorials */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="mb-12"
        >
          <h2 className="text-2xl font-bold text-lifedeck-text mb-6 flex items-center">
            <Play className="w-6 h-6 mr-3 text-lifedeck-primary" />
            Video Tutorials
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {tutorials.map((tutorial, index) => (
              <div
                key={index}
                className="bg-lifedeck-surface rounded-xl p-6 border border-lifedeck-border"
              >
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <h3 className="font-semibold text-lifedeck-text mb-2">
                      {tutorial.title}
                    </h3>
                    <p className="text-sm text-lifedeck-textSecondary mb-3">
                      {tutorial.description}
                    </p>
                    <div className="flex items-center text-xs text-lifedeck-textTertiary">
                      <Play className="w-4 h-4 mr-1" />
                      {tutorial.duration}
                    </div>
                  </div>
                </div>

                {tutorial.steps && (
                  <div className="space-y-2">
                    {tutorial.steps.map((step, stepIndex) => (
                      <div key={stepIndex} className="flex items-start">
                        <div className="w-5 h-5 rounded-full bg-lifedeck-primary/20 flex items-center justify-center mr-3 mt-0.5">
                          <span className="text-xs font-medium text-lifedeck-primary">
                            {stepIndex + 1}
                          </span>
                        </div>
                        <span className="text-sm text-lifedeck-textSecondary">
                          {step}
                        </span>
                      </div>
                    ))}
                  </div>
                )}

                <button className="mt-4 w-full bg-lifedeck-primary hover:bg-lifedeck-primary/80 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200 flex items-center justify-center">
                  <Play className="w-4 h-4 mr-2" />
                  Watch Tutorial
                </button>
              </div>
            ))}
          </div>
        </motion.div>

        {/* FAQ Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <h2 className="text-2xl font-bold text-lifedeck-text mb-6 flex items-center">
            <FileText className="w-6 h-6 mr-3 text-lifedeck-primary" />
            Frequently Asked Questions
          </h2>

          <div className="space-y-4">
            {faqs.map((faq, index) => (
              <div
                key={index}
                className="bg-lifedeck-surface rounded-xl border border-lifedeck-border overflow-hidden"
              >
                <button
                  onClick={() => toggleFAQ(index)}
                  className="w-full px-6 py-4 text-left flex items-center justify-between hover:bg-lifedeck-background/50 transition-colors duration-200"
                >
                  <span className="font-medium text-lifedeck-text">
                    {faq.question}
                  </span>
                  {expandedFAQ === index ? (
                    <ChevronDown className="w-5 h-5 text-lifedeck-textSecondary" />
                  ) : (
                    <ChevronRight className="w-5 h-5 text-lifedeck-textSecondary" />
                  )}
                </button>

                {expandedFAQ === index && (
                  <motion.div
                    initial={{ height: 0, opacity: 0 }}
                    animate={{ height: 'auto', opacity: 1 }}
                    exit={{ height: 0, opacity: 0 }}
                    className="px-6 pb-4"
                  >
                    <p className="text-lifedeck-textSecondary leading-relaxed">
                      {faq.answer}
                    </p>
                  </motion.div>
                )}
              </div>
            ))}
          </div>
        </motion.div>

        {/* Contact Support */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="mt-12 bg-lifedeck-surface rounded-xl p-8 border border-lifedeck-border text-center"
        >
          <Target className="w-12 h-12 text-lifedeck-primary mx-auto mb-4" />
          <h3 className="text-xl font-bold text-lifedeck-text mb-2">
            Still need help?
          </h3>
          <p className="text-lifedeck-textSecondary mb-6">
            Our support team is here to help you get the most out of LifeDeck
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <button className="bg-lifedeck-primary hover:bg-lifedeck-primary/80 text-white font-medium py-3 px-6 rounded-lg transition-colors duration-200">
              Contact Support
            </button>
            <button className="bg-lifedeck-background hover:bg-lifedeck-border text-lifedeck-text font-medium py-3 px-6 rounded-lg transition-colors duration-200 border border-lifedeck-border">
              View Documentation
            </button>
          </div>
        </motion.div>
      </div>
    </Layout>
  );
};

export default HelpPage;
import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  Linking,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';

interface FAQ {
  question: string;
  answer: string;
}

const HelpScreen = () => {
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

  const toggleFAQ = (index: number) => {
    setExpandedFAQ(expandedFAQ === index ? null : index);
  };

  const openSupportEmail = () => {
    Linking.openURL('mailto:support@lifedeck.app?subject=LifeDeck Support Request');
  };

  const openWebsite = () => {
    Linking.openURL('https://lifedeck.app/help');
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Icon name="help" size={48} color="#2196F3" />
        <Text style={styles.title}>Help Center</Text>
        <Text style={styles.subtitle}>
          Everything you need to get the most out of LifeDeck
        </Text>
      </View>

      {/* Quick Actions */}
      <View style={styles.quickActions}>
        <TouchableOpacity style={styles.actionCard} onPress={openWebsite}>
          <Icon name="book" size={24} color="#2196F3" />
          <Text style={styles.actionTitle}>User Guide</Text>
          <Text style={styles.actionDescription}>
            Step-by-step guides to master LifeDeck
          </Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.actionCard} onPress={openSupportEmail}>
          <Icon name="email" size={24} color="#2196F3" />
          <Text style={styles.actionTitle}>Contact Support</Text>
          <Text style={styles.actionDescription}>
            Get help from our support team
          </Text>
        </TouchableOpacity>
      </View>

      {/* FAQ Section */}
      <View style={styles.faqSection}>
        <Text style={styles.sectionTitle}>Frequently Asked Questions</Text>

        {faqs.map((faq, index) => (
          <View key={index} style={styles.faqItem}>
            <TouchableOpacity
              style={styles.faqQuestion}
              onPress={() => toggleFAQ(index)}
            >
              <Text style={styles.questionText}>{faq.question}</Text>
              <Icon
                name={expandedFAQ === index ? 'expand-less' : 'expand-more'}
                size={24}
                color="#888"
              />
            </TouchableOpacity>

            {expandedFAQ === index && (
              <View style={styles.faqAnswer}>
                <Text style={styles.answerText}>{faq.answer}</Text>
              </View>
            )}
          </View>
        ))}
      </View>

      {/* Contact Support */}
      <View style={styles.contactSection}>
        <Icon name="contact-support" size={32} color="#2196F3" />
        <Text style={styles.contactTitle}>Still need help?</Text>
        <Text style={styles.contactDescription}>
          Our support team is here to help you get the most out of LifeDeck
        </Text>

        <View style={styles.contactButtons}>
          <TouchableOpacity style={styles.primaryButton} onPress={openSupportEmail}>
            <Text style={styles.primaryButtonText}>Contact Support</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.secondaryButton} onPress={openWebsite}>
            <Text style={styles.secondaryButtonText}>View Documentation</Text>
          </TouchableOpacity>
        </View>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#121212',
    padding: 16,
  },
  header: {
    alignItems: 'center',
    marginBottom: 32,
    paddingTop: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#fff',
    marginTop: 16,
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#888',
    textAlign: 'center',
    lineHeight: 24,
  },
  quickActions: {
    flexDirection: 'row',
    marginBottom: 32,
  },
  actionCard: {
    flex: 1,
    backgroundColor: '#1e1e1e',
    borderRadius: 12,
    padding: 16,
    marginHorizontal: 4,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#333',
  },
  actionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#fff',
    marginTop: 8,
    marginBottom: 4,
  },
  actionDescription: {
    fontSize: 12,
    color: '#888',
    textAlign: 'center',
    lineHeight: 16,
  },
  faqSection: {
    marginBottom: 32,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 16,
  },
  faqItem: {
    backgroundColor: '#1e1e1e',
    borderRadius: 12,
    marginBottom: 8,
    borderWidth: 1,
    borderColor: '#333',
    overflow: 'hidden',
  },
  faqQuestion: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
  },
  questionText: {
    fontSize: 16,
    fontWeight: '500',
    color: '#fff',
    flex: 1,
    marginRight: 16,
  },
  faqAnswer: {
    padding: 16,
    paddingTop: 0,
    borderTopWidth: 1,
    borderTopColor: '#333',
  },
  answerText: {
    fontSize: 14,
    color: '#ccc',
    lineHeight: 20,
  },
  contactSection: {
    backgroundColor: '#1e1e1e',
    borderRadius: 12,
    padding: 24,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#333',
  },
  contactTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#fff',
    marginTop: 16,
    marginBottom: 8,
  },
  contactDescription: {
    fontSize: 14,
    color: '#888',
    textAlign: 'center',
    lineHeight: 20,
    marginBottom: 24,
  },
  contactButtons: {
    width: '100%',
  },
  primaryButton: {
    backgroundColor: '#2196F3',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: 12,
  },
  primaryButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  secondaryButton: {
    backgroundColor: 'transparent',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#333',
  },
  secondaryButtonText: {
    color: '#888',
    fontSize: 16,
    fontWeight: '600',
  },
});

export default HelpScreen;
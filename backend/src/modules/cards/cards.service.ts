import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { AiService } from '../ai/ai.service';
import { Card, LifeDomain } from '@prisma/client';

@Injectable()
export class CardsService {
  constructor(
    private prisma: PrismaService,
    private aiService: AiService,
  ) {}

  async findDailyCards(userId: string): Promise<Card[]> {
    // Get user's preferred domains and settings
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { settings: true, progress: true },
    });

    if (!user) throw new Error('User not found');

    // Check premium limits
    const isPremium = user.subscriptionTier === 'PREMIUM';
    const maxCards = isPremium ? 10 : 3; // Premium gets more cards
    const allowAIGenerated = isPremium; // Only premium users get AI-generated cards

    // Check if user has already received cards today
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const existingCards = await this.prisma.card.findMany({
      where: {
        userId,
        createdAt: {
          gte: today,
          lt: tomorrow,
        },
        status: 'PENDING',
      },
    });

    if (existingCards.length >= maxCards) {
      return existingCards.slice(0, maxCards);
    }

    const cardsNeeded = maxCards - existingCards.length;

    try {
      let cardsToCreate = [];

      if (allowAIGenerated) {
        // Generate AI-powered personalized cards for premium users
        const aiCards = await this.aiService.generateDailyCardSet(userId, {
          progress: user.progress,
          settings: user.settings,
          subscriptionTier: user.subscriptionTier,
        });
        cardsToCreate = aiCards.slice(0, cardsNeeded);
      } else {
        // Use template-based cards for free users
        const templateCards = this.getTemplateCards(userId, user.progress).slice(0, cardsNeeded);
        cardsToCreate = templateCards;
      }

      // Convert cards to database format and save
      const savedCards = [];
      for (const card of cardsToCreate) {
        const savedCard = await this.prisma.card.create({
          data: {
            ...card,
            userId,
            createdAt: new Date(),
            isPremium: card.isPremium || false,
          },
        });
        savedCards.push(savedCard);
      }

      return [...existingCards, ...savedCards];
    } catch (error) {
      console.error('Failed to generate cards, using fallback:', error);
      // Fallback to sample cards
      const fallbackCards = this.getSampleCards(userId).slice(0, cardsNeeded);
      const savedFallbackCards = [];
      for (const card of fallbackCards) {
        const savedCard = await this.prisma.card.create({
          data: {
            ...card,
            userId,
            createdAt: new Date(),
          },
        });
        savedFallbackCards.push(savedCard);
      }
      return [...existingCards, ...savedFallbackCards];
    }
  }

  async createCard(data: any): Promise<Card> {
    return this.prisma.card.create({
      data,
    });
  }

  async updateCard(id: string, data: any): Promise<Card> {
    return this.prisma.card.update({
      where: { id },
      data,
    });
  }

  async completeCard(id: string, userId: string): Promise<Card> {
    const card = await this.prisma.card.update({
      where: { id },
      data: {
        status: 'COMPLETED',
        completedAt: new Date(),
      },
    });

    // Update user progress
    await this.updateUserProgress(userId, card.domain);

    return card;
  }

  private async updateUserProgress(userId: string, domain: LifeDomain) {
    const progress = await this.prisma.userProgress.findUnique({
      where: { userId },
    });

    if (!progress) {
      // Create initial progress
      await this.prisma.userProgress.create({
        data: {
          userId,
          healthScore: domain === 'HEALTH' ? 10 : 0,
          financeScore: domain === 'FINANCE' ? 10 : 0,
          productivityScore: domain === 'PRODUCTIVITY' ? 10 : 0,
          mindfulnessScore: domain === 'MINDFULNESS' ? 10 : 0,
          lifePoints: 10,
          totalCardsCompleted: 1,
          currentStreak: 1,
          lastActiveDate: new Date(),
        },
      });
    } else {
      // Update existing progress
      const updateData: any = {
        lifePoints: { increment: 10 },
        totalCardsCompleted: { increment: 1 },
        lastActiveDate: new Date(),
      };

      switch (domain) {
        case 'HEALTH':
          updateData.healthScore = Math.min(100, progress.healthScore + 5);
          break;
        case 'FINANCE':
          updateData.financeScore = Math.min(100, progress.financeScore + 5);
          break;
        case 'PRODUCTIVITY':
          updateData.productivityScore = Math.min(100, progress.productivityScore + 5);
          break;
        case 'MINDFULNESS':
          updateData.mindfulnessScore = Math.min(100, progress.mindfulnessScore + 5);
          break;
      }

      await this.prisma.userProgress.update({
        where: { userId },
        data: updateData,
      });
    }
  }

  private getTemplateCards(userId: string, progress: any): any[] {
    const templates = [
      {
        title: 'Take a Mindful Walk',
        description: 'Step outside for a 10-minute walk and focus on your breathing',
        actionText: 'Walk for 10 minutes outside',
        domain: 'HEALTH',
        actionType: 'STANDARD',
        priority: 'MEDIUM',
        icon: 'figure.walk',
        tips: ['Leave your phone behind', 'Focus on your breathing'],
        benefits: ['Improves cardiovascular health', 'Reduces stress'],
        aiGenerated: false,
        templateId: 'health-walk-001',
      },
      {
        title: 'Review Yesterday\'s Expenses',
        description: 'Take 5 minutes to review what you spent money on yesterday',
        actionText: 'Review and categorize yesterday\'s spending',
        domain: 'FINANCE',
        actionType: 'STANDARD',
        priority: 'MEDIUM',
        icon: 'chart.line.uptrend.xyaxis',
        tips: ['Use your banking app', 'Look for unnecessary purchases'],
        benefits: ['Increases spending awareness', 'Helps identify waste'],
        aiGenerated: false,
        templateId: 'finance-review-001',
      },
      {
        title: 'Clear Your Desk',
        description: 'Spend 5 minutes organizing your workspace for better focus',
        actionText: 'Organize and clear your desk',
        domain: 'PRODUCTIVITY',
        actionType: 'QUICK',
        priority: 'MEDIUM',
        icon: 'desktopcomputer',
        tips: ['Keep only essentials visible', 'Use organizers for supplies'],
        benefits: ['Reduces distractions', 'Improves focus', 'Creates calm environment'],
        aiGenerated: false,
        templateId: 'productivity-desk-001',
      },
      {
        title: 'Take 5 Deep Breaths',
        description: 'Pause and take five slow, intentional breaths',
        actionText: 'Complete 5 deep breathing cycles',
        domain: 'MINDFULNESS',
        actionType: 'QUICK',
        priority: 'MEDIUM',
        icon: 'lungs.fill',
        tips: ['Inhale for 4 counts', 'Hold for 2 counts', 'Exhale for 6 counts'],
        benefits: ['Reduces stress', 'Improves focus', 'Calms nervous system'],
        aiGenerated: false,
        templateId: 'mindfulness-breathing-001',
      },
    ];

    // Prioritize domains with lower scores
    const domainPriority = [
      { domain: 'HEALTH', score: progress?.healthScore || 0 },
      { domain: 'FINANCE', score: progress?.financeScore || 0 },
      { domain: 'PRODUCTIVITY', score: progress?.productivityScore || 0 },
      { domain: 'MINDFULNESS', score: progress?.mindfulnessScore || 0 },
    ].sort((a, b) => a.score - b.score);

    const selectedTemplates = [];
    for (const { domain } of domainPriority) {
      const domainTemplates = templates.filter(t => t.domain === domain);
      if (domainTemplates.length > 0) {
        selectedTemplates.push(domainTemplates[0]);
        if (selectedTemplates.length >= 3) break;
      }
    }

    return selectedTemplates.map(template => ({
      ...template,
      status: 'PENDING',
      createdAt: new Date(),
      completedAt: null,
      dismissedAt: null,
      snoozedUntil: null,
      viewCount: 0,
      timeSpentViewing: 0,
      userId,
    }));
  }

  private getSampleCards(userId: string): any[] {
    return [
      {
        title: 'Take a Mindful Walk',
        description: 'Step outside for a 10-minute walk and focus on your breathing',
        actionText: 'Walk for 10 minutes outside',
        domain: 'HEALTH',
        actionType: 'STANDARD',
        priority: 'MEDIUM',
        icon: 'figure.walk',
        tips: ['Leave your phone behind', 'Focus on your breathing'],
        benefits: ['Improves cardiovascular health', 'Reduces stress'],
        status: 'PENDING',
        createdAt: new Date(),
        completedAt: null,
        dismissedAt: null,
        snoozedUntil: null,
        viewCount: 0,
        timeSpentViewing: 0,
        aiGenerated: false,
        templateId: 'health-walk-001',
        userId,
      },
      {
        title: 'Review Yesterday\'s Expenses',
        description: 'Take 5 minutes to review what you spent money on yesterday',
        actionText: 'Review and categorize yesterday\'s spending',
        domain: 'FINANCE',
        actionType: 'STANDARD',
        priority: 'MEDIUM',
        icon: 'chart.line.uptrend.xyaxis',
        tips: ['Use your banking app', 'Look for unnecessary purchases'],
        benefits: ['Increases spending awareness', 'Helps identify waste'],
        status: 'PENDING',
        createdAt: new Date(),
        completedAt: null,
        dismissedAt: null,
        snoozedUntil: null,
        viewCount: 0,
        timeSpentViewing: 0,
        aiGenerated: false,
        templateId: 'finance-review-001',
        userId,
      },
    ];
  }
}
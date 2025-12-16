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
      // Generate AI-powered personalized cards
      const aiCards = await this.aiService.generateDailyCardSet(userId, {
        progress: user.progress,
        settings: user.settings,
        subscriptionTier: user.subscriptionTier,
      });

      // Limit cards for free users
      const cardsToCreate = aiCards.slice(0, cardsNeeded);

      // Convert AI cards to database format and save
      const savedCards = [];
      for (const aiCard of cardsToCreate) {
        const card = await this.prisma.card.create({
          data: {
            ...aiCard,
            userId,
            createdAt: new Date(),
            isPremium: aiCard.isPremium || false,
          },
        });
        savedCards.push(card);
      }

      return [...existingCards, ...savedCards];
    } catch (error) {
      console.error('Failed to generate AI cards, using fallback:', error);
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

  private getSampleCards(userId: string): Card[] {
    return [
      {
        id: '1',
        title: 'Take a Mindful Walk',
        description: 'Step outside for a 10-minute walk and focus on your breathing',
        actionText: 'Walk for 10 minutes outside',
        domain: 'HEALTH',
        actionType: 'STANDARD',
        priority: 'MEDIUM',
        icon: 'figure.walk',
        backgroundColor: null,
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
        templateId: null,
        userId,
      },
      {
        id: '2',
        title: 'Review Yesterday\'s Expenses',
        description: 'Take 5 minutes to review what you spent money on yesterday',
        actionText: 'Review and categorize yesterday\'s spending',
        domain: 'FINANCE',
        actionType: 'STANDARD',
        priority: 'MEDIUM',
        icon: 'chart.line.uptrend.xyaxis',
        backgroundColor: null,
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
        templateId: null,
        userId,
      },
    ] as Card[];
  }
}
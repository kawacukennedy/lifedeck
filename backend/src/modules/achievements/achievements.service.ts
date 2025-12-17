import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';

interface AchievementDefinition {
  id: string;
  title: string;
  description: string;
  icon: string;
  category: 'health' | 'finance' | 'productivity' | 'mindfulness' | 'general';
  pointsRequired: number;
  type: 'streak' | 'cards_completed' | 'score_threshold' | 'consistency' | 'milestone';
  criteria: {
    streakDays?: number;
    cardsCompleted?: number;
    scoreThreshold?: number;
    domain?: string;
    consistencyDays?: number;
  };
}

@Injectable()
export class AchievementsService {
  private achievementDefinitions: AchievementDefinition[] = [
    // Streak achievements
    {
      id: 'first_streak',
      title: 'Getting Started',
      description: 'Complete cards for 3 days in a row',
      icon: '🔥',
      category: 'general',
      pointsRequired: 10,
      type: 'streak',
      criteria: { streakDays: 3 },
    },
    {
      id: 'week_warrior',
      title: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: '⚔️',
      category: 'general',
      pointsRequired: 25,
      type: 'streak',
      criteria: { streakDays: 7 },
    },
    {
      id: 'month_master',
      title: 'Month Master',
      description: 'Achieve a 30-day streak',
      icon: '👑',
      category: 'general',
      pointsRequired: 100,
      type: 'streak',
      criteria: { streakDays: 30 },
    },
    {
      id: 'century_club',
      title: 'Century Club',
      description: 'Reach a 100-day streak',
      icon: '💯',
      category: 'general',
      pointsRequired: 500,
      type: 'streak',
      criteria: { streakDays: 100 },
    },

    // Card completion achievements
    {
      id: 'card_collector',
      title: 'Card Collector',
      description: 'Complete 10 coaching cards',
      icon: '🃏',
      category: 'general',
      pointsRequired: 15,
      type: 'cards_completed',
      criteria: { cardsCompleted: 10 },
    },
    {
      id: 'habit_builder',
      title: 'Habit Builder',
      description: 'Complete 50 coaching cards',
      icon: '🏗️',
      category: 'general',
      pointsRequired: 75,
      type: 'cards_completed',
      criteria: { cardsCompleted: 50 },
    },
    {
      id: 'life_optimizer',
      title: 'Life Optimizer',
      description: 'Complete 100 coaching cards',
      icon: '🚀',
      category: 'general',
      pointsRequired: 150,
      type: 'cards_completed',
      criteria: { cardsCompleted: 100 },
    },

    // Domain-specific achievements
    {
      id: 'health_hero',
      title: 'Health Hero',
      description: 'Achieve a health score of 80 or higher',
      icon: '❤️',
      category: 'health',
      pointsRequired: 50,
      type: 'score_threshold',
      criteria: { scoreThreshold: 80, domain: 'health' },
    },
    {
      id: 'finance_wizard',
      title: 'Finance Wizard',
      description: 'Achieve a finance score of 80 or higher',
      icon: '💰',
      category: 'finance',
      pointsRequired: 50,
      type: 'score_threshold',
      criteria: { scoreThreshold: 80, domain: 'finance' },
    },
    {
      id: 'productivity_pro',
      title: 'Productivity Pro',
      description: 'Achieve a productivity score of 80 or higher',
      icon: '⚡',
      category: 'productivity',
      pointsRequired: 50,
      type: 'score_threshold',
      criteria: { scoreThreshold: 80, domain: 'productivity' },
    },
    {
      id: 'mindfulness_master',
      title: 'Mindfulness Master',
      description: 'Achieve a mindfulness score of 80 or higher',
      icon: '🧘',
      category: 'mindfulness',
      pointsRequired: 50,
      type: 'score_threshold',
      criteria: { scoreThreshold: 80, domain: 'mindfulness' },
    },

    // Consistency achievements
    {
      id: 'consistent_completer',
      title: 'Consistent Completer',
      description: 'Complete at least one card every day for 14 days',
      icon: '📅',
      category: 'general',
      pointsRequired: 40,
      type: 'consistency',
      criteria: { consistencyDays: 14 },
    },

    // Milestone achievements
    {
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Complete your first card before 8 AM',
      icon: '🐦',
      category: 'general',
      pointsRequired: 5,
      type: 'milestone',
      criteria: {},
    },
    {
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Complete cards after 10 PM',
      icon: '🦉',
      category: 'general',
      pointsRequired: 5,
      type: 'milestone',
      criteria: {},
    },
  ];

  constructor(
    private prisma: PrismaService,
    private notificationsService: NotificationsService,
  ) {}

  async checkAndUnlockAchievements(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { progress: true, achievements: true },
    });

    if (!user || !user.progress) return [];

    const unlockedAchievements = [];
    const existingAchievementIds = user.achievements.map(a => a.id);

    for (const achievement of this.achievementDefinitions) {
      // Skip if already unlocked
      if (existingAchievementIds.includes(achievement.id)) continue;

      // Check if achievement criteria are met
      if (await this.checkAchievementCriteria(user, achievement)) {
        // Unlock the achievement
        const unlockedAchievement = await this.prisma.achievement.create({
          data: {
            id: achievement.id,
            userId,
            title: achievement.title,
            description: achievement.description,
            icon: achievement.icon,
            pointsRequired: achievement.pointsRequired,
            category: achievement.category.toUpperCase(),
            isUnlocked: true,
            unlockedDate: new Date(),
          },
        });

        unlockedAchievements.push(unlockedAchievement);

        // Send notification
        await this.notificationsService.sendPushNotification(
          userId,
          '🏆 Achievement Unlocked!',
          achievement.title,
          {
            type: 'achievement_unlocked',
            achievementId: achievement.id,
            achievementTitle: achievement.title,
          },
        );

        // Award bonus points
        await this.prisma.userProgress.update({
          where: { userId },
          data: {
            lifePoints: { increment: achievement.pointsRequired },
          },
        });
      }
    }

    return unlockedAchievements;
  }

  private async checkAchievementCriteria(user: any, achievement: AchievementDefinition): Promise<boolean> {
    const { progress } = user;

    switch (achievement.type) {
      case 'streak':
        return progress.currentStreak >= (achievement.criteria.streakDays || 0);

      case 'cards_completed':
        return progress.totalCardsCompleted >= (achievement.criteria.cardsCompleted || 0);

      case 'score_threshold':
        const domain = achievement.criteria.domain;
        if (!domain) return false;

        const scoreKey = `${domain.toLowerCase()}Score`;
        return progress[scoreKey] >= (achievement.criteria.scoreThreshold || 0);

      case 'consistency':
        // Check if user has completed cards consistently over the period
        const consistencyDays = achievement.criteria.consistencyDays || 0;
        const activities = await this.prisma.activity.findMany({
          where: {
            userId: user.id,
            createdAt: {
              gte: new Date(Date.now() - consistencyDays * 24 * 60 * 60 * 1000),
            },
          },
        });

        // Count days with at least one activity
        const activeDays = new Set(
          activities.map(a => a.createdAt.toDateString())
        ).size;

        return activeDays >= consistencyDays;

      case 'milestone':
        // Special case achievements that require specific conditions
        if (achievement.id === 'early_bird') {
          const earlyActivities = await this.prisma.activity.findFirst({
            where: {
              userId: user.id,
              createdAt: {
                gte: new Date(new Date().setHours(0, 0, 0, 0)),
                lt: new Date(new Date().setHours(8, 0, 0, 0)),
              },
            },
          });
          return !!earlyActivities;
        } else if (achievement.id === 'night_owl') {
          const nightActivities = await this.prisma.activity.findFirst({
            where: {
              userId: user.id,
              createdAt: {
                gte: new Date(new Date().setHours(22, 0, 0, 0)),
              },
            },
          });
          return !!nightActivities;
        }

      default:
        return false;
    }
  }

  async getUserAchievements(userId: string) {
    return this.prisma.achievement.findMany({
      where: { userId },
      orderBy: { unlockedDate: 'desc' },
    });
  }

  async getAvailableAchievements(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { achievements: true, progress: true },
    });

    if (!user) return [];

    const unlockedIds = user.achievements.map(a => a.id);

    return this.achievementDefinitions
      .filter(achievement => !unlockedIds.includes(achievement.id))
      .map(achievement => ({
        ...achievement,
        progress: this.calculateAchievementProgress(user, achievement),
        isUnlockable: this.isAchievementUnlockable(user, achievement),
      }));
  }

  private calculateAchievementProgress(user: any, achievement: AchievementDefinition): number {
    const { progress } = user;

    switch (achievement.type) {
      case 'streak':
        return Math.min(100, (progress.currentStreak / (achievement.criteria.streakDays || 1)) * 100);

      case 'cards_completed':
        return Math.min(100, (progress.totalCardsCompleted / (achievement.criteria.cardsCompleted || 1)) * 100);

      case 'score_threshold':
        const domain = achievement.criteria.domain;
        if (!domain) return 0;

        const scoreKey = `${domain.toLowerCase()}Score`;
        return Math.min(100, (progress[scoreKey] / (achievement.criteria.scoreThreshold || 1)) * 100);

      default:
        return 0;
    }
  }

  private isAchievementUnlockable(user: any, achievement: AchievementDefinition): boolean {
    // For now, all achievements are unlockable
    // In the future, you might have premium-only achievements
    return true;
  }

  async getAchievementStats(userId: string) {
    const achievements = await this.prisma.achievement.findMany({
      where: { userId },
    });

    const totalAchievements = this.achievementDefinitions.length;
    const unlockedAchievements = achievements.length;
    const totalPoints = achievements.reduce((sum, a) => sum + a.pointsRequired, 0);

    return {
      totalAchievements,
      unlockedAchievements,
      completionPercentage: Math.round((unlockedAchievements / totalAchievements) * 100),
      totalPoints,
    };
  }
}
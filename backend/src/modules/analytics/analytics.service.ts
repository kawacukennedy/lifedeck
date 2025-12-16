import { Injectable, Inject } from '@nestjs/common';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';
import { PrismaService } from '../../database/prisma.service';
import { LifeDomain } from '@prisma/client';

@Injectable()
export class AnalyticsService {
  constructor(
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
    private prisma: PrismaService,
  ) {}

  async getUserAnalytics(userId: string, timeframe: 'week' | 'month' | 'year' = 'month') {
    const cacheKey = `analytics-${userId}-${timeframe}`;

    // Check cache first
    const cachedAnalytics = await this.cacheManager.get(cacheKey);
    if (cachedAnalytics) {
      return cachedAnalytics;
    }

    const progress = await this.prisma.userProgress.findUnique({
      where: { userId },
    });

    const activities = await this.prisma.activity.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });

    const insights = await this.generateInsights(userId, timeframe);
    const trends = await this.calculateTrends(userId, timeframe);
    const correlations = await this.analyzeCorrelations(userId);

    const analytics = {
      progress,
      activities,
      insights,
      trends,
      correlations,
    };

    // Cache for 30 minutes
    await this.cacheManager.set(cacheKey, analytics, 30 * 60 * 1000);

    return analytics;
  }

  async getLifeScore(userId: string) {
    const cacheKey = `life-score-${userId}`;

    // Check cache first
    const cachedScore = await this.cacheManager.get(cacheKey);
    if (cachedScore !== undefined) {
      return cachedScore;
    }

    const progress = await this.prisma.userProgress.findUnique({
      where: { userId },
    });

    const score = progress
      ? (progress.healthScore + progress.financeScore + progress.productivityScore + progress.mindfulnessScore) / 4
      : 0;

    // Cache for 15 minutes
    await this.cacheManager.set(cacheKey, score, 15 * 60 * 1000);

    return score;
  }

  async getDomainAnalytics(userId: string, domain: LifeDomain) {
    const progress = await this.prisma.userProgress.findUnique({
      where: { userId },
    });

    const domainActivities = await this.prisma.activity.findMany({
      where: {
        userId,
        domain,
      },
      orderBy: { createdAt: 'desc' },
      take: 30,
    });

    const domainScore = progress ? this.getDomainScore(progress, domain) : 0;
    const improvement = await this.calculateDomainImprovement(userId, domain, 30); // 30 days

    return {
      domain,
      score: domainScore,
      improvement,
      activities: domainActivities,
      recommendations: this.generateDomainRecommendations(domain, domainScore, improvement),
    };
  }

  private getDomainScore(progress: any, domain: LifeDomain): number {
    switch (domain) {
      case 'HEALTH':
        return progress.healthScore;
      case 'FINANCE':
        return progress.financeScore;
      case 'PRODUCTIVITY':
        return progress.productivityScore;
      case 'MINDFULNESS':
        return progress.mindfulnessScore;
      default:
        return 0;
    }
  }

  private async calculateDomainImprovement(userId: string, domain: LifeDomain, days: number): Promise<number> {
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(endDate.getDate() - days);

    // Get activities in the timeframe
    const activities = await this.prisma.activity.findMany({
      where: {
        userId,
        domain,
        createdAt: {
          gte: startDate,
          lte: endDate,
        },
      },
    });

    // Calculate improvement based on activity frequency and points
    const totalPoints = activities.reduce((sum, activity) => sum + activity.points, 0);
    const averageDailyPoints = totalPoints / days;

    // Normalize to a 0-100 scale
    return Math.min(100, averageDailyPoints * 10);
  }

  private generateDomainRecommendations(domain: LifeDomain, score: number, improvement: number): string[] {
    const recommendations = [];

    if (score < 40) {
      switch (domain) {
        case 'HEALTH':
          recommendations.push('Focus on building basic healthy habits like daily walks or proper sleep.');
          recommendations.push('Consider tracking your step count and setting achievable daily goals.');
          break;
        case 'FINANCE':
          recommendations.push('Start by tracking daily expenses and identifying spending patterns.');
          recommendations.push('Set up a simple budget for essential categories.');
          break;
        case 'PRODUCTIVITY':
          recommendations.push('Begin with time-blocking techniques and prioritize your top 3 daily tasks.');
          recommendations.push('Minimize distractions during focused work periods.');
          break;
        case 'MINDFULNESS':
          recommendations.push('Start with 5-minute daily meditation sessions.');
          recommendations.push('Practice gratitude by noting three things you\'re thankful for each day.');
          break;
      }
    } else if (score < 70) {
      recommendations.push('You\'re making good progress! Focus on consistency to reach the next level.');
      if (improvement < 20) {
        recommendations.push('Consider increasing the frequency of activities in this domain.');
      }
    } else {
      recommendations.push('Excellent work! You\'re excelling in this area.');
      recommendations.push('Consider mentoring others or taking on advanced challenges.');
    }

    return recommendations;
  }

  private async generateInsights(userId: string, timeframe: string): Promise<any[]> {
    const insights = [];
    const progress = await this.prisma.userProgress.findUnique({
      where: { userId },
    });

    if (!progress) return insights;

    // Streak insights
    if (progress.currentStreak >= 7) {
      insights.push({
        type: 'streak',
        title: 'Consistency Champion!',
        description: `You've maintained a ${progress.currentStreak}-day streak. Keep it up!`,
        impact: 'high',
      });
    }

    // Domain balance insights
    const scores = [
      { domain: 'Health', score: progress.healthScore },
      { domain: 'Finance', score: progress.financeScore },
      { domain: 'Productivity', score: progress.productivityScore },
      { domain: 'Mindfulness', score: progress.mindfulnessScore },
    ];

    const lowestDomain = scores.reduce((min, current) =>
      current.score < min.score ? current : min
    );

    if (lowestDomain.score < 50) {
      insights.push({
        type: 'improvement',
        title: `${lowestDomain.domain} Needs Attention`,
        description: `Your ${lowestDomain.domain.toLowerCase()} score is ${lowestDomain.score}. Consider focusing more activities here.`,
        impact: 'medium',
      });
    }

    // Life score trends
    const lifeScore = await this.getLifeScore(userId);
    if (lifeScore >= 75) {
      insights.push({
        type: 'achievement',
        title: 'Life Optimization Master',
        description: 'Your overall life score is excellent! You\'re living a well-balanced life.',
        impact: 'high',
      });
    }

    return insights;
  }

  private async calculateTrends(userId: string, timeframe: string): Promise<any> {
    // Calculate trends over time
    const days = timeframe === 'week' ? 7 : timeframe === 'month' ? 30 : 365;

    const activities = await this.prisma.activity.findMany({
      where: {
        userId,
        createdAt: {
          gte: new Date(Date.now() - days * 24 * 60 * 60 * 1000),
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    // Group activities by day
    const dailyActivity = activities.reduce((acc, activity) => {
      const date = activity.createdAt.toDateString();
      acc[date] = (acc[date] || 0) + activity.points;
      return acc;
    }, {} as Record<string, number>);

    // Calculate moving averages and trends
    const dates = Object.keys(dailyActivity).sort();
    const values = dates.map(date => dailyActivity[date]);

    return {
      dates,
      values,
      trend: this.calculateTrend(values),
      average: values.reduce((a, b) => a + b, 0) / values.length,
      bestDay: dates[values.indexOf(Math.max(...values))],
    };
  }

  private calculateTrend(values: number[]): 'up' | 'down' | 'stable' {
    if (values.length < 2) return 'stable';

    const firstHalf = values.slice(0, Math.floor(values.length / 2));
    const secondHalf = values.slice(Math.floor(values.length / 2));

    const firstAvg = firstHalf.reduce((a, b) => a + b, 0) / firstHalf.length;
    const secondAvg = secondHalf.reduce((a, b) => a + b, 0) / secondHalf.length;

    const change = ((secondAvg - firstAvg) / firstAvg) * 100;

    if (change > 10) return 'up';
    if (change < -10) return 'down';
    return 'stable';
  }

  private async analyzeCorrelations(userId: string): Promise<any[]> {
    // Analyze correlations between different life domains
    const correlations = [];

    // Example: Check if productivity improves when health score is high
    const healthProductivityCorrelation = await this.calculateDomainCorrelation(
      userId,
      'HEALTH',
      'PRODUCTIVITY',
      30,
    );

    if (Math.abs(healthProductivityCorrelation) > 0.3) {
      correlations.push({
        domains: ['Health', 'Productivity'],
        correlation: healthProductivityCorrelation,
        insight: healthProductivityCorrelation > 0
          ? 'Your productivity tends to improve when your health score is higher.'
          : 'Your productivity may decrease when focusing heavily on health activities.',
      });
    }

    return correlations;
  }

  private async calculateDomainCorrelation(
    userId: string,
    domain1: LifeDomain,
    domain2: LifeDomain,
    days: number,
  ): Promise<number> {
    // Simplified correlation calculation
    // In a real implementation, you'd use proper statistical methods
    const activities1 = await this.prisma.activity.count({
      where: {
        userId,
        domain: domain1,
        createdAt: {
          gte: new Date(Date.now() - days * 24 * 60 * 60 * 1000),
        },
      },
    });

    const activities2 = await this.prisma.activity.count({
      where: {
        userId,
        domain: domain2,
        createdAt: {
          gte: new Date(Date.now() - days * 24 * 60 * 60 * 1000),
        },
      },
    });

    // Simple correlation approximation
    const avgActivities = (activities1 + activities2) / 2;
    const correlation = (activities1 - avgActivities) * (activities2 - avgActivities) > 0 ? 0.5 : -0.5;

    return correlation;
  }
}
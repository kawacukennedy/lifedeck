import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class AnalyticsService {
  constructor(private prisma: PrismaService) {}

  async getUserAnalytics(userId: string) {
    const progress = await this.prisma.userProgress.findUnique({
      where: { userId },
    });

    const activities = await this.prisma.activity.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 10,
    });

    return {
      progress,
      activities,
    };
  }

  async getLifeScore(userId: string) {
    const progress = await this.prisma.userProgress.findUnique({
      where: { userId },
    });

    if (!progress) return 0;

    return (progress.healthScore + progress.financeScore + progress.productivityScore + progress.mindfulnessScore) / 4;
  }
}
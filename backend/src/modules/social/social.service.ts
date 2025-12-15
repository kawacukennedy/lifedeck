import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class SocialService {
  constructor(private prisma: PrismaService) {}

  async getLeaderboard(timeframe: 'daily' | 'weekly' | 'monthly' | 'all-time' = 'weekly', limit: number = 50) {
    const dateFilter = this.getDateFilter(timeframe);

    const users = await this.prisma.user.findMany({
      where: dateFilter ? {
        progress: {
          lastActiveDate: {
            gte: dateFilter,
          },
        },
      } : {},
      include: {
        progress: true,
        achievements: {
          where: {
            isUnlocked: true,
          },
        },
      },
      orderBy: {
        progress: {
          lifeScore: 'desc',
        },
      },
      take: limit,
    });

    return users.map((user, index) => ({
      rank: index + 1,
      userId: user.id,
      name: user.name || 'Anonymous',
      avatar: user.avatar,
      lifeScore: user.progress?.lifeScore || 0,
      currentStreak: user.progress?.currentStreak || 0,
      totalCardsCompleted: user.progress?.totalCardsCompleted || 0,
      achievementsCount: user.achievements.length,
      isCurrentUser: false, // This would be set based on request user
    }));
  }

  async getUserRank(userId: string, timeframe: 'daily' | 'weekly' | 'monthly' | 'all-time' = 'weekly') {
    const dateFilter = this.getDateFilter(timeframe);

    const usersAbove = await this.prisma.user.count({
      where: {
        AND: [
          dateFilter ? {
            progress: {
              lastActiveDate: {
                gte: dateFilter,
              },
            },
          } : {},
          {
            progress: {
              lifeScore: {
                gt: await this.getUserLifeScore(userId),
              },
            },
          },
        ],
      },
    });

    const totalUsers = await this.prisma.user.count({
      where: dateFilter ? {
        progress: {
          lastActiveDate: {
            gte: dateFilter,
          },
        },
      } : {},
    });

    return {
      rank: usersAbove + 1,
      totalUsers,
      percentile: totalUsers > 0 ? ((totalUsers - usersAbove) / totalUsers) * 100 : 0,
    };
  }

  async getAchievementsLeaderboard(limit: number = 20) {
    const users = await this.prisma.user.findMany({
      include: {
        achievements: {
          where: {
            isUnlocked: true,
          },
        },
        progress: true,
      },
      orderBy: {
        achievements: {
          _count: 'desc',
        },
      },
      take: limit,
    });

    return users.map((user, index) => ({
      rank: index + 1,
      userId: user.id,
      name: user.name || 'Anonymous',
      avatar: user.avatar,
      achievementsCount: user.achievements.length,
      recentAchievements: user.achievements
        .sort((a, b) => b.unlockedDate?.getTime() || 0 - (a.unlockedDate?.getTime() || 0))
        .slice(0, 3)
        .map(achievement => ({
          title: achievement.title,
          unlockedDate: achievement.unlockedDate,
        })),
    }));
  }

  async getStreakLeaderboard(limit: number = 20) {
    const users = await this.prisma.user.findMany({
      include: {
        progress: true,
      },
      where: {
        progress: {
          currentStreak: {
            gt: 0,
          },
        },
      },
      orderBy: {
        progress: {
          currentStreak: 'desc',
        },
      },
      take: limit,
    });

    return users.map((user, index) => ({
      rank: index + 1,
      userId: user.id,
      name: user.name || 'Anonymous',
      avatar: user.avatar,
      currentStreak: user.progress?.currentStreak || 0,
      longestStreak: user.progress?.longestStreak || 0,
    }));
  }

  async shareAchievement(userId: string, achievementId: string, platform: 'twitter' | 'facebook' | 'general') {
    const achievement = await this.prisma.achievement.findFirst({
      where: {
        id: achievementId,
        userId,
        isUnlocked: true,
      },
    });

    if (!achievement) {
      throw new Error('Achievement not found or not unlocked');
    }

    // Generate shareable content
    const shareContent = {
      title: `🏆 Achievement Unlocked: ${achievement.title}`,
      description: achievement.description,
      url: `${process.env.FRONTEND_URL}/achievements/${achievement.id}`,
      hashtags: ['LifeDeck', 'PersonalGrowth', 'Achievement'],
    };

    // Log the share activity
    await this.prisma.activity.create({
      data: {
        userId,
        type: 'ACHIEVEMENT_SHARED',
        domain: achievement.category,
        metadata: {
          achievementId,
          platform,
          shareContent,
        },
      },
    });

    return shareContent;
  }

  async getCommunityStats() {
    const [
      totalUsers,
      activeUsers,
      totalCardsCompleted,
      averageLifeScore,
      topStreaks,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.user.count({
        where: {
          progress: {
            lastActiveDate: {
              gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // Last 7 days
            },
          },
        },
      }),
      this.prisma.userProgress.aggregate({
        _sum: {
          totalCardsCompleted: true,
        },
      }),
      this.prisma.userProgress.aggregate({
        _avg: {
          lifeScore: true,
        },
      }),
      this.prisma.userProgress.findMany({
        orderBy: {
          longestStreak: 'desc',
        },
        take: 5,
        include: {
          user: {
            select: {
              name: true,
            },
          },
        },
      }),
    ]);

    return {
      totalUsers,
      activeUsers,
      totalCardsCompleted: totalCardsCompleted._sum.totalCardsCompleted || 0,
      averageLifeScore: averageLifeScore._avg.lifeScore || 0,
      topStreaks: topStreaks.map(streak => ({
        userName: streak.user.name || 'Anonymous',
        longestStreak: streak.longestStreak,
      })),
    };
  }

  private getDateFilter(timeframe: 'daily' | 'weekly' | 'monthly' | 'all-time') {
    const now = new Date();
    switch (timeframe) {
      case 'daily':
        return new Date(now.getTime() - 24 * 60 * 60 * 1000);
      case 'weekly':
        return new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      case 'monthly':
        return new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      case 'all-time':
        return null;
      default:
        return new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    }
  }

  private async getUserLifeScore(userId: string): Promise<number> {
    const progress = await this.prisma.userProgress.findUnique({
      where: { userId },
    });
    return progress?.lifeScore || 0;
  }
}
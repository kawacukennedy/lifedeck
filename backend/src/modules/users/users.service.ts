import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { User } from '@prisma/client';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { id },
    });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { email },
    });
  }

  async create(data: {
    email: string;
    password?: string;
    name?: string;
    avatar?: string;
  }): Promise<User> {
    return this.prisma.user.create({
      data: {
        email: data.email,
        name: data.name,
        avatar: data.avatar,
        ...(data.password && { password: data.password }),
      },
    });
  }

  async update(id: string, data: Partial<User>): Promise<User> {
    return this.prisma.user.update({
      where: { id },
      data,
    });
  }

   async delete(id: string): Promise<User> {
     return this.prisma.user.delete({
       where: { id },
     });
   }

   async setGoals(userId: string, goals: any[]) {
     // Create or update user settings with goals
     await this.prisma.userSettings.upsert({
       where: { userId },
       update: {
         // Store goals in metadata or create separate Goal model
         // For now, we'll store in a JSON field if we add it to UserSettings
       },
       create: {
         userId,
         // goals: goals,
       },
     });

     return { success: true, goals };
   }

   async setPreferences(userId: string, preferences: { domains: string[]; maxDailyCards: number }) {
     await this.prisma.userSettings.upsert({
       where: { userId },
       update: {
         preferredDomains: preferences.domains as any,
         maxDailyCards: preferences.maxDailyCards,
       },
       create: {
         userId,
         preferredDomains: preferences.domains as any,
         maxDailyCards: preferences.maxDailyCards,
       },
     });

     return { success: true, preferences };
   }

   async completeOnboarding(userId: string) {
     await this.prisma.user.update({
       where: { id: userId },
       data: { lastActiveDate: new Date() },
     });

     // Could also create initial progress, settings, etc.
     await this.initializeUserProgress(userId);

     return { success: true, message: 'Onboarding completed' };
   }

   private async initializeUserProgress(userId: string) {
     // Create initial user progress if it doesn't exist
     const existingProgress = await this.prisma.userProgress.findUnique({
       where: { userId },
     });

     if (!existingProgress) {
       await this.prisma.userProgress.create({
         data: {
           userId,
           healthScore: 0,
           financeScore: 0,
           productivityScore: 0,
           mindfulnessScore: 0,
           lifeScore: 0,
           currentStreak: 0,
           lifePoints: 0,
           totalCardsCompleted: 0,
         },
       });
     }

     // Create initial user settings if they don't exist
     const existingSettings = await this.prisma.userSettings.findUnique({
       where: { userId },
     });

     if (!existingSettings) {
       await this.prisma.userSettings.create({
         data: {
           userId,
           notificationsEnabled: true,
           dailyReminderTime: new Date('09:00:00'),
           preferredDomains: ['HEALTH', 'FINANCE', 'PRODUCTIVITY', 'MINDFULNESS'],
           maxDailyCards: 5,
           soundEnabled: true,
           hapticEnabled: true,
         },
       });
     }
   }
}
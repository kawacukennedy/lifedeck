import { Injectable } from '@nestjs/common';
import { google } from 'googleapis';
import { PrismaService } from '../../database/prisma.service';

interface HealthData {
  steps: number;
  calories: number;
  activeMinutes: number;
  sleepHours: number;
  heartRate?: number;
  date: string;
}

interface HealthInsights {
  averageSteps: number;
  averageCalories: number;
  averageSleep: number;
  activityTrend: 'increasing' | 'decreasing' | 'stable';
  sleepTrend: 'improving' | 'worsening' | 'stable';
  recommendations: string[];
  weeklyGoals: {
    steps: number;
    calories: number;
    sleep: number;
  };
}

@Injectable()
export class HealthService {
  private fitness;

  constructor(private prisma: PrismaService) {
    // Initialize Google Fitness API
    this.fitness = google.fitness('v1');
  }

  // Google Fit Integration
  generateGoogleFitAuthUrl(userId: string): string {
    const oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_FIT_CLIENT_ID,
      process.env.GOOGLE_FIT_CLIENT_SECRET,
      `${process.env.BASE_URL || 'http://localhost:3000'}/v1/integrations/google-fit/callback`,
    );

    const scopes = [
      'https://www.googleapis.com/auth/fitness.activity.read',
      'https://www.googleapis.com/auth/fitness.body.read',
      'https://www.googleapis.com/auth/fitness.sleep.read',
    ];

    return oauth2Client.generateAuthUrl({
      access_type: 'offline',
      scope: scopes,
      state: userId,
    });
  }

  async getGoogleFitTokens(code: string) {
    const oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_FIT_CLIENT_ID,
      process.env.GOOGLE_FIT_CLIENT_SECRET,
      `${process.env.BASE_URL || 'http://localhost:3000'}/v1/integrations/google-fit/callback`,
    );

    const { tokens } = await oauth2Client.getToken(code);
    return tokens;
  }

  async getGoogleFitData(accessToken: string, refreshToken: string, days: number = 7): Promise<HealthData[]> {
    const oauth2Client = new google.auth.OAuth2();
    oauth2Client.setCredentials({
      access_token: accessToken,
      refresh_token: refreshToken,
    });

    const endTimeMillis = Date.now();
    const startTimeMillis = endTimeMillis - (days * 24 * 60 * 60 * 1000);

    const dataSources = [
      'derived:com.google.step_count.delta:com.google.android.gms:estimated_steps',
      'derived:com.google.calories.expended:com.google.android.gms:from_activities',
      'derived:com.google.active_minutes:com.google.android.gms:from_activities',
      'derived:com.google.sleep.segment:com.google.android.gms:merged',
    ];

    const healthData: HealthData[] = [];

    for (let i = 0; i < days; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];

      const dayData: HealthData = {
        steps: 0,
        calories: 0,
        activeMinutes: 0,
        sleepHours: 0,
        date: dateStr,
      };

      try {
        // Get steps
        const stepsResponse = await this.fitness.users.dataSources.datasets.get({
          userId: 'me',
          dataSourceId: dataSources[0],
          datasetId: `${startTimeMillis * 1000000}-${endTimeMillis * 1000000}`,
          auth: oauth2Client,
        });

        if (stepsResponse.data.point) {
          stepsResponse.data.point.forEach(point => {
            if (point.value && point.value[0]) {
              dayData.steps += point.value[0].intVal || 0;
            }
          });
        }

        // Get calories
        const caloriesResponse = await this.fitness.users.dataSources.datasets.get({
          userId: 'me',
          dataSourceId: dataSources[1],
          datasetId: `${startTimeMillis * 1000000}-${endTimeMillis * 1000000}`,
          auth: oauth2Client,
        });

        if (caloriesResponse.data.point) {
          caloriesResponse.data.point.forEach(point => {
            if (point.value && point.value[0]) {
              dayData.calories += point.value[0].fpVal || 0;
            }
          });
        }

        // Get active minutes
        const activeMinutesResponse = await this.fitness.users.dataSources.datasets.get({
          userId: 'me',
          dataSourceId: dataSources[2],
          datasetId: `${startTimeMillis * 1000000}-${endTimeMillis * 1000000}`,
          auth: oauth2Client,
        });

        if (activeMinutesResponse.data.point) {
          activeMinutesResponse.data.point.forEach(point => {
            if (point.value && point.value[0]) {
              dayData.activeMinutes += point.value[0].intVal || 0;
            }
          });
        }

        // Get sleep data
        const sleepResponse = await this.fitness.users.dataSources.datasets.get({
          userId: 'me',
          dataSourceId: dataSources[3],
          datasetId: `${startTimeMillis * 1000000}-${endTimeMillis * 1000000}`,
          auth: oauth2Client,
        });

        if (sleepResponse.data.point) {
          sleepResponse.data.point.forEach(point => {
            if (point.value && point.value[0] && point.value[0].intVal === 1) { // Sleep segment
              const startTime = point.startTimeNanos! / 1000000000;
              const endTime = point.endTimeNanos! / 1000000000;
              dayData.sleepHours += (endTime - startTime) / 3600; // Convert to hours
            }
          });
        }

      } catch (error) {
        console.error(`Failed to fetch health data for ${dateStr}:`, error);
      }

      healthData.push(dayData);
    }

    return healthData.reverse(); // Return in chronological order
  }

  // Apple HealthKit Integration (via web interface - limited)
  // Note: Full Apple HealthKit integration requires native iOS app
  async processAppleHealthData(userId: string, healthData: any) {
    // Store Apple Health data sent from iOS app
    // This would typically come via a native iOS app that accesses HealthKit

    const processedData = {
      userId,
      steps: healthData.steps || 0,
      calories: healthData.calories || 0,
      activeMinutes: healthData.activeMinutes || 0,
      sleepHours: healthData.sleepHours || 0,
      heartRate: healthData.heartRate,
      date: healthData.date || new Date().toISOString().split('T')[0],
      source: 'apple-healthkit',
    };

    // Store in database
    await this.prisma.healthData.upsert({
      where: {
        userId_date: {
          userId,
          date: processedData.date,
        },
      },
      update: processedData,
      create: processedData,
    });

    return processedData;
  }

  // General health data processing
  async storeHealthData(userId: string, data: HealthData, source: 'google-fit' | 'apple-healthkit' | 'manual') {
    return await this.prisma.healthData.upsert({
      where: {
        userId_date: {
          userId,
          date: data.date,
        },
      },
      update: {
        ...data,
        source,
      },
      create: {
        userId,
        ...data,
        source,
      },
    });
  }

  async getHealthData(userId: string, days: number = 30): Promise<HealthData[]> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const healthRecords = await this.prisma.healthData.findMany({
      where: {
        userId,
        date: {
          gte: startDate.toISOString().split('T')[0],
        },
      },
      orderBy: {
        date: 'asc',
      },
    });

    return healthRecords.map(record => ({
      steps: record.steps,
      calories: record.calories,
      activeMinutes: record.activeMinutes,
      sleepHours: record.sleepHours,
      heartRate: record.heartRate || undefined,
      date: record.date,
    }));
  }

  async getHealthInsights(userId: string, days: number = 30): Promise<HealthInsights> {
    const healthData = await this.getHealthData(userId, days);

    if (healthData.length === 0) {
      return {
        averageSteps: 0,
        averageCalories: 0,
        averageSleep: 0,
        activityTrend: 'stable',
        sleepTrend: 'stable',
        recommendations: ['Start tracking your health data to get personalized insights!'],
        weeklyGoals: {
          steps: 7000,
          calories: 2000,
          sleep: 7,
        },
      };
    }

    const insights: HealthInsights = {
      averageSteps: healthData.reduce((sum, d) => sum + d.steps, 0) / healthData.length,
      averageCalories: healthData.reduce((sum, d) => sum + d.calories, 0) / healthData.length,
      averageSleep: healthData.reduce((sum, d) => sum + d.sleepHours, 0) / healthData.length,
      activityTrend: 'stable',
      sleepTrend: 'stable',
      recommendations: [],
      weeklyGoals: {
        steps: 10000,
        calories: 2000,
        sleep: 8,
      },
    };

    // Calculate trends
    const firstHalf = healthData.slice(0, Math.floor(healthData.length / 2));
    const secondHalf = healthData.slice(Math.floor(healthData.length / 2));

    const firstHalfAvgSteps = firstHalf.reduce((sum, d) => sum + d.steps, 0) / firstHalf.length;
    const secondHalfAvgSteps = secondHalf.reduce((sum, d) => sum + d.steps, 0) / secondHalf.length;

    if (secondHalfAvgSteps > firstHalfAvgSteps * 1.1) {
      insights.activityTrend = 'increasing';
    } else if (secondHalfAvgSteps < firstHalfAvgSteps * 0.9) {
      insights.activityTrend = 'decreasing';
    }

    const firstHalfAvgSleep = firstHalf.reduce((sum, d) => sum + d.sleepHours, 0) / firstHalf.length;
    const secondHalfAvgSleep = secondHalf.reduce((sum, d) => sum + d.sleepHours, 0) / secondHalf.length;

    if (secondHalfAvgSleep > firstHalfAvgSleep * 1.05) {
      insights.sleepTrend = 'improving';
    } else if (secondHalfAvgSleep < firstHalfAvgSleep * 0.95) {
      insights.sleepTrend = 'worsening';
    }

    // Generate recommendations
    if (insights.averageSteps < 5000) {
      insights.recommendations.push('Try to increase your daily steps to at least 5,000 for better health.');
    } else if (insights.averageSteps < 10000) {
      insights.recommendations.push('Great job on steps! Aim for 10,000 daily for optimal fitness.');
    }

    if (insights.averageSleep < 7) {
      insights.recommendations.push('Consider improving your sleep schedule. Aim for 7-9 hours per night.');
    }

    if (insights.activityTrend === 'decreasing') {
      insights.recommendations.push('Your activity levels have been decreasing. Try to maintain or increase your physical activity.');
    }

    if (insights.sleepTrend === 'worsening') {
      insights.recommendations.push('Your sleep quality seems to be declining. Consider establishing a consistent sleep routine.');
    }

    // Set personalized goals
    insights.weeklyGoals.steps = Math.max(7000, Math.round(insights.averageSteps * 1.2));
    insights.weeklyGoals.calories = Math.max(1800, Math.round(insights.averageCalories));
    insights.weeklyGoals.sleep = Math.max(7, Math.round(insights.averageSleep + 0.5));

    return insights;
  }

  // Sync health data from connected services
  async syncHealthData(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        googleFitAccessToken: true,
        googleFitRefreshToken: true,
        appleHealthConnected: true,
      },
    });

    if (!user) {
      throw new Error('User not found');
    }

    const results = {
      googleFit: null as any,
      appleHealth: null as any,
    };

    // Sync Google Fit data
    if (user.googleFitAccessToken && user.googleFitRefreshToken) {
      try {
        const googleFitData = await this.getGoogleFitData(
          user.googleFitAccessToken,
          user.googleFitRefreshToken,
          7 // Last 7 days
        );

        for (const data of googleFitData) {
          await this.storeHealthData(userId, data, 'google-fit');
        }

        results.googleFit = { success: true, records: googleFitData.length };
      } catch (error) {
        console.error('Failed to sync Google Fit data:', error);
        results.googleFit = { success: false, error: error.message };
      }
    }

    // Apple Health data would be synced via iOS app
    if (user.appleHealthConnected) {
      results.appleHealth = { success: true, message: 'Apple Health data synced via iOS app' };
    }

    return results;
  }
}
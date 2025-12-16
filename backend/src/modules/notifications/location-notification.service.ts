import { Injectable } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bull';
import { Queue } from 'bull';
import { PrismaService } from '../../database/prisma.service';

export interface LocationContext {
  latitude: number;
  longitude: number;
  accuracy?: number;
  timestamp: number;
  contexts: string[]; // e.g., ['morning', 'weekday', 'at_home']
}

export interface LocationTrigger {
  id: string;
  userId: string;
  triggerType: 'geofence_entry' | 'geofence_exit' | 'context_change' | 'time_location';
  location?: {
    latitude: number;
    longitude: number;
    radius: number;
  };
  contexts?: string[]; // Required contexts for trigger
  excludedContexts?: string[]; // Contexts that prevent trigger
  cardId?: string; // Specific card to notify about
  message: string;
  isActive: boolean;
  cooldownMinutes: number; // Prevent spam notifications
  lastTriggered?: Date;
}

@Injectable()
export class LocationNotificationService {
  private userTriggers: Map<string, LocationTrigger[]> = new Map();

  constructor(
    @InjectQueue('notifications') private notificationsQueue: Queue,
    private prisma: PrismaService,
  ) {}

  async addLocationTrigger(trigger: LocationTrigger): Promise<void> {
    const userTriggers = this.userTriggers.get(trigger.userId) || [];
    userTriggers.push(trigger);
    this.userTriggers.set(trigger.userId, userTriggers);

    // Persist to database
    await this.prisma.locationTrigger.upsert({
      where: { id: trigger.id },
      update: trigger,
      create: trigger,
    });
  }

  async removeLocationTrigger(triggerId: string, userId: string): Promise<void> {
    const userTriggers = this.userTriggers.get(userId) || [];
    const filteredTriggers = userTriggers.filter(t => t.id !== triggerId);
    this.userTriggers.set(userId, filteredTriggers);

    // Remove from database
    await this.prisma.locationTrigger.delete({
      where: { id: triggerId },
    });
  }

  async processLocationUpdate(userId: string, locationContext: LocationContext): Promise<void> {
    const triggers = this.userTriggers.get(userId) || [];

    for (const trigger of triggers) {
      if (!trigger.isActive) continue;

      // Check cooldown
      if (trigger.lastTriggered) {
        const cooldownEnd = new Date(trigger.lastTriggered.getTime() + trigger.cooldownMinutes * 60 * 1000);
        if (new Date() < cooldownEnd) continue;
      }

      // Check if trigger conditions are met
      if (await this.evaluateTrigger(trigger, locationContext)) {
        await this.fireTrigger(trigger, locationContext);
      }
    }
  }

  private async evaluateTrigger(trigger: LocationTrigger, context: LocationContext): Promise<boolean> {
    // Check location-based conditions
    if (trigger.triggerType === 'geofence_entry' || trigger.triggerType === 'geofence_exit') {
      if (!trigger.location) return false;

      const distance = this.calculateDistance(
        context.latitude,
        context.longitude,
        trigger.location.latitude,
        trigger.location.longitude,
      );

      const isInside = distance <= trigger.location.radius;

      if (trigger.triggerType === 'geofence_entry' && !isInside) return false;
      if (trigger.triggerType === 'geofence_exit' && isInside) return false;
    }

    // Check context conditions
    if (trigger.contexts) {
      const hasRequiredContexts = trigger.contexts.every(ctx =>
        context.contexts.includes(ctx)
      );
      if (!hasRequiredContexts) return false;
    }

    if (trigger.excludedContexts) {
      const hasExcludedContexts = trigger.excludedContexts.some(ctx =>
        context.contexts.includes(ctx)
      );
      if (hasExcludedContexts) return false;
    }

    return true;
  }

  private async fireTrigger(trigger: LocationTrigger, context: LocationContext): Promise<void> {
    // Update last triggered time
    trigger.lastTriggered = new Date();
    await this.prisma.locationTrigger.update({
      where: { id: trigger.id },
      data: { lastTriggered: trigger.lastTriggered },
    });

    // Queue notification
    await this.notificationsQueue.add('location-notification', {
      userId: trigger.userId,
      message: trigger.message,
      cardId: trigger.cardId,
      locationContext: context,
      triggerId: trigger.id,
    });
  }

  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371e3; // Earth's radius in meters
    const φ1 = (lat1 * Math.PI) / 180;
    const φ2 = (lat2 * Math.PI) / 180;
    const Δφ = ((lat2 - lat1) * Math.PI) / 180;
    const Δλ = ((lon2 - lon1) * Math.PI) / 180;

    const a =
      Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
      Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
  }

  // Predefined location triggers for common scenarios
  async setupDefaultTriggers(userId: string): Promise<void> {
    const defaultTriggers: Omit<LocationTrigger, 'id'>[] = [
      {
        userId,
        triggerType: 'context_change',
        contexts: ['morning', 'weekday'],
        message: 'Good morning! Ready to start your day with a quick win?',
        isActive: true,
        cooldownMinutes: 60, // Once per hour
      },
      {
        userId,
        triggerType: 'context_change',
        contexts: ['evening', 'weekday'],
        message: 'Evening reflection: How did your day go? Take a moment to review.',
        isActive: true,
        cooldownMinutes: 120, // Once every 2 hours
      },
      {
        userId,
        triggerType: 'context_change',
        contexts: ['weekend', 'morning'],
        message: 'Weekend morning! How about a mindfulness practice to start your day?',
        isActive: true,
        cooldownMinutes: 180, // Once every 3 hours
      },
    ];

    for (const trigger of defaultTriggers) {
      await this.addLocationTrigger({
        ...trigger,
        id: `${userId}-${trigger.triggerType}-${trigger.contexts?.join('-')}`,
      });
    }
  }

  async getUserTriggers(userId: string): Promise<LocationTrigger[]> {
    return this.userTriggers.get(userId) || [];
  }
}
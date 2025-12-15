import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class SubscriptionsService {
  constructor(private prisma: PrismaService) {}

  async getSubscription(userId: string) {
    return this.prisma.subscription.findUnique({
      where: { userId },
    });
  }

  async updateSubscription(userId: string, data: any) {
    return this.prisma.subscription.upsert({
      where: { userId },
      update: data,
      create: {
        userId,
        ...data,
      },
    });
  }

  async upgradeToPremium(userId: string, productId: string) {
    return this.updateSubscription(userId, {
      tier: 'PREMIUM',
      status: 'ACTIVE',
      productId,
      startDate: new Date(),
    });
  }
}
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { CacheModule } from '@nestjs/cache-manager';
import { BullModule } from '@nestjs/bull';
import * as redisStore from 'cache-manager-redis-store';

import { DatabaseModule } from './database/database.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { CardsModule } from './modules/cards/cards.module';
import { AnalyticsModule } from './modules/analytics/analytics.module';
import { SubscriptionsModule } from './modules/subscriptions/subscriptions.module';
import { AiModule } from './modules/ai/ai.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),
    ThrottlerModule.forRoot({
      ttl: 60,
      limit: 100,
    }),
    CacheModule.register({
      isGlobal: true,
      store: redisStore,
      host: process.env.REDIS_HOST || 'localhost',
      port: process.env.REDIS_PORT || 6379,
    }),
    BullModule.forRoot({
      redis: {
        host: process.env.REDIS_HOST || 'localhost',
        port: process.env.REDIS_PORT || 6379,
      },
    }),
    DatabaseModule,
    AuthModule,
    UsersModule,
    CardsModule,
    AnalyticsModule,
    SubscriptionsModule,
    AiModule,
  ],
})
export class AppModule {}
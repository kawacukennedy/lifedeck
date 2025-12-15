import { Module } from '@nestjs/common';
import { SubscriptionsService } from './subscriptions.service';
import { StripeService } from './stripe.service';
import { SubscriptionsController } from './subscriptions.controller';

@Module({
  controllers: [SubscriptionsController],
  providers: [SubscriptionsService, StripeService],
})
export class SubscriptionsModule {}
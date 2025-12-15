import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { SubscriptionsService } from './subscriptions.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('subscriptions')
@UseGuards(JwtAuthGuard)
export class SubscriptionsController {
  constructor(private readonly subscriptionsService: SubscriptionsService) {}

  @Get()
  getSubscription(@Request() req) {
    return this.subscriptionsService.getSubscription(req.user.id);
  }

  @Post('upgrade')
  upgradeToPremium(@Request() req, @Body() body: { productId: string }) {
    return this.subscriptionsService.upgradeToPremium(req.user.id, body.productId);
  }

  @Post('webhook')
  handleWebhook(@Body() webhookData: any) {
    // Handle Stripe/webhook events
    console.log('Webhook received:', webhookData);
    return { received: true };
  }
}
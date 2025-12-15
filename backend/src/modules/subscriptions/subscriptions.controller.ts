import { Controller, Get, Post, Body, UseGuards, Request, Headers } from '@nestjs/common';
import { SubscriptionsService } from './subscriptions.service';
import { StripeService } from './stripe.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('subscriptions')
@UseGuards(JwtAuthGuard)
export class SubscriptionsController {
  constructor(
    private readonly subscriptionsService: SubscriptionsService,
    private readonly stripeService: StripeService,
  ) {}

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

  // Stripe Integration
  @Post('stripe/create-customer')
  @UseGuards(JwtAuthGuard)
  async createStripeCustomer(@Request() req, @Body() body: { paymentMethodId: string }) {
    const customer = await this.stripeService.createCustomer(req.user.email, req.user.name);
    return { customer };
  }

  @Post('stripe/create-subscription')
  @UseGuards(JwtAuthGuard)
  async createStripeSubscription(@Request() req, @Body() body: { customerId: string; priceId: string }) {
    const subscription = await this.stripeService.createSubscription(body.customerId, body.priceId);
    return { subscription };
  }

  @Post('stripe/webhook')
  async handleStripeWebhook(
    @Body() rawBody: Buffer,
    @Headers('stripe-signature') signature: string,
  ) {
    return await this.stripeService.handleWebhook(rawBody, signature);
  }

  @Get('stripe/products')
  getStripeProducts() {
    return {
      products: this.stripeService.lifedeckProducts,
    };
  }

  @Post('stripe/cancel')
  @UseGuards(JwtAuthGuard)
  async cancelStripeSubscription(@Body() body: { subscriptionId: string }) {
    const subscription = await this.stripeService.cancelSubscription(body.subscriptionId);
    return { subscription };
  }
}
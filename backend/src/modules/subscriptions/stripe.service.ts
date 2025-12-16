import { Injectable } from '@nestjs/common';
import Stripe from 'stripe';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class StripeService {
  private stripe: Stripe;

  constructor(private prisma: PrismaService) {
    this.stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
      apiVersion: '2023-10-16',
    });
  }

  async createCustomer(email: string, name?: string) {
    return await this.stripe.customers.create({
      email,
      name,
    });
  }

  async createSubscription(customerId: string, priceId: string) {
    return await this.stripe.subscriptions.create({
      customer: customerId,
      items: [{ price: priceId }],
      payment_behavior: 'default_incomplete',
      expand: ['latest_invoice.payment_intent'],
    });
  }

  async createPaymentIntent(amount: number, currency: string = 'usd') {
    return await this.stripe.paymentIntents.create({
      amount,
      currency,
    });
  }

  async getSubscription(subscriptionId: string) {
    return await this.stripe.subscriptions.retrieve(subscriptionId);
  }

  async cancelSubscription(subscriptionId: string) {
    return await this.stripe.subscriptions.update(subscriptionId, {
      cancel_at_period_end: true,
    });
  }

  async reactivateSubscription(subscriptionId: string) {
    return await this.stripe.subscriptions.update(subscriptionId, {
      cancel_at_period_end: false,
    });
  }

  async getCustomer(customerId: string) {
    return await this.stripe.customers.retrieve(customerId);
  }

  async getCustomerSubscriptions(customerId: string) {
    return await this.stripe.subscriptions.list({
      customer: customerId,
      status: 'active',
    });
  }

  async createPrice(amount: number, currency: string = 'usd', interval: 'month' | 'year' = 'month') {
    return await this.stripe.prices.create({
      unit_amount: amount,
      currency,
      recurring: {
        interval,
      },
      product_data: {
        name: `LifeDeck Premium ${interval.charAt(0).toUpperCase() + interval.slice(1)}ly`,
      },
    });
  }

  async handleWebhook(rawBody: Buffer, signature: string) {
    const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET!;
    let event: Stripe.Event;

    try {
      event = this.stripe.webhooks.constructEvent(rawBody, signature, endpointSecret);
    } catch (err) {
      throw new Error(`Webhook signature verification failed: ${err.message}`);
    }

    // Handle the event
    switch (event.type) {
      case 'customer.subscription.created':
        await this.handleSubscriptionCreated(event.data.object as Stripe.Subscription);
        break;
      case 'customer.subscription.updated':
        await this.handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
        break;
      case 'customer.subscription.deleted':
        await this.handleSubscriptionDeleted(event.data.object as Stripe.Subscription);
        break;
      case 'invoice.payment_succeeded':
        await this.handlePaymentSucceeded(event.data.object as Stripe.Invoice);
        break;
      case 'invoice.payment_failed':
        await this.handlePaymentFailed(event.data.object as Stripe.Invoice);
        break;
      default:
        console.log(`Unhandled event type ${event.type}`);
    }

    return { received: true };
  }

  private async handleSubscriptionCreated(subscription: Stripe.Subscription) {
    console.log('Subscription created:', subscription.id);

    // Find user by customer ID
    const customer = await this.stripe.customers.retrieve(subscription.customer as string) as Stripe.Customer;
    const user = await this.prisma.user.findUnique({
      where: { email: customer.email! },
    });

    if (!user) {
      console.error('User not found for subscription:', subscription.id);
      return;
    }

    // Update subscription in database
    await this.prisma.subscription.upsert({
      where: { userId: user.id },
      update: {
        tier: 'PREMIUM',
        status: 'ACTIVE',
        startDate: new Date(subscription.current_period_start * 1000),
        expiryDate: new Date(subscription.current_period_end * 1000),
        autoRenewEnabled: !subscription.cancel_at_period_end,
        productId: subscription.items.data[0]?.price.id,
        transactionId: subscription.id,
        updatedAt: new Date(),
      },
      create: {
        userId: user.id,
        tier: 'PREMIUM',
        status: 'ACTIVE',
        startDate: new Date(subscription.current_period_start * 1000),
        expiryDate: new Date(subscription.current_period_end * 1000),
        autoRenewEnabled: !subscription.cancel_at_period_end,
        productId: subscription.items.data[0]?.price.id,
        transactionId: subscription.id,
      },
    });

    // Update user tier
    await this.prisma.user.update({
      where: { id: user.id },
      data: { subscriptionTier: 'PREMIUM' },
    });
  }

  private async handleSubscriptionUpdated(subscription: Stripe.Subscription) {
    console.log('Subscription updated:', subscription.id);

    const existingSubscription = await this.prisma.subscription.findUnique({
      where: { transactionId: subscription.id },
    });

    if (!existingSubscription) {
      console.error('Subscription not found in database:', subscription.id);
      return;
    }

    // Update subscription status
    let status: string;
    switch (subscription.status) {
      case 'active':
        status = 'ACTIVE';
        break;
      case 'canceled':
        status = subscription.cancel_at_period_end ? 'PENDING_CANCELLATION' : 'CANCELLED';
        break;
      case 'incomplete':
        status = 'PENDING';
        break;
      case 'incomplete_expired':
        status = 'EXPIRED';
        break;
      case 'past_due':
        status = 'IN_GRACE_PERIOD';
        break;
      case 'unpaid':
        status = 'EXPIRED';
        break;
      default:
        status = 'ACTIVE';
    }

    await this.prisma.subscription.update({
      where: { transactionId: subscription.id },
      data: {
        status,
        expiryDate: new Date(subscription.current_period_end * 1000),
        autoRenewEnabled: !subscription.cancel_at_period_end,
        updatedAt: new Date(),
      },
    });

    // Update user tier if subscription is no longer active
    if (status !== 'ACTIVE') {
      await this.prisma.user.update({
        where: { id: existingSubscription.userId },
        data: { subscriptionTier: 'FREE' },
      });
    }
  }

  private async handleSubscriptionDeleted(subscription: Stripe.Subscription) {
    console.log('Subscription deleted:', subscription.id);

    const existingSubscription = await this.prisma.subscription.findUnique({
      where: { transactionId: subscription.id },
    });

    if (!existingSubscription) {
      console.error('Subscription not found in database:', subscription.id);
      return;
    }

    await this.prisma.subscription.update({
      where: { transactionId: subscription.id },
      data: {
        status: 'CANCELLED',
        expiryDate: new Date(), // Expired now
        autoRenewEnabled: false,
        updatedAt: new Date(),
      },
    });

    // Downgrade user to free tier
    await this.prisma.user.update({
      where: { id: existingSubscription.userId },
      data: { subscriptionTier: 'FREE' },
    });
  }

  private async handlePaymentSucceeded(invoice: Stripe.Invoice) {
    console.log('Payment succeeded for invoice:', invoice.id);

    if (invoice.subscription) {
      // This is a subscription payment
      const subscription = await this.prisma.subscription.findUnique({
        where: { transactionId: invoice.subscription as string },
      });

      if (subscription) {
        // Update subscription expiry date
        const stripeSub = await this.stripe.subscriptions.retrieve(invoice.subscription as string);
        await this.prisma.subscription.update({
          where: { transactionId: invoice.subscription as string },
          data: {
            expiryDate: new Date(stripeSub.current_period_end * 1000),
            updatedAt: new Date(),
          },
        });
      }
    }
  }

  private async handlePaymentFailed(invoice: Stripe.Invoice) {
    console.log('Payment failed for invoice:', invoice.id);

    if (invoice.subscription) {
      // Mark subscription as in grace period or expired
      await this.prisma.subscription.update({
        where: { transactionId: invoice.subscription as string },
        data: {
          status: 'IN_GRACE_PERIOD',
          updatedAt: new Date(),
        },
      });
    }
  }

  // Product and Price IDs for LifeDeck
  get lifedeckProducts() {
    return {
      monthly: {
        id: process.env.STRIPE_PRICE_MONTHLY || 'price_monthly_placeholder',
        amount: 799, // $7.99
      },
      yearly: {
        id: process.env.STRIPE_PRICE_YEARLY || 'price_yearly_placeholder',
        amount: 7999, // $79.99
      },
    };
  }
}
import { Injectable } from '@nestjs/common';
import Stripe from 'stripe';

@Injectable()
export class StripeService {
  private stripe: Stripe;

  constructor() {
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
    // Update user subscription status in database
  }

  private async handleSubscriptionUpdated(subscription: Stripe.Subscription) {
    console.log('Subscription updated:', subscription.id);
    // Update user subscription status in database
  }

  private async handleSubscriptionDeleted(subscription: Stripe.Subscription) {
    console.log('Subscription deleted:', subscription.id);
    // Update user subscription status in database
  }

  private async handlePaymentSucceeded(invoice: Stripe.Invoice) {
    console.log('Payment succeeded for invoice:', invoice.id);
    // Handle successful payment
  }

  private async handlePaymentFailed(invoice: Stripe.Invoice) {
    console.log('Payment failed for invoice:', invoice.id);
    // Handle failed payment
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
import React, { useState } from 'react';
import { CardElement, useStripe, useElements } from '@stripe/react-stripe-js';
import { apiService } from '../lib/api';
import { Button } from './ButtonStyles'; // Assuming you have a Button component

interface StripePaymentFormProps {
  priceId: string;
  onSuccess: (subscription: any) => void;
  onError: (error: string) => void;
  disabled?: boolean;
}

const CARD_ELEMENT_OPTIONS = {
  style: {
    base: {
      color: '#32325d',
      fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
      fontSmoothing: 'antialiased',
      fontSize: '16px',
      '::placeholder': {
        color: '#aab7c4',
      },
    },
    invalid: {
      color: '#fa755a',
      iconColor: '#fa755a',
    },
  },
};

export default function StripePaymentForm({
  priceId,
  onSuccess,
  onError,
  disabled = false,
}: StripePaymentFormProps) {
  const stripe = useStripe();
  const elements = useElements();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();

    if (!stripe || !elements) {
      onError('Stripe has not loaded yet.');
      return;
    }

    const cardElement = elements.getElement(CardElement);
    if (!cardElement) {
      onError('Card element not found.');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      // Create payment method
      const { error: paymentMethodError, paymentMethod } = await stripe.createPaymentMethod({
        type: 'card',
        card: cardElement,
      });

      if (paymentMethodError) {
        throw new Error(paymentMethodError.message || 'Failed to create payment method');
      }

      // Create customer with payment method
      const customerResponse = await apiService.createStripeCustomer(paymentMethod.id);
      const customerId = customerResponse.customer.id;

      // Create subscription
      const subscriptionResponse = await apiService.createStripeSubscription(customerId, priceId);
      const subscription = subscriptionResponse.subscription;

      // Confirm payment if required
      if (subscription.latest_invoice.payment_intent) {
        const { error: confirmError } = await stripe.confirmCardPayment(
          subscription.latest_invoice.payment_intent.client_secret
        );

        if (confirmError) {
          throw new Error(confirmError.message || 'Payment confirmation failed');
        }
      }

      onSuccess(subscription);
    } catch (err: any) {
      const errorMessage = err.message || 'An error occurred during payment processing';
      setError(errorMessage);
      onError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <label className="block text-sm font-medium text-lifedeck-text">
          Card Information
        </label>
        <div className="p-3 border border-lifedeck-border rounded-lg bg-lifedeck-surface">
          <CardElement options={CARD_ELEMENT_OPTIONS} />
        </div>
      </div>

      {error && (
        <div className="p-3 bg-red-50 border border-red-200 rounded-lg">
          <p className="text-red-600 text-sm">{error}</p>
        </div>
      )}

      <Button
        type="submit"
        disabled={!stripe || loading || disabled}
        className="w-full"
      >
        {loading ? 'Processing...' : 'Subscribe Now'}
      </Button>

      <p className="text-xs text-lifedeck-textSecondary text-center">
        Your payment information is secure and encrypted.
        You can cancel anytime.
      </p>
    </form>
  );
}
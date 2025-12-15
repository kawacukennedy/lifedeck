import { Injectable } from '@nestjs/common';
import { Configuration, PlaidApi, PlaidEnvironments } from 'plaid';

@Injectable()
export class PlaidService {
  private plaidClient: PlaidApi;

  constructor() {
    const configuration = new Configuration({
      basePath: PlaidEnvironments.sandbox, // Change to 'development' or 'production' as needed
      baseOptions: {
        headers: {
          'PLAID-CLIENT-ID': process.env.PLAID_CLIENT_ID,
          'PLAID-SECRET': process.env.PLAID_SECRET,
        },
      },
    });

    this.plaidClient = new PlaidApi(configuration);
  }

  async createLinkToken(userId: string): Promise<string> {
    try {
      const response = await this.plaidClient.linkTokenCreate({
        user: {
          client_user_id: userId,
        },
        client_name: 'LifeDeck',
        products: ['transactions'],
        country_codes: ['US'],
        language: 'en',
      });

      return response.data.link_token;
    } catch (error) {
      console.error('Failed to create Plaid link token:', error);
      throw error;
    }
  }

  async exchangePublicToken(publicToken: string): Promise<string> {
    try {
      const response = await this.plaidClient.itemPublicTokenExchange({
        public_token: publicToken,
      });

      return response.data.access_token;
    } catch (error) {
      console.error('Failed to exchange public token:', error);
      throw error;
    }
  }

  async getTransactions(accessToken: string, startDate: string, endDate: string) {
    try {
      const response = await this.plaidClient.transactionsGet({
        access_token: accessToken,
        start_date: startDate,
        end_date: endDate,
      });

      return response.data.transactions;
    } catch (error) {
      console.error('Failed to get transactions:', error);
      throw error;
    }
  }

  async getAccountBalances(accessToken: string) {
    try {
      const response = await this.plaidClient.accountsBalanceGet({
        access_token: accessToken,
      });

      return response.data.accounts;
    } catch (error) {
      console.error('Failed to get account balances:', error);
      throw error;
    }
  }

  async getSpendingInsights(accessToken: string, days: number = 30) {
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(endDate.getDate() - days);

    const transactions = await this.getTransactions(
      accessToken,
      startDate.toISOString().split('T')[0],
      endDate.toISOString().split('T')[0],
    );

    // Analyze spending patterns
    const insights = {
      totalSpent: 0,
      categories: {} as Record<string, number>,
      largestTransaction: null as any,
      averageTransaction: 0,
      transactionCount: transactions.length,
      spendingByDay: {} as Record<string, number>,
    };

    transactions.forEach(transaction => {
      if (transaction.amount > 0) { // Only count expenses (positive amounts in Plaid)
        insights.totalSpent += transaction.amount;

        // Category analysis
        const category = transaction.category?.[0] || 'Other';
        insights.categories[category] = (insights.categories[category] || 0) + transaction.amount;

        // Largest transaction
        if (!insights.largestTransaction || transaction.amount > insights.largestTransaction.amount) {
          insights.largestTransaction = transaction;
        }

        // Daily spending
        const date = transaction.date;
        insights.spendingByDay[date] = (insights.spendingByDay[date] || 0) + transaction.amount;
      }
    });

    insights.averageTransaction = insights.totalSpent / Math.max(insights.transactionCount, 1);

    return insights;
  }

  async getBudgetRecommendations(accessToken: string) {
    const insights = await this.getSpendingInsights(accessToken, 90); // 3 months

    const recommendations = [];

    // Analyze spending categories
    const topCategories = Object.entries(insights.categories)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 3);

    for (const [category, amount] of topCategories) {
      if (amount > insights.totalSpent * 0.3) { // If category > 30% of spending
        recommendations.push({
          type: 'reduce_spending',
          category,
          message: `Consider reducing spending in ${category}. It represents ${(amount / insights.totalSpent * 100).toFixed(1)}% of your expenses.`,
          potentialSavings: amount * 0.1, // Suggest 10% reduction
        });
      }
    }

    // Check for impulse spending patterns
    const dailySpending = Object.values(insights.spendingByDay);
    const avgDaily = dailySpending.reduce((a, b) => a + b, 0) / dailySpending.length;
    const highSpendingDays = dailySpending.filter(amount => amount > avgDaily * 2).length;

    if (highSpendingDays > 7) { // More than 7 high-spending days in the period
      recommendations.push({
        type: 'budget_planning',
        message: 'Consider creating a daily spending limit to avoid impulse purchases.',
        potentialSavings: avgDaily * 0.2, // Suggest 20% reduction in high-spending days
      });
    }

    return recommendations;
  }
}
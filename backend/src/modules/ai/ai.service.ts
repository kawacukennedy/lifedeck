import { Injectable, Inject } from '@nestjs/common';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';
import OpenAI from 'openai';
import { LifeDomain } from '@prisma/client';

@Injectable()
export class AiService {
  private openai: OpenAI;

  constructor(
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });
  }

  async generatePersonalizedCard(
    userId: string,
    domain: LifeDomain,
    userContext: any = {},
  ) {
    // Create cache key based on user context and domain
    const contextHash = this.hashUserContext(userContext);
    const cacheKey = `ai-card-${domain}-${contextHash}`;

    // Check cache first
    const cachedCard = await this.cacheManager.get(cacheKey);
    if (cachedCard) {
      return cachedCard;
    }

    const prompt = this.buildCardGenerationPrompt(domain, userContext);

    try {
      const completion = await this.openai.chat.completions.create({
        model: 'gpt-4',
        messages: [
          {
            role: 'system',
            content: 'You are an AI life coach that creates personalized, actionable micro-coaching cards. Each card should be specific, achievable in 5-15 minutes, and focused on sustainable habit building.',
          },
          {
            role: 'user',
            content: prompt,
          },
        ],
        max_tokens: 500,
        temperature: 0.7,
      });

      const response = completion.choices[0]?.message?.content;
      if (!response) throw new Error('No response from OpenAI');

      const card = this.parseCardResponse(response, domain);

      // Cache the result for 24 hours
      await this.cacheManager.set(cacheKey, card, 24 * 60 * 60 * 1000);

      return card;
    } catch (error) {
      console.error('AI card generation failed:', error);
      // Fallback to template-based cards
      const fallbackCard = this.generateFallbackCard(domain);

      // Cache fallback for shorter time (1 hour)
      await this.cacheManager.set(cacheKey, fallbackCard, 60 * 60 * 1000);

      return fallbackCard;
    }
  }

  async generateDailyCardSet(userId: string, userContext: any = {}) {
    const domains: LifeDomain[] = ['HEALTH', 'FINANCE', 'PRODUCTIVITY', 'MINDFULNESS'];
    const cards = [];

    for (const domain of domains) {
      const card = await this.generatePersonalizedCard(userId, domain, userContext);
      cards.push(card);
    }

    return cards;
  }

  private buildCardGenerationPrompt(domain: LifeDomain, userContext: any): string {
    const domainContext = {
      HEALTH: 'physical wellness, exercise, nutrition, sleep, or stress management',
      FINANCE: 'budgeting, saving, investing, spending habits, or financial planning',
      PRODUCTIVITY: 'time management, focus, task completion, or work efficiency',
      MINDFULNESS: 'meditation, gratitude, presence, or emotional awareness',
    };

    return `Create a personalized coaching card for the ${domain.toLowerCase()} domain.

User context: ${JSON.stringify(userContext)}

Requirements:
- Title: Catchy and motivating (max 50 chars)
- Description: Brief explanation (max 100 chars) 
- Action: Specific, actionable step (max 200 chars)
- Tips: 2-3 helpful implementation tips
- Benefits: 2-3 expected outcomes
- Type: quick (1-2 min), standard (5-15 min), or extended (30+ min)
- Priority: low, medium, or high based on user needs

Focus on ${domainContext[domain]}.

Make it personal, achievable, and immediately actionable.`;
  }

  private parseCardResponse(response: string, domain: LifeDomain) {
    // Parse the AI response and structure it as a card
    // This is a simplified parser - in production you'd use more robust parsing
    const lines = response.split('\n').filter(line => line.trim());

    const card = {
      title: this.extractField(lines, 'Title:') || `Improve Your ${domain}`,
      description: this.extractField(lines, 'Description:') || `Take action in ${domain.toLowerCase()}`,
      actionText: this.extractField(lines, 'Action:') || 'Complete this task',
      domain,
      actionType: this.extractActionType(response),
      priority: this.extractPriority(response),
      tips: this.extractList(lines, 'Tips:'),
      benefits: this.extractList(lines, 'Benefits:'),
      aiGenerated: true,
    };

    return card;
  }

  private extractField(lines: string[], fieldName: string): string | null {
    const line = lines.find(line => line.startsWith(fieldName));
    return line ? line.replace(fieldName, '').trim() : null;
  }

  private extractList(lines: string[], fieldName: string): string[] {
    const startIndex = lines.findIndex(line => line.startsWith(fieldName));
    if (startIndex === -1) return [];

    const list = [];
    for (let i = startIndex + 1; i < lines.length; i++) {
      const line = lines[i].trim();
      if (line.startsWith('- ') || line.startsWith('• ')) {
        list.push(line.substring(2));
      } else if (line && !line.includes(':')) {
        list.push(line);
      } else {
        break;
      }
    }
    return list;
  }

  private extractActionType(response: string): string {
    if (response.toLowerCase().includes('quick') || response.toLowerCase().includes('1-2 min')) {
      return 'QUICK';
    } else if (response.toLowerCase().includes('extended') || response.toLowerCase().includes('30+')) {
      return 'EXTENDED';
    }
    return 'STANDARD';
  }

  private extractPriority(response: string): string {
    if (response.toLowerCase().includes('high priority') || response.toLowerCase().includes('urgent')) {
      return 'HIGH';
    } else if (response.toLowerCase().includes('low priority')) {
      return 'LOW';
    }
    return 'MEDIUM';
  }

  private hashUserContext(userContext: any): string {
    // Create a simple hash of relevant user context for caching
    const relevantKeys = ['progress', 'settings', 'subscriptionTier'];
    const contextString = relevantKeys
      .map(key => {
        const value = userContext[key];
        return value ? JSON.stringify(value) : '';
      })
      .join('|');

    // Simple hash function
    let hash = 0;
    for (let i = 0; i < contextString.length; i++) {
      const char = contextString.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return Math.abs(hash).toString();
  }

  private generateFallbackCard(domain: LifeDomain) {
    const fallbackCards = {
      HEALTH: {
        title: 'Take a Mindful Walk',
        description: 'Step outside for a 10-minute walk and focus on your breathing',
        actionText: 'Walk for 10 minutes outside',
        tips: ['Leave your phone behind', 'Focus on your breathing', 'Notice your surroundings'],
        benefits: ['Improves cardiovascular health', 'Reduces stress', 'Boosts mood'],
        actionType: 'STANDARD',
        priority: 'MEDIUM',
      },
      FINANCE: {
        title: 'Review Yesterday\'s Expenses',
        description: 'Take 5 minutes to review what you spent money on yesterday',
        actionText: 'Review and categorize yesterday\'s spending',
        tips: ['Use your banking app', 'Look for unnecessary purchases', 'Note spending patterns'],
        benefits: ['Increases spending awareness', 'Helps identify waste', 'Improves budgeting'],
        actionType: 'STANDARD',
        priority: 'MEDIUM',
      },
      PRODUCTIVITY: {
        title: 'Clear Your Desk',
        description: 'Spend 5 minutes organizing your workspace for better focus',
        actionText: 'Organize and clear your desk',
        tips: ['Keep only essentials visible', 'Use organizers for supplies'],
        benefits: ['Reduces distractions', 'Improves focus', 'Creates calm environment'],
        actionType: 'QUICK',
        priority: 'MEDIUM',
      },
      MINDFULNESS: {
        title: 'Take 5 Deep Breaths',
        description: 'Pause and take five slow, intentional breaths',
        actionText: 'Complete 5 deep breathing cycles',
        tips: ['Inhale for 4 counts', 'Hold for 2 counts', 'Exhale for 6 counts'],
        benefits: ['Reduces stress', 'Improves focus', 'Calms nervous system'],
        actionType: 'QUICK',
        priority: 'MEDIUM',
      },
    };

    return {
      ...fallbackCards[domain],
      domain,
      aiGenerated: false,
    };
  }
}
import { Test, TestingModule } from '@nestjs/testing';
import { AiService } from './ai.service';

describe('AiService', () => {
  let service: AiService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AiService],
    }).compile();

    service = module.get<AiService>(AiService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('generatePersonalizedCard', () => {
    it('should generate a card with required fields', async () => {
      const userId = 'test-user-id';
      const domain = 'HEALTH' as any;
      const context = { currentStreak: 5, healthScore: 70 };

      // Mock the OpenAI response
      jest.spyOn(service as any, 'openai').mockImplementation({
        chat: {
          completions: {
            create: jest.fn().mockResolvedValue({
              choices: [{
                message: {
                  content: `Title: Take a Mindful Walk
Description: Step outside for a 10-minute walk and focus on your breathing
Action: Walk for 10 minutes outside
Tips: - Leave your phone behind
- Focus on your breathing
Benefits: - Improves cardiovascular health
- Reduces stress
Type: quick
Priority: medium`
                }
              }]
            })
          }
        }
      });

      const result = await service.generatePersonalizedCard(userId, domain, context);

      expect(result).toHaveProperty('title');
      expect(result).toHaveProperty('description');
      expect(result).toHaveProperty('actionText');
      expect(result).toHaveProperty('domain', domain);
      expect(result).toHaveProperty('tips');
      expect(result).toHaveProperty('benefits');
      expect(result).toHaveProperty('aiGenerated', true);
    });

    it('should fallback to template card on AI failure', async () => {
      const userId = 'test-user-id';
      const domain = 'HEALTH' as any;

      // Mock OpenAI to throw error
      jest.spyOn(service as any, 'openai').mockImplementation({
        chat: {
          completions: {
            create: jest.fn().mockRejectedValue(new Error('API Error'))
          }
        }
      });

      const result = await service.generatePersonalizedCard(userId, domain);

      expect(result).toHaveProperty('title');
      expect(result).toHaveProperty('description');
      expect(result).toHaveProperty('domain', domain);
      expect(result).toHaveProperty('aiGenerated', false);
    });
  });

  describe('generateDailyCardSet', () => {
    it('should generate cards for all domains', async () => {
      const userId = 'test-user-id';
      const domains = ['HEALTH', 'FINANCE', 'PRODUCTIVITY', 'MINDFULNESS'];

      // Mock generatePersonalizedCard
      const mockCard = {
        title: 'Test Card',
        description: 'Test description',
        actionText: 'Test action',
        domain: 'HEALTH' as any,
        tips: ['Tip 1'],
        benefits: ['Benefit 1'],
        aiGenerated: true,
      };

      jest.spyOn(service, 'generatePersonalizedCard').mockResolvedValue(mockCard);

      const result = await service.generateDailyCardSet(userId);

      expect(result).toHaveLength(domains.length);
      expect(result.every(card => card.title === 'Test Card')).toBe(true);
    });
  });

  describe('Card parsing utilities', () => {
    it('should extract field from text', () => {
      const lines = ['Title: Test Title', 'Description: Test Description'];
      const result = (service as any).extractField(lines, 'Title:');
      expect(result).toBe('Test Title');
    });

    it('should extract list items', () => {
      const lines = ['Tips:', '- Tip 1', '- Tip 2', 'Benefits:'];
      const result = (service as any).extractList(lines, 'Tips:');
      expect(result).toEqual(['Tip 1', 'Tip 2']);
    });

    it('should determine action type', () => {
      expect((service as any).extractActionType('quick action')).toBe('QUICK');
      expect((service as any).extractActionType('extended task')).toBe('EXTENDED');
      expect((service as any).extractActionType('standard activity')).toBe('STANDARD');
    });

    it('should determine priority', () => {
      expect((service as any).extractPriority('high priority')).toBe('HIGH');
      expect((service as any).extractPriority('low priority')).toBe('LOW');
      expect((service as any).extractPriority('normal task')).toBe('MEDIUM');
    });
  });
});
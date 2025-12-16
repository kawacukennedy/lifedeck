import { Test, TestingModule } from '@nestjs/testing';
import { CardsService } from './cards.service';
import { PrismaService } from '../../database/prisma.service';
import { AiService } from '../ai/ai.service';

describe('CardsService', () => {
  let service: CardsService;
  let prismaService: PrismaService;
  let aiService: AiService;

  const mockPrismaService = {
    user: {
      findUnique: jest.fn(),
    },
    card: {
      create: jest.fn(),
      findMany: jest.fn(),
      update: jest.fn(),
    },
    userProgress: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
  };

  const mockAiService = {
    generateDailyCardSet: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CardsService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
        {
          provide: AiService,
          useValue: mockAiService,
        },
      ],
    }).compile();

    service = module.get<CardsService>(CardsService);
    prismaService = module.get<PrismaService>(PrismaService);
    aiService = module.get<AiService>(AiService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findDailyCards', () => {
    it('should return existing cards if available', async () => {
      const userId = 'test-user';
      const existingCards = [
        { id: '1', title: 'Test Card', status: 'PENDING' },
      ];

      mockPrismaService.user.findUnique.mockResolvedValue({
        id: userId,
        subscriptionTier: 'FREE',
        settings: {},
        progress: {},
      });

      mockPrismaService.card.findMany.mockResolvedValue(existingCards);

      const result = await service.findDailyCards(userId);

      expect(result).toEqual(existingCards);
      expect(mockAiService.generateDailyCardSet).not.toHaveBeenCalled();
    });

    it('should generate new cards when none exist', async () => {
      const userId = 'test-user';
      const aiCards = [
        {
          title: 'AI Generated Card',
          description: 'Test description',
          actionText: 'Test action',
          domain: 'HEALTH',
          tips: ['Tip 1'],
          benefits: ['Benefit 1'],
        },
      ];

      mockPrismaService.user.findUnique.mockResolvedValue({
        id: userId,
        subscriptionTier: 'FREE',
        settings: {},
        progress: {},
      });

      mockPrismaService.card.findMany.mockResolvedValue([]);
      mockAiService.generateDailyCardSet.mockResolvedValue(aiCards);
      mockPrismaService.card.create.mockImplementation((data) =>
        Promise.resolve({ ...data.data, id: 'new-id', createdAt: new Date() })
      );

      const result = await service.findDailyCards(userId);

      expect(result).toHaveLength(1);
      expect(result[0].title).toBe('AI Generated Card');
      expect(mockAiService.generateDailyCardSet).toHaveBeenCalledWith(
        userId,
        expect.objectContaining({
          subscriptionTier: 'FREE',
        })
      );
    });

    it('should limit free users to 3 cards per day', async () => {
      const userId = 'test-user';
      const aiCards = Array(5).fill({
        title: 'Card',
        description: 'Desc',
        actionText: 'Action',
        domain: 'HEALTH',
        tips: [],
        benefits: [],
      });

      mockPrismaService.user.findUnique.mockResolvedValue({
        id: userId,
        subscriptionTier: 'FREE',
        settings: {},
        progress: {},
      });

      mockPrismaService.card.findMany.mockResolvedValue([]);
      mockAiService.generateDailyCardSet.mockResolvedValue(aiCards);
      mockPrismaService.card.create.mockImplementation((data) =>
        Promise.resolve({ ...data.data, id: 'new-id', createdAt: new Date() })
      );

      const result = await service.findDailyCards(userId);

      expect(result).toHaveLength(3); // Limited to 3 for free users
    });

    it('should allow premium users unlimited cards', async () => {
      const userId = 'test-user';
      const aiCards = Array(8).fill({
        title: 'Card',
        description: 'Desc',
        actionText: 'Action',
        domain: 'HEALTH',
        tips: [],
        benefits: [],
      });

      mockPrismaService.user.findUnique.mockResolvedValue({
        id: userId,
        subscriptionTier: 'PREMIUM',
        settings: {},
        progress: {},
      });

      mockPrismaService.card.findMany.mockResolvedValue([]);
      mockAiService.generateDailyCardSet.mockResolvedValue(aiCards);
      mockPrismaService.card.create.mockImplementation((data) =>
        Promise.resolve({ ...data.data, id: 'new-id', createdAt: new Date() })
      );

      const result = await service.findDailyCards(userId);

      expect(result).toHaveLength(8); // No limit for premium users
    });
  });

  describe('completeCard', () => {
    it('should update card status and user progress', async () => {
      const cardId = 'test-card';
      const userId = 'test-user';
      const card = {
        id: cardId,
        domain: 'HEALTH',
        status: 'PENDING',
      };

      mockPrismaService.card.update.mockResolvedValue({
        ...card,
        status: 'COMPLETED',
        completedAt: new Date(),
      });

      mockPrismaService.userProgress.findUnique.mockResolvedValue({
        userId,
        healthScore: 50,
        totalCardsCompleted: 5,
        lifePoints: 100,
      });

      mockPrismaService.userProgress.update.mockResolvedValue({});

      const result = await service.completeCard(cardId, userId);

      expect(result.status).toBe('COMPLETED');
      expect(mockPrismaService.userProgress.update).toHaveBeenCalledWith({
        where: { userId },
        data: expect.objectContaining({
          healthScore: 55, // 50 + 5
          totalCardsCompleted: 6, // 5 + 1
          lifePoints: 110, // 100 + 10
        }),
      });
    });

    it('should create user progress if none exists', async () => {
      const cardId = 'test-card';
      const userId = 'test-user';

      mockPrismaService.card.update.mockResolvedValue({
        id: cardId,
        domain: 'HEALTH',
        status: 'COMPLETED',
        completedAt: new Date(),
      });

      mockPrismaService.userProgress.findUnique.mockResolvedValue(null);
      mockPrismaService.userProgress.create.mockResolvedValue({});

      await service.completeCard(cardId, userId);

      expect(mockPrismaService.userProgress.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          userId,
          healthScore: 10,
          totalCardsCompleted: 1,
          lifePoints: 10,
        }),
      });
    });
  });
});
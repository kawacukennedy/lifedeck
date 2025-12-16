import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/database/prisma.service';

describe('Cards (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let authToken: string;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    prisma = moduleFixture.get<PrismaService>(PrismaService);

    await app.init();

    // Create test user and get auth token
    const testUser = await prisma.user.create({
      data: {
        email: 'test@example.com',
        name: 'Test User',
        password: 'hashedpassword',
      },
    });

    // Mock JWT token generation (in real test, you'd authenticate properly)
    authToken = 'mock-jwt-token-for-user-' + testUser.id;
  });

  afterEach(async () => {
    await prisma.user.deleteMany();
    await prisma.card.deleteMany();
    await app.close();
  });

  describe('/cards/daily (GET)', () => {
    it('should return daily cards for authenticated user', () => {
      return request(app.getHttpServer())
        .get('/v1/cards/daily')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)
        .expect((res) => {
          expect(Array.isArray(res.body)).toBe(true);
        });
    });

    it('should return 401 for unauthenticated request', () => {
      return request(app.getHttpServer())
        .get('/v1/cards/daily')
        .expect(401);
    });
  });

  describe('/cards (POST)', () => {
    it('should create a new card', () => {
      const cardData = {
        title: 'Test Card',
        description: 'Test description',
        actionText: 'Test action',
        domain: 'HEALTH',
        actionType: 'STANDARD',
        priority: 'MEDIUM',
        icon: 'heart',
        tips: ['Tip 1'],
        benefits: ['Benefit 1'],
      };

      return request(app.getHttpServer())
        .post('/v1/cards')
        .set('Authorization', `Bearer ${authToken}`)
        .send(cardData)
        .expect(201)
        .expect((res) => {
          expect(res.body).toHaveProperty('id');
          expect(res.body.title).toBe(cardData.title);
          expect(res.body.domain).toBe(cardData.domain);
        });
    });
  });

  describe('/cards/:id/complete (PATCH)', () => {
    it('should complete a card and update progress', async () => {
      // Create a test card
      const card = await prisma.card.create({
        data: {
          title: 'Test Card',
          description: 'Test description',
          actionText: 'Test action',
          domain: 'HEALTH',
          userId: (await prisma.user.findFirst())!.id,
        },
      });

      return request(app.getHttpServer())
        .patch(`/v1/cards/${card.id}/complete`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)
        .expect((res) => {
          expect(res.body.status).toBe('COMPLETED');
          expect(res.body.completedAt).toBeDefined();
        });
    });

    it('should return 404 for non-existent card', () => {
      return request(app.getHttpServer())
        .patch('/v1/cards/non-existent-id/complete')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);
    });
  });
});
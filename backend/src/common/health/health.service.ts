import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { LoggerService } from '../logging/logger.service';

interface HealthCheckResult {
  status: 'ok' | 'error';
  timestamp: Date;
  uptime: number;
  memory: NodeJS.MemoryUsage;
  database: {
    status: 'ok' | 'error';
    responseTime?: number;
  };
  redis?: {
    status: 'ok' | 'error';
    responseTime?: number;
  };
  openai?: {
    status: 'ok' | 'error';
    responseTime?: number;
  };
}

@Injectable()
export class HealthService {
  constructor(
    private prisma: PrismaService,
    private logger: LoggerService,
  ) {}

  async getHealthStatus(): Promise<HealthCheckResult> {
    const startTime = Date.now();
    const result: HealthCheckResult = {
      status: 'ok',
      timestamp: new Date(),
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      database: await this.checkDatabase(),
    };

    // Check Redis if available
    if (process.env.REDIS_HOST) {
      result.redis = await this.checkRedis();
    }

    // Check OpenAI if API key is configured
    if (process.env.OPENAI_API_KEY) {
      result.openai = await this.checkOpenAI();
    }

    const totalTime = Date.now() - startTime;
    this.logger.logPerformance('health_check_duration', totalTime);

    // Set overall status
    if (
      result.database.status === 'error' ||
      result.redis?.status === 'error' ||
      result.openai?.status === 'error'
    ) {
      result.status = 'error';
    }

    return result;
  }

  private async checkDatabase(): Promise<{ status: 'ok' | 'error'; responseTime?: number }> {
    const startTime = Date.now();

    try {
      await this.prisma.$queryRaw`SELECT 1`;
      const responseTime = Date.now() - startTime;

      this.logger.logDatabaseOperation('health_check', 'health', responseTime, true);

      return {
        status: 'ok',
        responseTime,
      };
    } catch (error) {
      const responseTime = Date.now() - startTime;

      this.logger.error('Database health check failed', error as Error, {
        operation: 'health_check',
      });

      return {
        status: 'error',
        responseTime,
      };
    }
  }

  private async checkRedis(): Promise<{ status: 'ok' | 'error'; responseTime?: number }> {
    const startTime = Date.now();

    try {
      // TODO: Implement Redis health check
      // For now, assume it's ok if configured
      const responseTime = Date.now() - startTime;

      return {
        status: 'ok',
        responseTime,
      };
    } catch (error) {
      const responseTime = Date.now() - startTime;

      this.logger.error('Redis health check failed', error as Error);

      return {
        status: 'error',
        responseTime,
      };
    }
  }

  private async checkOpenAI(): Promise<{ status: 'ok' | 'error'; responseTime?: number }> {
    const startTime = Date.now();

    try {
      // TODO: Implement OpenAI health check with a simple API call
      // For now, assume it's ok if API key is configured
      const responseTime = Date.now() - startTime;

      return {
        status: 'ok',
        responseTime,
      };
    } catch (error) {
      const responseTime = Date.now() - startTime;

      this.logger.error('OpenAI health check failed', error as Error);

      return {
        status: 'error',
        responseTime,
      };
    }
  }

  async getMetrics() {
    return {
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      cpu: process.cpuUsage(),
      platform: process.platform,
      nodeVersion: process.version,
      environment: process.env.NODE_ENV,
    };
  }
}
import { Module } from '@nestjs/common';
import { LoggerService } from './logging/logger.service';
import { SentryService } from './sentry/sentry.service';

@Module({
  providers: [LoggerService, SentryService],
  exports: [LoggerService, SentryService],
})
export class CommonModule {}
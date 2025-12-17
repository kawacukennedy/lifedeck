import { Module } from '@nestjs/common';
import { PlaidService } from './plaid.service';
import { GoogleCalendarService } from './google-calendar.service';
import { HealthService } from './health.service';
import { IntegrationsController } from './integrations.controller';

@Module({
  controllers: [IntegrationsController],
  providers: [PlaidService, GoogleCalendarService, HealthService],
  exports: [PlaidService, GoogleCalendarService, HealthService],
})
export class IntegrationsModule {}
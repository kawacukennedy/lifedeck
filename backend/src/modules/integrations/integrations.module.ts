import { Module } from '@nestjs/common';
import { PlaidService } from './plaid.service';
import { GoogleCalendarService } from './google-calendar.service';
import { IntegrationsController } from './integrations.controller';

@Module({
  controllers: [IntegrationsController],
  providers: [PlaidService, GoogleCalendarService],
  exports: [PlaidService, GoogleCalendarService],
})
export class IntegrationsModule {}
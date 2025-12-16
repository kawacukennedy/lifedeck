import { Module } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { NotificationsController } from './notifications.controller';
import { LocationNotificationService } from './location-notification.service';

@Module({
  controllers: [NotificationsController],
  providers: [NotificationsService, LocationNotificationService],
  exports: [NotificationsService, LocationNotificationService],
})
export class NotificationsModule {}
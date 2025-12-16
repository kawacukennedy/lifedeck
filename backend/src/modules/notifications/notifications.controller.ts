import { Controller, Post, Body, UseGuards, Request } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { LocationNotificationService, LocationContext } from './location-notification.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(
    private readonly notificationsService: NotificationsService,
    private readonly locationNotificationService: LocationNotificationService,
  ) {}

  @Post('register-device')
  registerDevice(
    @Request() req,
    @Body() body: { token: string; platform: 'ios' | 'android' | 'web' },
  ) {
    return this.notificationsService.registerDeviceToken(
      req.user.id,
      body.token,
      body.platform,
    );
  }

  @Post('test-notification')
  sendTestNotification(@Request() req) {
    return this.notificationsService.sendPushNotification(
      req.user.id,
      'LifeDeck Reminder',
      'Don\'t forget to complete your daily coaching cards!',
      { type: 'reminder' },
    );
  }

  @Post('location-update')
  async updateLocation(
    @Request() req,
    @Body() body: LocationContext,
  ) {
    await this.locationNotificationService.processLocationUpdate(req.user.id, body);
    return { success: true };
  }

  @Post('setup-location-triggers')
  async setupLocationTriggers(@Request() req) {
    await this.locationNotificationService.setupDefaultTriggers(req.user.id);
    return { success: true };
  }
}
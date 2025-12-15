import { Controller, Post, Body, UseGuards, Request } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

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
}
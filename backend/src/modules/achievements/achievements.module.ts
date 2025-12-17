import { Module } from '@nestjs/common';
import { AchievementsService } from './achievements.service';
import { AchievementsController } from './achievements.controller';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  controllers: [AchievementsController],
  providers: [AchievementsService],
  exports: [AchievementsService],
  imports: [NotificationsModule],
})
export class AchievementsModule {}
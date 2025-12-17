import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { AchievementsService } from './achievements.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('achievements')
@UseGuards(JwtAuthGuard)
export class AchievementsController {
  constructor(private readonly achievementsService: AchievementsService) {}

  @Get()
  getUserAchievements(@Request() req) {
    return this.achievementsService.getUserAchievements(req.user.id);
  }

  @Get('available')
  getAvailableAchievements(@Request() req) {
    return this.achievementsService.getAvailableAchievements(req.user.id);
  }

  @Get('stats')
  getAchievementStats(@Request() req) {
    return this.achievementsService.getAchievementStats(req.user.id);
  }

  @Get('check')
  async checkAndUnlockAchievements(@Request() req) {
    const unlocked = await this.achievementsService.checkAndUnlockAchievements(req.user.id);
    return { unlockedAchievements: unlocked };
  }
}
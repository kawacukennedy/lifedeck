import { Controller, Get, Post, Body, UseGuards, Request, Query } from '@nestjs/common';
import { SocialService } from './social.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('social')
@UseGuards(JwtAuthGuard)
export class SocialController {
  constructor(private readonly socialService: SocialService) {}

  @Get('leaderboard')
  getLeaderboard(
    @Query('timeframe') timeframe?: 'daily' | 'weekly' | 'monthly' | 'all-time',
    @Query('limit') limit?: number,
  ) {
    return this.socialService.getLeaderboard(timeframe || 'weekly', limit || 50);
  }

  @Get('rank')
  getUserRank(
    @Request() req,
    @Query('timeframe') timeframe?: 'daily' | 'weekly' | 'monthly' | 'all-time',
  ) {
    return this.socialService.getUserRank(req.user.id, timeframe || 'weekly');
  }

  @Get('achievements-leaderboard')
  getAchievementsLeaderboard(@Query('limit') limit?: number) {
    return this.socialService.getAchievementsLeaderboard(limit || 20);
  }

  @Get('streak-leaderboard')
  getStreakLeaderboard(@Query('limit') limit?: number) {
    return this.socialService.getStreakLeaderboard(limit || 20);
  }

  @Post('share-achievement')
  shareAchievement(
    @Request() req,
    @Body() body: { achievementId: string; platform: 'twitter' | 'facebook' | 'general' },
  ) {
    return this.socialService.shareAchievement(req.user.id, body.achievementId, body.platform);
  }

  @Get('community-stats')
  getCommunityStats() {
    return this.socialService.getCommunityStats();
  }
}
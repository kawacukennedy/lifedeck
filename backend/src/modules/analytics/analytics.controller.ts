import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { AnalyticsService } from './analytics.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('analytics')
@UseGuards(JwtAuthGuard)
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Get()
  getAnalytics(@Request() req) {
    return this.analyticsService.getUserAnalytics(req.user.id);
  }

  @Get('life-score')
  getLifeScore(@Request() req) {
    return this.analyticsService.getLifeScore(req.user.id);
  }
}
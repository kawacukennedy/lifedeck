import { Controller, Get, UseGuards, Request, Query } from '@nestjs/common';
import { AnalyticsService } from './analytics.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('analytics')
@UseGuards(JwtAuthGuard)
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Get()
  getAnalytics(@Request() req, @Query('timeframe') timeframe?: 'week' | 'month' | 'year') {
    return this.analyticsService.getUserAnalytics(req.user.id, timeframe || 'month');
  }

  @Get('life-score')
  getLifeScore(@Request() req) {
    return this.analyticsService.getLifeScore(req.user.id);
  }

  @Get('domain/:domain')
  getDomainAnalytics(@Request() req, @Query('domain') domain: string) {
    return this.analyticsService.getDomainAnalytics(req.user.id, domain as any);
  }

  @Get('insights')
  getInsights(@Request() req, @Query('timeframe') timeframe?: 'week' | 'month' | 'year') {
    return this.analyticsService.getUserAnalytics(req.user.id, timeframe || 'month').then(data => data.insights);
  }

  @Get('trends')
  getTrends(@Request() req, @Query('timeframe') timeframe?: 'week' | 'month' | 'year') {
    return this.analyticsService.getUserAnalytics(req.user.id, timeframe || 'month').then(data => data.trends);
  }
}
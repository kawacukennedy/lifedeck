import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { AiService } from './ai.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('ai')
@UseGuards(JwtAuthGuard)
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('generate-card')
  generateCard(@Request() req, @Body() body: { domain: string; context?: any }) {
    return this.aiService.generatePersonalizedCard(
      req.user.id,
      body.domain as any,
      body.context,
    );
  }

  @Get('daily-cards')
  generateDailyCards(@Request() req) {
    return this.aiService.generateDailyCardSet(req.user.id);
  }
}
import { Controller, Get, Post, Body, UseGuards, Request, Query } from '@nestjs/common';
import { PlaidService } from './plaid.service';
import { GoogleCalendarService } from './google-calendar.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('integrations')
@UseGuards(JwtAuthGuard)
export class IntegrationsController {
  constructor(
    private readonly plaidService: PlaidService,
    private readonly googleCalendarService: GoogleCalendarService,
  ) {}

  @Get('plaid/link-token')
  async getPlaidLinkToken(@Request() req) {
    return {
      link_token: await this.plaidService.createLinkToken(req.user.id),
    };
  }

  @Post('plaid/exchange-token')
  async exchangePlaidToken(@Request() req, @Body() body: { public_token: string }) {
    const accessToken = await this.plaidService.exchangePublicToken(body.public_token);

    // Store access token securely (in production, encrypt and store in database)
    // For now, just return success
    return {
      success: true,
      access_token: accessToken, // Don't return this in production!
    };
  }

  @Get('plaid/transactions')
  async getPlaidTransactions(@Request() req, @Body() body: { access_token: string; days?: number }) {
    const days = body.days || 30;
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(endDate.getDate() - days);

    return await this.plaidService.getTransactions(
      body.access_token,
      startDate.toISOString().split('T')[0],
      endDate.toISOString().split('T')[0],
    );
  }

  @Get('plaid/balances')
  async getPlaidBalances(@Request() req, @Body() body: { access_token: string }) {
    return await this.plaidService.getAccountBalances(body.access_token);
  }

  @Get('plaid/insights')
  async getPlaidInsights(@Request() req, @Body() body: { access_token: string; days?: number }) {
    const days = body.days || 30;
    return await this.plaidService.getSpendingInsights(body.access_token, days);
  }

  @Get('plaid/recommendations')
  async getPlaidRecommendations(@Request() req, @Body() body: { access_token: string }) {
    return await this.plaidService.getBudgetRecommendations(body.access_token);
  }

  // Google Calendar Integration
  @Get('google-calendar/auth-url')
  getGoogleCalendarAuthUrl(@Request() req) {
    return {
      auth_url: this.googleCalendarService.generateAuthUrl(req.user.id),
    };
  }

  @Post('google-calendar/callback')
  async handleGoogleCalendarCallback(@Body() body: { code: string; state: string }) {
    const tokens = await this.googleCalendarService.getTokens(body.code);
    // Store tokens securely for the user
    return { success: true, tokens };
  }

  @Get('google-calendar/events')
  async getGoogleCalendarEvents(
    @Request() req,
    @Query('access_token') accessToken: string,
    @Query('refresh_token') refreshToken: string,
    @Query('days') days?: number,
  ) {
    return await this.googleCalendarService.getCalendarEvents(accessToken, refreshToken, days || 7);
  }

  @Get('google-calendar/insights')
  async getGoogleCalendarInsights(
    @Request() req,
    @Query('access_token') accessToken: string,
    @Query('refresh_token') refreshToken: string,
  ) {
    return await this.googleCalendarService.getProductivityInsights(accessToken, refreshToken);
  }

  @Post('google-calendar/reminder')
  async scheduleCalendarReminder(
    @Request() req,
    @Body() body: { access_token: string; refresh_token: string; title: string; date: string },
  ) {
    const date = new Date(body.date);
    return await this.googleCalendarService.scheduleLifeDeckReminder(
      body.access_token,
      body.refresh_token,
      body.title,
      date,
    );
  }
}
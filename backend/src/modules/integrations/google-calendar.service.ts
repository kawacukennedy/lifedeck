import { Injectable } from '@nestjs/common';
import { google } from 'googleapis';

@Injectable()
export class GoogleCalendarService {
  private oauth2Client;

  constructor() {
    this.oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET,
      `${process.env.BASE_URL || 'http://localhost:3000'}/v1/integrations/google-calendar/callback`,
    );
  }

  generateAuthUrl(userId: string): string {
    const scopes = [
      'https://www.googleapis.com/auth/calendar.readonly',
      'https://www.googleapis.com/auth/calendar.events',
    ];

    return this.oauth2Client.generateAuthUrl({
      access_type: 'offline',
      scope: scopes,
      state: userId, // Pass user ID in state
    });
  }

  async getTokens(code: string) {
    const { tokens } = await this.oauth2Client.getToken(code);
    return tokens;
  }

  async getCalendarEvents(accessToken: string, refreshToken: string, days: number = 7) {
    this.oauth2Client.setCredentials({
      access_token: accessToken,
      refresh_token: refreshToken,
    });

    const calendar = google.calendar({ version: 'v3', auth: this.oauth2Client });

    const now = new Date();
    const future = new Date();
    future.setDate(now.getDate() + days);

    try {
      const response = await calendar.events.list({
        calendarId: 'primary',
        timeMin: now.toISOString(),
        timeMax: future.toISOString(),
        singleEvents: true,
        orderBy: 'startTime',
      });

      return response.data.items || [];
    } catch (error) {
      console.error('Failed to fetch calendar events:', error);
      throw error;
    }
  }

  async createCalendarEvent(accessToken: string, refreshToken: string, event: any) {
    this.oauth2Client.setCredentials({
      access_token: accessToken,
      refresh_token: refreshToken,
    });

    const calendar = google.calendar({ version: 'v3', auth: this.oauth2Client });

    try {
      const response = await calendar.events.insert({
        calendarId: 'primary',
        requestBody: event,
      });

      return response.data;
    } catch (error) {
      console.error('Failed to create calendar event:', error);
      throw error;
    }
  }

  async getProductivityInsights(accessToken: string, refreshToken: string) {
    const events = await this.getCalendarEvents(accessToken, refreshToken, 30); // Last 30 days

    const insights = {
      totalEvents: events.length,
      workHours: 0,
      meetingHours: 0,
      focusTimeHours: 0,
      busiestDay: null as string | null,
      dailyEventCount: {} as Record<string, number>,
      averageEventsPerDay: 0,
      recommendations: [] as string[],
    };

    events.forEach(event => {
      if (event.start?.dateTime && event.end?.dateTime) {
        const start = new Date(event.start.dateTime);
        const end = new Date(event.end.dateTime);
        const duration = (end.getTime() - start.getTime()) / (1000 * 60 * 60); // hours

        // Categorize events
        const title = event.summary?.toLowerCase() || '';
        if (title.includes('meeting') || title.includes('call') || title.includes('sync')) {
          insights.meetingHours += duration;
        } else if (title.includes('focus') || title.includes('deep work') || title.includes('coding')) {
          insights.focusTimeHours += duration;
        } else {
          insights.workHours += duration;
        }

        // Daily event count
        const date = start.toDateString();
        insights.dailyEventCount[date] = (insights.dailyEventCount[date] || 0) + 1;
      }
    });

    // Find busiest day
    let maxEvents = 0;
    for (const [date, count] of Object.entries(insights.dailyEventCount)) {
      if (count > maxEvents) {
        maxEvents = count;
        insights.busiestDay = date;
      }
    }

    insights.averageEventsPerDay = insights.totalEvents / 30;

    // Generate recommendations
    if (insights.meetingHours > insights.focusTimeHours * 2) {
      insights.recommendations.push('Consider reducing meeting time to allow more focused work periods.');
    }

    if (insights.averageEventsPerDay > 8) {
      insights.recommendations.push('Your schedule seems packed. Consider blocking time for breaks and unexpected tasks.');
    }

    if (insights.focusTimeHours < 4) {
      insights.recommendations.push('Try to schedule at least 4 hours of focused work time daily.');
    }

    return insights;
  }

  async scheduleLifeDeckReminder(accessToken: string, refreshToken: string, title: string, date: Date) {
    const event = {
      summary: `LifeDeck: ${title}`,
      description: 'Personalized coaching reminder from LifeDeck',
      start: {
        dateTime: date.toISOString(),
        timeZone: 'UTC',
      },
      end: {
        dateTime: new Date(date.getTime() + 30 * 60 * 1000).toISOString(), // 30 minutes
        timeZone: 'UTC',
      },
      reminders: {
        useDefault: false,
        overrides: [
          { method: 'popup', minutes: 10 },
          { method: 'email', minutes: 30 },
        ],
      },
    };

    return await this.createCalendarEvent(accessToken, refreshToken, event);
  }
}
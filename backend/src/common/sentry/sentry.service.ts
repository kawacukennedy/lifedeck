import { Injectable } from '@nestjs/common';
import * as Sentry from '@sentry/node';

@Injectable()
export class SentryService {
  constructor() {
    if (process.env.SENTRY_DSN) {
      Sentry.init({
        dsn: process.env.SENTRY_DSN,
        environment: process.env.NODE_ENV || 'development',
        tracesSampleRate: 1.0,
        profilesSampleRate: 1.0,
      });
    }
  }

  captureException(error: Error, context?: any) {
    if (process.env.SENTRY_DSN) {
      Sentry.withScope((scope) => {
        if (context) {
          scope.setContext('additional_info', context);
        }
        Sentry.captureException(error);
      });
    }
  }

  captureMessage(message: string, level: Sentry.SeverityLevel = 'info', context?: any) {
    if (process.env.SENTRY_DSN) {
      Sentry.withScope((scope) => {
        scope.setLevel(level);
        if (context) {
          scope.setContext('additional_info', context);
        }
        Sentry.captureMessage(message);
      });
    }
  }

  setUser(user: { id: string; email?: string; username?: string }) {
    if (process.env.SENTRY_DSN) {
      Sentry.setUser(user);
    }
  }

  setTag(key: string, value: string) {
    if (process.env.SENTRY_DSN) {
      Sentry.setTag(key, value);
    }
  }

  addBreadcrumb(breadcrumb: {
    message: string;
    level?: Sentry.SeverityLevel;
    category?: string;
  }) {
    if (process.env.SENTRY_DSN) {
      Sentry.addBreadcrumb(breadcrumb);
    }
  }
}
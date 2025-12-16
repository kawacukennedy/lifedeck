import { Injectable } from '@nestjs/common';
import * as winston from 'winston';
import * as DailyRotateFile from 'winston-daily-rotate-file';

@Injectable()
export class LoggerService {
  private logger: winston.Logger;

  constructor() {
    this.initializeLogger();
  }

  private initializeLogger() {
    const logFormat = winston.format.combine(
      winston.format.timestamp(),
      winston.format.errors({ stack: true }),
      winston.format.json(),
    );

    const transports: winston.transport[] = [
      // Console transport for development
      new winston.transports.Console({
        level: process.env.LOG_LEVEL || 'info',
        format: winston.format.combine(
          winston.format.colorize(),
          winston.format.simple(),
        ),
      }),
    ];

    // File transports for production
    if (process.env.NODE_ENV === 'production') {
      transports.push(
        // Error log
        new DailyRotateFile({
          filename: 'logs/error-%DATE%.log',
          datePattern: 'YYYY-MM-DD',
          level: 'error',
          maxSize: '20m',
          maxFiles: '14d',
        }),
        // Combined log
        new DailyRotateFile({
          filename: 'logs/combined-%DATE%.log',
          datePattern: 'YYYY-MM-DD',
          maxSize: '20m',
          maxFiles: '14d',
        }),
      );
    }

    this.logger = winston.createLogger({
      level: process.env.LOG_LEVEL || 'info',
      format: logFormat,
      transports,
      exceptionHandlers: [
        new winston.transports.File({ filename: 'logs/exceptions.log' }),
      ],
      rejectionHandlers: [
        new winston.transports.File({ filename: 'logs/rejections.log' }),
      ],
    });
  }

  log(level: string, message: string, meta?: any) {
    this.logger.log(level, message, meta);
  }

  info(message: string, meta?: any) {
    this.logger.info(message, meta);
  }

  error(message: string, error?: Error, meta?: any) {
    this.logger.error(message, {
      ...meta,
      error: error?.message,
      stack: error?.stack,
    });
  }

  warn(message: string, meta?: any) {
    this.logger.warn(message, meta);
  }

  debug(message: string, meta?: any) {
    this.logger.debug(message, meta);
  }

  // Request logging
  logRequest(req: any, res: any, responseTime: number) {
    this.logger.info('HTTP Request', {
      method: req.method,
      url: req.url,
      statusCode: res.statusCode,
      responseTime: `${responseTime}ms`,
      userAgent: req.get('User-Agent'),
      ip: req.ip,
    });
  }

  // Database operation logging
  logDatabaseOperation(operation: string, table: string, duration: number, success: boolean) {
    this.logger.info('Database Operation', {
      operation,
      table,
      duration: `${duration}ms`,
      success,
    });
  }

  // AI operation logging
  logAIOperation(operation: string, model: string, tokens: number, duration: number, success: boolean) {
    this.logger.info('AI Operation', {
      operation,
      model,
      tokens,
      duration: `${duration}ms`,
      success,
    });
  }

  // User activity logging
  logUserActivity(userId: string, action: string, details?: any) {
    this.logger.info('User Activity', {
      userId,
      action,
      ...details,
    });
  }

  // Performance monitoring
  logPerformance(metric: string, value: number, tags?: Record<string, string>) {
    this.logger.info('Performance Metric', {
      metric,
      value,
      tags,
    });
  }
}
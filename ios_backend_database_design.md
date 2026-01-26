# LifeDeck iOS Backend & Database Design Specification

## Overview

This document outlines the comprehensive backend and database design required to support the LifeDeck iOS application. The design is based on analysis of the iOS codebase, project specifications, and design requirements.

## System Architecture

### Backend Architecture
- **Framework**: NestJS 10 (Node.js 20)
- **Pattern**: Modular Monolith with Service-Oriented Components
- **API Type**: REST with JWT authentication
- **Base URL**: `https://api.lifedeck.app/v1`

### Database Architecture
- **Primary Database**: PostgreSQL 16
- **ORM**: Prisma 5
- **Caching**: Redis 7
- **Queue System**: BullMQ 4

## Database Schema Design

### Core Tables

#### 1. Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    has_completed_onboarding BOOLEAN DEFAULT FALSE,
    join_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 2. User Progress Table
```sql
CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    health_score DECIMAL(5,2) DEFAULT 50.0,
    finance_score DECIMAL(5,2) DEFAULT 50.0,
    productivity_score DECIMAL(5,2) DEFAULT 50.0,
    mindfulness_score DECIMAL(5,2) DEFAULT 50.0,
    life_score DECIMAL(5,2) DEFAULT 50.0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    life_points INTEGER DEFAULT 0,
    total_cards_completed INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);
```

#### 3. User Settings Table
```sql
CREATE TABLE user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    notifications_enabled BOOLEAN DEFAULT TRUE,
    weekly_reports_enabled BOOLEAN DEFAULT TRUE,
    haptics_enabled BOOLEAN DEFAULT TRUE,
    sound_enabled BOOLEAN DEFAULT TRUE,
    auto_start_day BOOLEAN DEFAULT FALSE,
    daily_reminder_time TIME DEFAULT '09:00:00',
    theme VARCHAR(50) DEFAULT 'system',
    language VARCHAR(10) DEFAULT 'en',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);
```

#### 4. User Focus Areas Table
```sql
CREATE TABLE user_focus_areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    domain VARCHAR(50) NOT NULL, -- 'health', 'finance', 'productivity', 'mindfulness'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, domain)
);
```

#### 5. Coaching Cards Table
```sql
CREATE TABLE coaching_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    domain VARCHAR(50) NOT NULL, -- 'health', 'finance', 'productivity', 'mindfulness'
    action_text TEXT NOT NULL,
    difficulty DECIMAL(3,1) DEFAULT 1.0,
    points INTEGER DEFAULT 10,
    priority VARCHAR(20) DEFAULT 'medium', -- 'low', 'medium', 'high', 'critical'
    estimated_duration VARCHAR(20) DEFAULT 'standard', -- 'quick', 'short', 'standard', 'extended'
    is_premium BOOLEAN DEFAULT FALSE,
    ai_generated BOOLEAN DEFAULT TRUE,
    tags TEXT[], -- Array of tag strings
    impact DECIMAL(5,2) DEFAULT 5.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 6. User Daily Cards Table
```sql
CREATE TABLE user_daily_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    card_id UUID REFERENCES coaching_cards(id) ON DELETE CASCADE,
    assigned_date DATE NOT NULL,
    completed_date TIMESTAMP WITH TIME ZONE,
    snoozed_until TIMESTAMP WITH TIME ZONE,
    user_note TEXT,
    is_bookmarked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, card_id, assigned_date)
);
```

#### 7. User Goals Table
```sql
CREATE TABLE user_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    domain VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    target_value INTEGER NOT NULL,
    current_value INTEGER DEFAULT 0,
    unit VARCHAR(50) NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 8. Achievements Table
```sql
CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    icon_name VARCHAR(100) NOT NULL,
    domain VARCHAR(50), -- Optional domain for specific achievements
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 9. User Achievements Table
```sql
CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    achievement_id UUID REFERENCES achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);
```

#### 10. Subscriptions Table
```sql
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    tier VARCHAR(20) DEFAULT 'free', -- 'free', 'premium'
    status VARCHAR(30) DEFAULT 'not_subscribed', -- 'not_subscribed', 'active', 'expired', 'cancelled', 'pending_renewal', 'in_grace_period'
    start_date TIMESTAMP WITH TIME ZONE,
    expiry_date TIMESTAMP WITH TIME ZONE,
    auto_renew_enabled BOOLEAN DEFAULT FALSE,
    product_id VARCHAR(100),
    transaction_id VARCHAR(255),
    original_transaction_id VARCHAR(255),
    purchase_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);
```

#### 11. Streaks Table
```sql
CREATE TABLE streaks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    daily_streak INTEGER DEFAULT 0,
    weekly_streak INTEGER DEFAULT 0,
    monthly_streak INTEGER DEFAULT 0,
    last_activity_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);
```

#### 12. Card Analytics Table
```sql
CREATE TABLE card_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    card_id UUID REFERENCES coaching_cards(id) ON DELETE CASCADE,
    action_date DATE NOT NULL,
    action_type VARCHAR(20) NOT NULL, -- 'completed', 'snoozed', 'skipped', 'bookmarked'
    completion_time_seconds INTEGER, -- Time taken to complete
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Indexes

```sql
-- Performance indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_settings_user_id ON user_settings(user_id);
CREATE INDEX idx_coaching_cards_domain ON coaching_cards(domain);
CREATE INDEX idx_coaching_cards_is_premium ON coaching_cards(is_premium);
CREATE INDEX idx_user_daily_cards_user_id ON user_daily_cards(user_id);
CREATE INDEX idx_user_daily_cards_assigned_date ON user_daily_cards(assigned_date);
CREATE INDEX idx_user_daily_cards_user_date ON user_daily_cards(user_id, assigned_date);
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_card_analytics_user_date ON card_analytics(user_id, action_date);
CREATE INDEX idx_card_analytics_card_id ON card_analytics(card_id);
```

## API Endpoints Design

### Authentication Endpoints

#### POST /v1/auth/register
```json
{
  "request": {
    "name": "string",
    "email": "string",
    "password": "string"
  },
  "response": {
    "user": "User",
    "token": "string",
    "refreshToken": "string"
  }
}
```

#### POST /v1/auth/login
```json
{
  "request": {
    "email": "string",
    "password": "string"
  },
  "response": {
    "user": "User",
    "token": "string",
    "refreshToken": "string"
  }
}
```

#### POST /v1/auth/refresh
```json
{
  "request": {
    "refreshToken": "string"
  },
  "response": {
    "token": "string",
    "refreshToken": "string"
  }
}
```

### User Management Endpoints

#### GET /v1/users/profile
```json
{
  "response": {
    "id": "uuid",
    "name": "string",
    "email": "string",
    "hasCompletedOnboarding": "boolean",
    "joinDate": "datetime",
    "subscription": "AppSubscriptionInfo",
    "progress": "UserProgress",
    "settings": "UserSettings"
  }
}
```

#### PUT /v1/users/profile
```json
{
  "request": {
    "name": "string",
    "email": "string"
  },
  "response": {
    "user": "User"
  }
}
```

#### GET /v1/users/progress
```json
{
  "response": {
    "healthScore": "number",
    "financeScore": "number",
    "productivityScore": "number",
    "mindfulnessScore": "number",
    "lifeScore": "number",
    "currentStreak": "number",
    "longestStreak": "number",
    "lifePoints": "number",
    "totalCardsCompleted": "number"
  }
}
```

#### GET /v1/users/settings
```json
{
  "response": {
    "notificationsEnabled": "boolean",
    "weeklyReportsEnabled": "boolean",
    "hapticsEnabled": "boolean",
    "soundEnabled": "boolean",
    "autoStartDay": "boolean",
    "dailyReminderTime": "time",
    "theme": "string",
    "language": "string",
    "focusAreas": ["string"]
  }
}
```

#### PUT /v1/users/settings
```json
{
  "request": {
    "notificationsEnabled": "boolean",
    "weeklyReportsEnabled": "boolean",
    "hapticsEnabled": "boolean",
    "soundEnabled": "boolean",
    "autoStartDay": "boolean",
    "dailyReminderTime": "time",
    "theme": "string",
    "language": "string",
    "focusAreas": ["string"]
  },
  "response": {
    "settings": "UserSettings"
  }
}
```

### Cards Endpoints

#### GET /v1/cards/daily
```json
{
  "response": {
    "cards": [
      {
        "id": "uuid",
        "title": "string",
        "description": "string",
        "domain": "string",
        "actionText": "string",
        "difficulty": "number",
        "points": "number",
        "priority": "string",
        "estimatedDuration": "string",
        "isPremium": "boolean",
        "aiGenerated": "boolean",
        "tags": ["string"],
        "impact": "number",
        "createdDate": "datetime",
        "completedDate": "datetime?",
        "snoozedUntil": "datetime?",
        "userNote": "string?",
        "isBookmarked": "boolean"
      }
    ]
  }
}
```

#### POST /v1/cards/{cardId}/complete
```json
{
  "response": {
    "success": "boolean",
    "pointsEarned": "number",
    "updatedProgress": "UserProgress"
  }
}
```

#### POST /v1/cards/{cardId}/snooze
```json
{
  "request": {
    "snoozeDuration": "number" // hours
  },
  "response": {
    "success": "boolean",
    "snoozedUntil": "datetime"
  }
}
```

#### POST /v1/cards/{cardId}/bookmark
```json
{
  "response": {
    "success": "boolean",
    "isBookmarked": "boolean"
  }
}
```

#### PUT /v1/cards/{cardId}/note
```json
{
  "request": {
    "note": "string"
  },
  "response": {
    "success": "boolean"
  }
}
```

### Goals Endpoints

#### GET /v1/goals
```json
{
  "response": {
    "goals": [
      {
        "id": "uuid",
        "domain": "string",
        "description": "string",
        "targetValue": "number",
        "currentValue": "number",
        "unit": "string",
        "isCompleted": "boolean",
        "createdAt": "datetime",
        "progress": "number"
      }
    ]
  }
}
```

#### POST /v1/goals
```json
{
  "request": {
    "domain": "string",
    "description": "string",
    "targetValue": "number",
    "unit": "string"
  },
  "response": {
    "goal": "UserGoal"
  }
}
```

#### PUT /v1/goals/{goalId}
```json
{
  "request": {
    "currentValue": "number",
    "isCompleted": "boolean"
  },
  "response": {
    "goal": "UserGoal"
  }
}
```

### Achievements Endpoints

#### GET /v1/achievements
```json
{
  "response": {
    "achievements": [
      {
        "id": "uuid",
        "title": "string",
        "description": "string",
        "iconName": "string",
        "domain": "string?",
        "unlockedAt": "datetime?",
        "isUnlocked": "boolean"
      }
    ]
  }
}
```

### Subscription Endpoints

#### GET /v1/subscription/status
```json
{
  "response": {
    "tier": "string",
    "status": "string",
    "startDate": "datetime?",
    "expiryDate": "datetime?",
    "autoRenewEnabled": "boolean",
    "productId": "string?",
    "isPremium": "boolean"
  }
}
```

#### POST /v1/subscription/verify
```json
{
  "request": {
    "receiptData": "string",
    "productId": "string"
  },
  "response": {
    "verified": "boolean",
    "subscription": "AppSubscriptionInfo"
  }
}
```

### Analytics Endpoints

#### GET /v1/analytics/dashboard
```json
{
  "response": {
    "lifeScore": "number",
    "domainScores": {
      "health": "number",
      "finance": "number",
      "productivity": "number",
      "mindfulness": "number"
    },
    "streaks": {
      "current": "number",
      "longest": "number",
      "daily": "number",
      "weekly": "number",
      "monthly": "number"
    },
    "weeklyProgress": [
      {
        "date": "date",
        "cardsCompleted": "number",
        "lifeScore": "number"
      }
    ],
    "domainBreakdown": [
      {
        "domain": "string",
        "cardsCompleted": "number",
        "averageScore": "number"
      }
    ]
  }
}
```

## Business Logic Implementation

### AI Card Generation Service

The AI service should:

1. **Analyze User Profile**: Consider user's current scores, focus areas, and completion history
2. **Domain-Based Generation**: Generate cards based on user's weak areas first
3. **Difficulty Progression**: Adjust card difficulty based on user's domain scores
4. **Premium Gating**: Ensure premium cards are only served to premium users
5. **Variety**: Mix different card types and durations

### Life Score Calculation

```javascript
function calculateLifeScore(domainScores) {
  return (domainScores.health + 
          domainScores.finance + 
          domainScores.productivity + 
          domainScores.mindfulness) / 4;
}

function updateDomainScore(currentScore, cardDifficulty, cardImpact, actionType) {
  let scoreChange = 0;
  
  if (actionType === 'completed') {
    scoreChange = cardImpact * (1 + cardDifficulty * 0.1);
  } else if (actionType === 'snoozed') {
    scoreChange = -0.5;
  }
  
  return Math.max(0, Math.min(100, currentScore + scoreChange));
}
```

### Streak Management

```javascript
function updateStreaks(lastActivityDate, today) {
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);
  
  if (lastActivityDate?.toDateString() === yesterday.toDateString()) {
    // Continue streak
    return { currentStreak: currentStreak + 1, longestStreak: Math.max(longestStreak, currentStreak + 1) };
  } else if (lastActivityDate?.toDateString() === today.toDateString()) {
    // Same day, no change
    return { currentStreak, longestStreak };
  } else {
    // Streak broken
    return { currentStreak: 1, longestStreak };
  }
}
```

## Security Implementation

### Authentication & Authorization

1. **JWT Tokens**: Use short-lived access tokens (15 minutes) with refresh tokens (7 days)
2. **Password Security**: bcrypt with salt rounds >= 12
3. **Rate Limiting**: 100 requests/minute per user
4. **CORS**: Restrict to LifeDeck domains
5. **Input Validation**: Zod schemas for all inputs

### Data Protection

1. **Encryption**: AES-256 at rest, TLS 1.3 in transit
2. **PII Handling**: Email masking in logs
3. **GDPR Compliance**: User data export/delete endpoints
4. **Audit Logging**: Log all user actions and admin changes

## Performance Optimization

### Database Optimization

1. **Connection Pooling**: PgBouncer with 20 connections
2. **Read Replicas**: 2 read replicas for analytics queries
3. **Indexing Strategy**: Composite indexes for common query patterns
4. **Query Optimization**: Use EXPLAIN ANALYZE for slow queries

### Caching Strategy

1. **Redis Caching**: 
   - User sessions (15 min TTL)
   - Daily cards (5 min TTL)
   - User progress (1 hour TTL)
2. **HTTP Caching**: Cache-Control headers for static data
3. **CDN**: CloudFront for API responses

### Background Jobs

1. **Daily Card Generation**: BullMQ job at 00:00 UTC per user timezone
2. **Analytics Aggregation**: Hourly job to calculate domain scores
3. **Streak Reset**: Daily job to reset streaks for inactive users
4. **Subscription Sync**: Real-time webhooks from App Store

## Monitoring & Observability

### Metrics to Track

1. **Application Metrics**:
   - API response times
   - Error rates by endpoint
   - User engagement (cards completed/day)
   - Subscription conversion rates

2. **Database Metrics**:
   - Query performance
   - Connection pool usage
   - Table sizes and growth

3. **Business Metrics**:
   - Daily active users
   - Card completion rates
   - Streak lengths distribution
   - Premium feature usage

### Alerting Rules

1. **High Priority**:
   - Error rate > 5%
   - Response time > 2s
   - Database connections > 80%

2. **Medium Priority**:
   - Card generation failures
   - Payment processing errors
   - User authentication failures

## Deployment Architecture

### Environment Configuration

1. **Development**: Local Docker with PostgreSQL and Redis
2. **Staging**: AWS ECS with RDS PostgreSQL and ElastiCache Redis
3. **Production**: AWS EKS with Aurora PostgreSQL and ElastiCache Redis

### CI/CD Pipeline

1. **Build**: Docker image build and push to ECR
2. **Test**: Unit tests, integration tests, security scans
3. **Deploy**: Blue-green deployment with health checks
4. **Rollback**: Automatic rollback on health check failures

## Scalability Considerations

### Horizontal Scaling

1. **API Servers**: Stateless containers behind ALB
2. **Database**: Read replicas for analytics, connection pooling
3. **Cache**: Redis Cluster for horizontal scaling
4. **Queue**: BullMQ with multiple workers

### Vertical Scaling

1. **Database**: Aurora Serverless v2 for auto-scaling
2. **Cache**: Memory-optimized Redis instances
3. **Compute**: Auto-scaling based on CPU/memory metrics

## Testing Strategy

### Unit Tests

- Cover all business logic functions
- Mock external dependencies (AI service, payment gateways)
- Target 85% code coverage

### Integration Tests

- API endpoint testing with real database
- Authentication flow testing
- Payment verification testing

### Load Testing

- 10k concurrent users simulation
- Database query performance under load
- API response time benchmarks

## Migration Strategy

### Database Migrations

1. **Version Control**: All migrations in Prisma schema
2. **Rollback Capability**: Down migrations for each change
3. **Zero Downtime**: Use multi-step migrations for large tables
4. **Backups**: Automated backups before each migration

### API Versioning

1. **URL Versioning**: /v1, /v2, etc.
2. **Backward Compatibility**: Maintain old versions for 6 months
3. **Deprecation Notices**: Communicate changes to iOS team

## Conclusion

This backend and database design provides a robust, scalable foundation for the LifeDeck iOS application. The architecture supports the core features identified in the iOS codebase while ensuring performance, security, and maintainability.

Key highlights:
- Comprehensive user management with progress tracking
- AI-powered card generation with personalization
- Premium subscription management with Apple integration
- Real-time analytics and streak management
- Scalable architecture supporting growth
- Security-first approach with GDPR compliance

The design aligns with the iOS app's data models and API requirements, ensuring seamless integration and optimal user experience.
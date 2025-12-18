# Contributing to LifeDeck

Thank you for your interest in contributing to LifeDeck! We welcome contributions from developers of all skill levels. This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors. Please:

- Be respectful and inclusive in all interactions
- Focus on constructive feedback
- Help create a positive community
- Report any unacceptable behavior to the maintainers

## Getting Started

### Prerequisites

- **Node.js 20+** for backend development
- **Xcode 15+** for iOS development
- **Android Studio** for Android development
- **PostgreSQL 16** for database
- **Redis 7** for caching
- **Git** for version control

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/lifedeck.git
   cd lifedeck
   ```

2. **Set up backend**
   ```bash
   cd backend
   npm install
   cp .env.example .env.local
   # Configure your environment variables
   npx prisma generate
   npx prisma db push
   npm run start:dev
   ```

3. **Set up web app**
   ```bash
   cd web
   npm install
   npm run dev
   ```

4. **Set up iOS app**
   ```bash
   cd LifeDeck
   open LifeDeck.xcodeproj
   # Build and run in Xcode
   ```

5. **Set up Android app**
   ```bash
   cd android
   npm install
   npx react-native run-android
   ```

## Development Workflow

### Branching Strategy

We use a simplified Git flow:

- `main`: Production-ready code
- `feature/*`: New features
- `bugfix/*`: Bug fixes
- `hotfix/*`: Critical production fixes

### Commit Convention

We follow conventional commits:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Testing
- `chore`: Maintenance

Examples:
```
feat(auth): add Google OAuth support
fix(api): resolve memory leak in card generation
docs(readme): update deployment instructions
```

## Coding Standards

### TypeScript/JavaScript

- Use TypeScript for all new code
- Follow ESLint configuration
- Use Prettier for code formatting
- Prefer `const` over `let`, avoid `var`
- Use async/await over Promises
- Add JSDoc comments for public APIs

### Swift (iOS)

- Follow Swift API Design Guidelines
- Use SwiftUI for new UI components
- Prefer structs over classes where possible
- Use Combine for reactive programming
- Follow MVVM architecture pattern

### React Native (Android)

- Follow React Native best practices
- Use TypeScript for type safety
- Follow Redux Toolkit patterns
- Use React Navigation for routing
- Implement proper error boundaries

### Next.js (Web)

- Use App Router for new routes
- Implement proper loading states
- Use server components where possible
- Follow accessibility guidelines (WCAG 2.1 AA)
- Optimize for Core Web Vitals

### Database

- Use Prisma migrations for schema changes
- Follow naming conventions in schema
- Add indexes for performance-critical queries
- Use transactions for multi-table operations

## Testing

### Backend Testing

```bash
cd backend
npm run test              # Run unit tests
npm run test:cov         # Run with coverage
npm run test:e2e         # Run e2e tests
npm run test:debug       # Debug tests
```

### Frontend Testing

```bash
# iOS
cd LifeDeck
xcodebuild test -scheme LifeDeck -destination 'platform=iOS Simulator,name=iPhone 15'

# Android
cd android
npm run test
npm run test:e2e

# Web
cd web
npm run test
npm run test:e2e
```

### Testing Guidelines

- Write tests for all new features
- Maintain >85% code coverage for backend
- Test both happy path and error scenarios
- Use descriptive test names
- Mock external dependencies
- Test database operations with test database

## Submitting Changes

### Pull Request Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow coding standards
   - Add tests for new functionality
   - Update documentation if needed
   - Ensure all tests pass

3. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

4. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   # Create PR on GitHub
   ```

5. **PR Review**
   - Address reviewer feedback
   - Ensure CI checks pass
   - Get approval from maintainers

6. **Merge**
   - Squash merge for clean history
   - Delete feature branch after merge

### PR Requirements

- [ ] All tests pass
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No breaking changes without discussion
- [ ] Security review completed
- [ ] Performance impact assessed

## Reporting Issues

### Bug Reports

When reporting bugs, please include:

- Clear title and description
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, device, app version)
- Screenshots/logs if applicable
- Use the bug report template

### Feature Requests

For feature requests, please provide:

- Clear description of the feature
- Problem it solves
- Proposed solution
- Alternative approaches considered
- User impact assessment
- Use the feature request template

## Security

- Never commit sensitive data (API keys, passwords, etc.)
- Use environment variables for configuration
- Follow OWASP guidelines
- Report security issues privately to maintainers
- Implement proper input validation

## Performance

- Optimize database queries
- Implement proper caching strategies
- Minimize bundle sizes
- Use lazy loading for large components
- Monitor Core Web Vitals
- Profile memory usage

## Documentation

- Keep README files up to date
- Document API changes
- Add code comments for complex logic
- Update deployment guides
- Maintain changelog

## Getting Help

- Check existing issues and documentation first
- Use GitHub Discussions for questions
- Join our Discord/Slack community
- Contact maintainers for urgent issues

## Recognition

Contributors will be recognized in:
- Repository contributors list
- Changelog entries
- Release notes
- Community acknowledgments

Thank you for contributing to LifeDeck! 🚀
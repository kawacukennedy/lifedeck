# LifeDeck Deployment Guide

This guide covers deploying the LifeDeck application across all platforms (backend, web, iOS, Android).

## Table of Contents

- [Prerequisites](#prerequisites)
- [Backend Deployment](#backend-deployment)
- [Web Deployment](#web-deployment)
- [iOS Deployment](#ios-deployment)
- [Android Deployment](#android-deployment)
- [Infrastructure Setup](#infrastructure-setup)
- [Monitoring & Maintenance](#monitoring--maintenance)

## Prerequisites

### Required Accounts & Services

- **AWS Account** (for cloud infrastructure)
- **Apple Developer Program** ($99/year) for iOS deployment
- **Google Play Console** ($25 one-time) for Android deployment
- **Vercel/Netlify** account for web deployment
- **Stripe** account for payments
- **OpenAI** API access
- **Plaid** account for financial integrations

### Required Tools

- Docker & Docker Compose
- AWS CLI
- Terraform
- kubectl (for Kubernetes deployments)
- Xcode 15+ (for iOS)
- Android Studio (for Android)

## Backend Deployment

### Option 1: AWS ECS (Recommended for Production)

1. **Set up AWS Infrastructure**
   ```bash
   cd infrastructure/terraform
   terraform init
   terraform plan -var-file=production.tfvars
   terraform apply -var-file=production.tfvars
   ```

2. **Configure Environment Variables**
   ```bash
   # Update ECS task definition with secrets
   aws ecs update-service --cluster lifedeck-cluster --service lifedeck-backend-service --force-new-deployment
   ```

3. **Database Migration**
   ```bash
   # Run migrations on RDS
   npx prisma migrate deploy
   ```

4. **Health Check**
   ```bash
   curl https://api.lifedeck.app/v1/health
   ```

### Option 2: Vercel (Simple Deployment)

1. **Connect Repository**
   ```bash
   # Vercel will auto-detect NestJS
   vercel --prod
   ```

2. **Configure Environment Variables**
   - Set all required env vars in Vercel dashboard
   - Configure PostgreSQL database (e.g., Neon, Supabase)

3. **Deploy**
   ```bash
   vercel --prod
   ```

### Option 3: Docker Compose (Development/Staging)

```bash
cd backend
docker-compose -f docker-compose.prod.yml up -d
```

## Web Deployment

### Vercel (Recommended)

1. **Connect Repository**
   ```bash
   cd web
   vercel --prod
   ```

2. **Configure Build Settings**
   ```json
   {
     "buildCommand": "npm run build",
     "outputDirectory": ".next",
     "installCommand": "npm install"
   }
   ```

3. **Environment Variables**
   - `NEXT_PUBLIC_API_URL`: Backend API URL
   - `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`: Stripe key

4. **Custom Domain**
   ```bash
   vercel domains add lifedeck.app
   ```

### Netlify (Alternative)

1. **Connect Repository**
2. **Configure Build Settings**
   - Build command: `npm run build`
   - Publish directory: `.next`
3. **Set Environment Variables**

## iOS Deployment

### Prerequisites

1. **Apple Developer Account**
   - Enroll in Apple Developer Program
   - Create App ID: `com.lifedeck.app`
   - Configure App Store Connect

2. **Certificates & Provisioning**
   ```bash
   # Generate certificates in Xcode or manually
   # Create provisioning profiles
   ```

### Build & Upload

1. **Configure Project**
   ```bash
   cd LifeDeck
   open LifeDeck.xcodeproj
   ```

2. **Update Configuration**
   - Set bundle identifier
   - Configure signing certificates
   - Update API endpoints
   - Configure In-App Purchase products

3. **Build Archive**
   ```bash
   # In Xcode: Product > Archive
   ```

4. **Upload to App Store**
   ```bash
   # Use Xcode Organizer or Transporter app
   ```

5. **TestFlight Distribution**
   - Create TestFlight build
   - Invite beta testers
   - Collect feedback

6. **App Store Submission**
   - Prepare screenshots and metadata
   - Submit for review
   - Monitor review status

### In-App Purchase Setup

1. **App Store Connect**
   - Create subscription products
   - Set pricing and availability
   - Configure shared secret

2. **Code Configuration**
   ```swift
   // Update product IDs in SubscriptionManager
   let productIds = ["com.lifedeck.premium.monthly"]
   ```

## Android Deployment

### Prerequisites

1. **Google Play Console**
   - Create developer account
   - Set up app listing
   - Configure payment profile

2. **Signing Configuration**
   ```bash
   # Generate upload key
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

### Build & Upload

1. **Configure Project**
   ```bash
   cd android
   # Update gradle.properties with signing config
   ```

2. **Build Release APK/AAB**
   ```bash
   cd android
   ./gradlew assembleRelease  # APK
   ./gradlew bundleRelease    # AAB (recommended)
   ```

3. **Upload to Play Console**
   - Create new release
   - Upload bundle
   - Add release notes
   - Set rollout percentage

4. **Internal/Closed Testing**
   - Create testing track
   - Upload build
   - Add testers via email/group

5. **Open Testing/Beta**
   - Promote to beta track
   - Configure testing URL
   - Collect user feedback

6. **Production Release**
   - Promote to production
   - Set pricing and distribution
   - Publish app

### In-App Billing Setup

1. **Play Console**
   - Create subscription products
   - Set pricing and billing period
   - Configure grace period

2. **Code Configuration**
   ```javascript
   // Update product IDs in IAP manager
   const productIds = ['lifedeck_premium_monthly'];
   ```

## Infrastructure Setup

### AWS Infrastructure (Terraform)

```bash
cd infrastructure/terraform

# Development
terraform workspace select dev
terraform apply -var-file=dev.tfvars

# Production
terraform workspace select prod
terraform apply -var-file=prod.tfvars
```

### Kubernetes (Helm)

```bash
# Install backend
helm install lifedeck-backend ./infrastructure/helm/lifedeck-backend \
  --namespace lifedeck \
  --create-namespace

# Install web (if using Kubernetes for web)
helm install lifedeck-web ./infrastructure/helm/lifedeck-web
```

### Monitoring Setup

1. **CloudWatch (AWS)**
   ```bash
   # Set up alarms for ECS services
   aws cloudwatch put-metric-alarm \
     --alarm-name "Backend-HighCPU" \
     --alarm-description "Backend CPU > 80%" \
     --metric-name CPUUtilization \
     --namespace AWS/ECS \
     --statistic Average \
     --period 300 \
     --threshold 80 \
     --comparison-operator GreaterThanThreshold
   ```

2. **New Relic/DataDog**
   - Install agents on ECS tasks
   - Configure dashboards
   - Set up alerts

## Monitoring & Maintenance

### Health Checks

- Backend: `GET /v1/health`
- Web: Automated uptime monitoring
- Mobile: In-app health checks

### Backup Strategy

1. **Database Backups**
   ```bash
   # RDS automated backups (7-35 days retention)
   aws rds describe-db-instance-automated-backups --db-instance-identifier lifedeck-db
   ```

2. **Application Backups**
   - ECR image backups
   - Configuration backups
   - User data exports

### Scaling

1. **Horizontal Scaling**
   ```bash
   aws ecs update-service \
     --cluster lifedeck-cluster \
     --service lifedeck-backend-service \
     --desired-count 5
   ```

2. **Database Scaling**
   - RDS read replicas
   - Connection pooling
   - Query optimization

### Security Updates

1. **Dependency Updates**
   ```bash
   npm audit
   npm update
   ```

2. **Infrastructure Updates**
   ```bash
   terraform plan
   terraform apply
   ```

3. **SSL Certificate Renewal**
   - ACM auto-renews
   - Monitor expiration dates

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Check environment variables
   - Verify dependencies
   - Check build logs

2. **Database Connection Issues**
   - Verify security groups
   - Check connection strings
   - Test connectivity

3. **Performance Issues**
   - Monitor CloudWatch metrics
   - Check Redis cache hit rates
   - Analyze slow queries

### Rollback Procedures

1. **ECS Rollback**
   ```bash
   aws ecs update-service \
     --cluster lifedeck-cluster \
     --service lifedeck-backend-service \
     --task-definition lifedeck-backend:previous-version
   ```

2. **App Store Rollback**
   - Submit new version with fixes
   - Expedited review if critical

## Cost Optimization

### AWS Cost Management

1. **Reserved Instances** for steady workloads
2. **Spot Instances** for development
3. **Auto Scaling** based on demand
4. **CloudWatch billing alerts**

### Monitoring Costs

- Set up billing alerts
- Regular cost analysis
- Resource cleanup

---

For detailed configuration files and additional deployment options, see the respective platform directories and infrastructure folder.
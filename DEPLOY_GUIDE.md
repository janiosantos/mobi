# 🚀 MOBI Platform - Deploy Guide

**Version:** 1.0.0
**Last Updated:** 2025-11-20
**Target:** Production & Staging Environments

---

## 📋 Table of Contents

1. [Pre-requisites](#pre-requisites)
2. [Infrastructure Setup](#infrastructure-setup)
3. [Backend Deployment](#backend-deployment)
4. [Mobile Apps Deployment](#mobile-apps-deployment)
5. [Database Migration](#database-migration)
6. [Environment Variables](#environment-variables)
7. [SSL Configuration](#ssl-configuration)
8. [Monitoring & Logging](#monitoring--logging)
9. [Backup Strategy](#backup-strategy)
10. [CI/CD Pipeline](#cicd-pipeline)
11. [Rollback Procedures](#rollback-procedures)
12. [Troubleshooting](#troubleshooting)

---

## 🔧 Pre-requisites

### Server Requirements

**Minimum (Staging):**
- 2 vCPUs
- 4 GB RAM
- 50 GB SSD Storage
- Ubuntu 22.04 LTS or equivalent

**Recommended (Production):**
- 4+ vCPUs
- 8+ GB RAM
- 100+ GB SSD Storage
- Load Balancer
- Auto-scaling capability

### Software Stack

- **Docker:** 24.0+ & Docker Compose 2.20+
- **PostgreSQL:** 16.x
- **Redis:** 7.x
- **Nginx:** Latest stable
- **Node.js:** 18.x (for build tools)
- **PHP:** 8.3+

### External Services

- **Domain Name** with DNS access
- **SSL Certificate** (Let's Encrypt recommended)
- **Firebase Account** (Push notifications)
- **Google Maps API Key** (Geocoding & Maps)
- **MercadoPago Account** (Payment gateway)
- **AWS S3 or MinIO** (File storage)
- **Email Service** (SMTP/SES)
- **Monitoring Tool** (Sentry, Datadog, or equivalent)

---

## 🏗️ Infrastructure Setup

### Option A: Single Server (Small Scale)

```bash
# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# 3. Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 4. Verify installation
docker --version
docker-compose --version
```

### Option B: Multi-Server (High Availability)

```
┌─────────────────┐
│  Load Balancer  │  (Nginx/HAProxy)
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼────┐
│ App 1 │ │ App 2 │  (Backend API - Auto-scaling)
└───┬───┘ └──┬────┘
    │        │
┌───▼────────▼───┐
│  PostgreSQL    │  (Managed DB - RDS/Cloud SQL)
│     Primary    │
└───────┬────────┘
        │
┌───────▼────────┐
│  PostgreSQL    │  (Read Replica)
│    Replica     │
└────────────────┘

┌────────────────┐
│     Redis      │  (ElastiCache/MemoryStore)
└────────────────┘

┌────────────────┐
│      S3        │  (File Storage)
└────────────────┘
```

---

## 🐳 Backend Deployment

### 1. Clone Repository

```bash
# Create deployment directory
mkdir -p /var/www/mobi
cd /var/www/mobi

# Clone repository
git clone <repository-url> .
git checkout main  # Or your production branch
```

### 2. Configure Environment

```bash
# Copy environment file
cp .env.example .env

# Edit with production values
nano .env
```

**Critical Environment Variables (see full list below):**
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.mobi.com.br

DB_HOST=postgres
DB_DATABASE=mobi_prod
DB_USERNAME=mobi_prod_user
DB_PASSWORD=STRONG_PASSWORD_HERE

REDIS_HOST=redis
REDIS_PASSWORD=STRONG_REDIS_PASSWORD

# External Services
GOOGLE_MAPS_API_KEY=your_maps_api_key
MERCADOPAGO_PUBLIC_KEY=your_mercadopago_key
MERCADOPAGO_ACCESS_TOKEN=your_mercadopago_token
FIREBASE_CREDENTIALS=/path/to/firebase-credentials.json
```

### 3. Build & Start Containers

```bash
# Build containers
docker-compose -f docker-compose.production.yml build

# Start services
docker-compose -f docker-compose.production.yml up -d

# Verify all containers are running
docker-compose ps
```

### 4. Run Migrations & Seeders

```bash
# Enter backend container
docker-compose exec backend bash

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate --force

# Seed essential data (roles, categories, admin)
php artisan db:seed --class=RoleSeeder --force
php artisan db:seed --class=VehicleCategorySeeder --force
php artisan db:seed --class=AdminUserSeeder --force

# Create storage link
php artisan storage:link

# Cache configurations
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Start queue workers (Horizon)
php artisan horizon:install
php artisan horizon:publish
```

### 5. Configure Supervisor (Queue Workers)

Create `/etc/supervisor/conf.d/mobi-worker.conf`:

```ini
[program:mobi-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/mobi/backend/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=8
redirect_stderr=true
stdout_logfile=/var/www/mobi/backend/storage/logs/worker.log
stopwaitsecs=3600
```

```bash
# Reload supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start mobi-worker:*
```

### 6. Configure Reverb (WebSocket Server)

Create `/etc/supervisor/conf.d/mobi-reverb.conf`:

```ini
[program:mobi-reverb]
command=php /var/www/mobi/backend/artisan reverb:start
autostart=true
autorestart=true
user=www-data
redirect_stderr=true
stdout_logfile=/var/www/mobi/backend/storage/logs/reverb.log
```

```bash
sudo supervisorctl update
sudo supervisorctl start mobi-reverb
```

---

## 📱 Mobile Apps Deployment

### Android (Play Store)

#### 1. Build Release APK/AAB

```bash
cd apps/passenger  # or apps/driver

# Clean build
flutter clean
flutter pub get

# Build Android App Bundle (for Play Store)
flutter build appbundle --release

# Or build APK (for direct distribution)
flutter build apk --release --split-per-abi
```

**Output:**
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

#### 2. Upload to Play Console

1. Go to https://play.google.com/console
2. Select your app
3. Production → Create new release
4. Upload AAB file
5. Add release notes
6. Review and rollout

### iOS (App Store)

#### 1. Build Release IPA

```bash
cd apps/passenger  # or apps/driver

# Clean build
flutter clean
flutter pub get

# Build iOS Archive
flutter build ipa --release
```

#### 2. Upload to App Store Connect

```bash
# Using Transporter app or command line
xcrun altool --upload-app --type ios \
  --file build/ios/ipa/mobi_passenger.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

---

## 🗄️ Database Migration

### Initial Setup

```bash
# Backup current database (if migrating)
docker-compose exec postgres pg_dump -U mobi_user mobi > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore on new server
docker-compose exec -T postgres psql -U mobi_prod_user mobi_prod < backup.sql

# Run pending migrations
docker-compose exec backend php artisan migrate --force
```

### Zero-Downtime Migration Strategy

```bash
# 1. Put application in maintenance mode
php artisan down --refresh=15 --message="Updating database..."

# 2. Create backup
pg_dump mobi_prod > pre_migration_backup.sql

# 3. Run migrations
php artisan migrate --force

# 4. Verify application
php artisan tinker
# Test critical queries

# 5. Bring application back up
php artisan up
```

---

## 🔐 Environment Variables

### Backend (.env)

```env
# Application
APP_NAME=MOBI
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.mobi.com.br
APP_KEY=base64:GENERATE_WITH_php_artisan_key:generate

# Database
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=mobi_prod
DB_USERNAME=mobi_prod_user
DB_PASSWORD=STRONG_PASSWORD_HERE

# Redis
REDIS_HOST=redis
REDIS_PASSWORD=STRONG_REDIS_PASSWORD
REDIS_PORT=6379

# Cache & Session
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Broadcasting
BROADCAST_DRIVER=reverb
REVERB_APP_ID=mobi
REVERB_APP_KEY=GENERATE_RANDOM_KEY
REVERB_APP_SECRET=GENERATE_RANDOM_SECRET
REVERB_HOST=wss://ws.mobi.com.br
REVERB_PORT=443
REVERB_SCHEME=https

# Mail
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io  # Or SES/SendGrid
MAIL_PORT=587
MAIL_USERNAME=your_username
MAIL_PASSWORD=your_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=no-reply@mobi.com.br
MAIL_FROM_NAME="${APP_NAME}"

# Google Maps
GOOGLE_MAPS_API_KEY=your_google_maps_api_key

# Firebase (Push Notifications)
FIREBASE_CREDENTIALS=/path/to/firebase-admin-sdk.json

# MercadoPago (Payments)
MERCADOPAGO_PUBLIC_KEY=APP_USR-xxxxxxxx
MERCADOPAGO_ACCESS_TOKEN=APP_USR-xxxxxxxx
MERCADOPAGO_WEBHOOK_SECRET=your_webhook_secret

# AWS S3 (or MinIO)
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=mobi-uploads
AWS_USE_PATH_STYLE_ENDPOINT=false

# Monitoring
SENTRY_LARAVEL_DSN=https://xxxx@sentry.io/xxxx

# Admin Panel
FILAMENT_PATH=admin
```

### Mobile Apps (Flutter)

Create `apps/passenger/.env` and `apps/driver/.env`:

```env
API_BASE_URL=https://api.mobi.com.br
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_PROJECT_ID=mobi-12345
WEBSOCKET_URL=wss://ws.mobi.com.br
```

---

## 🔒 SSL Configuration

### Using Let's Encrypt (Recommended)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Generate certificate
sudo certbot --nginx -d api.mobi.com.br -d ws.mobi.com.br

# Auto-renewal (already configured by certbot)
sudo certbot renew --dry-run
```

### Nginx Configuration

Create `/etc/nginx/sites-available/mobi`:

```nginx
# API Backend
server {
    listen 80;
    server_name api.mobi.com.br;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.mobi.com.br;

    ssl_certificate /etc/letsencrypt/live/api.mobi.com.br/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.mobi.com.br/privkey.pem;

    # SSL Configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Proxy to Backend
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;
}

# WebSocket Server
server {
    listen 443 ssl http2;
    server_name ws.mobi.com.br;

    ssl_certificate /etc/letsencrypt/live/ws.mobi.com.br/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ws.mobi.com.br/privkey.pem;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/mobi /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

---

## 📊 Monitoring & Logging

### Sentry (Error Tracking)

```bash
# Install Sentry SDK (already in composer.json)
composer require sentry/sentry-laravel

# Publish config
php artisan sentry:publish --dsn=YOUR_SENTRY_DSN

# Test
php artisan sentry:test
```

### Application Logs

```bash
# View logs in real-time
tail -f backend/storage/logs/laravel.log

# Rotate logs (configure logrotate)
sudo nano /etc/logrotate.d/mobi
```

```
/var/www/mobi/backend/storage/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
}
```

### Horizon Dashboard

Access at: https://api.mobi.com.br/horizon

Secure it in `app/Providers/HorizonServiceProvider.php`:

```php
protected function gate(): void
{
    Gate::define('viewHorizon', function ($user) {
        return in_array($user->email, [
            'admin@mobi.com.br',
        ]);
    });
}
```

---

## 💾 Backup Strategy

### Automated Database Backups

Create `/usr/local/bin/mobi-backup.sh`:

```bash
#!/bin/bash

BACKUP_DIR="/var/backups/mobi"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="mobi_prod"
DB_USER="mobi_prod_user"
RETENTION_DAYS=30

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
docker-compose exec -T postgres pg_dump -U $DB_USER $DB_NAME | gzip > $BACKUP_DIR/db_backup_$DATE.sql.gz

# Backup uploaded files
tar -czf $BACKUP_DIR/storage_backup_$DATE.tar.gz backend/storage/app/public

# Remove old backups
find $BACKUP_DIR -type f -name "*.gz" -mtime +$RETENTION_DAYS -delete

# Upload to S3 (optional)
# aws s3 cp $BACKUP_DIR/db_backup_$DATE.sql.gz s3://mobi-backups/

echo "Backup completed: $DATE"
```

```bash
# Make executable
chmod +x /usr/local/bin/mobi-backup.sh

# Add to crontab (daily at 2 AM)
sudo crontab -e
```

```
0 2 * * * /usr/local/bin/mobi-backup.sh >> /var/log/mobi-backup.log 2>&1
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

Already configured in `.github/workflows/`:

- `ci.yml` - Main CI pipeline
- `backend-ci.yml` - Backend tests
- `flutter-ci.yml` - Mobile tests
- `build.yml` - Build artifacts
- `deploy.yml` - Auto-deployment

### Manual Deployment Script

Create `scripts/deploy.sh`:

```bash
#!/bin/bash

set -e

echo "🚀 Starting deployment..."

# Pull latest code
git pull origin main

# Rebuild containers
docker-compose -f docker-compose.production.yml build

# Restart services with zero downtime
docker-compose -f docker-compose.production.yml up -d --no-deps --build backend

# Run migrations
docker-compose exec backend php artisan migrate --force

# Clear caches
docker-compose exec backend php artisan cache:clear
docker-compose exec backend php artisan config:cache
docker-compose exec backend php artisan route:cache

# Restart queue workers
docker-compose exec backend php artisan queue:restart

echo "✅ Deployment completed successfully!"
```

---

## ⏮️ Rollback Procedures

### Quick Rollback

```bash
# 1. Switch to previous git commit
git log --oneline  # Find previous stable commit
git checkout <previous-commit-hash>

# 2. Rebuild containers
docker-compose -f docker-compose.production.yml build

# 3. Restart services
docker-compose -f docker-compose.production.yml up -d

# 4. Rollback database (if needed)
php artisan migrate:rollback --step=1

# 5. Clear caches
php artisan cache:clear
php artisan config:cache
```

### Database Rollback

```bash
# Restore from backup
docker-compose exec -T postgres psql -U mobi_prod_user mobi_prod < backup_YYYYMMDD_HHMMSS.sql
```

---

## 🔍 Troubleshooting

### Common Issues

**1. Database Connection Failed**
```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Check credentials in .env
grep DB_ .env

# Test connection
docker-compose exec backend php artisan tinker
# DB::connection()->getPdo();
```

**2. Redis Connection Failed**
```bash
# Check Redis is running
docker-compose ps redis

# Test connection
docker-compose exec redis redis-cli ping
```

**3. Queue Workers Not Processing**
```bash
# Check Horizon status
php artisan horizon:status

# Restart workers
php artisan queue:restart
supervisorctl restart mobi-worker:*
```

**4. WebSocket Not Connecting**
```bash
# Check Reverb is running
docker-compose exec backend php artisan reverb:status

# Check logs
tail -f storage/logs/reverb.log
```

**5. High Memory Usage**
```bash
# Check container stats
docker stats

# Optimize PHP-FPM (in php.ini)
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
```

### Performance Tuning

```bash
# Enable OPcache (php.ini)
opcache.enable=1
opcache.memory_consumption=256
opcache.max_accelerated_files=20000

# PostgreSQL tuning (postgresql.conf)
shared_buffers = 2GB
effective_cache_size = 6GB
maintenance_work_mem = 512MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 10MB
```

---

## 📞 Support & Resources

- **Documentation:** https://docs.mobi.com.br
- **Status Page:** https://status.mobi.com.br
- **Support Email:** support@mobi.com.br
- **Emergency Hotline:** +55 11 XXXX-XXXX

---

**Last Updated:** 2025-11-20
**Maintained by:** MOBI DevOps Team
**Version:** 1.0.0

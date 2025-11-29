# 🔑 External Services Configuration Guide

**Project:** MOBI Ride-Sharing Platform
**Date:** 2025-11-20
**Purpose:** Guide for obtaining and configuring external service credentials

---

## 📋 Required Services Overview

| Service | Purpose | Priority | Cost | Setup Time |
|---------|---------|----------|------|------------|
| Google Maps API | Location services, routing, geocoding | 🔴 Critical | Free tier available | 15 min |
| Firebase (FCM) | Push notifications to mobile apps | 🔴 Critical | Free | 20 min |
| MercadoPago | Primary payment gateway (Brazil) | 🔴 Critical | Transaction fees | 30 min |
| Twilio | SMS notifications | 🟡 Important | Pay-as-you-go | 15 min |
| Email Service | Transactional emails | 🟡 Important | Free tier available | 10 min |
| EFI (Gerencianet) | Alternative payment (PIX) | 🟢 Optional | Transaction fees | 30 min |
| Stone | Alternative payment gateway | 🟢 Optional | Transaction fees | 30 min |
| PagSeguro | Alternative payment gateway | 🟢 Optional | Transaction fees | 30 min |
| Cielo | Alternative payment gateway | 🟢 Optional | Transaction fees | 30 min |

---

## 1. Google Maps API (Critical) 🔴

### What it does
- Geocoding (address → coordinates)
- Reverse geocoding (coordinates → address)
- Distance Matrix (calculate route distances)
- Directions (turn-by-turn navigation)
- Places API (search locations)

### How to get credentials

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/

2. **Create a new project**
   - Click "Select a project" → "New Project"
   - Name: "MOBI Production" (or similar)
   - Click "Create"

3. **Enable APIs**
   - Navigate to "APIs & Services" → "Library"
   - Enable these APIs:
     - ✅ Maps JavaScript API
     - ✅ Maps SDK for Android
     - ✅ Maps SDK for iOS
     - ✅ Geocoding API
     - ✅ Directions API
     - ✅ Distance Matrix API
     - ✅ Places API

4. **Create API Key**
   - Go to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "API Key"
   - Copy the API key
   - **Important:** Click "Restrict Key"
     - Application restrictions: Set based on your deployment
     - API restrictions: Select only the APIs you enabled

5. **Configure Billing** (required after free tier)
   - Go to "Billing"
   - Set up billing account
   - Set budget alerts

### .env Configuration

```bash
GOOGLE_MAPS_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### Monthly Cost Estimate
- **Free Tier:** $200/month credit
- **Typical Usage (100 rides/day):**
  - Geocoding: ~$5/month
  - Directions: ~$10/month
  - Distance Matrix: ~$15/month
  - **Total:** ~$30/month (covered by free tier)

### Testing
```bash
# Test geocoding
curl "https://maps.googleapis.com/maps/api/geocode/json?address=Av+Paulista,+São+Paulo&key=YOUR_API_KEY"
```

---

## 2. Firebase Cloud Messaging (Critical) 🔴

### What it does
- Send push notifications to iOS and Android apps
- Handle notification delivery and tracking
- Support for topics, user segments

### How to get credentials

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/

2. **Create new project**
   - Click "Add project"
   - Name: "MOBI" (same as Google Cloud project)
   - Enable Google Analytics (recommended)

3. **Add Android App**
   - Click "Add app" → Android icon
   - Package name: `com.mobi.passenger` (and `com.mobi.driver`)
   - Download `google-services.json`
   - Place in `apps/passenger/android/app/` and `apps/driver/android/app/`

4. **Add iOS App**
   - Click "Add app" → iOS icon
   - Bundle ID: `com.mobi.passenger` (and `com.mobi.driver`)
   - Download `GoogleService-Info.plist`
   - Add to Xcode project

5. **Get Server Key**
   - Go to Project Settings (gear icon)
   - Click "Cloud Messaging" tab
   - Copy "Server key" (legacy)
   - **Note:** New projects use FCM HTTP v1 API with service account JSON

6. **Download Service Account**
   - Project Settings → Service Accounts
   - Click "Generate new private key"
   - Save JSON file securely
   - Move to `backend/storage/firebase/credentials.json`

### .env Configuration

```bash
# Legacy (easier setup)
FCM_SERVER_KEY=AAAA_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Modern (recommended)
FIREBASE_CREDENTIALS=/path/to/firebase-credentials.json
```

### Monthly Cost
- **Free:** Unlimited notifications

### Testing
```bash
# Test notification (legacy)
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_TOKEN",
    "notification": {
      "title": "Test",
      "body": "Hello from MOBI"
    }
  }'
```

---

## 3. MercadoPago (Critical) 🔴

### What it does
- Process credit/debit card payments
- PIX instant payments
- Payment notifications via webhooks
- Refunds and chargebacks

### How to get credentials

1. **Create MercadoPago Account**
   - Visit: https://www.mercadopago.com.br/developers
   - Sign up for business account
   - Complete KYC verification

2. **Access Developer Panel**
   - Go to "Suas integrações"
   - Create new application
   - Name: "MOBI Platform"

3. **Get Credentials**
   - Click on your application
   - Go to "Credenciais"
   - You'll see:
     - **Public Key** (for frontend)
     - **Access Token** (for backend)
   - **Important:** Use "Produção" credentials for production

4. **Configure Webhooks**
   - Go to "Webhooks"
   - Add URL: `https://your-domain.com/api/v1/webhooks/mercadopago`
   - Select events:
     - ✅ Pagamentos
     - ✅ Chargebacks
     - ✅ Reembolsos

### .env Configuration

```bash
# Production
MERCADOPAGO_PUBLIC_KEY=APP_USR-XXXXXXXX-XXXXXX-XXXX-XXXX-XXXXXXXXXXXX
MERCADOPAGO_ACCESS_TOKEN=APP_USR-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Sandbox (testing)
MERCADOPAGO_PUBLIC_KEY=TEST-XXXXXXXX-XXXXXX-XXXX-XXXX-XXXXXXXXXXXX
MERCADOPAGO_ACCESS_TOKEN=TEST-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### Transaction Fees (Brazil)
- **Credit Card:** 4.99% + R$0.40 per transaction
- **Debit Card:** 3.99% + R$0.40 per transaction
- **PIX:** 0.99% (promotional, may change)
- **Typical Ride (R$20):** ~R$1.40 fee

### Testing
```bash
# Test payment
curl -X POST https://api.mercadopago.com/v1/payments \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "transaction_amount": 100,
    "description": "Test ride",
    "payment_method_id": "pix",
    "payer": {"email": "test@test.com"}
  }'
```

---

## 4. Twilio (Important) 🟡

### What it does
- Send SMS notifications
- Emergency alerts
- OTP verification
- Driver/passenger notifications

### How to get credentials

1. **Create Twilio Account**
   - Visit: https://www.twilio.com/try-twilio
   - Sign up for free trial ($15 credit)

2. **Get Phone Number**
   - Go to Phone Numbers → Buy a Number
   - Choose Brazil (+55) number with SMS capability
   - Cost: ~$1/month

3. **Get Credentials**
   - Dashboard → Account Info
   - Copy:
     - **Account SID**
     - **Auth Token**
     - **Phone Number**

4. **Configure Messaging Service** (optional, recommended)
   - Go to Messaging → Services
   - Create new service
   - Add your phone number
   - Get Messaging Service SID

### .env Configuration

```bash
TWILIO_ACCOUNT_SID=ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_FROM_NUMBER=+5511999999999

# Optional
TWILIO_MESSAGING_SERVICE_SID=MGXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### Monthly Cost Estimate
- **Phone Number:** $1/month
- **SMS (Brazil):**
  - Outbound: $0.0160 per SMS
  - Typical usage (100 rides/day, 2 SMS/ride): ~$96/month
- **Alternatives:** Use WhatsApp Business API (cheaper for Brazil)

### Testing
```bash
curl -X POST "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Messages.json" \
  --data-urlencode "Body=Test from MOBI" \
  --data-urlencode "From=$TWILIO_FROM_NUMBER" \
  --data-urlencode "To=+5511988887777" \
  -u $TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN
```

---

## 5. Email Service (Important) 🟡

### Options

#### Option A: Mailgun (Recommended)
- **Free Tier:** 5,000 emails/month
- **Paid:** $0.80 per 1,000 emails
- **Setup:** 15 minutes
- **Deliverability:** Excellent

#### Option B: Amazon SES
- **Free Tier:** 3,000 emails/month (if on EC2)
- **Paid:** $0.10 per 1,000 emails
- **Setup:** 20 minutes
- **Deliverability:** Excellent

#### Option C: SendGrid
- **Free Tier:** 100 emails/day
- **Paid:** $19.95/month for 50,000 emails
- **Setup:** 10 minutes

### Mailgun Setup (Recommended)

1. **Create Account**
   - Visit: https://www.mailgun.com/
   - Sign up for free account

2. **Add Domain**
   - Go to Sending → Domains
   - Add your domain (e.g., mail.mobi.com.br)
   - Add DNS records as instructed

3. **Get Credentials**
   - Click on your domain
   - Copy API Key
   - Note the domain name

### .env Configuration

```bash
MAIL_MAILER=mailgun
MAIL_HOST=smtp.mailgun.org
MAIL_PORT=587
MAIL_USERNAME=postmaster@mail.mobi.com.br
MAIL_PASSWORD=your_mailgun_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@mobi.com.br
MAIL_FROM_NAME="MOBI"

MAILGUN_DOMAIN=mail.mobi.com.br
MAILGUN_SECRET=key-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
MAILGUN_ENDPOINT=api.mailgun.net
```

### Testing
```bash
php artisan tinker
Mail::raw('Test email', fn($msg) => $msg->to('test@example.com')->subject('Test'));
```

---

## 6. Alternative Payment Gateways (Optional) 🟢

### EFI (Gerencianet) - PIX Specialist

**Best for:** PIX payments
**Setup:** https://sejaefi.com.br/

```bash
EFI_CLIENT_ID=Client_Id_XXXXXXXXXXXXXXXXXXXXXXXXXXXX
EFI_CLIENT_SECRET=Client_Secret_XXXXXXXXXXXXXXXXXXXXXXXXXXXX
EFI_SANDBOX=false
EFI_PIX_KEY=seu_email@provedor.com.br
```

### Stone

**Best for:** High volume merchants
**Setup:** https://www.stone.com.br/

```bash
STONE_API_KEY=your_stone_api_key_here
STONE_SECRET_KEY=your_stone_secret_key_here
```

### PagSeguro

**Best for:** Established businesses
**Setup:** https://pagseguro.uol.com.br/

```bash
PAGSEGURO_EMAIL=seu_email@provedor.com.br
PAGSEGURO_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
PAGSEGURO_ENV=production
```

### Cielo

**Best for:** Enterprise
**Setup:** https://www.cielo.com.br/

```bash
CIELO_MERCHANT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
CIELO_MERCHANT_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
CIELO_ENV=production
```

---

## 🔒 Security Best Practices

### Credential Storage

1. **Never commit credentials to Git**
   ```bash
   # Already in .gitignore
   .env
   .env.*
   storage/firebase/
   ```

2. **Use environment variables**
   - Development: `.env.local`
   - Staging: `.env.staging`
   - Production: Use server environment variables or secrets manager

3. **Rotate credentials regularly**
   - API keys: Every 6 months
   - Access tokens: Every 3 months
   - Service accounts: Every year

4. **Use secrets manager in production**
   - AWS Secrets Manager
   - Azure Key Vault
   - Google Secret Manager
   - HashiCorp Vault

### IP Restrictions

Configure IP restrictions where possible:
- Google Maps API: Restrict to server IPs
- Payment gateways: Add webhook IP whitelist
- Firebase: Add app fingerprints

### Monitoring

Set up alerts for:
- API quota exceeded
- Failed payment attempts
- Suspicious API usage
- Credential exposure (use GitHub secret scanning)

---

## 📊 Cost Summary (100 rides/day)

| Service | Monthly Cost | Annual Cost |
|---------|-------------|-------------|
| Google Maps API | $30 (covered by free tier) | $0 |
| Firebase FCM | $0 | $0 |
| MercadoPago | ~R$4,200 (fees on R$60k revenue) | ~R$50k |
| Twilio SMS | $96 | $1,152 |
| Mailgun | $0 (free tier) | $0 |
| **Total** | **~$126 + R$4,200** | **~$1,500 + R$50k** |

**Note:** Most cost is transaction fees (unavoidable). Actual infrastructure cost is very low.

---

## ✅ Configuration Checklist

### Development Environment
- [ ] Google Maps API key (with restrictions)
- [ ] Firebase credentials (test project)
- [ ] MercadoPago sandbox credentials
- [ ] Twilio trial account
- [ ] Mailgun free tier or Mailtrap

### Staging Environment
- [ ] Same as production but with test credentials
- [ ] Separate Firebase project
- [ ] MercadoPago sandbox
- [ ] Test payment cards

### Production Environment
- [ ] Google Maps API (production key, restricted)
- [ ] Firebase (production project, separate iOS/Android apps)
- [ ] MercadoPago production credentials
- [ ] Twilio production account with dedicated number
- [ ] Mailgun production domain (verified)
- [ ] SSL certificate for webhooks
- [ ] Webhook URLs configured in all services
- [ ] Monitoring and alerts configured
- [ ] Backup credentials stored securely

---

## 🧪 Testing Credentials

### Test Mode Credentials

Most services provide test credentials:

**MercadoPago Test Cards:**
```
Mastercard: 5031 4332 1540 6351
Visa: 4235 6477 2802 5682
CVV: Any 3 digits
Expiry: Any future date
Name: APRO (approved) or OTHE (rejected)
```

**Twilio Test Number:**
```
From: Your Twilio trial number
To: Your verified number
```

**Stripe Test Cards (if added):**
```
Success: 4242 4242 4242 4242
Decline: 4000 0000 0000 0002
```

---

## 📞 Support Contacts

| Service | Support Type | Contact |
|---------|--------------|---------|
| Google Maps | Documentation, Forums | https://developers.google.com/maps/support |
| Firebase | Email, Chat (paid) | https://firebase.google.com/support |
| MercadoPago | Email, Phone | suporte@mercadopago.com.br |
| Twilio | Email, Phone, Chat | https://www.twilio.com/help/contact |
| Mailgun | Email, Chat | support@mailgun.com |

---

## 🚀 Quick Start Commands

Once you have all credentials, configure them:

```bash
# 1. Copy example env
cp .env.example .env

# 2. Edit .env with your credentials
nano .env

# 3. Test connections
php artisan tinker
# Test Mail
Mail::raw('Test', fn($m) => $m->to('test@test.com')->subject('Test'));
# Test Notifications
// Test push notification
app(\App\Jobs\SendPushNotificationJob::class)
    ->handle(User::first(), 'Test', 'Message');

# 4. Run migrations
php artisan migrate

# 5. Start services
php artisan serve
php artisan reverb:start
php artisan horizon
```

---

**Last Updated:** 2025-11-20
**Maintained By:** MOBI Development Team

# 📚 MOBI API Reference

**Version:** 1.0.0
**Base URL:** `http://localhost:8000` (Development)
**Production URL:** `https://api.mobi.com.br`
**Last Updated:** 2025-11-20

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [API Endpoints](#api-endpoints)
   - [Authentication](#authentication-endpoints)
   - [Profile Management](#profile-management)
   - [Passenger - Rides](#passenger-rides)
   - [Passenger - Payments](#passenger-payments)
   - [Passenger - Ratings](#passenger-ratings)
   - [Driver - Profile](#driver-profile)
   - [Driver - Rides](#driver-rides)
   - [Driver - Documents](#driver-documents)
   - [Driver - Earnings](#driver-earnings)
   - [Driver - Ratings](#driver-ratings)
   - [Gamification](#gamification)
   - [Safety Features](#safety-features)
   - [Chat & Messaging](#chat--messaging)
   - [Additional Features](#additional-features)
4. [Response Format](#response-format)
5. [Error Handling](#error-handling)
6. [Rate Limiting](#rate-limiting)

---

## Overview

The MOBI API is a RESTful API for the MOBI ride-sharing platform. It provides comprehensive endpoints for:

- **Passengers**: Request rides, manage payments, track trips
- **Drivers**: Accept rides, manage earnings, track statistics
- **Admin**: Monitor operations, manage users, view analytics
- **Third-party integrations**: Payment gateways, mapping services

### Key Features

- ✅ **Authentication**: JWT token-based authentication via Laravel Sanctum
- ✅ **Real-time**: WebSocket support for live updates
- ✅ **Gamification**: Complete XP, badges, and achievement system
- ✅ **Safety**: SOS alerts, emergency contacts, trip sharing
- ✅ **Payments**: Multiple gateways (PIX, cards, wallet)
- ✅ **Localization**: Portuguese (pt-BR) primary language

---

## Authentication

### Authentication Flow

1. **Register** or **Login** to receive a token
2. Include token in all authenticated requests
3. **Refresh** token before expiration
4. **Logout** to revoke token

### Headers

All authenticated requests must include:

```http
Authorization: Bearer {token}
Accept: application/json
Content-Type: application/json
```

### Token Management

- **Token Lifetime**: 30 days (configurable)
- **Refresh**: Use `/api/v1/auth/refresh` endpoint
- **Revoke**: Logout endpoint revokes current token

---

## API Endpoints

### Authentication Endpoints

#### Register Passenger

```http
POST /api/v1/auth/register/passenger
```

Create a new passenger account.

**Request Body:**
```json
{
  "name": "João Silva",
  "email": "joao@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "phone": "11999999999",
  "cpf": "12345678900",
  "birth_date": "1990-01-15",
  "gender": "male",
  "device_token": "fcm_token_here",
  "device_type": "android"
}
```

**Response (201):**
```json
{
  "message": "Passageiro registrado com sucesso!",
  "data": {
    "user": {
      "id": 1,
      "name": "João Silva",
      "email": "joao@example.com",
      "phone": "11999999999",
      "user_type": "passenger",
      "level": 1,
      "total_xp": 0,
      "created_at": "2025-11-20T10:00:00.000000Z"
    },
    "token": "1|abcdef123456..."
  }
}
```

---

#### Register Driver

```http
POST /api/v1/auth/register/driver
```

Create a new driver account (requires approval).

**Request Body:**
```json
{
  "name": "Maria Santos",
  "email": "maria@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "phone": "11988888888",
  "cpf": "98765432100",
  "birth_date": "1985-05-20",
  "gender": "female",
  "license_number": "12345678900",
  "license_expiry": "2026-12-31",
  "license_category": "B",
  "device_token": "fcm_token_here",
  "device_type": "android"
}
```

**Response (201):**
```json
{
  "message": "Motorista registrado com sucesso! Aguarde aprovação.",
  "data": {
    "user": {
      "id": 2,
      "name": "Maria Santos",
      "email": "maria@example.com",
      "user_type": "driver",
      "driver_profile": {
        "id": 1,
        "license_number": "12345678900",
        "approval_status": "pending"
      }
    },
    "token": "2|xyz789..."
  }
}
```

---

#### Login

```http
POST /api/v1/auth/login
```

Authenticate user and receive token.

**Request Body:**
```json
{
  "email": "joao@example.com",
  "password": "password123",
  "device_token": "fcm_token_here",
  "device_type": "android"
}
```

**Response (200):**
```json
{
  "message": "Login realizado com sucesso!",
  "data": {
    "user": {
      "id": 1,
      "name": "João Silva",
      "email": "joao@example.com",
      "user_type": "passenger",
      "wallet_balance": 50.00,
      "level": 5,
      "total_xp": 1250
    },
    "token": "1|newtoken123..."
  }
}
```

---

#### Get Current User

```http
GET /api/v1/auth/me
```

Retrieve authenticated user's profile.

**Headers:** `Authorization: Bearer {token}`

**Response (200):**
```json
{
  "data": {
    "id": 1,
    "name": "João Silva",
    "email": "joao@example.com",
    "phone": "11999999999",
    "user_type": "passenger",
    "profile_photo_url": "https://storage.mobi.com.br/profile-photos/user1.jpg",
    "wallet_balance": 50.00,
    "level": 5,
    "total_xp": 1250,
    "current_streak": 7,
    "created_at": "2025-01-01T00:00:00.000000Z"
  }
}
```

---

#### Logout

```http
POST /api/v1/auth/logout
```

Revoke current authentication token.

**Headers:** `Authorization: Bearer {token}`

**Response (200):**
```json
{
  "message": "Logout realizado com sucesso!"
}
```

---

#### Refresh Token

```http
POST /api/v1/auth/refresh
```

Generate a new authentication token.

**Headers:** `Authorization: Bearer {token}`

**Response (200):**
```json
{
  "message": "Token renovado com sucesso!",
  "data": {
    "token": "1|refreshed_token..."
  }
}
```

---

#### Delete Account

```http
DELETE /api/v1/auth/account
```

Permanently delete user account (soft delete).

**Headers:** `Authorization: Bearer {token}`

**Response (200):**
```json
{
  "message": "Conta excluída com sucesso!"
}
```

---

### Profile Management

#### View Profile

```http
GET /api/v1/profile
```

Get user profile information.

**Headers:** `Authorization: Bearer {token}`

**Response (200):**
```json
{
  "data": {
    "id": 1,
    "name": "João Silva",
    "email": "joao@example.com",
    "phone": "11999999999",
    "cpf": "12345678900",
    "birth_date": "1990-01-15",
    "gender": "male",
    "profile_photo_url": "https://...",
    "wallet_balance": 50.00,
    "level": 5,
    "total_xp": 1250
  }
}
```

---

#### Update Profile

```http
PUT /api/v1/profile
```

Update user profile information.

**Request Body:**
```json
{
  "name": "João Silva Jr.",
  "phone": "11977777777",
  "birth_date": "1990-01-15",
  "gender": "male"
}
```

**Response (200):**
```json
{
  "message": "Perfil atualizado com sucesso!",
  "data": {
    "id": 1,
    "name": "João Silva Jr.",
    "phone": "11977777777"
  }
}
```

---

#### Upload Profile Photo

```http
POST /api/v1/profile/photo
```

Upload or update profile photo.

**Request (multipart/form-data):**
```
profile_photo: (file, max 5MB, jpg/png)
```

**Response (200):**
```json
{
  "message": "Foto de perfil atualizada com sucesso!",
  "data": {
    "profile_photo_url": "https://storage.mobi.com.br/profile-photos/user1_new.jpg"
  }
}
```

---

#### Delete Profile Photo

```http
DELETE /api/v1/profile/photo
```

Remove profile photo.

**Response (200):**
```json
{
  "message": "Foto de perfil removida com sucesso!"
}
```

---

### Passenger - Rides

#### Estimate Ride Price

```http
POST /api/v1/passenger/rides/estimate
```

Calculate estimated price for a ride.

**Request Body:**
```json
{
  "vehicle_category_id": 1,
  "pickup_latitude": -23.5505,
  "pickup_longitude": -46.6333,
  "dropoff_latitude": -23.5629,
  "dropoff_longitude": -46.6544,
  "stops": [
    {
      "latitude": -23.5550,
      "longitude": -46.6400,
      "wait_minutes": 5
    }
  ]
}
```

**Response (200):**
```json
{
  "data": {
    "distance_km": 5.2,
    "duration_minutes": 18,
    "estimated_price": 25.50,
    "price_breakdown": {
      "base_price": 5.00,
      "distance_price": 15.60,
      "time_price": 4.90
    },
    "category": {
      "id": 1,
      "name": "Economy",
      "description": "Basic ride"
    }
  }
}
```

---

#### Create Ride

```http
POST /api/v1/passenger/rides
```

Request a new ride.

**Request Body:**
```json
{
  "vehicle_category_id": 1,
  "pickup_address": "Av. Paulista, 1000",
  "pickup_latitude": -23.5505,
  "pickup_longitude": -46.6333,
  "dropoff_address": "Av. Faria Lima, 2000",
  "dropoff_latitude": -23.5629,
  "dropoff_longitude": -46.6544,
  "payment_method_id": 1,
  "notes": "Please arrive quickly",
  "scheduled_for": "2025-11-21T14:00:00Z"
}
```

**Response (201):**
```json
{
  "message": "Corrida solicitada com sucesso!",
  "data": {
    "id": 123,
    "ride_number": "RIDE-2025-000123",
    "status": "requested",
    "pickup_address": "Av. Paulista, 1000",
    "dropoff_address": "Av. Faria Lima, 2000",
    "estimated_price": 25.50,
    "passenger": {
      "id": 1,
      "name": "João Silva"
    },
    "created_at": "2025-11-20T10:00:00.000000Z"
  }
}
```

---

#### List Rides

```http
GET /api/v1/passenger/rides
```

Get ride history with pagination.

**Query Parameters:**
- `page` (integer): Page number (default: 1)
- `per_page` (integer): Items per page (default: 20)
- `status` (string): Filter by status

**Response (200):**
```json
{
  "data": [
    {
      "id": 123,
      "ride_number": "RIDE-2025-000123",
      "status": "completed",
      "pickup_address": "Av. Paulista, 1000",
      "dropoff_address": "Av. Faria Lima, 2000",
      "final_price": 25.50,
      "driver": {
        "id": 2,
        "name": "Maria Santos",
        "average_rating": 4.8
      },
      "completed_at": "2025-11-20T11:30:00.000000Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 20,
    "total": 95
  }
}
```

---

#### Get Active Ride

```http
GET /api/v1/passenger/rides/active
```

Get current active ride (if any).

**Response (200):**
```json
{
  "data": {
    "id": 124,
    "ride_number": "RIDE-2025-000124",
    "status": "in_progress",
    "driver": {
      "id": 3,
      "name": "Carlos Lima",
      "phone": "11966666666",
      "average_rating": 4.9,
      "vehicle": {
        "make": "Honda",
        "model": "Civic",
        "year": 2022,
        "color": "Branco",
        "license_plate": "ABC1D23"
      }
    },
    "pickup_address": "Av. Paulista, 1000",
    "dropoff_address": "Av. Faria Lima, 2000",
    "estimated_price": 25.50,
    "started_at": "2025-11-20T12:00:00.000000Z"
  }
}
```

---

#### View Ride Details

```http
GET /api/v1/passenger/rides/{ride}
```

Get detailed information about a specific ride.

**Response (200):**
```json
{
  "data": {
    "id": 123,
    "ride_number": "RIDE-2025-000123",
    "status": "completed",
    "passenger": {...},
    "driver": {...},
    "vehicle": {...},
    "pickup_address": "Av. Paulista, 1000",
    "pickup_coordinates": {
      "latitude": -23.5505,
      "longitude": -46.6333
    },
    "dropoff_address": "Av. Faria Lima, 2000",
    "dropoff_coordinates": {
      "latitude": -23.5629,
      "longitude": -46.6544
    },
    "distance_km": 5.2,
    "duration_minutes": 18,
    "price_breakdown": {
      "base_price": 5.00,
      "distance_price": 15.60,
      "time_price": 4.90,
      "surge_multiplier": 1.0,
      "discount": 0.00,
      "tip": 5.00,
      "final_price": 30.50
    },
    "payment": {
      "method": "credit_card",
      "status": "paid"
    },
    "timeline": {
      "requested_at": "2025-11-20T10:00:00.000000Z",
      "accepted_at": "2025-11-20T10:02:00.000000Z",
      "driver_arrived_at": "2025-11-20T10:10:00.000000Z",
      "started_at": "2025-11-20T10:15:00.000000Z",
      "completed_at": "2025-11-20T10:33:00.000000Z"
    }
  }
}
```

---

#### Cancel Ride

```http
POST /api/v1/passenger/rides/{ride}/cancel
```

Cancel an active ride.

**Request Body:**
```json
{
  "reason": "Mudança de planos"
}
```

**Response (200):**
```json
{
  "message": "Corrida cancelada com sucesso!",
  "data": {
    "id": 123,
    "status": "cancelled",
    "cancelled_by": "passenger",
    "cancellation_reason": "Mudança de planos",
    "cancellation_fee": 0.00
  }
}
```

---

#### Track Ride

```http
GET /api/v1/passenger/rides/{ride}/track
```

Get real-time tracking information.

**Response (200):**
```json
{
  "data": {
    "ride_id": 124,
    "status": "in_progress",
    "driver_location": {
      "latitude": -23.5520,
      "longitude": -46.6350,
      "heading": 180,
      "speed_kmh": 45,
      "updated_at": "2025-11-20T12:05:30.000000Z"
    },
    "eta_minutes": 8,
    "distance_to_destination_km": 3.5
  }
}
```

---

### Passenger - Payments

#### List Payment Methods

```http
GET /api/v1/passenger/payment-methods
```

Get all saved payment methods.

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "type": "credit_card",
      "brand": "visa",
      "last_four": "1234",
      "is_default": true,
      "created_at": "2025-01-01T00:00:00.000000Z"
    },
    {
      "id": 2,
      "type": "pix",
      "is_default": false,
      "created_at": "2025-01-05T00:00:00.000000Z"
    }
  ]
}
```

---

#### Add Payment Method

```http
POST /api/v1/passenger/payment-methods
```

Add a new payment method.

**Request Body (Credit Card):**
```json
{
  "type": "credit_card",
  "card_number": "4111111111111111",
  "card_holder_name": "JOAO SILVA",
  "expiry_month": "12",
  "expiry_year": "2026",
  "cvv": "123"
}
```

**Request Body (PIX):**
```json
{
  "type": "pix"
}
```

**Response (201):**
```json
{
  "message": "Método de pagamento adicionado com sucesso!",
  "data": {
    "id": 3,
    "type": "credit_card",
    "brand": "visa",
    "last_four": "1111",
    "is_default": false
  }
}
```

---

#### Set Default Payment Method

```http
POST /api/v1/passenger/payment-methods/{paymentMethod}/set-default
```

Set a payment method as default.

**Response (200):**
```json
{
  "message": "Método de pagamento padrão atualizado!",
  "data": {
    "id": 3,
    "is_default": true
  }
}
```

---

#### Remove Payment Method

```http
DELETE /api/v1/passenger/payment-methods/{paymentMethod}
```

Remove a payment method.

**Response (200):**
```json
{
  "message": "Método de pagamento removido com sucesso!"
}
```

---

### Passenger - Ratings

#### Rate Driver

```http
POST /api/v1/passenger/ratings/rides/{ride}
```

Rate driver after completing a ride.

**Request Body:**
```json
{
  "stars": 5,
  "comment": "Excelente motorista, muito educado!",
  "tags": ["Polite", "Clean car", "Safe driving"]
}
```

**Response (201):**
```json
{
  "message": "Avaliação enviada com sucesso!",
  "data": {
    "id": 45,
    "ride_id": 123,
    "rated_user": {
      "id": 2,
      "name": "Maria Santos"
    },
    "stars": 5,
    "comment": "Excelente motorista, muito educado!",
    "tags": ["Polite", "Clean car", "Safe driving"],
    "created_at": "2025-11-20T11:35:00.000000Z"
  }
}
```

---

### Driver - Profile

#### Get Driver Profile

```http
GET /api/v1/driver/profile
```

Get driver profile with statistics.

**Headers:** `Authorization: Bearer {driver_token}`

**Response (200):**
```json
{
  "data": {
    "id": 1,
    "user": {
      "id": 2,
      "name": "Maria Santos",
      "email": "maria@example.com",
      "phone": "11988888888"
    },
    "license_number": "12345678900",
    "license_expiry": "2026-12-31",
    "license_category": "B",
    "approval_status": "approved",
    "is_online": false,
    "total_rides": 342,
    "completed_rides": 330,
    "cancelled_rides": 12,
    "average_rating": 4.8,
    "total_ratings": 285,
    "total_earnings": 15230.50,
    "available_balance": 2450.00,
    "withdrawn_balance": 12780.50
  }
}
```

---

#### Update Driver Profile

```http
PUT /api/v1/driver/profile
```

Update driver profile information.

**Request Body:**
```json
{
  "license_expiry": "2027-12-31",
  "bank_account": {
    "bank_code": "001",
    "agency": "1234",
    "account": "12345-6",
    "account_type": "checking"
  }
}
```

**Response (200):**
```json
{
  "message": "Perfil atualizado com sucesso!",
  "data": {
    "license_expiry": "2027-12-31"
  }
}
```

---

#### Go Online

```http
POST /api/v1/driver/online
```

Set driver status to online (available for rides).

**Response (200):**
```json
{
  "message": "Você está online agora!",
  "data": {
    "is_online": true,
    "current_location": {
      "latitude": -23.5505,
      "longitude": -46.6333
    }
  }
}
```

---

#### Go Offline

```http
POST /api/v1/driver/offline
```

Set driver status to offline (not available).

**Response (200):**
```json
{
  "message": "Você está offline agora!",
  "data": {
    "is_online": false
  }
}
```

---

#### Get Online Status

```http
GET /api/v1/driver/status
```

Check current online/offline status.

**Response (200):**
```json
{
  "data": {
    "is_online": true,
    "is_available": true,
    "current_location": {
      "latitude": -23.5505,
      "longitude": -46.6333,
      "updated_at": "2025-11-20T12:00:00.000000Z"
    }
  }
}
```

---

### Driver - Rides

#### Get Available Rides

```http
GET /api/v1/driver/rides/available
```

Get nearby available ride requests.

**Query Parameters:**
- `radius_km` (float): Search radius (default: 5)

**Response (200):**
```json
{
  "data": [
    {
      "id": 125,
      "ride_number": "RIDE-2025-000125",
      "passenger": {
        "id": 5,
        "name": "Pedro Costa",
        "average_rating": 4.7
      },
      "pickup_address": "Av. Paulista, 1000",
      "pickup_coordinates": {
        "latitude": -23.5505,
        "longitude": -46.6333
      },
      "dropoff_address": "Av. Faria Lima, 2000",
      "estimated_price": 25.50,
      "distance_to_pickup_km": 1.2,
      "eta_to_pickup_minutes": 4,
      "requested_at": "2025-11-20T12:10:00.000000Z"
    }
  ]
}
```

---

#### Accept Ride

```http
POST /api/v1/driver/rides/{ride}/accept
```

Accept a ride request.

**Response (200):**
```json
{
  "message": "Corrida aceita com sucesso!",
  "data": {
    "id": 125,
    "status": "accepted",
    "passenger": {
      "id": 5,
      "name": "Pedro Costa",
      "phone": "11955555555",
      "profile_photo_url": "..."
    },
    "pickup_address": "Av. Paulista, 1000",
    "dropoff_address": "Av. Faria Lima, 2000",
    "estimated_price": 25.50
  }
}
```

---

#### Mark Arrived at Pickup

```http
POST /api/v1/driver/rides/{ride}/arrive
```

Notify passenger that driver has arrived.

**Response (200):**
```json
{
  "message": "Passageiro notificado da sua chegada!",
  "data": {
    "id": 125,
    "status": "driver_arrived",
    "driver_arrived_at": "2025-11-20T12:14:00.000000Z"
  }
}
```

---

#### Start Ride

```http
POST /api/v1/driver/rides/{ride}/start
```

Start the ride (passenger is in the car).

**Response (200):**
```json
{
  "message": "Corrida iniciada!",
  "data": {
    "id": 125,
    "status": "in_progress",
    "started_at": "2025-11-20T12:15:00.000000Z"
  }
}
```

---

#### Complete Ride

```http
POST /api/v1/driver/rides/{ride}/complete
```

Mark ride as completed.

**Request Body (optional):**
```json
{
  "final_latitude": -23.5629,
  "final_longitude": -46.6544,
  "final_distance_km": 5.2
}
```

**Response (200):**
```json
{
  "message": "Corrida concluída com sucesso!",
  "data": {
    "id": 125,
    "status": "completed",
    "final_price": 25.50,
    "driver_earnings": 21.68,
    "platform_fee": 3.82,
    "completed_at": "2025-11-20T12:33:00.000000Z"
  }
}
```

---

#### Cancel Ride (Driver)

```http
POST /api/v1/driver/rides/{ride}/cancel
```

Cancel an accepted ride.

**Request Body:**
```json
{
  "reason": "Problema mecânico"
}
```

**Response (200):**
```json
{
  "message": "Corrida cancelada.",
  "data": {
    "id": 125,
    "status": "cancelled",
    "cancelled_by": "driver",
    "cancellation_reason": "Problema mecânico"
  }
}
```

---

### Driver - Documents

#### List Documents

```http
GET /api/v1/driver/documents
```

Get all uploaded documents with approval status.

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "type": "cnh",
      "file_url": "https://storage.mobi.com.br/documents/cnh_123.jpg",
      "status": "approved",
      "reviewed_at": "2025-11-18T10:00:00.000000Z",
      "uploaded_at": "2025-11-15T14:30:00.000000Z"
    },
    {
      "id": 2,
      "type": "vehicle_registration",
      "file_url": "https://storage.mobi.com.br/documents/crlv_123.jpg",
      "status": "pending",
      "uploaded_at": "2025-11-19T09:00:00.000000Z"
    }
  ]
}
```

---

#### Upload Document

```http
POST /api/v1/driver/documents
```

Upload a KYC document.

**Request (multipart/form-data):**
```
type: "cnh" | "vehicle_registration" | "insurance" | "photo"
document: (file, max 10MB, jpg/png/pdf)
```

**Response (201):**
```json
{
  "message": "Documento enviado com sucesso! Aguarde aprovação.",
  "data": {
    "id": 3,
    "type": "insurance",
    "file_url": "https://storage.mobi.com.br/documents/insurance_123.pdf",
    "status": "pending",
    "uploaded_at": "2025-11-20T12:00:00.000000Z"
  }
}
```

---

#### Delete Document

```http
DELETE /api/v1/driver/documents/{document}
```

Delete a pending document (cannot delete approved docs).

**Response (200):**
```json
{
  "message": "Documento removido com sucesso!"
}
```

---

### Driver - Earnings

#### List Earnings

```http
GET /api/v1/driver/earnings
```

Get earnings history with pagination.

**Query Parameters:**
- `page` (integer)
- `per_page` (integer)
- `start_date` (date): Filter from date
- `end_date` (date): Filter to date

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "ride_id": 123,
      "ride_number": "RIDE-2025-000123",
      "amount": 25.50,
      "platform_fee": 3.82,
      "driver_amount": 21.68,
      "status": "paid",
      "created_at": "2025-11-20T10:33:00.000000Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total": 330
  }
}
```

---

#### Earnings Summary

```http
GET /api/v1/driver/earnings/summary
```

Get earnings summary.

**Response (200):**
```json
{
  "data": {
    "total_earnings": 15230.50,
    "available_balance": 2450.00,
    "withdrawn_balance": 12780.50,
    "pending_earnings": 125.00,
    "total_rides": 342,
    "completed_rides": 330,
    "average_per_ride": 46.15
  }
}
```

---

#### Daily Earnings

```http
GET /api/v1/driver/earnings/daily
```

Get earnings breakdown by day.

**Query Parameters:**
- `start_date` (date): Default: 7 days ago
- `end_date` (date): Default: today

**Response (200):**
```json
{
  "data": [
    {
      "date": "2025-11-20",
      "total_rides": 8,
      "total_earnings": 245.50,
      "platform_fee": 36.82,
      "driver_earnings": 208.68
    },
    {
      "date": "2025-11-19",
      "total_rides": 12,
      "total_earnings": 380.00,
      "platform_fee": 57.00,
      "driver_earnings": 323.00
    }
  ]
}
```

---

#### Request Withdrawal

```http
POST /api/v1/driver/earnings/withdraw
```

Request withdrawal of available balance.

**Request Body:**
```json
{
  "amount": 500.00,
  "bank_account": {
    "bank_code": "001",
    "agency": "1234",
    "account": "12345-6",
    "account_type": "checking"
  }
}
```

**Response (201):**
```json
{
  "message": "Solicitação de saque enviada! Processamento em até 2 dias úteis.",
  "data": {
    "id": 45,
    "amount": 500.00,
    "status": "pending",
    "estimated_completion": "2025-11-22T23:59:59.000000Z",
    "created_at": "2025-11-20T14:00:00.000000Z"
  }
}
```

---

### Gamification

#### Get Gamification Profile

```http
GET /api/v1/gamification/profile
```

Get user's gamification profile (level, XP, badges).

**Response (200):**
```json
{
  "data": {
    "user_id": 1,
    "level": 5,
    "current_xp": 250,
    "total_xp": 1250,
    "xp_to_next_level": 118,
    "current_streak": 7,
    "longest_streak": 15,
    "badges_count": 8,
    "achievements_count": 12,
    "completed_achievements": 5
  }
}
```

---

#### List Available Badges

```http
GET /api/v1/gamification/badges
```

Get all available badges.

**Response (200):**
```json
{
  "data": {
    "earned": [
      {
        "id": 1,
        "name": "First Ride",
        "description": "Complete sua primeira corrida",
        "rarity": "common",
        "icon": "🚗",
        "points": 10,
        "earned_at": "2025-01-01T10:00:00.000000Z"
      }
    ],
    "available": [
      {
        "id": 5,
        "name": "Century Club",
        "description": "Complete 100 corridas",
        "rarity": "rare",
        "icon": "💯",
        "points": 50,
        "progress": {
          "current": 42,
          "target": 100
        }
      }
    ]
  }
}
```

---

#### List Achievements

```http
GET /api/v1/gamification/achievements
```

Get all achievements with progress.

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Iniciante",
      "description": "Complete 10 corridas",
      "type": "progressive",
      "current_progress": 10,
      "target_value": 10,
      "completed": true,
      "xp_reward": 100,
      "money_reward": 10.00,
      "completed_at": "2025-01-15T12:00:00.000000Z"
    },
    {
      "id": 2,
      "name": "Veterano",
      "description": "Complete 100 corridas",
      "type": "progressive",
      "current_progress": 42,
      "target_value": 100,
      "completed": false,
      "xp_reward": 500,
      "money_reward": 50.00
    }
  ]
}
```

---

#### Get Leaderboard

```http
GET /api/v1/gamification/leaderboard
```

Get rankings for different categories.

**Query Parameters:**
- `period` (string): `weekly` | `monthly` | `all_time` (default: `all_time`)
- `category` (string): `rides` | `earnings` | `ratings` | `xp` (default: `xp`)
- `limit` (integer): Number of results (default: 100)

**Response (200):**
```json
{
  "data": {
    "period": "all_time",
    "category": "xp",
    "user_rank": 45,
    "leaderboard": [
      {
        "rank": 1,
        "user": {
          "id": 15,
          "name": "Carlos Machado",
          "level": 25
        },
        "score": 15230,
        "total_rides": 850
      },
      {
        "rank": 2,
        "user": {
          "id": 8,
          "name": "Ana Costa",
          "level": 22
        },
        "score": 12450,
        "total_rides": 720
      }
    ]
  }
}
```

---

### Safety Features

#### Add Emergency Contact

```http
POST /api/v1/emergency-contacts
```

Add an emergency contact.

**Request Body:**
```json
{
  "name": "João Silva (Pai)",
  "phone": "11999999999",
  "is_primary": true
}
```

**Response (201):**
```json
{
  "message": "Contato de emergência adicionado!",
  "data": {
    "id": 1,
    "name": "João Silva (Pai)",
    "phone": "11999999999",
    "is_primary": true
  }
}
```

---

#### Share Trip

```http
POST /api/v1/rides/{ride}/share
```

Generate a public link to share trip with contacts.

**Response (200):**
```json
{
  "message": "Link de compartilhamento gerado!",
  "data": {
    "share_code": "ABC123XYZ",
    "share_url": "https://mobi.com.br/shared-trip/ABC123XYZ",
    "expires_at": "2025-11-21T00:00:00.000000Z"
  }
}
```

---

#### View Shared Trip (Public)

```http
GET /api/v1/shared-trip/{code}
```

View a shared trip (no authentication required).

**Response (200):**
```json
{
  "data": {
    "ride_number": "RIDE-2025-000123",
    "passenger": {
      "name": "Pedro Costa"
    },
    "driver": {
      "name": "Maria Santos",
      "vehicle": "Honda Civic Branco - ABC1D23"
    },
    "status": "in_progress",
    "current_location": {
      "latitude": -23.5550,
      "longitude": -46.6400,
      "updated_at": "2025-11-20T12:10:00.000000Z"
    },
    "pickup_address": "Av. Paulista, 1000",
    "dropoff_address": "Av. Faria Lima, 2000",
    "started_at": "2025-11-20T12:00:00.000000Z"
  }
}
```

---

#### Trigger SOS Alert

```http
POST /api/v1/sos/activate
```

Activate emergency SOS alert.

**Request Body:**
```json
{
  "ride_id": 125,
  "latitude": -23.5550,
  "longitude": -46.6400,
  "reason": "Feeling unsafe"
}
```

**Response (201):**
```json
{
  "message": "Alerta SOS ativado! Contatos de emergência notificados.",
  "data": {
    "id": 10,
    "tracking_code": "SOS-2025-0010",
    "tracking_url": "https://mobi.com.br/track-sos/SOS-2025-0010",
    "status": "active",
    "emergency_contacts_notified": 2,
    "monitoring_center_notified": true
  }
}
```

---

#### Deactivate SOS

```http
POST /api/v1/sos/deactivate
```

Deactivate SOS alert (false alarm).

**Response (200):**
```json
{
  "message": "Alerta SOS desativado.",
  "data": {
    "status": "resolved",
    "resolved_at": "2025-11-20T12:15:00.000000Z"
  }
}
```

---

### Chat & Messaging

#### Get Chat Messages

```http
GET /api/v1/rides/{ride}/messages
```

Get chat history for a ride.

**Query Parameters:**
- `limit` (integer): Number of messages (default: 50)

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "sender": {
        "id": 1,
        "name": "Pedro Costa",
        "user_type": "passenger"
      },
      "message": "Estou no local!",
      "type": "text",
      "read_at": "2025-11-20T12:01:00.000000Z",
      "created_at": "2025-11-20T12:00:00.000000Z"
    },
    {
      "id": 2,
      "sender": {
        "id": 2,
        "name": "Maria Santos",
        "user_type": "driver"
      },
      "message": "Chegando em 2 minutos!",
      "type": "text",
      "created_at": "2025-11-20T12:00:30.000000Z"
    }
  ]
}
```

---

#### Send Message

```http
POST /api/v1/rides/{ride}/messages
```

Send a message in ride chat.

**Request Body:**
```json
{
  "message": "Estou a caminho!",
  "type": "text"
}
```

**Response (201):**
```json
{
  "message": "Mensagem enviada!",
  "data": {
    "id": 3,
    "sender": {
      "id": 1,
      "name": "Pedro Costa"
    },
    "message": "Estou a caminho!",
    "type": "text",
    "created_at": "2025-11-20T12:02:00.000000Z"
  }
}
```

---

#### Get Unread Count

```http
GET /api/v1/rides/{ride}/messages/unread-count
```

Get count of unread messages.

**Response (200):**
```json
{
  "data": {
    "unread_count": 3
  }
}
```

---

### Additional Features

#### List Vehicle Categories

```http
GET /api/v1/vehicle-categories
```

Get all available vehicle categories.

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "code": "economy",
      "name": "Economy",
      "description": "Basic ride, best value",
      "base_price": 5.00,
      "price_per_km": 3.00,
      "price_per_minute": 0.50,
      "minimum_price": 8.00,
      "max_passengers": 4,
      "features": ["Air conditioning", "Music"],
      "icon_url": "https://cdn.mobi.com.br/icons/economy.png"
    },
    {
      "id": 2,
      "code": "comfort",
      "name": "Comfort",
      "description": "Better cars, more comfort",
      "base_price": 8.00,
      "price_per_km": 4.50,
      "price_per_minute": 0.80,
      "minimum_price": 12.00,
      "max_passengers": 4,
      "features": ["Premium AC", "Premium Music", "Phone charger"],
      "icon_url": "https://cdn.mobi.com.br/icons/comfort.png"
    }
  ]
}
```

---

#### List Coupons

```http
GET /api/v1/passenger/coupons
```

Get available coupons for the user.

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "code": "WELCOME10",
      "type": "percentage",
      "value": 10,
      "max_discount": 20.00,
      "min_ride_value": 15.00,
      "valid_until": "2025-12-31T23:59:59.000000Z",
      "uses_remaining": 1
    }
  ]
}
```

---

#### Validate Coupon

```http
POST /api/v1/passenger/coupons/validate
```

Validate a coupon code for a ride.

**Request Body:**
```json
{
  "code": "WELCOME10",
  "ride_value": 50.00
}
```

**Response (200):**
```json
{
  "data": {
    "valid": true,
    "code": "WELCOME10",
    "discount_amount": 5.00,
    "final_price": 45.00,
    "message": "Cupom aplicado com sucesso!"
  }
}
```

---

#### List Notifications

```http
GET /api/v1/notifications
```

Get user notifications.

**Query Parameters:**
- `page` (integer)
- `per_page` (integer)
- `unread_only` (boolean): Filter unread only

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "type": "ride_completed",
      "title": "Corrida concluída!",
      "message": "Sua corrida foi concluída com sucesso. Avalie o motorista!",
      "data": {
        "ride_id": 123
      },
      "read_at": null,
      "created_at": "2025-11-20T12:33:00.000000Z"
    }
  ],
  "meta": {
    "unread_count": 5
  }
}
```

---

## Response Format

### Success Response

All successful requests return:

```json
{
  "message": "Operation successful message",
  "data": {
    // Response data
  }
}
```

For list/collection responses:

```json
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "last_page": 10,
    "per_page": 20,
    "total": 195
  },
  "links": {
    "first": "https://api.mobi.com.br/...",
    "last": "https://api.mobi.com.br/...",
    "prev": null,
    "next": "https://api.mobi.com.br/..."
  }
}
```

---

## Error Handling

### Error Response Format

```json
{
  "message": "Error description",
  "errors": {
    "field_name": [
      "Validation error message"
    ]
  }
}
```

### HTTP Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 204 | No Content | Request successful, no content to return |
| 400 | Bad Request | Invalid request format |
| 401 | Unauthorized | Missing or invalid authentication token |
| 403 | Forbidden | Authenticated but not authorized |
| 404 | Not Found | Resource not found |
| 422 | Unprocessable Entity | Validation error |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |
| 503 | Service Unavailable | Service temporarily unavailable |

### Common Errors

**401 Unauthorized:**
```json
{
  "message": "Unauthenticated."
}
```

**403 Forbidden:**
```json
{
  "message": "This action is unauthorized."
}
```

**404 Not Found:**
```json
{
  "message": "Resource not found."
}
```

**422 Validation Error:**
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": [
      "The email field is required."
    ],
    "password": [
      "The password must be at least 8 characters."
    ]
  }
}
```

**429 Rate Limit:**
```json
{
  "message": "Too many requests. Please try again in 60 seconds."
}
```

---

## Rate Limiting

### Limits

- **Default**: 60 requests/minute per IP
- **Authentication endpoints**: 5 requests/minute per IP
- **Driver location updates**: 120 requests/minute per driver

### Response Headers

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
Retry-After: 30
```

### Rate Limit Exceeded

When exceeded, API returns **429 Too Many Requests** with `Retry-After` header indicating seconds until reset.

---

## Interactive Documentation

**Swagger UI:** `http://localhost:8000/api/documentation`

The interactive Swagger UI allows you to:
- Explore all endpoints
- Test API calls directly
- View request/response schemas
- Authenticate and test protected endpoints

---

## Support

**Documentation:** https://docs.mobi.com.br
**API Status:** https://status.mobi.com.br
**Support Email:** dev@mobi.com.br
**GitHub Issues:** https://github.com/mobi/backend/issues

---

**Last Updated:** 2025-11-20
**API Version:** 1.0.0
**Maintained by:** MOBI Development Team

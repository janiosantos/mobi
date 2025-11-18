# 🚀 MOBI - Próximos Passos de Desenvolvimento

Este documento fornece um roteiro detalhado para continuar o desenvolvimento do sistema MOBI.

---

## 📦 ETAPA 1: Preparar Ambiente de Desenvolvimento

### 1.1 Instalar Dependências do Backend

```bash
cd backend
composer install
```

### 1.2 Configurar Banco de Dados

1. Copie o arquivo `.env.example` para `.env`:
```bash
cp .env.example .env
```

2. Configure as credenciais do banco de dados no `.env`:
```env
DB_CONNECTION=pgsql
DB_HOST=localhost
DB_PORT=5432
DB_DATABASE=mobi
DB_USERNAME=seu_usuario
DB_PASSWORD=sua_senha
```

3. Gere a chave da aplicação:
```bash
php artisan key:generate
```

4. Execute as migrations:
```bash
php artisan migrate
```

### 1.3 Configurar Redis

```env
REDIS_HOST=localhost
REDIS_PASSWORD=null
REDIS_PORT=6379
```

---

## 🔧 ETAPA 2: Implementar Services

Crie os Services na ordem de dependência:

### 2.1 Criar GoogleMapsService

**Arquivo:** `app/Services/GoogleMapsService.php`

```php
<?php

namespace App\Services;

use GuzzleHttp\Client;

class GoogleMapsService
{
    protected Client $client;
    protected string $apiKey;

    public function __construct()
    {
        $this->client = new Client();
        $this->apiKey = config('services.google.maps.api_key');
    }

    public function getDirections(array $origin, array $destination)
    {
        // Implementar chamada à API Directions
    }

    public function getDistanceMatrix(array $origins, array $destinations)
    {
        // Implementar chamada à API Distance Matrix
    }

    public function geocode(string $address)
    {
        // Implementar Geocoding
    }

    public function reverseGeocode(float $lat, float $lng)
    {
        // Implementar Reverse Geocoding
    }
}
```

### 2.2 Criar PricingService

**Arquivo:** `app/Services/PricingService.php`

```php
<?php

namespace App\Services;

use App\Models\VehicleCategory;
use App\Models\PricingRule;
use App\Models\SurgePricingLog;

class PricingService
{
    public function calculateEstimate(
        VehicleCategory $category,
        float $distance,
        int $duration,
        array $pickupLocation
    ): array {
        // 1. Buscar regra de pricing ativa
        // 2. Calcular base fare
        // 3. Calcular distance fare
        // 4. Calcular time fare
        // 5. Aplicar surge pricing se houver
        // 6. Aplicar category multiplier
        // 7. Retornar estimativa
    }

    public function getSurgeMultiplier(float $lat, float $lng): float
    {
        // Verificar se há surge pricing ativo na área
    }
}
```

### 2.3 Criar RideService

**Arquivo:** `app/Services/RideService.php`

```php
<?php

namespace App\Services;

use App\Models\Ride;
use App\Models\User;
use App\DTOs\RideDTO;
use App\Events\RideRequested;

class RideService
{
    public function __construct(
        protected GoogleMapsService $googleMaps,
        protected PricingService $pricing,
        protected DriverMatchingService $driverMatching
    ) {}

    public function estimateRide(RideDTO $data): array
    {
        // 1. Calcular rota via Google Maps
        // 2. Calcular preço via PricingService
        // 3. Retornar estimativa
    }

    public function createRide(User $passenger, RideDTO $data): Ride
    {
        // 1. Criar a corrida
        // 2. Disparar evento RideRequested
        // 3. Iniciar busca por motorista
        // 4. Retornar ride
    }

    public function acceptRide(Ride $ride, User $driver): Ride
    {
        // 1. Validar se motorista pode aceitar
        // 2. Atualizar ride
        // 3. Disparar evento RideAccepted
    }

    public function startRide(Ride $ride): Ride
    {
        // Iniciar corrida
    }

    public function completeRide(Ride $ride): Ride
    {
        // 1. Completar corrida
        // 2. Calcular ganhos do motorista
        // 3. Processar pagamento
    }

    public function cancelRide(Ride $ride, User $user, string $reason): Ride
    {
        // Cancelar corrida e aplicar penalidade se necessário
    }
}
```

### 2.4 Criar MercadoPagoService

**Arquivo:** `app/Services/MercadoPagoService.php`

```php
<?php

namespace App\Services;

use MercadoPago\SDK;
use MercadoPago\Payment;
use App\Models\Ride;

class MercadoPagoService
{
    public function __construct()
    {
        SDK::setAccessToken(config('services.mercadopago.access_token'));
    }

    public function createPixPayment(Ride $ride): array
    {
        // 1. Criar pagamento PIX
        // 2. Retornar QR Code e transaction ID
    }

    public function createCardPayment(Ride $ride, array $cardData): array
    {
        // 1. Criar pagamento com cartão
        // 2. Retornar status
    }

    public function checkPaymentStatus(string $paymentId): string
    {
        // Verificar status do pagamento
    }
}
```

### 2.5 Criar DriverMatchingService

**Arquivo:** `app/Services/DriverMatchingService.php`

```php
<?php

namespace App\Services;

use App\Models\Ride;
use App\Models\DriverProfile;
use Illuminate\Support\Collection;

class DriverMatchingService
{
    public function findNearbyDrivers(
        float $latitude,
        float $longitude,
        int $categoryId,
        float $radius = 5
    ): Collection {
        return DriverProfile::query()
            ->available()
            ->nearby($latitude, $longitude, $radius)
            ->whereHas('vehicles', function ($query) use ($categoryId) {
                $query->where('vehicle_category_id', $categoryId)
                    ->where('is_active', true);
            })
            ->get();
    }

    public function notifyDrivers(Ride $ride, Collection $drivers): void
    {
        // Enviar notificação push para motoristas próximos
    }
}
```

---

## 🎮 ETAPA 3: Implementar Controllers

### 3.1 AuthController

**Arquivo:** `app/Http/Controllers/Api/V1/Auth/AuthController.php`

```php
<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\RegisterRequest;
use App\Http\Requests\Api\V1\LoginRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(RegisterRequest $request): JsonResponse
    {
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
            'user_type' => $request->user_type ?? 'passenger',
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'user' => new UserResource($user),
            'token' => $token,
        ], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'user' => new UserResource($user),
            'token' => $token,
        ]);
    }

    public function logout(): JsonResponse
    {
        auth()->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully',
        ]);
    }

    public function me(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'user' => new UserResource(auth()->user()),
        ]);
    }
}
```

### 3.2 RideController (Passageiro)

**Arquivo:** `app/Http/Controllers/Api/V1/Passenger/RideController.php`

```php
<?php

namespace App\Http\Controllers\Api\V1\Passenger;

use App\Http\Controllers\Controller;
use App\Services\RideService;
use App\Http\Requests\Api/V1\RideEstimateRequest;
use App\Http\Requests\Api/V1\CreateRideRequest;
use App\Http\Resources\RideResource;
use Illuminate\Http\JsonResponse;

class RideController extends Controller
{
    public function __construct(
        protected RideService $rideService
    ) {}

    public function estimate(RideEstimateRequest $request): JsonResponse
    {
        $estimate = $this->rideService->estimateRide(
            $request->toDTO()
        );

        return response()->json([
            'success' => true,
            'estimate' => $estimate,
        ]);
    }

    public function store(CreateRideRequest $request): JsonResponse
    {
        $ride = $this->rideService->createRide(
            auth()->user(),
            $request->toDTO()
        );

        return response()->json([
            'success' => true,
            'ride' => new RideResource($ride),
        ], 201);
    }

    // Implementar outros métodos: index, show, cancel, track
}
```

---

## 📋 ETAPA 4: Criar DTOs

**Exemplo:** `app/DTOs/RideDTO.php`

```php
<?php

namespace App\DTOs;

class RideDTO
{
    public function __construct(
        public int $vehicleCategoryId,
        public float $pickupLatitude,
        public float $pickupLongitude,
        public string $pickupAddress,
        public float $dropoffLatitude,
        public float $dropoffLongitude,
        public string $dropoffAddress,
        public ?string $passengerNotes = null,
        public ?int $couponId = null,
    ) {}

    public static function fromRequest(array $data): self
    {
        return new self(
            vehicleCategoryId: $data['vehicle_category_id'],
            pickupLatitude: $data['pickup_latitude'],
            pickupLongitude: $data['pickup_longitude'],
            pickupAddress: $data['pickup_address'],
            dropoffLatitude: $data['dropoff_latitude'],
            dropoffLongitude: $data['dropoff_longitude'],
            dropoffAddress: $data['dropoff_address'],
            passengerNotes: $data['passenger_notes'] ?? null,
            couponId: $data['coupon_id'] ?? null,
        );
    }
}
```

---

## 🎨 ETAPA 5: Criar Seeders

**Arquivo:** `database/seeders/VehicleCategorySeeder.php`

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\VehicleCategory;

class VehicleCategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Econômico',
                'slug' => 'economy',
                'description' => 'Opção mais econômica',
                'icon' => 'car',
                'base_multiplier' => 1.0,
                'max_passengers' => 4,
                'is_active' => true,
                'sort_order' => 1,
            ],
            [
                'name' => 'Conforto',
                'slug' => 'comfort',
                'description' => 'Viagem com mais conforto',
                'icon' => 'car-luxury',
                'base_multiplier' => 1.3,
                'max_passengers' => 4,
                'is_active' => true,
                'sort_order' => 2,
            ],
            // Adicionar mais categorias
        ];

        foreach ($categories as $category) {
            VehicleCategory::create($category);
        }
    }
}
```

---

## 🔥 ETAPA 6: Implementar Eventos e Listeners

### Evento RideRequested

**Arquivo:** `app/Events/RideRequested.php`

```php
<?php

namespace App\Events;

use App\Models\Ride;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class RideRequested implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public Ride $ride
    ) {}

    public function broadcastOn(): Channel
    {
        return new Channel('available-rides');
    }

    public function broadcastAs(): string
    {
        return 'ride.requested';
    }
}
```

---

## 🐳 ETAPA 7: Configurar Docker

**Arquivo:** `infra/docker/docker-compose.yml`

```yaml
version: '3.8'

services:
  backend:
    build:
      context: ../../backend
      dockerfile: ../infra/docker/Dockerfile.backend
    ports:
      - "8000:8000"
    environment:
      - APP_ENV=local
      - DB_HOST=postgres
      - REDIS_HOST=redis
    volumes:
      - ../../backend:/var/www/html
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:15-alpine
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: mobi
      POSTGRES_USER: mobi
      POSTGRES_PASSWORD: secret
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ../../backend:/var/www/html
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - backend

volumes:
  postgres_data:
```

---

## 📱 ETAPA 8: Iniciar Apps Flutter

### 8.1 Criar estrutura do App Passageiro

```bash
cd apps
flutter create passenger
cd passenger
```

### 8.2 Adicionar dependências no `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0
  flutter_bloc: ^8.1.3
  get_it: ^7.6.4
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  socket_io_client: ^2.0.3
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
```

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

### Backend
- [ ] Implementar todos os Services
- [ ] Implementar todos os Controllers
- [ ] Criar todos os DTOs
- [ ] Criar todos os Form Requests
- [ ] Criar todos os API Resources
- [ ] Implementar Policies
- [ ] Implementar Events/Jobs/Listeners
- [ ] Criar Seeders
- [ ] Configurar Horizon
- [ ] Configurar WebSockets
- [ ] Testes automatizados

### Apps Flutter
- [ ] Estrutura base
- [ ] Design System
- [ ] Integração API
- [ ] Google Maps
- [ ] WebSockets
- [ ] Autenticação
- [ ] Telas Passageiro
- [ ] Telas Motorista

### DevOps
- [ ] Docker Compose
- [ ] CI/CD
- [ ] Scripts deploy

---

## 📚 Recursos Úteis

- [Laravel 11 Docs](https://laravel.com/docs/11.x)
- [Filament Docs](https://filamentphp.com/docs)
- [Flutter Docs](https://flutter.dev/docs)
- [Google Maps API](https://developers.google.com/maps)
- [MercadoPago API](https://www.mercadopago.com.br/developers)

---

**Boa sorte com o desenvolvimento! 🚀**

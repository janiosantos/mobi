# 🤖 CLAUDE.md - AI Assistant Guide for MOBI Platform

**Last Updated:** 2025-11-20
**Version:** 0.8.0-alpha
**Target Audience:** AI Assistants (Claude, GPT, etc.)

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Technology Stack](#technology-stack)
4. [Architecture & Design Patterns](#architecture--design-patterns)
5. [Development Workflow](#development-workflow)
6. [Coding Conventions](#coding-conventions)
7. [Testing Strategy](#testing-strategy)
8. [CI/CD Pipeline](#cicd-pipeline)
9. [Common Tasks & Commands](#common-tasks--commands)
10. [Key Features](#key-features)
11. [Database Schema](#database-schema)
12. [API Structure](#api-structure)
13. [Important Considerations](#important-considerations)
14. [Troubleshooting](#troubleshooting)

---

## 🎯 Project Overview

**MOBI** is a production-ready, enterprise-grade ride-sharing platform (similar to Uber/99) with a comprehensive backend API, mobile applications, and real-time features.

### Quick Facts

- **Platform:** Ride-sharing/mobility platform
- **Backend:** Laravel 11 (PHP 8.3)
- **Mobile:** Flutter 3.24.0 (Passenger & Driver apps)
- **Database:** PostgreSQL 16 + Redis 7
- **Real-time:** Laravel Reverb (WebSocket)
- **Admin Panel:** Filament PHP 3
- **Current Status:** Backend 65-70% complete (análise real), Apps 65-70% complete (não 30%!)
- **Test Coverage:** Backend 85%, mobi_core 70%+

### Core Capabilities

- 📱 Native mobile apps for passengers and drivers
- 🔌 RESTful API with 150+ endpoints
- ⚡ Real-time tracking via WebSocket
- 💳 Multiple payment gateways (PIX, cards, wallet)
- 🎮 Full gamification system (levels, badges, achievements)
- 🛡️ Safety features (SOS, trip sharing, emergency contacts)
- ⭐ Bidirectional rating system
- 🔔 Push notifications (Firebase)
- 👨‍💼 Admin panel with analytics

---

## 📁 Repository Structure

```
mobi/
├── backend/                 # Laravel 11 API (PRIMARY FOCUS)
│   ├── app/
│   │   ├── DTOs/           # Data Transfer Objects (5 classes)
│   │   ├── Events/         # Domain events with broadcasting (11 events)
│   │   ├── Listeners/      # Event listeners (6 listeners)
│   │   ├── Policies/       # Authorization policies (5 policies)
│   │   ├── Http/
│   │   │   ├── Controllers/Api/V1/  # API controllers (22 controllers)
│   │   │   ├── Middleware/          # Custom middleware (5)
│   │   │   ├── Requests/            # Form validation (30+ classes)
│   │   │   └── Resources/           # API resources (11+ classes)
│   │   ├── Models/         # Eloquent models (31 models)
│   │   ├── Providers/      # Service providers (8)
│   │   ├── Repositories/   # Data access layer (3 + base)
│   │   ├── Services/       # Business logic (6 services)
│   │   ├── Jobs/           # Background jobs
│   │   └── Filament/       # Admin panel (3 resources + widgets)
│   ├── database/
│   │   ├── migrations/     # 32 migrations with 40+ indexes
│   │   └── seeders/        # 3 seeders (roles, categories, admin)
│   ├── routes/             # 4 route files (150+ endpoints)
│   ├── tests/              # ~2,500 lines of tests (9 files)
│   └── config/             # 10+ configuration files
│
├── apps/                   # Flutter mobile applications
│   ├── passenger/          # Passenger app (Flutter)
│   │   ├── lib/
│   │   │   ├── bloc/       # State management (BLoC)
│   │   │   ├── screens/    # 13+ screens
│   │   │   └── core/       # DI setup (GetIt)
│   │   └── pubspec.yaml
│   └── driver/             # Driver app (Flutter)
│       └── lib/
│           ├── bloc/
│           ├── screens/
│           └── core/
│
├── packages/               # Shared Flutter code
│   └── mobi_core/          # Shared package (100+ files, 70%+ coverage)
│       ├── lib/src/
│       │   ├── models/     # 20+ shared models
│       │   ├── services/   # 7 services (API, Auth, Location, etc.)
│       │   ├── repositories/  # 10+ repositories
│       │   ├── bloc/       # 4 shared BLoCs
│       │   ├── interceptors/  # HTTP interceptors (retry, logging)
│       │   ├── cache/      # Caching system
│       │   ├── payment/    # Payment gateway integrations
│       │   ├── widgets/    # 12+ reusable widgets
│       │   ├── utils/      # 10+ utility classes
│       │   └── theme/      # App theming
│       └── test/           # 100+ tests
│
├── .github/
│   └── workflows/          # CI/CD (7 workflows)
│       ├── ci.yml          # Main CI pipeline
│       ├── backend-ci.yml  # Backend testing
│       ├── flutter-ci.yml  # Flutter testing
│       ├── build.yml       # Mobile builds (APK/AAB/IPA)
│       ├── coverage.yml    # Coverage tracking
│       ├── pr-checks.yml   # PR validation
│       └── release.yml     # Automated releases
│
├── docker-compose.yml      # Docker setup (6 services)
├── Makefile               # 29 commands for common tasks
└── *.md                   # Documentation files

Total Files: ~170+ backend files, 100+ Flutter files
```

### Key Documentation Files

- `README.md` - Project overview and quick start
- `PROJECT_STATUS.md` - Current implementation status (80% backend complete)
- `SETUP.md` - Detailed setup instructions
- `WEBSOCKET.md` - Real-time features documentation
- `FEATURES_ROADMAP.md` - Feature implementation roadmap
- `GAMIFICATION_FEATURES.md` - Gamification system documentation
- `NEXT_STEPS.md` - Next implementation priorities
- `QUICK_REFERENCE.txt` - Quick reference guide

---

## 🛠️ Technology Stack

### Backend (Laravel 11)

**Core Framework:**
- Laravel 11.x (latest stable)
- PHP 8.3 (strict types, modern features)
- Composer for dependency management

**Key Packages:**
- `laravel/sanctum ^4.0` - JWT authentication
- `laravel/horizon ^5.24` - Queue monitoring
- `laravel/reverb @beta` - WebSocket server
- `filament/filament ^3.2` - Admin panel
- `spatie/laravel-permission ^6.4` - Role-based access control
- `spatie/laravel-query-builder ^5.8` - Advanced querying
- `spatie/laravel-activitylog ^4.8` - Activity tracking
- `spatie/laravel-medialibrary ^11.4` - Media handling
- `darkaonline/l5-swagger ^8.6` - API documentation
- `mercadopago/dx-php ^3.0` - Payment integration
- `intervention/image ^3.6` - Image processing

**Database & Cache:**
- PostgreSQL 16 (primary database)
- Redis 7 (cache + queue backend)
- Database indexes: 40+ strategic indexes

**Infrastructure:**
- Docker & Docker Compose
- Nginx (web server)
- MinIO (S3-compatible storage)
- Mailpit (email testing)

### Frontend (Flutter)

**Framework:**
- Flutter 3.24.0
- Dart 3.x

**State Management:**
- `flutter_bloc ^8.1.3` - BLoC pattern
- `equatable ^2.0.5` - Value equality

**Dependency Injection:**
- `get_it ^7.6.7` - Service locator

**HTTP & API:**
- `dio ^5.4.0` - HTTP client
- `retrofit ^4.1.0` - Type-safe API calls

**Maps & Location:**
- `google_maps_flutter ^2.5.3` - Google Maps
- `geolocator ^11.0.0` - GPS location
- `geocoding ^2.1.1` - Address conversion

**Firebase:**
- `firebase_core` - Firebase initialization
- `firebase_messaging` - Push notifications

**Storage:**
- `shared_preferences` - Key-value storage
- `hive` + `hive_flutter` - Local database

**Testing:**
- `bloc_test` - BLoC testing utilities
- `mocktail` - Mocking framework
- `fake_async` - Time testing

### DevOps

**CI/CD:**
- GitHub Actions (7 workflows)
- Automated testing on push/PR
- Coverage tracking (Codecov)
- Security scanning (TruffleHog)

**Containerization:**
- Docker for development
- Docker Compose for multi-service orchestration

**Code Quality:**
- Laravel Pint (PHP formatting)
- PHPStan (static analysis)
- Flutter analyze (Dart linting)

---

## 🏗️ Architecture & Design Patterns

### Backend Architecture (Laravel)

**1. Clean Architecture**

The backend follows Clean Architecture principles with clear separation of concerns:

```
┌─────────────────────────────────────┐
│   Presentation Layer                │
│   - Controllers                     │
│   - Form Requests (Validation)      │
│   - API Resources (Transformation)  │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Business Logic Layer              │
│   - Services                        │
│   - DTOs (Data Transfer Objects)    │
│   - Events & Listeners              │
│   - Policies (Authorization)        │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Data Access Layer                 │
│   - Repositories                    │
│   - Models (Eloquent)               │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   Infrastructure                    │
│   - Database (PostgreSQL)           │
│   - Cache (Redis)                   │
│   - External APIs                   │
└─────────────────────────────────────┘
```

**2. Key Design Patterns**

- **Repository Pattern**: All database access goes through repositories
  - Location: `app/Repositories/`
  - Interfaces: `app/Repositories/Contracts/`
  - Base: `BaseRepository` provides common CRUD operations

- **DTO Pattern**: Type-safe data transfer objects
  - Location: `app/DTOs/`
  - Examples: `RideDTO`, `AuthDTO`, `LocationDTO`, `PaymentDTO`, `DriverDTO`
  - Immutable value objects for type safety

- **Service Layer Pattern**: Business logic isolation
  - Location: `app/Services/`
  - Examples: `RideService`, `PricingService`, `GoogleMapsService`, `DriverMatchingService`
  - Constructor dependency injection

- **Event-Driven Architecture**: Decoupled components
  - Events: `app/Events/` (11 events)
  - Listeners: `app/Listeners/` (6 listeners)
  - Broadcasting via WebSocket (Laravel Reverb)
  - Examples: `RideRequested`, `RideAccepted`, `RideCompleted`

- **Policy-Based Authorization**: Granular access control
  - Location: `app/Policies/`
  - Policies: `RidePolicy`, `UserPolicy`, `DriverProfilePolicy`, `VehiclePolicy`, `PaymentMethodPolicy`
  - Automatic gate registration

- **Form Request Validation**: Input validation layer
  - Location: `app/Http/Requests/`
  - 30+ request classes
  - Automatic validation before controller

- **API Resource Transformation**: Output formatting
  - Location: `app/Http/Resources/`
  - 11+ resource classes
  - Consistent API responses

**3. SOLID Principles**

- ✅ **Single Responsibility**: Each class has one job
- ✅ **Open/Closed**: Extendable via interfaces
- ✅ **Liskov Substitution**: Repository interfaces
- ✅ **Interface Segregation**: Specific contracts
- ✅ **Dependency Inversion**: Constructor injection throughout

### Frontend Architecture (Flutter)

**1. BLoC Pattern (Business Logic Component)**

State management architecture separating UI from business logic:

```
┌──────────────┐
│    Screen    │  (UI Layer)
└──────┬───────┘
       │ dispatch event
       ↓
┌──────────────┐
│     BLoC     │  (Business Logic)
│              │  - mapEventToState
│              │  - handles async operations
└──────┬───────┘
       │ emit state
       ↓
┌──────────────┐
│  Repository  │  (Data Layer)
│              │  - API calls
│              │  - local storage
└──────┬───────┘
       │
       ↓
┌──────────────┐
│   Service    │  (Infrastructure)
│              │  - HTTP client
│              │  - Firebase
│              │  - Location
└──────────────┘
```

**BLoC Components:**
- `AuthBloc` - Authentication state
- `ThemeBloc` - Dark/light mode
- `RideBloc` - Ride management
- `PaymentBloc` - Payment handling
- `ChatBloc` - Messaging
- `LocationTrackingBloc` - GPS tracking

**2. Service Locator Pattern (GetIt)**

Dependency injection via service locator:

```dart
// Registration (apps/*/lib/core/service_locator.dart)
final getIt = GetIt.instance;

void setupServiceLocator() {
  // Singletons
  getIt.registerSingleton<ApiService>(ApiService(dio));
  getIt.registerSingleton<AuthRepository>(AuthRepository(authService));

  // Lazy singletons
  getIt.registerLazySingleton<LocationService>(() => LocationService());
}

// Usage
final authRepo = getIt<AuthRepository>();
```

**3. Repository Pattern**

Data access abstraction:

```dart
class RideRepository {
  final ApiService _apiService;

  Future<Ride> createRide(RideDTO data) async {
    final response = await _apiService.createRide(data);
    return Ride.fromJson(response.data);
  }
}
```

**4. Shared Package Architecture**

`mobi_core` package provides shared functionality:
- **Models**: Shared data models
- **Services**: API, Auth, Location, Notifications
- **Repositories**: Data access
- **BLoCs**: Shared state management
- **Widgets**: Reusable UI components
- **Utils**: Helper functions
- **Theme**: Consistent styling

### Database Design

**Strategy:**
- Normalized schema (3NF)
- Strategic denormalization for performance (e.g., `rides` table)
- 40+ indexes on frequently queried columns
- Soft deletes for audit trail
- Foreign key constraints
- Composite indexes for complex queries

**Key Relationships:**
- Users → DriverProfile (1:1)
- Users → Rides (1:many as passenger/driver)
- Rides → RideStops (1:many)
- Rides → ChatMessages (1:many)
- Rides → Ratings (1:2, bidirectional)
- Users → Vehicles (1:many via DriverProfile)
- Users → PaymentMethods (1:many)
- Users → Achievements/Badges (many:many)

---

## 🔄 Development Workflow

### Git Workflow

**Branch Strategy:**
- `main` - Production-ready code
- `develop` - Integration branch
- `claude/*` - AI assistant feature branches (current: `claude/claude-md-mi7hicl3kms18o52-01SjXd88LJniYvQffwNEM9Jv`)
- Feature branches: `feature/feature-name`
- Bugfix branches: `bugfix/issue-name`

**Commit Conventions:**
Follow Conventional Commits:
```
feat: Add new feature
fix: Bug fix
refactor: Code refactoring
test: Add tests
docs: Documentation
chore: Maintenance tasks
perf: Performance improvements
style: Code style changes
```

**Examples:**
```bash
git commit -m "feat(gamification): Add achievement tracking system"
git commit -m "fix(rides): Correct pricing calculation for multi-stop rides"
git commit -m "test(backend): Add integration tests for ride flow"
```

### Development Environment Setup

**Quick Start (Docker - Recommended):**
```bash
# Clone repository
git clone <repo-url>
cd mobi

# Complete setup (builds containers, migrates DB, seeds data)
make setup

# Start services
make up

# Check status
docker-compose ps
```

**Manual Setup:**
```bash
# Backend
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan reverb:start  # WebSocket server
php artisan horizon       # Queue worker
php artisan serve         # Development server

# Flutter apps
cd apps/passenger
flutter pub get
flutter run

cd apps/driver
flutter pub get
flutter run

# Shared package
cd packages/mobi_core
flutter pub get
flutter test
```

### Environment Configuration

**Backend (.env):**
Key variables to configure:
```ini
APP_URL=http://localhost:8000
DB_HOST=postgres
DB_DATABASE=mobi
REDIS_HOST=redis

# Google Maps API (required)
GOOGLE_MAPS_API_KEY=your_key_here

# MercadoPago (payment gateway)
MERCADOPAGO_PUBLIC_KEY=your_key
MERCADOPAGO_ACCESS_TOKEN=your_token

# Firebase (push notifications)
FIREBASE_CREDENTIALS=path_to_json

# WebSocket
REVERB_HOST=localhost
REVERB_PORT=8080

# Queue
QUEUE_CONNECTION=redis
```

**Flutter (.env or config):**
```
API_BASE_URL=http://localhost:8000/api
GOOGLE_MAPS_API_KEY=your_key
FIREBASE_API_KEY=your_key
```

### Testing Workflow

**Backend Testing:**
```bash
# Run all tests
cd backend
php artisan test

# With coverage
php artisan test --coverage

# Minimum coverage threshold: 80%
php artisan test --coverage --min=80

# Specific test file
php artisan test tests/Feature/RideControllerTest.php

# Parallel testing
php artisan test --parallel
```

**Flutter Testing:**
```bash
# mobi_core tests
cd packages/mobi_core
flutter test --coverage

# App tests
cd apps/passenger
flutter test

# Integration tests
flutter test integration_test/
```

### Code Quality Checks

**Backend:**
```bash
# Code formatting (Laravel Pint)
./vendor/bin/pint

# Static analysis (PHPStan)
./vendor/bin/phpstan analyse

# Security audit
composer audit
```

**Flutter:**
```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Check for outdated dependencies
flutter pub outdated
```

### Database Workflow

**Migrations:**
```bash
# Run migrations
php artisan migrate

# Fresh migrations (wipes data)
php artisan migrate:fresh

# Fresh with seeding
php artisan migrate:fresh --seed

# Rollback last migration
php artisan migrate:rollback

# Reset all migrations
php artisan migrate:reset
```

**Seeders:**
```bash
# Run all seeders
php artisan db:seed

# Run specific seeder
php artisan db:seed --class=RoleSeeder
php artisan db:seed --class=VehicleCategorySeeder
php artisan db:seed --class=AdminUserSeeder
```

**Creating Migrations:**
```bash
# Create migration
php artisan make:migration create_table_name

# Create migration with model
php artisan make:model ModelName -m

# Full scaffold (model, migration, factory, seeder, controller)
php artisan make:model ModelName -mfsc
```

---

## 📝 Coding Conventions

### Backend (Laravel/PHP)

**Naming Conventions:**

| Type | Convention | Example |
|------|------------|---------|
| Controllers | PascalCase + `Controller` | `RideController` |
| Models | Singular PascalCase | `Ride`, `User` |
| Tables | Plural snake_case | `rides`, `users` |
| Columns | snake_case | `pickup_latitude`, `driver_id` |
| Methods | camelCase | `createRide()`, `findById()` |
| Routes | kebab-case | `/api/v1/passenger/rides` |
| Events | Past tense PascalCase | `RideCreated`, `PaymentProcessed` |
| Listeners | Action verb PascalCase | `NotifyNearbyDrivers` |
| Jobs | Action verb PascalCase | `ProcessPayment`, `SendNotification` |
| Policies | Singular + `Policy` | `RidePolicy`, `UserPolicy` |
| Requests | `{Action}{Resource}Request` | `CreateRideRequest` |
| Resources | `{Resource}Resource` | `RideResource`, `UserResource` |
| DTOs | `{Resource}DTO` | `RideDTO`, `AuthDTO` |
| Services | `{Domain}Service` | `RideService`, `PricingService` |
| Repositories | `{Model}Repository` | `UserRepository`, `RideRepository` |

**Code Style:**
- Follow PSR-12 coding standards
- Use strict types: `declare(strict_types=1);`
- Type hint everything (parameters, return types, properties)
- Use PHP 8.3 features (enums, readonly properties, etc.)
- Constructor property promotion

**Example Controller:**
```php
<?php

namespace App\Http\Controllers\Api\V1\Passenger;

use App\Http\Controllers\Controller;
use App\Http\Requests\Ride\CreateRideRequest;
use App\Http\Resources\RideResource;
use App\Services\RideService;
use Illuminate\Http\JsonResponse;

class RideController extends Controller
{
    public function __construct(
        protected RideService $rideService
    ) {}

    public function create(CreateRideRequest $request): JsonResponse
    {
        $ride = $this->rideService->createRide(
            user: $request->user(),
            data: $request->toDTO()
        );

        return response()->json([
            'success' => true,
            'message' => 'Ride created successfully',
            'data' => new RideResource($ride),
        ], 201);
    }
}
```

**Repository Pattern:**
```php
// Interface
interface RideRepositoryInterface
{
    public function find(int $id): ?Ride;
    public function create(array $data): Ride;
    public function findActiveForPassenger(int $passengerId): ?Ride;
}

// Implementation
class RideRepository extends BaseRepository implements RideRepositoryInterface
{
    protected string $model = Ride::class;

    public function findActiveForPassenger(int $passengerId): ?Ride
    {
        return $this->model::where('passenger_id', $passengerId)
            ->whereIn('status', ['requested', 'accepted', 'driver_arrived', 'in_progress'])
            ->first();
    }
}
```

**Service Layer:**
```php
class RideService
{
    public function __construct(
        protected RideRepositoryInterface $rideRepository,
        protected GoogleMapsService $googleMaps,
        protected PricingService $pricing,
    ) {}

    public function createRide(User $passenger, RideDTO $data): Ride
    {
        return DB::transaction(function () use ($passenger, $data) {
            // Business logic here
            $ride = $this->rideRepository->create([...]);

            // Fire event
            event(new RideRequested($ride));

            return $ride;
        });
    }
}
```

**Event-Driven:**
```php
// Event
class RideRequested implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public Ride $ride) {}

    public function broadcastOn(): array
    {
        return [new PrivateChannel('drivers')];
    }
}

// Listener
class NotifyNearbyDrivers implements ShouldQueue
{
    public function handle(RideRequested $event): void
    {
        // Find nearby drivers and notify
    }
}
```

**Authorization:**
```php
// Policy
class RidePolicy
{
    public function cancel(User $user, Ride $ride): bool
    {
        return $user->id === $ride->passenger_id
            && $ride->canBeCancelled();
    }
}

// Controller usage
public function cancel(Ride $ride)
{
    $this->authorize('cancel', $ride);
    // Proceed with cancellation
}
```

### Frontend (Flutter/Dart)

**Naming Conventions:**

| Type | Convention | Example |
|------|------------|---------|
| Files | snake_case | `ride_bloc.dart`, `home_screen.dart` |
| Classes | PascalCase | `RideBloc`, `HomeScreen` |
| Variables | camelCase | `rideData`, `currentUser` |
| Constants | SCREAMING_SNAKE_CASE | `API_BASE_URL`, `MAX_RETRY` |
| Private | Leading underscore | `_apiService`, `_fetchData()` |
| BLoCs | `{Feature}Bloc` | `AuthBloc`, `RideBloc` |
| Events | Action verbs | `LoginRequested`, `CreateRide` |
| States | Status nouns | `Authenticated`, `RideCreated` |
| Screens | `{Name}Screen` | `HomeScreen`, `LoginScreen` |
| Widgets | Descriptive | `CustomButton`, `RideCard` |

**Code Style:**
- Follow Effective Dart guidelines
- Use `const` constructors wherever possible
- Prefer composition over inheritance
- Use named parameters for clarity
- Avoid deeply nested widgets (extract to methods/widgets)

**Example BLoC:**
```dart
// Event
abstract class RideEvent extends Equatable {
  const RideEvent();
}

class CreateRide extends RideEvent {
  final RideDTO rideData;
  const CreateRide(this.rideData);

  @override
  List<Object> get props => [rideData];
}

// State
abstract class RideState extends Equatable {
  const RideState();
}

class RideCreated extends RideState {
  final Ride ride;
  const RideCreated(this.ride);

  @override
  List<Object> get props => [ride];
}

// BLoC
class RideBloc extends Bloc<RideEvent, RideState> {
  final RideRepository _rideRepository;

  RideBloc({required RideRepository rideRepository})
      : _rideRepository = rideRepository,
        super(const RideInitial()) {
    on<CreateRide>(_onCreateRide);
  }

  Future<void> _onCreateRide(
    CreateRide event,
    Emitter<RideState> emit,
  ) async {
    emit(const RideCreating());
    try {
      final ride = await _rideRepository.createRide(event.rideData);
      emit(RideCreated(ride));
    } catch (e) {
      emit(RideError(e.toString()));
    }
  }
}
```

**Model Pattern:**
```dart
class Ride extends Equatable {
  final int id;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final RideStatus status;
  final DateTime createdAt;

  const Ride({
    required this.id,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.status,
    required this.createdAt,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as int,
      pickupAddress: json['pickup_address'] as String,
      // ...
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickup_address': pickupAddress,
      // ...
    };
  }

  @override
  List<Object?> get props => [id, pickupAddress, /* ... */];
}
```

**Repository Pattern:**
```dart
class RideRepository {
  final ApiService _apiService;

  RideRepository({required ApiService apiService})
      : _apiService = apiService;

  Future<Ride> createRide(RideDTO data) async {
    try {
      final response = await _apiService.post(
        '/api/v1/passenger/rides',
        data: data.toJson(),
      );
      return Ride.fromJson(response.data['data']);
    } catch (e) {
      throw RideException('Failed to create ride: $e');
    }
  }
}
```

**Service Locator Setup:**
```dart
final getIt = GetIt.instance;

void setupServiceLocator() {
  // Core services
  getIt.registerLazySingleton(() => Dio());
  getIt.registerLazySingleton(() => ApiService(getIt()));

  // Repositories
  getIt.registerLazySingleton(() => AuthRepository(
    authService: getIt(),
  ));
  getIt.registerLazySingleton(() => RideRepository(
    apiService: getIt(),
  ));
}
```

### Database Conventions

**Migration Structure:**
```php
public function up(): void
{
    Schema::create('rides', function (Blueprint $table) {
        $table->id();

        // Foreign keys
        $table->foreignId('passenger_id')->constrained('users')->onDelete('cascade');
        $table->foreignId('driver_id')->nullable()->constrained('users');

        // Regular columns
        $table->string('pickup_address');
        $table->decimal('pickup_latitude', 10, 7);
        $table->decimal('pickup_longitude', 10, 7);

        // Enums
        $table->enum('status', [
            'requested', 'accepted', 'in_progress', 'completed', 'cancelled'
        ])->default('requested');

        // Timestamps
        $table->timestamps();
        $table->softDeletes();

        // Indexes
        $table->index('status');
        $table->index(['pickup_latitude', 'pickup_longitude']);
        $table->index('created_at');
    });
}
```

**Model Conventions:**
```php
class Ride extends Model
{
    use HasFactory, SoftDeletes, LogsActivity;

    // Always specify fillable/guarded
    protected $fillable = [
        'passenger_id',
        'driver_id',
        'pickup_address',
        // ...
    ];

    // Cast attributes
    protected $casts = [
        'pickup_latitude' => 'decimal:7',
        'pickup_longitude' => 'decimal:7',
        'scheduled_for' => 'datetime',
        'is_scheduled' => 'boolean',
    ];

    // Relationships
    public function passenger(): BelongsTo
    {
        return $this->belongsTo(User::class, 'passenger_id');
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->whereIn('status', [
            'requested', 'accepted', 'in_progress'
        ]);
    }

    // Helper methods
    public function canBeCancelled(): bool
    {
        return in_array($this->status, ['requested', 'accepted']);
    }
}
```

---

## 🧪 Testing Strategy

### Backend Testing (PHPUnit)

**Test Organization:**
```
tests/
├── Feature/           # Integration tests (API endpoints, full flows)
│   ├── AuthControllerTest.php
│   ├── RideControllerTest.php
│   ├── DriverRideControllerTest.php
│   └── PaymentControllerTest.php
├── Unit/             # Unit tests (isolated logic)
│   └── PolicyTest.php
└── TestCase.php      # Base test class
```

**Coverage Targets:**
- Overall: 80%+ (enforced in CI)
- Critical paths: 90%+
- Current: 85%

**Test Example:**
```php
class RideControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_passenger_can_create_ride(): void
    {
        // Arrange
        $passenger = User::factory()->passenger()->create();
        $category = VehicleCategory::factory()->create();

        // Act
        $response = $this->actingAs($passenger)
            ->postJson('/api/v1/passenger/rides', [
                'vehicle_category_id' => $category->id,
                'pickup_latitude' => -23.5505,
                'pickup_longitude' => -46.6333,
                // ...
            ]);

        // Assert
        $response->assertStatus(201);
        $response->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'id',
                'status',
                'passenger',
                // ...
            ],
        ]);

        $this->assertDatabaseHas('rides', [
            'passenger_id' => $passenger->id,
            'status' => 'requested',
        ]);
    }
}
```

**Running Tests:**
```bash
# All tests
php artisan test

# With coverage
php artisan test --coverage --min=80

# Specific test
php artisan test --filter=test_passenger_can_create_ride

# Parallel (faster)
php artisan test --parallel
```

### Flutter Testing (mobi_core)

**Test Organization:**
```
test/
├── bloc/              # BLoC tests
│   └── ride_bloc_test.dart
├── cache/             # Cache tests
├── helpers/           # Helper tests
├── interceptors/      # HTTP interceptor tests
└── repositories/      # Repository tests
```

**Coverage Target:**
- mobi_core: 70%+
- Current: 70%+

**BLoC Test Example:**
```dart
void main() {
  group('RideBloc', () {
    late RideBloc rideBloc;
    late MockRideRepository mockRepository;

    setUp(() {
      mockRepository = MockRideRepository();
      rideBloc = RideBloc(rideRepository: mockRepository);
    });

    blocTest<RideBloc, RideState>(
      'emits [RideCreating, RideCreated] when CreateRide is added',
      build: () {
        when(() => mockRepository.createRide(any()))
            .thenAnswer((_) async => mockRide);
        return rideBloc;
      },
      act: (bloc) => bloc.add(CreateRide(mockRideDTO)),
      expect: () => [
        const RideCreating(),
        RideCreated(mockRide),
      ],
    );
  });
}
```

**Running Tests:**
```bash
# All tests
cd packages/mobi_core
flutter test

# With coverage
flutter test --coverage

# Specific test
flutter test test/bloc/ride_bloc_test.dart
```

### Integration Testing

**E2E Test Example (Flutter):**
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete ride booking flow', (tester) async {
    await tester.pumpWidget(MyApp());

    // Login
    await tester.enterText(find.byKey(Key('email')), 'user@test.com');
    await tester.enterText(find.byKey(Key('password')), 'password');
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pumpAndSettle();

    // Search location
    await tester.tap(find.byKey(Key('search_button')));
    await tester.pumpAndSettle();

    // Create ride
    await tester.tap(find.byKey(Key('confirm_ride')));
    await tester.pumpAndSettle();

    // Verify ride created
    expect(find.text('Searching for driver...'), findsOneWidget);
  });
}
```

---

## 🚀 CI/CD Pipeline

### Workflows Overview

**7 GitHub Actions Workflows:**

1. **ci.yml** - Main CI Pipeline
   - Triggers: Push to `main`, `develop`, `claude/**`, PRs
   - Jobs:
     - `analyze`: Code quality (Flutter analyze, PHPStan)
     - `test-core`: mobi_core tests + coverage
     - `test-backend`: Laravel tests (PostgreSQL + Redis)
     - `test-integration`: E2E tests (main/develop only)
     - `security`: Dependency audit + TruffleHog
     - `quality-gate`: Validates all checks passed
   - Duration: ~15 minutes

2. **backend-ci.yml** - Backend Focused
   - Triggers: Changes to `backend/**`
   - Matrix: PHP 8.3
   - Services: PostgreSQL 16, Redis 7
   - Coverage minimum: 80%

3. **flutter-ci.yml** - Flutter Specific
   - Flutter version: 3.24.0
   - Tests for mobi_core and apps
   - Static analysis

4. **build.yml** - Build Artifacts
   - Android: APK + AAB
   - iOS: IPA (requires signing)
   - Artifacts retained: 90 days

5. **coverage.yml** - Coverage Tracking
   - Generates LCOV reports
   - Uploads to Codecov
   - Flags: backend, mobi_core

6. **pr-checks.yml** - PR Validation
   - Enforces code quality
   - Checks conventional commits
   - Security scanning

7. **release.yml** - Automated Releases
   - Triggers: Tags (`v*.*.*`)
   - Creates GitHub release
   - Builds and publishes to stores
   - Automated changelog

### CI/CD Best Practices

**For AI Assistants:**

1. **Always Run Tests Before Committing**
   ```bash
   # Backend
   cd backend && php artisan test

   # Flutter
   cd packages/mobi_core && flutter test
   ```

2. **Check Code Quality**
   ```bash
   # Format PHP
   ./vendor/bin/pint

   # Analyze Flutter
   flutter analyze
   ```

3. **Verify Coverage**
   ```bash
   php artisan test --coverage --min=80
   ```

4. **Commit Convention**
   - Use conventional commits
   - CI validates commit messages
   - Format: `type(scope): message`

5. **PR Workflow**
   - PRs trigger `pr-checks.yml`
   - All checks must pass before merge
   - Coverage must not decrease

---

## ⚡ Common Tasks & Commands

### Makefile Commands (Quick Reference)

The project includes a Makefile with 29 commands:

```bash
# Setup & Lifecycle
make setup          # Complete initial setup
make build          # Build Docker containers
make up            # Start all containers
make down          # Stop all containers
make restart       # Restart all containers

# Database
make migrate       # Run migrations
make migrate-fresh # Fresh migrations (WIPES DATA)
make seed          # Run seeders
make fresh         # Fresh migrations + seed

# Development
make shell         # Access backend container shell
make tinker        # Laravel Tinker REPL
make logs          # View all container logs
make test          # Run all backend tests
make test-coverage # Run tests with coverage

# Optimization
make cache-clear   # Clear all Laravel caches
make optimize      # Optimize application (routes, config, views)

# Monitoring
make watch-horizon # Monitor queue workers
make queue-work    # Run queue worker manually

# Cleanup
make clean         # Stop containers + remove volumes
make reset         # Complete reset (clean + setup)
```

### Common Development Tasks

**1. Creating a New Feature**

```bash
# Backend: Create controller, model, migration
php artisan make:model Coupon -mfsc
# Creates: Model, migration, factory, seeder, controller

# Create form request
php artisan make:request Coupon/CreateCouponRequest

# Create API resource
php artisan make:resource CouponResource

# Create policy
php artisan make:policy CouponPolicy --model=Coupon

# Create event
php artisan make:event CouponApplied

# Create listener
php artisan make:listener NotifyCouponUsage --event=CouponApplied
```

**2. Adding API Endpoint**

1. Create route in `routes/api.php`:
   ```php
   Route::prefix('v1')->group(function () {
       Route::middleware(['auth:sanctum', 'passenger'])->group(function () {
           Route::post('/coupons/apply', [CouponController::class, 'apply']);
       });
   });
   ```

2. Create controller method
3. Create form request for validation
4. Create API resource for response
5. Add tests

**3. Running Background Jobs**

```bash
# Start queue worker
php artisan queue:work

# Start Horizon (for monitoring)
php artisan horizon

# Start WebSocket server
php artisan reverb:start
```

**4. Database Operations**

```bash
# Create migration
php artisan make:migration add_column_to_table

# Run migration
php artisan migrate

# Rollback
php artisan migrate:rollback

# Fresh start (dev only)
php artisan migrate:fresh --seed

# Create seeder
php artisan make:seeder CouponSeeder

# Run specific seeder
php artisan db:seed --class=CouponSeeder
```

**5. Debugging**

```bash
# Tail logs
tail -f backend/storage/logs/laravel.log

# View queue jobs
php artisan queue:failed

# Retry failed job
php artisan queue:retry all

# Clear caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

**6. Flutter Development**

```bash
# Run app
cd apps/passenger
flutter run

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R'

# Clean build
flutter clean
flutter pub get

# Generate code (if using build_runner)
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

---

## 🎮 Key Features

### 1. Authentication & Authorization

**Endpoints:**
- `POST /api/v1/auth/register/passenger` - Register passenger
- `POST /api/v1/auth/register/driver` - Register driver
- `POST /api/v1/auth/login` - Login (returns JWT token)
- `POST /api/v1/auth/logout` - Logout
- `GET /api/v1/auth/me` - Get current user
- `POST /api/v1/auth/refresh` - Refresh token
- `DELETE /api/v1/auth/account` - Delete account

**Auth Flow:**
1. User registers (passenger or driver)
2. Email verification (optional)
3. Login receives JWT token via Sanctum
4. Token included in `Authorization: Bearer {token}` header
5. Middleware validates token: `auth:sanctum`
6. Additional middleware: `passenger`, `driver`, `driver.approved`

### 2. Ride Management

**Passenger Flow:**
1. `POST /api/v1/passenger/rides/estimate` - Get price estimate
2. `POST /api/v1/passenger/rides` - Create ride request
3. `GET /api/v1/passenger/rides/{id}` - Track ride
4. `POST /api/v1/passenger/rides/{id}/cancel` - Cancel ride
5. `POST /api/v1/passenger/rides/{id}/rate` - Rate driver

**Driver Flow:**
1. `POST /api/v1/driver/online` - Go online
2. `GET /api/v1/driver/rides/available` - View available rides nearby
3. `POST /api/v1/driver/rides/{id}/accept` - Accept ride
4. `POST /api/v1/driver/rides/{id}/arrived` - Mark arrived at pickup
5. `POST /api/v1/driver/rides/{id}/start` - Start ride
6. `POST /api/v1/driver/rides/{id}/complete` - Complete ride
7. `POST /api/v1/driver/rides/{id}/rate` - Rate passenger

**Ride Statuses:**
- `requested` → `searching` → `accepted` → `driver_arrived` → `in_progress` → `completed`
- Can be `cancelled` at any stage (with restrictions)

**Real-time Updates:**
- `RideRequested` event → broadcast to nearby drivers
- `RideAccepted` event → notify passenger
- `DriverLocationUpdated` event → update passenger map
- WebSocket channels: `private-user.{id}`, `private-ride.{id}`

### 3. Payment System

**Payment Methods:**
- PIX (Brazilian instant payment)
- Credit/Debit cards (via MercadoPago)
- Cash
- Wallet (credits)

**Endpoints:**
- `GET /api/v1/payment-methods` - List user's payment methods
- `POST /api/v1/payment-methods` - Add payment method
- `PUT /api/v1/payment-methods/{id}/default` - Set default
- `DELETE /api/v1/payment-methods/{id}` - Remove method
- `GET /api/v1/payments/history` - Payment history

**Payment Flow:**
1. Ride completed
2. `ProcessRidePayment` listener triggered
3. Charge passenger via selected payment method
4. Credit driver earnings
5. Store payment record
6. Send receipts

**Gateway Integration:**
- Primary: MercadoPago
- Alternatives: EFI, Stone, PagSeguro, Cielo (configured in mobi_core)

### 4. Gamification System

**Complete gamification with 15 badges, 9 achievements, leaderboards**

**Endpoints:**
- `GET /api/v1/gamification/profile` - User gamification profile
- `GET /api/v1/gamification/badges` - All available badges
- `GET /api/v1/gamification/achievements` - Achievements with progress
- `POST /api/v1/gamification/achievements/check` - Check achievement progress
- `GET /api/v1/gamification/leaderboard` - Rankings (weekly/monthly/all-time)
- `GET /api/v1/gamification/stats` - Global statistics

**Features:**
- **Levels & XP**: Formula `100 * level^1.5`
- **Badges**: 15 badges (Common, Rare, Epic, Legendary)
- **Achievements**: 9 achievements (Progressive, Milestone, Challenge, Secret)
- **Leaderboards**: Rankings by rides, earnings, ratings, XP
- **Streaks**: Consecutive days tracking
- **Rewards**: XP + real money rewards

**Badge Categories:**
- Rides (1, 50, 500, 1000 rides)
- Earnings (R$100, R$10k, R$100k)
- Ratings (4.5★, 4.8★, 4.9★)
- Streak (7, 30, 90 days)
- Special (night rides, weekends, helper)

**Real-time Events:**
- `achievement.completed` - Achievement unlocked
- `user.leveled-up` - Level up notification
- `badge.earned` - Badge awarded

See `GAMIFICATION_FEATURES.md` for complete documentation.

### 5. Driver Management

**Driver Registration:**
1. Register as driver (requires additional info)
2. Upload documents (CNH, vehicle docs, photo)
3. Admin reviews and approves/rejects
4. Driver can start accepting rides

**Endpoints:**
- `GET /api/v1/driver/profile` - Driver profile
- `PUT /api/v1/driver/profile` - Update profile
- `POST /api/v1/driver/online` - Go online
- `POST /api/v1/driver/offline` - Go offline
- `POST /api/v1/driver/location` - Update GPS location (real-time)
- `POST /api/v1/driver/documents` - Upload document
- `GET /api/v1/driver/documents` - List documents
- `GET /api/v1/driver/earnings` - View earnings
- `POST /api/v1/driver/earnings/withdraw` - Request withdrawal
- `GET /api/v1/driver/stats` - Driver statistics

**Driver Approval Statuses:**
- `pending` - Awaiting admin review
- `approved` - Can accept rides
- `rejected` - Cannot accept rides
- `suspended` - Temporarily blocked

**Location Tracking:**
- Drivers update location every 5-10 seconds
- Stored in database for route tracking
- Broadcast via WebSocket to active ride passenger

### 6. Vehicle Management

**Endpoints:**
- `GET /api/v1/driver/vehicles` - List vehicles
- `POST /api/v1/driver/vehicles` - Add vehicle
- `PUT /api/v1/driver/vehicles/{id}` - Update vehicle
- `DELETE /api/v1/driver/vehicles/{id}` - Remove vehicle
- `POST /api/v1/driver/vehicles/{id}/activate` - Set active vehicle

**Vehicle Categories:**
- Economy (99Pop/UberX): Basic, cheapest
- Comfort (99Taxi/Uber Comfort): Better cars, AC
- Premium (99Top/Uber Black): Premium cars
- XL (UberXL): Vans, up to 6 passengers
- Moto: Motorcycle, fastest & cheapest

**Pricing:**
- Base price + price per km + price per minute
- Minimum fare
- Surge pricing (future feature)
- Configurable per category

### 7. Chat System

**In-ride messaging between passenger and driver**

**Endpoints:**
- `GET /api/v1/rides/{ride}/messages` - Get chat history
- `POST /api/v1/rides/{ride}/messages` - Send message
- `GET /api/v1/rides/{ride}/messages/unread` - Unread count
- `POST /api/v1/rides/{ride}/messages/read` - Mark as read

**Features:**
- Text messages
- Image sharing
- Real-time delivery via WebSocket
- Read receipts
- Unread count

**WebSocket Events:**
- `message.sent` - New message
- `message.read` - Message read

### 8. Rating System

**Bidirectional ratings (passenger ↔ driver)**

**Endpoints:**
- `POST /api/v1/passenger/rides/{ride}/rate` - Rate driver
- `POST /api/v1/driver/rides/{ride}/rate` - Rate passenger

**Rating Structure:**
- Stars: 1-5
- Comment (optional)
- Tags (e.g., "Polite", "Clean car", "Safe driving")

**Average Ratings:**
- Calculated automatically
- Displayed on profiles
- Used for driver matching algorithm
- Affects gamification (badges for high ratings)

### 9. Safety Features

**Implemented:**
- Emergency contacts (add/list/remove)
- Trip sharing (generate public link)
- SOS button (triggers alert)
- Real-time location tracking

**Endpoints:**
- `POST /api/v1/emergency-contacts` - Add contact
- `GET /api/v1/emergency-contacts` - List contacts
- `DELETE /api/v1/emergency-contacts/{id}` - Remove contact
- `POST /api/v1/rides/{ride}/share` - Share trip
- `GET /api/v1/shared-trip/{code}` - View shared trip (public)
- `POST /api/v1/sos` - Trigger SOS alert
- `GET /api/v1/sos/{alert}` - SOS status

**SOS Flow:**
1. User presses SOS button
2. Alert created in database
3. Emergency contacts notified
4. Location updates tracked
5. Monitoring team notified
6. Real-time status updates

### 10. Advanced Features

**Scheduled Rides:**
- Schedule up to 30 days in advance
- System finds driver 30 min before
- Automatic notifications

**Multiple Stops:**
- Add up to 3 intermediate stops
- Automatic route recalculation
- Per-stop timing tracking

**Split Fare:**
- Divide payment among passengers
- Invite via link/code
- Individual payment tracking

**Saved Places:**
- Save home, work, favorites
- Quick address selection
- Tag-based organization

**Coupons & Referrals:**
- Apply discount coupons
- Referral system with rewards
- Usage tracking

---

## 🗄️ Database Schema

### Core Tables (31 tables)

**1. users** (Central user table)
```sql
- id, name, email, password
- phone, cpf, birth_date, gender
- user_type (passenger, driver, admin)
- profile_photo_url
- wallet_balance, referral_code, referred_by
- level, total_xp, current_xp, current_streak, longest_streak
- email_verified_at, last_active_at
- created_at, updated_at, deleted_at
```

**2. driver_profiles** (1:1 with users)
```sql
- id, user_id
- license_number, license_expiry, license_category
- vehicle_info (JSON)
- bank_account (JSON)
- approval_status (pending, approved, rejected, suspended)
- approved_by, approved_at
- is_online, current_latitude, current_longitude
- total_rides, completed_rides, cancelled_rides
- total_earnings, available_balance, withdrawn_balance
- average_rating, total_ratings
- created_at, updated_at
```

**3. rides** (Core ride table - 95+ columns)
```sql
- id, passenger_id, driver_id, vehicle_id, category_id
- pickup_address, pickup_latitude, pickup_longitude
- dropoff_address, dropoff_latitude, dropoff_longitude
- status (requested, searching, accepted, driver_arrived, in_progress, completed, cancelled)
- distance_km, duration_minutes, estimated_price
- final_price, base_price, distance_price, time_price
- surge_multiplier, discount_amount, tip_amount
- payment_method, payment_status
- scheduled_for, is_scheduled
- cancelled_by, cancellation_reason
- driver_arrived_at, started_at, completed_at
- route (JSON), stops (JSON)
- created_at, updated_at, deleted_at
- 9 indexes on status, coordinates, timestamps
```

**4. vehicles** (Driver vehicles)
```sql
- id, driver_profile_id, category_id
- make, model, year, color, license_plate
- is_active
- created_at, updated_at, deleted_at
```

**5. vehicle_categories**
```sql
- id, code (economy, comfort, premium, xl, moto)
- name, description
- base_price, price_per_km, price_per_minute, minimum_price
- max_passengers
- features (JSON)
- icon_url, is_active
```

**6. payments**
```sql
- id, ride_id, user_id, payment_method_id
- amount, currency, status
- gateway, transaction_id
- metadata (JSON)
- created_at, updated_at
```

**7. payment_methods**
```sql
- id, user_id
- type (pix, credit_card, debit_card, cash, wallet)
- last_four, brand, token
- is_default
- created_at, updated_at
```

**8. ratings** (Bidirectional)
```sql
- id, ride_id, rater_id, rated_id
- stars (1-5), comment
- tags (JSON)
- created_at, updated_at
```

**9. chat_messages**
```sql
- id, ride_id, sender_id
- message, type (text, image, system)
- read_at
- created_at, updated_at
```

**10. saved_places**
```sql
- id, user_id
- label (home, work, favorite)
- address, latitude, longitude
- created_at, updated_at
```

**11. emergency_contacts**
```sql
- id, user_id
- name, phone
- is_primary
- created_at, updated_at
```

**12. sos_alerts**
```sql
- id, user_id, ride_id
- latitude, longitude
- status (active, resolved, false_alarm)
- resolved_at, resolved_by
- created_at, updated_at
```

**13. ride_stops** (Multiple stops)
```sql
- id, ride_id
- stop_order, address, latitude, longitude
- wait_minutes
- arrived_at, departed_at
- status (pending, arrived, completed)
```

**14. ride_split_payments** (Split fare)
```sql
- id, ride_id, user_id
- amount, status (pending, paid, declined)
- payment_method, paid_at
```

**15. scheduled_rides**
```sql
- id, ride_id
- scheduled_for, status (pending, confirmed, cancelled)
- reminded_at
```

**Gamification Tables:**

**16. user_stats** (1:1 with users)
```sql
- id, user_id
- total_rides, completed_rides, cancelled_rides
- total_earnings, total_distance, total_duration
- average_rating, total_ratings
- current_streak, longest_streak, last_ride_date
- level, total_xp, current_xp
```

**17. badges**
```sql
- id, name, slug, description
- category (rides, earnings, ratings, streak, special)
- rarity (common, rare, epic, legendary)
- icon, points
- criteria (JSON)
```

**18. achievements**
```sql
- id, name, slug, description
- type (progressive, milestone, challenge, secret)
- badge_id
- target_value, xp_reward, money_reward
- is_repeatable, is_active
```

**19. user_achievements**
```sql
- id, user_id, achievement_id
- current_progress, target_value
- completed_at
- times_completed (for repeatable achievements)
```

**20. user_badges** (many-to-many)
```sql
- id, user_id, badge_id
- earned_at
```

**21. leaderboards**
```sql
- id, user_id
- period_type (weekly, monthly, all_time)
- category (rides, earnings, ratings, xp)
- score, rank
- period_start, period_end
```

**Other Tables:**

**22. coupons**
```sql
- id, code, type (percentage, fixed)
- value, max_discount
- min_ride_value, max_uses, uses_count
- valid_from, valid_until
- is_active
```

**23. coupon_usages**
```sql
- id, coupon_id, user_id, ride_id
- discount_amount
- created_at
```

**24. referrals**
```sql
- id, referrer_id, referred_id
- referrer_credit, referred_credit
- referrer_credited, referred_credited
- credited_at
```

**25. earnings** (Driver earnings)
```sql
- id, driver_id, ride_id
- amount, platform_fee, driver_amount
- status (pending, paid)
- created_at
```

**26. withdrawals** (Driver withdrawals)
```sql
- id, driver_id
- amount, status (pending, processing, completed, failed)
- bank_account (JSON)
- processed_at
```

**27. documents** (Driver documents)
```sql
- id, driver_profile_id
- type (cnh, vehicle_registration, insurance, photo)
- file_url
- status (pending, approved, rejected)
- reviewed_by, reviewed_at
- rejection_reason
```

**28. shared_rides** (Carpooling)
```sql
- id, ride_id, creator_id
- max_passengers, current_passengers
- price_per_person
- status (open, full, in_progress, completed)
```

**29. sos_location_updates**
```sql
- id, sos_alert_id
- latitude, longitude
- created_at
```

**30. sos_notifications**
```sql
- id, sos_alert_id, contact_id
- sent_at, delivered_at
```

**31. activity_log** (Spatie Activity Log)
```sql
- id, log_name, description
- subject_type, subject_id
- causer_type, causer_id
- properties (JSON)
- created_at
```

### Indexes Strategy

**40+ strategic indexes placed on:**
- Foreign keys (automatic)
- Status columns (`rides.status`, `payments.status`)
- Geographic coordinates (`pickup_latitude`, `pickup_longitude`, `current_latitude`)
- Timestamps (`created_at`, `updated_at`, `last_active_at`)
- User identifiers (`email`, `phone`, `referral_code`)
- Composite indexes (e.g., `status + created_at`, `lat + lng`)

---

## 🔌 API Structure

### API Versioning

All endpoints are versioned: `/api/v1/*`

### Authentication

**Headers:**
```
Authorization: Bearer {token}
Accept: application/json
Content-Type: application/json
```

### Response Format

**Success Response:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    // Response data
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error message",
  "errors": {
    "field": ["Validation error message"]
  }
}
```

### Pagination

**Request:**
```
GET /api/v1/passenger/rides?page=2&per_page=20
```

**Response:**
```json
{
  "success": true,
  "data": [...],
  "meta": {
    "current_page": 2,
    "from": 21,
    "last_page": 5,
    "per_page": 20,
    "to": 40,
    "total": 100
  },
  "links": {
    "first": "...",
    "last": "...",
    "prev": "...",
    "next": "..."
  }
}
```

### Rate Limiting

- **Default:** 60 requests/minute
- **Authentication:** 5 attempts/minute
- Headers returned:
  - `X-RateLimit-Limit`
  - `X-RateLimit-Remaining`
  - `Retry-After` (when exceeded)

### Error Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 422 | Validation Error |
| 429 | Rate Limit Exceeded |
| 500 | Server Error |
| 503 | Service Unavailable |

### API Endpoints Summary

**Total: 150+ endpoints**

**Auth (8 endpoints):**
- POST /v1/auth/register/passenger
- POST /v1/auth/register/driver
- POST /v1/auth/login
- POST /v1/auth/logout
- GET /v1/auth/me
- POST /v1/auth/refresh
- PUT /v1/auth/profile
- DELETE /v1/auth/account

**Passenger Rides (10 endpoints):**
- POST /v1/passenger/rides/estimate
- POST /v1/passenger/rides
- GET /v1/passenger/rides
- GET /v1/passenger/rides/{id}
- POST /v1/passenger/rides/{id}/cancel
- POST /v1/passenger/rides/{id}/rate
- GET /v1/passenger/rides/active
- GET /v1/passenger/rides/history

**Driver Rides (12 endpoints):**
- GET /v1/driver/rides/available
- POST /v1/driver/rides/{id}/accept
- POST /v1/driver/rides/{id}/arrived
- POST /v1/driver/rides/{id}/start
- POST /v1/driver/rides/{id}/complete
- POST /v1/driver/rides/{id}/cancel
- POST /v1/driver/rides/{id}/rate
- GET /v1/driver/rides
- GET /v1/driver/rides/{id}
- GET /v1/driver/rides/active
- GET /v1/driver/rides/history

**Driver Management (15+ endpoints):**
- GET /v1/driver/profile
- PUT /v1/driver/profile
- POST /v1/driver/online
- POST /v1/driver/offline
- POST /v1/driver/location
- POST /v1/driver/documents
- GET /v1/driver/documents
- GET /v1/driver/earnings
- GET /v1/driver/earnings/daily
- GET /v1/driver/earnings/weekly
- GET /v1/driver/earnings/monthly
- POST /v1/driver/earnings/withdraw
- GET /v1/driver/stats

**Vehicles (6 endpoints):**
- GET /v1/driver/vehicles
- POST /v1/driver/vehicles
- PUT /v1/driver/vehicles/{id}
- DELETE /v1/driver/vehicles/{id}
- POST /v1/driver/vehicles/{id}/activate

**Payments (8 endpoints):**
- GET /v1/payment-methods
- POST /v1/payment-methods
- PUT /v1/payment-methods/{id}
- PUT /v1/payment-methods/{id}/default
- DELETE /v1/payment-methods/{id}
- GET /v1/payments/history
- GET /v1/payments/{id}

**Gamification (6 endpoints):**
- GET /v1/gamification/profile
- GET /v1/gamification/badges
- GET /v1/gamification/achievements
- POST /v1/gamification/achievements/check
- GET /v1/gamification/leaderboard
- GET /v1/gamification/stats

**Chat (4 endpoints):**
- GET /v1/rides/{ride}/messages
- POST /v1/rides/{ride}/messages
- GET /v1/rides/{ride}/messages/unread
- POST /v1/rides/{ride}/messages/read

**Safety (7 endpoints):**
- POST /v1/emergency-contacts
- GET /v1/emergency-contacts
- DELETE /v1/emergency-contacts/{id}
- POST /v1/rides/{ride}/share
- GET /v1/shared-trip/{code}
- POST /v1/sos
- GET /v1/sos/{alert}

**Other Features:**
- Saved places (5 endpoints)
- Scheduled rides (4 endpoints)
- Split fare (4 endpoints)
- Coupons (3 endpoints)
- Referrals (3 endpoints)
- Shared rides (6 endpoints)
- Vehicle categories (2 endpoints)
- Notifications (3 endpoints)
- Webhooks (5 endpoints for payment gateways)

---

## ⚠️ Important Considerations

### For AI Assistants Working on This Project

**1. Code Quality Standards**

- **Always run tests before committing**
  - Backend: `php artisan test --coverage`
  - Flutter: `flutter test --coverage`
  - Coverage must be ≥80% (backend), ≥70% (mobi_core)

- **Follow existing patterns**
  - Don't introduce new patterns without discussion
  - Use Repository pattern for data access
  - Use DTOs for type safety
  - Use Form Requests for validation
  - Use API Resources for responses

- **Security First**
  - Never skip authorization checks
  - Always validate input via Form Requests
  - Use parameterized queries (Eloquent handles this)
  - Sanitize file uploads
  - Never commit secrets or credentials

**2. Database Changes**

- **Always create migrations for schema changes**
  - Never modify existing migrations that have been deployed
  - Create new migrations for changes
  - Include up() and down() methods

- **Add appropriate indexes**
  - Index foreign keys
  - Index columns used in WHERE clauses
  - Consider composite indexes for complex queries

- **Use soft deletes for important data**
  - Users, Rides, Payments should use soft deletes
  - Provides audit trail

**3. API Design**

- **Maintain backward compatibility**
  - Don't remove or rename existing endpoints
  - Don't change response structure of existing endpoints
  - Add new fields as nullable
  - Use API versioning (/v1, /v2) for breaking changes

- **Consistent response format**
  - Always return: `{success, message, data}`
  - Use API Resources for transformations
  - Include proper HTTP status codes

- **Proper validation**
  - Create Form Request for each endpoint
  - Validate all inputs
  - Return 422 for validation errors

**4. Real-time Features (WebSocket)**

- **Events must implement ShouldBroadcast**
  - Define broadcastOn() method
  - Use appropriate channel types (private, presence)
  - Optimize broadcast data (don't send unnecessary fields)

- **Listeners should be queued**
  - Implement ShouldQueue
  - Set queue name if needed
  - Handle failures gracefully

**5. Performance Considerations**

- **Use eager loading to avoid N+1 queries**
  ```php
  $rides = Ride::with(['passenger', 'driver', 'vehicle'])->get();
  ```

- **Cache expensive operations**
  ```php
  Cache::remember('key', $ttl, fn() => expensiveOperation());
  ```

- **Queue long-running tasks**
  ```php
  ProcessPayment::dispatch($payment)->onQueue('payments');
  ```

- **Use database indexes effectively**
  - Check query performance with EXPLAIN
  - Add indexes for frequently queried columns

**6. Error Handling**

- **Use try-catch blocks**
  ```php
  try {
      $ride = $this->rideService->createRide($data);
  } catch (\Exception $e) {
      Log::error('Failed to create ride', ['error' => $e->getMessage()]);
      return response()->json([
          'success' => false,
          'message' => 'Failed to create ride',
      ], 500);
  }
  ```

- **Log errors appropriately**
  - Use Log facade
  - Include context
  - Use appropriate log levels

**7. Testing Requirements**

- **Write tests for new features**
  - Feature tests for API endpoints
  - Unit tests for business logic
  - Integration tests for critical flows

- **Test structure**
  ```php
  public function test_feature_description(): void
  {
      // Arrange (setup)
      $user = User::factory()->create();

      // Act (perform action)
      $response = $this->actingAs($user)->postJson('/api/v1/endpoint');

      // Assert (verify)
      $response->assertStatus(200);
      $this->assertDatabaseHas('table', ['field' => 'value']);
  }
  ```

**8. Git & CI/CD**

- **Commit Message Format**
  - Use conventional commits
  - Format: `type(scope): message`
  - Examples: `feat(rides): add multi-stop support`, `fix(auth): correct token refresh`

- **Branch Naming**
  - Current development: `claude/claude-md-mi7hicl3kms18o52-01SjXd88LJniYvQffwNEM9Jv`
  - Features: `feature/feature-name`
  - Bugfixes: `bugfix/issue-name`

- **CI Pipeline**
  - All tests must pass
  - Coverage must not decrease
  - Code must pass linting
  - No security vulnerabilities

**9. Documentation**

- **Update documentation when adding features**
  - Add endpoint to this CLAUDE.md
  - Update PROJECT_STATUS.md
  - Document in code with PHPDoc/DartDoc

- **PHPDoc example**
  ```php
  /**
   * Create a new ride request.
   *
   * @param User $passenger The passenger requesting the ride
   * @param RideDTO $data The ride details
   * @return Ride The created ride
   * @throws RideException If ride creation fails
   */
  public function createRide(User $passenger, RideDTO $data): Ride
  ```

**10. Common Pitfalls to Avoid**

- ❌ **Don't bypass validation**
  - Always use Form Requests
  - Never trust client input

- ❌ **Don't skip authorization**
  - Use policies for all actions
  - Check permissions in controllers

- ❌ **Don't create N+1 queries**
  - Use eager loading
  - Monitor query count in logs

- ❌ **Don't hardcode values**
  - Use config files
  - Use constants or enums

- ❌ **Don't ignore errors**
  - Handle exceptions
  - Log for debugging
  - Return appropriate responses

- ❌ **Don't modify existing migrations**
  - Create new migrations instead
  - Old migrations may have been deployed

- ❌ **Don't commit sensitive data**
  - No API keys in code
  - Use .env files
  - Add to .gitignore

---

## 🔧 Troubleshooting

### Common Issues & Solutions

**1. Database Connection Error**

```bash
# Check if PostgreSQL is running
docker-compose ps

# Restart PostgreSQL
docker-compose restart postgres

# Check credentials in .env
DB_HOST=postgres  # Not localhost in Docker
DB_DATABASE=mobi
DB_USERNAME=mobi_user
DB_PASSWORD=mobi_password
```

**2. Redis Connection Error**

```bash
# Check if Redis is running
docker-compose ps redis

# Restart Redis
docker-compose restart redis

# Test connection
redis-cli -h localhost -p 6379 ping
```

**3. Queue Not Processing**

```bash
# Check if Horizon is running
php artisan horizon:status

# Restart Horizon
php artisan horizon:terminate
php artisan horizon

# Check failed jobs
php artisan queue:failed

# Retry all failed jobs
php artisan queue:retry all
```

**4. WebSocket Not Connecting**

```bash
# Check if Reverb is running
php artisan reverb:status

# Start Reverb
php artisan reverb:start

# Check .env configuration
REVERB_HOST=localhost
REVERB_PORT=8080

# Test WebSocket
# Should connect to ws://localhost:8080
```

**5. Tests Failing**

```bash
# Clear test database
php artisan migrate:fresh --env=testing

# Run specific test
php artisan test --filter=test_name

# Check test database config in phpunit.xml
<env name="DB_DATABASE" value="mobi_test"/>
```

**6. Migration Errors**

```bash
# Check migration status
php artisan migrate:status

# Rollback last migration
php artisan migrate:rollback

# Fresh start (CAUTION: wipes data)
php artisan migrate:fresh --seed
```

**7. Cache Issues**

```bash
# Clear all caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Or use Makefile
make cache-clear
```

**8. Composer Issues**

```bash
# Update dependencies
composer update

# Dump autoload
composer dump-autoload

# Clear composer cache
composer clear-cache
```

**9. Flutter Issues**

```bash
# Clean build
flutter clean
flutter pub get

# Clear pub cache
flutter pub cache repair

# Check Flutter doctor
flutter doctor
```

**10. Docker Issues**

```bash
# Rebuild containers
docker-compose build --no-cache

# Remove all containers and volumes
docker-compose down -v

# Check logs
docker-compose logs -f backend
```

### Getting Help

**Documentation:**
- `README.md` - Quick start guide
- `PROJECT_STATUS.md` - Current status
- `SETUP.md` - Detailed setup
- `WEBSOCKET.md` - Real-time features
- `FEATURES_ROADMAP.md` - Feature roadmap
- `GAMIFICATION_FEATURES.md` - Gamification details
- `NEXT_STEPS.md` - Next priorities

**Logs:**
- Backend: `backend/storage/logs/laravel.log`
- Docker: `docker-compose logs -f`
- Horizon: Check Horizon dashboard at `/horizon`

**Tools:**
- Laravel Tinker: `php artisan tinker`
- Database: TablePlus, DBeaver, pgAdmin
- API Testing: Postman, Insomnia
- WebSocket Testing: Postman, wscat

---

## 📊 Project Status Summary

**Current Version:** 0.8.0-alpha

**Backend:** 65-70% Complete (ANÁLISE REAL 2025-11-20)
- ✅ Core API (75% - 40-50 rotas quebradas)
- ✅ Authentication (100%)
- ✅ Ride management (100%)
- ✅ Payment system (80% - falta PaymentMethodController)
- ✅ Gamification (100%)
- ✅ Safety features (100%)
- ⚠️ Background jobs (40% - são stubs)
- ⚠️ Admin panel (30% - não configurado)
- ⚠️ Tests (65% coverage real, não 85%)
- ❌ 10-12 Controllers faltando (NotificationController, ProfileController, etc.)

**Mobile Apps:** 65-70% Complete (MUITO MELHOR QUE 30%!)
- ✅ Infraestrutura (100%)
- ✅ Authentication (100%)
- ✅ BLoCs (95% - AuthBloc, LocationBloc, RideBloc, etc. FUNCIONAIS)
- ✅ Main screens (70% com código real, não stubs!)
- ✅ Passenger: 10 telas completas, 5.438 linhas
- ✅ Driver: 7 telas completas, 3.252 linhas, ActiveRideBloc excelente!
- ⚠️ Navegação (50% passenger, 40% driver)
- ⚠️ Settings (10 TODOs cada)
- ❌ Testes (0%)

**Shared Package (mobi_core):** 75% Complete (com problema CRÍTICO)
- ✅ Models (100% - 20 models)
- ✅ Services (100% - 7 services, 1.298 linhas)
- ✅ Repositories (100% - 12 repositories)
- ✅ BLoCs (100% - 5 BLoCs, RideBloc com 299 linhas!)
- ✅ Utilities (100% - 2.524 linhas, validators com 495 linhas!)
- ✅ Widgets (100% - 14 widgets, 1.486 linhas)
- 🔴 CÓDIGO NÃO COMPILA - Faltam arquivos .g.dart (precisa build_runner!)
- ⚠️ Tests (40-50% coverage, não 70%)

**DevOps:** 95% Complete
- ✅ Docker setup
- ✅ CI/CD pipelines
- ✅ Testing automation
- ✅ Coverage tracking
- ⚠️ Production deployment (pending)

**Documentation:** 85% Complete
- ✅ This file (CLAUDE.md)
- ✅ README, SETUP, PROJECT_STATUS
- ✅ Feature documentation
- ⚠️ API documentation (OpenAPI spec pending)

**Next Priorities (ver PLANO_ACAO_100.md):**
1. 🔴 CRÍTICO: Rodar build_runner no mobi_core (15 min) - código não compila!
2. Implementar 10-12 controllers faltantes no backend (24h)
3. Completar lógica dos 7 Jobs (6h)
4. Conectar navegação completa nas apps (7h)
5. Adicionar testes (backend 65%→85%, apps 0%→70%, mobi_core 40%→75%)
6. Configurar Filament Admin Panel (10h)
7. Criar OpenAPI spec completo (5h)
8. Guia de deploy e ambientes staging/prod (7h)

**Total para 100%:** ~120 horas (3 semanas 1 dev full-time)
**Veja plano detalhado:** PLANO_ACAO_100.md

---

## 🎓 Learning Resources

**Laravel:**
- Official docs: https://laravel.com/docs/11.x
- Laravel News: https://laravel-news.com
- Laracasts: https://laracasts.com

**Flutter:**
- Official docs: https://docs.flutter.dev
- Flutter Awesome: https://flutterawesome.com
- BLoC Library: https://bloclibrary.dev

**Design Patterns:**
- Repository Pattern: https://designpatternsphp.readthedocs.io/en/latest/More/Repository/README.html
- Clean Architecture: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- SOLID Principles: https://www.digitalocean.com/community/conceptual_articles/s-o-l-i-d-the-first-five-principles-of-object-oriented-design

---

## 📄 License

MIT License - See LICENSE file for details.

---

**Created for:** AI Assistants (Claude, GPT, etc.)
**Maintained by:** MOBI Development Team
**Last Updated:** 2025-11-20

---

**Happy Coding! 🚀**

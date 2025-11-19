# EXEMPLOS DE CORREÇÕES PARA MOBI BACKEND

## 1. CORRIGIR BUG EM SharedRideController.php

### ANTES (ERRADO):
```php
// SharedRideController.php linha 90
public function store(Request $request): JsonResponse
{
    $user = $request->user();
    
    // ERRADO - $user->role não existe no model!
    if ($user->role !== 'driver') {
        return response()->json(['message' => 'Only drivers can create shared rides'], 403);
    }
}
```

### DEPOIS (CORRETO):
```php
// SharedRideController.php
public function store(Request $request): JsonResponse
{
    $user = $request->user();
    
    // CORRETO - usar user_type que existe na tabela users
    if ($user->user_type !== 'driver') {
        return response()->json(['message' => 'Apenas motoristas podem criar viagens compartilhadas'], 403);
    }
}
```

---

## 2. CONSOLIDAR CONTROLLERS DE CHAT

### PASSO 1: Manter Api/V1/ChatController (deletar o outro)

```php
// /backend/app/Http/Controllers/Api/V1/ChatController.php - VERSÃO FINAL

<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Chat\SendMessageRequest;
use App\Http\Resources\MessageResource;
use App\Models\Message;
use App\Models\Ride;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ChatController extends Controller
{
    /**
     * Get messages for a ride
     */
    public function index(Request $request, Ride $ride): JsonResponse
    {
        try {
            $user = $request->user();

            // Verify user is part of this ride
            if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para ver estas mensagens.',
                ], 403);
            }

            $messages = Message::where('ride_id', $ride->id)
                ->with(['sender', 'receiver'])
                ->orderBy('created_at', 'asc')
                ->paginate(50); // ADD PAGINATION!

            // Mark messages as read
            Message::where('ride_id', $ride->id)
                ->where('receiver_id', $user->id)
                ->where('is_read', false)
                ->update([
                    'is_read' => true,
                    'read_at' => now(),
                ]);

            return response()->json([
                'data' => MessageResource::collection($messages),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar mensagens.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Send a message
     */
    public function store(SendMessageRequest $request, Ride $ride): JsonResponse
    {
        try {
            $user = $request->user();

            // Verify user is part of this ride
            if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para enviar mensagens nesta corrida.',
                ], 403);
            }

            $validated = $request->validated();

            // Determine receiver
            $receiverId = $ride->passenger_id === $user->id
                ? $ride->driver_id
                : $ride->passenger_id;

            $messageData = [
                'ride_id' => $ride->id,
                'sender_id' => $user->id,
                'receiver_id' => $receiverId,
                'message' => $validated['message'],
                'type' => $validated['type'] ?? 'text',
            ];

            // Handle attachment if present
            if ($request->hasFile('attachment')) {
                $attachmentPath = $request->file('attachment')
                    ->store('chat-attachments/' . $ride->id, 'private');
                $messageData['attachment_url'] = $attachmentPath;
                $messageData['type'] = 'image';
            }

            $message = Message::create($messageData);

            // TODO: Implementar Jobs para WebSocket broadcasting
            // dispatch(new BroadcastMessage($message));

            return response()->json([
                'message' => 'Mensagem enviada com sucesso!',
                'data' => new MessageResource($message->load(['sender', 'receiver'])),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao enviar mensagem.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Mark message as read
     */
    public function markAsRead(Request $request, Ride $ride, Message $message): JsonResponse
    {
        try {
            $user = $request->user();

            // Verify user is part of this ride
            if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para esta ação.',
                ], 403);
            }

            // Verify message belongs to this ride
            if ($message->ride_id !== $ride->id) {
                return response()->json([
                    'message' => 'Mensagem não encontrada.',
                ], 404);
            }

            // User cannot mark their own messages as read
            if ($message->sender_id === $user->id) {
                return response()->json([
                    'message' => 'Não pode marcar suas próprias mensagens como lidas.',
                ], 400);
            }

            $message->update([
                'is_read' => true,
                'read_at' => now(),
            ]);

            return response()->json([
                'message' => 'Mensagem marcada como lida.',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao marcar mensagem como lida.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get unread message count
     */
    public function unreadCount(Request $request, Ride $ride): JsonResponse
    {
        try {
            $user = $request->user();

            // Verify user is part of this ride
            if ($ride->passenger_id !== $user->id && $ride->driver_id !== $user->id) {
                return response()->json([
                    'message' => 'Você não tem permissão para esta ação.',
                ], 403);
            }

            $count = Message::where('ride_id', $ride->id)
                ->where('receiver_id', $user->id)
                ->where('is_read', false)
                ->count();

            return response()->json([
                'data' => ['unread_count' => $count],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao contar mensagens.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
```

### PASSO 2: Remover ChatController root
```bash
rm /home/user/mobi/backend/app/Http/Controllers/ChatController.php
```

### PASSO 3: Deletar tabela chat_messages (usar apenas messages)
Criar migration:
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // Deletar tabela chat_messages se existir
        if (Schema::hasTable('chat_messages')) {
            Schema::dropIfExists('chat_messages');
        }
    }

    public function down(): void
    {
        // Recriar se necessário
    }
};
```

---

## 3. CORRIGIR N+1 QUERY EM DriverRideController

### ANTES (ERRADO):
```php
// DriverRideController.php linhas 46-60
public function available(Request $request): JsonResponse
{
    try {
        $driver = $request->user();
        $driverProfile = $driver->driverProfile;

        // ... validações ...

        $radius = $request->input('radius', 5);

        // PROBLEMA: Traz TODAS as rides searching do banco
        // Depois filtra em PHP (N+1 query!)
        $availableRides = Ride::where('status', 'searching')
            ->where('vehicle_category_id', $driverProfile->vehicles()->first()?->vehicle_category_id)
            ->whereNull('driver_id')
            ->with(['passenger', 'category'])
            ->get()  // ← AQUI: traz TODAS! Depois filtra em PHP
            ->filter(function ($ride) use ($driverProfile, $radius) {
                $distance = $this->calculateDistance(
                    $driverProfile->current_latitude,
                    $driverProfile->current_longitude,
                    $ride->pickup_latitude,
                    $ride->pickup_longitude
                );
                return $distance <= $radius; // Filtro em PHP - LENTO!
            })
            ->values();

        return response()->json([
            'data' => RideResource::collection($availableRides),
            'count' => $availableRides->count(),
        ], 200);
    } catch (\Exception $e) {
        // ...
    }
}
```

### DEPOIS (CORRETO):
```php
// DriverRideController.php - VERSÃO OTIMIZADA
<?php

namespace App\Http\Controllers\Api\V1\Driver;

use App\Http\Controllers\Controller;
use App\Http\Resources\RideResource;
use App\Services\RideService;
use App\Models\Ride;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DriverRideController extends Controller
{
    public function __construct(
        protected RideService $rideService
    ) {}

    /**
     * Get available rides near driver (OTIMIZADO)
     */
    public function available(Request $request): JsonResponse
    {
        try {
            $driver = $request->user();
            $driverProfile = $driver->driverProfile;

            if (!$driverProfile || !$driverProfile->canAcceptRides()) {
                return response()->json([
                    'message' => 'Você não pode aceitar corridas no momento.',
                ], 403);
            }

            if (!$driverProfile->current_latitude || !$driverProfile->current_longitude) {
                return response()->json([
                    'message' => 'Localização do motorista não encontrada.',
                ], 400);
            }

            $radius = $request->input('radius', 5);
            $categoryId = $driverProfile->vehicles()
                ->where('is_active', true)
                ->first()?->vehicle_category_id;

            if (!$categoryId) {
                return response()->json([
                    'message' => 'Você precisa ter um veículo ativo.',
                ], 400);
            }

            // CORRETO: Usar scope com Haversine no SQL
            // Vê a implementação do scope abaixo
            $availableRides = Ride::where('status', 'searching')
                ->where('vehicle_category_id', $categoryId)
                ->whereNull('driver_id')
                // Usar novo scope para filtrar por distância no SQL
                ->nearby(
                    $driverProfile->current_latitude,
                    $driverProfile->current_longitude,
                    $radius
                )
                ->with(['passenger:id,name,average_rating,total_ratings,profile_photo', 'category'])
                ->limit(20) // Limitar para performance
                ->get();

            return response()->json([
                'data' => RideResource::collection($availableRides),
                'count' => $availableRides->count(),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar corridas disponíveis.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    // ... outros métodos ...
}
```

### PASSO 2: Adicionar Scope ao Model Ride

```php
// /backend/app/Models/Ride.php

class Ride extends Model
{
    // ... código existente ...

    /**
     * Scope para buscar rides próximos usando Haversine formula
     * Todos os cálculos em SQL, não em PHP!
     */
    public function scopeNearby($query, float $latitude, float $longitude, float $radiusKm = 5)
    {
        // Usar Haversine formula no SQL para calcular distância
        // e retornar apenas rides dentro do raio
        return $query->selectRaw("
            rides.*,
            (
                6371 * acos(
                    cos(radians(?)) *
                    cos(radians(pickup_latitude)) *
                    cos(radians(pickup_longitude) - radians(?)) +
                    sin(radians(?)) *
                    sin(radians(pickup_latitude))
                )
            ) AS distance_km
        ", [$latitude, $longitude, $latitude])
            ->having('distance_km', '<=', $radiusKm)
            ->orderBy('distance_km', 'asc');
    }
}
```

---

## 4. CONVERTER SharedRideController PARA FORM REQUESTS

### PASSO 1: Criar Form Request

```php
// /backend/app/Http/Requests/SharedRide/CreateSharedRideRequest.php

<?php

namespace App\Http\Requests\SharedRide;

use Illuminate\Foundation\Http\FormRequest;

class CreateSharedRideRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Verificar se é motorista
        return $this->user() && $this->user()->user_type === 'driver';
    }

    public function rules(): array
    {
        return [
            'pickup_latitude' => 'required|numeric|between:-90,90',
            'pickup_longitude' => 'required|numeric|between:-180,180',
            'pickup_address' => 'required|string|max:255',
            'dropoff_latitude' => 'required|numeric|between:-90,90',
            'dropoff_longitude' => 'required|numeric|between:-180,180',
            'dropoff_address' => 'required|string|max:255',
            'departure_time' => 'required|date|after:now',
            'max_passengers' => 'required|integer|min:1|max:7',
            'price_per_seat' => 'required|numeric|min:1|max:999.99',
            'vehicle_id' => 'required|exists:vehicles,id',
        ];
    }

    public function messages(): array
    {
        return [
            'departure_time.after' => 'A hora de saída deve ser no futuro',
            'vehicle_id.exists' => 'O veículo selecionado não existe',
            'max_passengers.min' => 'Mínimo 1 passageiro',
            'max_passengers.max' => 'Máximo 7 passageiros',
        ];
    }
}
```

### PASSO 2: Usar Form Request no Controller

```php
// /backend/app/Http/Controllers/SharedRideController.php

use App\Http\Requests\SharedRide\CreateSharedRideRequest;

class SharedRideController extends Controller
{
    /**
     * Create a new shared ride.
     */
    public function store(CreateSharedRideRequest $request): JsonResponse
    {
        try {
            $user = $request->user();
            $validated = $request->validated(); // Dados já validados!

            // Verificar que vehicle_id pertence ao motorista
            $vehicle = $user->driverProfile->vehicles()
                ->where('id', $validated['vehicle_id'])
                ->first();

            if (!$vehicle) {
                return response()->json([
                    'message' => 'Este veículo não pertence a você'
                ], 403);
            }

            // Criar shared ride com dados já validados e seguros
            $sharedRide = SharedRide::create([
                'driver_id' => $user->id,
                'vehicle_id' => $validated['vehicle_id'],
                'pickup_latitude' => $validated['pickup_latitude'],
                'pickup_longitude' => $validated['pickup_longitude'],
                'pickup_address' => $validated['pickup_address'],
                'dropoff_latitude' => $validated['dropoff_latitude'],
                'dropoff_longitude' => $validated['dropoff_longitude'],
                'dropoff_address' => $validated['dropoff_address'],
                'departure_time' => $validated['departure_time'],
                'max_passengers' => $validated['max_passengers'],
                'price_per_seat' => $validated['price_per_seat'],
                'status' => 'scheduled',
            ]);

            $sharedRide->load(['driver', 'vehicle', 'passengers']);

            return response()->json([
                'data' => $sharedRide,
                'message' => 'Viagem compartilhada criada com sucesso!'
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erro ao criar viagem',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
```

---

## 5. ADICIONAR TRANSAÇÕES EM OPERAÇÕES CRÍTICAS

### ANTES (ERRADO):
```php
// /backend/app/Http/Controllers/Api/V1/Passenger/RideController.php linhas 240-262

$rating = Rating::create([
    'ride_id' => $ride->id,
    'rater_id' => $passenger->id,
    'rated_id' => $ride->driver_id,
    'rating' => $validated['rating'],
    'comment' => $validated['comment'] ?? null,
    'tags' => $validated['tags'] ?? null,
]);

// PROBLEMA: Se um dos updates falhar, fica inconsistente!
$driver = $ride->driver;
$driver->update([
    'total_ratings' => $driver->total_ratings + 1,
    'average_rating' => $driver->ratings()->avg('rating'),
]);

if ($driver->driverProfile) {
    $driver->driverProfile->update([
        'total_ratings' => $driver->total_ratings,
        'average_rating' => $driver->average_rating,
    ]);
}
```

### DEPOIS (CORRETO):
```php
// /backend/app/Http/Controllers/Api/V1/Passenger/RideController.php

use Illuminate\Support\Facades\DB;

public function rate(RateRideRequest $request, Ride $ride): JsonResponse
{
    try {
        $passenger = $request->user();
        $validated = $request->validated();

        if ($ride->passenger_id !== $passenger->id) {
            return response()->json([
                'message' => 'Você não tem permissão para avaliar esta corrida.',
            ], 403);
        }

        if ($ride->status !== 'completed') {
            return response()->json([
                'message' => 'Você só pode avaliar corridas concluídas.',
            ], 400);
        }

        // Usar TRANSAÇÃO para garantir consistência
        $rating = DB::transaction(function () use ($ride, $passenger, $validated) {
            // Verificar se já avaliou
            $existingRating = Rating::where('ride_id', $ride->id)
                ->where('rater_id', $passenger->id)
                ->first();

            if ($existingRating) {
                throw new \Exception('Você já avaliou esta corrida.');
            }

            // Criar rating
            $rating = Rating::create([
                'ride_id' => $ride->id,
                'rater_id' => $passenger->id,
                'rated_id' => $ride->driver_id,
                'rating' => $validated['rating'],
                'comment' => $validated['comment'] ?? null,
                'tags' => $validated['tags'] ?? null,
            ]);

            // Atualizar driver stats
            $driver = $ride->driver;
            $averageRating = $driver->ratings()->avg('rating');
            $totalRatings = $driver->ratings()->count();

            $driver->update([
                'total_ratings' => $totalRatings,
                'average_rating' => $averageRating,
            ]);

            // Atualizar driver profile também
            if ($driver->driverProfile) {
                $driver->driverProfile->update([
                    'total_ratings' => $totalRatings,
                    'average_rating' => $averageRating,
                ]);
            }

            // Dispatch event para notificações, etc
            event(new RideRated($rating, $driver));

            return $rating;
        });

        return response()->json([
            'message' => 'Avaliação enviada com sucesso!',
            'data' => new RatingResource($rating),
        ], 201);
    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Erro ao enviar avaliação.',
            'error' => $e->getMessage(),
        ], 500);
    }
}
```

---

## 6. ADICIONAR VALIDAÇÃO EM ReportController

### CRIAR FORM REQUEST:

```php
// /backend/app/Http/Requests/Report/ReportFilterRequest.php

<?php

namespace App\Http\Requests\Report;

use Illuminate\Foundation\Http\FormRequest;

class ReportFilterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // Autenticação já é feita pelo middleware
    }

    public function rules(): array
    {
        return [
            'start_date' => 'nullable|date_format:Y-m-d',
            'end_date' => 'nullable|date_format:Y-m-d|after_or_equal:start_date',
            'status' => 'nullable|in:requested,searching,accepted,driver_arrived,in_progress,completed,cancelled_by_passenger,cancelled_by_driver,cancelled_by_system',
            'period' => 'nullable|in:all,week,month,year',
            'per_page' => 'nullable|integer|min:1|max:100',
        ];
    }

    public function messages(): array
    {
        return [
            'start_date.date_format' => 'Data inicial deve estar no formato YYYY-MM-DD',
            'end_date.date_format' => 'Data final deve estar no formato YYYY-MM-DD',
            'end_date.after_or_equal' => 'Data final deve ser >= data inicial',
            'status.in' => 'Status inválido',
            'period.in' => 'Período inválido',
        ];
    }
}
```

### USAR NO CONTROLLER:

```php
// /backend/app/Http/Controllers/ReportController.php

use App\Http\Requests\Report\ReportFilterRequest;

public function rideHistory(ReportFilterRequest $request): JsonResponse
{
    $user = $request->user();
    $validated = $request->validated();

    $query = Ride::query();

    // Filter by user type
    if ($user->isPassenger()) {
        $query->where('passenger_id', $user->id);
    } elseif ($user->isDriver()) {
        $query->where('driver_id', $user->id);
    }

    // Agora é seguro usar os inputs validados!
    if (isset($validated['start_date'])) {
        $query->whereDate('created_at', '>=', $validated['start_date']);
    }

    if (isset($validated['end_date'])) {
        $query->whereDate('created_at', '<=', $validated['end_date']);
    }

    if (isset($validated['status'])) {
        $query->where('status', $validated['status']);
    }

    $perPage = $validated['per_page'] ?? 20;
    $rides = $query->with(['passenger', 'driver', 'category'])
        ->orderBy('created_at', 'desc')
        ->paginate($perPage);

    return response()->json($rides);
}
```

---

## 7. ADICIONAR MIDDLEWARE PARA WEBHOOKS

```php
// /backend/app/Http/Middleware/VerifyWebhookSignature.php

<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class VerifyWebhookSignature
{
    public function handle(Request $request, Closure $next): Response
    {
        // Verificar signature baseado no provider
        $provider = $request->route('provider') ?? 'mercadopago';
        $signature = $request->header('X-Signature') ?? $request->input('signature');

        if (!$signature) {
            return response()->json([
                'message' => 'Signature not provided'
            ], 401);
        }

        if (!$this->verifySignature($provider, $request, $signature)) {
            return response()->json([
                'message' => 'Invalid signature'
            ], 401);
        }

        return $next($request);
    }

    private function verifySignature(string $provider, Request $request, string $signature): bool
    {
        $secret = config("services.{$provider}.webhook_secret");
        
        if (!$secret) {
            return false;
        }

        $payload = $request->getContent();
        $expectedSignature = hash_hmac('sha256', $payload, $secret);

        return hash_equals($expectedSignature, $signature);
    }
}
```

### USO NAS ROTAS:

```php
// /backend/routes/api.php

Route::prefix('webhooks')->middleware('verify.webhook.signature')->group(function () {
    Route::post('/mercadopago', [WebhookController::class, 'mercadopago']);
    Route::post('/efi', [PaymentWebhookController::class, 'efi']);
    Route::post('/stone', [PaymentWebhookController::class, 'stone']);
    // ... etc
});
```

---

## 8. CRIAR NotificationService

```php
// /backend/app/Services/NotificationService.php

<?php

namespace App\Services;

use App\Models\User;
use App\Models\Notification;

class NotificationService
{
    /**
     * Enviar notificação por todos os canais
     */
    public function notify(
        User $user,
        string $type,
        string $title,
        string $message,
        array $data = [],
        array $channels = ['database', 'push', 'email', 'sms']
    ): void {
        // Criar notificação no banco
        if (in_array('database', $channels)) {
            Notification::create([
                'user_id' => $user->id,
                'type' => $type,
                'title' => $title,
                'message' => $message,
                'data' => $data,
            ]);
        }

        // Enviar push (job assincronado)
        if (in_array('push', $channels) && $user->fcm_token) {
            dispatch(new SendPushNotification($user, $title, $message, $data));
        }

        // Enviar email (job assincronado)
        if (in_array('email', $channels) && $user->email_verified_at) {
            dispatch(new SendEmailNotification($user, $title, $message, $data));
        }

        // Enviar SMS (job assincronado)
        if (in_array('sms', $channels) && $user->phone_verified_at) {
            dispatch(new SendSmsNotification($user, $message));
        }
    }

    /**
     * Notificar motoristas próximos quando ride é criada
     */
    public function notifyNearbyDrivers(Ride $ride): void
    {
        dispatch(new NotifyNearbyDrivers($ride))
            ->onQueue('notifications')
            ->delay(now()->addSeconds(2));
    }
}
```

### USAR NO CONTROLLER:

```php
// /backend/app/Http/Controllers/Api/V1/Passenger/RideController.php

public function store(CreateRideRequest $request): JsonResponse
{
    try {
        $passenger = $request->user();
        $validated = $request->validated();
        $rideDTO = RideDTO::fromArray($validated);

        // Create ride
        $ride = $this->rideService->createRide($passenger, $rideDTO);

        // Notificar motoristas próximos (agora em job!)
        $this->notificationService->notifyNearbyDrivers($ride);

        return response()->json([
            'message' => 'Corrida criada com sucesso! Procurando motoristas...',
            'data' => new RideResource($ride->load(['category', 'passenger'])),
        ], 201);
    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Erro ao criar corrida.',
            'error' => $e->getMessage(),
        ], 500);
    }
}
```

---

## RESUMO DAS CORREÇÕES

| Problema | Arquivo | Linha | Severidade | Tempo |
|----------|---------|-------|-----------|-------|
| role → user_type | SharedRideController.php | 90 | Crítica | 5 min |
| Chat Controller duplicado | ChatController.php | - | Crítica | 30 min |
| Foreign keys sem onDelete | rides migration | 90 | Crítica | 10 min |
| Rotas públicas sem auth | routes/api.php | 311 | Crítica | 10 min |
| Webhooks sem validation | routes/api.php | 318-327 | Crítica | 1 hora |
| Validator::make | 18 controllers | - | Alta | 3-4 horas |
| N+1 queries | DriverRideController.php | 46-60 | Alta | 2 horas |
| Rating sem transação | RideController.php | 240-262 | Alta | 1 hora |
| Validação dates | ReportController.php | 30-35 | Alta | 1 hora |

**Total estimado**: 8-9 horas para correções críticas e altas


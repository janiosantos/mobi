# ANÁLISE COMPLETA DO BACKEND LARAVEL - MOBI (App de Mobilidade)

## RESUMO EXECUTIVO

Análise realizada em: 2025-11-19
Projeto: MOBI - App de Mobilidade Urbana (Similar Uber/99)
Backend: Laravel 11 + Sanctum + Spatie Permission

### Estatísticas Encontradas
- Controllers: 21
- Models: 25
- Migrations: 31
- Services: 6
- Policies: 6
- Problemas Críticos: 8
- Problemas Altos: 12
- Problemas Médios: 15

---

## 1. INCONSISTÊNCIAS DE CÓDIGO

### 1.1 - DUPLICAÇÃO DE CONTROLLERS DE CHAT (CRÍTICO)
**Severidade**: CRÍTICA
**Arquivos**:
- `/backend/app/Http/Controllers/ChatController.php` (188 linhas)
- `/backend/app/Http/Controllers/Api/V1/ChatController.php` (165 linhas)

**Problema**:
- Ambos controllers implementam funcionalidade de chat para rides
- Usam models diferentes: `ChatMessage` vs `Message`
- Implementações similares mas com diferenças críticas:
  - `ChatController` (root): usa ChatMessage, sem autenticação em alguns métodos
  - `Api/V1/ChatController`: usa Message, com autenticação consistente
- Há duas tabelas no banco: `messages` e `chat_messages`

**Localização de Roteamento**:
```php
// routes/api.php linhas 79-85
Route::prefix('rides/{ride}')->group(function () {
    Route::get('/messages', [\App\Http\Controllers\ChatController::class, 'index']);
    // Usar ChatController root ao invés de Api/V1/ChatController
});

// Há inconsistência: Api/V1/ChatController está definido mas não é usado nas rotas
```

**Impacto**:
- Duplicação de lógica dificulta manutenção
- Potencial para sincronização incorreta entre mensagens
- Confusão sobre qual tabela usar (`messages` vs `chat_messages`)

**Recomendação**:
- Manter apenas um controller (preferencialmente Api/V1/ChatController)
- Consolidar modelos em um único `Message` ou `ChatMessage`
- Manter apenas uma tabela de mensagens

---

### 1.2 - INCONSISTÊNCIA DE SISTEMA DE AUTORIZAÇÃO
**Severidade**: ALTA
**Arquivos Afetados**:
- User.php: usa `user_type` (enum: 'passenger', 'driver', 'admin')
- Policies: usa `hasRole()` (do Spatie\Permission)
- Alguns Controllers: fazem verificações manuais

**Problema Específico em SharedRideController.php linha 90**:
```php
// ERRADO - $user->role não existe!
if ($user->role !== 'driver') {
    return response()->json(['message' => 'Only drivers can create shared rides'], 403);
}

// CORRETO deveria ser:
if ($user->user_type !== 'driver') { /* ... */ }
// OU usar hasRole() do Spatie
if (!$user->hasRole('driver')) { /* ... */ }
```

**Inconsistências**:
```
Sistema 1: user_type (enum no users table)
- User::isDriver()
- User::isPassenger()
- User::isApprovedDriver()

Sistema 2: Spatie\Permission roles
- user->hasRole('admin')
- user->hasRole('driver')
- user->hasRole('passenger')

Problema: Alguns controllers/policies usam um, outros usam o outro!
```

**Arquivos com inconsistências**:
- `RidePolicy.php`: linha 25 mistura `isPassenger()` com `hasRole('passenger')`
- `SharedRideController.php`: linha 90 usa `$user->role` (não existe)
- `Policies/UserPolicy.php`: usa `hasRole('admin')`
- Middlewares: usam `user_type` corretamente

**Recomendação**: Padronizar para UMA abordagem:
- Opção A: Remover Spatie e usar apenas `user_type`
- Opção B: Remover `user_type` e usar roles do Spatie
- Opção C: Mapear `user_type` para roles automaticamente em boot()

---

### 1.3 - VALIDAÇÃO INCONSISTENTE
**Severidade**: ALTA
**Problema**: Mistura de Form Requests com Validator::make()

**Padrão 1 - Form Requests** (correto):
```php
// Api/V1/AuthController.php linha 31
public function registerPassenger(RegisterPassengerRequest $request)
{ $validated = $request->validated(); }

// Api/V1/Passenger/RideController.php linha 30
public function estimate(RideEstimateRequest $request)
```

**Padrão 2 - Validator::make()** (inconsistente):
```php
// SharedRideController.php linhas 19-33
Validator::make($request->all(), [ /* regras */ ])

// SavedPlaceController.php linhas 33-40
Validator::make($request->all(), [ /* regras */ ])

// TipController.php linhas 31-40
Validator::make($request->all(), [ /* regras */ ])

// EmergencyContactController.php linhas 30-41
Validator::make($request->all(), [ /* regras */ ])
```

**Contagem**: 18 uso de `Validator::make()` vs Form Requests em outras rotas

**Recomendação**: Converter todos para Form Requests (mais seguro contra mass assignment)

---

## 2. PROBLEMAS DE SEGURANÇA

### 2.1 - VULNERABILIDADE DE MASS ASSIGNMENT (CRÍTICA)
**Severidade**: CRÍTICA
**Arquivos**:
- SharedRideController.php: linhas 96-109
- SavedPlaceController.php: linhas 49-57, 113-120
- RideStopController.php
- TipController.php: linhas 54-57

**Problema**:
```php
// SharedRideController.php linha 96-109
$sharedRide = SharedRide::create([
    'driver_id' => $user->id,
    'vehicle_id' => $request->input('vehicle_id'),
    'pickup_latitude' => $request->input('pickup_latitude'),
    // ... sem validação que o vehicle_id pertence ao driver
    'price_per_seat' => $request->input('price_per_seat'),
]);

// SavedPlaceController.php linha 49-57
$place = SavedPlace::create([
    'user_id' => $request->user()->id,
    'type' => $request->input('type'),
    // ... massa assignment sem Form Request validation
]);
```

**Riscos**:
- Dados não-validados passados diretamente ao banco
- Sem whitelist de campos
- Sem verificação de relacionamentos (ex: vehicle_id pertence ao driver?)

---

### 2.2 - FALTA DE AUTENTICAÇÃO EM ROTAS PÚBLICAS (ALTA)
**Severidade**: ALTA
**Arquivos**: routes/api.php

**Problemas**:
1. **Rota 311 - Shared Trip View (Sem Autenticação)**:
```php
// routes/api.php linha 311
Route::get('/shared-trip/{code}', [\App\Http\Controllers\SafetyController::class, 'getSharedTrip']);
// ✗ Sem middleware auth:sanctum - qualquer pessoa pode acessar
```

2. **Rota 319-327 - Webhooks Sem Validação de Assinatura**:
```php
Route::prefix('webhooks')->group(function () {
    Route::post('/mercadopago', [WebhookController::class, 'mercadopago']);
    Route::post('/notifications', [WebhookController::class, 'notifications']);
    Route::post('/efi', [PaymentWebhookController::class, 'efi']);
    Route::post('/stone', [PaymentWebhookController::class, 'stone']);
    Route::post('/pagseguro', [PaymentWebhookController::class, 'pagseguro']);
    Route::post('/cielo', [PaymentWebhookController::class, 'cielo']);
});
// ✗ Sem validação de webhook signature/token
// ✗ Sem middleware que valide origem
```

---

### 2.3 - FALTA DE VALIDAÇÃO DE INPUT (ALTA)
**Severidade**: ALTA
**Arquivo**: ReportController.php

**Problema**: Inputs não validados antes de uso em queries:
```php
// ReportController.php linhas 30-35
if ($request->has('start_date')) {
    $query->whereDate('created_at', '>=', $request->input('start_date'));
    // ✗ Sem validação de formato data!
}

if ($request->has('end_date')) {
    $query->whereDate('created_at', '<=', $request->input('end_date'));
    // ✗ Sem validação de formato data!
}

// Sem verificação se start_date > end_date
// Sem validação de date format
```

**Impacto**: Possível SQL injection ou erro na aplicação

---

### 2.4 - AUTORIZAÇÃO INCOMPLETA (ALTA)
**Severidade**: ALTA
**Problemas**:

1. **SplitFareController linha 149-164 - Acesso Público**:
```php
public function show(string $inviteCode): JsonResponse
{
    $splitPayment = RideSplitPayment::with(['ride', 'inviter'])
        ->where('invite_code', $inviteCode)
        ->first();
    // ✗ Sem autenticação! Qualquer pessoa com o invite code pode ver detalhes
    // ✗ Sem verificação de autorização
    
    return response()->json(['data' => $splitPayment]);
}
```

2. **ReportController - Sem Autorização de Dados**:
```php
// ReportController linhas 16-48
public function rideHistory(Request $request)
{
    $user = $request->user(); // Valida auth
    
    $query = Ride::query();
    
    if ($user->isPassenger()) {
        $query->where('passenger_id', $user->id);
    }
    // ✓ Passa filtro por usuario
    
    // MAS: Se um user sabe o ID de outro user...
    // O filtro protege? Sim. Mas falta Rate Limiting e logging
}
```

---

### 2.5 - RELACIONAMENTOS DE BANCO SEM CONSTRAINTS (ALTA)
**Severidade**: ALTA
**Migrations**:
- rides_table.php: `foreignId('payment_id')` SEM `->onDelete()`
- payments_table.php: `foreignId('ride_id')` SEM `->onDelete()`
- Vários outros

**Problema**:
```php
// rides_table.php linha 90
$table->foreignId('payment_id')->nullable()->constrained();
// ✗ Sem CASCADE ou RESTRICT
// Se payment for deletado, ride fica com payment_id órfão

// Melhor seria:
$table->foreignId('payment_id')->nullable()->constrained()->onDelete('cascade');
```

---

## 3. PROBLEMAS DE PERFORMANCE

### 3.1 - N+1 QUERIES DETECTADAS (ALTA)
**Severidade**: ALTA
**Arquivo**: DriverRideController.php linhas 25-72

**Código Problemático**:
```php
public function available(Request $request): JsonResponse
{
    $availableRides = Ride::where('status', 'searching')
        ->where('vehicle_category_id', $driverProfile->vehicles()->first()?->vehicle_category_id)
        ->whereNull('driver_id')
        ->with(['passenger', 'category'])
        ->get()                                    // ← PROBLEMA: Aqui traz TODAS as rides
        ->filter(function ($ride) use ($driverProfile, $radius) {
            $distance = $this->calculateDistance(
                $driverProfile->current_latitude,
                $driverProfile->current_longitude,
                $ride->pickup_latitude,
                $ride->pickup_longitude
            );
            return $distance <= $radius;          // ← Filtro em PHP, não em SQL!
        })
        ->values();
}
```

**Problema**: 
- Traz TODAS as corridas `searching` do banco (potencialmente milhares)
- Depois filtra por distância em PHP (deveria estar em SQL com Haversine)
- Cálculo de distância repetido para cada ride (poderia estar em query)

**Impacto**:
- Para 10.000 rides searching: traz todas, depois filtra 9.990
- N+1 queries devido ao `with(['passenger', 'category'])`

**Recomendação**:
```php
// Usar scope com Haversine formula no SQL
$availableRides = Ride::where('status', 'searching')
    ->where('vehicle_category_id', $categoryId)
    ->whereNull('driver_id')
    ->nearby($lat, $lon, $radius)      // Scope com Haversine
    ->with(['passenger', 'category'])
    ->paginate(20);
```

---

### 3.2 - DUPLICAÇÃO DE LÓGICA DE DISTÂNCIA (MÉDIA)
**Severidade**: MÉDIA
**Arquivos**:
- DriverProfile.php linha 215-235: `distanceFrom()` method
- DriverRideController.php linha 353-369: `calculateDistance()` method

**Código**:
```php
// Ambas fazem a mesma coisa (Haversine formula)
// DriverProfile
public function distanceFrom(float $latitude, float $longitude): float {
    $earthRadius = 6371;
    $latFrom = deg2rad($this->current_latitude);
    // ... implementação
    return $angle * $earthRadius;
}

// DriverRideController
private function calculateDistance(float $lat1, float $lon1, float $lat2, float $lon2): float {
    $earthRadius = 6371;
    $latFrom = deg2rad($lat1);
    // ... MESMA implementação duplicada
    return $angle * $earthRadius;
}
```

**Recomendação**: Criar um Trait ou Service `DistanceCalculatorService`

---

### 3.3 - QUERIES COM DUPLICAÇÃO DE LÓGICA (MÉDIA)
**Severidade**: MÉDIA
**Arquivo**: ReportController.php

**Exemplo**:
```php
// Linhas 69-80: Filtro por período (primeira vez)
switch ($period) {
    case 'week':
        $query->where('completed_at', '>=', now()->subWeek());
        break;
    // ... case month, year
}

// Linhas 95-106: MESMA LÓGICA repetida (segunda vez)
->when($period !== 'all', function($q) use ($period) {
    switch ($period) {
        case 'week':
            $q->where('completed_at', '>=', now()->subWeek());
            break;
        // ... REPETIÇÃO IDÊNTICA
    }
})

// Linhas 313-323: TERCEIRA VEZ (calculateAcceptanceRate)
switch ($period) {
    case 'week':
        $query->where('created_at', '>=', now()->subWeek());
        break;
    // ... REPETIÇÃO NOVAMENTE
}

// Linhas 334-348: QUARTA VEZ (calculateCancellationRate)
switch ($period) {
    case 'week':
        $query->where('created_at', '>=', now()->subWeek());
        break;
    // ... E NOVAMENTE
}
```

**Recomendação**: Criar Scope ou helper method:
```php
public function scopeByPeriod($query, $period)
{
    return $query->when($period !== 'all', function($q) use ($period) {
        // Lógica uma vez
    });
}

// Usar: Ride::where(...)->byPeriod('month')->get();
```

---

### 3.4 - FALTA DE ÍNDICES APROPRIADOS (MÉDIA)
**Severidade**: MÉDIA
**Migrations**:

**Faltam índices para**:
- `users.referred_by` (usado em joins)
- `rides.vehicle_category_id` (usado em filtros)
- `payments.payment_method_id` (usado em joins)
- `chat_messages.is_read` (usado em queries frequentes)
- Índice composto: `(ride_id, is_read)` em messages

**Exemplo da migration correcta**:
```php
// chat_messages_table linha 25-26
$table->index(['ride_id', 'created_at']);
$table->index(['sender_id', 'created_at']);

// Deveria também ter:
// $table->index(['ride_id', 'is_read']); // Para queries de mensagens não lidas
```

---

### 3.5 - APPENDS E RELATED DATA (BAIXA)
**Severidade**: BAIXA
**Arquivo**: ChatMessage.php linha 28

```php
protected $appends = ['sender_name'];

public function getSenderNameAttribute()
{
    return $this->sender ? $this->sender->name : 'Unknown';
    // Causa query extra se 'sender' não foi carregado!
}
```

**Recomendação**: Sempre usar `->load('sender')` ou usar `->select('sender.*')` no Relationship

---

## 4. PROBLEMAS DE ARQUITETURA

### 4.1 - FUNCIONALIDADES INCOMPLETAS (TODO Comments)
**Severidade**: ALTA
**Encontrados 7 TODOs**:

1. **ChatController Api/V1 linha 96**:
```php
// TODO: Broadcast message via WebSocket
// broadcast(new MessageSent($message))->toOthers();
```

2. **TipController linha 60**:
```php
// TODO: Add to driver earnings
// Funcionalidade de gorjeta não atualiza ganhos do motorista!
```

3. **SplitFareController linhas 105 e 276**:
```php
// TODO: Send notification/email/SMS to participant
// TODO: Process actual payment with payment gateway
```

4. **SafetyController**:
```php
// TODO: Send SMS/notification to emergency contacts
// TODO: Implement emergency actions
```

5. **ReferralController**:
```php
// TODO: Send invitation via email/SMS
```

**Impacto**: Funcionalidades críticas não implementadas

---

### 4.2 - FALTA DE JOBS/QUEUES PARA OPERAÇÕES ASSINCRONAS (ALTA)
**Severidade**: ALTA
**Problemas**:

Operations que DEVERIAM ser assincronas:
- Envio de notificações (SMS, Email, Push)
- Processamento de pagamentos
- Cálculo de relatórios pesados
- Envio de webhooks
- Broadcast de WebSocket

**Implementação Atual**: Síncrona em controllers (bloqueante)

**Exemplo do que deveria ser**:
```php
// Ao invés de fazer no controller:
broadcast(new MessageSent($message))->toOthers();

// Deveria ser um Job:
dispatch(new BroadcastMessage($message));
dispatch(new SendPaymentNotification($payment));
dispatch(new CalculateReports($user));
```

---

### 4.3 - FALTA DE EVENTS/LISTENERS (MÉDIA)
**Severidade**: MÉDIA

**Events que DEVERIAM existir**:
- `RideCreated` → Listener: notificar motoristas próximos
- `RideAccepted` → Listener: notificar passageiro
- `RideCompleted` → Listeners: atualizar estatísticas, processar pagamento, contar ganhos
- `PaymentProcessed` → Listeners: notificar, atualizar carteira
- `RideRated` → Listener: atualizar rating médio
- `UserRegistered` → Listener: enviar email de boas-vindas

**Atual**: Lógica está espalhada nos controllers e services

---

### 4.4 - POLICIES NÃO IMPLEMENTADAS/USADAS (MÉDIA)
**Severidade**: MÉDIA

**Policies Existentes mas Não Usadas**:
- MessagePolicy.php
- PaymentMethodPolicy.php
- DriverProfilePolicy.php
- VehiclePolicy.php

**Todos os controllers fazem verificações manuais ao invés de usar**:
```php
// Ao invés de:
if ($payment->user_id !== $user->id) { return 403; }

// Deveria ser:
$this->authorize('view', $payment); // Usa Policy automaticamente
```

---

### 4.5 - FALTA DE SERVICES/REPOSITORIES PARA LÓGICA DE NEGÓCIO (MÉDIA)
**Severidade**: MÉDIA

**Services Existentes** (6 apenas):
- AuthService
- RideService
- DriverMatchingService
- PaymentService
- PricingService
- GoogleMapsService

**Services QUE DEVERIAM EXISTIR**:
- `NotificationService` → centralizar SMS/Email/Push
- `ReportService` → mover lógica de ReportController
- `RatingService` → mover lógica de avaliações
- `WalletService` → gerenciar saldo do usuário
- `DocumentVerificationService` → validar documentos
- `ChatService` → consolidar lógica de chat
- `SafetyService` → gerenciar SOS e compartilhamento
- `CouponService` → gerenciar cupons

---

### 4.6 - RELACIONAMENTOS ELOQUENT INCOMPLETOS (MÉDIA)
**Severidade**: MÉDIA

**Problemas**:

1. **RideSplitPayment.php**: Faltam alguns relacionamentos
```php
// Deveria ter:
public function user() { return $this->belongsTo(User::class); }
public function ride() { return $this->belongsTo(Ride::class); }
public function inviter() { return $this->belongsTo(User::class, 'invited_by'); }
```

2. **PaymentMethod.php**: Sem relacionamentos explícitos
3. **Earning.php**: Sem relacionamentos

**Recomendação**: Documentar e criar relacionamentos para todos

---

### 4.7 - VALIDAÇÕES NOS MODELS (BAIXA)
**Severidade**: BAIXA
**Problema**: Nenhum Model tem validações (laravel-validation)

**Deveria ter**:
```php
class Ride extends Model
{
    protected $rules = [
        'estimated_distance' => 'required|numeric|min:0.1',
        'estimated_price' => 'required|numeric|min:0',
        'final_price' => 'nullable|numeric|min:0',
        // ...
    ];
}
```

---

## 5. PROBLEMAS ESPECÍFICOS POR ARQUIVO

### RideController.php (Passenger)
**Linhas 250-262**: Rating Updates sem Transação
```php
$driver = $ride->driver;
$driver->update(['total_ratings' => $driver->total_ratings + 1]);
$driver->driverProfile->update(['total_ratings' => $driver->total_ratings]);
// ✗ Sem transação! Se second update falhar, driver table fica inconsistente
// ✗ Deveria usar transaction ou event listener
```

### Payment Migration
**Linha 17-18**: Relacionamento Bidirecional Confuso
```php
// rides_table linha 90
$table->foreignId('payment_id')->nullable()->constrained();

// payments_table linha 17
$table->foreignId('ride_id')->constrained();

// Problema: ambas as tabelas referenciam uma à outra
// Qual é a tabela "dona"? Deveria haver apenas payment_id em rides
```

---

## 6. RESUMO DAS RECOMENDAÇÕES

### Críticas (Corrigir Imediatamente)
1. **Remover duplicação ChatController** - consolidar em uma implementação
2. **Corrigir `$user->role` → `$user->user_type`** em SharedRideController
3. **Padronizar sistema de autorização** (user_type vs Spatie roles)
4. **Adicionar validação de webhooks** (signature verification)
5. **Implementar transações** nas operações críticas (ratings, payments)

### Altas Prioridade (Próximas 2 semanas)
6. **Converter todos Validator::make para Form Requests**
7. **Implementar validação de datas** em ReportController
8. **Implementar N+1 query fix** em DriverRideController com Haversine scope
9. **Adicionar middleware de validação** em rotas públicas
10. **Criar Services** para NotificationService, ReportService, WalletService

### Médias Prioridade (Próximas 4 semanas)
11. **Implementar Jobs/Queues** para operações assincronas
12. **Criar Events/Listeners** para fluxos de negócio
13. **Consolidar lógica duplicada** (distância, período filtering)
14. **Implementar caching** para relatórios e queries pesadas
15. **Adicionar índices** nas foreign keys e campos frequentes

### Baixas Prioridade (Refatoração)
16. **Usar Policies** em todos os controllers
17. **Adicionar validações** nos Models
18. **Criar repository pattern** para queries complexas
19. **Documentar relacionamentos** Eloquent
20. **Adicionar rate limiting** em endpoints críticos

---

## 7. PADRÕES RECOMENDADOS

### Structure de um Controller Seguro:
```php
class RideController extends Controller
{
    public function __construct(
        protected RideService $rideService,
        protected RidePolicy $ridePolicy
    ) {}

    public function show(Request $request, Ride $ride)
    {
        // 1. Autenticar
        $user = $request->user();
        
        // 2. Autorizar (via Policy)
        $this->authorize('view', $ride);
        
        // 3. Validação via FormRequest (automática)
        // 4. Executar lógica no Service
        return response()->json([
            'data' => new RideResource($ride->load(['driver', 'passenger']))
        ]);
    }
}
```

### Structure de um Service Seguro:
```php
class RideService
{
    public function createRide(User $user, RideDTO $dto): Ride
    {
        return DB::transaction(function () use ($user, $dto) {
            $ride = $user->ridesAsPassenger()->create($dto->toArray());
            
            // Usar events para side effects
            event(new RideCreated($ride));
            
            return $ride;
        });
    }
}
```

---

## CONCLUSÃO

O backend MOBI tem uma boa estrutura geral com serviços bem organizados, mas necessita:

1. **Consolidação** de código duplicado (Chat Controllers)
2. **Padronização** de segurança (autorização, validação)
3. **Otimização** de queries (N+1, índices)
4. **Completar** TODOs pendentes (funcionalidades críticas)
5. **Arquitetura** mais robusta (Jobs, Events, Services)

Estimativa de trabalho:
- **Críticas**: 5-7 dias
- **Altas**: 2-3 semanas
- **Médias**: 3-4 semanas
- **Baixas**: 2-3 semanas

**Total**: ~4-6 semanas de refatoração


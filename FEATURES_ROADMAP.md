# 🗺️ MOBI - Features Roadmap

Guia de implementação das features restantes para competir com Uber e 99.

---

## ✅ IMPLEMENTADO (Sprint 1 - Parte 1)

### 1. ⭐ Favoritos/Endereços Salvos
**Status:** ✅ Completo
- Backend: SavedPlace model, controller, 7 endpoints
- Flutter: Model + Repository
- Suporte para Casa, Trabalho e Favoritos

### 2. 💰 Gorjeta para Motorista
**Status:** ✅ Completo
- Backend: Tip system com sugestões automáticas
- Tipos: percentage, fixed, custom
- Sugestões: 5%, 10%, 15%, R$5, R$10

---

## 🚧 PENDENTE DE IMPLEMENTAÇÃO

### Sprint 1 - Parte 2/3

#### 3. 🛡️ Safety Features Avançadas
**Prioridade:** ALTA

**Backend Necessário:**
```php
// Migration: add_safety_to_rides_table.php
Schema::table('rides', function (Blueprint $table) {
    $table->json('emergency_contacts')->nullable();
    $table->boolean('share_trip')->default(false);
    $table->string('share_code', 6)->unique()->nullable();
    $table->boolean('audio_recording')->default(false);
    $table->timestamp('sos_triggered_at')->nullable();
});

// Table: emergency_contacts
Schema::create('emergency_contacts', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->string('name');
    $table->string('phone');
    $table->boolean('is_primary')->default(false);
    $table->timestamps();
});

// Endpoints:
POST   /api/v1/emergency-contacts              // Add contact
GET    /api/v1/emergency-contacts               // List contacts
DELETE /api/v1/emergency-contacts/{id}          // Remove contact
POST   /api/v1/rides/{ride}/share               // Share trip
POST   /api/v1/rides/{ride}/sos                 // Trigger SOS
GET    /api/v1/rides/shared/{code}              // View shared trip (public)
```

**Features:**
- ✅ Compartilhar trajeto em tempo real
- ✅ Botão SOS/Emergência
- ✅ Contatos de emergência configurados
- ✅ Link público para acompanhar corrida
- ⚠️ Gravação de áudio (requer permissões especiais)
- ⚠️ Verificação facial (futuro)

---

### Sprint 2

#### 4. 📍 Múltiplas Paradas
**Prioridade:** ALTA

**Backend Necessário:**
```php
// Table: ride_stops
Schema::create('ride_stops', function (Blueprint $table) {
    $table->id();
    $table->foreignId('ride_id')->constrained()->onDelete('cascade');
    $table->integer('stop_order'); // 1, 2, 3...
    $table->string('address');
    $table->decimal('latitude', 10, 7);
    $table->decimal('longitude', 10, 7);
    $table->integer('wait_minutes')->default(3);
    $table->timestamp('arrived_at')->nullable();
    $table->timestamp('departed_at')->nullable();
    $table->enum('status', ['pending', 'arrived', 'completed'])->default('pending');
    $table->timestamps();
});

// Endpoints:
POST   /api/v1/rides/{ride}/stops                // Add stop
GET    /api/v1/rides/{ride}/stops                // List stops
PUT    /api/v1/rides/{ride}/stops/{stop}         // Update stop
DELETE /api/v1/rides/{ride}/stops/{stop}         // Remove stop
POST   /api/v1/rides/{ride}/stops/{stop}/arrive  // Mark arrived
POST   /api/v1/rides/{ride}/stops/{stop}/depart  // Mark departed
```

**Regras:**
- Máximo 3 paradas intermediárias
- Tempo de espera padrão: 3 minutos
- Recalculo automático de preço e rota
- Timer em cada parada

---

#### 5. 🚗 Categorias de Veículos
**Prioridade:** ALTA

**Backend Necessário:**
```php
// Table: vehicle_categories
Schema::create('vehicle_categories', function (Blueprint $table) {
    $table->id();
    $table->string('code'); // 'economy', 'comfort', 'premium', 'xl', 'moto'
    $table->string('name');
    $table->text('description');
    $table->decimal('base_price', 10, 2);
    $table->decimal('price_per_km', 10, 2);
    $table->decimal('price_per_minute', 10, 2);
    $table->decimal('minimum_price', 10, 2);
    $table->integer('max_passengers');
    $table->json('features'); // ['ac', 'wifi', 'premium_seats']
    $table->string('icon_url')->nullable();
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});

// Add category_id to vehicles table
Schema::table('vehicles', function (Blueprint $table) {
    $table->foreignId('category_id')->nullable()->constrained('vehicle_categories');
});

// Add category_id to rides table
Schema::table('rides', function (Blueprint $table) {
    $table->foreignId('category_id')->nullable()->constrained('vehicle_categories');
});

// Endpoints:
GET    /api/v1/vehicle-categories                    // List all categories
GET    /api/v1/vehicle-categories/{id}               // Get category details
POST   /api/v1/rides/estimate                        // Estimate with category
```

**Categorias Sugeridas:**
- **Economy** (99Pop/UberX): Básico, mais barato
- **Comfort** (99Taxi/Uber Comfort): Carros melhores, AC garantido
- **Premium** (99Top/Uber Black): Carros premium, motoristas top
- **XL** (UberXL): Vans, até 6 passageiros
- **Moto** (99Moto): Moto, mais rápido e barato

---

### Sprint 3

#### 6. ⏰ Corrida Agendada (Schedule Ride)
**Prioridade:** MÉDIA

**Backend Necessário:**
```php
// Add to rides table:
Schema::table('rides', function (Blueprint $table) {
    $table->timestamp('scheduled_for')->nullable();
    $table->boolean('is_scheduled')->default(false);
    $table->enum('schedule_status', ['pending', 'confirmed', 'cancelled'])->nullable();
});

// Job: AssignScheduledRide (runs 30 min before)
// Notification: ScheduledRideReminder

// Endpoints:
POST   /api/v1/rides/schedule                  // Schedule ride
GET    /api/v1/rides/scheduled                 // List scheduled rides
PUT    /api/v1/rides/{ride}/reschedule         // Change schedule
DELETE /api/v1/rides/{ride}/cancel-schedule    // Cancel scheduled
```

**Lógica:**
- Agendar até 30 dias no futuro
- Sistema busca motorista 30 min antes
- Notificação para passageiro e motorista
- Cancelamento até 1h antes sem custo

---

#### 7. 💵 Split Fare (Divisão de Conta)
**Prioridade:** MÉDIA

**Backend Necessário:**
```php
// Table: ride_splits
Schema::create('ride_splits', function (Blueprint $table) {
    $table->id();
    $table->foreignId('ride_id')->constrained()->onDelete('cascade');
    $table->foreignId('user_id')->constrained(); // Who pays
    $table->decimal('amount', 10, 2);
    $table->enum('status', ['pending', 'paid', 'declined'])->default('pending');
    $table->string('payment_method')->nullable();
    $table->timestamp('paid_at')->nullable();
    $table->timestamps();
});

// Endpoints:
POST   /api/v1/rides/{ride}/split                  // Create split request
GET    /api/v1/rides/{ride}/splits                 // List participants
POST   /api/v1/rides/{ride}/splits/{split}/pay     // Pay your part
POST   /api/v1/rides/{ride}/splits/{split}/decline // Decline
```

**Fluxo:**
1. Passageiro solicita split
2. Convida amigos (via link/código)
3. Amigos aceitam e pagam sua parte
4. Corrida só completa quando todos pagarem

---

### Sprint 4

#### 8. 🎁 Sistema de Referral/Indicação
**Prioridade:** MÉDIA

**Backend Necessário:**
```php
// Add to users table:
Schema::table('users', function (Blueprint $table) {
    $table->string('referral_code', 10)->unique()->nullable();
    $table->foreignId('referred_by')->nullable()->constrained('users');
});

// Table: referrals
Schema::create('referrals', function (Blueprint $table) {
    $table->id();
    $table->foreignId('referrer_id')->constrained('users');
    $table->foreignId('referred_id')->constrained('users');
    $table->decimal('referrer_credit', 10, 2)->default(10.00);
    $table->decimal('referred_credit', 10, 2)->default(10.00);
    $table->boolean('referrer_credited')->default(false);
    $table->boolean('referred_credited')->default(false);
    $table->timestamp('credited_at')->nullable();
    $table->timestamps();
});

// Endpoints:
GET    /api/v1/referral/code                    // Get my code
POST   /api/v1/referral/apply                   // Apply code
GET    /api/v1/referral/stats                   // My referral stats
```

**Regras:**
- Código único por usuário
- R$ 10 para quem indica
- R$ 10 para quem foi indicado
- Crédito liberado após primeira corrida do indicado

---

#### 9. 📊 Relatórios e Insights
**Prioridade:** MÉDIA

**Backend Necessário:**
```php
// Endpoints:
GET    /api/v1/insights/spending                 // Gastos mensais
GET    /api/v1/insights/rides                    // Corridas por período
GET    /api/v1/insights/routes                   // Rotas mais frequentes
GET    /api/v1/insights/savings                  // Economia com cupons
GET    /api/v1/insights/carbon                   // Pegada de carbono
```

**Features:**
- Dashboard de gastos
- Gráficos de corridas por mês
- Rotas mais usadas
- Economia total com cupons
- Comparativo com mês anterior
- Pegada de carbono (opcional)

---

## 🎯 Ordem de Implementação Recomendada

### Fase 1 (Essencial):
1. ✅ Favoritos
2. ✅ Gorjetas
3. 🛡️ Safety Features
4. 🚗 Categorias de Veículos
5. 📍 Múltiplas Paradas

### Fase 2 (Importante):
6. ⏰ Corrida Agendada
7. 💵 Split Fare
8. 🎁 Referral

### Fase 3 (Nice to have):
9. 📊 Relatórios

---

## 📝 Notas de Implementação

### Frontend (Flutter):
Para cada feature backend, criar:
- Model correspondente
- Repository com métodos
- Telas de UI quando necessário
- Integração com BLoC/Cubit

### Testes:
- Unit tests para repositories
- Integration tests para fluxos completos
- E2E tests para critical paths

### Documentação:
- Atualizar API docs
- Screenshots das telas
- Guia do usuário

---

## 🚀 Status Atual

**Implementado:** 2/9 features (22%)

**Sprint 1:** ✅ 2/3 completo (Favoritos + Gorjetas)
**Sprint 2:** ⏳ 0/2 pendente
**Sprint 3:** ⏳ 0/2 pendente
**Sprint 4:** ⏳ 0/2 pendente

---

## 📦 Próximo Passo

Implementar **Safety Features** para completar Sprint 1, então seguir para Sprint 2.

Cada feature pode ser implementada e testada independentemente.

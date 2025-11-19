# Backend Integration - Premium Features

Este documento descreve a integração backend das features premium implementadas no MOBI.

## 📋 Índice

1. [Chat em Tempo Real](#chat-em-tempo-real)
2. [Compartilhamento de Corridas (Carpooling)](#compartilhamento-de-corridas)
3. [Gateways de Pagamento](#gateways-de-pagamento)
4. [WebSocket Events](#websocket-events)
5. [Migrations](#migrations)

## 💬 Chat em Tempo Real

### Database

**Tabela:** `chat_messages`

```sql
- id (bigint, PK)
- ride_id (FK para rides)
- sender_id (FK para users)
- sender_type (enum: 'passenger', 'driver')
- message (text)
- type (enum: 'text', 'image', 'location', 'system')
- attachment_url (string, nullable)
- is_read (boolean, default: false)
- created_at, updated_at (timestamps)
```

### Endpoints

#### GET /api/v1/rides/{ride}/messages
Retorna mensagens do chat de uma corrida.

**Autenticação:** Bearer Token
**Permissões:** Apenas passageiro ou motorista da corrida

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "ride_id": 123,
      "sender_id": 45,
      "sender_name": "João Silva",
      "sender_type": "passenger",
      "message": "Estou chegando",
      "type": "text",
      "attachment_url": null,
      "is_read": false,
      "created_at": "2024-01-20T10:30:00Z"
    }
  ]
}
```

#### POST /api/v1/rides/{ride}/messages
Envia uma nova mensagem.

**Autenticação:** Bearer Token
**Permissões:** Apenas passageiro ou motorista da corrida

**Request:**
```json
{
  "message": "Oi, estou a caminho!",
  "type": "text"
}
```

**Para enviar imagem:**
```http
POST /api/v1/rides/123/messages
Content-Type: multipart/form-data

message: "Aqui está a foto"
type: image
image: [arquivo binário]
```

**Para enviar localização:**
```json
{
  "message": "Minha localização atual",
  "type": "location",
  "latitude": -23.5505,
  "longitude": -46.6333
}
```

#### PUT /api/v1/rides/{ride}/messages/{message}/read
Marca mensagem como lida.

#### PUT /api/v1/rides/{ride}/messages/read-all
Marca todas as mensagens como lidas.

#### GET /api/v1/rides/{ride}/messages/unread-count
Retorna contagem de mensagens não lidas.

**Response:**
```json
{
  "count": 3
}
```

### WebSocket Event

**Channel:** `private-ride.{id}`
**Event:** `chat.message.sent`

**Payload:**
```json
{
  "id": 1,
  "ride_id": 123,
  "sender_id": 45,
  "sender_name": "João Silva",
  "sender_type": "passenger",
  "message": "Estou chegando",
  "type": "text",
  "attachment_url": null,
  "is_read": false,
  "created_at": "2024-01-20T10:30:00Z"
}
```

## 🚗 Compartilhamento de Corridas (Carpooling)

### Database

**Tabela:** `shared_rides`

```sql
- id (bigint, PK)
- driver_id (FK para users)
- vehicle_id (FK para vehicles, nullable)
- pickup_latitude, pickup_longitude (decimal)
- pickup_address (string)
- dropoff_latitude, dropoff_longitude (decimal)
- dropoff_address (string)
- departure_time (timestamp)
- max_passengers (integer, default: 4)
- current_passengers (integer, default: 0)
- price_per_seat (decimal)
- status (enum: 'scheduled', 'in_progress', 'completed', 'cancelled')
- created_at, updated_at (timestamps)
```

**Tabela:** `shared_ride_passengers`

```sql
- id (bigint, PK)
- shared_ride_id (FK para shared_rides)
- passenger_id (FK para users)
- pickup_latitude, pickup_longitude (decimal)
- pickup_address (string)
- dropoff_latitude, dropoff_longitude (decimal)
- dropoff_address (string)
- status (enum: 'pending', 'confirmed', 'picked_up', 'dropped_off', 'cancelled')
- price (decimal)
- created_at, updated_at (timestamps)
```

### Endpoints

#### GET /api/v1/shared-rides/search
Busca corridas compartilhadas disponíveis.

**Query Parameters:**
- `pickup_latitude` (required)
- `pickup_longitude` (required)
- `dropoff_latitude` (required)
- `dropoff_longitude` (required)
- `departure_time` (optional) - busca ±2h do horário especificado
- `limit` (optional, default: 20, max: 50)

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "driver_id": 10,
      "driver": {
        "id": 10,
        "name": "Maria Souza",
        "photo_url": "...",
        "rating": 4.8
      },
      "vehicle": {
        "id": 5,
        "brand": "Toyota",
        "model": "Corolla",
        "plate": "ABC1234"
      },
      "pickup_address": "Av. Paulista, 1000",
      "dropoff_address": "Centro, São Paulo",
      "departure_time": "2024-01-20T18:00:00Z",
      "max_passengers": 3,
      "current_passengers": 1,
      "price_per_seat": 15.00,
      "status": "scheduled",
      "has_available_seats": true,
      "is_full": false,
      "pickup_distance": 0.8,
      "dropoff_distance": 1.2
    }
  ]
}
```

#### POST /api/v1/shared-rides
Cria nova corrida compartilhada (apenas motoristas).

**Request:**
```json
{
  "pickup_latitude": -23.5505,
  "pickup_longitude": -46.6333,
  "pickup_address": "Av. Paulista, 1000",
  "dropoff_latitude": -23.5489,
  "dropoff_longitude": -46.6388,
  "dropoff_address": "Centro, São Paulo",
  "departure_time": "2024-01-20T18:00:00Z",
  "max_passengers": 3,
  "price_per_seat": 15.00,
  "vehicle_id": 5
}
```

#### POST /api/v1/shared-rides/{id}/join
Entrar em uma corrida compartilhada (passageiros).

**Request:**
```json
{
  "pickup_latitude": -23.5510,
  "pickup_longitude": -46.6330,
  "pickup_address": "Próximo da Av. Paulista",
  "dropoff_latitude": -23.5490,
  "dropoff_longitude": -46.6390,
  "dropoff_address": "Próximo do Centro"
}
```

#### POST /api/v1/shared-rides/{id}/leave
Sair de uma corrida compartilhada.

#### POST /api/v1/shared-rides/{id}/cancel
Cancelar corrida compartilhada (apenas motorista).

#### POST /api/v1/shared-rides/{id}/start
Iniciar corrida compartilhada (apenas motorista).

#### POST /api/v1/shared-rides/{id}/passengers/{passengerId}/pickup
Marcar passageiro como embarcado.

#### POST /api/v1/shared-rides/{id}/passengers/{passengerId}/dropoff
Marcar passageiro como desembarcado.

#### GET /api/v1/shared-rides/my-rides/driver
Minhas corridas como motorista.

#### GET /api/v1/shared-rides/my-rides/passenger
Minhas corridas como passageiro.

## 💳 Gateways de Pagamento

### Webhooks

Todos os webhooks devem validar a assinatura antes de processar.

#### POST /api/v1/webhooks/efi
Webhook da EFI (Gerencianet).

**Headers:**
- `X-Gerencianet-Signature`: HMAC SHA256

#### POST /api/v1/webhooks/stone
Webhook da Stone.

**Headers:**
- `X-Stone-Signature`: HMAC SHA256

#### POST /api/v1/webhooks/pagseguro
Webhook do PagSeguro.

**Body:**
```json
{
  "notificationCode": "...",
  "notificationType": "transaction"
}
```

#### POST /api/v1/webhooks/cielo
Webhook da Cielo.

**Headers:**
- `X-Cielo-Signature`: HMAC SHA256

### Configuração

Adicionar no `.env`:

```env
# EFI (Gerencianet)
EFI_CLIENT_ID=your_client_id
EFI_CLIENT_SECRET=your_client_secret
EFI_SANDBOX=true
EFI_WEBHOOK_SECRET=your_webhook_secret

# Stone
STONE_API_KEY=your_api_key
STONE_SANDBOX=true
STONE_WEBHOOK_SECRET=your_webhook_secret

# PagSeguro
PAGSEGURO_EMAIL=your_email
PAGSEGURO_TOKEN=your_token
PAGSEGURO_SANDBOX=true

# Cielo
CIELO_MERCHANT_ID=your_merchant_id
CIELO_MERCHANT_KEY=your_merchant_key
CIELO_SANDBOX=true
CIELO_WEBHOOK_SECRET=your_webhook_secret
```

## 📡 WebSocket Events

### Eventos Existentes

1. **ride.status.updated** - Status da corrida mudou
2. **driver.location.updated** - Localização do motorista atualizada
3. **ride.new.available** - Nova corrida disponível

### Novos Eventos

4. **chat.message.sent** - Nova mensagem de chat

**Channel:** `private-ride.{rideId}`

## 🗃️ Migrations

### Executar Migrations

```bash
cd backend
php artisan migrate
```

### Migrations Criadas

1. `2024_01_20_000001_create_chat_messages_table.php`
2. `2024_01_20_000002_create_shared_rides_table.php`

## 🔐 Autenticação de Canais

Os canais WebSocket já estão configurados em `routes/channels.php`:

```php
// Canal privado da corrida (usado para chat)
Broadcast::channel('ride.{rideId}', function ($user, $rideId) {
    $ride = Ride::find($rideId);
    return (int) $user->id === (int) $ride->passenger_id
        || (int) $user->id === (int) $ride->driver_id;
});
```

## 📝 Testes

### Testar Chat

```bash
# Enviar mensagem
curl -X POST http://localhost:8000/api/v1/rides/1/messages \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"message": "Olá!", "type": "text"}'

# Listar mensagens
curl http://localhost:8000/api/v1/rides/1/messages \
  -H "Authorization: Bearer {token}"
```

### Testar Shared Rides

```bash
# Buscar corridas
curl "http://localhost:8000/api/v1/shared-rides/search?pickup_latitude=-23.5505&pickup_longitude=-46.6333&dropoff_latitude=-23.5489&dropoff_longitude=-46.6388" \
  -H "Authorization: Bearer {token}"

# Criar corrida compartilhada
curl -X POST http://localhost:8000/api/v1/shared-rides \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{...}'
```

## 🚀 Deploy

1. Executar migrations em produção
2. Configurar variáveis de ambiente dos gateways de pagamento
3. Configurar webhooks nos painéis dos gateways
4. Testar WebSocket em produção com Laravel Reverb

## 📚 Referências

- [Laravel Broadcasting](https://laravel.com/docs/11.x/broadcasting)
- [Laravel Reverb](https://laravel.com/docs/11.x/reverb)
- [EFI API Docs](https://dev.gerencianet.com.br/)
- [Stone API Docs](https://docs.stone.com.br/)
- [PagSeguro API Docs](https://dev.pagseguro.uol.com.br/)
- [Cielo API Docs](https://developercielo.github.io/)

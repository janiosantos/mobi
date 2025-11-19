# WebSocket Real-Time - MOBI Platform

## 📡 Visão Geral

O MOBI utiliza **Laravel Reverb** para comunicação em tempo real entre passageiros, motoristas e o servidor.

## 🔧 Configuração do Backend

### 1. Variáveis de Ambiente

Adicione ao `.env`:

```env
BROADCAST_CONNECTION=reverb

REVERB_APP_ID=mobi-app
REVERB_APP_KEY=your-app-key-here
REVERB_APP_SECRET=your-app-secret-here
REVERB_HOST=0.0.0.0
REVERB_PORT=8080
REVERB_SCHEME=http
```

### 2. Iniciar Laravel Reverb

```bash
# Desenvolvimento
php artisan reverb:start

# Produção (com supervisor)
php artisan reverb:start --host=0.0.0.0 --port=8080
```

### 3. Configurar Supervisor (Produção)

Criar `/etc/supervisor/conf.d/reverb.conf`:

```ini
[program:reverb]
command=php /var/www/mobi/backend/artisan reverb:start
directory=/var/www/mobi/backend
autostart=true
autorestart=true
user=www-data
redirect_stderr=true
stdout_logfile=/var/www/mobi/backend/storage/logs/reverb.log
```

## 📣 Eventos de Broadcast

### 1. RideStatusUpdated

Disparado quando o status de uma corrida muda.

**Canais:**
- `private-ride.{rideId}`
- `private-user.{passengerId}`
- `private-user.{driverId}`

**Evento:** `ride.status.updated`

**Payload:**
```json
{
  "ride": {
    "id": 123,
    "ride_number": "MOBI-20240101-ABC123",
    "status": "accepted",
    "passenger_id": 1,
    "driver_id": 2,
    "pickup_latitude": -23.5505,
    "pickup_longitude": -46.6333,
    "pickup_address": "Av. Paulista, 1000",
    "dropoff_latitude": -23.5600,
    "dropoff_longitude": -46.6500,
    "dropoff_address": "Av. Faria Lima, 2000",
    "estimated_price": 25.50,
    "final_price": null,
    "driver": {
      "id": 2,
      "name": "João Silva",
      "rating": 4.8,
      "profile_photo_url": "https://..."
    },
    "vehicle": {
      "id": 5,
      "brand": "Toyota",
      "model": "Corolla",
      "color": "Preto",
      "plate": "ABC-1234"
    }
  }
}
```

**Quando disparar:**
```php
use App\Events\RideStatusUpdated;

// Após mudar status
$ride->update(['status' => 'accepted']);
event(new RideStatusUpdated($ride));
```

---

### 2. DriverLocationUpdated

Disparado quando a localização do motorista é atualizada (a cada 5 segundos).

**Canais:**
- `private-ride.{rideId}`
- `private-user.{passengerId}`

**Evento:** `driver.location.updated`

**Payload:**
```json
{
  "ride_id": 123,
  "driver_id": 2,
  "latitude": -23.5505,
  "longitude": -46.6333,
  "timestamp": "2024-01-01T12:00:00.000000Z"
}
```

**Quando disparar:**
```php
use App\Events\DriverLocationUpdated;

// Atualizar localização
event(new DriverLocationUpdated($ride, $latitude, $longitude));
```

---

### 3. NewRideAvailable

Disparado quando uma nova corrida está disponível para motoristas próximos.

**Canais:**
- `private-user.{driverId}` (para cada motorista próximo)

**Evento:** `ride.new.available`

**Payload:**
```json
{
  "ride": {
    "id": 123,
    "ride_number": "MOBI-20240101-ABC123",
    "pickup_latitude": -23.5505,
    "pickup_longitude": -46.6333,
    "pickup_address": "Av. Paulista, 1000",
    "dropoff_latitude": -23.5600,
    "dropoff_longitude": -46.6500,
    "dropoff_address": "Av. Faria Lima, 2000",
    "estimated_distance_meters": 5000,
    "estimated_duration_seconds": 900,
    "estimated_price": 25.50,
    "vehicle_category_id": 1,
    "passenger": {
      "id": 1,
      "name": "Maria Santos",
      "rating": 4.9,
      "profile_photo_url": "https://..."
    }
  }
}
```

**Quando disparar:**
```php
use App\Events\NewRideAvailable;

// Notificar motoristas próximos
$nearbyDriverIds = [2, 5, 8];
event(new NewRideAvailable($ride, $nearbyDriverIds));
```

---

## 🔐 Autenticação de Canais

Os canais privados requerem autenticação. Definido em `routes/channels.php`:

### Canal de Usuário
```php
Broadcast::channel('user.{userId}', function ($user, $userId) {
    return (int) $user->id === (int) $userId;
});
```

### Canal de Corrida
```php
Broadcast::channel('ride.{rideId}', function ($user, $rideId) {
    $ride = Ride::find($rideId);

    return (int) $user->id === (int) $ride->passenger_id
        || (int) $user->id === (int) $ride->driver_id;
});
```

---

## 📱 Integração Flutter (Cliente)

### 1. Instalar Pacotes

```yaml
dependencies:
  pusher_channels_flutter: ^2.2.0
  # ou
  laravel_echo: ^1.0.0
```

### 2. Configurar Cliente

```dart
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class WebSocketService {
  late PusherChannelsFlutter pusher;

  Future<void> initialize(String token) async {
    pusher = PusherChannelsFlutter();

    await pusher.init(
      apiKey: 'your-app-key',
      cluster: '', // Not used with self-hosted
      onConnectionStateChange: _onConnectionStateChange,
      onError: _onError,
      host: 'your-server.com',
      wsPort: 8080,
      wssPort: 8080,
      authEndpoint: 'https://your-api.com/broadcasting/auth',
      auth: PusherAuth(
        'https://your-api.com/broadcasting/auth',
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    await pusher.connect();
  }

  void _onConnectionStateChange(String currentState, String previousState) {
    print('Connection: $previousState -> $currentState');
  }

  void _onError(String message, int? code, dynamic error) {
    print('Error: $message');
  }
}
```

### 3. Subscribir a Canais

```dart
// Subscribir ao canal do usuário
final userChannel = await pusher.subscribe(
  channelName: 'private-user.$userId',
);

// Subscribir ao canal da corrida
final rideChannel = await pusher.subscribe(
  channelName: 'private-ride.$rideId',
);
```

### 4. Ouvir Eventos

```dart
// Ouvir status da corrida
userChannel.bind('ride.status.updated', (event) {
  final data = jsonDecode(event!.data);
  final ride = Ride.fromJson(data['ride']);

  // Atualizar UI
  setState(() {
    currentRide = ride;
  });
});

// Ouvir localização do motorista
rideChannel.bind('driver.location.updated', (event) {
  final data = jsonDecode(event!.data);
  final lat = data['latitude'];
  final lng = data['longitude'];

  // Atualizar marcador no mapa
  updateDriverMarker(lat, lng);
});

// Ouvir novas corridas (motorista)
userChannel.bind('ride.new.available', (event) {
  final data = jsonDecode(event!.data);
  final ride = Ride.fromJson(data['ride']);

  // Mostrar notificação de nova corrida
  showNewRideNotification(ride);
});
```

### 5. Desconectar

```dart
@override
void dispose() {
  pusher.disconnect();
  super.dispose();
}
```

---

## 🧪 Testar WebSocket

### 1. Usando Postman / Insomnia

1. Iniciar Reverb: `php artisan reverb:start`
2. Conectar ao WebSocket: `ws://localhost:8080/app/your-app-key`
3. Enviar mensagem de subscribe:
```json
{
  "event": "pusher:subscribe",
  "data": {
    "channel": "private-user.1",
    "auth": "bearer_token_here"
  }
}
```

### 2. Usando Laravel Tinker

```php
php artisan tinker

// Criar evento de teste
$ride = Ride::first();
event(new \App\Events\RideStatusUpdated($ride));

// Verificar se o evento foi disparado
```

---

## 🚀 Deploy em Produção

### 1. Configurar HTTPS/WSS

```env
REVERB_SCHEME=https
REVERB_HOST=api.mobi.com.br
REVERB_PORT=443
```

### 2. Configurar Nginx

```nginx
server {
    listen 443 ssl http2;
    server_name api.mobi.com.br;

    # WebSocket proxy
    location /app {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. Monitorar

```bash
# Ver logs do Reverb
tail -f storage/logs/reverb.log

# Ver status do supervisor
sudo supervisorctl status reverb

# Reiniciar Reverb
sudo supervisorctl restart reverb
```

---

## 📊 Métricas e Monitoramento

### Eventos Importantes

| Evento | Descrição | Frequência |
|--------|-----------|------------|
| `ride.status.updated` | Status da corrida mudou | Sob demanda |
| `driver.location.updated` | Localização do motorista | A cada 5s |
| `ride.new.available` | Nova corrida disponível | Sob demanda |

### Performance

- **Latência esperada:** < 100ms
- **Conexões simultâneas:** Até 10.000
- **Mensagens por segundo:** Até 1.000

---

## 🐛 Troubleshooting

### Problema: Não consegue conectar

**Solução:**
1. Verificar se o Reverb está rodando: `ps aux | grep reverb`
2. Verificar porta: `netstat -tulpn | grep 8080`
3. Verificar firewall: `sudo ufw allow 8080`

### Problema: Autenticação falha

**Solução:**
1. Verificar se o token está correto
2. Verificar endpoint de auth: `/broadcasting/auth`
3. Verificar headers: `Authorization: Bearer {token}`

### Problema: Eventos não chegam

**Solução:**
1. Verificar se o canal está subscrito corretamente
2. Verificar permissões do canal em `routes/channels.php`
3. Verificar logs: `storage/logs/laravel.log`

---

## 📚 Referências

- [Laravel Broadcasting](https://laravel.com/docs/11.x/broadcasting)
- [Laravel Reverb](https://laravel.com/docs/11.x/reverb)
- [Pusher Protocol](https://pusher.com/docs/channels/library_auth_reference/pusher-websockets-protocol)

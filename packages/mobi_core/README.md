# MOBI Core Package

Pacote compartilhado contendo código comum para os aplicativos de Passageiro e Motorista da plataforma MOBI.

## Conteúdo

### Models
- User
- Ride
- Vehicle
- Payment
- Location

### Services
- ApiService (Retrofit + Dio)
- AuthService
- LocationService (Geolocator)
- NotificationService (Firebase)

### Repositories
- AuthRepository
- RideRepository
- PaymentRepository

### Constants
- ApiConstants
- AppConstants

### Utils
- Validators
- Formatters
- Extensions

### Widgets
- CustomButton
- CustomTextField
- LoadingOverlay

## Uso

```dart
import 'package:mobi_core/mobi_core.dart';
```

## Dependências

- flutter_bloc: State management
- dio/retrofit: HTTP client
- geolocator: Localização
- firebase_messaging: Notificações push
- shared_preferences: Armazenamento local
- hive: Database local

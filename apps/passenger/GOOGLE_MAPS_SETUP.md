# Google Maps Setup - App Passageiro MOBI

## 1. Obter API Key

1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Crie ou selecione um projeto
3. Habilite as seguintes APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Directions API
   - Geocoding API
   - Distance Matrix API

4. Vá em "Credentials" > "Create Credentials" > "API Key"
5. Copie a API Key
6. Restrinja a API Key (recomendado):
   - Android: Package name + SHA-1
   - iOS: Bundle ID

## 2. Configurar Android

**android/app/src/main/AndroidManifest.xml:**
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY_HERE"/>
    </application>

    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
</manifest>
```

## 3. Configurar iOS

**ios/Runner/AppDelegate.swift:**
```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**ios/Runner/Info.plist:**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Precisamos da sua localização para solicitar corridas</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Precisamos da sua localização para acompanhar suas corridas</string>
```

## 4. Configurar .env

Crie o arquivo `.env` na raiz do projeto:

```env
GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY_HERE
```

## 5. Adicionar ao pubspec.yaml

Já está adicionado em `pubspec.yaml`:
```yaml
dependencies:
  google_maps_flutter: ^2.5.3
  geolocator: ^11.0.0
  geocoding: ^2.1.1
```

## 6. Testar

Execute o app e verifique se o mapa aparece corretamente:

```bash
flutter run
```

## Notas Importantes:

- **Nunca commite a API Key no repositório!**
- Use variáveis de ambiente (`.env`)
- Restrinja a API Key no Google Cloud Console
- Para produção, use APIs Keys diferentes para cada ambiente
- Monitore o uso da API no Google Cloud Console para evitar custos inesperados

## Limites Gratuitos (Google Maps):

- 28.500 cargas de mapa / mês grátis
- $200 de crédito mensal
- Após isso, ~$7 por 1.000 cargas

Monitore em: https://console.cloud.google.com/google/maps-apis/quotas

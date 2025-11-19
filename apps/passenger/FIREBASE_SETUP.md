# Firebase Setup - App Passageiro MOBI

## 1. Criar Projeto no Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Nome: "MOBI Passenger"
4. Siga os passos de criação

## 2. Adicionar App Android

1. No projeto Firebase, clique em "Adicionar app" > Android
2. Package name: `com.mobi.passenger`
3. Baixe o arquivo `google-services.json`
4. Coloque em: `android/app/google-services.json`

### Configurar build.gradle

**android/build.gradle:**
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

**android/app/build.gradle:**
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

## 3. Adicionar App iOS

1. No projeto Firebase, clique em "Adicionar app" > iOS
2. Bundle ID: `com.mobi.passenger`
3. Baixe o arquivo `GoogleService-Info.plist`
4. Coloque em: `ios/Runner/GoogleService-Info.plist`

### Configurar Podfile

**ios/Podfile:**
```ruby
platform :ios, '13.0'

target 'Runner' do
  use_frameworks!

  pod 'Firebase/Messaging'
end
```

Depois rode:
```bash
cd ios
pod install
```

## 4. Habilitar Cloud Messaging

1. No Firebase Console, vá em: Build > Cloud Messaging
2. Copie a "Server Key" e "Sender ID"
3. Adicione no backend `.env`:
```env
FCM_SERVER_KEY=sua_server_key_aqui
FCM_SENDER_ID=seu_sender_id_aqui
```

## 5. Configurar Permissões

### Android (android/app/src/main/AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY" />

<application>
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_channel_id"
        android:value="high_importance_channel" />
</application>
```

### iOS (ios/Runner/Info.plist):
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## 6. Testar Notificações

Após configurar, teste enviando uma notificação:

1. Firebase Console > Cloud Messaging
2. "Send your first message"
3. Selecione o app
4. Envie teste

## Arquivos Necessários (não commitados):

- ✅ `android/app/google-services.json`
- ✅ `ios/Runner/GoogleService-Info.plist`

Estes arquivos estão no `.gitignore` para segurança.

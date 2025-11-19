# 🚀 CI/CD Guide - MOBI Platform

Este guia explica a configuração completa de CI/CD do projeto MOBI.

## 📋 Tabela de Conteúdos

- [Workflows](#workflows)
- [Configuração de Secrets](#secrets)
- [Quality Gates](#quality-gates)
- [Badges](#badges)
- [Troubleshooting](#troubleshooting)

---

## 🔄 Workflows

### 1. CI - Tests & Analysis (`ci.yml`)

**Trigger:** Push em `main`, `develop`, `claude/**` | Pull Requests

**Jobs:**
1. **analyze**: Análise de código (Flutter analyze, PHPStan)
2. **test-core**: Testes unitários do mobi_core
3. **test-backend**: Testes do backend Laravel
4. **test-integration**: Testes de integração E2E
5. **security**: Security scan (dependency audit, secrets scan)
6. **quality-gate**: Validação de qualidade geral

**Duração:** ~15-20 minutos

```bash
# Executar localmente
cd packages/mobi_core && flutter test
cd backend && php artisan test
```

### 2. Build - Android & iOS (`build.yml`)

**Trigger:** Push em `main`, `develop` | Tags `v*.*.*` | Manual

**Jobs:**
1. **build-android**: APK + AAB (debug e release)
2. **build-ios**: IPA (debug e release)
3. **build-web**: Build para web (CanvasKit)
4. **deploy-firebase**: Deploy automático para Firebase App Distribution

**Artifacts:**
- Android APK (debug/release)
- Android AAB (release)
- iOS IPA (release)
- Web build

**Duração:** ~30-40 minutos

### 3. PR Checks (`pr-checks.yml`)

**Trigger:** Pull Requests (opened, synchronize, reopened)

**Validações:**
1. ✅ Título do PR (Conventional Commits)
2. ✅ Descrição do PR (mínimo 20 caracteres)
3. ✅ Code quality (analyzer + formatting)
4. ✅ Changed files analysis
5. ✅ Test coverage (mínimo 70%)
6. ✅ Dependency audit
7. ✅ APK size analysis (se label "performance")

**Exemplo de título válido:**
```
feat: Adicionar sistema de pagamento via PIX
fix: Corrigir crash ao abrir mapa
docs: Atualizar guia de instalação
```

### 4. Coverage (`coverage.yml`)

**Trigger:** Push em `main`, `develop` | Pull Requests | Daily (2 AM UTC)

**Features:**
- ✅ Code coverage report (mobi_core + backend)
- ✅ Upload para Codecov
- ✅ Coverage por módulo
- ✅ Coverage trends (histórico)
- ✅ Uncovered code report
- ✅ HTML report generation

**Coverage Threshold:** 70% mínimo

### 5. Release (`release.yml`)

**Trigger:** Tags `v*.*.*` | Manual

**Fluxo:**
1. Criar GitHub Release com changelog automático
2. Build Android (APK + AAB assinados)
3. Build iOS (IPA assinado)
4. Upload assets para GitHub Release
5. Deploy para Google Play (Internal Track)
6. Upload para TestFlight

---

## 🔐 Configuração de Secrets

### GitHub Secrets Necessários

#### Android
```bash
ANDROID_KEYSTORE_BASE64      # Keystore em base64
ANDROID_KEYSTORE_PASSWORD    # Senha do keystore
ANDROID_KEY_ALIAS            # Alias da chave
ANDROID_KEY_PASSWORD         # Senha da chave
```

**Gerar keystore base64:**
```bash
base64 -i upload-keystore.jks | tr -d '\n'
```

#### iOS
```bash
IOS_P12_BASE64                    # Certificado em base64
IOS_P12_PASSWORD                  # Senha do certificado
IOS_PROVISIONING_PROFILE_BASE64   # Provisioning profile
APPSTORE_API_KEY_ID              # App Store Connect API Key ID
APPSTORE_API_ISSUER_ID           # Issuer ID
APPSTORE_API_PRIVATE_KEY         # Private key
```

**Gerar certificado base64:**
```bash
base64 -i certificate.p12 | tr -d '\n'
```

#### Google Play
```bash
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON  # Service account JSON
```

#### Firebase
```bash
FIREBASE_APP_ID_ANDROID              # Firebase App ID (Android)
FIREBASE_APP_ID_IOS                  # Firebase App ID (iOS)
FIREBASE_SERVICE_CREDENTIALS         # Service account JSON
```

#### Code Coverage
```bash
CODECOV_TOKEN  # Token do Codecov.io
```

---

## ✅ Quality Gates

### Critérios de Aprovação

#### Pull Requests
- ✅ Todos os testes passando
- ✅ Coverage >= 70%
- ✅ Nenhum erro de análise estática
- ✅ Código formatado (dart format)
- ✅ Título seguindo Conventional Commits
- ✅ Descrição detalhada

#### Main Branch
- ✅ Todos os workflows passando
- ✅ Coverage >= 70%
- ✅ Build successful (Android + iOS)
- ✅ Security scan clean

### Conventional Commits

Tipos permitidos:
- `feat`: Nova feature
- `fix`: Bug fix
- `docs`: Documentação
- `style`: Formatação
- `refactor`: Refatoração
- `perf`: Performance
- `test`: Testes
- `build`: Build system
- `ci`: CI/CD
- `chore`: Manutenção

**Exemplos:**
```bash
feat(auth): Adicionar login com Google
fix(map): Corrigir marker não aparecendo
docs(readme): Atualizar instruções de setup
test(bloc): Adicionar testes do RideBloc
```

---

## 📊 Badges

### README Badges

```markdown
[![CI](https://github.com/janiosantos/mobi/actions/workflows/ci.yml/badge.svg)](https://github.com/janiosantos/mobi/actions/workflows/ci.yml)
[![Build](https://github.com/janiosantos/mobi/actions/workflows/build.yml/badge.svg)](https://github.com/janiosantos/mobi/actions/workflows/build.yml)
[![Coverage](https://github.com/janiosantos/mobi/actions/workflows/coverage.yml/badge.svg)](https://github.com/janiosantos/mobi/actions/workflows/coverage.yml)
[![codecov](https://codecov.io/gh/janiosantos/mobi/branch/main/graph/badge.svg)](https://codecov.io/gh/janiosantos/mobi)
```

### Coverage Badge (Codecov)

1. Acesse https://codecov.io/gh/janiosantos/mobi
2. Vá em Settings > Badge
3. Copie o Markdown badge

---

## 🔧 Troubleshooting

### Build Falhou

#### Android
```bash
# Limpar cache
cd apps/mobi_passenger/android
./gradlew clean

# Rebuild
flutter clean
flutter pub get
flutter build apk
```

#### iOS
```bash
# Limpar cache
cd apps/mobi_passenger/ios
rm -rf Pods Podfile.lock
pod install

# Rebuild
cd ..
flutter clean
flutter pub get
flutter build ios
```

### Testes Falhando

```bash
# Executar localmente com verbose
flutter test --reporter expanded

# Específico
flutter test test/bloc/ride/ride_bloc_test.dart

# Com coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Coverage Baixo

1. Verifique arquivos sem testes:
```bash
# Gerar coverage
flutter test --coverage

# Ver uncovered
lcov --list coverage/lcov.info
```

2. Adicione testes para arquivos importantes em `lib/src/`:
   - BLoCs
   - Repositories
   - Services
   - Models (se tiverem lógica)

### Security Scan Failing

```bash
# Audit dependencies
cd backend && composer audit
cd packages/mobi_core && flutter pub outdated

# Scan secrets locally
trufflehog git file://. --only-verified
```

### PR Checks Failing

**Título inválido:**
```bash
# ❌ Errado
Update README
add new feature

# ✅ Correto
docs: Update README with CI/CD guide
feat: Add payment integration
```

**Coverage baixo:**
```bash
# Adicionar mais testes
flutter test test/bloc/payment/payment_bloc_test.dart --coverage
```

**Formatting:**
```bash
# Auto-format
dart format lib test
```

---

## 📱 Deploy Manual

### Android (Google Play)

```bash
# Build AAB
cd apps/mobi_passenger
flutter build appbundle --release

# Upload via Console
# 1. Acesse https://play.google.com/console
# 2. Selecione o app
# 3. Release > Internal testing
# 4. Upload app-release.aab
```

### iOS (TestFlight)

```bash
# Build IPA
cd apps/mobi_passenger
flutter build ios --release

# Upload via Xcode
# 1. Abra ios/Runner.xcworkspace
# 2. Product > Archive
# 3. Distribute App > TestFlight
```

---

## 🎯 Best Practices

### 1. **Sempre criar branch a partir de `develop`**
```bash
git checkout develop
git pull
git checkout -b feat/nova-feature
```

### 2. **Rodar testes localmente antes de push**
```bash
flutter test
php artisan test
```

### 3. **Usar Conventional Commits**
```bash
git commit -m "feat(rides): Adicionar cancelamento de corrida"
```

### 4. **Manter coverage alto**
- Escrever testes para novas features
- Mínimo 70% coverage

### 5. **Revisar PR checks antes de merge**
- Todos os checks verdes
- Coverage mantido ou aumentado
- Código revisado

---

## 📚 Recursos Adicionais

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Codecov Documentation](https://docs.codecov.com/)
- [Flutter Testing](https://docs.flutter.dev/testing)
- [Laravel Testing](https://laravel.com/docs/testing)

---

**Última atualização:** 2024-11-19

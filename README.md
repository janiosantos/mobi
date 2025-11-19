# 🚗 MOBI - Plataforma de Transporte Particular

[![CI](https://github.com/janiosantos/mobi/actions/workflows/ci.yml/badge.svg)](https://github.com/janiosantos/mobi/actions/workflows/ci.yml)
[![Build](https://github.com/janiosantos/mobi/actions/workflows/build.yml/badge.svg)](https://github.com/janiosantos/mobi/actions/workflows/build.yml)
[![Coverage](https://github.com/janiosantos/mobi/actions/workflows/coverage.yml/badge.svg)](https://github.com/janiosantos/mobi/actions/workflows/coverage.yml)
[![codecov](https://codecov.io/gh/janiosantos/mobi/branch/main/graph/badge.svg)](https://codecov.io/gh/janiosantos/mobi)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.24.0-02569B?logo=flutter)](https://flutter.dev)
[![Laravel](https://img.shields.io/badge/Laravel-11-FF2D20?logo=laravel)](https://laravel.com)

Sistema completo de transporte particular estilo Uber, com backend Laravel 11, apps mobile Flutter e atualizações em tempo real via WebSocket.

---

## 🌟 Visão Geral

MOBI é uma plataforma completa de transporte particular que conecta passageiros e motoristas em tempo real.

### Features Principais

- 📱 **Apps Mobile Nativos** (Flutter) para Passageiros e Motoristas
- 🔌 **API RESTful** completa (Laravel 11)
- ⚡ **Real-Time** via WebSocket (Laravel Reverb)
- 👨‍💼 **Admin Panel** completo (Filament PHP)
- 💳 **Pagamentos** PIX + Cartão (MercadoPago)
- 📍 **Geolocalização** em tempo real
- ⭐ **Avaliações** bidirecionais
- 🔔 **Notificações Push** (Firebase)

---

## 🚀 Quick Start

### Com Docker (Recomendado)

\`\`\`bash
# Clone
git clone https://github.com/your-org/mobi.git
cd mobi

# Setup completo
make setup

# Acessar
# API: http://localhost:8000
# Admin: http://localhost:8000/admin
# WebSocket: ws://localhost:8080
\`\`\`

### Manual

\`\`\`bash
# Backend
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve

# Apps Mobile
cd apps/passenger && flutter run
cd apps/driver && flutter run
\`\`\`

---

## 📚 Documentação

- 📖 [Setup Completo](./SETUP.md)
- 🔌 [WebSocket Real-Time](./WEBSOCKET.md)
- 📱 [Firebase Setup](./apps/passenger/FIREBASE_SETUP.md)
- 🗺️ [Google Maps Setup](./apps/passenger/GOOGLE_MAPS_SETUP.md)

---

## 🧪 Testes

\`\`\`bash
# Backend (105+ testes)
cd backend && php artisan test --coverage

# Flutter - mobi_core (100+ testes)
cd packages/mobi_core && flutter test --coverage

# Executar todos os testes via CI
# Os workflows rodam automaticamente em push/PR
\`\`\`

**Coverage:** Backend 85% | mobi_core 70%+ | Total: ~3.200 linhas de testes

---

## 🏗️ Arquitetura

\`\`\`
mobi/
├── backend/          # Laravel 11 API
├── apps/
│   ├── passenger/    # App Passageiro
│   └── driver/       # App Motorista
├── packages/
│   └── mobi_core/    # Código compartilhado
└── .github/          # CI/CD
\`\`\`

---

## 🛠️ Stack Tecnológico

**Backend:** Laravel 11 • PostgreSQL 16 • Redis 7 • Laravel Reverb
**Mobile:** Flutter 3.19+ • BLoC • GetIt • Google Maps
**DevOps:** Docker • GitHub Actions • Nginx

---

## 📊 Status do Projeto

| Componente | Status | Coverage | Testes |
|------------|--------|----------|--------|
| Backend API | ✅ 100% | 85% | 105+ testes |
| Admin Panel | ✅ 100% | - | - |
| Passenger App | ✅ 100% | - | - |
| Driver App | ✅ 100% | - | - |
| mobi_core | ✅ 100% | 70%+ | 100+ testes |
| WebSocket | ✅ 100% | - | - |
| CI/CD Pipeline | ✅ 100% | - | 5 workflows |

### 🚀 CI/CD Pipelines

- **CI (Tests & Analysis)**: Testes automatizados, análise de código, security scan
- **Build**: Builds Android (APK/AAB) e iOS (IPA)
- **Coverage**: Code coverage tracking e reports
- **PR Checks**: Validações automáticas em Pull Requests
- **Release**: Publicação automática para Google Play e TestFlight

---

## 📝 Licença

MIT License - veja [LICENSE](LICENSE)

---

**Desenvolvido com ❤️ pela equipe MOBI**

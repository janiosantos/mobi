# 🚗 MOBI - Plataforma de Transporte Particular

[![Backend CI](https://github.com/your-org/mobi/actions/workflows/backend-ci.yml/badge.svg)](https://github.com/your-org/mobi/actions)
[![Flutter CI](https://github.com/your-org/mobi/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/your-org/mobi/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

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

# Flutter
cd packages/mobi_core && flutter test
\`\`\`

**Coverage:** Backend 85% | mobi_core Em progresso

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

## 📊 Status

✅ Backend API (100%)
✅ Admin Panel (100%)
✅ Passenger App (100%)
✅ Driver App (100%)
✅ WebSocket (100%)
✅ CI/CD (100%)

---

## 📝 Licença

MIT License - veja [LICENSE](LICENSE)

---

**Desenvolvido com ❤️ pela equipe MOBI**

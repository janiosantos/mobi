# 🚗 MOBI - Plataforma de Mobilidade Urbana

Sistema completo de mobilidade urbana (tipo Uber/99) desenvolvido com Laravel 11, Flutter e Docker.

## 📋 Sobre o Projeto

MOBI é uma plataforma completa de mobilidade urbana que conecta passageiros e motoristas, oferecendo:

- **Solicitação de corridas em tempo real**
- **Rastreamento GPS ao vivo**
- **Sistema de pagamentos (Pix e Cartão)**
- **Chat entre passageiro e motorista**
- **Painel administrativo completo**
- **Sistema de aprovação de motoristas (KYC)**
- **Cálculo dinâmico de tarifas**
- **Histórico de corridas e relatórios**

## 🏗️ Arquitetura

```
mobi/
├── backend/              # API Laravel 11 + Admin Filament
│   ├── app/
│   │   ├── Models/
│   │   ├── Http/
│   │   │   ├── Controllers/Api/V1/
│   │   │   ├── Requests/
│   │   │   └── Resources/
│   │   ├── Services/
│   │   ├── Repositories/
│   │   ├── DTOs/
│   │   ├── Events/
│   │   ├── Jobs/
│   │   ├── Listeners/
│   │   ├── Policies/
│   │   └── Filament/      # Admin Panel
│   ├── database/
│   │   ├── migrations/
│   │   └── seeders/
│   ├── routes/
│   └── config/
│
├── apps/
│   ├── passenger/        # App Flutter Passageiro
│   │   ├── lib/
│   │   │   ├── core/
│   │   │   ├── features/
│   │   │   ├── shared/
│   │   │   └── main.dart
│   │   └── pubspec.yaml
│   │
│   └── driver/           # App Flutter Motorista
│       ├── lib/
│       │   ├── core/
│       │   ├── features/
│       │   ├── shared/
│       │   └── main.dart
│       └── pubspec.yaml
│
├── infra/
│   ├── docker/
│   │   ├── docker-compose.yml
│   │   ├── Dockerfile.backend
│   │   ├── Dockerfile.websockets
│   │   └── nginx/
│   └── scripts/
│       ├── deploy.sh
│       └── setup.sh
│
└── docs/
    ├── api/              # OpenAPI 3.1 Specs
    ├── diagrams/         # Fluxogramas Mermaid
    └── design-system/    # Design System UI/UX
```

## 🚀 Tecnologias

### Backend
- **Laravel 11** - Framework PHP
- **PostgreSQL** - Banco de dados
- **Redis** - Cache e Filas
- **Laravel Sanctum** - Autenticação JWT
- **Laravel Horizon** - Gerenciamento de filas
- **Laravel WebSockets** - Comunicação em tempo real
- **Filament PHP** - Painel administrativo
- **Spatie Permissions** - Controle de permissões

### Apps Mobile
- **Flutter 3.x** - Framework mobile
- **Bloc/Cubit** - Gerenciamento de estado
- **GetIt** - Injeção de dependência
- **Dio** - Cliente HTTP
- **Socket.io** - WebSockets
- **Google Maps Flutter** - Mapas e navegação

### DevOps
- **Docker & Docker Compose**
- **Nginx** - Servidor web
- **GitHub Actions** - CI/CD
- **PostgreSQL 15**
- **Redis 7**

### Integrações
- **Google Maps API** - Directions, Geocoding, Distance Matrix
- **MercadoPago** - Pagamentos (Pix e Cartão)
- **Firebase Cloud Messaging** - Notificações push

## 📱 Funcionalidades

### App Passageiro
- ✅ Cadastro e autenticação
- ✅ Busca de endereços (Google Places)
- ✅ Estimativa de preço em tempo real
- ✅ Solicitação de corrida
- ✅ Rastreamento do motorista no mapa
- ✅ Chat com motorista
- ✅ Avaliação do motorista
- ✅ Pagamento via Pix ou Cartão
- ✅ Histórico de corridas
- ✅ Cupons de desconto

### App Motorista
- ✅ Cadastro e upload de documentos
- ✅ Aprovação por KYC
- ✅ Modo online/offline
- ✅ Recebimento de solicitações
- ✅ Navegação até o passageiro
- ✅ Início e fim de corrida
- ✅ Chat com passageiro
- ✅ Extrato de ganhos
- ✅ Histórico de corridas
- ✅ Avaliação do passageiro

### Painel Admin
- ✅ Dashboard em tempo real
- ✅ Aprovação de motoristas
- ✅ Gerenciamento de usuários
- ✅ Visualização de corridas ativas
- ✅ Configuração de tarifas
- ✅ Gestão de cupons
- ✅ Relatórios financeiros
- ✅ Exportação CSV/PDF
- ✅ Logs do sistema

## 🔧 Instalação e Configuração

### Pré-requisitos
- Docker e Docker Compose
- Git
- Flutter SDK (para desenvolvimento mobile)

### 1. Clone o repositório
```bash
git clone https://github.com/janiosantos/mobi.git
cd mobi
```

### 2. Configure as variáveis de ambiente
```bash
cp backend/.env.example backend/.env
```

Edite `backend/.env` com suas credenciais:
- Banco de dados
- Redis
- Google Maps API Key
- MercadoPago credentials
- Pusher/WebSockets credentials

### 3. Inicie os containers Docker
```bash
cd infra/docker
docker-compose up -d
```

### 4. Instale as dependências do Laravel
```bash
docker-compose exec backend composer install
docker-compose exec backend php artisan key:generate
docker-compose exec backend php artisan migrate --seed
docker-compose exec backend php artisan storage:link
```

### 5. Inicie o Horizon (filas)
```bash
docker-compose exec backend php artisan horizon
```

### 6. Inicie o WebSocket Server
```bash
docker-compose exec websockets php artisan websockets:serve
```

### 7. Configure os apps Flutter

#### App Passageiro
```bash
cd apps/passenger
flutter pub get
flutter run
```

#### App Motorista
```bash
cd apps/driver
flutter pub get
flutter run
```

## 🌐 API Documentation

A documentação completa da API está disponível em:
- **Swagger UI**: `http://localhost:8000/api/documentation`
- **OpenAPI Spec**: `/docs/api/openapi.yaml`

### Principais Endpoints

#### Autenticação
- `POST /api/v1/auth/register` - Registro de usuário
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/logout` - Logout
- `GET /api/v1/auth/me` - Dados do usuário autenticado

#### Corridas (Passageiro)
- `POST /api/v1/rides/estimate` - Estimar preço
- `POST /api/v1/rides` - Solicitar corrida
- `GET /api/v1/rides/{id}` - Detalhes da corrida
- `POST /api/v1/rides/{id}/cancel` - Cancelar corrida
- `POST /api/v1/rides/{id}/rate` - Avaliar corrida

#### Corridas (Motorista)
- `POST /api/v1/driver/rides/{id}/accept` - Aceitar corrida
- `POST /api/v1/driver/rides/{id}/start` - Iniciar corrida
- `POST /api/v1/driver/rides/{id}/complete` - Finalizar corrida
- `POST /api/v1/driver/location` - Atualizar localização

#### Pagamentos
- `POST /api/v1/payments/methods` - Adicionar método de pagamento
- `POST /api/v1/payments/pix` - Gerar QR Code Pix
- `GET /api/v1/payments/history` - Histórico de pagamentos

## 🔐 Segurança

- **Autenticação JWT** via Laravel Sanctum
- **Rate Limiting** em todas as rotas
- **Validação de dados** com Form Requests
- **Policies** para autorização
- **CORS** configurado
- **HTTPS** obrigatório em produção
- **Sanitização** de inputs
- **Encrypted** de dados sensíveis

## 📊 Banco de Dados

### Principais Tabelas
- `users` - Usuários (passageiros e motoristas)
- `driver_profiles` - Perfil completo dos motoristas
- `driver_documents` - Documentos para KYC
- `rides` - Corridas
- `ride_locations` - Rastreamento GPS
- `payments` - Pagamentos
- `ratings` - Avaliações
- `messages` - Chat
- `pricing_rules` - Regras de precificação
- `coupons` - Cupons de desconto

## 🧪 Testes

```bash
# Backend (PHPUnit)
docker-compose exec backend php artisan test

# Flutter (Passenger)
cd apps/passenger
flutter test

# Flutter (Driver)
cd apps/driver
flutter test
```

## 📈 Monitoramento

- **Laravel Horizon**: `http://localhost:8000/horizon`
- **Logs**: `backend/storage/logs/`
- **Redis**: Porta 6379
- **PostgreSQL**: Porta 5432

## 🚢 Deploy

### Produção

```bash
cd infra/scripts
./deploy.sh production
```

### Build Apps Mobile

```bash
# Android (Passenger)
cd apps/passenger
flutter build apk --release

# Android (Driver)
cd apps/driver
flutter build apk --release

# iOS (requer macOS)
flutter build ios --release
```

## 📝 Licença

Este projeto está sob a licença MIT.

## 👥 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📞 Suporte

Para suporte, entre em contato:
- Email: suporte@mobi.com
- Issues: https://github.com/janiosantos/mobi/issues

---

**Desenvolvido com ❤️ para revolucionar a mobilidade urbana**

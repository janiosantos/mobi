# MOBI - Guia de Setup

## 🚀 Quick Start

### Pré-requisitos

- Docker & Docker Compose
- Git
- Make (opcional, mas recomendado)

### 1. Clonar o Repositório

```bash
git clone <repository-url>
cd mobi
```

### 2. Configurar Ambiente

```bash
# Copiar arquivo de ambiente
cp backend/.env.example backend/.env

# Editar .env com suas configurações (opcional para dev local)
# As configurações padrão já funcionam com Docker
```

### 3. Iniciar com Make (Recomendado)

```bash
# Setup inicial completo (build, up, migrate, seed)
make setup

# Acessar aplicação
# Backend API: http://localhost:8000
# Admin Panel: http://localhost:8000/admin
# Mailpit: http://localhost:8025
# MinIO: http://localhost:9001
```

### 4. Ou Iniciar Manualmente

```bash
# Build dos containers
docker-compose build

# Iniciar containers
docker-compose up -d

# Rodar migrations
docker-compose exec backend php artisan migrate

# Rodar seeders
docker-compose exec backend php artisan db:seed
```

## 📦 Serviços Disponíveis

| Serviço | Porta | URL | Descrição |
|---------|-------|-----|-----------|
| Backend API | 8000 | http://localhost:8000 | Laravel API |
| PostgreSQL | 5432 | localhost:5432 | Database |
| Redis | 6379 | localhost:6379 | Cache & Queue |
| Mailpit | 8025 | http://localhost:8025 | Email Testing |
| MinIO | 9001 | http://localhost:9001 | S3 Storage |
| Horizon | - | http://localhost:8000/horizon | Queue Dashboard |

## 🛠️ Comandos Úteis

### Containers

```bash
make up          # Iniciar containers
make down        # Parar containers
make restart     # Reiniciar containers
make logs        # Ver logs
make status      # Status dos containers
```

### Backend

```bash
make shell              # Acessar shell do backend
make migrate            # Rodar migrations
make migrate-fresh      # Fresh migrations
make seed               # Rodar seeders
make fresh              # Fresh + Seed
make test               # Rodar testes
make cache-clear        # Limpar cache
make optimize           # Otimizar aplicação
```

### Desenvolvimento

```bash
make watch-horizon      # Monitorar Horizon
make tinker             # Abrir Tinker
make queue-work         # Rodar queue worker
make filament-user      # Criar usuário admin
```

### Cleanup

```bash
make clean              # Limpar tudo (containers + volumes)
make reset              # Reset completo (clean + setup)
```

## 📱 Apps Mobile (Flutter)

### Passenger App

```bash
cd apps/passenger

# Instalar dependências
flutter pub get

# Rodar app
flutter run
```

### Driver App

```bash
cd apps/driver

# Instalar dependências
flutter pub get

# Rodar app
flutter run
```

## 🔧 Configuração

### Backend (.env)

```env
APP_URL=http://localhost:8000
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=mobi
DB_USERNAME=mobi
DB_PASSWORD=secret

REDIS_HOST=redis
REDIS_PORT=6379

QUEUE_CONNECTION=redis
CACHE_DRIVER=redis
```

### Mobile Apps (.env)

```env
API_BASE_URL=http://localhost:8000/api/v1
GOOGLE_MAPS_API_KEY=your_key_here
MERCADOPAGO_PUBLIC_KEY=your_key_here
```

## 📚 Estrutura do Projeto

```
mobi/
├── backend/              # Laravel 11 API
│   ├── app/
│   │   ├── Models/
│   │   ├── Http/Controllers/
│   │   ├── Services/
│   │   ├── Repositories/
│   │   ├── Jobs/
│   │   ├── Events/
│   │   ├── Policies/
│   │   └── Filament/
│   ├── database/
│   ├── tests/
│   └── routes/
├── apps/
│   ├── passenger/        # App Flutter Passageiro
│   └── driver/           # App Flutter Motorista
├── packages/
│   └── mobi_core/        # Package compartilhado
├── docker-compose.yml
└── Makefile
```

## 🧪 Testes

```bash
# Rodar todos os testes
make test

# Rodar testes específicos
docker-compose exec backend php artisan test --filter=AuthControllerTest

# Rodar com coverage
docker-compose exec backend php artisan test --coverage
```

## 🔍 Troubleshooting

### Containers não iniciam

```bash
# Ver logs
make logs

# Rebuild
make clean
make build
make up
```

### Erro de permissões

```bash
# No backend
docker-compose exec backend chown -R www-data:www-data storage bootstrap/cache
```

### Limpar cache

```bash
make cache-clear
```

## 📖 Documentação Adicional

- [API Documentation](./docs/API.md)
- [Database Schema](./docs/DATABASE.md)
- [Architecture](./docs/ARCHITECTURE.md)

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

MIT License

.PHONY: help build up down restart logs shell migrate seed fresh test

help: ## Mostrar ajuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build dos containers
	docker-compose build

up: ## Iniciar containers
	docker-compose up -d

down: ## Parar containers
	docker-compose down

restart: down up ## Reiniciar containers

logs: ## Ver logs
	docker-compose logs -f

logs-backend: ## Ver logs do backend
	docker-compose logs -f backend

logs-horizon: ## Ver logs do Horizon
	docker-compose logs -f horizon

shell: ## Acessar shell do backend
	docker-compose exec backend sh

shell-postgres: ## Acessar shell do PostgreSQL
	docker-compose exec postgres psql -U mobi -d mobi

migrate: ## Rodar migrations
	docker-compose exec backend php artisan migrate

migrate-fresh: ## Rodar migrations fresh
	docker-compose exec backend php artisan migrate:fresh

seed: ## Rodar seeders
	docker-compose exec backend php artisan db:seed

fresh: ## Fresh + Seed
	docker-compose exec backend php artisan migrate:fresh --seed

test: ## Rodar testes
	docker-compose exec backend php artisan test

cache-clear: ## Limpar cache
	docker-compose exec backend php artisan cache:clear
	docker-compose exec backend php artisan config:clear
	docker-compose exec backend php artisan route:clear
	docker-compose exec backend php artisan view:clear

optimize: ## Otimizar aplicação
	docker-compose exec backend php artisan optimize

composer-install: ## Instalar dependências Composer
	docker-compose exec backend composer install

npm-install: ## Instalar dependências NPM
	docker-compose exec backend npm install

npm-build: ## Build assets
	docker-compose exec backend npm run build

setup: build up migrate seed ## Setup inicial completo
	@echo "✅ Setup completo! Acesse http://localhost:8000"

status: ## Ver status dos containers
	docker-compose ps

clean: down ## Limpar tudo
	docker-compose down -v
	rm -rf backend/vendor backend/node_modules

reset: clean setup ## Reset completo

watch-horizon: ## Monitorar Horizon
	docker-compose exec backend php artisan horizon

tinker: ## Abrir tinker
	docker-compose exec backend php artisan tinker

queue-work: ## Rodar queue worker manualmente
	docker-compose exec backend php artisan queue:work

filament-user: ## Criar usuário admin do Filament
	docker-compose exec backend php artisan make:filament-user

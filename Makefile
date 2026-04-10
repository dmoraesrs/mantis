.PHONY: help up down restart logs logs-backend logs-web logs-db logs-vl \
       build rebuild status ps clean purge \
       dev dev-backend dev-web install install-backend install-web \
       test lint format check \
       db-shell db-reset vl-query vl-errors vl-stats \
       trigger fingerprints health metrics \
       gen-logs gen-logs-small gen-logs-large gen-logs-chaos \
       k8s-apply k8s-delete k8s-status k8s-logs k8s-port-forward \
       setup-projeto setup-projeto-force code-base code-base-here \
       check-deps list-agents list-mcps

# Cores
GREEN  := \033[0;32m
YELLOW := \033[0;33m
CYAN   := \033[0;36m
RESET  := \033[0m

help: ## Mostra este help
	@echo ""
	@echo "$(CYAN)MANTIS - Log Analyzer Agent$(RESET)"
	@echo ""
	@echo "$(YELLOW)Docker Compose:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E 'up|down|restart|build|rebuild|status|clean|purge|logs' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Dev Local (sem Docker):$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E 'dev|install' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Qualidade:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E 'test|lint|format|check' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Banco e VictoriaLogs:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E 'db-|vl-' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)API:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E 'trigger|fingerprints|health|metrics' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Kubernetes:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E 'k8s-' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Claude Code Toolkit:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E 'setup-projeto|code-base|check-deps|list-agents|list-mcps' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""

# ====================
# Docker Compose
# ====================

up: ## Sobe todos os servicos (postgres + victorialogs + backend + web)
	docker compose up -d
	@echo "$(GREEN)Servicos iniciados:$(RESET)"
	@echo "  Backend:       http://localhost:8000"
	@echo "  Frontend:      http://localhost:3000"
	@echo "  VictoriaLogs:  http://localhost:9428"
	@echo "  PostgreSQL:    localhost:5432"

down: ## Para todos os servicos
	docker compose down

restart: ## Reinicia todos os servicos
	docker compose restart

build: ## Builda as imagens
	docker compose build

rebuild: ## Rebuilda as imagens do zero (sem cache)
	docker compose build --no-cache

status: ## Mostra status dos containers
	docker compose ps

logs: ## Mostra logs de todos os servicos (follow)
	docker compose logs -f

logs-backend: ## Mostra logs do backend (follow)
	docker compose logs -f backend

logs-web: ## Mostra logs do frontend (follow)
	docker compose logs -f web

logs-db: ## Mostra logs do PostgreSQL (follow)
	docker compose logs -f postgres

logs-vl: ## Mostra logs do VictoriaLogs (follow)
	docker compose logs -f victorialogs

clean: ## Para containers e remove volumes
	docker compose down -v

purge: ## Remove tudo (containers, volumes, imagens)
	docker compose down -v --rmi all

# ====================
# Dev Local (sem Docker)
# ====================

install: install-backend install-web ## Instala dependencias (backend + frontend)

install-backend: ## Instala dependencias do backend
	pip install -e '.[dev]'

install-web: ## Instala dependencias do frontend
	cd web && npm install

dev: ## Sobe backend + frontend local (precisa de postgres e victorialogs rodando)
	@echo "$(YELLOW)Subindo infra (postgres + victorialogs)...$(RESET)"
	docker compose up -d postgres victorialogs
	@echo "$(GREEN)Aguardando postgres...$(RESET)"
	@sleep 3
	@echo "$(GREEN)Iniciando backend e frontend...$(RESET)"
	@trap 'kill %1 %2 2>/dev/null' EXIT; \
	python -m src & \
	cd web && npm run dev & \
	wait

dev-backend: ## Sobe apenas o backend local
	docker compose up -d postgres victorialogs
	@sleep 2
	python -m src

dev-web: ## Sobe apenas o frontend local
	cd web && npm run dev

# ====================
# Qualidade
# ====================

test: ## Roda testes
	pytest tests/ -v --cov=src --cov-report=term-missing

lint: ## Roda linter (ruff)
	ruff check src/

format: ## Formata codigo (ruff)
	ruff format src/

check: lint test ## Roda lint + testes

# ====================
# Banco e VictoriaLogs
# ====================

db-shell: ## Abre shell do PostgreSQL
	docker compose exec postgres psql -U mantis -d mantis

db-reset: ## Reseta o banco (drop + recreate tabelas)
	docker compose exec postgres psql -U mantis -d mantis -c "DROP TABLE IF EXISTS error_fingerprints CASCADE;"
	@echo "$(GREEN)Tabela removida. Sera recriada no proximo start do backend.$(RESET)"

vl-query: ## Query de teste no VictoriaLogs (erros dos ultimos 15min)
	@curl -s -X POST 'http://localhost:9428/select/logsql/query' \
		-d 'query=_msg:error&start=-15m&end=now&limit=10' | head -20 || \
		echo "$(YELLOW)VictoriaLogs sem logs. Use: make gen-logs$(RESET)"

vl-errors: ## Mostra apenas erros fatais/criticos no VictoriaLogs
	@curl -s -X POST 'http://localhost:9428/select/logsql/query' \
		-d 'query=level:in(error,fatal)&start=-1h&end=now&limit=20'

vl-stats: ## Contagem de erros por servico
	@curl -s -X POST 'http://localhost:9428/select/logsql/query' \
		-d 'query=level:in(error,fatal) | stats by (service) count() as total&start=-1h&end=now' || \
		echo "$(YELLOW)Sem dados. Use: make gen-logs$(RESET)"

# ====================
# Gerar Logs de Teste
# ====================

gen-logs: ## Gera 50 logs de teste (mix de erros e normais)
	@bash scripts/generate-test-logs.sh http://localhost:9428 50

gen-logs-small: ## Gera 10 logs de teste (rapido)
	@bash scripts/generate-test-logs.sh http://localhost:9428 10

gen-logs-large: ## Gera 200 logs de teste (volume alto)
	@bash scripts/generate-test-logs.sh http://localhost:9428 200

gen-logs-chaos: ## Gera 500 logs de teste (simula incidente)
	@echo "$(YELLOW)Simulando incidente com 500 logs...$(RESET)"
	@bash scripts/generate-test-logs.sh http://localhost:9428 500
	@echo "$(GREEN)Incidente simulado. Use: make trigger$(RESET)"

# ====================
# API do MANTIS
# ====================

health: ## Verifica health do backend
	@curl -s http://localhost:8000/healthz | python3 -m json.tool

metrics: ## Mostra metricas Prometheus
	@curl -s http://localhost:8000/metrics | head -30

trigger: ## Dispara analise manual
	@echo "$(YELLOW)Disparando analise...$(RESET)"
	@curl -s -X POST http://localhost:8000/api/v1/analyze/trigger | python3 -m json.tool

fingerprints: ## Lista fingerprints abertos
	@curl -s 'http://localhost:8000/api/v1/fingerprints?status=open' | python3 -m json.tool

# ====================
# Kubernetes
# ====================

k8s-apply: ## Aplica manifests no cluster
	kubectl apply -k k8s/

k8s-delete: ## Remove manifests do cluster
	kubectl delete -k k8s/

k8s-status: ## Status dos pods MANTIS
	kubectl get pods -n mantis

k8s-logs: ## Logs do backend no K8s
	kubectl logs -n mantis -l app=backend -f

k8s-port-forward: ## Port-forward para acesso local
	@echo "Backend: http://localhost:8000"
	@echo "Frontend: http://localhost:3000"
	@kubectl port-forward -n mantis svc/web 3000:3000 & kubectl port-forward -n mantis svc/backend 8000:8000

# ====================
# Claude Code Toolkit
# ====================

TOOLKIT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

setup-projeto: ## Configura Claude Code + Agentes em um projeto (uso: make setup-projeto PROJETO=/caminho)
	@if [ -z "$(PROJETO)" ]; then \
		echo "$(YELLOW)[ERRO] Informe o caminho: make setup-projeto PROJETO=/caminho/do/projeto$(RESET)"; \
		exit 1; \
	fi
	@bash $(TOOLKIT_DIR)/scripts/setup-projeto.sh "$(PROJETO)" $(ARGS)

setup-projeto-force: ## Mesmo que setup-projeto mas sobrescreve existentes
	@if [ -z "$(PROJETO)" ]; then \
		echo "$(YELLOW)[ERRO] Informe o caminho: make setup-projeto-force PROJETO=/caminho/do/projeto$(RESET)"; \
		exit 1; \
	fi
	@bash $(TOOLKIT_DIR)/scripts/setup-projeto.sh "$(PROJETO)" --force

code-base: ## Analisa codebase e gera contexto para pair programming (uso: make code-base PROJETO=/caminho)
	@if [ -z "$(PROJETO)" ]; then \
		echo "$(YELLOW)[ERRO] Informe o caminho: make code-base PROJETO=/caminho/do/projeto$(RESET)"; \
		exit 1; \
	fi
	@echo "$(CYAN)Iniciando analise do codebase em $(PROJETO)...$(RESET)"
	@cd "$(PROJETO)" && claude --print "/code-base"

code-base-here: ## Analisa codebase do diretorio atual
	@echo "$(CYAN)Iniciando analise do codebase...$(RESET)"
	@claude --print "/code-base"

check-deps: ## Verifica dependencias do toolkit (pre-commit, gitleaks, npx, claude)
	@echo "$(CYAN)Verificando dependencias...$(RESET)"
	@printf "  %-20s" "pre-commit:" && (command -v pre-commit >/dev/null 2>&1 && echo "$(GREEN)OK$(RESET)" || echo "$(YELLOW)FALTA - pip install pre-commit$(RESET)")
	@printf "  %-20s" "gitleaks:" && (command -v gitleaks >/dev/null 2>&1 && echo "$(GREEN)OK$(RESET)" || echo "$(YELLOW)FALTA - brew install gitleaks$(RESET)")
	@printf "  %-20s" "npx:" && (command -v npx >/dev/null 2>&1 && echo "$(GREEN)OK$(RESET)" || echo "$(YELLOW)FALTA - instale Node.js$(RESET)")
	@printf "  %-20s" "claude:" && (command -v claude >/dev/null 2>&1 && echo "$(GREEN)OK$(RESET)" || echo "$(YELLOW)FALTA - npm install -g @anthropic-ai/claude-code$(RESET)")

list-agents: ## Lista todos os agentes disponiveis
	@echo ""
	@echo "$(CYAN)Agentes Disponiveis$(RESET)"
	@echo ""
	@find $(TOOLKIT_DIR)/agents -name "*.md" -not -name "README.md" -not -name "TEMPLATE*" | sort | while read f; do \
		dir=$$(dirname "$$f" | xargs basename); \
		name=$$(basename "$$f" .md); \
		printf "  $(GREEN)%-25s$(RESET) %s\n" "$$name" "($$dir)"; \
	done
	@echo ""

list-mcps: ## Lista MCPs configurados
	@echo ""
	@echo "$(CYAN)MCPs Configurados$(RESET)"
	@echo ""
	@if [ -f "$(TOOLKIT_DIR)/.claude/settings.json" ]; then \
		grep '"description"' "$(TOOLKIT_DIR)/.claude/settings.json" | sed 's/.*"description": "//;s/"//' | while read desc; do \
			printf "  - %s\n" "$$desc"; \
		done; \
	fi
	@echo ""

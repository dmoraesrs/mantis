#!/usr/bin/env bash
# setup-projeto.sh - Configura Claude Code + Agentes em qualquer projeto
# Uso: ./setup-projeto.sh /caminho/do/projeto [--force]
set -euo pipefail

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJETO_DIR="${1:-}"
FORCE="${2:-}"

banner() {
  echo -e "${CYAN}"
  echo "  ╔══════════════════════════════════════════════╗"
  echo "  ║      SETUP PROJETO - Claude Code Toolkit     ║"
  echo "  ╚══════════════════════════════════════════════╝"
  echo -e "${NC}"
}

log_info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERRO]${NC}  $1"; }

usage() {
  echo "Uso: $0 <caminho-do-projeto> [--force]"
  echo ""
  echo "Argumentos:"
  echo "  caminho-do-projeto   Diretorio raiz do projeto alvo"
  echo "  --force              Sobrescreve arquivos existentes"
  echo ""
  echo "Exemplo:"
  echo "  $0 /home/user/meu-projeto"
  echo "  $0 ../minha-api --force"
  exit 1
}

# Validacoes
banner

if [[ -z "$PROJETO_DIR" ]]; then
  log_error "Caminho do projeto nao informado"
  usage
fi

PROJETO_DIR="$(cd "$PROJETO_DIR" 2>/dev/null && pwd || echo "$PROJETO_DIR")"

if [[ ! -d "$PROJETO_DIR" ]]; then
  log_error "Diretorio nao existe: $PROJETO_DIR"
  exit 1
fi

log_info "Toolkit:  $TOOLKIT_DIR"
log_info "Projeto:  $PROJETO_DIR"
echo ""

# ============================================================
# 1. Criar estrutura .claude/
# ============================================================
log_info "Configurando .claude/ ..."

mkdir -p "$PROJETO_DIR/.claude/skills"

# Copiar settings.json (MCPs)
if [[ -f "$PROJETO_DIR/.claude/settings.json" && "$FORCE" != "--force" ]]; then
  log_warn ".claude/settings.json ja existe (use --force para sobrescrever)"
else
  cp "$TOOLKIT_DIR/.claude/settings.json" "$PROJETO_DIR/.claude/settings.json"
  log_ok ".claude/settings.json (MCPs configurados)"
fi

# Copiar skills
if [[ -d "$TOOLKIT_DIR/.claude/skills" ]]; then
  SKILLS_COUNT=0
  for skill_dir in "$TOOLKIT_DIR/.claude/skills"/*/; do
    skill_name="$(basename "$skill_dir")"
    target_dir="$PROJETO_DIR/.claude/skills/$skill_name"
    if [[ -d "$target_dir" && "$FORCE" != "--force" ]]; then
      log_warn "Skill '$skill_name' ja existe (use --force)"
    else
      mkdir -p "$target_dir"
      cp -r "$skill_dir"* "$target_dir/" 2>/dev/null || true
      SKILLS_COUNT=$((SKILLS_COUNT + 1))
    fi
  done
  log_ok "$SKILLS_COUNT skills copiadas"
fi

# ============================================================
# 2. Copiar agentes
# ============================================================
log_info "Copiando agentes ..."

if [[ -d "$PROJETO_DIR/agents" && "$FORCE" != "--force" ]]; then
  log_warn "agents/ ja existe (use --force para sobrescrever)"
else
  mkdir -p "$PROJETO_DIR/agents"
  cp -r "$TOOLKIT_DIR/agents/"* "$PROJETO_DIR/agents/"
  AGENT_COUNT=$(find "$PROJETO_DIR/agents" -name "*.md" -not -name "README.md" -not -name "TEMPLATE*" | wc -l | tr -d ' ')
  log_ok "$AGENT_COUNT agentes copiados"
fi

# ============================================================
# 3. Configurar .gitignore
# ============================================================
log_info "Configurando .gitignore ..."

GITIGNORE_ENTRIES=(
  "# Claude Code"
  ".claude/settings.local.json"
  ".claude/memory/"
  ".claude/todos/"
  ".claude/analytics/"
)

if [[ -f "$PROJETO_DIR/.gitignore" ]]; then
  ADDED=0
  for entry in "${GITIGNORE_ENTRIES[@]}"; do
    if ! grep -qF "$entry" "$PROJETO_DIR/.gitignore" 2>/dev/null; then
      echo "$entry" >> "$PROJETO_DIR/.gitignore"
      ADDED=1
    fi
  done
  if [[ $ADDED -eq 1 ]]; then
    log_ok ".gitignore atualizado com exclusoes do Claude"
  else
    log_ok ".gitignore ja continha as exclusoes"
  fi
else
  printf '%s\n' "${GITIGNORE_ENTRIES[@]}" > "$PROJETO_DIR/.gitignore"
  log_ok ".gitignore criado"
fi

# ============================================================
# 4. Configurar pre-commit hooks
# ============================================================
log_info "Configurando pre-commit hooks ..."

if [[ -f "$PROJETO_DIR/.pre-commit-config.yaml" && "$FORCE" != "--force" ]]; then
  log_warn ".pre-commit-config.yaml ja existe (use --force)"
else
  cp "$TOOLKIT_DIR/.pre-commit-config.yaml" "$PROJETO_DIR/.pre-commit-config.yaml"
  log_ok ".pre-commit-config.yaml copiado"
fi

# Copiar scripts de seguranca do pre-commit
mkdir -p "$PROJETO_DIR/scripts"
for script in "$TOOLKIT_DIR/scripts"/block-*.sh; do
  if [[ -f "$script" ]]; then
    script_name="$(basename "$script")"
    cp "$script" "$PROJETO_DIR/scripts/$script_name"
    chmod +x "$PROJETO_DIR/scripts/$script_name"
  fi
done
log_ok "Scripts de seguranca copiados"

# Copiar gitleaks config se existir
if [[ -f "$TOOLKIT_DIR/.gitleaks.toml" ]]; then
  cp "$TOOLKIT_DIR/.gitleaks.toml" "$PROJETO_DIR/.gitleaks.toml"
  log_ok ".gitleaks.toml copiado"
fi

# ============================================================
# 5. Criar CLAUDE.md se nao existir
# ============================================================
log_info "Configurando CLAUDE.md ..."

if [[ -f "$PROJETO_DIR/CLAUDE.md" && "$FORCE" != "--force" ]]; then
  log_warn "CLAUDE.md ja existe (use --force)"
else
  PROJETO_NOME="$(basename "$PROJETO_DIR")"
  cat > "$PROJETO_DIR/CLAUDE.md" << 'CLAUDEMD'
# CLAUDE.md - Instrucoes do Projeto

## Agentes Disponiveis

Este projeto utiliza o sistema multi-agente. Consulte `agents/README.md` para lista completa.

### Comandos Rapidos

```
/orquestrador [tarefa complexa multi-dominio]
/code-base                              # Analisa codebase e gera documentacao
/k8s [problema kubernetes]
/devops [tarefa CI/CD]
/secops [review de seguranca]
```

### MCPs Configurados

Os seguintes MCPs estao disponiveis em `.claude/settings.json`:

| MCP | Funcao |
|-----|--------|
| context7 | Docs atualizadas de libs/frameworks |
| serena | Analise semantica de codigo |
| sequential-thinking | Raciocinio estruturado |
| postgres | Schema e queries PostgreSQL |
| mysql | Schema e queries MySQL |
| sqlserver | Schema e queries SQL Server |
| docker | Containers e imagens |
| kubernetes | Clusters e workloads K8s |
| github | Repos, PRs, issues |
| azure-devops | Work items, pipelines |
| brave-search | Pesquisa web tecnica |
| filesystem | Sistema de arquivos |

> **IMPORTANTE:** MCPs de banco devem apontar para replicas READ-ONLY.
> Configure as variaveis de ambiente no `.env` do projeto.

## Regras

- Sempre responda em portugues brasileiro (pt-BR)
- Nunca inclua comentarios mencionando IA/Claude/Anthropic no codigo
- Nunca inclua Co-Authored-By de IA nos commits
- Rode build/testes antes de commitar
CLAUDEMD
  log_ok "CLAUDE.md criado"
fi

# ============================================================
# 6. Criar .env.example para MCPs
# ============================================================
log_info "Criando .env.example ..."

if [[ ! -f "$PROJETO_DIR/.env.example" || "$FORCE" == "--force" ]]; then
  cat > "$PROJETO_DIR/.env.example" << 'ENVEXAMPLE'
# ============================================================
# Variaveis de ambiente para MCPs do Claude Code
# Copie para .env e preencha os valores
# ============================================================

# GitHub
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx

# PostgreSQL (USAR REPLICA READ-ONLY!)
POSTGRES_CONNECTION_STRING=postgresql://user:pass@readonly-host:5432/dbname

# MySQL (USAR REPLICA READ-ONLY!)
MYSQL_HOST=readonly-host
MYSQL_PORT=3306
MYSQL_USER=readonly_user
MYSQL_PASSWORD=
MYSQL_DATABASE=dbname

# SQL Server (USAR REPLICA READ-ONLY!)
MSSQL_CONNECTION_STRING=Server=readonly-host;Database=dbname;User Id=reader;Password=;

# Azure DevOps
AZURE_DEVOPS_ORG_URL=https://dev.azure.com/sua-org
AZURE_DEVOPS_PAT=

# Brave Search
BRAVE_API_KEY=

# Projeto
PROJECT_ROOT=.
ENVEXAMPLE
  log_ok ".env.example criado"
else
  log_warn ".env.example ja existe"
fi

# ============================================================
# 7. Instalar pre-commit (se disponivel)
# ============================================================
log_info "Verificando pre-commit ..."

if command -v pre-commit &>/dev/null; then
  cd "$PROJETO_DIR"
  if [[ -d .git ]]; then
    pre-commit install 2>/dev/null && log_ok "pre-commit hooks instalados" || log_warn "Falha ao instalar hooks (rode 'pre-commit install' manualmente)"
  else
    log_warn "Nao e um repositorio git - rode 'git init && pre-commit install' depois"
  fi
else
  log_warn "pre-commit nao encontrado - instale com: pip install pre-commit"
fi

# ============================================================
# Resumo
# ============================================================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            SETUP CONCLUIDO!                  ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Projeto: ${CYAN}$PROJETO_DIR${NC}"
echo ""
echo -e "  ${YELLOW}Proximos passos:${NC}"
echo -e "  1. Copie .env.example para .env e preencha as credenciais"
echo -e "  2. Rode ${CYAN}cd $PROJETO_DIR && claude${NC} para iniciar"
echo -e "  3. Use ${CYAN}/code-base${NC} para analisar o codebase"
echo -e "  4. Use ${CYAN}/orquestrador${NC} para tarefas complexas"
echo ""
echo -e "  ${YELLOW}MCPs que precisam de configuracao:${NC}"
echo -e "  - postgres:      POSTGRES_CONNECTION_STRING (replica read-only)"
echo -e "  - mysql:         MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD"
echo -e "  - sqlserver:     MSSQL_CONNECTION_STRING (replica read-only)"
echo -e "  - github:        GITHUB_TOKEN"
echo -e "  - azure-devops:  AZURE_DEVOPS_ORG_URL, AZURE_DEVOPS_PAT"
echo -e "  - brave-search:  BRAVE_API_KEY"
echo ""

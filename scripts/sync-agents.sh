#!/usr/bin/env bash
# sync-agents.sh - Atualiza submodule de agentes para a versao mais recente
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo -e "${BLUE}[INFO]${NC}  Atualizando submodule .agentes-repo ..."
git submodule update --remote .agentes-repo

CHANGES=$(git diff --name-only .agentes-repo)
if [[ -z "$CHANGES" ]]; then
  echo -e "${GREEN}[OK]${NC}    Submodule ja esta na versao mais recente. Nada a fazer."
  exit 0
fi

LATEST_MSG=$(git -C .agentes-repo log -1 --format="%s")
echo -e "${GREEN}[OK]${NC}    Submodule atualizado para: ${YELLOW}${LATEST_MSG}${NC}"

git add .agentes-repo
git commit -m "chore: atualiza submodule agentes

Ultimo commit: ${LATEST_MSG}"

echo -e "${GREEN}[OK]${NC}    Commit criado no mantis."

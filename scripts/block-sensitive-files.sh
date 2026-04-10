#!/usr/bin/env bash
# Bloqueia commit de arquivos sensiveis por extensao/nome
set -euo pipefail

BLOCKED=0
for f in "$@"; do
  case "$f" in
    *.env|*.env.*|*.pem|*.key|*.p12|*.pfx|*.jks)
      echo "BLOQUEADO: $f - arquivo sensivel nao permitido"
      BLOCKED=1 ;;
    *id_rsa*|*id_ed25519*|*.credentials|*credentials.json)
      echo "BLOQUEADO: $f - credencial nao permitida"
      BLOCKED=1 ;;
    *service-account*.json|*.tfstate|*.tfvars)
      echo "BLOQUEADO: $f - arquivo de infraestrutura sensivel"
      BLOCKED=1 ;;
    *kubeconfig|*.htpasswd|*.npmrc|*.pypirc)
      echo "BLOQUEADO: $f - arquivo com possiveis tokens"
      BLOCKED=1 ;;
  esac
done

exit $BLOCKED

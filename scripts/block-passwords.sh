#!/usr/bin/env bash
# Detecta senhas hardcoded suspeitas (ignora placeholders)
set -euo pipefail

FOUND=0
for f in "$@"; do
  # Busca padroes como password: "valor", POSTGRES_PASSWORD=valor, senha="valor"
  if grep -Ein '(password|passwd|pwd|senha)\s*[:=]\s*["\x27][^<$\{"\x27]{8,}' "$f" 2>/dev/null | \
     grep -iv 'ALTERAR\|EXAMPLE\|CHANGE\|PLACEHOLDER\|YOUR_\|TODO\|SUBSTITUA\|NAO_REAL\|TROCAR' | \
     grep -q .; then
    echo "ALERTA em $f: Possivel senha hardcoded detectada:"
    grep -Ein '(password|passwd|pwd|senha)\s*[:=]\s*["\x27][^<$\{"\x27]{8,}' "$f" | \
      grep -iv 'ALTERAR\|EXAMPLE\|CHANGE\|PLACEHOLDER\|YOUR_\|TODO\|SUBSTITUA\|NAO_REAL\|TROCAR'
    FOUND=1
  fi
done

exit $FOUND

#!/usr/bin/env bash
# Detecta credenciais AWS (Access Key, Secret Key, Account ID, ARNs reais)
set -euo pipefail

FOUND=0
for f in "$@"; do
  # AWS Access Key ID (AKIA, ASIA, AGPA, AIDA, AROA, AIPA, ANPA, ANVA)
  if grep -En '(AKIA|ASIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA)[A-Z0-9]{16}' "$f" 2>/dev/null | \
     grep -v 'AKIA1234567890ABCDEF' | \
     grep -v 'AKIAIOSFODNN7EXAMPLE' | \
     grep -v '<SUA_ACCESS_KEY>' | \
     grep -q .; then
    echo "BLOQUEADO em $f: AWS Access Key ID possivelmente real:"
    grep -En '(AKIA|ASIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA)[A-Z0-9]{16}' "$f" | \
      grep -v 'AKIA1234567890ABCDEF' | \
      grep -v 'AKIAIOSFODNN7EXAMPLE' | \
      grep -v '<SUA_ACCESS_KEY>'
    FOUND=1
  fi

  # AWS Secret Access Key (40 chars base64 em contexto aws_secret)
  if grep -Ein '(aws_secret_access_key|aws_secret_key|secret_access_key)\s*[:=]\s*["'"'"']?[A-Za-z0-9/+=]{40}' "$f" 2>/dev/null | \
     grep -iv 'EXAMPLE\|ALTERAR\|CHANGE\|PLACEHOLDER\|YOUR_\|TODO\|SUBSTITUA\|wJalrXUtnFEMI' | \
     grep -q .; then
    echo "BLOQUEADO em $f: AWS Secret Access Key possivelmente real:"
    grep -Ein '(aws_secret_access_key|aws_secret_key|secret_access_key)\s*[:=]\s*["'"'"']?[A-Za-z0-9/+=]{40}' "$f" | \
      grep -iv 'EXAMPLE\|ALTERAR\|CHANGE\|PLACEHOLDER\|YOUR_\|TODO\|SUBSTITUA\|wJalrXUtnFEMI'
    FOUND=1
  fi

  # AWS ARN com Account ID real (nao placeholder)
  if grep -En 'arn:aws:[a-z0-9-]+:[a-z0-9-]*:[0-9]{12}:' "$f" 2>/dev/null | \
     grep -v '123456789012' | \
     grep -v '000000000000' | \
     grep -q .; then
    echo "BLOQUEADO em $f: AWS ARN com Account ID possivelmente real:"
    grep -En 'arn:aws:[a-z0-9-]+:[a-z0-9-]*:[0-9]{12}:' "$f" | \
      grep -v '123456789012' | \
      grep -v '000000000000'
    FOUND=1
  fi

  # AWS RDS endpoint real
  if grep -En '[a-z][a-z0-9-]+\.[a-z0-9]+\.[a-z]{2}-[a-z]+-[0-9]\.rds\.amazonaws\.com' "$f" 2>/dev/null | \
     grep -iv 'exemplo\|example\|meu-banco\|<SEU' | \
     grep -q .; then
    echo "BLOQUEADO em $f: AWS RDS endpoint possivelmente real:"
    grep -En '[a-z][a-z0-9-]+\.[a-z0-9]+\.[a-z]{2}-[a-z]+-[0-9]\.rds\.amazonaws\.com' "$f" | \
      grep -iv 'exemplo\|example\|meu-banco\|<SEU'
    FOUND=1
  fi

  # AWS Secrets Manager ARN
  if grep -Ein 'arn:aws:secretsmanager:[a-z0-9-]+:[0-9]{12}:secret:' "$f" 2>/dev/null | \
     grep -v '123456789012' | \
     grep -v '000000000000' | \
     grep -iv '<SUA_SECRET' | \
     grep -q .; then
    echo "BLOQUEADO em $f: AWS Secrets Manager ARN possivelmente real:"
    grep -Ein 'arn:aws:secretsmanager:[a-z0-9-]+:[0-9]{12}:secret:' "$f" | \
      grep -v '123456789012' | \
      grep -v '000000000000' | \
      grep -iv '<SUA_SECRET'
    FOUND=1
  fi
done

exit $FOUND

#!/usr/bin/env bash
# Detecta CPFs possivelmente reais (ignora CPFs obvios de exemplo)
set -euo pipefail

FOUND=0
for f in "$@"; do
  # Busca CPFs no formato XXX.XXX.XXX-XX
  if grep -En '[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}' "$f" 2>/dev/null | \
     grep -v '123\.456\.789-00' | \
     grep -v '000\.000\.000-00' | \
     grep -v '111\.111\.111-11' | \
     grep -v '999\.999\.999-99' | \
     grep -q .; then
    echo "ALERTA em $f: CPF possivelmente real detectado:"
    grep -En '[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}' "$f" | \
      grep -v '123\.456\.789-00' | \
      grep -v '000\.000\.000-00' | \
      grep -v '111\.111\.111-11' | \
      grep -v '999\.999\.999-99'
    FOUND=1
  fi

  # Busca CNPJs no formato XX.XXX.XXX/XXXX-XX
  if grep -En '[0-9]{2}\.[0-9]{3}\.[0-9]{3}/[0-9]{4}-[0-9]{2}' "$f" 2>/dev/null | \
     grep -v '00\.000\.000/0001-91' | \
     grep -q .; then
    echo "ALERTA em $f: CNPJ possivelmente real detectado:"
    grep -En '[0-9]{2}\.[0-9]{3}\.[0-9]{3}/[0-9]{4}-[0-9]{2}' "$f" | \
      grep -v '00\.000\.000/0001-91'
    FOUND=1
  fi
done

exit $FOUND

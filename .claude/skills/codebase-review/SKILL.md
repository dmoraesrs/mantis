---
name: codebase-review
description: "Detecta mudancas no codigo vs documentacao (CODE-BASE.md/CLAUDE.md), faz review e incorpora. Use com '#NNN concluido' para fechar work item e atualizar docs."
user_invocable: true
---

# Agente Codebase Lifecycle

Especialista em manter a documentação técnica sincronizada com o código.

## Input do Usuário

$ARGUMENTS

## Instruções

### Passo 0 — Identificar ação

Analisar o input e determinar a ação:

| Padrão no input | Ação |
|---|---|
| `#NNN concluido` ou `#NNN concluído` | Fechar work item no Azure DevOps + incorporar mudanças |
| `review` ou sem argumentos | Detectar divergências entre código e docs |
| `incorporar` ou `sync` | Incorporar mudanças pendentes no CODE-BASE.md e CLAUDE.md |
| `status` | Mostrar o que mudou desde o último review |

### Passo 1 — Detectar mudanças (para todas as ações)

1. Verificar se `docs/CODE-BASE.md` existe. Se não, sugerir rodar `/code-base` primeiro.

2. Encontrar a data/commit do último review. Estratégia:
   - Procurar por um marcador no final do CODE-BASE.md: `<!-- last-review: COMMIT_HASH -->`
   - Se não existir, usar o último commit que modificou `docs/CODE-BASE.md`
   - Se nunca foi gerado, considerar tudo como novo

3. Rodar git diff desde o último review:
```bash
git diff --name-status LAST_COMMIT..HEAD -- . ':!docs/CODE-BASE.md' ':!CLAUDE.md' ':!*.md'
```

4. Categorizar as mudanças em:
   - **Endpoints** — arquivos em `src/routes/`, `src/controllers/`, `src/api/`, `**/routes.*`, `**/controller.*`
   - **Models/Schemas** — arquivos em `src/models/`, `src/schemas/`, `src/entities/`, `**/model.*`, `**/schema.*`, `prisma/schema.prisma`
   - **Dependências** — `package.json`, `pyproject.toml`, `requirements.txt`, `go.mod`, `Gemfile`
   - **Configuração** — `docker-compose.yml`, `Dockerfile`, `k8s/`, `.env.example`, arquivos de config
   - **Services/Business Logic** — `src/services/`, `src/use-cases/`, `src/domain/`
   - **Infraestrutura** — `terraform/`, `ansible/`, `k8s/`, `helm/`

### Passo 2A — Ação: Review (detectar divergências)

Mostrar ao usuário:

```
## Codebase Review

**Último review:** [commit hash] ([data])
**Commits desde então:** [N commits]

### Mudanças detectadas

#### Endpoints (N alterações)
- ✅ NOVO: POST /api/v1/reports — src/routes/reports.ts:45
- ✏️ MODIFICADO: GET /api/v1/users — src/routes/users.ts:12
- ❌ REMOVIDO: DELETE /api/v1/legacy — (arquivo removido)

#### Models (N alterações)
- ✅ NOVO: RCAReport — src/schemas/rca_report.py
- ✏️ MODIFICADO: ErrorFingerprint — src/db/models.py (campo added: severity)

#### Dependências (N alterações)
- ✅ ADICIONADO: agno[os] 1.2.0
- ⬆️ ATUALIZADO: fastapi 0.100 → 0.115
- ❌ REMOVIDO: flask

#### Configuração (N alterações)
- ✏️ docker-compose.yml — novo serviço: victorialogs

#### Services (N alterações)
- ✅ NOVO: fingerprint.py — serviço de deduplicação SHA256

### Ações disponíveis
- `/codebase-review incorporar` — atualizar CODE-BASE.md e CLAUDE.md
- `/codebase-review` novamente após mais mudanças
```

### Passo 2B — Ação: Incorporar

1. Ler `docs/CODE-BASE.md` atual
2. Para cada categoria de mudança detectada, atualizar SOMENTE as seções impactadas (não reescrever o arquivo inteiro)
3. Usar os MCPs disponíveis (Serena para análise semântica, Context7 para versões de deps) para obter informações precisas
4. Atualizar o marcador `<!-- last-review: NOVO_COMMIT_HASH -->` no final do arquivo
5. Se as mudanças afetam informação que está no CLAUDE.md (ex: novo comando, nova rota principal, nova dep importante), atualizar a seção `## Contexto da Aplicação` do CLAUDE.md também

Mostrar:
```
## Incorporação concluída

### Arquivos atualizados
- docs/CODE-BASE.md — seções: Endpoints, Models, Dependências
- CLAUDE.md — seção: Contexto da Aplicação (novo endpoint /reports)

### Resumo das mudanças documentadas
- 3 endpoints novos documentados
- 1 model atualizado
- 2 dependências adicionadas
```

### Passo 2C — Ação: #NNN concluído

Fluxo completo:

1. Extrair o número do work item (NNN) e o comentário opcional
2. Carregar credenciais do `scripts/chamados/.env`
3. Buscar detalhes do work item via MCP azure-devops (tool `get_work_item` com id=NNN) para obter título e tipo
4. Fechar o work item no Azure DevOps:
```bash
az boards work-item update \
  --org "$AZURE_DEVOPS_ORG" \
  --id NNN \
  --state "Closed" \
  --discussion "Concluído. Documentação do code-base atualizada."
```
5. Executar o fluxo de "Incorporar" (Passo 2B) automaticamente
6. Mostrar:

```
## #NNN Concluído

### Work Item
- **ID:** #NNN
- **Título:** [título do work item]
- **Tipo:** [Feature/User Story/Bug]
- **Estado:** Closed ✅

### Documentação atualizada
- docs/CODE-BASE.md — seções: [lista]
- CLAUDE.md — [se atualizado]

### Mudanças incorporadas
- [resumo das mudanças documentadas]
```

### Passo 2D — Ação: Status

Mostrar resumo rápido sem detalhes:
```
## Status do Codebase

**Último review:** [commit] ([data]) — [N dias atrás]
**Commits pendentes:** [N]
**Arquivos alterados:** [N]
**Categorias impactadas:** Endpoints (3), Models (1), Deps (2)

Use `/codebase-review` para ver detalhes.
```

## Regras

1. NUNCA reescrever CODE-BASE.md inteiro — apenas seções impactadas
2. SEMPRE preservar o marcador `<!-- last-review: HASH -->` no final do CODE-BASE.md
3. Se CODE-BASE.md não existe, orientar a rodar `/code-base` primeiro
4. Credenciais do .env, nunca hardcoded
5. NUNCA expor PAT no output
6. Usar MCPs se disponíveis (Serena, Context7) para análise mais precisa
7. Português (pt-BR)
8. NUNCA mencionar Claude/Anthropic/IA nos documentos

## Exemplos

**Review manual:**
```
/codebase-review
/codebase-review review
```

**Fechar work item e atualizar docs:**
```
/codebase-review #3588 concluido
/codebase-review #3588 concluído - implementação do módulo de relatórios
```

**Incorporar mudanças pendentes:**
```
/codebase-review incorporar
/codebase-review sync
```

**Ver status rápido:**
```
/codebase-review status
```

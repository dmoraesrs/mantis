---
name: bmad-devops
description: "Cria hierarquia de work items no Azure DevOps a partir do PRP/BMAD (Epic → Features → User Stories → Bugs)"
user_invocable: true
---

# Agente BMAD DevOps

Especialista em materializar PRPs e planos BMAD em work items rastreáveis no Azure DevOps.

## Input do Usuário

$ARGUMENTS

## Instruções

### Passo 0 — Carregar credenciais

Ler `scripts/chamados/.env` para obter:
- AZURE_DEVOPS_ORG (ex: https://dev.azure.com/org)
- AZURE_DEVOPS_PROJECT
- AZURE_DEVOPS_PAT

### Passo 1 — Identificar origem

O input pode ser:
- Um PRP completo (output de `/mesa-redonda`)
- Uma descrição livre de funcionalidade
- Uma referência a um arquivo PRP existente (ex: `docs/prp-xxx.md`)

Se for descrição livre, estruturar internamente como mini-PRP antes de prosseguir.

### Passo 2 — Mapear hierarquia

Extrair do PRP/descrição e montar a árvore:

```
Epic: [objetivo principal / título do projeto]
├── Feature: [capacidade 1]
│   ├── User Story: Como [persona], quero [ação] para [benefício]
│   ├── User Story: ...
│   └── Bug: [se identificado risco/defeito conhecido]
├── Feature: [capacidade 2]
│   ├── User Story: ...
│   └── User Story: ...
└── Feature: [capacidade N]
    └── User Story: ...
```

Cada item deve ter:
- **Título** claro e conciso
- **Descrição** em HTML estruturado com `<h3>` para seções
- **Critérios de Aceite** como checklist HTML (`<ul><li>`)
- **Tags** relevantes (ex: "bmad", "toolkit", nome-do-projeto)
- **Area Path** seguindo o padrão do projeto (ex: `Business`)

### Passo 3 — Preview para aprovação

Mostrar ao usuário a árvore completa formatada assim:

```
## Preview — Work Items Azure DevOps

### 👑 Epic: [título]
> [descrição resumida]

  ### 🏆 Feature 1: [título]
  > [descrição resumida]
  > Critérios: [lista resumida]

    📋 US 1.1: [título da user story]
    📋 US 1.2: [título]

  ### 🏆 Feature 2: [título]
    📋 US 2.1: [título]
    📋 US 2.2: [título]
    🐛 Bug 2.1: [título] (se aplicável)

**Total:** X Epic, Y Features, Z User Stories, W Bugs
```

Perguntar: "Confirma a criação? (sim / ajustar)"

Se o usuário pedir ajuste, modificar e mostrar preview novamente.

### Passo 4 — Criar no Azure DevOps

Criar na ordem (parent primeiro, depois children):

1. **Epic** via:
```bash
az boards work-item create \
  --org "$AZURE_DEVOPS_ORG" \
  --project "$AZURE_DEVOPS_PROJECT" \
  --type "Epic" \
  --title "[título]" \
  --description "[HTML]" \
  --fields "System.Tags=bmad" "System.AreaPath=$AZURE_DEVOPS_PROJECT\\Business"
```

2. **Features** vinculadas ao Epic:
```bash
az boards work-item create \
  --org "$AZURE_DEVOPS_ORG" \
  --project "$AZURE_DEVOPS_PROJECT" \
  --type "Feature" \
  --title "[título]" \
  --description "[HTML com critérios de aceite]" \
  --fields "System.Tags=bmad" "System.AreaPath=$AZURE_DEVOPS_PROJECT\\Business"

# Vincular ao Epic parent:
az boards work-item relation add \
  --org "$AZURE_DEVOPS_ORG" \
  --id [FEATURE_ID] \
  --relation-type "parent" \
  --target-id [EPIC_ID]
```

3. **User Stories** vinculadas à Feature (mesmo padrão com --type "User Story")

4. **Bugs** se aplicável (--type "Bug")

### Passo 5 — Report

Após criação, mostrar:
```
## ✅ Work Items Criados

👑 Epic #[ID]: [título] — [link]
  🏆 Feature #[ID]: [título] — [link]
    📋 US #[ID]: [título] — [link]
    📋 US #[ID]: [título] — [link]
  🏆 Feature #[ID]: [título] — [link]
    📋 US #[ID]: [título] — [link]

**Total criado:** X itens
**Link do board:** [URL do board]
```

## Formato da Descrição HTML

Para cada work item, usar este template HTML:

**Epic:**
```html
<h3>Objetivo</h3>
<p>[objetivo do epic]</p>
<h3>Contexto</h3>
<p>[contexto/motivação]</p>
<h3>Escopo</h3>
<ul><li>[item incluído]</li></ul>
<h3>Fora do Escopo</h3>
<ul><li>[item excluído]</li></ul>
```

**Feature:**
```html
<h3>Descrição</h3>
<p>[o que a feature entrega]</p>
<h3>Critérios de Aceite</h3>
<ul>
<li>[ ] [critério 1]</li>
<li>[ ] [critério 2]</li>
</ul>
<h3>Dependências</h3>
<ul><li>[se houver]</li></ul>
```

**User Story:**
```html
<h3>User Story</h3>
<p>Como [persona], quero [ação] para [benefício]</p>
<h3>Critérios de Aceite</h3>
<ul>
<li>[ ] [critério 1]</li>
<li>[ ] [critério 2]</li>
</ul>
<h3>Notas Técnicas</h3>
<p>[detalhes de implementação se relevante]</p>
```

## Suporte a criação parcial

Se o usuário pedir:
- "só epic e features" → criar apenas Epic + Features, sem User Stories
- "só o épico" → criar apenas o Epic
- "tudo" ou sem especificação → criar hierarquia completa

## Regras

1. SEMPRE mostrar preview antes de criar
2. NUNCA criar sem confirmação do usuário
3. Credenciais SEMPRE do .env, nunca hardcoded
4. NUNCA expor o PAT no output
5. Descrições SEMPRE em HTML estruturado
6. Critérios de aceite OBRIGATÓRIOS em Features e User Stories
7. Vínculo hierárquico (parent) OBRIGATÓRIO
8. Tags "bmad" em todos os itens para rastreabilidade
9. Português (pt-BR) em todo conteúdo
10. NUNCA mencionar Claude/Anthropic/IA no conteúdo dos work items

## Exemplos

**Input:** `/bmad-devops Criar sistema de notificações push para o app mobile`

**Input com PRP:** `/bmad-devops` (cola o PRP da mesa-redonda)

**Input parcial:** `/bmad-devops só epic e features para o módulo de relatórios`

# Root Cause Analysis (RCA) Report Template

---

# Root Cause Analysis: [Titulo do Incidente/Problema]

## Metadata

| Campo | Valor |
|-------|-------|
| **ID do RCA** | RCA-YYYYMMDD-XXX |
| **Incidente Relacionado** | INC-YYYYMMDD-XXX |
| **Problema Relacionado** | PRB-YYYYMMDD-XXX |
| **Data do Incidente** | YYYY-MM-DD |
| **Data do RCA** | YYYY-MM-DD |
| **Autor** | [Nome] |
| **Revisores** | [Nomes] |
| **Status** | Draft / Em Revisao / Aprovado / Fechado |

## Sumario Executivo

[Paragrafo de 3-5 linhas resumindo: o que aconteceu, qual foi a causa raiz, qual foi o impacto, e quais sao as principais acoes preventivas]

## Contexto do Incidente

### Descricao do Incidente

[Descricao detalhada do que aconteceu]

### Timeline Resumido

| Fase | Inicio | Fim | Duracao |
|------|--------|-----|---------|
| Incidente | YYYY-MM-DD HH:MM | YYYY-MM-DD HH:MM | Xh Ym |
| Deteccao | YYYY-MM-DD HH:MM | - | TTD: Xm |
| Mitigacao | YYYY-MM-DD HH:MM | YYYY-MM-DD HH:MM | TTM: Xm |
| Resolucao | YYYY-MM-DD HH:MM | YYYY-MM-DD HH:MM | TTR: Xm |

### Impacto

| Metrica | Valor |
|---------|-------|
| Duracao total | X horas |
| Usuarios afetados | X usuarios |
| Transacoes perdidas | X transacoes |
| Revenue impactado | $X |
| SLO breach | X% do error budget |

## Metodologia de Analise

### Metodo Utilizado

- [x] 5 Whys (5 Porques)
- [ ] Fishbone Diagram (Ishikawa)
- [ ] Fault Tree Analysis
- [ ] Timeline Analysis
- [ ] Outro: [especificar]

### Participantes da Analise

| Nome | Papel | Contribuicao |
|------|-------|--------------|
| [Nome] | Facilitador RCA | Coordenacao |
| [Nome] | SME - [area] | Conhecimento tecnico |
| [Nome] | SME - [area] | Conhecimento tecnico |

### Fontes de Dados

- [ ] Logs de aplicacao
- [ ] Metricas de monitoramento
- [ ] Traces distribuidos
- [ ] Entrevistas com equipe
- [ ] Registros de mudanca
- [ ] Codigo fonte
- [ ] Outro: [especificar]

## Analise de Causa Raiz

### 5 Whys (5 Porques)

#### Problema: [Descricao do problema]

**Why 1:** Por que [o problema aconteceu]?
- Resposta: [resposta]
- Evidencia: [evidencia que suporta]

**Why 2:** Por que [resposta do why 1]?
- Resposta: [resposta]
- Evidencia: [evidencia que suporta]

**Why 3:** Por que [resposta do why 2]?
- Resposta: [resposta]
- Evidencia: [evidencia que suporta]

**Why 4:** Por que [resposta do why 3]?
- Resposta: [resposta]
- Evidencia: [evidencia que suporta]

**Why 5:** Por que [resposta do why 4]?
- Resposta: [resposta]
- Evidencia: [evidencia que suporta]

### Causa Raiz Identificada

> **CAUSA RAIZ:** [Descricao clara e concisa da causa raiz]

### Diagrama de Causa e Efeito (se aplicavel)

```
                                    +------------------+
                                    |    INCIDENTE     |
                                    | [descricao]      |
                                    +--------+---------+
                                             |
              +------------------------------+------------------------------+
              |                              |                              |
    +---------v---------+          +---------v---------+          +---------v---------+
    | Causa Direta 1    |          | Causa Direta 2    |          | Causa Direta 3    |
    | [descricao]       |          | [descricao]       |          | [descricao]       |
    +---------+---------+          +---------+---------+          +---------+---------+
              |                              |                              |
    +---------v---------+          +---------v---------+          +---------v---------+
    | Causa Raiz 1      |          | Causa Raiz 2      |          | Causa Raiz 3      |
    | [descricao]       |          | [descricao]       |          | [descricao]       |
    +-------------------+          +-------------------+          +-------------------+
```

## Fatores Contribuintes

### Fatores Tecnicos

| Fator | Descricao | Contribuicao |
|-------|-----------|--------------|
| [Fator 1] | [descricao] | [como contribuiu] |
| [Fator 2] | [descricao] | [como contribuiu] |

### Fatores de Processo

| Fator | Descricao | Contribuicao |
|-------|-----------|--------------|
| [Fator 1] | [descricao] | [como contribuiu] |
| [Fator 2] | [descricao] | [como contribuiu] |

### Fatores Humanos

| Fator | Descricao | Contribuicao |
|-------|-----------|--------------|
| [Fator 1] | [descricao] | [como contribuiu] |
| [Fator 2] | [descricao] | [como contribuiu] |

### Fatores Organizacionais

| Fator | Descricao | Contribuicao |
|-------|-----------|--------------|
| [Fator 1] | [descricao] | [como contribuiu] |
| [Fator 2] | [descricao] | [como contribuiu] |

## O Que Deu Errado vs O Que Deu Certo

### O Que Deu Errado

1. **[Item 1]:** [descricao]
2. **[Item 2]:** [descricao]
3. **[Item 3]:** [descricao]

### O Que Deu Certo

1. **[Item 1]:** [descricao]
2. **[Item 2]:** [descricao]
3. **[Item 3]:** [descricao]

### O Que Foi Sorte

1. **[Item 1]:** [descricao - fatores que ajudaram mas nao eram planejados]

## Acoes Corretivas e Preventivas

### Acoes de Curto Prazo (< 1 semana)

| # | Acao | Tipo | Owner | Deadline | Ticket | Status |
|---|------|------|-------|----------|--------|--------|
| 1 | [acao] | Fix/Melhoria | [nome] | YYYY-MM-DD | [link] | Pendente |
| 2 | [acao] | Fix/Melhoria | [nome] | YYYY-MM-DD | [link] | Pendente |

### Acoes de Medio Prazo (1-4 semanas)

| # | Acao | Tipo | Owner | Deadline | Ticket | Status |
|---|------|------|-------|----------|--------|--------|
| 1 | [acao] | Fix/Melhoria | [nome] | YYYY-MM-DD | [link] | Pendente |
| 2 | [acao] | Fix/Melhoria | [nome] | YYYY-MM-DD | [link] | Pendente |

### Acoes de Longo Prazo (> 1 mes)

| # | Acao | Tipo | Owner | Deadline | Ticket | Status |
|---|------|------|-------|----------|--------|--------|
| 1 | [acao] | Arquitetura/Processo | [nome] | YYYY-MM-DD | [link] | Pendente |
| 2 | [acao] | Arquitetura/Processo | [nome] | YYYY-MM-DD | [link] | Pendente |

### Matriz de Priorizacao

| Acao | Impacto | Esforco | Prioridade |
|------|---------|---------|------------|
| [acao 1] | Alto/Medio/Baixo | Alto/Medio/Baixo | P1/P2/P3 |
| [acao 2] | Alto/Medio/Baixo | Alto/Medio/Baixo | P1/P2/P3 |

## Melhorias de Deteccao

### Gaps Identificados

| Gap | Descricao | Como Afetou |
|-----|-----------|-------------|
| [gap 1] | [descricao] | [impacto na deteccao] |
| [gap 2] | [descricao] | [impacto na deteccao] |

### Novos Alertas/Monitores

| Alerta | Descricao | Threshold | Owner | Status |
|--------|-----------|-----------|-------|--------|
| [alerta 1] | [descricao] | [threshold] | [nome] | Pendente |
| [alerta 2] | [descricao] | [threshold] | [nome] | Pendente |

## Melhorias de Resposta

### Gaps no Processo de Resposta

| Gap | Descricao | Recomendacao |
|-----|-----------|--------------|
| [gap 1] | [descricao] | [recomendacao] |
| [gap 2] | [descricao] | [recomendacao] |

### Atualizacoes de Runbook

| Runbook | Mudanca Necessaria | Owner | Status |
|---------|-------------------|-------|--------|
| [runbook 1] | [mudanca] | [nome] | Pendente |
| [runbook 2] | [mudanca] | [nome] | Pendente |

## Licoes Aprendidas

### Licao 1: [Titulo]
**Contexto:** [contexto]
**Licao:** [o que aprendemos]
**Aplicacao:** [como aplicar no futuro]

### Licao 2: [Titulo]
**Contexto:** [contexto]
**Licao:** [o que aprendemos]
**Aplicacao:** [como aplicar no futuro]

### Licao 3: [Titulo]
**Contexto:** [contexto]
**Licao:** [o que aprendemos]
**Aplicacao:** [como aplicar no futuro]

## Compartilhamento de Conhecimento

### Apresentacao do RCA

- [ ] Apresentado para equipe: YYYY-MM-DD
- [ ] Apresentado para organizacao: YYYY-MM-DD
- [ ] Documentado em wiki: [link]

### Treinamentos Necessarios

| Treinamento | Audiencia | Responsavel | Data |
|-------------|-----------|-------------|------|
| [treinamento 1] | [equipe] | [nome] | YYYY-MM-DD |

## Follow-up

### Reuniao de Follow-up

- **Data:** YYYY-MM-DD
- **Objetivo:** Revisar status das acoes
- **Participantes:** [nomes]

### Metricas de Sucesso

| Metrica | Valor Atual | Meta | Prazo |
|---------|-------------|------|-------|
| [metrica 1] | [valor] | [meta] | YYYY-MM-DD |
| [metrica 2] | [valor] | [meta] | YYYY-MM-DD |

## Anexos

### Timeline Detalhado

[Link para timeline completo do incidente]

### Logs e Evidencias

[Links para logs, screenshots, dashboards]

### Diagrama de Arquitetura

[Diagrama mostrando onde o problema ocorreu]

## Referencias

- Incident Report: [link]
- Problem Report: [link]
- PRs/Commits relacionados: [links]
- Documentacao relacionada: [links]

---

## Aprovacao do RCA

| Papel | Nome | Data | Status |
|-------|------|------|--------|
| Autor | [nome] | YYYY-MM-DD | Completo |
| Revisor Tecnico | [nome] | YYYY-MM-DD | Pendente |
| Revisor de Processo | [nome] | YYYY-MM-DD | Pendente |
| Aprovador Final | [nome] | YYYY-MM-DD | Pendente |

### Criterios de Fechamento

- [ ] Todas as acoes de curto prazo completadas
- [ ] Acoes de medio/longo prazo com tickets criados
- [ ] RCA apresentado para equipe
- [ ] Documentacao atualizada
- [ ] Monitoramento implementado

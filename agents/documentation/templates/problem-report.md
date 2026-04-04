# Problem Report Template

---

# Problem Report: [Titulo Descritivo do Problema]

## Metadata

| Campo | Valor |
|-------|-------|
| **ID do Problema** | PRB-YYYYMMDD-XXX |
| **Data de Identificacao** | YYYY-MM-DD |
| **Reportado por** | [Nome] |
| **Severidade** | Critica / Alta / Media / Baixa |
| **Status** | Aberto / Em Analise / Resolvido / Fechado |
| **Categoria** | Bug / Performance / Seguranca / Configuracao / Outro |
| **Autor do Report** | [Nome] |
| **Data do Report** | YYYY-MM-DD |

## Sumario

[Resumo de 2-3 frases descrevendo o problema, onde ocorre, e qual o impacto]

## Descricao do Problema

### O que esta acontecendo?

[Descricao detalhada do problema observado]

### Comportamento Esperado

[O que deveria acontecer]

### Comportamento Atual

[O que esta acontecendo de fato]

### Como Reproduzir

1. [Passo 1]
2. [Passo 2]
3. [Passo 3]
4. Resultado: [o que acontece]

## Contexto

### Quando foi Identificado

- **Data/Hora:** YYYY-MM-DD HH:MM (UTC)
- **Por quem:** [Nome/Sistema]
- **Como:** [Alerta/Usuario/Teste/Outro]

### Onde Ocorre

- **Ambiente:** [Producao/Staging/Dev]
- **Servico/Aplicacao:** [nome]
- **Componente:** [componente especifico]
- **Regiao:** [se aplicavel]

### Frequencia

- [ ] Sempre (100%)
- [ ] Frequente (>50%)
- [ ] Intermitente (10-50%)
- [ ] Raro (<10%)
- [ ] Unica ocorrencia

### Desde Quando

- **Primeira ocorrencia:** YYYY-MM-DD
- **Correlacao com mudanca:** [Sim/Nao - detalhes]

## Impacto

### Nivel de Impacto

| Aspecto | Impacto | Detalhes |
|---------|---------|----------|
| Usuarios | [Alto/Medio/Baixo/Nenhum] | [detalhes] |
| Performance | [Alto/Medio/Baixo/Nenhum] | [detalhes] |
| Seguranca | [Alto/Medio/Baixo/Nenhum] | [detalhes] |
| Financeiro | [Alto/Medio/Baixo/Nenhum] | [detalhes] |
| Operacional | [Alto/Medio/Baixo/Nenhum] | [detalhes] |

### Usuarios/Sistemas Afetados

- [Usuario/Sistema 1]
- [Usuario/Sistema 2]

### Workaround Disponivel?

- [ ] Sim - [descrever workaround]
- [ ] Nao

## Investigacao

### Agente Responsavel

| Agente | Responsabilidade |
|--------|------------------|
| [nome do agente] | Investigacao principal |
| [nome do agente] | Suporte |

### Evidencias Coletadas

#### Logs

```
[logs relevantes]
```

#### Metricas

| Metrica | Valor Normal | Valor Observado |
|---------|--------------|-----------------|
| [metrica 1] | [valor] | [valor] |
| [metrica 2] | [valor] | [valor] |

#### Screenshots/Graficos

[inserir ou linkar screenshots]

### Analise Inicial

[Descricao da analise inicial realizada]

### Hipoteses

1. **Hipotese 1:** [descricao]
   - Evidencia a favor: [evidencia]
   - Evidencia contra: [evidencia]
   - Status: [Confirmada/Refutada/Em investigacao]

2. **Hipotese 2:** [descricao]
   - Evidencia a favor: [evidencia]
   - Evidencia contra: [evidencia]
   - Status: [Confirmada/Refutada/Em investigacao]

## Causa Raiz

### Descricao da Causa

[Descricao detalhada da causa raiz identificada]

### Categoria da Causa

- [ ] Codigo (bug)
- [ ] Configuracao
- [ ] Infraestrutura
- [ ] Dependencia externa
- [ ] Capacidade
- [ ] Processo
- [ ] Documentacao insuficiente
- [ ] Outro: [especificar]

### Componente Afetado

- **Sistema:** [nome]
- **Modulo/Arquivo:** [referencia]
- **Linha de codigo:** [se aplicavel]

## Solucao

### Solucao Implementada

[Descricao da solucao aplicada]

### Tipo de Solucao

- [ ] Fix definitivo
- [ ] Workaround temporario
- [ ] Rollback
- [ ] Configuracao
- [ ] Outro: [especificar]

### Acoes Realizadas

| # | Acao | Responsavel | Data | Status |
|---|------|-------------|------|--------|
| 1 | [acao] | [nome] | YYYY-MM-DD | Completo |
| 2 | [acao] | [nome] | YYYY-MM-DD | Completo |

### Codigo/Configuracao Alterada

```
[diff ou descricao da mudanca]
```

### Referencias

- PR: [link]
- Commit: [hash]
- Ticket: [link]

## Validacao

### Testes Realizados

| Teste | Resultado | Evidencia |
|-------|-----------|-----------|
| [teste 1] | Pass/Fail | [link/screenshot] |
| [teste 2] | Pass/Fail | [link/screenshot] |

### Metricas Pos-Solucao

| Metrica | Antes | Depois | Esperado |
|---------|-------|--------|----------|
| [metrica 1] | [valor] | [valor] | [valor] |
| [metrica 2] | [valor] | [valor] | [valor] |

### Validado por

- [Nome] em YYYY-MM-DD

## Prevencao

### Acoes Preventivas

| # | Acao | Owner | Prioridade | Deadline | Status |
|---|------|-------|------------|----------|--------|
| 1 | [acao preventiva] | [nome] | P1/P2/P3 | YYYY-MM-DD | Pendente |
| 2 | [acao preventiva] | [nome] | P1/P2/P3 | YYYY-MM-DD | Pendente |

### Monitoramento Adicional

- [ ] Novo alerta criado: [descricao]
- [ ] Dashboard atualizado: [link]
- [ ] Metrica adicionada: [nome]

### Documentacao Atualizada

- [ ] Runbook: [link]
- [ ] Wiki: [link]
- [ ] README: [link]

## Timeline do Problema

| Data | Evento |
|------|--------|
| YYYY-MM-DD | Problema identificado |
| YYYY-MM-DD | Investigacao iniciada |
| YYYY-MM-DD | Causa raiz identificada |
| YYYY-MM-DD | Solucao implementada |
| YYYY-MM-DD | Validacao completa |
| YYYY-MM-DD | Problema fechado |

## Anexos

- [Link para dashboard]
- [Link para logs completos]
- [Outros anexos]

---

## Aprovacao

| Papel | Nome | Data | Assinatura |
|-------|------|------|------------|
| Autor | [nome] | YYYY-MM-DD | [x] |
| Revisor | [nome] | YYYY-MM-DD | [ ] |
| Owner do Servico | [nome] | YYYY-MM-DD | [ ] |

# Incident Report Template

---

# Incident Report: [Titulo Descritivo do Incidente]

## Metadata

| Campo | Valor |
|-------|-------|
| **ID do Incidente** | INC-YYYYMMDD-XXX |
| **Data do Incidente** | YYYY-MM-DD |
| **Hora de Inicio (UTC)** | HH:MM |
| **Hora de Resolucao (UTC)** | HH:MM |
| **Duracao Total** | Xh Ym |
| **Severidade** | SEV1 / SEV2 / SEV3 / SEV4 |
| **Status** | Resolvido / Em Monitoramento / Em Investigacao |
| **Autor do Report** | [Nome] |
| **Data do Report** | YYYY-MM-DD |

## Sumario Executivo

[Resumo de 2-3 frases descrevendo o que aconteceu, qual foi o impacto, e como foi resolvido]

## Impacto

### Metricas de Impacto

| Metrica | Valor |
|---------|-------|
| Duracao do impacto | X minutos/horas |
| Usuarios afetados | X usuarios / X% da base |
| Requests com erro | X requests |
| Taxa de erro | X% |
| Revenue impactado | $X (se aplicavel) |
| SLA breach | Sim/Nao |

### Servicos Afetados

| Servico | Tipo de Impacto | Severidade |
|---------|-----------------|------------|
| [Servico 1] | [Indisponivel/Degradado] | [Alta/Media/Baixa] |
| [Servico 2] | [Indisponivel/Degradado] | [Alta/Media/Baixa] |

### Regioes/Ambientes Afetados

- [ ] Producao
- [ ] Staging
- [ ] Regiao: [especificar]

## Timeline do Incidente

| Data/Hora (UTC) | Evento | Responsavel |
|-----------------|--------|-------------|
| YYYY-MM-DD HH:MM | **INICIO:** [Descricao do inicio do problema] | Sistema/Alerta |
| YYYY-MM-DD HH:MM | Alerta disparado: [nome do alerta] | Sistema |
| YYYY-MM-DD HH:MM | Investigacao iniciada | [Nome] |
| YYYY-MM-DD HH:MM | Causa identificada: [resumo] | [Nome] |
| YYYY-MM-DD HH:MM | Acao de mitigacao aplicada: [acao] | [Nome] |
| YYYY-MM-DD HH:MM | **RESOLUCAO:** Servico restaurado | [Nome] |
| YYYY-MM-DD HH:MM | Incidente encerrado | [Nome] |

## Deteccao

### Como foi detectado?

- [ ] Alerta automatico
- [ ] Report de usuario
- [ ] Monitoramento proativo
- [ ] Descoberta acidental
- [ ] Outro: [especificar]

### Alerta que disparou (se aplicavel)

- **Nome do Alerta:** [nome]
- **Threshold:** [valor]
- **Valor observado:** [valor]
- **Link para dashboard:** [link]

### Tempo para Deteccao (TTD)

Tempo entre o inicio do problema e a deteccao: **X minutos**

## Causa Raiz

### Descricao da Causa Raiz

[Descricao clara e detalhada do que causou o incidente]

### Categoria da Causa

- [ ] Mudanca de codigo
- [ ] Mudanca de configuracao
- [ ] Mudanca de infraestrutura
- [ ] Dependencia externa
- [ ] Capacidade/Escala
- [ ] Bug de software
- [ ] Erro humano
- [ ] Falha de hardware
- [ ] Ataque/Seguranca
- [ ] Desconhecido
- [ ] Outro: [especificar]

### Componente que Falhou

- **Sistema:** [nome do sistema]
- **Componente:** [componente especifico]
- **Arquivo/Codigo:** [referencia, se aplicavel]

## Resposta ao Incidente

### Equipe de Resposta

| Nome | Role | Responsabilidade |
|------|------|------------------|
| [Nome] | Incident Commander | Coordenacao geral |
| [Nome] | Tech Lead | Investigacao tecnica |
| [Nome] | Comunicacao | Updates para stakeholders |

### Acoes de Mitigacao

| # | Acao | Responsavel | Status |
|---|------|-------------|--------|
| 1 | [Acao tomada] | [Nome] | Completo |
| 2 | [Acao tomada] | [Nome] | Completo |

### Acoes de Resolucao

| # | Acao | Responsavel | Status |
|---|------|-------------|--------|
| 1 | [Acao tomada] | [Nome] | Completo |
| 2 | [Acao tomada] | [Nome] | Completo |

## Comunicacao

### Comunicacao Interna

| Hora | Canal | Mensagem |
|------|-------|----------|
| HH:MM | Slack #incidents | [resumo da mensagem] |
| HH:MM | Email | [resumo da mensagem] |

### Comunicacao Externa (se aplicavel)

| Hora | Canal | Mensagem |
|------|-------|----------|
| HH:MM | Status Page | [resumo da mensagem] |
| HH:MM | Email para clientes | [resumo da mensagem] |

## Metricas de Resposta

| Metrica | Valor | Target | Status |
|---------|-------|--------|--------|
| Time to Detect (TTD) | X min | Y min | OK/BREACH |
| Time to Mitigate (TTM) | X min | Y min | OK/BREACH |
| Time to Resolve (TTR) | X min | Y min | OK/BREACH |

## Acoes de Follow-up

### Acoes Preventivas

| # | Acao | Owner | Prioridade | Deadline | Status |
|---|------|-------|------------|----------|--------|
| 1 | [Acao para prevenir recorrencia] | [Nome] | P1/P2/P3 | YYYY-MM-DD | Pendente |
| 2 | [Acao para prevenir recorrencia] | [Nome] | P1/P2/P3 | YYYY-MM-DD | Pendente |

### Melhorias de Deteccao

| # | Acao | Owner | Deadline | Status |
|---|------|-------|----------|--------|
| 1 | [Novo alerta/dashboard] | [Nome] | YYYY-MM-DD | Pendente |

### Melhorias de Processo

| # | Acao | Owner | Deadline | Status |
|---|------|-------|----------|--------|
| 1 | [Melhoria de runbook/processo] | [Nome] | YYYY-MM-DD | Pendente |

## Licoes Aprendidas

### O que funcionou bem?

- [Ponto positivo 1]
- [Ponto positivo 2]

### O que pode melhorar?

- [Area de melhoria 1]
- [Area de melhoria 2]

### O que foi sorte?

- [Fator que ajudou mas nao era planejado]

## Anexos

### Dashboards e Graficos

- [Link para dashboard 1]
- [Link para dashboard 2]

### Logs Relevantes

```
[Snippets de log relevantes]
```

### Screenshots

[Inserir screenshots relevantes]

## Referencias

- **Runbook utilizado:** [link]
- **RCA detalhado:** [link, se aplicavel]
- **Ticket relacionado:** [link]
- **PR/Commit de fix:** [link]

---

## Revisao do Report

| Revisor | Data | Status |
|---------|------|--------|
| [Nome] | YYYY-MM-DD | Aprovado/Pendente |
| [Nome] | YYYY-MM-DD | Aprovado/Pendente |

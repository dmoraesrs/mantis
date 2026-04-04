# Guia Completo - Monitoramento de SQL Server no Grafana

**Ambiente:** Grafana v12.2.1 | EKS <CLUSTER_NAME> | us-east-1 | namespace observability

---

## Indice

1. [PARTE 1: Preparacao do SQL Server](#parte-1-preparacao-do-sql-server)
2. [PARTE 2: Configuracao do Data Source no Grafana](#parte-2-configuracao-do-data-source-no-grafana)
3. [PARTE 3: Importacao do Dashboard](#parte-3-importacao-do-dashboard)
4. [PARTE 4: Configuracao do Alerta de Query Lenta](#parte-4-configuracao-do-alerta-de-query-lenta)
5. [PARTE 5: Notification Policy e Template](#parte-5-notification-policy-e-template)
6. [PARTE 6: Verificacao e Validacao](#parte-6-verificacao-e-validacao)
7. [Referencia de Queries e Thresholds](#referencia-de-queries-e-thresholds)

---

## PARTE 1: Preparacao do SQL Server

### 1.1 Executar o Script de Criacao de Usuario

**Arquivo:** `01-setup-monitoring-user.sql`

Conecte no SQL Server de PRD via SSMS ou Azure Data Studio como **sysadmin** e execute o script completo.

```
Abrir SSMS > Conectar no SQL Server > New Query > Colar conteudo do arquivo > Execute
```

**O que o script faz:**

| Etapa | Acao | Permissao |
|-------|------|-----------|
| 1 | Cria login `grafana_monitor` | Login no servidor |
| 2 | Concede `VIEW SERVER STATE` | Acesso a DMVs de performance |
| 3 | Concede `VIEW ANY DEFINITION` | Metadados de objetos |
| 4 | Concede `CONNECT ANY DATABASE` | Conexao em todas as databases |
| 5 | Cria usuario em cada database | `VIEW DATABASE STATE` por database |

**IMPORTANTE:** Altere a senha no script antes de executar! A senha padrao e `<ALTERAR_SENHA_FORTE_AQUI>`.

### 1.2 Verificar Permissoes

Apos executar, valide conectando como `grafana_monitor`:

```sql
-- Testar VIEW SERVER STATE
SELECT TOP 1 * FROM sys.dm_exec_query_stats;

-- Testar sys.dm_os_sys_info
SELECT sqlserver_start_time FROM sys.dm_os_sys_info;

-- Testar sys.dm_os_ring_buffers
SELECT TOP 1 * FROM sys.dm_os_ring_buffers WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR';

-- Testar sys.master_files
SELECT TOP 1 * FROM sys.master_files;
```

Se todas retornarem dados, as permissoes estao corretas.

---

## PARTE 2: Configuracao do Data Source no Grafana

### 2.1 Instalar o Plugin (se necessario)

O plugin Microsoft SQL Server (mssql) geralmente ja vem pre-instalado no Grafana 12.x. Verifique em:

```
Grafana > Administration > Plugins > Buscar "Microsoft SQL Server"
```

Se nao estiver instalado, no pod do Grafana:

```bash
grafana-cli plugins install grafana-mssql-datasource
```

Ou via Helm values (se usando Helm chart):

```yaml
plugins:
  - grafana-mssql-datasource
```

### 2.2 Criar o Data Source

1. Acesse o Grafana: **Menu lateral > Connections > Data sources > Add data source**
2. Busque por **Microsoft SQL Server**
3. Configure:

| Campo | Valor |
|-------|-------|
| **Name** | `SQL Server` |
| **Host** | `<IP_OU_HOSTNAME_DO_SQL_SERVER>:<PORTA>` |
| **Database** | `master` |
| **Authentication** | SQL Server Authentication |
| **User** | `grafana_monitor` |
| **Password** | `<ALTERAR_SENHA_FORTE_AQUI>` (a que voce definiu) |
| **Encrypt** | `false` (ou `true` se usar TLS/SSL) |
| **Max open connections** | `10` |
| **Max idle connections** | `5` |
| **Max connection lifetime** | `600` (10 min) |

**Configuracoes adicionais recomendadas:**

| Campo | Valor | Motivo |
|-------|-------|--------|
| Min time interval | `30s` | Evita queries excessivas |
| Connection timeout | `30` | Timeout de conexao em segundos |

4. Clique em **Save & test**
5. Deve aparecer: **"Data source is working"**

### 2.3 Via API (Alternativa)

Se preferir criar via API do Grafana:

```bash
curl -X POST \
  'http://GRAFANA_URL/api/datasources' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer SEU_API_KEY' \
  -d '{
    "name": "SQL Server",
    "type": "mssql",
    "url": "HOST:PORTA",
    "database": "master",
    "user": "grafana_monitor",
    "secureJsonData": {
      "password": "<ALTERAR_SENHA_FORTE_AQUI>"
    },
    "jsonData": {
      "maxOpenConns": 10,
      "maxIdleConns": 5,
      "connMaxLifetime": 600,
      "encrypt": "false",
      "tlsSkipVerify": true
    },
    "access": "proxy",
    "isDefault": false
  }'
```

Anote o `uid` retornado na resposta - voce precisara para o alert rule.

---

## PARTE 3: Importacao do Dashboard

### 3.1 Importar via Interface

1. Acesse o Grafana: **Menu lateral > Dashboards > New > Import**
2. Clique em **Upload dashboard JSON file**
3. Selecione o arquivo `02-dashboard-sqlserver-performance.json`
4. Na tela de importacao:
   - **Name:** SQL Server Performance Monitor - PRD (ja preenchido)
   - **Folder:** Escolha ou crie a pasta desejada (ex: "SQL Server" ou "Database Monitoring")
   - **SQL Server:** Selecione o data source criado no passo anterior (`SQL Server`)
   - **Unique identifier (UID):** `sqlserver-perf` (ja preenchido)
5. Clique em **Import**

### 3.2 Importar via API (Alternativa)

```bash
# Primeiro, substitua "${DS_SQLSERVER}" pelo UID real do data source no JSON
# Depois:
curl -X POST \
  'http://GRAFANA_URL/api/dashboards/db' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer SEU_API_KEY' \
  -d '{
    "dashboard": <CONTEUDO_DO_JSON>,
    "folderId": 0,
    "overwrite": true
  }'
```

### 3.3 O que o Dashboard Contem

O dashboard possui **8 rows (secoes)** com **25 paineis**:

| Row | Secao | Paineis | Tipo |
|-----|-------|---------|------|
| 1 | Visao Geral | Uptime, Versao, Conexoes, Requests, Blocked | 5 Stats |
| 2 | Top 10 Queries Lentas | Tabela, Bar Chart, Gauge | Table + BarChart + Gauge |
| 3 | CPU e Memoria | CPU TimeSeries, Mem Total, Mem SQL, Buffer Cache, PLE | TimeSeries + Stats + Gauges |
| 4 | Wait Stats | Pie Chart Top 10, Tabela Detalhada | PieChart + Table |
| 5 | I/O Performance | Tabela por DB, Gauge Read Latency, Gauge Write Latency | Table + 2 Gauges |
| 6 | Conexoes e Sessoes | Tabela Sessoes, Stat Blocked, Blocking Chains | Table + Stat + Table |
| 7 | Database Space | Tabela Arquivos, Bar Chart Tamanho | Table + BarChart |
| 8 | Index Health | Missing Indexes, Indices Fragmentados | 2 Tables |

**Auto-refresh:** 30 segundos (configuravel no canto superior direito)

---

## PARTE 4: Configuracao do Alerta de Query Lenta

### 4.1 Criar Pasta de Alertas (se necessario)

1. Acesse: **Alerting > Alert rules > + New alert rule**
2. Ou crie a pasta primeiro: **Dashboards > New folder > Nome: "SQL Server Alerts"**

### 4.2 Criar Alert Rule via Interface

1. Acesse: **Alerting > Alert rules > + New alert rule**

2. **Section 1 - Rule name:**
   - Nome: `SQL Server - Query Lenta Critica`

3. **Section 2 - Define query and alert condition:**
   - Data source: `SQL Server`
   - Query A (SQL):
   ```sql
   SELECT MAX((qs.total_elapsed_time / qs.execution_count) / 1000) AS max_avg_elapsed_time_ms
   FROM sys.dm_exec_query_stats qs
   WHERE qs.execution_count > 0
   ```
   - Clique em **Expressions** e adicione:
     - **Threshold:** `A` is above `35000`
   - Marque esta expression como **Alert condition**

4. **Section 3 - Set evaluation behavior:**
   - Folder: `SQL Server Alerts` (ou a pasta que voce criou)
   - Evaluation group: `sql-server-alerts` (crie se necessario)
   - Evaluate every: `1m` (a cada 1 minuto)
   - Pending period: `0s` (imediato - dispara na primeira ocorrencia)

5. **Section 4 - Configure labels and notifications:**
   - Labels:
     - `severity` = `critical`
     - `team` = `dba`
     - `source` = `sql-server-alerts`

6. **Section 5 - Add annotations:**
   - Summary: `Query lenta detectada no SQL Server`
   - Description: `Uma query esta com tempo medio de execucao de {{ $value }}ms (threshold: 35000ms / 35s). Verifique o dashboard SQL Server Performance Monitor.`
   - Dashboard UID: `sqlserver-perf`
   - Panel ID: `6`

7. Clique em **Save rule and exit**

### 4.3 Criar Alert Rule via API

```bash
# Obtenha o UID do data source primeiro:
DS_UID=$(curl -s -H 'Authorization: Bearer SEU_API_KEY' \
  'http://GRAFANA_URL/api/datasources/name/SQL%20Server%20PRD' | jq -r '.uid')

# Criar a pasta de alertas (se nao existir)
FOLDER_UID=$(curl -s -X POST \
  'http://GRAFANA_URL/api/folders' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer SEU_API_KEY' \
  -d '{"uid":"sql-server-alerts","title":"SQL Server Alerts"}' | jq -r '.uid')

# Criar o alert rule
curl -X POST \
  'http://GRAFANA_URL/api/v1/provisioning/alert-rules' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer SEU_API_KEY' \
  -d '{
    "title": "SQL Server - Query Lenta Critica",
    "ruleGroup": "sql-server-alerts",
    "folderUID": "'$FOLDER_UID'",
    "noDataState": "NoData",
    "execErrState": "Error",
    "for": "0s",
    "annotations": {
      "summary": "Query lenta detectada no SQL Server",
      "description": "Uma query esta com tempo medio de execucao de {{ $value }}ms (threshold: 35000ms / 35s). Verifique o dashboard SQL Server Performance Monitor.",
      "dashboardUid": "sqlserver-perf",
      "panelId": "6"
    },
    "labels": {
      "severity": "critical",
      "team": "dba",
      "source": "sql-server-alerts"
    },
    "data": [
      {
        "refId": "A",
        "relativeTimeRange": {"from": 60, "to": 0},
        "datasourceUid": "'$DS_UID'",
        "model": {
          "editorMode": "code",
          "format": "table",
          "rawQuery": true,
          "rawSql": "SELECT MAX((qs.total_elapsed_time / qs.execution_count) / 1000) AS max_avg_elapsed_time_ms FROM sys.dm_exec_query_stats qs WHERE qs.execution_count > 0",
          "refId": "A"
        }
      },
      {
        "refId": "B",
        "relativeTimeRange": {"from": 60, "to": 0},
        "datasourceUid": "-100",
        "model": {
          "conditions": [
            {
              "evaluator": {"params": [35000], "type": "gt"},
              "operator": {"type": "and"},
              "query": {"params": ["A"]},
              "reducer": {"params": [], "type": "last"},
              "type": "query"
            }
          ],
          "datasource": {"type": "__expr__", "uid": "-100"},
          "expression": "A",
          "type": "threshold",
          "refId": "B"
        }
      }
    ]
  }'
```

---

## PARTE 5: Notification Policy e Template

### 5.1 Criar Notification Template

1. Acesse: **Alerting > Contact points > Notification templates > + Add notification template**
2. **Nome:** `sql_slow_query`
3. **Conteudo:**

```
{{ define "sql_slow_query" }}
*ALERTA: Query Lenta no SQL Server*

Tempo medio: {{ $value }}ms
Threshold: 35.000ms (35s)
Severidade: CRITICAL

Dashboard: SQL Server Performance Monitor - PRD
Link: {{ externalURL }}/d/sqlserver-perf

Acao: Verificar as Top 10 queries no dashboard e otimizar a query ofensora.

Dicas rapidas:
1. Acesse o dashboard e veja a ROW 2 (Top Queries)
2. Identifique a query com maior avg_elapsed_time_ms
3. Verifique se ha missing indexes na ROW 8
4. Verifique wait stats na ROW 4 para entender o gargalo
{{ end }}
```

4. Clique em **Save**

### 5.2 Template para WhatsApp (via WhatsApp Bridge)

Se estiver usando um bridge de notificacao (ex: WhatsApp bridge), use este template adaptado:

```
{{ define "sql_slow_query_whatsapp" }}
*ALERTA: Query Lenta no SQL Server*

Tempo medio: {{ $value }}ms
Threshold: 35.000ms (35s)
Severidade: CRITICAL

Acesse o dashboard para mais detalhes.

Acao imediata:
1. Verificar Top 10 queries
2. Checar missing indexes
3. Analisar wait stats
{{ end }}
```

**IMPORTANTE (Licao Aprendida):** Se o WhatsApp Bridge esta atras de Cloudflare, o contact point DEVE ter o header `User-Agent` configurado para evitar erro 1010.

### 5.3 Configurar Notification Policy para TODOS os Contact Points

No Grafana 12.x, para enviar alertas a TODOS os contact points, existem duas abordagens:

#### Abordagem 1: Continue Matching (Recomendada)

1. Acesse: **Alerting > Notification policies**
2. Na **root policy**, mantenha o contact point padrao (ex: email ou Slack principal)
3. Clique em **+ New child policy**
4. Configure:
   - **Matching labels:** `severity = critical`
   - **Contact point:** Selecione o segundo contact point (ex: WhatsApp)
   - **IMPORTANTE:** Marque **"Continue matching subsequent sibling nodes"** = `true`
5. Repita para cada contact point adicional
6. Clique em **Save policy**

```
Root Policy (Contact Point: Email DBA)
  |
  +-- Child Policy 1 (severity=critical) -> WhatsApp [Continue: true]
  |
  +-- Child Policy 2 (severity=critical) -> Slack [Continue: true]
  |
  +-- Child Policy 3 (severity=critical) -> PagerDuty [Continue: false]
```

#### Abordagem 2: Multiple Contact Points na Mesma Policy

A partir do Grafana 12.x, voce pode adicionar multiplos contact points na mesma policy:

1. Acesse: **Alerting > Notification policies**
2. Edite a root policy ou crie uma child policy
3. Adicione todos os contact points desejados no campo **Contact point**

### 5.4 Configurar via API

```bash
# Listar contact points existentes
curl -s -H 'Authorization: Bearer SEU_API_KEY' \
  'http://GRAFANA_URL/api/v1/provisioning/contact-points'

# Criar notification policy com continue matching
curl -X PUT \
  'http://GRAFANA_URL/api/v1/provisioning/policies' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer SEU_API_KEY' \
  -d '{
    "receiver": "email-dba",
    "group_by": ["grafana_folder", "alertname"],
    "routes": [
      {
        "receiver": "whatsapp-bridge",
        "matchers": ["severity=critical"],
        "continue": true
      },
      {
        "receiver": "slack-dba",
        "matchers": ["severity=critical"],
        "continue": true
      },
      {
        "receiver": "pagerduty",
        "matchers": ["severity=critical"],
        "continue": false
      }
    ]
  }'
```

---

## PARTE 6: Verificacao e Validacao

### 6.1 Checklist de Verificacao

Apos completar todas as etapas, valide cada item:

- [ ] **SQL Server:** Login `grafana_monitor` criado e com permissoes
- [ ] **Data Source:** `SQL Server` configurado e "Data source is working"
- [ ] **Dashboard:** Importado e mostrando dados em todas as 8 rows
- [ ] **Alert Rule:** Criado e em estado "Normal" (verde) ou "Firing" se houver query lenta
- [ ] **Notification Template:** `sql_slow_query` criado
- [ ] **Notification Policy:** Configurada com `continue: true` para todos os contact points
- [ ] **Teste de Alerta:** Disparar alerta de teste e verificar recebimento

### 6.2 Testar o Alerta

Para testar, voce pode criar uma query propositalmente lenta no SQL Server:

```sql
-- APENAS PARA TESTE - Executar e cancelar
-- Isso vai aparecer no dm_exec_query_stats e potencialmente disparar o alerta
WAITFOR DELAY '00:00:40'; -- Espera 40 segundos (acima do threshold de 35s)
```

Ou use o botao **Test** na pagina do alert rule no Grafana.

### 6.3 Paineis que Devem Mostrar Dados Imediatamente

| Painel | Deve Mostrar | Se Vazio |
|--------|-------------|----------|
| Uptime | Numero de horas | Verifique permissao em sys.dm_os_sys_info |
| Versao | Numero da versao | Query simples, deve funcionar |
| Conexoes | Numero > 0 | Pelo menos a conexao do Grafana |
| Top Queries | Tabela com queries | Pode estar vazio se server acabou de reiniciar |
| CPU | Grafico temporal | Ring buffer pode ter poucos dados se server e novo |
| Wait Stats | Pie chart colorido | Sempre deve ter dados |
| I/O | Tabela com databases | Sempre deve ter dados |
| Database Space | Tabela com arquivos | Sempre deve ter dados |
| Missing Indexes | Pode estar vazio | Normal se nao ha indices faltando |
| Fragmented Indexes | Pode estar vazio | Normal se indices sao novos |

### 6.4 Troubleshooting Comum

| Problema | Causa Provavel | Solucao |
|----------|---------------|---------|
| "Data source is not working" | Credenciais ou rede | Verificar IP/porta, firewall, login/senha |
| Paineis com "No data" | Permissao insuficiente | Re-executar script SQL como sysadmin |
| CPU TimeSeries vazio | Ring buffer sem dados | Aguardar ~1h apos restart do SQL Server |
| Index Fragmentation vazio | Query pesada em databases grandes | A query de fragmentacao roda em LIMITED mode para ser rapida, mas em databases muito grandes pode demorar |
| Alerta nao dispara | Threshold muito alto | Verificar se ha queries acima de 35000ms |
| Alerta dispara constantemente | Queries legitimamente lentas | Otimizar as queries ou aumentar threshold |

---

## Referencia de Queries e Thresholds

### Thresholds Utilizados no Dashboard

| Metrica | Verde | Amarelo | Vermelho | Unidade |
|---------|-------|---------|----------|---------|
| Avg Query Time | < 10.000 | 10.000 - 35.000 | > 35.000 | ms |
| Conexoes Ativas | < 100 | 100 - 500 | > 500 | count |
| Requests em Execucao | < 10 | 10 - 50 | > 50 | count |
| Sessoes Bloqueadas | 0 | - | >= 1 | count |
| Buffer Cache Hit Ratio | > 95 | 90 - 95 | < 90 | % |
| Page Life Expectancy | > 300 | 200 - 300 | < 200 | seconds |
| Disk Read Latency | < 20 | 20 - 50 | > 50 | ms |
| Disk Write Latency | < 20 | 20 - 50 | > 50 | ms |
| Index Fragmentation | < 10 | 10 - 30 | > 30 | % |
| CPU Usage | < 85 | - | > 85 | % |

### Nota sobre total_elapsed_time

A DMV `sys.dm_exec_query_stats` retorna `total_elapsed_time` em **microsegundos** (1 segundo = 1.000.000 microsegundos).

- Dividir por `1.000` = milissegundos
- Dividir por `1.000.000` = segundos

O threshold de alerta esta configurado em **35.000 milissegundos = 35 segundos**.

### Wait Types Excluidos

Os seguintes wait types sao excluidos das analises por serem waits de sistema (idle/background):

```
SLEEP_TASK, BROKER_TO_FLUSH, SQLTRACE_BUFFER_FLUSH,
CLR_AUTO_EVENT, CLR_MANUAL_EVENT, LAZYWRITER_SLEEP,
CHECKPOINT_QUEUE, WAITFOR, BROKER_EVENTHANDLER,
FT_IFTS_SCHEDULER_IDLE_WAIT, XE_DISPATCHER_WAIT,
XE_TIMER_EVENT, HADR_FILESTREAM_IOMGR_IOCOMPLETION,
DIRTY_PAGE_POLL, REQUEST_FOR_DEADLOCK_SEARCH,
LOGMGR_QUEUE, ONDEMAND_TASK_QUEUE, BROKER_RECEIVE_WAITFOR,
PREEMPTIVE_OS_GETPROCADDRESS, PREEMPTIVE_OS_AUTHENTICATIONOPS,
BROKER_TASK_STOP, SP_SERVER_DIAGNOSTICS_SLEEP
```

---

## Arquivos Entregues

| # | Arquivo | Descricao |
|---|---------|-----------|
| 1 | `01-setup-monitoring-user.sql` | Script SQL para criar usuario de monitoramento |
| 2 | `02-dashboard-sqlserver-performance.json` | Dashboard JSON completo (8 rows, 25 paineis) |
| 3 | `03-alert-rule-slow-query.json` | JSON do alert rule para query > 35s |
| 4 | `GUIA-COMPLETO-SQLSERVER-MONITORING.md` | Este guia de instrucoes |

---

## Proximos Passos Recomendados

1. **Criar alertas adicionais** para:
   - Buffer Cache Hit Ratio < 90% (severity: warning)
   - Page Life Expectancy < 200s (severity: warning)
   - Sessoes bloqueadas > 0 por mais de 5 minutos (severity: critical)
   - Disk latency > 50ms (severity: critical)

2. **Adicionar variaveis de template** para filtrar por database especifica

3. **Configurar anotacoes** para marcar eventos de deploy/manutencao no dashboard

4. **Integrar com runbook** automatizado para acoes de remediation

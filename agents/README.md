# Claude Code Agents - Sistema Multi-Agente para Infraestrutura e Desenvolvimento

## Visao Geral

Este repositorio contem uma colecao de agentes especializados para Claude Code, projetados para auxiliar em tarefas de infraestrutura, desenvolvimento, operacoes e documentacao.

## Arquitetura

```
                                    +-------------------+
                                    |   ORCHESTRATOR    |
                                    | (Orquestrador)    |
                                    +--------+----------+
                                             |
            +--------------------------------+--------------------------------+
            |                |               |               |                |
    +-------v------+  +------v------+  +-----v-----+  +-----v-----+  +-------v-------+
    | INFRA LAYER  |  | DEV LAYER   |  | OPS LAYER |  | SEC LAYER |  | DOC LAYER     |
    +--------------+  +-------------+  +-----------+  +-----------+  +---------------+
    | - Kubernetes |  | - Python    |  | - DevOps  |  | - SecOps  |  | - Documentation|
    | - Cloud      |  | - Node.js   |  | - Tester  |  |           |  | - Templates    |
    | - Managed K8s|  | - FastAPI   |  |           |  |           |  |                |
    | - Networking |  |             |  |           |  |           |  |                |
    | - Database   |  |             |  |           |  |           |  |                |
    | - Observab.  |  |             |  |           |  |           |  |                |
    | - Backstage  |  |             |  |           |  |           |  |                |
    +--------------+  +-------------+  +-----------+  +-----------+  +---------------+
```

## Agentes Disponiveis

### Orquestracao
| Agente | Descricao | Arquivo |
|--------|-----------|---------|
| Orchestrator | Orquestra todos os agentes, nao executa tarefas diretamente | [orchestrator.md](orchestrator/orchestrator.md) |

### Infraestrutura
| Agente | Descricao | Arquivo |
|--------|-----------|---------|
| K8s Troubleshooting | Resolucao de problemas em Kubernetes | [k8s-troubleshooting.md](kubernetes/k8s-troubleshooting.md) |
| Observability | Monitoramento, metricas e logs | [observability.md](observability/observability.md) |
| Azure Cloud | Especialista em Microsoft Azure | [azure.md](cloud/azure.md) |
| AWS Cloud | Especialista em Amazon Web Services | [aws.md](cloud/aws.md) |
| GCP Cloud | Especialista em Google Cloud Platform | [gcp.md](cloud/gcp.md) |
| OCI Cloud | Especialista em Oracle Cloud Infrastructure | [oci.md](cloud/oci.md) |
| AKS | Azure Kubernetes Service | [aks.md](managed-k8s/aks.md) |
| EKS | Elastic Kubernetes Service | [eks.md](managed-k8s/eks.md) |
| GKE | Google Kubernetes Engine | [gke.md](managed-k8s/gke.md) |
| OKE | Oracle Kubernetes Engine | [oke.md](managed-k8s/oke.md) |
| Networking | Especialista em redes (CCNA) | [ccna-networking.md](networking/ccna-networking.md) |
| PostgreSQL DBA | Administracao de banco de dados PostgreSQL | [postgresql-dba.md](database/postgresql-dba.md) |
| Backstage | Portal de desenvolvedores | [backstage.md](backstage/backstage.md) |

### Desenvolvimento
| Agente | Descricao | Arquivo |
|--------|-----------|---------|
| Python Developer | Desenvolvimento em Python | [python-developer.md](development/python-developer.md) |
| Node.js Developer | Desenvolvimento em Node.js | [nodejs-developer.md](development/nodejs-developer.md) |
| FastAPI Developer | Desenvolvimento com FastAPI | [fastapi-developer.md](development/fastapi-developer.md) |

### Operacoes
| Agente | Descricao | Arquivo |
|--------|-----------|---------|
| DevOps | CI/CD e infraestrutura como codigo | [devops.md](devops/devops.md) |
| Tester | Quality Assurance e testes | [tester.md](testing/tester.md) |

### Seguranca
| Agente | Descricao | Arquivo |
|--------|-----------|---------|
| SecOps | Seguranca de operacoes | [secops.md](security/secops.md) |

### Documentacao
| Agente | Descricao | Arquivo |
|--------|-----------|---------|
| Documentation | Geracao de documentacao usando Design Docs | [documentation.md](documentation/documentation.md) |

## Templates de Report

O agente de documentacao utiliza os seguintes templates:

| Template | Uso | Arquivo |
|----------|-----|---------|
| Incident Report | Documentacao de incidentes | [incident-report.md](documentation/templates/incident-report.md) |
| Problem Report | Documentacao de problemas | [problem-report.md](documentation/templates/problem-report.md) |
| RCA Report | Analise de causa raiz | [rca-report.md](documentation/templates/rca-report.md) |
| App Documentation | Documentacao de aplicacoes | [app-documentation.md](documentation/templates/app-documentation.md) |

## Como Usar

### Invocando o Orquestrador

O orquestrador deve ser o ponto de entrada para tarefas complexas que envolvem multiplos agentes:

```
Use o agente orchestrator para: [descreva sua tarefa]
```

### Invocando Agentes Diretamente

Para tarefas especificas, voce pode invocar agentes diretamente:

```
Use o agente [nome-do-agente] para: [descreva sua tarefa]
```

## Fluxo de Report

Todos os agentes seguem um fluxo padronizado de report:

1. **Identificacao** - Identificar o problema/tarefa
2. **Analise** - Analisar o contexto e impacto
3. **Acao** - Executar as acoes necessarias
4. **Documentacao** - Documentar resultados e causas raiz
5. **Report** - Gerar report final usando template apropriado

## Contribuindo

Para adicionar novos agentes:

1. Crie um novo diretorio em `agents/`
2. Crie o arquivo MD seguindo o padrao existente
3. Atualize este README
4. Adicione templates de report se necessario

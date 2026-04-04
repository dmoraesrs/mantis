# Padrao de Webhook - Azure Logic App (Email via Office 365)

## Objetivo

Este documento define o **formato padrao de payload** para envio de notificacoes por email via Azure Logic Apps com conector Office 365. Todos os projetos devem seguir este padrao para reutilizar a mesma Logic App.

---

## Payload Padrao

```json
{
  "notification_type": "generic",
  "recipient_email": "usuario@email.com",
  "recipient_name": "Nome do Usuario",
  "subject": "Assunto do Email",
  "data": {
    "html_content": "<html>...</html>"
  }
}
```

### Com Anexo (opcional)

```json
{
  "notification_type": "generic",
  "recipient_email": "usuario@email.com",
  "recipient_name": "Nome do Usuario",
  "subject": "Assunto do Email",
  "data": {
    "html_content": "<html>...</html>",
    "attachment": {
      "Name": "arquivo.pdf",
      "ContentBytes": "base64-encoded-content"
    }
  }
}
```

---

## Campos

| Campo | Tipo | Obrigatorio | Descricao |
|-------|------|-------------|-----------|
| `notification_type` | string | Sim | Tipo da notificacao. Use `"generic"` para emails com HTML customizado |
| `recipient_email` | string | Sim | Email do destinatario |
| `recipient_name` | string | Sim | Nome do destinatario (exibido no "Para") |
| `subject` | string | Sim | Assunto do email |
| `data` | object | Sim | Dados especificos da notificacao |
| `data.html_content` | string | Sim* | Conteudo HTML do email (obrigatorio para `notification_type: "generic"`) |
| `data.attachment` | object | Nao | Anexo unico do email |
| `data.attachment.Name` | string | Sim** | Nome do arquivo anexo (ex: `recibo.pdf`) |
| `data.attachment.ContentBytes` | string | Sim** | Conteudo do arquivo em base64 |

*\* Obrigatorio quando `notification_type` = `"generic"`*
*\*\* Obrigatorio quando `data.attachment` esta presente*

---

## Tipos de Notificacao Suportados

| Tipo | Uso | Campos em `data` |
|------|-----|-------------------|
| `generic` | Email com HTML livre | `html_content`, `attachment?` |
| `alert` | Alerta generico | `alert_name`, `current_value`, `threshold_value`, `percentage`, `threshold`, `alert_severity`, `entity_name`, `source`, `unit` |
| `anomaly` | Anomalia detectada | `service_name`, `source`, `current_value`, `expected_value`, `change_percent`, `unit` |
| `daily_report` | Relatorio diario | `report_date`, `value`, `change_percent`, `unit` |
| `welcome` | Boas-vindas | (vazio) |
| `scheduled_report` | Relatorio agendado com anexo | `html_content`, `attachment` |

> **Nota:** Para a maioria dos projetos, use `notification_type: "generic"` com `html_content`. Os outros tipos tem templates HTML embutidos na Logic App (configurados no seu projeto).

---

## Exemplos de Implementacao

### TypeScript/Node.js

```typescript
interface LogicAppPayload {
  notification_type: string;
  recipient_email: string;
  recipient_name: string;
  subject: string;
  data: {
    html_content?: string;
    attachment?: {
      Name: string;
      ContentBytes: string;
    };
    [key: string]: unknown;
  };
}

async function sendNotification(webhookUrl: string, payload: LogicAppPayload): Promise<boolean> {
  const response = await fetch(webhookUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
  return response.ok;
}

// Exemplo: Email simples
await sendNotification(webhookUrl, {
  notification_type: 'generic',
  recipient_email: 'user@email.com',
  recipient_name: 'Joao Silva',
  subject: 'Bem-vindo ao Sistema',
  data: {
    html_content: '<h1>Ola Joao!</h1><p>Sua conta foi criada.</p>',
  },
});

// Exemplo: Email com anexo PDF
await sendNotification(webhookUrl, {
  notification_type: 'generic',
  recipient_email: 'user@email.com',
  recipient_name: 'Joao Silva',
  subject: 'Recibo de Pagamento - 2026-01',
  data: {
    html_content: '<h1>Recibo</h1><p>Segue em anexo seu recibo.</p>',
    attachment: {
      Name: 'recibo_2026-01.pdf',
      ContentBytes: 'JVBERi0xLjQK...', // base64
    },
  },
});
```

### Python

```python
import httpx

async def send_notification(webhook_url: str, payload: dict) -> bool:
    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(
            webhook_url,
            json=payload,
            headers={"Content-Type": "application/json"},
        )
        return response.status_code in (200, 202)

# Exemplo: Email simples
await send_notification(webhook_url, {
    "notification_type": "generic",
    "recipient_email": "user@email.com",
    "recipient_name": "Joao Silva",
    "subject": "Redefinicao de Senha",
    "data": {
        "html_content": "<h1>Reset</h1><p>Clique no link para redefinir.</p>"
    }
})
```

---

## Logic App - Configuracao

A Logic App que recebe estes payloads deve:

1. **Trigger:** HTTP Request (POST)
2. **Schema do Request Body:**

```json
{
  "type": "object",
  "properties": {
    "notification_type": { "type": "string" },
    "recipient_email": { "type": "string" },
    "recipient_name": { "type": "string" },
    "subject": { "type": "string" },
    "data": {
      "type": "object",
      "properties": {
        "html_content": { "type": "string" },
        "attachment": {
          "type": "object",
          "properties": {
            "Name": { "type": "string" },
            "ContentBytes": { "type": "string" }
          }
        }
      }
    }
  },
  "required": ["notification_type", "recipient_email", "subject"]
}
```

3. **Action:** Office 365 Outlook - Send an email (V2)
   - **To:** `@triggerBody()?['recipient_email']`
   - **Subject:** `@triggerBody()?['subject']`
   - **Body:** `@triggerBody()?['data']?['html_content']`
   - **Attachments** (condicional, quando `data.attachment` existe):
     ```
     Name: @triggerBody()?['data']?['attachment']?['Name']
     ContentBytes: @triggerBody()?['data']?['attachment']?['ContentBytes']
     ```

---

## Projetos que Usam Este Padrao

| Projeto | Linguagem | Arquivo de Referencia |
|---------|-----------|----------------------|
| **Seu Projeto** | Python | `<caminho>/notifications.py` |

---

## Regras para Novos Projetos

1. **SEMPRE** use o formato padrao acima para enviar emails via Logic App
2. **NUNCA** envie campos como `to`, `toName`, `body` diretamente - use `recipient_email`, `recipient_name`, `data.html_content`
3. **Use `notification_type: "generic"`** para emails com HTML customizado
4. **Anexos** sao limitados a 1 por email (limitacao do template da Logic App)
5. **ContentBytes** deve ser o conteudo do arquivo em **base64**
6. A Logic App aceita respostas **200** ou **202** como sucesso
7. **Timeout** recomendado para o request: 30 segundos

## Regra de Isolamento Multi-Tenant

> **REGRA CRITICA**: Todo codigo, query, configuracao ou endpoint gerado DEVE garantir isolamento multi-tenant.
>
> - **Backend**: Toda query Prisma DEVE filtrar por `tenantId`. Todo endpoint DEVE ter `authenticate` + `tenantIsolation` como preHandler
> - **PromQL**: Toda query DEVE incluir `zorky_tenant_id="${tenantId}"` como label filter
> - **TraceQL**: Toda query DEVE incluir `resource.tenant_id="${tenantId}"`
> - **LogsQL**: Toda query DEVE incluir `attributes.tenant_id:exact("${tenantId}")`
> - **Pyroscope**: Toda query DEVE incluir `zorky_tenant_id="${tenantId}"`
> - **Anti-spoofing**: SEMPRE remover qualquer tenant_id fornecido pelo usuario antes de injetar o correto do JWT
> - **Cache**: Toda cache key DEVE incluir `tenantId` para evitar vazamento cross-tenant
> - **Respostas**: Validar pos-query que os dados retornados pertencem ao tenant (defense-in-depth)
> - **IDOR**: Usar `findFirst({ where: { id, tenantId } })` em vez de `findUnique({ where: { id } })` para prevenir acesso cross-tenant
> - **Nenhum cliente deve ver dados de outro cliente. Violacao desta regra e vulnerabilidade CRITICA.**

## Regra de Atribuicao de Codigo

> **REGRA OBRIGATORIA**: NUNCA incluir comentarios, headers, footers, annotations ou qualquer referencia a "Claude", "Claude Code", "Anthropic", "Generated by AI", "Co-Authored-By" de IA, ou qualquer ferramenta de IA nos arquivos gerados (codigo, configs, documentacao, commits, PRs).

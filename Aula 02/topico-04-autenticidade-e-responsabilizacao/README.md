# Tópico 04 — Autenticidade e responsabilização

## Objetivo

Verificar a origem confiável de arquivos e usar registros para reconstruir uma sequência de ações.

## Atividade 06 — Autenticidade e assinatura

Script: [atividade-06-autenticidade-assinatura.ps1](atividade-06-autenticidade-assinatura.ps1)

Interface para alunos: [interface-atividade-06-autenticidade-assinatura.ps1](interface-atividade-06-autenticidade-assinatura.ps1)

O script consulta a assinatura Authenticode de [dados/script-teste.ps1](dados/script-teste.ps1) e do executável do Windows PowerShell. Os resultados podem indicar, por exemplo, `Valid` ou `NotSigned`.

O laboratório apenas consulta assinaturas: nenhum arquivo é executado ou alterado.

## Atividade 07 — Logs e análise forense

Script: [atividade-07-logs-e-forense.ps1](atividade-07-logs-e-forense.ps1)

Interface para alunos: [interface-atividade-07-logs-forense.ps1](interface-atividade-07-logs-forense.ps1)

O exercício trabalha com eventos sintéticos, ordena os registros, agrupa falhas de autenticação por origem e destaca padrões que merecem investigação.

### Roteiro

1. Execute o script com [dados/eventos-seguranca.csv](dados/eventos-seguranca.csv).
2. Identifique usuário, origem, horário, ação e resultado.
3. Explique como esses campos contribuem para responsabilização e investigação.
4. Discuta por que várias falhas são um indicador, mas não uma prova isolada de ataque.

Os identificadores 4624, 4625 e 4688 aparecem no conjunto apenas como referência didática. O exercício não depende de eventos reais do Windows.

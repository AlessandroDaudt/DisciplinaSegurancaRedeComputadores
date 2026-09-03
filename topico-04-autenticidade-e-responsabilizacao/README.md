# Tópico 04 - Autenticidade e responsabilização

## Objetivo

Verificar a origem confiável de arquivos e utilizar registros de eventos para reconstruir uma sequência de ações.

## Atividade 06 - Verificação de autenticidade e assinatura

Arquivo: `atividade-06-autenticidade-assinatura.ps1`

O script consulta a assinatura Authenticode de um script de teste e do executável do Windows PowerShell. Os resultados podem ser `Valid`, `NotSigned` ou outro estado de validação.

O laboratório apenas consulta assinaturas. Nenhum arquivo é executado ou alterado.

## Atividade 07 - Registros e análise forense

Arquivo: `atividade-07-logs-e-forense.ps1`

O script analisa um conjunto de eventos sintéticos, ordena os registros, agrupa falhas de autenticação por origem e destaca padrões que merecem investigação.

### Roteiro

1. Execute o script com os dados fornecidos.
2. Identifique usuário, origem, horário, ação e resultado.
3. Explique como esses campos contribuem para responsabilização e investigação.
4. Discuta por que várias falhas são um indicador, mas não uma prova isolada de ataque.

Os eventos 4624, 4625 e 4688 são apresentados no arquivo apenas como referência didática. O exercício usa dados sintéticos para ser reproduzível em sala.

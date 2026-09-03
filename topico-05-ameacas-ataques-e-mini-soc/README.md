# Tópico 05 - Ameaças, ataques e mini-SOC

## Objetivo

Consolidar a diferença entre ameaça, ataque e vulnerabilidade e aplicar uma triagem inicial a indicadores de segurança.

## Atividade 08 - Classificação de cenários

Arquivo: `atividade-08-classificacao-seguranca.ps1`

O script apresenta cenários sintéticos e permite que o estudante responda:

1. Ameaça;
2. Ataque;
3. Vulnerabilidade.

Para visualizar o gabarito diretamente, execute com `-MostrarGabarito`. No modo normal, o script solicita as respostas e apresenta a pontuação.

## Atividade 09 - Mini-SOC em PowerShell

Arquivo: `atividade-09-mini-soc.ps1`

O script reúne dados sintéticos de triagem, calcula o hash de uma evidência local, classifica a prioridade por severidade e grava um relatório em `resultado/relatorio-mini-soc.txt`.

Opcionalmente, a turma pode coletar informações locais somente de leitura com `-ColetarHost`, incluindo portas em escuta e uma amostra de serviços parados.

O resultado é uma triagem inicial. Ele não substitui investigação, validação de contexto ou supervisão humana.

# Tópico 05 — Ameaças, ataques e mini-SOC

## Objetivo

Diferenciar ameaça, ataque e vulnerabilidade e aplicar uma triagem inicial a indicadores de segurança.

## Atividade 08 — Ameaça, ataque ou vulnerabilidade?

Script: [atividade-08-classificacao-seguranca.ps1](atividade-08-classificacao-seguranca.ps1)

Interface para alunos: [interface-atividade-08-classificacao-seguranca.ps1](interface-atividade-08-classificacao-seguranca.ps1)

O script apresenta cenários sintéticos para classificação. No modo normal, o estudante responde no console e recebe a pontuação. Para consultar o gabarito, use `-MostrarGabarito`.

## Atividade 09 — Mini-SOC em PowerShell

Script: [atividade-09-mini-soc.ps1](atividade-09-mini-soc.ps1)

Interface para alunos: [interface-atividade-09-mini-soc.ps1](interface-atividade-09-mini-soc.ps1)

O script reúne os eventos de [dados/eventos-triagem.csv](dados/eventos-triagem.csv), calcula o hash de [dados/evidencia-arquivo.txt](dados/evidencia-arquivo.txt), classifica a prioridade por severidade e grava um relatório em `resultado/relatorio-mini-soc.txt`.

Opcionalmente, `-ColetarHost` coleta informações locais somente de leitura, incluindo portas em escuta e uma amostra de serviços parados.

O resultado é uma triagem inicial. Ele não substitui investigação, validação de contexto ou supervisão humana.

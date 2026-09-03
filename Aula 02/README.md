# Aula 02 — Atividades práticas em PowerShell

Esta aula concentra os laboratórios práticos que acompanham a disciplina. Os exercícios foram separados por tópico para que cada conceito tenha seu próprio roteiro, script e conjunto de dados.

## Conteúdo

| Tópico | Conceito | Atividades |
| --- | --- | --- |
| [01 — Fundamentos e CIA](topico-01-fundamentos-e-cia/README.md) | Confidencialidade, integridade e disponibilidade | 01 |
| [02 — Integridade e hash](topico-02-integridade-e-hash/README.md) | Hash, linha de base e alterações | 02 e 03 |
| [03 — Criptografia](topico-03-criptografia/README.md) | Criptografia simétrica e assimétrica | 04 e 05 |
| [04 — Autenticidade e responsabilização](topico-04-autenticidade-e-responsabilizacao/README.md) | Assinaturas, logs e forense | 06 e 07 |
| [05 — Ameaças, ataques e mini-SOC](topico-05-ameacas-ataques-e-mini-soc/README.md) | Classificação e triagem | 08 e 09 |

## Roteiro recomendado

1. [Atividade 01 — Auditoria da tríade CIA](topico-01-fundamentos-e-cia/atividade-01-auditoria-cia.ps1)
2. [Atividade 02 — Verificação de integridade com hash](topico-02-integridade-e-hash/atividade-02-hash-integridade.ps1)
3. [Atividade 03 — Monitoramento de alterações](topico-02-integridade-e-hash/atividade-03-monitoramento-alteracoes.ps1)
4. [Atividade 04 — Criptografia simétrica](topico-03-criptografia/atividade-04-criptografia-simetrica.ps1)
5. [Atividade 05 — Criptografia assimétrica](topico-03-criptografia/atividade-05-criptografia-assimetrica.ps1)
6. [Atividade 06 — Autenticidade e assinatura](topico-04-autenticidade-e-responsabilizacao/atividade-06-autenticidade-assinatura.ps1)
7. [Atividade 07 — Logs e análise forense](topico-04-autenticidade-e-responsabilizacao/atividade-07-logs-e-forense.ps1)
8. [Atividade 08 — Ameaça, ataque ou vulnerabilidade](topico-05-ameacas-ataques-e-mini-soc/atividade-08-classificacao-seguranca.ps1)
9. [Atividade 09 — Mini-SOC em PowerShell](topico-05-ameacas-ataques-e-mini-soc/atividade-09-mini-soc.ps1)

## Execução

Abra o script no PowerShell ISE ou execute-o pelo Windows PowerShell 5.1. Os scripts usam `$PSScriptRoot`, portanto encontram os arquivos da pasta `dados` independentemente da pasta atual do console.

Exemplo:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Aula 02\topico-02-integridade-e-hash\atividade-02-hash-integridade.ps1"
```

A [interface principal](interface-principal.ps1) oferece acesso aos nove exercícios. O botão **Abrir roteiro** abre o roteiro específico da atividade e também este roteiro geral da aula. A atividade 08 é interativa e deve ser respondida no ISE; as demais podem ser executadas pela interface.

## Saídas e segurança

As pastas `resultado` são criadas automaticamente dentro de cada tópico e estão protegidas pelo `.gitignore`. Os arquivos de teste são sintéticos e os scripts não alteram políticas, serviços ou permissões do Windows. A atividade 05 pode criar um certificado autoassinado no repositório do usuário atual para fins didáticos.

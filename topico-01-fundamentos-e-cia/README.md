# Tópico 01 - Fundamentos e tríade CIA

## Objetivo

Relacionar confidencialidade, integridade e disponibilidade a evidências observáveis em um ambiente local.

## Atividade 01 - Auditoria da tríade CIA

Arquivo: `atividade-01-auditoria-cia.ps1`

O script avalia três evidências simples:

- **Confidencialidade:** permissões NTFS do arquivo de teste;
- **Integridade:** hash SHA-256 do arquivo de teste;
- **Disponibilidade:** existência e conteúdo de um arquivo que representa o status de um serviço.

### Roteiro

1. Execute o script e registre o resultado de cada dimensão.
2. Renomeie temporariamente `dados/status-servico.txt` para `status-servico.indisponivel.txt`.
3. Execute o script novamente e observe a mudança na disponibilidade.
4. Restaure o nome original e execute uma última vez.

O laboratório não altera permissões, serviços ou configurações do sistema.

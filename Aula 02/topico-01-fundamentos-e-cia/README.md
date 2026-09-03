# Tópico 01 — Fundamentos e tríade CIA

## Objetivo

Relacionar confidencialidade, integridade e disponibilidade a evidências que podem ser observadas em arquivos locais.

## Atividade 01 — Auditoria da tríade CIA

Script: [atividade-01-auditoria-cia.ps1](atividade-01-auditoria-cia.ps1)

Interface para alunos: [interface-atividade-01-auditoria-cia.ps1](interface-atividade-01-auditoria-cia.ps1)

O exercício verifica:

- **Confidencialidade:** permissões NTFS do arquivo de teste;
- **Integridade:** hash SHA-256 do arquivo de teste;
- **Disponibilidade:** existência e conteúdo de um arquivo que representa o status de um serviço.

### Roteiro

1. Execute o script e registre o resultado das três dimensões.
2. Renomeie temporariamente `dados/status-servico.txt` para `status-servico.indisponivel.txt`.
3. Execute o script novamente e observe a alteração na disponibilidade.
4. Restaure o nome original e repita a execução.

O laboratório é somente de leitura em relação ao sistema: ele não altera permissões, serviços ou configurações do Windows.

# Tópico 02 — Integridade e hash

## Objetivo

Usar funções de hash para detectar alterações em arquivos e compreender como uma linha de base apoia o monitoramento de integridade.

## Atividade 02 — Verificação de integridade com hash

Script: [atividade-02-hash-integridade.ps1](atividade-02-hash-integridade.ps1)

Na primeira execução, o script calcula e guarda uma referência SHA-256. Nas execuções seguintes, compara o conteúdo atual com essa referência.

### Roteiro

1. Execute o script uma vez para criar a referência.
2. Altere uma palavra em [dados/arquivo-teste.txt](dados/arquivo-teste.txt).
3. Execute o script novamente e observe a indicação de alteração.
4. Para iniciar uma nova referência, use o parâmetro `-RecriarReferencia`.

## Atividade 03 — Monitoramento de alterações

Script: [atividade-03-monitoramento-alteracoes.ps1](atividade-03-monitoramento-alteracoes.ps1)

O script calcula uma linha de base para os arquivos da pasta `dados` e identifica arquivos novos, modificados ou removidos.

### Roteiro

1. Execute o script para criar a linha de base.
2. Crie ou altere um arquivo dentro de `dados`.
3. Execute novamente e classifique cada resultado.
4. Use `-RecriarReferencia` para começar um novo laboratório.

As referências e os relatórios são gravados em `resultado`, que fica fora da linha de base e não deve ser versionado.

# Tópico 02 - Integridade e hash

## Objetivo

Observar como uma função de hash permite detectar alterações em arquivos e como uma linha de base apoia o monitoramento de integridade.

## Atividade 02 - Verificação de integridade com hash

Arquivo: `atividade-02-hash-integridade.ps1`

Na primeira execução, o script registra uma referência SHA-256. Nas execuções seguintes, compara o arquivo atual com essa referência.

### Roteiro

1. Execute o script uma vez para criar a referência.
2. Abra `dados/arquivo-teste.txt` e altere apenas uma palavra.
3. Execute o script novamente e observe a indicação de alteração.
4. Para iniciar uma nova referência, execute o script com a opção `-RecriarReferencia`.

## Atividade 03 - Monitoramento de alterações

Arquivo: `atividade-03-monitoramento-alteracoes.ps1`

O script calcula a linha de base de todos os arquivos da pasta `dados` e identifica arquivos novos, modificados ou removidos.

### Roteiro

1. Execute o script para criar a linha de base.
2. Crie ou altere um arquivo dentro de `dados`.
3. Execute novamente e classifique cada resultado.
4. Use `-RecriarReferencia` quando quiser iniciar uma nova aula ou laboratório.

As saídas ficam em `resultado`, que não deve ser usado como parte da linha de base.

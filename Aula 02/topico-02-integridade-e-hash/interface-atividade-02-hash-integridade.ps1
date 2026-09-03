[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$script:pastaAtividade = $PSScriptRoot
$script:scriptAtividade = Join-Path $script:pastaAtividade 'atividade-02-hash-integridade.ps1'
$script:roteiroAtividade = Join-Path $script:pastaAtividade 'README.md'
$script:arquivoPadrao = Join-Path (Join-Path $script:pastaAtividade 'dados') 'arquivo-teste.txt'

$script:ui = New-InterfaceDidatica -Titulo 'Atividade 02 — Verificação de integridade com hash' -Subtitulo 'Compare o hash atual com uma referência para identificar mudanças em um arquivo.' -Objetivo 'Entender como SHA-256 ajuda a perceber alterações em um arquivo de forma objetiva.' -Passos @(
    'Escolha o arquivo de teste.',
    'Na primeira execução, mantenha a opção de nova referência desmarcada.',
    'Altere uma palavra no arquivo e execute novamente para comparar os hashes.'
) -TextoExecutar 'Verificar integridade'

$script:campoArquivo = Add-CampoArquivo -Painel $script:ui.Campos -Rotulo 'Arquivo que será verificado' -ValorInicial $script:arquivoPadrao -Filtro 'Arquivos de texto (*.txt)|*.txt|Todos os arquivos (*.*)|*.*' -TituloSelecao 'Selecione o arquivo para verificar'
$script:recriarReferencia = Add-CaixaMarcacao -Painel $script:ui.Campos -Texto 'Criar uma nova referência de hash (reinicia a comparação)'
Add-NotaDidatica -Painel $script:ui.Campos -Texto 'A referência fica em resultado/hash-referencia.txt. Use a opção acima somente quando desejar começar de novo.'

function Executar-Atividade02 {
    $arquivo = $script:campoArquivo.TextBox.Text.Trim()
    if (-not (Test-Path -LiteralPath $arquivo -PathType Leaf)) {
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Erro -Texto 'Escolha um arquivo existente antes de executar.'
        return
    }

    $parametros = @{ Arquivo = $arquivo }
    if ($script:recriarReferencia.Checked) {
        $parametros.RecriarReferencia = $true
    }

    Invoke-AtividadeComSaida -ScriptPath $script:scriptAtividade -Parametros $parametros -Saida $script:ui.Saida -NomeAtividade 'Verificação de integridade com hash'
}

function Abrir-RoteiroAtividade02 {
    Abrir-DocumentoDidatico -Caminho $script:roteiroAtividade -Saida $script:ui.Saida
}

function Abrir-PastaAtividade02 {
    Abrir-PastaDidatica -Caminho $script:pastaAtividade -Saida $script:ui.Saida
}

$script:ui.BotaoExecutar.Add_Click({ Executar-Atividade02 })
$script:ui.BotaoRoteiro.Add_Click({ Abrir-RoteiroAtividade02 })
$script:ui.BotaoDados.Add_Click({ Abrir-PastaAtividade02 })
$script:ui.BotaoLimpar.Add_Click({ $script:ui.Saida.Clear() })

[void]$script:ui.Form.ShowDialog()

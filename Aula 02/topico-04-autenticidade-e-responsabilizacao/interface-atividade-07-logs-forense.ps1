[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$script:pastaAtividade = $PSScriptRoot
$script:scriptAtividade = Join-Path $script:pastaAtividade 'atividade-07-logs-e-forense.ps1'
$script:roteiroAtividade = Join-Path $script:pastaAtividade 'README.md'
$script:arquivoPadrao = Join-Path (Join-Path $script:pastaAtividade 'dados') 'eventos-seguranca.csv'

$script:ui = New-InterfaceDidatica -Titulo 'Atividade 07 — Logs e análise forense' -Subtitulo 'Organize eventos e identifique padrões que merecem investigação.' -Objetivo 'Ler uma linha do tempo, agrupar falhas de autenticação e interpretar indicadores com cautela.' -Passos @(
    'Escolha o arquivo CSV de eventos.',
    'Clique em Analisar registros.',
    'Observe a linha do tempo e os agrupamentos antes de tirar conclusões.'
) -TextoExecutar 'Analisar registros'

$script:campoArquivo = Add-CampoArquivo -Painel $script:ui.Campos -Rotulo 'Arquivo CSV de eventos' -ValorInicial $script:arquivoPadrao -Filtro 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*' -TituloSelecao 'Selecione o arquivo de eventos'
Add-NotaDidatica -Painel $script:ui.Campos -Texto 'Os arquivos de resultado são gravados em resultado. Os eventos fornecidos são sintéticos.'

function Executar-Atividade07 {
    $arquivo = $script:campoArquivo.TextBox.Text.Trim()
    if (-not (Test-Path -LiteralPath $arquivo -PathType Leaf)) {
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Erro -Texto 'Escolha um arquivo CSV existente antes de executar.'
        return
    }

    Invoke-AtividadeComSaida -ScriptPath $script:scriptAtividade -Parametros @{ ArquivoEventos = $arquivo } -Saida $script:ui.Saida -NomeAtividade 'Análise de logs e forense'
}

function Abrir-RoteiroAtividade07 {
    Abrir-DocumentoDidatico -Caminho $script:roteiroAtividade -Saida $script:ui.Saida
}

function Abrir-PastaAtividade07 {
    Abrir-PastaDidatica -Caminho $script:pastaAtividade -Saida $script:ui.Saida
}

$script:ui.BotaoExecutar.Add_Click({ Executar-Atividade07 })
$script:ui.BotaoRoteiro.Add_Click({ Abrir-RoteiroAtividade07 })
$script:ui.BotaoDados.Add_Click({ Abrir-PastaAtividade07 })
$script:ui.BotaoLimpar.Add_Click({ $script:ui.Saida.Clear() })

[void]$script:ui.Form.ShowDialog()

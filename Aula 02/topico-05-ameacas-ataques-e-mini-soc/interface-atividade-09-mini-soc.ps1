[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$script:pastaAtividade = $PSScriptRoot
$script:scriptAtividade = Join-Path $script:pastaAtividade 'atividade-09-mini-soc.ps1'
$script:roteiroAtividade = Join-Path $script:pastaAtividade 'README.md'
$script:arquivoEventosPadrao = Join-Path (Join-Path $script:pastaAtividade 'dados') 'eventos-triagem.csv'
$script:arquivoEvidenciaPadrao = Join-Path (Join-Path $script:pastaAtividade 'dados') 'evidencia-arquivo.txt'

$script:ui = New-InterfaceDidatica -Titulo 'Atividade 09 — Mini-SOC em PowerShell' -Subtitulo 'Faça uma triagem inicial com eventos, evidência e prioridade didática.' -Objetivo 'Relacionar severidade, indicadores e hash de evidência a uma decisão inicial de prioridade.' -Passos @(
    'Escolha o CSV de eventos e o arquivo de evidência.',
    'Decida se deseja incluir a coleta local somente de leitura.',
    'Clique em Gerar triagem e discuta quais evidências adicionais seriam necessárias.'
) -TextoExecutar 'Gerar triagem' -Aviso 'A coleta opcional consulta informações locais. Não envia dados para a internet.'

$script:ui.GrupoCampos.Height = 250
$script:campoEventos = Add-CampoArquivo -Painel $script:ui.Campos -Rotulo 'Arquivo CSV de eventos de triagem' -ValorInicial $script:arquivoEventosPadrao -Filtro 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*' -TituloSelecao 'Selecione o arquivo de eventos'
$script:campoEvidencia = Add-CampoArquivo -Painel $script:ui.Campos -Rotulo 'Arquivo de evidência para calcular o hash' -ValorInicial $script:arquivoEvidenciaPadrao -Filtro 'Arquivos de texto (*.txt)|*.txt|Todos os arquivos (*.*)|*.*' -TituloSelecao 'Selecione o arquivo de evidência'
$script:coletarHost = Add-CaixaMarcacao -Painel $script:ui.Campos -Texto 'Incluir coleta local somente de leitura (portas em escuta e serviços parados)'
Add-NotaDidatica -Painel $script:ui.Campos -Texto 'O relatório é salvo em resultado/relatorio-mini-soc.txt.'

function Executar-Atividade09 {
    $eventos = $script:campoEventos.TextBox.Text.Trim()
    $evidencia = $script:campoEvidencia.TextBox.Text.Trim()
    if (-not (Test-Path -LiteralPath $eventos -PathType Leaf)) {
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Erro -Texto 'Escolha um arquivo CSV de eventos existente antes de executar.'
        return
    }
    if (-not (Test-Path -LiteralPath $evidencia -PathType Leaf)) {
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Erro -Texto 'Escolha um arquivo de evidência existente antes de executar.'
        return
    }

    $parametros = @{
        ArquivoEventos   = $eventos
        ArquivoEvidencia = $evidencia
    }
    if ($script:coletarHost.Checked) {
        $parametros.ColetarHost = $true
    }

    Invoke-AtividadeComSaida -ScriptPath $script:scriptAtividade -Parametros $parametros -Saida $script:ui.Saida -NomeAtividade 'Triagem inicial de mini-SOC'
}

function Abrir-RoteiroAtividade09 {
    Abrir-DocumentoDidatico -Caminho $script:roteiroAtividade -Saida $script:ui.Saida
}

function Abrir-PastaAtividade09 {
    Abrir-PastaDidatica -Caminho $script:pastaAtividade -Saida $script:ui.Saida
}

$script:ui.BotaoExecutar.Add_Click({ Executar-Atividade09 })
$script:ui.BotaoRoteiro.Add_Click({ Abrir-RoteiroAtividade09 })
$script:ui.BotaoDados.Add_Click({ Abrir-PastaAtividade09 })
$script:ui.BotaoLimpar.Add_Click({ $script:ui.Saida.Clear() })

[void]$script:ui.Form.ShowDialog()

[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$script:pastaAtividade = $PSScriptRoot
$script:scriptAtividade = Join-Path $script:pastaAtividade 'atividade-03-monitoramento-alteracoes.ps1'
$script:roteiroAtividade = Join-Path $script:pastaAtividade 'README.md'
$script:pastaDadosPadrao = Join-Path $script:pastaAtividade 'dados'

$script:ui = New-InterfaceDidatica -Titulo 'Atividade 03 — Monitoramento de alterações' -Subtitulo 'Crie uma linha de base e descubra arquivos novos, modificados ou removidos.' -Objetivo 'Praticar o uso de uma linha de base para monitorar a integridade de uma pasta.' -Passos @(
    'Escolha a pasta que será monitorada.',
    'Execute uma vez para criar a linha de base.',
    'Altere, crie ou remova um arquivo e execute novamente para observar a diferença.'
) -TextoExecutar 'Monitorar alterações'

$script:campoPastaDados = Add-CampoPasta -Painel $script:ui.Campos -Rotulo 'Pasta que será monitorada' -ValorInicial $script:pastaDadosPadrao -Descricao 'Selecione a pasta de dados para monitorar'
$script:recriarReferencia = Add-CaixaMarcacao -Painel $script:ui.Campos -Texto 'Criar uma nova linha de base (reinicia o monitoramento)'
Add-NotaDidatica -Painel $script:ui.Campos -Texto 'Os relatórios são salvos em resultado. Essa pasta não entra na comparação.'

function Executar-Atividade03 {
    $pastaDados = $script:campoPastaDados.TextBox.Text.Trim()
    if (-not (Test-Path -LiteralPath $pastaDados -PathType Container)) {
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Erro -Texto 'Escolha uma pasta existente antes de executar.'
        return
    }

    $parametros = @{ PastaDados = $pastaDados }
    if ($script:recriarReferencia.Checked) {
        $parametros.RecriarReferencia = $true
    }

    Invoke-AtividadeComSaida -ScriptPath $script:scriptAtividade -Parametros $parametros -Saida $script:ui.Saida -NomeAtividade 'Monitoramento de alterações'
}

function Abrir-RoteiroAtividade03 {
    Abrir-DocumentoDidatico -Caminho $script:roteiroAtividade -Saida $script:ui.Saida
}

function Abrir-PastaAtividade03 {
    Abrir-PastaDidatica -Caminho $script:pastaAtividade -Saida $script:ui.Saida
}

$script:ui.BotaoExecutar.Add_Click({ Executar-Atividade03 })
$script:ui.BotaoRoteiro.Add_Click({ Abrir-RoteiroAtividade03 })
$script:ui.BotaoDados.Add_Click({ Abrir-PastaAtividade03 })
$script:ui.BotaoLimpar.Add_Click({ $script:ui.Saida.Clear() })

[void]$script:ui.Form.ShowDialog()

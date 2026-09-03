[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$script:pastaAtividade = $PSScriptRoot
$script:scriptAtividade = Join-Path $script:pastaAtividade 'atividade-01-auditoria-cia.ps1'
$script:roteiroAtividade = Join-Path $script:pastaAtividade 'README.md'
$script:pastaDadosPadrao = Join-Path $script:pastaAtividade 'dados'

$script:ui = New-InterfaceDidatica -Titulo 'Atividade 01 — Auditoria da tríade CIA' -Subtitulo 'Observe confidencialidade, integridade e disponibilidade usando arquivos locais de teste.' -Objetivo 'Reconhecer evidências simples da tríade CIA e discutir controles que reduzam os riscos encontrados.' -Passos @(
    'Mantenha a pasta de dados de exemplo ou selecione outra pasta compatível.',
    'Clique em Executar auditoria.',
    'Leia o resultado e relacione cada evidência à confidencialidade, integridade ou disponibilidade.'
) -TextoExecutar 'Executar auditoria' -Aviso 'A atividade consulta arquivos locais; não altera permissões, serviços ou configurações do Windows.'

$script:campoPastaDados = Add-CampoPasta -Painel $script:ui.Campos -Rotulo 'Pasta com ativo-confidencial.txt e status-servico.txt' -ValorInicial $script:pastaDadosPadrao -Descricao 'Selecione a pasta com os dados da atividade'
Add-NotaDidatica -Painel $script:ui.Campos -Texto 'Dica: renomeie temporariamente status-servico.txt para observar uma mudança na disponibilidade.'

function Executar-Atividade01 {
    $pastaDados = $script:campoPastaDados.TextBox.Text.Trim()
    if (-not (Test-Path -LiteralPath $pastaDados -PathType Container)) {
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Erro -Texto 'Escolha uma pasta de dados existente antes de executar.'
        return
    }

    Invoke-AtividadeComSaida -ScriptPath $script:scriptAtividade -Parametros @{ PastaDados = $pastaDados } -Saida $script:ui.Saida -NomeAtividade 'Auditoria da tríade CIA'
}

function Abrir-RoteiroAtividade01 {
    Abrir-DocumentoDidatico -Caminho $script:roteiroAtividade -Saida $script:ui.Saida
}

function Abrir-PastaAtividade01 {
    Abrir-PastaDidatica -Caminho $script:pastaAtividade -Saida $script:ui.Saida
}

$script:ui.BotaoExecutar.Add_Click({ Executar-Atividade01 })
$script:ui.BotaoRoteiro.Add_Click({ Abrir-RoteiroAtividade01 })
$script:ui.BotaoDados.Add_Click({ Abrir-PastaAtividade01 })
$script:ui.BotaoLimpar.Add_Click({ $script:ui.Saida.Clear() })

[void]$script:ui.Form.ShowDialog()

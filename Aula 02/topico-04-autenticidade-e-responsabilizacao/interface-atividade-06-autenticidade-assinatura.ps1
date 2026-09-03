[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$script:pastaAtividade = $PSScriptRoot
$script:scriptAtividade = Join-Path $script:pastaAtividade 'atividade-06-autenticidade-assinatura.ps1'
$script:roteiroAtividade = Join-Path $script:pastaAtividade 'README.md'
$script:arquivosPadrao = @(
    (Join-Path (Join-Path $script:pastaAtividade 'dados') 'script-teste.ps1'),
    (Join-Path $PSHOME 'powershell.exe')
)

$script:ui = New-InterfaceDidatica -Titulo 'Atividade 06 — Autenticidade e assinatura' -Subtitulo 'Consulte a assinatura digital de arquivos sem executá-los.' -Objetivo 'Interpretar o status de uma assinatura Authenticode como evidência de autenticidade e integridade.' -Passos @(
    'Selecione um ou mais arquivos para consultar.',
    'Clique em Verificar assinaturas.',
    'Compare o status encontrado com o contexto do arquivo.'
) -TextoExecutar 'Verificar assinaturas' -Aviso 'A atividade só consulta assinaturas; nenhum dos arquivos selecionados será executado.'

$script:ui.GrupoCampos.Height = 245
$script:campoArquivos = Add-CampoMultiplosArquivos -Painel $script:ui.Campos -Rotulo 'Arquivos para consultar' -ValoresIniciais $script:arquivosPadrao -Filtro 'Arquivos PowerShell (*.ps1)|*.ps1|Executáveis (*.exe)|*.exe|Todos os arquivos (*.*)|*.*'
Add-NotaDidatica -Painel $script:ui.Campos -Texto 'Use o botão Selecionar para substituir a lista. Selecione um item e use Remover para tirá-lo da consulta.'

function Executar-Atividade06 {
    $arquivos = @($script:campoArquivos.Lista.Items | ForEach-Object { [string]$_ })
    if ($arquivos.Count -eq 0) {
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Erro -Texto 'Selecione pelo menos um arquivo antes de executar.'
        return
    }

    Invoke-AtividadeComSaida -ScriptPath $script:scriptAtividade -Parametros @{ Arquivos = $arquivos } -Saida $script:ui.Saida -NomeAtividade 'Consulta de assinaturas digitais'
}

function Abrir-RoteiroAtividade06 {
    Abrir-DocumentoDidatico -Caminho $script:roteiroAtividade -Saida $script:ui.Saida
}

function Abrir-PastaAtividade06 {
    Abrir-PastaDidatica -Caminho $script:pastaAtividade -Saida $script:ui.Saida
}

$script:ui.BotaoExecutar.Add_Click({ Executar-Atividade06 })
$script:ui.BotaoRoteiro.Add_Click({ Abrir-RoteiroAtividade06 })
$script:ui.BotaoDados.Add_Click({ Abrir-PastaAtividade06 })
$script:ui.BotaoLimpar.Add_Click({ $script:ui.Saida.Clear() })

[void]$script:ui.Form.ShowDialog()

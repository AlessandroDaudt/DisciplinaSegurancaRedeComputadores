[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$pastaAtividade = $PSScriptRoot
$arquivoAtividade = Join-Path $pastaAtividade 'atividade-12-avaliacao-ambiente-cpd.ps1'
$roteiroAtividade = Join-Path $pastaAtividade 'roteiro-atividade-12.md'
$arquivoPadrao = Join-Path (Join-Path $pastaAtividade 'dados') 'ambientes-cpd.csv'
$imagemHero = Join-Path (Join-Path (Split-Path -Parent $pastaAtividade) 'assets') 'seguranca-fisica-laboratorio.png'

$ui = New-InterfaceSegurancaFisica -Titulo 'Atividade 12 — Avaliação do ambiente do CPD' -Subtitulo 'Transforme as características físicas de um ambiente em uma leitura didática de risco.' -Objetivo 'Reconhecer como perímetro, localização, energia, incêndio, climatização e mídias influenciam o risco de um CPD.' -Passos @(
    'Mantenha ou selecione o arquivo com os ambientes.',
    'Clique em Avaliar ambientes.',
    'Compare a pontuação de risco e as recomendações.'
) -CorDestaque ([System.Drawing.Color]::FromArgb(94, 53, 177)) -ImagemHero $imagemHero -TextoExecutar 'Avaliar ambientes'

$campoArquivo = Add-CampoArquivoSF -Painel $ui.Campos -Rotulo 'Arquivo CSV com características dos ambientes' -ValorInicial $arquivoPadrao -Filtro 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*' -TituloSelecao 'Selecione os ambientes do CPD'
Add-ContextoSF -Painel $ui.Campos -Titulo 'Mapa visual de risco' -Texto 'Cada controle ausente soma pontos de risco. A tela explica as lacunas sem alterar o ambiente real.' | Out-Null

$executar = {
    $arquivo = $campoArquivo.TextBox.Text.Trim()
    if (-not (Test-Path -LiteralPath $arquivo -PathType Leaf)) {
        Mostrar-ResultadoSF -Ui $ui -Tipo Erro -Texto 'Escolha um arquivo CSV existente antes de avaliar os ambientes.'
        return
    }
    Invoke-AtividadeSF -ScriptPath $arquivoAtividade -Parametros @{ ArquivoAmbientes = $arquivo } -Ui $ui -NomeAtividade 'AVALIAÇÃO DO AMBIENTE DO CPD'
}.GetNewClosure()

$abrirRoteiro = { Abrir-RoteiroSF -Caminho $roteiroAtividade -Ui $ui }.GetNewClosure()
$abrirPasta = { Abrir-PastaSF -Caminho $pastaAtividade -Ui $ui }.GetNewClosure()
$limpar = { Limpar-ResultadoSF -Ui $ui }.GetNewClosure()

$ui.BotaoExecutar.Add_Click($executar)
$ui.BotaoRoteiro.Add_Click($abrirRoteiro)
$ui.BotaoPasta.Add_Click($abrirPasta)
$ui.BotaoLimpar.Add_Click($limpar)

[void]$ui.Form.ShowDialog()

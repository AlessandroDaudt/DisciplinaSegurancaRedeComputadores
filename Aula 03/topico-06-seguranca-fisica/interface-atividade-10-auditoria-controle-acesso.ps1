[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$pastaAtividade = $PSScriptRoot
$arquivoAtividade = Join-Path $pastaAtividade 'atividade-10-auditoria-controle-acesso.ps1'
$roteiroAtividade = Join-Path $pastaAtividade 'roteiro-atividade-10.md'
$arquivoPadrao = Join-Path (Join-Path $pastaAtividade 'dados') 'acessos-fisicos.csv'
$imagemHero = Join-Path (Join-Path (Split-Path -Parent $pastaAtividade) 'assets') 'seguranca-fisica-laboratorio.png'

$ui = New-InterfaceSegurancaFisica -Titulo 'Atividade 10 — Auditoria de acessos físicos' -Subtitulo 'Observe como autorização, horário e perfil influenciam a proteção de áreas sensíveis.' -Objetivo 'Identificar registros compatíveis, de atenção e críticos em um controle de acesso físico simulado.' -Passos @(
    'Mantenha o arquivo de exemplo ou selecione outro CSV compatível.',
    'Clique em Analisar acessos.',
    'Leia a classificação e proponha um controle para cada risco.'
) -CorDestaque ([System.Drawing.Color]::FromArgb(0, 137, 123)) -ImagemHero $imagemHero -TextoExecutar 'Analisar acessos'

$campoArquivo = Add-CampoArquivoSF -Painel $ui.Campos -Rotulo 'Arquivo CSV com registros de entrada e saída' -ValorInicial $arquivoPadrao -Filtro 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*' -TituloSelecao 'Selecione o arquivo de acessos físicos'
Add-ContextoSF -Painel $ui.Campos -Titulo 'O que será verificado' -Texto 'A autorização, o horário permitido e a compatibilidade do perfil com a sensibilidade da área.' | Out-Null

$executar = {
    $arquivo = $campoArquivo.TextBox.Text.Trim()
    if (-not (Test-Path -LiteralPath $arquivo -PathType Leaf)) {
        Mostrar-ResultadoSF -Ui $ui -Tipo Erro -Texto 'Escolha um arquivo CSV existente antes de analisar os acessos.'
        return
    }
    Invoke-AtividadeSF -ScriptPath $arquivoAtividade -Parametros @{ ArquivoAcessos = $arquivo } -Ui $ui -NomeAtividade 'AUDITORIA DE ACESSOS FÍSICOS'
}.GetNewClosure()

$abrirRoteiro = {
    Abrir-RoteiroSF -Caminho $roteiroAtividade -Ui $ui
}.GetNewClosure()

$abrirPasta = {
    Abrir-PastaSF -Caminho $pastaAtividade -Ui $ui
}.GetNewClosure()

$limpar = {
    Limpar-ResultadoSF -Ui $ui
}.GetNewClosure()

$ui.BotaoExecutar.Add_Click($executar)
$ui.BotaoRoteiro.Add_Click($abrirRoteiro)
$ui.BotaoPasta.Add_Click($abrirPasta)
$ui.BotaoLimpar.Add_Click($limpar)

[void]$ui.Form.ShowDialog()

[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$pastaAtividade = $PSScriptRoot
$arquivoAtividade = Join-Path $pastaAtividade 'atividade-13-auditoria-midias.ps1'
$roteiroAtividade = Join-Path $pastaAtividade 'roteiro-atividade-13.md'
$arquivoPadrao = Join-Path (Join-Path $pastaAtividade 'dados') 'inventario-midias.csv'
$imagemHero = Join-Path (Join-Path (Split-Path -Parent $pastaAtividade) 'assets') 'seguranca-fisica-laboratorio.png'

$ui = New-InterfaceSegurancaFisica -Titulo 'Atividade 13 — Auditoria de mídias' -Subtitulo 'Verifique se mídias removíveis estão armazenadas e transportadas com segurança.' -Objetivo 'Identificar riscos de exposição física, transporte e condições ambientais em um inventário de mídias simulado.' -Passos @(
    'Mantenha o inventário de exemplo ou selecione outro CSV.',
    'Clique em Auditar mídias.',
    'Leia os riscos e associe-os a um controle de proteção.'
) -CorDestaque ([System.Drawing.Color]::FromArgb(0, 121, 140)) -ImagemHero $imagemHero -TextoExecutar 'Auditar mídias'

$campoArquivo = Add-CampoArquivoSF -Painel $ui.Campos -Rotulo 'Arquivo CSV com o inventário de mídias' -ValorInicial $arquivoPadrao -Filtro 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*' -TituloSelecao 'Selecione o inventário de mídias'
Add-ContextoSF -Painel $ui.Campos -Titulo 'Lembrete visual' -Texto 'O laboratório avalia proteção física, autorização de transporte e exposição ao calor ou a campos magnéticos.' | Out-Null

$executar = {
    $arquivo = $campoArquivo.TextBox.Text.Trim()
    if (-not (Test-Path -LiteralPath $arquivo -PathType Leaf)) {
        Mostrar-ResultadoSF -Ui $ui -Tipo Erro -Texto 'Escolha um arquivo CSV existente antes de auditar as mídias.'
        return
    }
    Invoke-AtividadeSF -ScriptPath $arquivoAtividade -Parametros @{ ArquivoInventario = $arquivo } -Ui $ui -NomeAtividade 'AUDITORIA DE MÍDIAS E TRANSPORTE'
}.GetNewClosure()

$abrirRoteiro = { Abrir-RoteiroSF -Caminho $roteiroAtividade -Ui $ui }.GetNewClosure()
$abrirPasta = { Abrir-PastaSF -Caminho $pastaAtividade -Ui $ui }.GetNewClosure()
$limpar = { Limpar-ResultadoSF -Ui $ui }.GetNewClosure()

$ui.BotaoExecutar.Add_Click($executar)
$ui.BotaoRoteiro.Add_Click($abrirRoteiro)
$ui.BotaoPasta.Add_Click($abrirPasta)
$ui.BotaoLimpar.Add_Click($limpar)

[void]$ui.Form.ShowDialog()

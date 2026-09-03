[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$pastaAtividade = $PSScriptRoot
$arquivoAtividade = Join-Path $pastaAtividade 'atividade-11-matriz-controles-fisicos.ps1'
$roteiroAtividade = Join-Path $pastaAtividade 'roteiro-atividade-11.md'
$arquivoPadrao = Join-Path (Join-Path $pastaAtividade 'dados') 'cenarios-controles-fisicos.csv'
$imagemHero = Join-Path (Join-Path (Split-Path -Parent $pastaAtividade) 'assets') 'seguranca-fisica-laboratorio.png'
$script:cenariosControles = @()

$ui = New-InterfaceSegurancaFisica -Titulo 'Atividade 11 — Matriz de controles físicos' -Subtitulo 'Escolha controles de perímetro, acesso, detecção e proteção ambiental para cada cenário.' -Objetivo 'Relacionar o risco físico observado aos controles preventivos, detectivos e de redução de impacto mais adequados.' -Passos @(
    'Carregue o arquivo de cenários.',
    'Escolha um cenário e marque os controles que considera essenciais.',
    'Clique em Avaliar escolha e compare com a explicação.'
) -CorDestaque ([System.Drawing.Color]::FromArgb(239, 108, 0)) -ImagemHero $imagemHero -TextoExecutar 'Avaliar escolha'

$campoArquivo = Add-CampoArquivoSF -Painel $ui.Campos -Rotulo 'Arquivo CSV com cenários de proteção física' -ValorInicial $arquivoPadrao -Filtro 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*' -TituloSelecao 'Selecione os cenários de controles físicos'
$listaCenarios = Add-ComboSF -Painel $ui.Campos -Rotulo 'Cenário para analisar'
$contexto = Add-ContextoSF -Painel $ui.Campos -Titulo 'Contexto do cenário'

$controles = @(
    'Barreira de perímetro',
    'CFTV',
    'Controle de acesso por cartão',
    'Biometria',
    'Detector de fumaça e combate a incêndio',
    'Climatização e energia redundante',
    'Armário protegido para mídias'
)
$caixas = foreach ($controle in $controles) {
    Add-CaixaMarcacaoSF -Painel $ui.Campos -Texto $controle
}

$atualizarCenario = {
    if ($listaCenarios.SelectedIndex -lt 0) {
        return
    }

    $selecionado = [string]$listaCenarios.SelectedItem
    $id = ($selecionado -split ' — ', 2)[0]
    $cenario = @($script:cenariosControles | Where-Object { $_.Id -eq $id }) | Select-Object -First 1
    if ($null -eq $cenario) {
        return
    }

    $contexto.Texto.Text = ('Área: ' + $cenario.Area + ' | Risco: ' + $cenario.RiscoPrincipal + [Environment]::NewLine + $cenario.Descricao)
}.GetNewClosure()

$carregarCenarios = {
    $arquivo = $campoArquivo.TextBox.Text.Trim()
    if (-not (Test-Path -LiteralPath $arquivo -PathType Leaf)) {
        Mostrar-ResultadoSF -Ui $ui -Tipo Erro -Texto 'Escolha um arquivo CSV existente antes de carregar os cenários.'
        return
    }

    try {
        $script:cenariosControles = @(Import-Csv -LiteralPath $arquivo -Encoding UTF8)
        if ($script:cenariosControles.Count -eq 0) {
            throw 'O arquivo não possui cenários.'
        }

        $listaCenarios.Items.Clear()
        foreach ($cenario in $script:cenariosControles) {
            [void]$listaCenarios.Items.Add(($cenario.Id + ' — ' + $cenario.Cenario))
        }
        $listaCenarios.SelectedIndex = 0
        & $atualizarCenario
        Mostrar-ResultadoSF -Ui $ui -Tipo Info -Texto 'Cenários carregados. Escolha os controles que protegem melhor o risco apresentado.'
    }
    catch {
        Mostrar-ResultadoSF -Ui $ui -Tipo Erro -Texto ('Não foi possível carregar os cenários. ' + $_.Exception.Message)
    }
}.GetNewClosure()

$executar = {
    if ($listaCenarios.SelectedIndex -lt 0) {
        Mostrar-ResultadoSF -Ui $ui -Tipo Erro -Texto 'Carregue e escolha um cenário antes de avaliar.'
        return
    }

    $arquivo = $campoArquivo.TextBox.Text.Trim()
    $id = (([string]$listaCenarios.SelectedItem) -split ' — ', 2)[0]
    $selecionados = @($caixas | Where-Object { $_.Checked } | ForEach-Object { $_.Text })
    Invoke-AtividadeSF -ScriptPath $arquivoAtividade -Parametros @{
        ArquivoCenarios       = $arquivo
        CenarioId             = $id
        ControlesSelecionados = $selecionados
    } -Ui $ui -NomeAtividade 'MATRIZ DE CONTROLES FÍSICOS'
}.GetNewClosure()

$botaoCarregar = New-Object System.Windows.Forms.Button
$botaoCarregar.Text = 'Carregar cenários'
$botaoCarregar.Size = [System.Drawing.Size]::new(150, 36)
Set-EstiloBotaoSF -Botao $botaoCarregar -CorFundo ([System.Drawing.Color]::FromArgb(25, 118, 210))

$abrirRoteiro = { Abrir-RoteiroSF -Caminho $roteiroAtividade -Ui $ui }.GetNewClosure()
$abrirPasta = { Abrir-PastaSF -Caminho $pastaAtividade -Ui $ui }.GetNewClosure()
$limpar = { Limpar-ResultadoSF -Ui $ui }.GetNewClosure()

$botaoCarregar.Add_Click($carregarCenarios)
$listaCenarios.Add_SelectedIndexChanged($atualizarCenario)
$ui.BotaoExecutar.Add_Click($executar)
$ui.BotaoRoteiro.Add_Click($abrirRoteiro)
$ui.BotaoPasta.Add_Click($abrirPasta)
$ui.BotaoLimpar.Add_Click($limpar)
$ui.PainelBotoes.Controls.Add($botaoCarregar)
$ui.PainelBotoes.Controls.SetChildIndex($botaoCarregar, 1)

& $carregarCenarios
[void]$ui.Form.ShowDialog()

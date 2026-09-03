[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$pastaAtividade = $PSScriptRoot
$arquivoAtividade = Join-Path $pastaAtividade 'atividade-14-rotina-segura-cpd.ps1'
$roteiroAtividade = Join-Path $pastaAtividade 'roteiro-atividade-14.md'
$arquivoPadrao = Join-Path (Join-Path $pastaAtividade 'dados') 'cenarios-rotina-cpd.csv'
$imagemHero = Join-Path (Join-Path (Split-Path -Parent $pastaAtividade) 'assets') 'seguranca-fisica-laboratorio.png'
$script:cenariosRotina = @()
$script:opcoesAtuais = @()

$ui = New-InterfaceSegurancaFisica -Titulo 'Atividade 14 — Rotina segura do CPD' -Subtitulo 'Tome decisões em situações do dia a dia e veja a relação com os procedimentos de segurança.' -Objetivo 'Aplicar procedimentos operacionais de controle de acesso, incêndio, energia, ambiente, equipamentos e mídias.' -Passos @(
    'Carregue os cenários de rotina.',
    'Escolha uma situação e selecione a ação mais segura.',
    'Clique em Validar decisão e leia a explicação.'
) -CorDestaque ([System.Drawing.Color]::FromArgb(198, 40, 40)) -ImagemHero $imagemHero -TextoExecutar 'Validar decisão'

$campoArquivo = Add-CampoArquivoSF -Painel $ui.Campos -Rotulo 'Arquivo CSV com situações da rotina do CPD' -ValorInicial $arquivoPadrao -Filtro 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*' -TituloSelecao 'Selecione os cenários da rotina'
$listaCenarios = Add-ComboSF -Painel $ui.Campos -Rotulo 'Situação para resolver'
$contexto = Add-ContextoSF -Painel $ui.Campos -Titulo 'Contexto da situação'
$painelOpcoes = New-PainelOpcoesSF -Painel $ui.Campos -Titulo '2. ESCOLHA A AÇÃO MAIS SEGURA' -Altura 190

$atualizarCenario = {
    if ($listaCenarios.SelectedIndex -lt 0) {
        return
    }

    $selecionado = [string]$listaCenarios.SelectedItem
    $id = ($selecionado -split ' — ', 2)[0]
    $cenario = @($script:cenariosRotina | Where-Object { $_.Id -eq $id }) | Select-Object -First 1
    if ($null -eq $cenario) {
        return
    }

    $contexto.Texto.Text = ('Área: ' + $cenario.Area + ' | Evento: ' + $cenario.Evento + [Environment]::NewLine + $cenario.Contexto)
    $painelOpcoes.Opcoes.Controls.Clear()
    $script:opcoesAtuais = @()
    foreach ($opcao in @($cenario.Opcoes -split '\|' | ForEach-Object { $_.Trim() })) {
        $script:opcoesAtuais += Add-RadioOpcaoSF -Painel $painelOpcoes.Opcoes -Texto $opcao
    }
}.GetNewClosure()

$carregarCenarios = {
    $arquivo = $campoArquivo.TextBox.Text.Trim()
    if (-not (Test-Path -LiteralPath $arquivo -PathType Leaf)) {
        Mostrar-ResultadoSF -Ui $ui -Tipo Erro -Texto 'Escolha um arquivo CSV existente antes de carregar os cenários.'
        return
    }

    try {
        $script:cenariosRotina = @(Import-Csv -LiteralPath $arquivo -Encoding UTF8)
        if ($script:cenariosRotina.Count -eq 0) {
            throw 'O arquivo não possui cenários.'
        }

        $listaCenarios.Items.Clear()
        foreach ($cenario in $script:cenariosRotina) {
            [void]$listaCenarios.Items.Add(($cenario.Id + ' — ' + $cenario.Evento))
        }
        $listaCenarios.SelectedIndex = 0
        & $atualizarCenario
        Mostrar-ResultadoSF -Ui $ui -Tipo Info -Texto 'Cenários carregados. Escolha a ação mais segura e valide sua decisão.'
    }
    catch {
        Mostrar-ResultadoSF -Ui $ui -Tipo Erro -Texto ('Não foi possível carregar os cenários. ' + $_.Exception.Message)
    }
}.GetNewClosure()

$executar = {
    if ($listaCenarios.SelectedIndex -lt 0) {
        Mostrar-ResultadoSF -Ui $ui -Tipo Erro -Texto 'Carregue e escolha uma situação antes de validar.'
        return
    }

    $radioMarcado = @($script:opcoesAtuais | Where-Object { $_.Checked } | Select-Object -First 1)
    if ($radioMarcado.Count -eq 0) {
        Mostrar-ResultadoSF -Ui $ui -Tipo Atencao -Texto 'Escolha uma ação antes de validar a decisão.'
        return
    }

    $arquivo = $campoArquivo.TextBox.Text.Trim()
    $id = (([string]$listaCenarios.SelectedItem) -split ' — ', 2)[0]
    Invoke-AtividadeSF -ScriptPath $arquivoAtividade -Parametros @{
        ArquivoCenarios = $arquivo
        CenarioId       = $id
        AcaoEscolhida   = $radioMarcado[0].Text
    } -Ui $ui -NomeAtividade 'SIMULADOR DE ROTINA SEGURA DO CPD'
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

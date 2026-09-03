[CmdletBinding()]
param()

. (Join-Path (Split-Path -Parent $PSScriptRoot) 'interface-comum.ps1')

$script:pastaAtividade = $PSScriptRoot
$script:roteiroAtividade = Join-Path $script:pastaAtividade 'README.md'
$script:arquivoPadrao = Join-Path (Join-Path $script:pastaAtividade 'dados') 'cenarios-seguranca.csv'
$script:cenarios = @()
$script:indiceCenario = 0
$script:acertos = 0

$script:ui = New-InterfaceDidatica -Titulo 'Atividade 08 — Ameaça, ataque ou vulnerabilidade?' -Subtitulo 'Classifique cenários de segurança e receba uma explicação imediata.' -Objetivo 'Diferenciar ameaça, ataque e vulnerabilidade em situações comuns de segurança da informação.' -Passos @(
    'Escolha o arquivo CSV com os cenários.',
    'Clique em Carregar cenários.',
    'Leia cada situação, escolha uma resposta e avance após receber o feedback.'
) -TextoExecutar 'Carregar cenários'

$script:campoArquivo = Add-CampoArquivo -Painel $script:ui.Campos -Rotulo 'Arquivo CSV de cenários' -ValorInicial $script:arquivoPadrao -Filtro 'Arquivos CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*' -TituloSelecao 'Selecione o arquivo de cenários'

$script:painelQuiz = New-Object System.Windows.Forms.Panel
$script:painelQuiz.Width = 880
$script:painelQuiz.Height = 138
$script:painelQuiz.Padding = New-Object System.Windows.Forms.Padding(2)

$script:progresso = New-Object System.Windows.Forms.Label
$script:progresso.Text = 'Carregue os cenários para começar.'
$script:progresso.AutoSize = $true
$script:progresso.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$script:progresso.Location = New-Object System.Drawing.Point(2, 3)

$script:cenario = New-Object System.Windows.Forms.TextBox
$script:cenario.Multiline = $true
$script:cenario.ReadOnly = $true
$script:cenario.ScrollBars = 'Vertical'
$script:cenario.Width = 845
$script:cenario.Height = 45
$script:cenario.Location = New-Object System.Drawing.Point(2, 25)
$script:cenario.BackColor = [System.Drawing.Color]::White

$script:botaoAmeaca = New-Object System.Windows.Forms.Button
$script:botaoAmeaca.Text = 'Ameaça'
$script:botaoAmeaca.Width = 120
$script:botaoAmeaca.Height = 30
$script:botaoAmeaca.Location = New-Object System.Drawing.Point(2, 76)
$script:botaoAmeaca.Enabled = $false

$script:botaoAtaque = New-Object System.Windows.Forms.Button
$script:botaoAtaque.Text = 'Ataque'
$script:botaoAtaque.Width = 120
$script:botaoAtaque.Height = 30
$script:botaoAtaque.Location = New-Object System.Drawing.Point(130, 76)
$script:botaoAtaque.Enabled = $false

$script:botaoVulnerabilidade = New-Object System.Windows.Forms.Button
$script:botaoVulnerabilidade.Text = 'Vulnerabilidade'
$script:botaoVulnerabilidade.Width = 135
$script:botaoVulnerabilidade.Height = 30
$script:botaoVulnerabilidade.Location = New-Object System.Drawing.Point(258, 76)
$script:botaoVulnerabilidade.Enabled = $false

$script:botaoProximo = New-Object System.Windows.Forms.Button
$script:botaoProximo.Text = 'Próximo cenário'
$script:botaoProximo.Width = 130
$script:botaoProximo.Height = 30
$script:botaoProximo.Location = New-Object System.Drawing.Point(402, 76)
$script:botaoProximo.Enabled = $false

$script:feedback = New-Object System.Windows.Forms.Label
$script:feedback.Text = ''
$script:feedback.AutoSize = $true
$script:feedback.MaximumSize = New-Object System.Drawing.Size(840, 25)
$script:feedback.Location = New-Object System.Drawing.Point(2, 112)

$script:painelQuiz.Controls.Add($script:progresso)
$script:painelQuiz.Controls.Add($script:cenario)
$script:painelQuiz.Controls.Add($script:botaoAmeaca)
$script:painelQuiz.Controls.Add($script:botaoAtaque)
$script:painelQuiz.Controls.Add($script:botaoVulnerabilidade)
$script:painelQuiz.Controls.Add($script:botaoProximo)
$script:painelQuiz.Controls.Add($script:feedback)
$script:ui.Campos.Controls.Add($script:painelQuiz)

$script:botaoGabarito = New-Object System.Windows.Forms.Button
$script:botaoGabarito.Text = 'Mostrar gabarito'
$script:botaoGabarito.Width = 125
$script:botaoGabarito.Height = 34
$script:ui.Botoes.Controls.Add($script:botaoGabarito)

function Atualizar-BotoesQuiz08 {
    param([bool]$HabilitarRespostas)

    $script:botaoAmeaca.Enabled = $HabilitarRespostas
    $script:botaoAtaque.Enabled = $HabilitarRespostas
    $script:botaoVulnerabilidade.Enabled = $HabilitarRespostas
}

function Mostrar-CenarioAtual08 {
    if ($script:indiceCenario -ge $script:cenarios.Count) {
        $script:progresso.Text = "Atividade concluída: $($script:acertos) de $($script:cenarios.Count) acertos."
        $script:cenario.Text = 'Você concluiu todos os cenários. Use Mostrar gabarito para revisar as respostas.'
        $script:feedback.Text = 'Discuta por que o contexto é importante antes de classificar um evento de segurança.'
        $script:feedback.ForeColor = [System.Drawing.Color]::FromArgb(31, 78, 121)
        Atualizar-BotoesQuiz08 -HabilitarRespostas $false
        $script:botaoProximo.Enabled = $false
        return
    }

    $item = $script:cenarios[$script:indiceCenario]
    $script:progresso.Text = "Cenário $($script:indiceCenario + 1) de $($script:cenarios.Count)"
    $script:cenario.Text = $item.Cenario
    $script:feedback.Text = 'Escolha a classificação que melhor descreve o cenário.'
    $script:feedback.ForeColor = [System.Drawing.Color]::DimGray
    Atualizar-BotoesQuiz08 -HabilitarRespostas $true
    $script:botaoProximo.Enabled = $false
}

function Carregar-Cenarios08 {
    $arquivo = $script:campoArquivo.TextBox.Text.Trim()
    if (-not (Test-Path -LiteralPath $arquivo -PathType Leaf)) {
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Erro -Texto 'Escolha um arquivo CSV existente antes de carregar os cenários.'
        return
    }

    try {
        $script:cenarios = @(Import-Csv -LiteralPath $arquivo -Encoding UTF8)
        if ($script:cenarios.Count -eq 0) {
            throw 'O arquivo não possui cenários.'
        }
        foreach ($coluna in @('ID', 'Cenario', 'Resposta', 'Justificativa')) {
            if ($script:cenarios[0].PSObject.Properties.Name -notcontains $coluna) {
                throw "A coluna obrigatória '$coluna' não foi encontrada."
            }
        }

        $script:indiceCenario = 0
        $script:acertos = 0
        Mostrar-CenarioAtual08
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Texto 'Cenários carregados. Leia cada situação e escolha uma das três classificações.'
    }
    catch {
        Set-SaidaDaAtividade -Saida $script:ui.Saida -Erro -Texto ('Não foi possível carregar os cenários.' + [Environment]::NewLine + $_.Exception.Message)
    }
}

function Responder-Atividade08 {
    param([Parameter(Mandatory)][string]$Resposta)

    if ($script:cenarios.Count -eq 0 -or $script:indiceCenario -ge $script:cenarios.Count) {
        return
    }

    $item = $script:cenarios[$script:indiceCenario]
    if ($Resposta -eq $item.Resposta) {
        $script:acertos++
        $script:feedback.Text = "Correto. $($item.Justificativa)"
        $script:feedback.ForeColor = [System.Drawing.Color]::FromArgb(46, 125, 50)
    }
    else {
        $script:feedback.Text = "Resposta esperada: $($item.Resposta). $($item.Justificativa)"
        $script:feedback.ForeColor = [System.Drawing.Color]::FromArgb(166, 91, 0)
    }

    Atualizar-BotoesQuiz08 -HabilitarRespostas $false
    $script:botaoProximo.Enabled = $true
}

function Avancar-Cenario08 {
    if ($script:cenarios.Count -eq 0) {
        return
    }

    $script:indiceCenario++
    Mostrar-CenarioAtual08
}

function Mostrar-Gabarito08 {
    if ($script:cenarios.Count -eq 0) {
        Carregar-Cenarios08
        if ($script:cenarios.Count -eq 0) {
            return
        }
    }

    $linhas = foreach ($item in $script:cenarios) {
        "Cenário $($item.ID): $($item.Resposta)" + [Environment]::NewLine + "Justificativa: $($item.Justificativa)" + [Environment]::NewLine
    }
    Set-SaidaDaAtividade -Saida $script:ui.Saida -Texto (($linhas -join [Environment]::NewLine).Trim())
}

function Abrir-RoteiroAtividade08 {
    Abrir-DocumentoDidatico -Caminho $script:roteiroAtividade -Saida $script:ui.Saida
}

function Abrir-PastaAtividade08 {
    Abrir-PastaDidatica -Caminho $script:pastaAtividade -Saida $script:ui.Saida
}

$script:ui.BotaoExecutar.Add_Click({ Carregar-Cenarios08 })
$script:ui.BotaoRoteiro.Add_Click({ Abrir-RoteiroAtividade08 })
$script:ui.BotaoDados.Add_Click({ Abrir-PastaAtividade08 })
$script:ui.BotaoLimpar.Add_Click({ $script:ui.Saida.Clear() })
$script:botaoGabarito.Add_Click({ Mostrar-Gabarito08 })
$script:botaoAmeaca.Add_Click({ Responder-Atividade08 -Resposta 'Ameaça' })
$script:botaoAtaque.Add_Click({ Responder-Atividade08 -Resposta 'Ataque' })
$script:botaoVulnerabilidade.Add_Click({ Responder-Atividade08 -Resposta 'Vulnerabilidade' })
$script:botaoProximo.Add_Click({ Avancar-Cenario08 })

[void]$script:ui.Form.ShowDialog()

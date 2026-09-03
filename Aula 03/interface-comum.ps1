[CmdletBinding()]
param()

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

function global:Set-EstiloBotaoSF {
    param(
        [Parameter(Mandatory)] [System.Windows.Forms.Button]$Botao,
        [Parameter(Mandatory)] [System.Drawing.Color]$CorFundo,
        [System.Drawing.Color]$CorTexto = [System.Drawing.Color]::White
    )

    $Botao.BackColor = $CorFundo
    $Botao.ForeColor = $CorTexto
    $Botao.FlatStyle = 'Flat'
    $Botao.FlatAppearance.BorderSize = 0
    $Botao.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
    $Botao.Cursor = [System.Windows.Forms.Cursors]::Hand
}

function global:New-CartaoLateralSF {
    param(
        [Parameter(Mandatory)] [System.Windows.Forms.FlowLayoutPanel]$Painel,
        [Parameter(Mandatory)] [string]$Titulo,
        [Parameter(Mandatory)] [string]$Texto,
        [Parameter(Mandatory)] [System.Drawing.Color]$Cor,
        [int]$Altura = 112
    )

    $cartao = New-Object System.Windows.Forms.Panel
    $cartao.Width = 292
    $cartao.Height = $Altura
    $cartao.Margin = [System.Windows.Forms.Padding]::new(9, 8, 9, 2)
    $cartao.BackColor = [System.Drawing.Color]::White

    $faixa = New-Object System.Windows.Forms.Panel
    $faixa.Dock = 'Left'
    $faixa.Width = 6
    $faixa.BackColor = $Cor

    $rotuloTitulo = New-Object System.Windows.Forms.Label
    $rotuloTitulo.Text = $Titulo.ToUpperInvariant()
    $rotuloTitulo.Location = [System.Drawing.Point]::new(18, 13)
    $rotuloTitulo.AutoSize = $true
    $rotuloTitulo.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 8, [System.Drawing.FontStyle]::Bold)
    $rotuloTitulo.ForeColor = $Cor

    $rotuloTexto = New-Object System.Windows.Forms.Label
    $rotuloTexto.Text = $Texto
    $rotuloTexto.Location = [System.Drawing.Point]::new(18, 35)
    $rotuloTexto.MaximumSize = [System.Drawing.Size]::new(252, 0)
    $rotuloTexto.AutoSize = $true
    $rotuloTexto.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9)
    $rotuloTexto.ForeColor = [System.Drawing.Color]::FromArgb(54, 67, 82)

    $cartao.Controls.Add($rotuloTexto)
    $cartao.Controls.Add($rotuloTitulo)
    $cartao.Controls.Add($faixa)
    $Painel.Controls.Add($cartao)
    return $cartao
}

function global:New-InterfaceSegurancaFisica {
    param(
        [Parameter(Mandatory)] [string]$Titulo,
        [Parameter(Mandatory)] [string]$Subtitulo,
        [Parameter(Mandatory)] [string]$Objetivo,
        [Parameter(Mandatory)] [string[]]$Passos,
        [Parameter(Mandatory)] [System.Drawing.Color]$CorDestaque,
        [string]$ImagemHero,
        [string]$TextoExecutar = 'Executar análise',
        [string]$Aviso = 'Laboratório local com dados sintéticos. Nenhum equipamento físico será controlado.'
    )

    $azulEscuro = [System.Drawing.Color]::FromArgb(13, 39, 66)
    $azulMedio = [System.Drawing.Color]::FromArgb(25, 69, 112)
    $cinzaFundo = [System.Drawing.Color]::FromArgb(240, 245, 249)
    $novaLinha = [Environment]::NewLine

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Titulo
    $form.StartPosition = 'CenterScreen'
    $form.Size = [System.Drawing.Size]::new(1220, 820)
    $form.MinimumSize = [System.Drawing.Size]::new(1020, 690)
    $form.BackColor = $cinzaFundo
    $form.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9)

    $layoutPrincipal = New-Object System.Windows.Forms.TableLayoutPanel
    $layoutPrincipal.Dock = 'Fill'
    $layoutPrincipal.ColumnCount = 1
    $layoutPrincipal.RowCount = 3
    $layoutPrincipal.BackColor = $cinzaFundo
    [void]$layoutPrincipal.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Absolute, 154))
    [void]$layoutPrincipal.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Percent, 100))
    [void]$layoutPrincipal.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Absolute, 30))

    $cabecalho = New-Object System.Windows.Forms.Panel
    $cabecalho.Dock = 'Fill'
    $cabecalho.BackColor = $azulEscuro

    $faixaDestaque = New-Object System.Windows.Forms.Panel
    $faixaDestaque.Dock = 'Left'
    $faixaDestaque.Width = 10
    $faixaDestaque.BackColor = $CorDestaque

    $selo = New-Object System.Windows.Forms.Label
    $selo.Text = 'AULA 03  •  SEGURANÇA FÍSICA'
    $selo.Location = [System.Drawing.Point]::new(31, 18)
    $selo.AutoSize = $true
    $selo.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 8, [System.Drawing.FontStyle]::Bold)
    $selo.ForeColor = $CorDestaque

    $rotuloTitulo = New-Object System.Windows.Forms.Label
    $rotuloTitulo.Text = $Titulo
    $rotuloTitulo.Location = [System.Drawing.Point]::new(29, 38)
    $rotuloTitulo.AutoSize = $true
    $rotuloTitulo.MaximumSize = [System.Drawing.Size]::new(720, 42)
    $rotuloTitulo.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 19, [System.Drawing.FontStyle]::Bold)
    $rotuloTitulo.ForeColor = [System.Drawing.Color]::White

    $rotuloSubtitulo = New-Object System.Windows.Forms.Label
    $rotuloSubtitulo.Text = $Subtitulo
    $rotuloSubtitulo.Location = [System.Drawing.Point]::new(32, 91)
    $rotuloSubtitulo.MaximumSize = [System.Drawing.Size]::new(710, 48)
    $rotuloSubtitulo.AutoSize = $true
    $rotuloSubtitulo.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9)
    $rotuloSubtitulo.ForeColor = [System.Drawing.Color]::FromArgb(222, 236, 248)

    $imagem = New-Object System.Windows.Forms.PictureBox
    $imagem.Size = [System.Drawing.Size]::new(360, 138)
    $imagem.Location = [System.Drawing.Point]::new(835, 8)
    $imagem.Anchor = 'Top, Right'
    $imagem.BackColor = [System.Drawing.Color]::FromArgb(228, 239, 247)
    $imagem.SizeMode = 'Zoom'
    if (-not [string]::IsNullOrWhiteSpace($ImagemHero) -and (Test-Path -LiteralPath $ImagemHero)) {
        try {
            $imagem.Image = [System.Drawing.Image]::FromFile($ImagemHero)
        }
        catch {
            $imagem.Visible = $false
        }
    }
    else {
        $imagem.Visible = $false
    }

    $cabecalho.Controls.Add($imagem)
    $cabecalho.Controls.Add($rotuloSubtitulo)
    $cabecalho.Controls.Add($rotuloTitulo)
    $cabecalho.Controls.Add($selo)
    $cabecalho.Controls.Add($faixaDestaque)
    $imagem.BringToFront()

    $divisor = New-Object System.Windows.Forms.SplitContainer
    $divisor.Dock = 'Fill'
    $divisor.FixedPanel = 'Panel1'
    $divisor.SplitterDistance = 318
    $divisor.Panel1MinSize = 280
    $divisor.BackColor = $cinzaFundo

    $painelLateral = New-Object System.Windows.Forms.FlowLayoutPanel
    $painelLateral.Dock = 'Fill'
    $painelLateral.FlowDirection = 'TopDown'
    $painelLateral.WrapContents = $false
    $painelLateral.AutoScroll = $true
    $painelLateral.BackColor = [System.Drawing.Color]::FromArgb(228, 237, 244)

    New-CartaoLateralSF -Painel $painelLateral -Titulo 'Objetivo da prática' -Texto $Objetivo -Cor $CorDestaque -Altura 126 | Out-Null
    $textoPassos = (($Passos | ForEach-Object -Begin { $numero = 0 } -Process { $numero++; "$numero. $_" }) -join $novaLinha)
    New-CartaoLateralSF -Painel $painelLateral -Titulo 'Roteiro rápido' -Texto $textoPassos -Cor $azulMedio -Altura 152 | Out-Null
    New-CartaoLateralSF -Painel $painelLateral -Titulo 'Camadas de proteção' -Texto 'Perímetro  →  Entrada controlada  →  Área sensível  →  Mídias protegidas' -Cor ([System.Drawing.Color]::FromArgb(111, 66, 193)) -Altura 112 | Out-Null
    New-CartaoLateralSF -Painel $painelLateral -Titulo 'Uso responsável' -Texto 'Os cenários são fictícios e a análise é local. A atividade não acessa catracas, câmeras, alarmes ou redes reais.' -Cor ([System.Drawing.Color]::FromArgb(22, 136, 126)) -Altura 118 | Out-Null
    $divisor.Panel1.Controls.Add($painelLateral)

    $painelDireito = New-Object System.Windows.Forms.TableLayoutPanel
    $painelDireito.Dock = 'Fill'
    $painelDireito.ColumnCount = 1
    $painelDireito.RowCount = 4
    $painelDireito.Padding = [System.Windows.Forms.Padding]::new(14, 12, 14, 10)
    [void]$painelDireito.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Percent, 44))
    [void]$painelDireito.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Absolute, 58))
    [void]$painelDireito.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Absolute, 32))
    [void]$painelDireito.RowStyles.Add([System.Windows.Forms.RowStyle]::new([System.Windows.Forms.SizeType]::Percent, 56))

    $cartaoDados = New-Object System.Windows.Forms.Panel
    $cartaoDados.Dock = 'Fill'
    $cartaoDados.BackColor = [System.Drawing.Color]::White

    $tituloDados = New-Object System.Windows.Forms.Label
    $tituloDados.Text = '1. PREPARE O CENÁRIO'
    $tituloDados.Dock = 'Top'
    $tituloDados.Height = 34
    $tituloDados.Padding = [System.Windows.Forms.Padding]::new(16, 10, 0, 0)
    $tituloDados.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
    $tituloDados.ForeColor = $CorDestaque

    $campos = New-Object System.Windows.Forms.FlowLayoutPanel
    $campos.Dock = 'Fill'
    $campos.FlowDirection = 'TopDown'
    $campos.WrapContents = $false
    $campos.AutoScroll = $true
    $campos.Padding = [System.Windows.Forms.Padding]::new(16, 3, 16, 8)
    $campos.BackColor = [System.Drawing.Color]::White
    $cartaoDados.Controls.Add($campos)
    $cartaoDados.Controls.Add($tituloDados)

    $painelBotoes = New-Object System.Windows.Forms.FlowLayoutPanel
    $painelBotoes.Dock = 'Fill'
    $painelBotoes.FlowDirection = 'LeftToRight'
    $painelBotoes.WrapContents = $false
    $painelBotoes.Padding = [System.Windows.Forms.Padding]::new(0, 11, 0, 0)
    $painelBotoes.BackColor = $cinzaFundo

    $botaoExecutar = New-Object System.Windows.Forms.Button
    $botaoExecutar.Text = $TextoExecutar
    $botaoExecutar.Size = [System.Drawing.Size]::new(185, 36)
    Set-EstiloBotaoSF -Botao $botaoExecutar -CorFundo $CorDestaque

    $botaoRoteiro = New-Object System.Windows.Forms.Button
    $botaoRoteiro.Text = 'Abrir roteiro'
    $botaoRoteiro.Size = [System.Drawing.Size]::new(132, 36)
    Set-EstiloBotaoSF -Botao $botaoRoteiro -CorFundo ([System.Drawing.Color]::FromArgb(72, 91, 108))

    $botaoPasta = New-Object System.Windows.Forms.Button
    $botaoPasta.Text = 'Abrir pasta'
    $botaoPasta.Size = [System.Drawing.Size]::new(118, 36)
    Set-EstiloBotaoSF -Botao $botaoPasta -CorFundo ([System.Drawing.Color]::FromArgb(90, 104, 118))

    $botaoLimpar = New-Object System.Windows.Forms.Button
    $botaoLimpar.Text = 'Limpar'
    $botaoLimpar.Size = [System.Drawing.Size]::new(92, 36)
    Set-EstiloBotaoSF -Botao $botaoLimpar -CorFundo ([System.Drawing.Color]::FromArgb(129, 142, 153))

    $painelBotoes.Controls.Add($botaoExecutar)
    $painelBotoes.Controls.Add($botaoRoteiro)
    $painelBotoes.Controls.Add($botaoPasta)
    $painelBotoes.Controls.Add($botaoLimpar)

    $cabecalhoResultado = New-Object System.Windows.Forms.Panel
    $cabecalhoResultado.Dock = 'Fill'
    $cabecalhoResultado.BackColor = [System.Drawing.Color]::FromArgb(233, 241, 247)

    $status = New-Object System.Windows.Forms.Label
    $status.Text = 'PRONTO PARA COMEÇAR'
    $status.AutoSize = $true
    $status.Location = [System.Drawing.Point]::new(13, 8)
    $status.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 8, [System.Drawing.FontStyle]::Bold)
    $status.ForeColor = $azulMedio

    $progresso = New-Object System.Windows.Forms.ProgressBar
    $progresso.Minimum = 0
    $progresso.Maximum = 100
    $progresso.Value = 0
    $progresso.Size = [System.Drawing.Size]::new(150, 8)
    $progresso.Location = [System.Drawing.Point]::new(180, 11)
    $progresso.Style = 'Continuous'
    $cabecalhoResultado.Controls.Add($status)
    $cabecalhoResultado.Controls.Add($progresso)

    $saida = New-Object System.Windows.Forms.RichTextBox
    $saida.Dock = 'Fill'
    $saida.ReadOnly = $true
    $saida.BorderStyle = 'None'
    $saida.BackColor = [System.Drawing.Color]::FromArgb(20, 32, 45)
    $saida.ForeColor = [System.Drawing.Color]::FromArgb(224, 242, 254)
    $saida.Font = New-Object System.Drawing.Font -ArgumentList @('Consolas', 9)
    $saida.WordWrap = $false
    $saida.ScrollBars = 'Both'
    $saida.Text = ('Quando estiver pronto, selecione o arquivo de exemplo e clique no botão de análise.' + $novaLinha + $novaLinha + 'A explicação aparecerá aqui, em linguagem didática.')

    $painelDireito.Controls.Add($cartaoDados, 0, 0)
    $painelDireito.Controls.Add($painelBotoes, 0, 1)
    $painelDireito.Controls.Add($cabecalhoResultado, 0, 2)
    $painelDireito.Controls.Add($saida, 0, 3)
    $divisor.Panel2.Controls.Add($painelDireito)

    $rodape = New-Object System.Windows.Forms.Label
    $rodape.Text = $Aviso
    $rodape.Dock = 'Fill'
    $rodape.Padding = [System.Windows.Forms.Padding]::new(18, 7, 0, 0)
    $rodape.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 8)
    $rodape.ForeColor = [System.Drawing.Color]::DimGray
    $rodape.BackColor = [System.Drawing.Color]::FromArgb(228, 237, 244)

    $layoutPrincipal.Controls.Add($cabecalho, 0, 0)
    $layoutPrincipal.Controls.Add($divisor, 0, 1)
    $layoutPrincipal.Controls.Add($rodape, 0, 2)
    $form.Controls.Add($layoutPrincipal)

    $ajustarDivisor = {
        if ($divisor.Width - $divisor.Panel2MinSize - 10 -ge 318) {
            $divisor.SplitterDistance = 318
        }
    }.GetNewClosure()
    $form.Add_Shown($ajustarDivisor)
    $form.Add_Resize($ajustarDivisor)

    return [PSCustomObject]@{
        Form           = $form
        Campos         = $campos
        Saida          = $saida
        Status         = $status
        Progresso      = $progresso
        BotaoExecutar  = $botaoExecutar
        BotaoRoteiro   = $botaoRoteiro
        BotaoPasta     = $botaoPasta
        BotaoLimpar    = $botaoLimpar
        PainelBotoes   = $painelBotoes
        CorDestaque    = $CorDestaque
    }
}

function global:Add-CampoArquivoSF {
    param(
        [Parameter(Mandatory)] [System.Windows.Forms.FlowLayoutPanel]$Painel,
        [Parameter(Mandatory)] [string]$Rotulo,
        [string]$ValorInicial,
        [string]$Filtro = 'Todos os arquivos (*.*)|*.*',
        [string]$TituloSelecao = 'Selecione um arquivo'
    )

    $linha = New-Object System.Windows.Forms.Panel
    $linha.Width = 810
    $linha.Height = 66
    $linha.Margin = [System.Windows.Forms.Padding]::new(0, 0, 0, 3)

    $rotuloCampo = New-Object System.Windows.Forms.Label
    $rotuloCampo.Text = $Rotulo
    $rotuloCampo.AutoSize = $true
    $rotuloCampo.Location = [System.Drawing.Point]::new(0, 2)
    $rotuloCampo.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)

    $texto = New-Object System.Windows.Forms.TextBox
    $texto.Text = $ValorInicial
    $texto.Location = [System.Drawing.Point]::new(0, 27)
    $texto.Width = 625
    $texto.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9)

    $botao = New-Object System.Windows.Forms.Button
    $botao.Text = 'Selecionar arquivo'
    $botao.Location = [System.Drawing.Point]::new(638, 25)
    $botao.Size = [System.Drawing.Size]::new(145, 28)
    Set-EstiloBotaoSF -Botao $botao -CorFundo ([System.Drawing.Color]::FromArgb(25, 118, 210))

    $filtroArquivo = $Filtro
    $tituloArquivo = $TituloSelecao
    $botao.Add_Click({
            $dialogo = New-Object System.Windows.Forms.OpenFileDialog
            $dialogo.Title = $tituloArquivo
            $dialogo.Filter = $filtroArquivo
            $dialogo.CheckFileExists = $true
            $dialogo.Multiselect = $false
            if ($dialogo.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $texto.Text = $dialogo.FileName
            }
            $dialogo.Dispose()
        }.GetNewClosure())

    $linha.Controls.Add($botao)
    $linha.Controls.Add($texto)
    $linha.Controls.Add($rotuloCampo)
    $Painel.Controls.Add($linha)
    return [PSCustomObject]@{ TextBox = $texto; Botao = $botao }
}

function global:Add-ComboSF {
    param(
        [Parameter(Mandatory)] [System.Windows.Forms.FlowLayoutPanel]$Painel,
        [Parameter(Mandatory)] [string]$Rotulo,
        [string[]]$Opcoes = @(),
        [int]$Largura = 660
    )

    $linha = New-Object System.Windows.Forms.Panel
    $linha.Width = 810
    $linha.Height = 65
    $linha.Margin = [System.Windows.Forms.Padding]::new(0, 0, 0, 3)

    $rotuloCampo = New-Object System.Windows.Forms.Label
    $rotuloCampo.Text = $Rotulo
    $rotuloCampo.AutoSize = $true
    $rotuloCampo.Location = [System.Drawing.Point]::new(0, 2)
    $rotuloCampo.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)

    $lista = New-Object System.Windows.Forms.ComboBox
    $lista.DropDownStyle = 'DropDownList'
    $lista.Width = $Largura
    $lista.Location = [System.Drawing.Point]::new(0, 27)
    $lista.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9)
    foreach ($opcao in $Opcoes) {
        [void]$lista.Items.Add($opcao)
    }
    if ($lista.Items.Count -gt 0) {
        $lista.SelectedIndex = 0
    }

    $linha.Controls.Add($lista)
    $linha.Controls.Add($rotuloCampo)
    $Painel.Controls.Add($linha)
    return $lista
}

function global:Add-ContextoSF {
    param(
        [Parameter(Mandatory)] [System.Windows.Forms.FlowLayoutPanel]$Painel,
        [Parameter(Mandatory)] [string]$Titulo,
        [string]$Texto = ''
    )

    $cartao = New-Object System.Windows.Forms.Panel
    $cartao.Width = 810
    $cartao.Height = 82
    $cartao.Margin = [System.Windows.Forms.Padding]::new(0, 3, 0, 4)
    $cartao.BackColor = [System.Drawing.Color]::FromArgb(240, 247, 252)

    $rotuloTitulo = New-Object System.Windows.Forms.Label
    $rotuloTitulo.Text = $Titulo.ToUpperInvariant()
    $rotuloTitulo.AutoSize = $true
    $rotuloTitulo.Location = [System.Drawing.Point]::new(12, 9)
    $rotuloTitulo.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 8, [System.Drawing.FontStyle]::Bold)
    $rotuloTitulo.ForeColor = [System.Drawing.Color]::FromArgb(25, 118, 210)

    $rotuloTexto = New-Object System.Windows.Forms.Label
    $rotuloTexto.Text = $Texto
    $rotuloTexto.Location = [System.Drawing.Point]::new(12, 29)
    $rotuloTexto.MaximumSize = [System.Drawing.Size]::new(770, 48)
    $rotuloTexto.AutoSize = $true
    $rotuloTexto.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9)
    $rotuloTexto.ForeColor = [System.Drawing.Color]::FromArgb(54, 67, 82)

    $cartao.Controls.Add($rotuloTexto)
    $cartao.Controls.Add($rotuloTitulo)
    $Painel.Controls.Add($cartao)
    return [PSCustomObject]@{ Painel = $cartao; Texto = $rotuloTexto }
}

function global:Add-CaixaMarcacaoSF {
    param(
        [Parameter(Mandatory)] [System.Windows.Forms.FlowLayoutPanel]$Painel,
        [Parameter(Mandatory)] [string]$Texto,
        [bool]$Marcada = $false
    )

    $linha = New-Object System.Windows.Forms.Panel
    $linha.Width = 810
    $linha.Height = 31
    $linha.Margin = [System.Windows.Forms.Padding]::new(0, 0, 0, 1)
    $linha.BackColor = [System.Drawing.Color]::FromArgb(248, 251, 253)

    $caixa = New-Object System.Windows.Forms.CheckBox
    $caixa.Text = $Texto
    $caixa.Checked = $Marcada
    $caixa.AutoSize = $true
    $caixa.Location = [System.Drawing.Point]::new(8, 6)
    $caixa.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9)
    $linha.Controls.Add($caixa)
    $Painel.Controls.Add($linha)
    return $caixa
}

function global:New-PainelOpcoesSF {
    param(
        [Parameter(Mandatory)] [System.Windows.Forms.FlowLayoutPanel]$Painel,
        [string]$Titulo = '2. ESCOLHA UMA RESPOSTA',
        [int]$Altura = 180
    )

    $cartao = New-Object System.Windows.Forms.Panel
    $cartao.Width = 810
    $cartao.Height = $Altura
    $cartao.Margin = [System.Windows.Forms.Padding]::new(0, 3, 0, 3)
    $cartao.BackColor = [System.Drawing.Color]::FromArgb(248, 251, 253)

    $rotulo = New-Object System.Windows.Forms.Label
    $rotulo.Text = $Titulo
    $rotulo.Dock = 'Top'
    $rotulo.Height = 30
    $rotulo.Padding = [System.Windows.Forms.Padding]::new(10, 9, 0, 0)
    $rotulo.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 8, [System.Drawing.FontStyle]::Bold)
    $rotulo.ForeColor = [System.Drawing.Color]::FromArgb(68, 83, 101)

    $opcoes = New-Object System.Windows.Forms.FlowLayoutPanel
    $opcoes.Dock = 'Fill'
    $opcoes.FlowDirection = 'TopDown'
    $opcoes.WrapContents = $false
    $opcoes.AutoScroll = $true
    $opcoes.Padding = [System.Windows.Forms.Padding]::new(10, 3, 10, 6)
    $opcoes.BackColor = [System.Drawing.Color]::FromArgb(248, 251, 253)
    $cartao.Controls.Add($opcoes)
    $cartao.Controls.Add($rotulo)
    $Painel.Controls.Add($cartao)
    return [PSCustomObject]@{ Painel = $cartao; Opcoes = $opcoes }
}

function global:Add-RadioOpcaoSF {
    param(
        [Parameter(Mandatory)] [System.Windows.Forms.FlowLayoutPanel]$Painel,
        [Parameter(Mandatory)] [string]$Texto
    )

    $radio = New-Object System.Windows.Forms.RadioButton
    $radio.Text = $Texto
    $radio.AutoSize = $true
    $radio.MaximumSize = [System.Drawing.Size]::new(750, 0)
    $radio.Padding = [System.Windows.Forms.Padding]::new(2, 3, 2, 3)
    $radio.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9)
    $Painel.Controls.Add($radio)
    return $radio
}

function global:Mostrar-ResultadoSF {
    param(
        [Parameter(Mandatory)] [psobject]$Ui,
        [Parameter(Mandatory)] [string]$Texto,
        [ValidateSet('Info', 'Sucesso', 'Atencao', 'Erro')] [string]$Tipo = 'Info'
    )

    $corStatus = [System.Drawing.Color]::FromArgb(25, 118, 210)
    $corFundo = [System.Drawing.Color]::FromArgb(20, 32, 45)
    $corTexto = [System.Drawing.Color]::FromArgb(224, 242, 254)
    $rotulo = 'ANÁLISE CONCLUÍDA'
    switch ($Tipo) {
        'Sucesso' {
            $corStatus = [System.Drawing.Color]::FromArgb(18, 120, 84)
            $corFundo = [System.Drawing.Color]::FromArgb(19, 52, 44)
            $corTexto = [System.Drawing.Color]::FromArgb(219, 255, 239)
        }
        'Atencao' {
            $corStatus = [System.Drawing.Color]::FromArgb(203, 124, 0)
            $corFundo = [System.Drawing.Color]::FromArgb(66, 48, 14)
            $corTexto = [System.Drawing.Color]::FromArgb(255, 241, 199)
            $rotulo = 'ATENÇÃO AO RESULTADO'
        }
        'Erro' {
            $corStatus = [System.Drawing.Color]::FromArgb(198, 40, 40)
            $corFundo = [System.Drawing.Color]::FromArgb(72, 28, 31)
            $corTexto = [System.Drawing.Color]::FromArgb(255, 220, 220)
            $rotulo = 'VERIFIQUE OS DADOS'
        }
    }

    $Ui.Saida.BackColor = $corFundo
    $Ui.Saida.ForeColor = $corTexto
    $Ui.Saida.Text = $Texto.Trim()
    $Ui.Saida.SelectionStart = $Ui.Saida.TextLength
    $Ui.Saida.ScrollToCaret()
    $Ui.Status.Text = $rotulo
    $Ui.Status.ForeColor = $corStatus
    $Ui.Progresso.Value = 100
}

function global:Limpar-ResultadoSF {
    param([Parameter(Mandatory)] [psobject]$Ui)

    $Ui.Saida.BackColor = [System.Drawing.Color]::FromArgb(20, 32, 45)
    $Ui.Saida.ForeColor = [System.Drawing.Color]::FromArgb(224, 242, 254)
    $Ui.Saida.Text = 'Pronto para uma nova análise.'
    $Ui.Status.Text = 'PRONTO PARA COMEÇAR'
    $Ui.Status.ForeColor = [System.Drawing.Color]::FromArgb(25, 118, 210)
    $Ui.Progresso.Value = 0
}

function global:Invoke-AtividadeSF {
    param(
        [Parameter(Mandatory)] [string]$ScriptPath,
        [Parameter(Mandatory)] [hashtable]$Parametros,
        [Parameter(Mandatory)] [psobject]$Ui,
        [Parameter(Mandatory)] [string]$NomeAtividade
    )

    $novaLinha = [Environment]::NewLine
    if (-not (Test-Path -LiteralPath $ScriptPath -PathType Leaf)) {
        Mostrar-ResultadoSF -Ui $Ui -Tipo Erro -Texto ('Não encontrei o script da atividade:' + $novaLinha + $ScriptPath)
        return
    }

    $Ui.Status.Text = 'ANALISANDO O CENÁRIO...'
    $Ui.Status.ForeColor = [System.Drawing.Color]::FromArgb(25, 118, 210)
    $Ui.Progresso.Value = 35
    [System.Windows.Forms.Application]::DoEvents()

    try {
        $resultado = @(& $ScriptPath @Parametros *>&1)
        $texto = ($resultado | Out-String -Width 240).Trim()
        $temErro = @($resultado | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }).Count -gt 0
        if ([string]::IsNullOrWhiteSpace($texto)) {
            $texto = 'A atividade terminou sem retornar texto.'
        }

        if ($temErro) {
            Mostrar-ResultadoSF -Ui $Ui -Tipo Erro -Texto ($texto + $novaLinha + $novaLinha + 'Revise o arquivo selecionado e tente novamente.')
            return
        }

        $cabecalho = $NomeAtividade + $novaLinha + ('=' * $NomeAtividade.Length)
        Mostrar-ResultadoSF -Ui $Ui -Tipo Sucesso -Texto ($cabecalho + $novaLinha + $novaLinha + $texto)
    }
    catch {
        Mostrar-ResultadoSF -Ui $Ui -Tipo Erro -Texto ('Não foi possível executar a atividade.' + $novaLinha + $novaLinha + $_.Exception.Message)
    }
}

function global:Abrir-RoteiroSF {
    param(
        [Parameter(Mandatory)] [string]$Caminho,
        [Parameter(Mandatory)] [psobject]$Ui
    )

    if (-not (Test-Path -LiteralPath $Caminho -PathType Leaf)) {
        Mostrar-ResultadoSF -Ui $Ui -Tipo Erro -Texto ('Roteiro não encontrado: ' + $Caminho)
        return
    }
    Start-Process -FilePath notepad.exe -ArgumentList (('"{0}"' -f $Caminho))
}

function global:Abrir-PastaSF {
    param(
        [Parameter(Mandatory)] [string]$Caminho,
        [Parameter(Mandatory)] [psobject]$Ui
    )

    if (-not (Test-Path -LiteralPath $Caminho -PathType Container)) {
        Mostrar-ResultadoSF -Ui $Ui -Tipo Erro -Texto ('Pasta não encontrada: ' + $Caminho)
        return
    }
    Start-Process -FilePath explorer.exe -ArgumentList (('"{0}"' -f $Caminho))
}

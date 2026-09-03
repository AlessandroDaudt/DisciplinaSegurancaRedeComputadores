[CmdletBinding()]
param()

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

function New-InterfaceDidatica {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Titulo,

        [Parameter(Mandatory)]
        [string]$Subtitulo,

        [Parameter(Mandatory)]
        [string]$Objetivo,

        [Parameter(Mandatory)]
        [string[]]$Passos,

        [string]$TextoExecutar = 'Executar atividade',

        [string]$Aviso = 'Use apenas arquivos de teste e realize o exercício em ambiente autorizado.'
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Titulo
    $form.StartPosition = 'CenterScreen'
    $form.Size = New-Object System.Drawing.Size(1020, 740)
    $form.MinimumSize = New-Object System.Drawing.Size(860, 620)
    $form.BackColor = [System.Drawing.Color]::WhiteSmoke

    $fonteNormal = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9)
    $fonteTitulo = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
    $fonteSubtitulo = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9)
    $fonteSaida = New-Object System.Drawing.Font -ArgumentList @('Consolas', 9)

    $cabecalho = New-Object System.Windows.Forms.Panel
    $cabecalho.Dock = 'Top'
    $cabecalho.Height = 90
    $cabecalho.BackColor = [System.Drawing.Color]::FromArgb(31, 78, 121)

    $rotuloTitulo = New-Object System.Windows.Forms.Label
    $rotuloTitulo.Text = $Titulo
    $rotuloTitulo.ForeColor = [System.Drawing.Color]::White
    $rotuloTitulo.Font = $fonteTitulo
    $rotuloTitulo.AutoSize = $true
    $rotuloTitulo.Location = New-Object System.Drawing.Point(22, 14)

    $rotuloSubtitulo = New-Object System.Windows.Forms.Label
    $rotuloSubtitulo.Text = $Subtitulo
    $rotuloSubtitulo.ForeColor = [System.Drawing.Color]::WhiteSmoke
    $rotuloSubtitulo.Font = $fonteSubtitulo
    $rotuloSubtitulo.AutoSize = $true
    $rotuloSubtitulo.MaximumSize = New-Object System.Drawing.Size(940, 40)
    $rotuloSubtitulo.Location = New-Object System.Drawing.Point(24, 51)

    $cabecalho.Controls.Add($rotuloTitulo)
    $cabecalho.Controls.Add($rotuloSubtitulo)

    $grupoObjetivo = New-Object System.Windows.Forms.GroupBox
    $grupoObjetivo.Text = 'Objetivo'
    $grupoObjetivo.Dock = 'Top'
    $grupoObjetivo.Height = 78
    $grupoObjetivo.Padding = New-Object System.Windows.Forms.Padding(12, 19, 12, 8)
    $grupoObjetivo.Font = $fonteNormal

    $campoObjetivo = New-Object System.Windows.Forms.TextBox
    $campoObjetivo.Text = $Objetivo
    $campoObjetivo.Dock = 'Fill'
    $campoObjetivo.Multiline = $true
    $campoObjetivo.ReadOnly = $true
    $campoObjetivo.BorderStyle = 'None'
    $campoObjetivo.BackColor = [System.Drawing.Color]::White
    $campoObjetivo.Font = $fonteNormal
    $grupoObjetivo.Controls.Add($campoObjetivo)

    $grupoPassos = New-Object System.Windows.Forms.GroupBox
    $grupoPassos.Text = 'Como fazer'
    $grupoPassos.Dock = 'Top'
    $grupoPassos.Height = 112
    $grupoPassos.Padding = New-Object System.Windows.Forms.Padding(12, 19, 12, 8)
    $grupoPassos.Font = $fonteNormal

    $campoPassos = New-Object System.Windows.Forms.TextBox
    $campoPassos.Text = (($Passos | ForEach-Object -Begin { $numero = 0 } -Process { $numero++; "$numero. $_" }) -join [Environment]::NewLine)
    $campoPassos.Dock = 'Fill'
    $campoPassos.Multiline = $true
    $campoPassos.ReadOnly = $true
    $campoPassos.BorderStyle = 'None'
    $campoPassos.BackColor = [System.Drawing.Color]::White
    $campoPassos.Font = $fonteNormal
    $grupoPassos.Controls.Add($campoPassos)

    $grupoCampos = New-Object System.Windows.Forms.GroupBox
    $grupoCampos.Text = 'Dados para o laboratório'
    $grupoCampos.Dock = 'Top'
    $grupoCampos.Height = 210
    $grupoCampos.Padding = New-Object System.Windows.Forms.Padding(10, 20, 10, 8)
    $grupoCampos.Font = $fonteNormal

    $campos = New-Object System.Windows.Forms.FlowLayoutPanel
    $campos.Dock = 'Fill'
    $campos.FlowDirection = 'TopDown'
    $campos.WrapContents = $false
    $campos.AutoScroll = $true
    $campos.BackColor = [System.Drawing.Color]::White
    $grupoCampos.Controls.Add($campos)

    $botoes = New-Object System.Windows.Forms.FlowLayoutPanel
    $botoes.Dock = 'Top'
    $botoes.Height = 57
    $botoes.WrapContents = $false
    $botoes.FlowDirection = 'LeftToRight'
    $botoes.Padding = New-Object System.Windows.Forms.Padding(12, 9, 12, 6)
    $botoes.BackColor = [System.Drawing.Color]::WhiteSmoke

    $botaoExecutar = New-Object System.Windows.Forms.Button
    $botaoExecutar.Text = $TextoExecutar
    $botaoExecutar.Width = 175
    $botaoExecutar.Height = 34
    $botaoExecutar.BackColor = [System.Drawing.Color]::FromArgb(46, 125, 50)
    $botaoExecutar.ForeColor = [System.Drawing.Color]::White
    $botaoExecutar.FlatStyle = 'Flat'

    $botaoRoteiro = New-Object System.Windows.Forms.Button
    $botaoRoteiro.Text = 'Abrir roteiro'
    $botaoRoteiro.Width = 120
    $botaoRoteiro.Height = 34

    $botaoDados = New-Object System.Windows.Forms.Button
    $botaoDados.Text = 'Abrir pasta'
    $botaoDados.Width = 105
    $botaoDados.Height = 34

    $botaoLimpar = New-Object System.Windows.Forms.Button
    $botaoLimpar.Text = 'Limpar saída'
    $botaoLimpar.Width = 110
    $botaoLimpar.Height = 34

    $botoes.Controls.Add($botaoExecutar)
    $botoes.Controls.Add($botaoRoteiro)
    $botoes.Controls.Add($botaoDados)
    $botoes.Controls.Add($botaoLimpar)

    $rotuloSaida = New-Object System.Windows.Forms.Label
    $rotuloSaida.Text = 'RESULTADO DA ATIVIDADE'
    $rotuloSaida.Dock = 'Top'
    $rotuloSaida.Height = 24
    $rotuloSaida.Padding = New-Object System.Windows.Forms.Padding(12, 5, 0, 0)
    $rotuloSaida.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)

    $saida = New-Object System.Windows.Forms.TextBox
    $saida.Dock = 'Fill'
    $saida.Multiline = $true
    $saida.ReadOnly = $true
    $saida.ScrollBars = 'Both'
    $saida.WordWrap = $false
    $saida.Font = $fonteSaida
    $saida.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $saida.ForeColor = [System.Drawing.Color]::FromArgb(222, 240, 222)

    $rodape = New-Object System.Windows.Forms.Label
    $rodape.Text = $Aviso
    $rodape.Dock = 'Bottom'
    $rodape.Height = 26
    $rodape.Padding = New-Object System.Windows.Forms.Padding(12, 5, 0, 0)
    $rodape.ForeColor = [System.Drawing.Color]::DimGray
    $rodape.Font = $fonteNormal

    $form.Controls.Add($saida)
    $form.Controls.Add($rotuloSaida)
    $form.Controls.Add($botoes)
    $form.Controls.Add($grupoCampos)
    $form.Controls.Add($grupoPassos)
    $form.Controls.Add($grupoObjetivo)
    $form.Controls.Add($cabecalho)
    $form.Controls.Add($rodape)

    return [PSCustomObject]@{
        Form           = $form
        Campos         = $campos
        Saida          = $saida
        BotaoExecutar  = $botaoExecutar
        BotaoRoteiro   = $botaoRoteiro
        BotaoDados     = $botaoDados
        BotaoLimpar    = $botaoLimpar
        Botoes         = $botoes
        GrupoCampos    = $grupoCampos
    }
}

function Add-CampoArquivo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Windows.Forms.FlowLayoutPanel]$Painel,

        [Parameter(Mandatory)]
        [string]$Rotulo,

        [string]$ValorInicial,

        [string]$Filtro = 'Todos os arquivos (*.*)|*.*',

        [string]$TituloSelecao = 'Selecione um arquivo'
    )

    $linha = New-Object System.Windows.Forms.Panel
    $linha.Width = 900
    $linha.Height = 58

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Rotulo
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(2, 4)

    $texto = New-Object System.Windows.Forms.TextBox
    $texto.Text = $ValorInicial
    $texto.Width = 700
    $texto.Location = New-Object System.Drawing.Point(2, 24)

    $botao = New-Object System.Windows.Forms.Button
    $botao.Text = 'Selecionar...'
    $botao.Width = 115
    $botao.Height = 25
    $botao.Location = New-Object System.Drawing.Point(712, 23)

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

    $linha.Controls.Add($label)
    $linha.Controls.Add($texto)
    $linha.Controls.Add($botao)
    $Painel.Controls.Add($linha)

    return [PSCustomObject]@{
        TextBox = $texto
        Botao   = $botao
    }
}

function Add-CampoPasta {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Windows.Forms.FlowLayoutPanel]$Painel,

        [Parameter(Mandatory)]
        [string]$Rotulo,

        [string]$ValorInicial,

        [string]$Descricao = 'Selecione uma pasta'
    )

    $linha = New-Object System.Windows.Forms.Panel
    $linha.Width = 900
    $linha.Height = 58

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Rotulo
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(2, 4)

    $texto = New-Object System.Windows.Forms.TextBox
    $texto.Text = $ValorInicial
    $texto.Width = 700
    $texto.Location = New-Object System.Drawing.Point(2, 24)

    $botao = New-Object System.Windows.Forms.Button
    $botao.Text = 'Selecionar...'
    $botao.Width = 115
    $botao.Height = 25
    $botao.Location = New-Object System.Drawing.Point(712, 23)

    $descricaoPasta = $Descricao
    $botao.Add_Click({
            $dialogo = New-Object System.Windows.Forms.FolderBrowserDialog
            $dialogo.Description = $descricaoPasta
            $dialogo.SelectedPath = $texto.Text
            if ($dialogo.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $texto.Text = $dialogo.SelectedPath
            }
            $dialogo.Dispose()
        }.GetNewClosure())

    $linha.Controls.Add($label)
    $linha.Controls.Add($texto)
    $linha.Controls.Add($botao)
    $Painel.Controls.Add($linha)

    return [PSCustomObject]@{
        TextBox = $texto
        Botao   = $botao
    }
}

function Add-CampoMultiplosArquivos {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Windows.Forms.FlowLayoutPanel]$Painel,

        [Parameter(Mandatory)]
        [string]$Rotulo,

        [string[]]$ValoresIniciais,

        [string]$Filtro = 'Todos os arquivos (*.*)|*.*'
    )

    $linha = New-Object System.Windows.Forms.Panel
    $linha.Width = 900
    $linha.Height = 118

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Rotulo
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(2, 4)

    $lista = New-Object System.Windows.Forms.ListBox
    $lista.Width = 700
    $lista.Height = 82
    $lista.HorizontalScrollbar = $true
    $lista.Location = New-Object System.Drawing.Point(2, 24)
    foreach ($valor in $ValoresIniciais) {
        if (-not [string]::IsNullOrWhiteSpace($valor)) {
            [void]$lista.Items.Add($valor)
        }
    }

    $botaoSelecionar = New-Object System.Windows.Forms.Button
    $botaoSelecionar.Text = 'Selecionar...'
    $botaoSelecionar.Width = 115
    $botaoSelecionar.Height = 27
    $botaoSelecionar.Location = New-Object System.Drawing.Point(712, 24)

    $botaoRemover = New-Object System.Windows.Forms.Button
    $botaoRemover.Text = 'Remover'
    $botaoRemover.Width = 115
    $botaoRemover.Height = 27
    $botaoRemover.Location = New-Object System.Drawing.Point(712, 59)

    $filtroArquivo = $Filtro
    $botaoSelecionar.Add_Click({
            $dialogo = New-Object System.Windows.Forms.OpenFileDialog
            $dialogo.Title = 'Selecione um ou mais arquivos'
            $dialogo.Filter = $filtroArquivo
            $dialogo.CheckFileExists = $true
            $dialogo.Multiselect = $true
            if ($dialogo.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $lista.Items.Clear()
                foreach ($arquivo in $dialogo.FileNames) {
                    [void]$lista.Items.Add($arquivo)
                }
            }
            $dialogo.Dispose()
        }.GetNewClosure())

    $botaoRemover.Add_Click({
            if ($lista.SelectedIndex -ge 0) {
                $lista.Items.RemoveAt($lista.SelectedIndex)
            }
        }.GetNewClosure())

    $linha.Controls.Add($label)
    $linha.Controls.Add($lista)
    $linha.Controls.Add($botaoSelecionar)
    $linha.Controls.Add($botaoRemover)
    $Painel.Controls.Add($linha)

    return [PSCustomObject]@{
        Lista            = $lista
        BotaoSelecionar  = $botaoSelecionar
        BotaoRemover     = $botaoRemover
    }
}

function Add-CampoTexto {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Windows.Forms.FlowLayoutPanel]$Painel,

        [Parameter(Mandatory)]
        [string]$Rotulo,

        [string]$ValorInicial,

        [switch]$OcultarTexto
    )

    $linha = New-Object System.Windows.Forms.Panel
    $linha.Width = 900
    $linha.Height = 58

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Rotulo
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(2, 4)

    $texto = New-Object System.Windows.Forms.TextBox
    $texto.Text = $ValorInicial
    $texto.Width = 500
    $texto.Location = New-Object System.Drawing.Point(2, 24)
    $texto.UseSystemPasswordChar = [bool]$OcultarTexto

    $linha.Controls.Add($label)
    $linha.Controls.Add($texto)
    $Painel.Controls.Add($linha)

    return $texto
}

function Add-CampoLista {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Windows.Forms.FlowLayoutPanel]$Painel,

        [Parameter(Mandatory)]
        [string]$Rotulo,

        [Parameter(Mandatory)]
        [string[]]$Opcoes,

        [string]$Selecionado
    )

    $linha = New-Object System.Windows.Forms.Panel
    $linha.Width = 900
    $linha.Height = 58

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Rotulo
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(2, 4)

    $lista = New-Object System.Windows.Forms.ComboBox
    $lista.DropDownStyle = 'DropDownList'
    $lista.Width = 220
    $lista.Location = New-Object System.Drawing.Point(2, 24)
    [void]$lista.Items.AddRange([object[]]$Opcoes)
    if ([string]::IsNullOrWhiteSpace($Selecionado)) {
        $lista.SelectedIndex = 0
    }
    else {
        $lista.SelectedItem = $Selecionado
    }

    $linha.Controls.Add($label)
    $linha.Controls.Add($lista)
    $Painel.Controls.Add($linha)

    return $lista
}

function Add-CaixaMarcacao {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Windows.Forms.FlowLayoutPanel]$Painel,

        [Parameter(Mandatory)]
        [string]$Texto,

        [bool]$Marcada = $false
    )

    $caixa = New-Object System.Windows.Forms.CheckBox
    $caixa.Text = $Texto
    $caixa.Checked = $Marcada
    $caixa.AutoSize = $true
    $caixa.Padding = New-Object System.Windows.Forms.Padding(2, 4, 2, 2)
    $caixa.MaximumSize = New-Object System.Drawing.Size(860, 42)
    $Painel.Controls.Add($caixa)

    return $caixa
}

function Add-NotaDidatica {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Windows.Forms.FlowLayoutPanel]$Painel,

        [Parameter(Mandatory)]
        [string]$Texto
    )

    $nota = New-Object System.Windows.Forms.Label
    $nota.Text = $Texto
    $nota.AutoSize = $true
    $nota.ForeColor = [System.Drawing.Color]::DimGray
    $nota.MaximumSize = New-Object System.Drawing.Size(850, 0)
    $nota.Padding = New-Object System.Windows.Forms.Padding(2, 3, 2, 3)
    $Painel.Controls.Add($nota)
}

function Set-SaidaDaAtividade {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Windows.Forms.TextBox]$Saida,

        [Parameter(Mandatory)]
        [string]$Texto,

        [switch]$Erro
    )

    $Saida.Clear()
    if ($Erro) {
        $Saida.ForeColor = [System.Drawing.Color]::FromArgb(255, 195, 195)
    }
    else {
        $Saida.ForeColor = [System.Drawing.Color]::FromArgb(222, 240, 222)
    }
    $Saida.AppendText($Texto)
    $Saida.SelectionStart = $Saida.TextLength
    $Saida.ScrollToCaret()
}

function Invoke-AtividadeComSaida {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ScriptPath,

        [Parameter(Mandatory)]
        [hashtable]$Parametros,

        [Parameter(Mandatory)]
        [System.Windows.Forms.TextBox]$Saida,

        [Parameter(Mandatory)]
        [string]$NomeAtividade
    )

    if (-not (Test-Path -LiteralPath $ScriptPath)) {
        Set-SaidaDaAtividade -Saida $Saida -Erro -Texto ("Arquivo da atividade não encontrado:" + [Environment]::NewLine + $ScriptPath)
        return
    }

    Set-SaidaDaAtividade -Saida $Saida -Texto ("Executando: $NomeAtividade..." + [Environment]::NewLine + [Environment]::NewLine)
    [System.Windows.Forms.Application]::DoEvents()

    try {
        $resultado = @(& $ScriptPath @Parametros *>&1)
        $texto = ($resultado | Out-String -Width 320).Trim()
        $temErro = @($resultado | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }).Count -gt 0

        if ([string]::IsNullOrWhiteSpace($texto)) {
            $texto = 'A atividade terminou sem retornar texto.'
        }

        if ($temErro) {
            Set-SaidaDaAtividade -Saida $Saida -Erro -Texto ($texto + [Environment]::NewLine + [Environment]::NewLine + 'A atividade apresentou uma mensagem de erro. Revise o arquivo selecionado e tente novamente.')
        }
        else {
            Set-SaidaDaAtividade -Saida $Saida -Texto ($texto + [Environment]::NewLine + [Environment]::NewLine + 'Atividade concluída.')
        }
    }
    catch {
        Set-SaidaDaAtividade -Saida $Saida -Erro -Texto ('Não foi possível executar a atividade.' + [Environment]::NewLine + $_.Exception.Message)
    }
}

function Abrir-DocumentoDidatico {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Caminho,

        [Parameter(Mandatory)]
        [System.Windows.Forms.TextBox]$Saida
    )

    if (-not (Test-Path -LiteralPath $Caminho)) {
        Set-SaidaDaAtividade -Saida $Saida -Erro -Texto ('Roteiro não encontrado:' + [Environment]::NewLine + $Caminho)
        return
    }

    Start-Process -FilePath notepad.exe -ArgumentList @(('"{0}"' -f $Caminho))
}

function Abrir-PastaDidatica {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Caminho,

        [Parameter(Mandatory)]
        [System.Windows.Forms.TextBox]$Saida
    )

    if (-not (Test-Path -LiteralPath $Caminho)) {
        Set-SaidaDaAtividade -Saida $Saida -Erro -Texto ('Pasta não encontrada:' + [Environment]::NewLine + $Caminho)
        return
    }

    Start-Process -FilePath explorer.exe -ArgumentList @(('"{0}"' -f $Caminho))
}

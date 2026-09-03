[CmdletBinding()]
param()

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

$script:repositorio = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($script:repositorio)) {
    $script:repositorio = (Get-Location).Path
}

$script:atividades = @(
    [PSCustomObject]@{
        Numero = 1
        Nome = 'Auditoria da triade CIA'
        Topico = 'Topico 01 - Fundamentos e CIA'
        Objetivo = 'Observar confidencialidade, integridade e disponibilidade em arquivos locais de teste.'
        ComoUsar = 'Execute a verificacao e discuta qual controle poderia reduzir o risco observado em cada dimensao.'
        ScriptRelativo = 'topico-01-fundamentos-e-cia\atividade-01-auditoria-cia.ps1'
        ReadmeRelativo = 'topico-01-fundamentos-e-cia\README.md'
        Interativa = $false
    }
    [PSCustomObject]@{
        Numero = 2
        Nome = 'Hash e integridade'
        Topico = 'Topico 02 - Integridade e hash'
        Objetivo = 'Calcular SHA-256 e verificar se um arquivo de teste foi alterado.'
        ComoUsar = 'Na primeira execucao uma referencia e criada. Altere uma palavra no arquivo e execute novamente.'
        ScriptRelativo = 'topico-02-integridade-e-hash\atividade-02-hash-integridade.ps1'
        ReadmeRelativo = 'topico-02-integridade-e-hash\README.md'
        Interativa = $false
    }
    [PSCustomObject]@{
        Numero = 3
        Nome = 'Monitoramento de alteracoes'
        Topico = 'Topico 02 - Integridade e hash'
        Objetivo = 'Criar uma linha de base e identificar arquivos novos, modificados ou removidos.'
        ComoUsar = 'Execute uma vez para criar a referencia, altere a pasta dados e execute novamente.'
        ScriptRelativo = 'topico-02-integridade-e-hash\atividade-03-monitoramento-alteracoes.ps1'
        ReadmeRelativo = 'topico-02-integridade-e-hash\README.md'
        Interativa = $false
    }
    [PSCustomObject]@{
        Numero = 4
        Nome = 'Criptografia simetrica'
        Topico = 'Topico 03 - Criptografia'
        Objetivo = 'Proteger e recuperar uma mensagem usando AES e a mesma senha de laboratorio.'
        ComoUsar = 'O modo Demonstrar cifra e decifra automaticamente o arquivo de teste.'
        ScriptRelativo = 'topico-03-criptografia\atividade-04-criptografia-simetrica.ps1'
        ReadmeRelativo = 'topico-03-criptografia\README.md'
        Interativa = $false
    }
    [PSCustomObject]@{
        Numero = 5
        Nome = 'Criptografia assimetrica'
        Topico = 'Topico 03 - Criptografia'
        Objetivo = 'Demonstrar o uso de chave publica e chave privada com um certificado de laboratorio.'
        ComoUsar = 'O script cria ou reutiliza um certificado no repositorio do usuario atual, sem exigir administrador.'
        ScriptRelativo = 'topico-03-criptografia\atividade-05-criptografia-assimetrica.ps1'
        ReadmeRelativo = 'topico-03-criptografia\README.md'
        Interativa = $false
    }
    [PSCustomObject]@{
        Numero = 6
        Nome = 'Autenticidade e assinatura'
        Topico = 'Topico 04 - Autenticidade e responsabilizacao'
        Objetivo = 'Consultar assinaturas Authenticode e observar o status de autenticidade de arquivos.'
        ComoUsar = 'O script apenas consulta o script de teste e o executavel do Windows PowerShell.'
        ScriptRelativo = 'topico-04-autenticidade-e-responsabilizacao\atividade-06-autenticidade-assinatura.ps1'
        ReadmeRelativo = 'topico-04-autenticidade-e-responsabilizacao\README.md'
        Interativa = $false
    }
    [PSCustomObject]@{
        Numero = 7
        Nome = 'Logs e analise forense'
        Topico = 'Topico 04 - Autenticidade e responsabilizacao'
        Objetivo = 'Organizar eventos sinteticos, agrupar falhas de logon e destacar indicadores.'
        ComoUsar = 'Analise usuario, origem, horario, acao e resultado na linha do tempo gerada.'
        ScriptRelativo = 'topico-04-autenticidade-e-responsabilizacao\atividade-07-logs-e-forense.ps1'
        ReadmeRelativo = 'topico-04-autenticidade-e-responsabilizacao\README.md'
        Interativa = $false
    }
    [PSCustomObject]@{
        Numero = 8
        Nome = 'Ameaca, ataque ou vulnerabilidade'
        Topico = 'Topico 05 - Ameacas, ataques e mini-SOC'
        Objetivo = 'Classificar cenarios de seguranca e receber feedback imediato.'
        ComoUsar = 'Esta atividade pede respostas no console do ISE. Use o botao para abrir o script e responda quando solicitado.'
        ScriptRelativo = 'topico-05-ameacas-ataques-e-mini-soc\atividade-08-classificacao-seguranca.ps1'
        ReadmeRelativo = 'topico-05-ameacas-ataques-e-mini-soc\README.md'
        Interativa = $true
    }
    [PSCustomObject]@{
        Numero = 9
        Nome = 'Mini-SOC em PowerShell'
        Topico = 'Topico 05 - Ameacas, ataques e mini-SOC'
        Objetivo = 'Reunir indicadores, hash de evidencia e prioridade em um relatorio de triagem.'
        ComoUsar = 'A interface executa o modo didatico com dados sinteticos. A coleta opcional do host nao e acionada.'
        ScriptRelativo = 'topico-05-ameacas-ataques-e-mini-soc\atividade-09-mini-soc.ps1'
        ReadmeRelativo = 'topico-05-ameacas-ataques-e-mini-soc\README.md'
        Interativa = $false
    }
)

foreach ($atividade in $script:atividades) {
    $atividade | Add-Member -MemberType NoteProperty -Name ScriptPath -Value (Join-Path $script:repositorio $atividade.ScriptRelativo)
    $atividade | Add-Member -MemberType NoteProperty -Name ReadmePath -Value (Join-Path $script:repositorio $atividade.ReadmeRelativo)
}

$script:atividadeAtual = $null

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Laboratorio de Seguranca de Redes de Computadores'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(1000, 680)
$form.MinimumSize = New-Object System.Drawing.Size(850, 560)
$form.BackColor = [System.Drawing.Color]::WhiteSmoke

$fonteNormal = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9)
$fonteTitulo = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
$fonteSubtitulo = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9)
$fonteSaida = New-Object System.Drawing.Font -ArgumentList @('Consolas', 9)

$cabecalho = New-Object System.Windows.Forms.Panel
$cabecalho.Dock = 'Top'
$cabecalho.Height = 86
$cabecalho.BackColor = [System.Drawing.Color]::FromArgb(31, 78, 121)

$titulo = New-Object System.Windows.Forms.Label
$titulo.Text = 'Laboratorio de Seguranca de Redes de Computadores'
$titulo.ForeColor = [System.Drawing.Color]::White
$titulo.Font = $fonteTitulo
$titulo.AutoSize = $true
$titulo.Location = New-Object System.Drawing.Point(22, 14)

$subtitulo = New-Object System.Windows.Forms.Label
$subtitulo.Text = 'Selecione uma atividade. Os laboratorios usam arquivos de teste e nao exigem administrador.'
$subtitulo.ForeColor = [System.Drawing.Color]::WhiteSmoke
$subtitulo.Font = $fonteSubtitulo
$subtitulo.AutoSize = $true
$subtitulo.Location = New-Object System.Drawing.Point(25, 52)

$cabecalho.Controls.Add($titulo)
$cabecalho.Controls.Add($subtitulo)

$painelEsquerdo = New-Object System.Windows.Forms.Panel
$painelEsquerdo.Dock = 'Left'
$painelEsquerdo.Width = 330
$painelEsquerdo.Padding = New-Object System.Windows.Forms.Padding(12)
$painelEsquerdo.BackColor = [System.Drawing.Color]::White

$rotuloAtividades = New-Object System.Windows.Forms.Label
$rotuloAtividades.Text = 'ATIVIDADES'
$rotuloAtividades.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$rotuloAtividades.AutoSize = $true
$rotuloAtividades.Dock = 'Top'
$rotuloAtividades.Height = 28

$lista = New-Object System.Windows.Forms.ListBox
$lista.Dock = 'Fill'
$lista.Font = $fonteNormal
$lista.IntegralHeight = $false
$lista.HorizontalScrollbar = $true

foreach ($atividade in $script:atividades) {
    [void]$lista.Items.Add(('{0:00} - {1}' -f $atividade.Numero, $atividade.Nome))
}

$painelEsquerdo.Controls.Add($lista)
$painelEsquerdo.Controls.Add($rotuloAtividades)

$painelDireito = New-Object System.Windows.Forms.Panel
$painelDireito.Dock = 'Fill'
$painelDireito.Padding = New-Object System.Windows.Forms.Padding(16, 12, 16, 12)
$painelDireito.BackColor = [System.Drawing.Color]::WhiteSmoke

$rotuloSelecionado = New-Object System.Windows.Forms.Label
$rotuloSelecionado.Dock = 'Top'
$rotuloSelecionado.Height = 34
$rotuloSelecionado.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 13, [System.Drawing.FontStyle]::Bold)

$rotuloTopico = New-Object System.Windows.Forms.Label
$rotuloTopico.Dock = 'Top'
$rotuloTopico.Height = 25
$rotuloTopico.ForeColor = [System.Drawing.Color]::DimGray
$rotuloTopico.Font = $fonteNormal

$descricao = New-Object System.Windows.Forms.TextBox
$descricao.Dock = 'Top'
$descricao.Height = 112
$descricao.Multiline = $true
$descricao.ReadOnly = $true
$descricao.ScrollBars = 'Vertical'
$descricao.BackColor = [System.Drawing.Color]::White
$descricao.Font = $fonteNormal

$botoes = New-Object System.Windows.Forms.FlowLayoutPanel
$botoes.Dock = 'Top'
$botoes.Height = 88
$botoes.WrapContents = $true
$botoes.FlowDirection = 'LeftToRight'
$botoes.Padding = New-Object System.Windows.Forms.Padding(0, 8, 0, 4)

$btnExecutar = New-Object System.Windows.Forms.Button
$btnExecutar.Text = 'Executar atividade'
$btnExecutar.Width = 150
$btnExecutar.Height = 34
$btnExecutar.BackColor = [System.Drawing.Color]::FromArgb(46, 125, 50)
$btnExecutar.ForeColor = [System.Drawing.Color]::White
$btnExecutar.FlatStyle = 'Flat'

$btnAbrirScript = New-Object System.Windows.Forms.Button
$btnAbrirScript.Text = 'Abrir script no ISE'
$btnAbrirScript.Width = 150
$btnAbrirScript.Height = 34

$btnAbrirRoteiro = New-Object System.Windows.Forms.Button
$btnAbrirRoteiro.Text = 'Abrir roteiro'
$btnAbrirRoteiro.Width = 120
$btnAbrirRoteiro.Height = 34

$btnAbrirPasta = New-Object System.Windows.Forms.Button
$btnAbrirPasta.Text = 'Abrir pasta'
$btnAbrirPasta.Width = 105
$btnAbrirPasta.Height = 34

$btnLimpar = New-Object System.Windows.Forms.Button
$btnLimpar.Text = 'Limpar saida'
$btnLimpar.Width = 105
$btnLimpar.Height = 34

$botoes.Controls.Add($btnExecutar)
$botoes.Controls.Add($btnAbrirScript)
$botoes.Controls.Add($btnAbrirRoteiro)
$botoes.Controls.Add($btnAbrirPasta)
$botoes.Controls.Add($btnLimpar)

$rotuloSaida = New-Object System.Windows.Forms.Label
$rotuloSaida.Text = 'SAIDA DA ATIVIDADE'
$rotuloSaida.Dock = 'Top'
$rotuloSaida.Height = 25
$rotuloSaida.Font = New-Object System.Drawing.Font -ArgumentList @('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)

$saida = New-Object System.Windows.Forms.TextBox
$saida.Dock = 'Fill'
$saida.Multiline = $true
$saida.ReadOnly = $true
$saida.ScrollBars = 'Both'
$saida.WordWrap = $false
$saida.Font = $fonteSaida
$saida.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$saida.ForeColor = [System.Drawing.Color]::FromArgb(210, 240, 210)

$rodape = New-Object System.Windows.Forms.Label
$rodape.Text = 'Execucao local: nenhum botao altera politicas, servicos ou permissoes do Windows.'
$rodape.Dock = 'Bottom'
$rodape.Height = 26
$rodape.ForeColor = [System.Drawing.Color]::DimGray
$rodape.TextAlign = 'MiddleLeft'

$painelDireito.Controls.Add($saida)
$painelDireito.Controls.Add($rotuloSaida)
$painelDireito.Controls.Add($botoes)
$painelDireito.Controls.Add($descricao)
$painelDireito.Controls.Add($rotuloTopico)
$painelDireito.Controls.Add($rotuloSelecionado)
$painelDireito.Controls.Add($rodape)

$form.Controls.Add($painelDireito)
$form.Controls.Add($painelEsquerdo)
$form.Controls.Add($cabecalho)

function Registrar-Saida {
    param([string]$Mensagem)

    $linha = '[{0}] {1}{2}' -f (Get-Date -Format 'HH:mm:ss'), $Mensagem, [Environment]::NewLine
    $script:saida.AppendText($linha)
    $script:saida.SelectionStart = $script:saida.TextLength
    $script:saida.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

function Atualizar-Atividade {
    if ($lista.SelectedIndex -lt 0) {
        return
    }

    $script:atividadeAtual = $script:atividades[$lista.SelectedIndex]
    $rotuloSelecionado.Text = ('{0:00} - {1}' -f $script:atividadeAtual.Numero, $script:atividadeAtual.Nome)
    $rotuloTopico.Text = $script:atividadeAtual.Topico
    $descricao.Text = "Objetivo:`r`n$($script:atividadeAtual.Objetivo)`r`n`r`nComo usar:`r`n$($script:atividadeAtual.ComoUsar)"

    if ($script:atividadeAtual.Interativa) {
        $btnExecutar.Enabled = $false
        $btnExecutar.Text = 'Responder no ISE'
    }
    else {
        $btnExecutar.Enabled = $true
        $btnExecutar.Text = 'Executar atividade'
    }
}

function Abrir-NoISE {
    param([string]$Caminho)

    if (-not (Test-Path -LiteralPath $Caminho)) {
        Registrar-Saida "Arquivo nao encontrado: $Caminho"
        return
    }

    $caminhoCompleto = [System.IO.Path]::GetFullPath($Caminho)
    if ($host.Name -eq 'Windows PowerShell ISE Host') {
        $arquivoAberto = $psISE.CurrentPowerShellTab.Files |
            Where-Object { $_.FullPath -eq $caminhoCompleto } |
            Select-Object -First 1

        if ($null -eq $arquivoAberto) {
            [void]$psISE.CurrentPowerShellTab.Files.Add($caminhoCompleto)
        }
        else {
            $arquivoAberto.Focus()
        }
        Registrar-Saida "Script aberto no PowerShell ISE: $caminhoCompleto"
    }
    else {
        $ise = Get-Command powershell_ise.exe -ErrorAction SilentlyContinue
        if ($null -ne $ise) {
            Start-Process -FilePath $ise.Source -ArgumentList @('-File', ('"{0}"' -f $caminhoCompleto))
            Registrar-Saida 'PowerShell ISE iniciado com o script selecionado.'
        }
        else {
            Start-Process -FilePath notepad.exe -ArgumentList @(('"{0}"' -f $caminhoCompleto))
            Registrar-Saida 'PowerShell ISE nao foi localizado; o script foi aberto no Bloco de Notas.'
        }
    }
}

function Executar-AtividadeAtual {
    if ($null -eq $script:atividadeAtual) {
        return
    }

    if ($script:atividadeAtual.Interativa) {
        Registrar-Saida 'Esta atividade e interativa. Use o botao Abrir script no ISE para responder aos cenarios.'
        Abrir-NoISE -Caminho $script:atividadeAtual.ScriptPath
        return
    }

    if (-not (Test-Path -LiteralPath $script:atividadeAtual.ScriptPath)) {
        Registrar-Saida "Script nao encontrado: $($script:atividadeAtual.ScriptPath)"
        return
    }

    $arquivoSaida = [System.IO.Path]::GetTempFileName()
    $arquivoErro = [System.IO.Path]::GetTempFileName()

    try {
        $powershell = Get-Command powershell.exe -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -eq $powershell) {
            throw 'Windows PowerShell nao foi localizado.'
        }

        Registrar-Saida "Executando: $($script:atividadeAtual.Nome)"
        $processo = Start-Process `
            -FilePath $powershell.Source `
            -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $script:atividadeAtual.ScriptPath)) `
            -RedirectStandardOutput $arquivoSaida `
            -RedirectStandardError $arquivoErro `
            -WindowStyle Hidden `
            -Wait `
            -PassThru

        $textoSaida = ''
        $textoErro = ''
        if (Test-Path -LiteralPath $arquivoSaida) {
            $textoSaida = [System.IO.File]::ReadAllText($arquivoSaida)
        }
        if (Test-Path -LiteralPath $arquivoErro) {
            $textoErro = [System.IO.File]::ReadAllText($arquivoErro)
        }

        if (-not [string]::IsNullOrWhiteSpace($textoSaida)) {
            Registrar-Saida $textoSaida.TrimEnd()
        }
        if (-not [string]::IsNullOrWhiteSpace($textoErro)) {
            Registrar-Saida "ERRO:`r`n$($textoErro.TrimEnd())"
        }

        if ($processo.ExitCode -eq 0) {
            Registrar-Saida 'Atividade concluida.'
        }
        else {
            Registrar-Saida "Atividade finalizada com codigo $($processo.ExitCode)."
        }
    }
    catch {
        Registrar-Saida "Falha ao executar a atividade: $($_.Exception.Message)"
    }
    finally {
        Remove-Item -LiteralPath $arquivoSaida, $arquivoErro -Force -ErrorAction SilentlyContinue
    }
}

$lista.Add_SelectedIndexChanged({ Atualizar-Atividade }.GetNewClosure())

$btnExecutar.Add_Click({ Executar-AtividadeAtual }.GetNewClosure())

$btnAbrirScript.Add_Click({
        if ($null -ne $script:atividadeAtual) {
            Abrir-NoISE -Caminho $script:atividadeAtual.ScriptPath
        }
    }.GetNewClosure())

$btnAbrirRoteiro.Add_Click({
        if ($null -ne $script:atividadeAtual -and (Test-Path -LiteralPath $script:atividadeAtual.ReadmePath)) {
            Start-Process -FilePath notepad.exe -ArgumentList @(('"{0}"' -f $script:atividadeAtual.ReadmePath))
            Registrar-Saida 'Roteiro aberto no Bloco de Notas.'
        }
        else {
            Registrar-Saida 'README do topico nao foi encontrado.'
        }
    }.GetNewClosure())

$btnAbrirPasta.Add_Click({
        Start-Process -FilePath explorer.exe -ArgumentList @(('"{0}"' -f $script:repositorio))
    }.GetNewClosure())

$btnLimpar.Add_Click({ $saida.Clear() }.GetNewClosure())

$form.Add_Shown({
        $lista.SelectedIndex = 0
        $lista.Focus()
    }.GetNewClosure())

[void]$form.ShowDialog()

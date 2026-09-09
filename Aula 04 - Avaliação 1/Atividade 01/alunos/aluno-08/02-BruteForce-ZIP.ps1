Set-StrictMode -Version Latest

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

if ($PSVersionTable.PSVersion.Major -lt 7) {
    [void][System.Windows.Forms.MessageBox]::Show("Use o PowerShell 7 instalado pelo winget para executar esta ferramenta.", "Dependência ausente")
    exit 1
}

Import-Module (Join-Path $PSScriptRoot "LabAluno.psm1") -Force

$script:StopRequested = $false
$script:FoundPassword = ""

$form = New-Object System.Windows.Forms.Form
$form.Text = "Brute force de ZIP controlado — Atividade 01"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(920, 700)
$form.MinimumSize = New-Object System.Drawing.Size(780, 590)
$form.BackColor = [System.Drawing.Color]::WhiteSmoke

$title = New-Object System.Windows.Forms.Label
$title.Text = "Brute force de ZIP controlado"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(24, 18)
$form.Controls.Add($title)

$note = New-Object System.Windows.Forms.Label
$note.Text = "Selecione somente o ZIP obtido após o login e a wordlist desta pasta."
$note.AutoSize = $true
$note.ForeColor = [System.Drawing.Color]::DarkRed
$note.Location = New-Object System.Drawing.Point(26, 52)
$form.Controls.Add($note)

$zipLabel = New-Object System.Windows.Forms.Label
$zipLabel.Text = "Arquivo ZIP:"
$zipLabel.AutoSize = $true
$zipLabel.Location = New-Object System.Drawing.Point(26, 94)
$form.Controls.Add($zipLabel)

$zipBox = New-Object System.Windows.Forms.TextBox
$zipBox.Location = New-Object System.Drawing.Point(150, 90)
$zipBox.Size = New-Object System.Drawing.Size(610, 24)
$form.Controls.Add($zipBox)

$zipBrowse = New-Object System.Windows.Forms.Button
$zipBrowse.Text = "Selecionar..."
$zipBrowse.Location = New-Object System.Drawing.Point(775, 88)
$zipBrowse.Size = New-Object System.Drawing.Size(120, 28)
$form.Controls.Add($zipBrowse)

$wordlistLabel = New-Object System.Windows.Forms.Label
$wordlistLabel.Text = "Wordlist:"
$wordlistLabel.AutoSize = $true
$wordlistLabel.Location = New-Object System.Drawing.Point(26, 134)
$form.Controls.Add($wordlistLabel)

$wordlistBox = New-Object System.Windows.Forms.TextBox
$wordlistBox.Text = Join-Path $PSScriptRoot "wordlist-zip.txt"
$wordlistBox.Location = New-Object System.Drawing.Point(150, 130)
$wordlistBox.Size = New-Object System.Drawing.Size(610, 24)
$form.Controls.Add($wordlistBox)

$wordlistBrowse = New-Object System.Windows.Forms.Button
$wordlistBrowse.Text = "Selecionar..."
$wordlistBrowse.Location = New-Object System.Drawing.Point(775, 128)
$wordlistBrowse.Size = New-Object System.Drawing.Size(120, 28)
$form.Controls.Add($wordlistBrowse)

$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Text = "Pasta de extração:"
$outputLabel.AutoSize = $true
$outputLabel.Location = New-Object System.Drawing.Point(26, 174)
$form.Controls.Add($outputLabel)

$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Text = Join-Path $PSScriptRoot "extraido"
$outputBox.Location = New-Object System.Drawing.Point(150, 170)
$outputBox.Size = New-Object System.Drawing.Size(610, 24)
$form.Controls.Add($outputBox)

$outputBrowse = New-Object System.Windows.Forms.Button
$outputBrowse.Text = "Selecionar..."
$outputBrowse.Location = New-Object System.Drawing.Point(775, 168)
$outputBrowse.Size = New-Object System.Drawing.Size(120, 28)
$form.Controls.Add($outputBrowse)

$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Iniciar quebra"
$startButton.Location = New-Object System.Drawing.Point(150, 212)
$startButton.Size = New-Object System.Drawing.Size(150, 32)
$form.Controls.Add($startButton)

$stopButton = New-Object System.Windows.Forms.Button
$stopButton.Text = "Parar"
$stopButton.Enabled = $false
$stopButton.Location = New-Object System.Drawing.Point(310, 212)
$stopButton.Size = New-Object System.Drawing.Size(100, 32)
$form.Controls.Add($stopButton)

$extractButton = New-Object System.Windows.Forms.Button
$extractButton.Text = "Extrair conteúdo"
$extractButton.Enabled = $false
$extractButton.Location = New-Object System.Drawing.Point(420, 212)
$extractButton.Size = New-Object System.Drawing.Size(155, 32)
$form.Controls.Add($extractButton)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Aguardando arquivo ZIP."
$statusLabel.AutoSize = $true
$statusLabel.Location = New-Object System.Drawing.Point(595, 220)
$form.Controls.Add($statusLabel)

$output = New-Object System.Windows.Forms.RichTextBox
$output.ReadOnly = $true
$output.BackColor = [System.Drawing.Color]::White
$output.Font = New-Object System.Drawing.Font("Consolas", 10)
$output.Location = New-Object System.Drawing.Point(24, 262)
$output.Size = New-Object System.Drawing.Size(850, 350)
$output.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($output)

$footer = New-Object System.Windows.Forms.Label
$footer.Text = "A ferramenta usa 7z.exe para testar integridade; nenhum arquivo extraído é executado."
$footer.AutoSize = $true
$footer.Location = New-Object System.Drawing.Point(26, 632)
$footer.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom
$form.Controls.Add($footer)

function Set-ZipOutput {
    param([string]$Text)
    $output.Text = $Text
    $output.SelectionStart = 0
    $output.ScrollToCaret()
}

function Invoke-7ZipTest {
    param(
        [string]$SevenZip,
        [string]$Archive,
        [string]$Password
    )

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $SevenZip
    $psi.Arguments = "t -p$Password -y -bso0 -bse0 `"$Archive`""
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    try {
        [void]$process.Start()
        if (-not $process.WaitForExit(15000)) {
            $process.Kill()
            return $false
        }
        return $process.ExitCode -eq 0
    }
    finally {
        $process.Dispose()
    }
}

function Invoke-7ZipExtract {
    param(
        [string]$SevenZip,
        [string]$Archive,
        [string]$Password,
        [string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Destination)) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $SevenZip
    $psi.Arguments = "x -p$Password -y -aoa `"$Archive`" -o`"$Destination`""
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    try {
        [void]$process.Start()
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        return [pscustomobject]@{ Code = $process.ExitCode; Output = "$stdout`r`n$stderr" }
    }
    finally {
        $process.Dispose()
    }
}

function Start-ZipBruteForce {
    $script:StopRequested = $false
    $script:FoundPassword = ""
    $extractButton.Enabled = $false

    try {
        $sevenZip = Get-Lab7Zip
        $archive = $zipBox.Text.Trim()
        $wordlist = $wordlistBox.Text.Trim()
        if (-not (Test-Path -LiteralPath $archive -PathType Leaf)) {
            throw "Selecione um arquivo ZIP existente."
        }
        if (-not (Test-Path -LiteralPath $wordlist -PathType Leaf)) {
            throw "A wordlist selecionada não existe."
        }

        $candidates = @(Get-Content -LiteralPath $wordlist | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })
        if ($candidates.Count -eq 0) {
            throw "A wordlist está vazia."
        }
        if ($candidates.Count -gt 12000) {
            throw "Para manter o escopo da aula, use uma wordlist com no máximo 12.000 entradas."
        }

        $startButton.Enabled = $false
        $stopButton.Enabled = $true
        $output.Clear()
        $statusLabel.Text = "Testando $($candidates.Count) candidatos..."
        $attempt = 0

        foreach ($candidate in $candidates) {
            if ($script:StopRequested) {
                break
            }
            $attempt++
            if (Invoke-7ZipTest -SevenZip $sevenZip -Archive $archive -Password $candidate) {
                $script:FoundPassword = $candidate
                $extractButton.Enabled = $true
                $statusLabel.Text = "Senha encontrada na tentativa $attempt."
                Set-ZipOutput -Text ((@(
                    "RESULTADO: senha do ZIP encontrada"
                    "Arquivo: $archive"
                    "Senha encontrada: $candidate"
                    "Tentativas: $attempt de $($candidates.Count)"
                    ""
                    "Escolha uma pasta vazia e clique em Extrair conteúdo."
                )) -join "`r`n")
                return
            }

            if (($attempt % 250) -eq 0) {
                $statusLabel.Text = "Tentativa $attempt de $($candidates.Count)..."
                [System.Windows.Forms.Application]::DoEvents()
            }
        }

        if ($script:StopRequested) {
            $statusLabel.Text = "Teste interrompido."
            Set-ZipOutput -Text "O teste foi interrompido após $attempt tentativa(s)."
        }
        else {
            $statusLabel.Text = "Senha não encontrada."
            Set-ZipOutput -Text "Nenhum candidato abriu o ZIP após $attempt tentativa(s). Verifique o arquivo e a wordlist."
        }
    }
    catch {
        $statusLabel.Text = "Erro de validação."
        Set-ZipOutput -Text "Falha controlada:`r`n$($_.Exception.Message)"
    }
    finally {
        $startButton.Enabled = $true
        $stopButton.Enabled = $false
    }
}

$zipBrowse.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "Arquivos ZIP (*.zip)|*.zip|Todos os arquivos (*.*)|*.*"
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $zipBox.Text = $dialog.FileName
    }
})

$wordlistBrowse.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "Listas de texto (*.txt)|*.txt|Todos os arquivos (*.*)|*.*"
    $dialog.InitialDirectory = $PSScriptRoot
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $wordlistBox.Text = $dialog.FileName
    }
})

$outputBrowse.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Escolha a pasta de extração"
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $outputBox.Text = $dialog.SelectedPath
    }
})

$startButton.Add_Click({ Start-ZipBruteForce })
$stopButton.Add_Click({ $script:StopRequested = $true })
$extractButton.Add_Click({
    try {
        if ([string]::IsNullOrWhiteSpace($script:FoundPassword)) {
            throw "Primeiro encontre a senha."
        }
        $sevenZip = Get-Lab7Zip
        $result = Invoke-7ZipExtract -SevenZip $sevenZip -Archive $zipBox.Text.Trim() -Password $script:FoundPassword -Destination $outputBox.Text.Trim()
        if ($result.Code -ne 0) {
            throw "O 7-Zip retornou código $($result.Code). $($result.Output)"
        }
        Set-ZipOutput -Text "Extração concluída em:`r`n$($outputBox.Text.Trim())`r`n`r`nAgora execute 03-Hashes-Arquivos.ps1 e selecione essa pasta."
    }
    catch {
        Set-ZipOutput -Text "Falha na extração:`r`n$($_.Exception.Message)"
    }
})

$form.Add_Shown({ $zipBox.Focus() })
[void]$form.ShowDialog()

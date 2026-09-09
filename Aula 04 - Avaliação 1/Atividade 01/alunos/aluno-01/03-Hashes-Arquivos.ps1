Set-StrictMode -Version Latest

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

if ($PSVersionTable.PSVersion.Major -lt 7) {
    [void][System.Windows.Forms.MessageBox]::Show("Use o PowerShell 7 instalado pelo winget para executar esta ferramenta.", "Dependência ausente")
    exit 1
}

Import-Module (Join-Path $PSScriptRoot "LabAluno.psm1") -Force

$form = New-Object System.Windows.Forms.Form
$form.Text = "Gerador de hashes — Atividade 01"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(1120, 720)
$form.MinimumSize = New-Object System.Drawing.Size(900, 600)
$form.BackColor = [System.Drawing.Color]::WhiteSmoke

$title = New-Object System.Windows.Forms.Label
$title.Text = "Gerador de hashes"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(24, 18)
$form.Controls.Add($title)

$note = New-Object System.Windows.Forms.Label
$note.Text = "Compare os hashes exibidos para identificar manualmente os arquivos equivalentes."
$note.AutoSize = $true
$note.Location = New-Object System.Drawing.Point(26, 52)
$form.Controls.Add($note)

$folderLabel = New-Object System.Windows.Forms.Label
$folderLabel.Text = "Pasta extraída:"
$folderLabel.AutoSize = $true
$folderLabel.Location = New-Object System.Drawing.Point(26, 92)
$form.Controls.Add($folderLabel)

$folderBox = New-Object System.Windows.Forms.TextBox
$folderBox.Location = New-Object System.Drawing.Point(145, 88)
$folderBox.Size = New-Object System.Drawing.Size(770, 24)
$form.Controls.Add($folderBox)

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Selecionar..."
$browseButton.Location = New-Object System.Drawing.Point(930, 86)
$browseButton.Size = New-Object System.Drawing.Size(135, 28)
$form.Controls.Add($browseButton)

$hashButton = New-Object System.Windows.Forms.Button
$hashButton.Text = "Gerar hashes"
$hashButton.Location = New-Object System.Drawing.Point(145, 128)
$hashButton.Size = New-Object System.Drawing.Size(145, 32)
$form.Controls.Add($hashButton)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Selecione a pasta que contém os 14 arquivos."
$statusLabel.AutoSize = $true
$statusLabel.Location = New-Object System.Drawing.Point(315, 136)
$form.Controls.Add($statusLabel)

$output = New-Object System.Windows.Forms.RichTextBox
$output.ReadOnly = $true
$output.BackColor = [System.Drawing.Color]::White
$output.Font = New-Object System.Drawing.Font("Consolas", 9)
$output.Location = New-Object System.Drawing.Point(24, 182)
$output.Size = New-Object System.Drawing.Size(1040, 430)
$output.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($output)

$footer = New-Object System.Windows.Forms.Label
$footer.Text = "Identifique manualmente os pares comparando os hashes iguais."
$footer.AutoSize = $true
$footer.Location = New-Object System.Drawing.Point(26, 642)
$footer.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom
$form.Controls.Add($footer)

function Get-Sha256Hex {
    param([byte[]]$Bytes)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ([System.BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace("-", "").ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Invoke-HashAnalysis {
    try {
        $folder = $folderBox.Text.Trim()
        if (-not (Test-Path -LiteralPath $folder -PathType Container)) {
            throw "Selecione uma pasta existente."
        }

        $files = @(Get-ChildItem -LiteralPath $folder -File -Recurse | Sort-Object FullName)
        if ($files.Count -ne 14) {
            throw "A pasta selecionada deve conter exatamente 14 arquivos; encontrados $($files.Count)."
        }

        $rows = foreach ($file in $files) {
            $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
            $text = [System.Text.Encoding]::UTF8.GetString($bytes)
            $normalized = Normalize-LabText -Text $text
            [pscustomobject]@{
                Name = $file.Name
                Hash = Get-Sha256Hex -Bytes ([System.Text.Encoding]::UTF8.GetBytes($normalized))
            }
        }

        $lines = New-Object System.Collections.Generic.List[string]
        [void]$lines.Add("NOME`tHASH")

        foreach ($row in $rows) {
            [void]$lines.Add((@($row.Name, $row.Hash) -join "`t"))
        }

        $statusLabel.Text = "Hashes gerados; identifique manualmente os pares comparando hashes iguais."

        $output.Text = $lines -join "`r`n"
        $output.SelectionStart = 0
        $output.ScrollToCaret()
    }
    catch {
        $statusLabel.Text = "Erro de validação."
        $output.Text = "Falha controlada:`r`n$($_.Exception.Message)"
    }
}

$browseButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Selecione a pasta extraída com os 14 arquivos"
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $folderBox.Text = $dialog.SelectedPath
    }
})

$hashButton.Add_Click({ Invoke-HashAnalysis })

$form.Add_Shown({ $folderBox.Focus() })
[void]$form.ShowDialog()

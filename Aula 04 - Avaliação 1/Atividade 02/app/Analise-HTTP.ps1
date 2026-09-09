Set-StrictMode -Version Latest

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

Import-Module (Join-Path $PSScriptRoot "LabHttp.psm1") -Force

$form = New-Object System.Windows.Forms.Form
$form.Text = "Analisador de exposição HTTP — Aula 04"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(820, 620)
$form.MinimumSize = New-Object System.Drawing.Size(720, 520)
$form.BackColor = [System.Drawing.Color]::WhiteSmoke

$title = New-Object System.Windows.Forms.Label
$title.Text = "Analisador de exposição HTTP"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(24, 18)
$form.Controls.Add($title)

$description = New-Object System.Windows.Forms.Label
$description.Text = "Fingerprinting e prova única contra o laboratório local. O aplicativo não faz varredura de rede."
$description.AutoSize = $true
$description.Location = New-Object System.Drawing.Point(26, 52)
$form.Controls.Add($description)

$targetLabel = New-Object System.Windows.Forms.Label
$targetLabel.Text = "Alvo autorizado:"
$targetLabel.AutoSize = $true
$targetLabel.Location = New-Object System.Drawing.Point(26, 90)
$form.Controls.Add($targetLabel)

$targetBox = New-Object System.Windows.Forms.TextBox
$targetBox.Text = "http://127.0.0.1:8080"
$targetBox.Location = New-Object System.Drawing.Point(130, 86)
$targetBox.Size = New-Object System.Drawing.Size(250, 24)
$form.Controls.Add($targetBox)

$analyzeButton = New-Object System.Windows.Forms.Button
$analyzeButton.Text = "Analisar serviço"
$analyzeButton.Location = New-Object System.Drawing.Point(400, 84)
$analyzeButton.Size = New-Object System.Drawing.Size(145, 30)
$form.Controls.Add($analyzeButton)

$proofButton = New-Object System.Windows.Forms.Button
$proofButton.Text = "Executar prova segura"
$proofButton.Location = New-Object System.Drawing.Point(555, 84)
$proofButton.Size = New-Object System.Drawing.Size(175, 30)
$form.Controls.Add($proofButton)

$output = New-Object System.Windows.Forms.RichTextBox
$output.ReadOnly = $true
$output.BackColor = [System.Drawing.Color]::White
$output.Font = New-Object System.Drawing.Font("Consolas", 10)
$output.Location = New-Object System.Drawing.Point(24, 132)
$output.Size = New-Object System.Drawing.Size(748, 400)
$output.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($output)

$footer = New-Object System.Windows.Forms.Label
$footer.Text = "Escopo: somente localhost. Registre as evidências no relatório da equipe."
$footer.AutoSize = $true
$footer.Location = New-Object System.Drawing.Point(26, 548)
$footer.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom
$form.Controls.Add($footer)

function Set-AnalysisOutput {
    param([string]$Text)
    $output.Text = $Text
    $output.SelectionStart = 0
    $output.ScrollToCaret()
}

function Invoke-Analysis {
    try {
        $target = Resolve-LabTarget -BaseUrl $targetBox.Text.Trim()
        $response = Send-LabHttpRequest -Target $target -Path "/"
        $version = Get-LabServerVersion -ServerHeader $response.Server

        $lines = @(
            "ALVO: $($target.Display)"
            "STATUS DA PÁGINA INICIAL: $($response.StatusCode)"
            "CABEÇALHO SERVER: $($response.Server)"
            "VERSÃO OBSERVADA: $version"
            ""
            "Próximo passo: pesquise o produto e a versão em uma fonte confiável."
            "Não conclua que uma versão é vulnerável apenas pelo número: confirme as condições e o comportamento."
            ""
            "RESUMO DA PÁGINA:"
            (Limit-LabText -Text $response.Body -Maximum 1800)
        )

        Set-AnalysisOutput -Text ($lines -join "`r`n")
    }
    catch {
        Set-AnalysisOutput -Text ("Falha controlada:`r`n$($_.Exception.Message)`r`n`r`nVerifique se o Docker Desktop está em execução e se a porta 8080 está livre.")
    }
}

function Invoke-SafeProof {
    try {
        $target = Resolve-LabTarget -BaseUrl $targetBox.Text.Trim()
        $proofPath = "/public/.%2e/lab-secrets/segredo.txt"
        $response = Send-LabHttpRequest -Target $target -Path $proofPath
        $confirmed = $response.StatusCode -eq 200 -and $response.Body -match "LAB-ARQUIVO-CONTROLADO"

        if ($confirmed) {
            $conclusion = "RESULTADO: comportamento de leitura fora do diretório público CONFIRMADO."
        }
        else {
            $conclusion = "RESULTADO: prova não confirmou leitura do arquivo didático."
        }

        $lines = @(
            "ALVO: $($target.Display)"
            "CAMINHO DE PROVA: $proofPath"
            "STATUS HTTP: $($response.StatusCode)"
            $conclusion
            ""
            "Trecho da resposta:"
            (Limit-LabText -Text $response.Body -Maximum 2400)
            ""
            "Interpretação: compare este resultado com a versão observada e pesquise o CVE associado."
        )

        Set-AnalysisOutput -Text ($lines -join "`r`n")
    }
    catch {
        Set-AnalysisOutput -Text ("Falha controlada:`r`n$($_.Exception.Message)")
    }
}

$analyzeButton.Add_Click({ Invoke-Analysis })
$proofButton.Add_Click({ Invoke-SafeProof })

$form.Add_Shown({ $targetBox.Focus() })
[void]$form.ShowDialog()

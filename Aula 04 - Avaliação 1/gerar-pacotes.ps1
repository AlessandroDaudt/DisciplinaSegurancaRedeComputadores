[CmdletBinding()]
param(
    [string]$OutputDirectory,
    [string]$PrivateManifestPath
)

$ErrorActionPreference = 'Stop'
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) { $OutputDirectory = $scriptRoot }
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
$modelRoot = Join-Path $scriptRoot 'modelo'
$stagingRoot = Join-Path ([IO.Path]::GetTempPath()) ("aula04-geracao-" + [Guid]::NewGuid().ToString('N'))
$utf8NoBom = [Text.UTF8Encoding]::new($false)
$rng = [Security.Cryptography.RandomNumberGenerator]::Create()

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Write-TextFile([string]$Path, [string]$Content) {
    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    [IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Join-ByteArrays {
    param([byte[][]]$Arrays)
    $stream = [IO.MemoryStream]::new()
    try {
        foreach ($array in $Arrays) {
            if ($null -ne $array -and $array.Length -gt 0) { $stream.Write($array, 0, $array.Length) }
        }
        $result = $stream.ToArray()
    } finally { $stream.Dispose() }
    return ,$result
}

function Get-U16BE([int]$Value) {
    [byte[]]$result = @([byte](($Value -shr 8) -band 255), [byte]($Value -band 255))
    return ,$result
}

function Get-U32BE([uint64]$Value) {
    [byte[]]$result = @(
        [byte](($Value -shr 24) -band 255),
        [byte](($Value -shr 16) -band 255),
        [byte](($Value -shr 8) -band 255),
        [byte]($Value -band 255)
    )
    return ,$result
}

function Get-U32LE([uint64]$Value) {
    [byte[]]$result = @(
        [byte]($Value -band 255),
        [byte](($Value -shr 8) -band 255),
        [byte](($Value -shr 16) -band 255),
        [byte](($Value -shr 24) -band 255)
    )
    return ,$result
}

function Set-U16BE([byte[]]$Buffer, [int]$Offset, [int]$Value) {
    $Buffer[$Offset] = [byte](($Value -shr 8) -band 255)
    $Buffer[$Offset + 1] = [byte]($Value -band 255)
}

function Set-U32BE([byte[]]$Buffer, [int]$Offset, [uint64]$Value) {
    $Buffer[$Offset] = [byte](($Value -shr 24) -band 255)
    $Buffer[$Offset + 1] = [byte](($Value -shr 16) -band 255)
    $Buffer[$Offset + 2] = [byte](($Value -shr 8) -band 255)
    $Buffer[$Offset + 3] = [byte]($Value -band 255)
}

function Get-IPv4Bytes([string]$Address) {
    $result = New-Object byte[] 4
    $parts = $Address.Split('.')
    if ($parts.Count -ne 4) { throw "IPv4 inválido: $Address" }
    for ($i = 0; $i -lt 4; $i++) { $result[$i] = [byte][int]$parts[$i] }
    return ,$result
}

function Get-InternetChecksum([byte[]]$Bytes) {
    [uint64]$sum = 0
    for ($i = 0; $i -lt $Bytes.Length; $i += 2) {
        [uint64]$word = [uint64]$Bytes[$i] -shl 8
        if (($i + 1) -lt $Bytes.Length) { $word += $Bytes[$i + 1] }
        $sum += $word
        while ($sum -gt 0xffff) { $sum = ($sum -band 0xffff) + ($sum -shr 16) }
    }
    return [int]((-bnot [int]$sum) -band 0xffff)
}

function New-TcpSegment {
    param(
        [byte[]]$SourceIp,
        [byte[]]$DestinationIp,
        [int]$SourcePort,
        [int]$DestinationPort,
        [uint32]$Sequence,
        [uint32]$Acknowledgement,
        [int]$Flags,
        [string]$Payload = ''
    )
    $payloadBytes = [Text.Encoding]::ASCII.GetBytes($Payload)
    $header = New-Object byte[] 20
    Set-U16BE $header 0 $SourcePort
    Set-U16BE $header 2 $DestinationPort
    Set-U32BE $header 4 $Sequence
    Set-U32BE $header 8 $Acknowledgement
    $header[12] = 0x50
    $header[13] = [byte]$Flags
    Set-U16BE $header 14 8192
    Set-U16BE $header 16 0
    Set-U16BE $header 18 0
    $segmentWithoutChecksum = Join-ByteArrays -Arrays @($header, $payloadBytes)
    $pseudoHeader = Join-ByteArrays -Arrays @($SourceIp, $DestinationIp, [byte[]](0, 6), (Get-U16BE $segmentWithoutChecksum.Length))
    $checksum = Get-InternetChecksum (Join-ByteArrays -Arrays @($pseudoHeader, $segmentWithoutChecksum))
    Set-U16BE $header 16 $checksum
    return (Join-ByteArrays -Arrays @($header, $payloadBytes))
}

function New-IPv4Packet {
    param(
        [byte[]]$SourceIp,
        [byte[]]$DestinationIp,
        [byte[]]$TcpSegment,
        [int]$Identification
    )
    $header = New-Object byte[] 20
    $header[0] = 0x45
    $header[1] = 0
    Set-U16BE $header 2 (20 + $TcpSegment.Length)
    Set-U16BE $header 4 $Identification
    Set-U16BE $header 6 0x4000
    $header[8] = 64
    $header[9] = 6
    Set-U16BE $header 10 0
    [Array]::Copy($SourceIp, 0, $header, 12, 4)
    [Array]::Copy($DestinationIp, 0, $header, 16, 4)
    Set-U16BE $header 10 (Get-InternetChecksum $header)
    return (Join-ByteArrays -Arrays @($header, $TcpSegment))
}

function New-EthernetFrame {
    param([byte[]]$SourceMac, [byte[]]$DestinationMac, [byte[]]$IpPacket)
    return (Join-ByteArrays -Arrays @($DestinationMac, $SourceMac, [byte[]](0x08, 0x00), $IpPacket))
}

function New-PcapRecord([int]$Seconds, [int]$Microseconds, [byte[]]$Frame) {
    return (Join-ByteArrays -Arrays @(
        (Get-U32LE $Seconds),
        (Get-U32LE $Microseconds),
        (Get-U32LE $Frame.Length),
        (Get-U32LE $Frame.Length),
        $Frame
    ))
}

function New-LoginPcap {
    param([int]$StudentIndex, [string]$StudentId, [string]$Username, [string]$Path)
    $clientIpText = "192.168.56.$(100 + $StudentIndex)"
    $serverIpText = "192.168.57.$(200 + $StudentIndex)"
    $clientIp = Get-IPv4Bytes $clientIpText
    $serverIp = Get-IPv4Bytes $serverIpText
    [byte[]]$clientMac = @(0x02, 0x00, 0x00, 0x00, 0x10, $StudentIndex)
    [byte[]]$serverMac = @(0x02, 0x00, 0x00, 0x00, 0x20, $StudentIndex)
    $clientPort = 51000 + $StudentIndex
    $serverPort = 80
    [uint32]$clientSequence = 100000 + ($StudentIndex * 1000)
    [uint32]$serverSequence = 500000 + ($StudentIndex * 1000)
    $body = "username=$Username"
    $request = "POST /identificar HTTP/1.1`r`nHost: laboratorio-$StudentId.local`r`nContent-Type: application/x-www-form-urlencoded`r`nContent-Length: $([Text.Encoding]::ASCII.GetByteCount($body))`r`nConnection: close`r`n`r`n$body"

    $synTcp = New-TcpSegment $clientIp $serverIp $clientPort $serverPort $clientSequence 0 0x02
    $synAckTcp = New-TcpSegment $serverIp $clientIp $serverPort $clientPort $serverSequence ($clientSequence + 1) 0x12
    $ackTcp = New-TcpSegment $clientIp $serverIp $clientPort $serverPort ($clientSequence + 1) ($serverSequence + 1) 0x10
    $postTcp = New-TcpSegment $clientIp $serverIp $clientPort $serverPort ($clientSequence + 1) ($serverSequence + 1) 0x18 $request
    $finalAckTcp = New-TcpSegment $serverIp $clientIp $serverPort $clientPort ($serverSequence + 1) ($clientSequence + 1 + [Text.Encoding]::ASCII.GetByteCount($request)) 0x10

    $frames = @(
        (New-EthernetFrame $clientMac $serverMac (New-IPv4Packet $clientIp $serverIp $synTcp 0x1001)),
        (New-EthernetFrame $serverMac $clientMac (New-IPv4Packet $serverIp $clientIp $synAckTcp 0x2001)),
        (New-EthernetFrame $clientMac $serverMac (New-IPv4Packet $clientIp $serverIp $ackTcp 0x1002)),
        (New-EthernetFrame $clientMac $serverMac (New-IPv4Packet $clientIp $serverIp $postTcp 0x1003)),
        (New-EthernetFrame $serverMac $clientMac (New-IPv4Packet $serverIp $clientIp $finalAckTcp 0x2002))
    )
    [byte[]]$globalHeader = @(0xD4, 0xC3, 0xB2, 0xA1, 0x02, 0x00, 0x04, 0x00, 0, 0, 0, 0, 0, 0, 0, 0, 0xFF, 0xFF, 0, 0, 0x01, 0, 0, 0)
    $baseTime = 1735689600 + ($StudentIndex * 60)
    $records = @(
        (New-PcapRecord $baseTime 100000 $frames[0]),
        (New-PcapRecord ($baseTime + 1) 200000 $frames[1]),
        (New-PcapRecord ($baseTime + 2) 300000 $frames[2]),
        (New-PcapRecord ($baseTime + 3) 400000 $frames[3]),
        (New-PcapRecord ($baseTime + 4) 500000 $frames[4])
    )
    [IO.File]::WriteAllBytes($Path, (Join-ByteArrays -Arrays @($globalHeader, $records[0], $records[1], $records[2], $records[3], $records[4])))
}

function Get-SecureNumber([int]$MaximumExclusive) {
    $bytes = New-Object byte[] 4
    $rng.GetBytes($bytes)
    [uint32]$value = [BitConverter]::ToUInt32($bytes, 0)
    return [int]($value % [uint32]$MaximumExclusive)
}

function Get-Sha256Hex([byte[]]$Bytes) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return (([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '')).ToLowerInvariant() } finally { $sha.Dispose() }
}

function Get-VariantBytes([string]$StudentId, [int]$Variant) {
    $lines = @(
        'Material didatico do laboratorio de seguranca de redes.',
        "Conjunto individual do aluno $StudentId.",
        'Compare os hashes para encontrar os pares.'
    )
    switch ($Variant) {
        0 { $text = ($lines -join "`n") + "`n" }
        1 { $lines[0] += ' '; $text = ($lines -join "`n") + "`n" }
        2 { $lines[1] += '  '; $text = ($lines -join "`n") + "`n" }
        3 { $text = $lines[0] + "`n" + $lines[1] + "`n`n" + $lines[2] + "`n" }
        4 { $lines[2] += ' '; $text = ($lines -join "`n") + "`n" }
        5 { $text = ($lines -join "`r`n") + "`r`n" }
        6 { $text = ($lines -join "`n") + "`n`n" }
        default { throw "Variação inválida: $Variant" }
    }
    return ,([Text.Encoding]::UTF8.GetBytes($text))
}

function New-MaterialZip([string]$StudentId, [int]$StudentIndex, [string]$Path) {
    $zipStream = [IO.MemoryStream]::new()
    $zip = [IO.Compression.ZipArchive]::new($zipStream, [IO.Compression.ZipArchiveMode]::Create, $true)
    try {
        for ($pair = 0; $pair -lt 7; $pair++) {
            $variant = ($StudentIndex - 1 + $pair) % 7
            $bytes = Get-VariantBytes $StudentId $variant
            $firstFile = ($pair * 2) + 1
            foreach ($fileNumber in @($firstFile, ($firstFile + 1))) {
                $entry = $zip.CreateEntry(("arquivo{0:D2}.txt" -f $fileNumber), [IO.Compression.CompressionLevel]::Optimal)
                $entryStream = $entry.Open()
                try { $entryStream.Write($bytes, 0, $bytes.Length) } finally { $entryStream.Dispose() }
            }
        }
    } finally { $zip.Dispose() }
    $zipBytes = $zipStream.ToArray()
    $zipStream.Dispose()

    $pin = $script:records[$StudentIndex - 1].pin
    $key = Get-Sha256Hex ([Text.Encoding]::ASCII.GetBytes($pin))
    $keyBytes = New-Object byte[] 32
    for ($i = 0; $i -lt 64; $i += 2) { $keyBytes[$i / 2] = [Convert]::ToByte($key.Substring($i, 2), 16) }
    $iv = New-Object byte[] 16
    $rng.GetBytes($iv)
    $magic = [Text.Encoding]::ASCII.GetBytes('LABSEGURANCA2026')
    $plain = Join-ByteArrays -Arrays @($magic, $zipBytes)
    $aes = [Security.Cryptography.Aes]::Create()
    $aes.KeySize = 256; $aes.BlockSize = 128; $aes.Mode = 'CBC'; $aes.Padding = 'PKCS7'; $aes.Key = $keyBytes; $aes.IV = $iv
    $encryptor = $aes.CreateEncryptor()
    try { $cipher = $encryptor.TransformFinalBlock($plain, 0, $plain.Length) } finally { $encryptor.Dispose(); $aes.Dispose() }
    [IO.File]::WriteAllBytes($Path, (Join-ByteArrays -Arrays @($iv, $cipher)))
}

function Copy-Template([string]$Source, [string]$Destination, [hashtable]$Replacements = @{}) {
    $text = Get-Content -LiteralPath $Source -Raw
    foreach ($key in $Replacements.Keys) { $text = $text.Replace($key, [string]$Replacements[$key]) }
    Write-TextFile $Destination $text
}

try {
    if (-not (Test-Path -LiteralPath $OutputDirectory)) { New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null }
    New-Item -ItemType Directory -Path $stagingRoot -Force | Out-Null
    $unpackedRoot = Join-Path $OutputDirectory 'pacotes-descompactados'
    New-Item -ItemType Directory -Path $unpackedRoot -Force | Out-Null
    $materialRoot = Join-Path $stagingRoot 'materiais'
    $pcapRoot = Join-Path $stagingRoot 'pcaps'
    New-Item -ItemType Directory -Path $materialRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $pcapRoot -Force | Out-Null

    $script:records = @()
    $usedPasswords = @{}
    $usedPins = @{}
    $publicRecords = @()
    for ($studentIndex = 1; $studentIndex -le 12; $studentIndex++) {
        $studentId = "aluno{0:D2}" -f $studentIndex
        do { $password = (Get-SecureNumber 10000).ToString('D4') } while ($usedPasswords.ContainsKey($password))
        do { $pin = (Get-SecureNumber 1000000).ToString('D6') } while ($usedPins.ContainsKey($pin))
        $usedPasswords[$password] = $true
        $usedPins[$pin] = $true
        $record = [pscustomobject]@{
            package = "Pacote_Aluno_{0:D2}" -f $studentIndex
            username = $studentId
            password = $password
            pin = $pin
            material = "material_$studentId.enc"
            user_sha256 = Get-Sha256Hex ([Text.Encoding]::UTF8.GetBytes($studentId))
            password_sha256 = Get-Sha256Hex ([Text.Encoding]::UTF8.GetBytes("lab-salt-2026:$password"))
        }
        $script:records += $record
        $publicRecords += [pscustomobject]@{
            username = $record.username
            user_sha256 = $record.user_sha256
            password_sha256 = $record.password_sha256
            material = $record.material
        }
    }

    $secretBytes = New-Object byte[] 32
    $rng.GetBytes($secretBytes)
    $flaskSecret = [Convert]::ToBase64String($secretBytes)
    $usersJson = $publicRecords | ConvertTo-Json -Depth 3

    for ($studentIndex = 1; $studentIndex -le 12; $studentIndex++) {
        $record = $script:records[$studentIndex - 1]
        $materialPath = Join-Path $materialRoot $record.material
        New-MaterialZip $record.username $studentIndex $materialPath
        $pcapPath = Join-Path $pcapRoot ("captura_$($record.username).pcap")
        New-LoginPcap $studentIndex $record.username $record.username $pcapPath
    }

    $compileRoot = Join-Path $stagingRoot 'compile'
    New-Item -ItemType Directory -Path $compileRoot -Force | Out-Null
    $sourceApp = Join-Path $modelRoot 'servidor\app\app.py'
    Copy-Item -LiteralPath $sourceApp -Destination (Join-Path $compileRoot 'app.py')
    Push-Location $compileRoot
    try {
        & python -m py_compile (Join-Path $compileRoot 'app.py')
        if ($LASTEXITCODE -ne 0) { throw 'Falha ao compilar o servidor Python.' }
    } finally { Pop-Location }
    $compiledApp = Get-ChildItem -LiteralPath (Join-Path $compileRoot '__pycache__') -Filter 'app*.pyc' | Select-Object -First 1
    if ($null -eq $compiledApp) { throw 'Bytecode app.pyc não foi gerado.' }

    for ($studentIndex = 1; $studentIndex -le 12; $studentIndex++) {
        $studentId = "aluno{0:D2}" -f $studentIndex
        $packageStage = Join-Path $stagingRoot ("Pacote_Aluno_{0:D2}" -f $studentIndex)
        New-Item -ItemType Directory -Path $packageStage -Force | Out-Null
        Copy-Template (Join-Path $modelRoot 'README.md') (Join-Path $packageStage 'README.md') @{ '__STUDENT_ID__' = $studentId }
        Copy-Item -LiteralPath (Join-Path $modelRoot 'Iniciar-Laboratorio.ps1') -Destination $packageStage
        Copy-Item -LiteralPath (Join-Path $modelRoot 'Parar-Laboratorio.ps1') -Destination $packageStage
        Copy-Item -LiteralPath (Join-Path $modelRoot 'ferramenta') -Destination $packageStage -Recurse
        Copy-Item -LiteralPath (Join-Path $modelRoot 'roteiro') -Destination $packageStage -Recurse
        $serverRoot = Join-Path $packageStage 'servidor'
        New-Item -ItemType Directory -Path (Join-Path $serverRoot 'app') -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $serverRoot 'dados\materiais') -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $modelRoot 'servidor\Dockerfile') -Destination $serverRoot
        Copy-Item -LiteralPath (Join-Path $modelRoot 'servidor\requirements.txt') -Destination $serverRoot
        Copy-Item -LiteralPath (Join-Path $modelRoot 'servidor\app\templates') -Destination (Join-Path $serverRoot 'app') -Recurse
        Copy-Item -LiteralPath (Join-Path $modelRoot 'servidor\app\static') -Destination (Join-Path $serverRoot 'app') -Recurse
        Copy-Item -LiteralPath $compiledApp.FullName -Destination (Join-Path $serverRoot 'app\app.pyc')
        Write-TextFile (Join-Path $serverRoot 'dados\usuarios.json') $usersJson
        $captureRoot = Join-Path $packageStage 'captura'
        New-Item -ItemType Directory -Path $captureRoot -Force | Out-Null
        Copy-Item -LiteralPath (Join-Path $pcapRoot ("captura_$studentId.pcap")) -Destination (Join-Path $captureRoot 'captura_login.pcap') -Force
        Copy-Item -LiteralPath $materialRoot -Destination (Join-Path $serverRoot 'dados') -Recurse -Force
        $compose = @"
services:
  web:
    build:
      context: ./servidor
    environment:
      FLASK_SECRET: "$flaskSecret"
    ports:
      - "127.0.0.1:8080:8080"
    restart: unless-stopped
"@
        Write-TextFile (Join-Path $packageStage 'docker-compose.yml') $compose.TrimStart()
        $unpackedPath = Join-Path $unpackedRoot ("Pacote_Aluno_{0:D2}" -f $studentIndex)
        if (Test-Path -LiteralPath $unpackedPath) { Remove-Item -LiteralPath $unpackedPath -Recurse -Force }
        Copy-Item -LiteralPath $packageStage -Destination $unpackedRoot -Recurse
        $zipPath = Join-Path $OutputDirectory ("Pacote_Aluno_{0:D2}.zip" -f $studentIndex)
        Compress-Archive -Path $packageStage -DestinationPath $zipPath -Force
    }

    if (-not [string]::IsNullOrWhiteSpace($PrivateManifestPath)) {
        $manifestFull = [IO.Path]::GetFullPath($PrivateManifestPath)
        if ($manifestFull.StartsWith($OutputDirectory + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
            throw 'O controle privado deve ficar fora do diretório versionado de saída.'
        }
        $manifestLines = @('# Controle privado da geração — não versionar', 'PACOTE`tUSUARIO`tSENHA_LOGIN`tPIN_ARQUIVO')
        foreach ($record in $script:records) {
            $manifestLines += ("{0}`t{1}`t{2}`t{3}`t{4}" -f $record.package, $record.username, $record.password, $record.pin, $record.material)
        }
        Write-TextFile $manifestFull ($manifestLines -join "`r`n")
        Write-Host "Controle privado gravado fora do diretório de saída."
    }
    Write-Host 'Foram gerados 12 pacotes individualizados sem gabarito (ZIP + cópia descompactada).'
} finally {
    $rng.Dispose()
    if (Test-Path -LiteralPath $stagingRoot) { Remove-Item -LiteralPath $stagingRoot -Recurse -Force }
}

[CmdletBinding()]
param(
    [ValidateSet('Demonstrar', 'Criptografar', 'Descriptografar')]
    [string]$Modo = 'Demonstrar',
    [string]$Senha = 'Senha-Laboratorio-2026!',
    [string]$ArquivoEntrada
)

Write-Host 'ATIVIDADE 04 - CRIPTOGRAFIA SIMÉTRICA COM AES' -ForegroundColor Cyan

if ([string]::IsNullOrWhiteSpace($ArquivoEntrada)) {
    $ArquivoEntrada = Join-Path (Join-Path $PSScriptRoot 'dados') 'mensagem-confidencial.txt'
}

$pastaResultado = Join-Path $PSScriptRoot 'resultado'
$arquivoCifrado = Join-Path $pastaResultado 'mensagem-confidencial.aes.txt'

if (-not (Test-Path -LiteralPath $arquivoEntrada)) {
    Write-Error "Mensagem de teste não encontrada: $arquivoEntrada"
    return
}

if (-not (Test-Path -LiteralPath $pastaResultado)) {
    New-Item -ItemType Directory -Path $pastaResultado | Out-Null
}

function Obter-Chave {
    param([string]$TextoSenha)

    $sha = New-Object System.Security.Cryptography.SHA256Managed
    try {
        return $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($TextoSenha))
    }
    finally {
        $sha.Dispose()
    }
}

function Proteger-TextoAes {
    param(
        [string]$Texto,
        [byte[]]$Chave
    )

    $aes = $null
    $memoria = $null
    $transformacao = $null
    $fluxo = $null

    try {
        $aes = New-Object System.Security.Cryptography.AesManaged
        $aes.Key = $Chave
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        $aes.GenerateIV()

        $memoria = New-Object System.IO.MemoryStream
        $transformacao = $aes.CreateEncryptor()
        $fluxo = New-Object System.Security.Cryptography.CryptoStream -ArgumentList @(
            $memoria,
            $transformacao,
            [System.Security.Cryptography.CryptoStreamMode]::Write
        )

        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Texto)
        $fluxo.Write($bytes, 0, $bytes.Length)
        $fluxo.FlushFinalBlock()

        $cifrado = $memoria.ToArray()
        $pacote = New-Object byte[] ($aes.IV.Length + $cifrado.Length)
        [System.Array]::Copy($aes.IV, 0, $pacote, 0, $aes.IV.Length)
        [System.Array]::Copy($cifrado, 0, $pacote, $aes.IV.Length, $cifrado.Length)

        return [System.Convert]::ToBase64String($pacote)
    }
    finally {
        if ($fluxo -ne $null) { $fluxo.Dispose() }
        if ($transformacao -ne $null) { $transformacao.Dispose() }
        if ($memoria -ne $null) { $memoria.Dispose() }
        if ($aes -ne $null) { $aes.Dispose() }
    }
}

function Recuperar-TextoAes {
    param(
        [string]$TextoCifrado,
        [byte[]]$Chave
    )

    $aes = $null
    $entrada = $null
    $saida = $null
    $transformacao = $null
    $fluxo = $null

    try {
        $pacote = [System.Convert]::FromBase64String($TextoCifrado.Trim())
        if ($pacote.Length -le 16) {
            throw 'O conteúdo cifrado é inválido.'
        }

        $iv = New-Object byte[] 16
        $cifrado = New-Object byte[] ($pacote.Length - 16)
        [System.Array]::Copy($pacote, 0, $iv, 0, 16)
        [System.Array]::Copy($pacote, 16, $cifrado, 0, $cifrado.Length)

        $aes = New-Object System.Security.Cryptography.AesManaged
        $aes.Key = $Chave
        $aes.IV = $iv
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

        $entrada = New-Object System.IO.MemoryStream
        $entrada.Write($cifrado, 0, $cifrado.Length)
        $entrada.Position = 0
        $transformacao = $aes.CreateDecryptor()
        $fluxo = New-Object System.Security.Cryptography.CryptoStream -ArgumentList @(
            $entrada,
            $transformacao,
            [System.Security.Cryptography.CryptoStreamMode]::Read
        )
        $saida = New-Object System.IO.MemoryStream
        $buffer = New-Object byte[] 1024

        do {
            $quantidade = $fluxo.Read($buffer, 0, $buffer.Length)
            if ($quantidade -gt 0) {
                $saida.Write($buffer, 0, $quantidade)
            }
        } while ($quantidade -gt 0)

        return [System.Text.Encoding]::UTF8.GetString($saida.ToArray())
    }
    finally {
        if ($fluxo -ne $null) { $fluxo.Dispose() }
        if ($transformacao -ne $null) { $transformacao.Dispose() }
        if ($entrada -ne $null) { $entrada.Dispose() }
        if ($saida -ne $null) { $saida.Dispose() }
        if ($aes -ne $null) { $aes.Dispose() }
    }
}

$chave = Obter-Chave -TextoSenha $Senha
$textoOriginal = Get-Content -LiteralPath $arquivoEntrada -Raw -Encoding UTF8

if ($Modo -eq 'Criptografar' -or $Modo -eq 'Demonstrar') {
    $textoCifrado = Proteger-TextoAes -Texto $textoOriginal -Chave $chave
    [System.IO.File]::WriteAllText($arquivoCifrado, $textoCifrado, [System.Text.Encoding]::ASCII)
    Write-Host "Arquivo cifrado criado em: $arquivoCifrado" -ForegroundColor Green
    Write-Host "Tamanho do texto cifrado em Base64: $($textoCifrado.Length) caracteres"
}

if ($Modo -eq 'Descriptografar' -or $Modo -eq 'Demonstrar') {
    if (-not (Test-Path -LiteralPath $arquivoCifrado)) {
        Write-Error "Arquivo cifrado não encontrado: $arquivoCifrado"
        return
    }

    $textoCifrado = Get-Content -LiteralPath $arquivoCifrado -Raw -Encoding ASCII
    $textoRecuperado = Recuperar-TextoAes -TextoCifrado $textoCifrado -Chave $chave
    Write-Host 'Texto recuperado:' -ForegroundColor Yellow
    Write-Host $textoRecuperado

    if ($Modo -eq 'Demonstrar') {
        if ($textoRecuperado -eq $textoOriginal) {
            Write-Host 'RESULTADO: o texto foi recuperado corretamente usando a mesma chave.' -ForegroundColor Green
        }
        else {
            Write-Host 'RESULTADO: o texto recuperado é diferente do original.' -ForegroundColor Red
        }
    }
}

Write-Host ''
Write-Host 'Pergunta para discussão: qual seria o risco se a mesma chave fosse divulgada?' -ForegroundColor Yellow

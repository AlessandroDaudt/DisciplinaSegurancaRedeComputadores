[CmdletBinding()]
param(
    [ValidateSet('Demonstrar', 'Proteger', 'Recuperar')]
    [string]$Modo = 'Demonstrar',

    [string]$Arquivo,

    [string]$ArquivoCifrado
)

Write-Host 'ATIVIDADE 05 - CRIPTOGRAFIA ASSIMETRICA COM CERTIFICADO' -ForegroundColor Cyan

$arquivoPadrao = Join-Path (Join-Path $PSScriptRoot 'dados') 'mensagem-confidencial.txt'
$pastaResultado = Join-Path $PSScriptRoot 'resultado'
$arquivoCifradoPadrao = Join-Path $pastaResultado 'mensagem-confidencial.cms'
$subject = 'CN=Disciplina-Seguranca-Rede-Laboratorio'

if ([string]::IsNullOrWhiteSpace($Arquivo)) {
    $Arquivo = $arquivoPadrao
}

if ([string]::IsNullOrWhiteSpace($ArquivoCifrado)) {
    $ArquivoCifrado = $arquivoCifradoPadrao
}

function Obter-CertificadoLaboratorio {
    [CmdletBinding()]
    param(
        [switch]$CriarSeAusente
    )

    $certificado = Get-ChildItem -Path 'Cert:\CurrentUser\My' -ErrorAction SilentlyContinue |
        Where-Object { $_.Subject -eq $subject -and $_.NotAfter -gt (Get-Date) } |
        Sort-Object NotAfter -Descending |
        Select-Object -First 1

    if ($null -eq $certificado -and $CriarSeAusente) {
        if (-not (Get-Command New-SelfSignedCertificate -ErrorAction SilentlyContinue)) {
            Write-Error 'New-SelfSignedCertificate nao esta disponivel neste computador.'
            return $null
        }

        Write-Host 'Criando certificado autoassinado para o laboratorio...' -ForegroundColor Yellow
        $certificado = New-SelfSignedCertificate -Subject $subject -CertStoreLocation 'Cert:\CurrentUser\My' -Type DocumentEncryptionCert -KeyAlgorithm RSA -KeyLength 2048
    }

    return $certificado
}

if ($Modo -eq 'Recuperar') {
    if (-not (Test-Path -LiteralPath $ArquivoCifrado -PathType Leaf)) {
        Write-Error "Arquivo protegido nao encontrado: $ArquivoCifrado"
        return
    }

    if (-not (Get-Command Unprotect-CmsMessage -ErrorAction SilentlyContinue)) {
        Write-Error 'Unprotect-CmsMessage nao esta disponivel. Execute esta atividade no Windows PowerShell 5.1.'
        return
    }

    $certificado = Obter-CertificadoLaboratorio
    if ($null -eq $certificado) {
        Write-Error 'Nenhum certificado do laboratorio foi encontrado. Primeiro proteja uma mensagem usando este mesmo usuario do Windows.'
        return
    }

    if (-not $certificado.HasPrivateKey) {
        Write-Error 'O certificado encontrado nao possui a chave privada necessaria para recuperar a mensagem.'
        return
    }

    try {
        $textoRecuperado = Unprotect-CmsMessage -Path $ArquivoCifrado -ErrorAction Stop
    }
    catch {
        Write-Error "Nao foi possivel recuperar a mensagem: $($_.Exception.Message)"
        return
    }

    Write-Host "Certificado utilizado: $($certificado.Thumbprint)" -ForegroundColor Gray
    Write-Host "Arquivo protegido recuperado: $ArquivoCifrado" -ForegroundColor Green
    Write-Host 'Texto recuperado com a chave privada:' -ForegroundColor Yellow
    Write-Host $textoRecuperado
    Write-Host 'RESULTADO: a mensagem foi recuperada com a chave privada do certificado de laboratorio.' -ForegroundColor Green
    return
}

if (-not (Test-Path -LiteralPath $Arquivo -PathType Leaf)) {
    Write-Error "Mensagem de teste nao encontrada: $Arquivo"
    return
}

if (-not (Get-Command Protect-CmsMessage -ErrorAction SilentlyContinue)) {
    Write-Error 'Protect-CmsMessage nao esta disponivel. Execute esta atividade no Windows PowerShell 5.1.'
    return
}

if ($Modo -eq 'Demonstrar' -and -not (Get-Command Unprotect-CmsMessage -ErrorAction SilentlyContinue)) {
    Write-Error 'Unprotect-CmsMessage nao esta disponivel. Execute esta atividade no Windows PowerShell 5.1.'
    return
}

if (-not (Test-Path -LiteralPath $pastaResultado)) {
    New-Item -ItemType Directory -Path $pastaResultado | Out-Null
}

$certificado = Obter-CertificadoLaboratorio -CriarSeAusente
if ($null -eq $certificado -or -not $certificado.HasPrivateKey) {
    Write-Error 'Nao foi possivel obter um certificado com chave privada.'
    return
}

$textoOriginal = Get-Content -LiteralPath $Arquivo -Raw -Encoding UTF8
try {
    Protect-CmsMessage -To $certificado -Content $textoOriginal -OutFile $ArquivoCifrado -ErrorAction Stop
}
catch {
    Write-Error "Nao foi possivel proteger a mensagem: $($_.Exception.Message)"
    return
}

Write-Host "Certificado utilizado: $($certificado.Thumbprint)" -ForegroundColor Gray
Write-Host "Arquivo cifrado criado em: $ArquivoCifrado" -ForegroundColor Green

if ($Modo -eq 'Proteger') {
    Write-Host 'RESULTADO: a mensagem foi protegida com a chave publica. Agora selecione o arquivo .cms e clique em Recuperar mensagem.' -ForegroundColor Green
    return
}

try {
    $textoRecuperado = Unprotect-CmsMessage -Path $ArquivoCifrado -ErrorAction Stop
}
catch {
    Write-Error "Nao foi possivel recuperar a mensagem criada: $($_.Exception.Message)"
    return
}

Write-Host 'Texto recuperado:' -ForegroundColor Yellow
Write-Host $textoRecuperado

if ($textoOriginal -eq $textoRecuperado) {
    Write-Host 'RESULTADO: a mensagem foi protegida com a chave publica e recuperada com a chave privada.' -ForegroundColor Green
}
else {
    Write-Host 'RESULTADO: o texto recuperado e diferente do original.' -ForegroundColor Red
}

Write-Host ''
Write-Host 'Observacao: o certificado e autoassinado e serve apenas para demonstracao.' -ForegroundColor Yellow

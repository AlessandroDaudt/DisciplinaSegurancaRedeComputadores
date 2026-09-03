[CmdletBinding()]
param(
    [string]$Arquivo
)

Write-Host 'ATIVIDADE 05 - CRIPTOGRAFIA ASSIMETRICA COM CERTIFICADO' -ForegroundColor Cyan

if ([string]::IsNullOrWhiteSpace($Arquivo)) {
    $Arquivo = Join-Path (Join-Path $PSScriptRoot 'dados') 'mensagem-confidencial.txt'
}

if (-not (Test-Path -LiteralPath $Arquivo)) {
    Write-Error "Mensagem de teste nao encontrada: $Arquivo"
    return
}

if (-not (Get-Command Protect-CmsMessage -ErrorAction SilentlyContinue)) {
    Write-Error 'Protect-CmsMessage nao esta disponivel. Execute esta atividade no Windows PowerShell 5.1.'
    return
}

if (-not (Get-Command New-SelfSignedCertificate -ErrorAction SilentlyContinue)) {
    Write-Error 'New-SelfSignedCertificate nao esta disponivel neste computador.'
    return
}

$pastaResultado = Join-Path $PSScriptRoot 'resultado'
$arquivoCifrado = Join-Path $pastaResultado 'mensagem-confidencial.cms'
$subject = 'CN=Disciplina-Seguranca-Rede-Laboratorio'

if (-not (Test-Path -LiteralPath $pastaResultado)) {
    New-Item -ItemType Directory -Path $pastaResultado | Out-Null
}

$certificado = Get-ChildItem -Path 'Cert:\CurrentUser\My' -ErrorAction SilentlyContinue |
    Where-Object { $_.Subject -eq $subject -and $_.NotAfter -gt (Get-Date) } |
    Sort-Object NotAfter -Descending |
    Select-Object -First 1

if ($null -eq $certificado) {
    Write-Host 'Criando certificado autoassinado para o laboratorio...' -ForegroundColor Yellow
    $certificado = New-SelfSignedCertificate `
        -Subject $subject `
        -CertStoreLocation 'Cert:\CurrentUser\My' `
        -Type DocumentEncryptionCert `
        -KeyAlgorithm RSA `
        -KeyLength 2048
}

if ($null -eq $certificado -or -not $certificado.HasPrivateKey) {
    Write-Error 'Nao foi possivel obter um certificado com chave privada.'
    return
}

$textoOriginal = Get-Content -LiteralPath $Arquivo -Raw -Encoding UTF8
Protect-CmsMessage -To $certificado -Content $textoOriginal -OutFile $arquivoCifrado
$textoRecuperado = Unprotect-CmsMessage -Path $arquivoCifrado

Write-Host "Certificado utilizado: $($certificado.Thumbprint)" -ForegroundColor Gray
Write-Host "Arquivo cifrado criado em: $arquivoCifrado" -ForegroundColor Green
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

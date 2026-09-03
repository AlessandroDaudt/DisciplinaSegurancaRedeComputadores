[CmdletBinding()]
param(
    [string]$Arquivo,
    [switch]$RecriarReferencia
)

if ([string]::IsNullOrWhiteSpace($Arquivo)) {
    $Arquivo = Join-Path (Join-Path $PSScriptRoot 'dados') 'arquivo-teste.txt'
}

Write-Host 'ATIVIDADE 02 - VERIFICAÇÃO DE INTEGRIDADE COM HASH' -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $Arquivo)) {
    Write-Error "Arquivo de teste não encontrado: $Arquivo"
    return
}

$pastaResultado = Join-Path $PSScriptRoot 'resultado'
$arquivoReferencia = Join-Path $pastaResultado 'hash-referencia.txt'

if (-not (Test-Path -LiteralPath $pastaResultado)) {
    New-Item -ItemType Directory -Path $pastaResultado | Out-Null
}

$hashAtual = (Get-FileHash -LiteralPath $Arquivo -Algorithm SHA256).Hash

Write-Host "Arquivo: $Arquivo"
Write-Host "Hash atual: $hashAtual"

if ($RecriarReferencia -or (-not (Test-Path -LiteralPath $arquivoReferencia))) {
    Set-Content -LiteralPath $arquivoReferencia -Value $hashAtual -Encoding UTF8
    Write-Host 'Referência criada ou recriada.' -ForegroundColor Green
    return
}

$hashReferencia = (Get-Content -LiteralPath $arquivoReferencia -Raw).Trim()
Write-Host "Hash de referência: $hashReferencia"

if ($hashAtual -eq $hashReferencia) {
    Write-Host 'RESULTADO: nenhuma alteração detectada.' -ForegroundColor Green
}
else {
    Write-Host 'RESULTADO: alteração detectada; a integridade não foi confirmada.' -ForegroundColor Red
}

Write-Host ''
Write-Host 'Pergunta para discussão: por que o hash não permite recuperar o arquivo original?' -ForegroundColor Yellow

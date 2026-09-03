[CmdletBinding()]
param(
    [string]$Arquivo = (Join-Path (Join-Path $PSScriptRoot 'dados') 'arquivo-teste.txt'),
    [switch]$RecriarReferencia
)

Write-Host 'ATIVIDADE 02 - VERIFICACAO DE INTEGRIDADE COM HASH' -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $Arquivo)) {
    Write-Error "Arquivo de teste nao encontrado: $Arquivo"
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
    Write-Host 'Referencia criada ou recriada.' -ForegroundColor Green
    return
}

$hashReferencia = (Get-Content -LiteralPath $arquivoReferencia -Raw).Trim()
Write-Host "Hash de referencia: $hashReferencia"

if ($hashAtual -eq $hashReferencia) {
    Write-Host 'RESULTADO: nenhuma alteracao detectada.' -ForegroundColor Green
}
else {
    Write-Host 'RESULTADO: alteracao detectada; a integridade nao foi confirmada.' -ForegroundColor Red
}

Write-Host ''
Write-Host 'Pergunta para discussao: por que o hash nao permite recuperar o arquivo original?' -ForegroundColor Yellow

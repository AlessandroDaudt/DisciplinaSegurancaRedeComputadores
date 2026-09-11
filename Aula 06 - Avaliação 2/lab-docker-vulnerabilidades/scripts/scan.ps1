$ErrorActionPreference = 'Stop'

$labRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $labRoot

Write-Host '== Descoberta de servicos ==' -ForegroundColor Cyan
docker compose --profile tools run --rm scanner -Pn -sV -p 80 apache
docker compose --profile tools run --rm scanner -Pn -sV -p 3306 mysql
docker compose --profile tools run --rm scanner -Pn -sV -p 22 osroot

Write-Host ''
Write-Host '== Confirmacao controlada do MySQL ==' -ForegroundColor Cyan
docker compose --profile tools run --rm mysql-check

Write-Host ''
Write-Host 'A analise de pacotes das imagens pode ser feita com Trivy; veja o README.' -ForegroundColor Yellow

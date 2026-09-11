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

Write-Host ''
Write-Host '== CVEs para pesquisa ==' -ForegroundColor Cyan
Write-Host 'Apache httpd 2.4.49: CVE-2021-41773'
Write-Host 'MySQL 5.5.23: CVE-2012-2122'
Write-Host 'sudo no container osroot: CVE-2019-14287'
Write-Host 'Pesquise a causa, o impacto, as evidencias e a correcao de cada CVE.' -ForegroundColor Yellow

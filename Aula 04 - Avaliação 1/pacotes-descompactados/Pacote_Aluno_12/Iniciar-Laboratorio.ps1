$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Write-Host "Docker não encontrado. Instale/inicie Docker Desktop antes da aula." -ForegroundColor Red; exit 1 }
Write-Host "Iniciando laboratório em http://127.0.0.1:8080 ..."
docker compose up -d --build
Write-Host "Pronto. Analise captura\captura_login.pcap e abra ferramenta\Laboratorio-Seguranca.ps1."

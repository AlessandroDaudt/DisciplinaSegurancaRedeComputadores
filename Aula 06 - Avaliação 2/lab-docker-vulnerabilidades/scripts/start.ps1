$ErrorActionPreference = 'Stop'

$labRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $labRoot

docker compose up -d --build
docker compose --profile tools build scanner
docker compose ps

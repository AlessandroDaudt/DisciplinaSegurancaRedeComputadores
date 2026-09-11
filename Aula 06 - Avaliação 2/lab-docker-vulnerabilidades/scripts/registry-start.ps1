$ErrorActionPreference = 'Stop'

$labRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $labRoot

docker compose -f ./registry/compose.yaml up -d
docker compose -f ./registry/compose.yaml ps

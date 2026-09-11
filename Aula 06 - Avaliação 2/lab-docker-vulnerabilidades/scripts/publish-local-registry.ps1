[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$Registry = 'localhost:5000',

    [switch]$IncludeOptionalTools
)

$ErrorActionPreference = 'Stop'
$Registry = $Registry.TrimEnd('/')

$labRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $labRoot

function Publish-LabImage {
    param(
        [Parameter(Mandatory)]
        [string]$Source,

        [Parameter(Mandatory)]
        [string]$Repository,

        [Parameter(Mandatory)]
        [string]$Tag
    )

    $target = '{0}/{1}:{2}' -f $Registry, $Repository, $Tag

    & docker image inspect $Source *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "Imagem local não encontrada: $Source. Execute .\scripts\start.ps1 antes."
    }

    Write-Host "Publicando $target..." -ForegroundColor Cyan
    & docker image tag $Source $target
    if ($LASTEXITCODE -ne 0) {
        throw "Não foi possível criar a tag $target."
    }

    & docker image push $target
    if ($LASTEXITCODE -ne 0) {
        throw "Não foi possível publicar $target. Verifique se o registry está ativo."
    }
}

$images = @(
    [pscustomobject]@{
        Source = 'dsc-lab/apache-vulneravel:2.4.49'
        Repository = 'dsc/apache-vulneravel'
        Tag = '2.4.49'
    }
    [pscustomobject]@{
        Source = 'vulhub/mysql:5.5.23'
        Repository = 'dsc/mysql'
        Tag = '5.5.23'
    }
    [pscustomobject]@{
        Source = 'dsc-lab/osroot-vulneravel:sudo-1.8.21'
        Repository = 'dsc/osroot-vulneravel'
        Tag = 'sudo-1.8.21'
    }
    [pscustomobject]@{
        Source = 'dsc-lab/scanner:nmap'
        Repository = 'dsc/scanner'
        Tag = 'nmap'
    }
)

if ($IncludeOptionalTools) {
    $images += [pscustomobject]@{
        Source = 'metasploitframework/metasploit-framework:latest'
        Repository = 'dsc/metasploit-framework'
        Tag = 'latest'
    }
    $images += [pscustomobject]@{
        Source = 'aquasec/trivy:0.74.0'
        Repository = 'dsc/trivy'
        Tag = '0.74.0'
    }
}

foreach ($image in $images) {
    Publish-LabImage -Source $image.Source -Repository $image.Repository -Tag $image.Tag
}

Write-Host 'Publicação concluída.' -ForegroundColor Green

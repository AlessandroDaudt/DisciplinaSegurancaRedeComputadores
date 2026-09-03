[CmdletBinding()]
param(
    [string]$PastaDados = (Join-Path $PSScriptRoot 'dados'),
    [switch]$RecriarReferencia
)

Write-Host 'ATIVIDADE 03 - MONITORAMENTO DE ALTERACOES' -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $PastaDados)) {
    Write-Error "Pasta de dados nao encontrada: $PastaDados"
    return
}

$pastaResultado = Join-Path $PSScriptRoot 'resultado'
$arquivoReferencia = Join-Path $pastaResultado 'linha-de-base.csv'
$arquivoRelatorio = Join-Path $pastaResultado 'monitoramento.csv'

if (-not (Test-Path -LiteralPath $pastaResultado)) {
    New-Item -ItemType Directory -Path $pastaResultado | Out-Null
}

function Obter-ArquivosDoLaboratorio {
    param([string]$Pasta)

    Get-ChildItem -LiteralPath $Pasta -File -Recurse | Where-Object {
        $_.FullName -notlike "$(Join-Path $Pasta 'resultado')*"
    }
}

$arquivos = @(Obter-ArquivosDoLaboratorio -Pasta $PastaDados)
$atuais = @(
    foreach ($item in $arquivos) {
        $caminhoRelativo = $item.FullName.Substring($PastaDados.Length).TrimStart([char[]]"\/")
        [PSCustomObject]@{
            Caminho = $caminhoRelativo
            Hash = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash
            Tamanho = $item.Length
        }
    }
)

if ($RecriarReferencia -or (-not (Test-Path -LiteralPath $arquivoReferencia))) {
    $atuais | Export-Csv -LiteralPath $arquivoReferencia -NoTypeInformation -Encoding UTF8
    Write-Host "Linha de base criada em: $arquivoReferencia" -ForegroundColor Green
    Write-Host "Arquivos registrados: $($atuais.Count)"
    return
}

$referencia = @(Import-Csv -LiteralPath $arquivoReferencia)
$referenciaPorCaminho = @{}
$atuaisPorCaminho = @{}

foreach ($item in $referencia) {
    $referenciaPorCaminho[$item.Caminho] = $item
}

foreach ($item in $atuais) {
    $atuaisPorCaminho[$item.Caminho] = $item
}

$alteracoes = @()

foreach ($item in $atuais) {
    if (-not $referenciaPorCaminho.ContainsKey($item.Caminho)) {
        $alteracoes += [PSCustomObject]@{
            Tipo = 'Novo'
            Caminho = $item.Caminho
            Observacao = 'Arquivo ausente na linha de base'
        }
    }
    elseif ($referenciaPorCaminho[$item.Caminho].Hash -ne $item.Hash) {
        $alteracoes += [PSCustomObject]@{
            Tipo = 'Modificado'
            Caminho = $item.Caminho
            Observacao = 'Hash diferente da linha de base'
        }
    }
}

foreach ($item in $referencia) {
    if (-not $atuaisPorCaminho.ContainsKey($item.Caminho)) {
        $alteracoes += [PSCustomObject]@{
            Tipo = 'Removido'
            Caminho = $item.Caminho
            Observacao = 'Arquivo registrado, mas nao localizado'
        }
    }
}

if ($alteracoes.Count -eq 0) {
    Write-Host 'RESULTADO: nenhuma alteracao detectada.' -ForegroundColor Green
}
else {
    $alteracoes | Format-Table -AutoSize
    $alteracoes | Export-Csv -LiteralPath $arquivoRelatorio -NoTypeInformation -Encoding UTF8
    Write-Host "Relatorio salvo em: $arquivoRelatorio" -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Pergunta para discussao: uma alteracao detectada prova que houve um ataque?' -ForegroundColor Yellow

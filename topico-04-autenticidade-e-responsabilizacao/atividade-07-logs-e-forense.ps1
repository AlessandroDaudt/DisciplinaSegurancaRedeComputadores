[CmdletBinding()]
param(
    [string]$ArquivoEventos = (Join-Path (Join-Path $PSScriptRoot 'dados') 'eventos-seguranca.csv')
)

Write-Host 'ATIVIDADE 07 - REGISTROS E ANALISE FORENSE' -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $ArquivoEventos)) {
    Write-Error "Arquivo de eventos nao encontrado: $ArquivoEventos"
    return
}

$pastaResultado = Join-Path $PSScriptRoot 'resultado'
$arquivoLinhaTempo = Join-Path $pastaResultado 'linha-do-tempo.csv'
$arquivoIndicadores = Join-Path $pastaResultado 'indicadores-logon.csv'

if (-not (Test-Path -LiteralPath $pastaResultado)) {
    New-Item -ItemType Directory -Path $pastaResultado | Out-Null
}

$eventos = @(Import-Csv -LiteralPath $ArquivoEventos -Encoding UTF8 | Sort-Object DataHora)
$eventos | Format-Table -AutoSize
$eventos | Export-Csv -LiteralPath $arquivoLinhaTempo -NoTypeInformation -Encoding UTF8

$falhas = @($eventos | Where-Object { $_.Resultado -eq 'Falha' })
$gruposPorOrigem = @($falhas | Group-Object Origem | Sort-Object Count -Descending)

Write-Host ''
Write-Host 'Falhas de autenticacao por origem:' -ForegroundColor Yellow
$gruposPorOrigem | Select-Object Name, Count | Format-Table -AutoSize

$indicadores = @($gruposPorOrigem | Where-Object { $_.Count -ge 3 } | ForEach-Object {
        [PSCustomObject]@{
            Origem = $_.Name
            QuantidadeFalhas = $_.Count
            Interpretacao = 'Indicador que merece investigacao; nao e prova isolada de ataque'
        }
    })

if ($indicadores.Count -eq 0) {
    Write-Host 'Nenhum padrao de repeticao foi destacado pelo criterio didatico.' -ForegroundColor Green
}
else {
    Write-Host 'Indicadores destacados:' -ForegroundColor Red
    $indicadores | Format-Table -Wrap -AutoSize
    $indicadores | Export-Csv -LiteralPath $arquivoIndicadores -NoTypeInformation -Encoding UTF8
}

Write-Host ''
Write-Host "Linha do tempo salva em: $arquivoLinhaTempo" -ForegroundColor Gray
Write-Host 'Pergunta para discussao: quais evidencias adicionais seriam necessarias antes de concluir que houve um ataque?' -ForegroundColor Yellow

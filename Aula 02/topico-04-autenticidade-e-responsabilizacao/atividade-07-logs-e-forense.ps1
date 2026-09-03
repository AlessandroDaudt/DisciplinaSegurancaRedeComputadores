[CmdletBinding()]
param(
    [string]$ArquivoEventos
)

if ([string]::IsNullOrWhiteSpace($ArquivoEventos)) {
    $ArquivoEventos = Join-Path (Join-Path $PSScriptRoot 'dados') 'eventos-seguranca.csv'
}

Write-Host 'ATIVIDADE 07 - REGISTROS E ANÁLISE FORENSE' -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $ArquivoEventos)) {
    Write-Error "Arquivo de eventos não encontrado: $ArquivoEventos"
    return
}

$pastaResultado = Join-Path $PSScriptRoot 'resultado'
$arquivoLinhaTempo = Join-Path $pastaResultado 'linha-do-tempo.csv'
$arquivoIndicadores = Join-Path $pastaResultado 'indicadores-logon.csv'

if (-not (Test-Path -LiteralPath $pastaResultado)) {
    New-Item -ItemType Directory -Path $pastaResultado | Out-Null
}

$eventos = @(Import-Csv -LiteralPath $ArquivoEventos -Encoding UTF8 | Sort-Object DataHora)
$eventos | Select-Object DataHora, IdEvento, @{ Name = 'Usuário'; Expression = { $_.Usuario } }, Origem, @{ Name = 'Ação'; Expression = { $_.Acao } }, Resultado, Detalhes | Format-Table -AutoSize
$eventos | Export-Csv -LiteralPath $arquivoLinhaTempo -NoTypeInformation -Encoding UTF8

$falhas = @($eventos | Where-Object { $_.Resultado -eq 'Falha' })
$gruposPorOrigem = @($falhas | Group-Object Origem | Sort-Object Count -Descending)

Write-Host ''
Write-Host 'Falhas de autenticação por origem:' -ForegroundColor Yellow
$gruposPorOrigem | Select-Object @{ Name = 'Origem'; Expression = { $_.Name } }, @{ Name = 'Falhas'; Expression = { $_.Count } } | Format-Table -AutoSize

$indicadores = @($gruposPorOrigem | Where-Object { $_.Count -ge 3 } | ForEach-Object {
        [PSCustomObject]@{
            Origem = $_.Name
            'Quantidade de falhas' = $_.Count
            Interpretação = 'Indicador que merece investigação; não é prova isolada de ataque'
        }
    })

if ($indicadores.Count -eq 0) {
    Write-Host 'Nenhum padrão de repetição foi destacado pelo critério didático.' -ForegroundColor Green
}
else {
    Write-Host 'Indicadores destacados:' -ForegroundColor Red
    $indicadores | Format-Table -Wrap -AutoSize
    $indicadores | Export-Csv -LiteralPath $arquivoIndicadores -NoTypeInformation -Encoding UTF8
}

Write-Host ''
Write-Host "Linha do tempo salva em: $arquivoLinhaTempo" -ForegroundColor Gray
Write-Host 'Pergunta para discussão: quais evidências adicionais seriam necessárias antes de concluir que houve um ataque?' -ForegroundColor Yellow

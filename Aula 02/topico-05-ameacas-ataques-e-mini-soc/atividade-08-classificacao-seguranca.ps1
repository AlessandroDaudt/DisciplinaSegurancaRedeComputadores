[CmdletBinding()]
param(
    [switch]$MostrarGabarito
)

Write-Host 'ATIVIDADE 08 - AMEACA, ATAQUE OU VULNERABILIDADE?' -ForegroundColor Cyan
Write-Host ''

$arquivoCenarios = Join-Path (Join-Path $PSScriptRoot 'dados') 'cenarios-seguranca.csv'
if (-not (Test-Path -LiteralPath $arquivoCenarios)) {
    Write-Error "Arquivo de cenarios nao encontrado: $arquivoCenarios"
    return
}

$cenarios = @(Import-Csv -LiteralPath $arquivoCenarios -Encoding UTF8)

if ($MostrarGabarito) {
    $cenarios | Select-Object ID, Cenario, Resposta, Justificativa | Format-Table -Wrap -AutoSize
    return
}

$mapaRespostas = @{
    '1' = 'Ameaça'
    '2' = 'Ataque'
    '3' = 'Vulnerabilidade'
    'ameaca' = 'Ameaça'
    'ameaça' = 'Ameaça'
    'ataque' = 'Ataque'
    'vulnerabilidade' = 'Vulnerabilidade'
}

$acertos = 0
$numero = 0

foreach ($cenario in $cenarios) {
    $numero++
    Write-Host "Cenario $($cenario.ID): $($cenario.Cenario)" -ForegroundColor White
    Write-Host '1 - Ameaca | 2 - Ataque | 3 - Vulnerabilidade' -ForegroundColor DarkGray
    $entrada = (Read-Host 'Sua resposta').Trim().ToLowerInvariant()

    if ($mapaRespostas.ContainsKey($entrada)) {
        $resposta = $mapaRespostas[$entrada]
    }
    else {
        $resposta = 'Resposta invalida'
    }

    if ($resposta -eq $cenario.Resposta) {
        $acertos++
        Write-Host 'Correto.' -ForegroundColor Green
    }
    else {
        Write-Host "Resposta esperada: $($cenario.Resposta)" -ForegroundColor Yellow
        Write-Host "Justificativa: $($cenario.Justificativa)" -ForegroundColor Gray
    }

    Write-Host ''
}

Write-Host "Resultado: $acertos de $numero acertos." -ForegroundColor Cyan

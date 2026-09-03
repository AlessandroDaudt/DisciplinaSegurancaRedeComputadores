[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ArquivoCenarios,

    [Parameter(Mandatory)]
    [string]$CenarioId,

    [string[]]$ControlesSelecionados = @()
)

if (-not (Test-Path -LiteralPath $ArquivoCenarios -PathType Leaf)) {
    throw ('Arquivo de cenários não encontrado: ' + $ArquivoCenarios)
}

$cenarios = @(Import-Csv -LiteralPath $ArquivoCenarios -Encoding UTF8)
if ($cenarios.Count -eq 0) {
    throw 'O arquivo selecionado não possui cenários.'
}

$colunasObrigatorias = @('Id', 'Cenario', 'Area', 'RiscoPrincipal', 'Descricao', 'ControlesRecomendados')
$colunasAusentes = @($colunasObrigatorias | Where-Object { $_ -notin $cenarios[0].PSObject.Properties.Name })
if ($colunasAusentes.Count -gt 0) {
    throw ('Colunas obrigatórias ausentes: ' + ($colunasAusentes -join ', '))
}

$cenario = @($cenarios | Where-Object { $_.Id -eq $CenarioId }) | Select-Object -First 1
if ($null -eq $cenario) {
    throw ('Cenário não encontrado: ' + $CenarioId)
}

$recomendados = @($cenario.ControlesRecomendados -split '\|' | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
$selecionados = @($ControlesSelecionados | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
$corretos = @($selecionados | Where-Object { $_ -in $recomendados })
$faltantes = @($recomendados | Where-Object { $_ -notin $selecionados })
$adicionais = @($selecionados | Where-Object { $_ -notin $recomendados })
$pontuacao = [math]::Round(($corretos.Count / $recomendados.Count) * 100, 0)
$novaLinha = [Environment]::NewLine

if ($pontuacao -eq 100) {
    $avaliacao = 'Excelente: todos os controles essenciais foram escolhidos.'
}
elseif ($pontuacao -ge 60) {
    $avaliacao = 'Bom começo: alguns controles essenciais ainda precisam ser incluídos.'
}
else {
    $avaliacao = 'Reavalie a proteção: faltam controles importantes para o risco apresentado.'
}

$relatorio = @(
    'RELATÓRIO — MATRIZ DE CONTROLES FÍSICOS'
    ('Cenário: ' + $cenario.Cenario)
    ('Área: ' + $cenario.Area)
    ('Risco principal: ' + $cenario.RiscoPrincipal)
    ''
    ('Descrição: ' + $cenario.Descricao)
    ''
    ('Controles escolhidos: ' + $(if ($selecionados.Count -gt 0) { $selecionados -join ', ' } else { 'nenhum' }))
    ('Controles essenciais: ' + ($recomendados -join ', '))
    ('Pontuação didática: ' + $pontuacao + '%')
    ''
    $avaliacao
    ('Controles faltantes: ' + $(if ($faltantes.Count -gt 0) { $faltantes -join ', ' } else { 'nenhum' }))
    ('Controles adicionais: ' + $(if ($adicionais.Count -gt 0) { $adicionais -join ', ' } else { 'nenhum' }))
    ''
    'Dica: controles adicionais podem ser úteis, mas o projeto deve priorizar os controles que reduzem o risco principal.'
) -join $novaLinha

$pastaResultado = Join-Path $PSScriptRoot 'resultado'
if (-not (Test-Path -LiteralPath $pastaResultado)) {
    New-Item -ItemType Directory -Path $pastaResultado | Out-Null
}
$caminhoRelatorio = Join-Path $pastaResultado ('relatorio-atividade-11-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.txt')
Set-Content -LiteralPath $caminhoRelatorio -Value $relatorio -Encoding UTF8

Write-Output $relatorio
Write-Output ''
Write-Output ('Relatório salvo em: ' + $caminhoRelatorio)

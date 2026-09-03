[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ArquivoCenarios,

    [Parameter(Mandatory)]
    [string]$CenarioId,

    [Parameter(Mandatory)]
    [string]$AcaoEscolhida
)

if (-not (Test-Path -LiteralPath $ArquivoCenarios -PathType Leaf)) {
    throw ('Arquivo de cenários não encontrado: ' + $ArquivoCenarios)
}

$cenarios = @(Import-Csv -LiteralPath $ArquivoCenarios -Encoding UTF8)
if ($cenarios.Count -eq 0) {
    throw 'O arquivo selecionado não possui cenários.'
}

$colunasObrigatorias = @('Id', 'Area', 'Evento', 'Contexto', 'Opcoes', 'AcaoCorreta', 'Explicacao')
$colunasAusentes = @($colunasObrigatorias | Where-Object { $_ -notin $cenarios[0].PSObject.Properties.Name })
if ($colunasAusentes.Count -gt 0) {
    throw ('Colunas obrigatórias ausentes: ' + ($colunasAusentes -join ', '))
}

$cenario = @($cenarios | Where-Object { $_.Id -eq $CenarioId }) | Select-Object -First 1
if ($null -eq $cenario) {
    throw ('Cenário não encontrado: ' + $CenarioId)
}

$acertou = $AcaoEscolhida.Trim() -eq $cenario.AcaoCorreta.Trim()
$novaLinha = [Environment]::NewLine
$avaliacao = if ($acertou) {
    'Resposta correta. A ação escolhida segue o procedimento seguro do cenário.'
}
else {
    'Resposta a revisar. Compare sua decisão com a ação recomendada e identifique o risco que ela evita.'
}

$relatorio = @(
    'RESULTADO — SIMULADOR DE ROTINA SEGURA DO CPD'
    ('Área: ' + $cenario.Area)
    ('Evento: ' + $cenario.Evento)
    ''
    ('Sua escolha: ' + $AcaoEscolhida)
    ('Ação recomendada: ' + $cenario.AcaoCorreta)
    ''
    $avaliacao
    ''
    ('Explicação: ' + $cenario.Explicacao)
    ''
    'Relação com a aula: procedimentos padronizados tornam desvios mais fáceis de perceber e reduzem riscos operacionais.'
) -join $novaLinha

$pastaResultado = Join-Path $PSScriptRoot 'resultado'
if (-not (Test-Path -LiteralPath $pastaResultado)) {
    New-Item -ItemType Directory -Path $pastaResultado | Out-Null
}
$caminhoRelatorio = Join-Path $pastaResultado ('relatorio-atividade-14-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.txt')
Set-Content -LiteralPath $caminhoRelatorio -Value $relatorio -Encoding UTF8

Write-Output $relatorio
Write-Output ''
Write-Output ('Relatório salvo em: ' + $caminhoRelatorio)

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ArquivoAmbientes
)

function Test-ValorSim {
    param([object]$Valor)

    return (([string]$Valor).Trim().ToLowerInvariant() -in @('sim', 's', 'true', '1'))
}

if (-not (Test-Path -LiteralPath $ArquivoAmbientes -PathType Leaf)) {
    throw ('Arquivo de ambientes não encontrado: ' + $ArquivoAmbientes)
}

$ambientes = @(Import-Csv -LiteralPath $ArquivoAmbientes -Encoding UTF8)
if ($ambientes.Count -eq 0) {
    throw 'O arquivo selecionado não possui ambientes para avaliar.'
}

$criterios = @(
    [PSCustomObject]@{ Campo = 'PredioDedicado'; Titulo = 'prédio ou área dedicada'; Peso = 2; Orientacao = 'reservar uma área dedicada para a infraestrutura crítica' }
    [PSCustomObject]@{ Campo = 'AreaElevada'; Titulo = 'instalação elevada'; Peso = 1; Orientacao = 'reduzir a exposição a alagamentos e outros riscos físicos' }
    [PSCustomObject]@{ Campo = 'InstalacaoNoNucleo'; Titulo = 'instalação no núcleo do edifício'; Peso = 2; Orientacao = 'posicionar recursos sensíveis longe das áreas periféricas' }
    [PSCustomObject]@{ Campo = 'Perimetro'; Titulo = 'perímetro protegido'; Peso = 2; Orientacao = 'criar barreiras entre o ambiente sensível e a circulação comum' }
    [PSCustomObject]@{ Campo = 'ControleAcesso'; Titulo = 'controle de acesso'; Peso = 3; Orientacao = 'formalizar a entrada de pessoas autorizadas' }
    [PSCustomObject]@{ Campo = 'CFTV'; Titulo = 'monitoramento por CFTV'; Peso = 1; Orientacao = 'adicionar capacidade de detecção e investigação' }
    [PSCustomObject]@{ Campo = 'DeteccaoIncendio'; Titulo = 'detecção e combate a incêndio'; Peso = 3; Orientacao = 'proteger pessoas, equipamentos e continuidade do serviço' }
    [PSCustomObject]@{ Campo = 'EnergiaRedundante'; Titulo = 'energia com contingência'; Peso = 2; Orientacao = 'reduzir interrupções causadas por falhas elétricas' }
    [PSCustomObject]@{ Campo = 'Climatizacao'; Titulo = 'controle de condições ambientais'; Peso = 2; Orientacao = 'manter temperatura e umidade adequadas aos equipamentos' }
    [PSCustomObject]@{ Campo = 'ArmazenamentoMidias'; Titulo = 'proteção de mídias'; Peso = 2; Orientacao = 'guardar e transportar mídias em local controlado' }
)

$colunasObrigatorias = @('Ambiente') + @($criterios | ForEach-Object { $_.Campo })
$colunasAusentes = @($colunasObrigatorias | Where-Object { $_ -notin $ambientes[0].PSObject.Properties.Name })
if ($colunasAusentes.Count -gt 0) {
    throw ('Colunas obrigatórias ausentes: ' + ($colunasAusentes -join ', '))
}

$analises = foreach ($ambiente in $ambientes) {
    $pontos = 0
    $lacunas = New-Object System.Collections.Generic.List[string]
    $recomendacoes = New-Object System.Collections.Generic.List[string]

    foreach ($criterio in $criterios) {
        if (-not (Test-ValorSim $ambiente.($criterio.Campo))) {
            $pontos += $criterio.Peso
            [void]$lacunas.Add($criterio.Titulo)
            [void]$recomendacoes.Add($criterio.Orientacao)
        }
    }

    $nivel = if ($pontos -le 4) { 'Baixo' } elseif ($pontos -le 10) { 'Médio' } else { 'Alto' }
    [PSCustomObject]@{
        Ambiente       = $ambiente.Ambiente
        PontosDeRisco  = $pontos
        NivelDeRisco   = $nivel
        Lacunas        = if ($lacunas.Count -gt 0) { $lacunas -join '; ' } else { 'Nenhuma lacuna informada' }
        Recomendacoes  = if ($recomendacoes.Count -gt 0) { $recomendacoes -join '; ' } else { 'Manter os controles e revisar periodicamente' }
    }
}

$novaLinha = [Environment]::NewLine
$tabela = $analises | Format-Table Ambiente, PontosDeRisco, NivelDeRisco, Lacunas -AutoSize -Wrap | Out-String -Width 240
$detalhes = foreach ($analise in $analises) {
    ('• ' + $analise.Ambiente + ': ' + $analise.Recomendacoes)
}

$relatorio = @(
    'RELATÓRIO — AVALIAÇÃO DO AMBIENTE DO CPD'
    ('Ambientes avaliados: ' + $analises.Count)
    ''
    $tabela.Trim()
    ''
    'Recomendações por ambiente:'
    ($detalhes -join $novaLinha)
    ''
    'Leitura didática: quanto maior a pontuação, mais lacunas de proteção física foram informadas no cenário.'
) -join $novaLinha

$pastaResultado = Join-Path $PSScriptRoot 'resultado'
if (-not (Test-Path -LiteralPath $pastaResultado)) {
    New-Item -ItemType Directory -Path $pastaResultado | Out-Null
}
$caminhoRelatorio = Join-Path $pastaResultado ('relatorio-atividade-12-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.txt')
Set-Content -LiteralPath $caminhoRelatorio -Value $relatorio -Encoding UTF8

Write-Output $relatorio
Write-Output ''
Write-Output ('Relatório salvo em: ' + $caminhoRelatorio)

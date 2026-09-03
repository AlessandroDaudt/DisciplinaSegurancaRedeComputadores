[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ArquivoInventario
)

function Test-ValorSim {
    param([object]$Valor)

    return (([string]$Valor).Trim().ToLowerInvariant() -in @('sim', 's', 'true', '1'))
}

if (-not (Test-Path -LiteralPath $ArquivoInventario -PathType Leaf)) {
    throw ('Arquivo de inventário não encontrado: ' + $ArquivoInventario)
}

$midias = @(Import-Csv -LiteralPath $ArquivoInventario -Encoding UTF8)
if ($midias.Count -eq 0) {
    throw 'O arquivo selecionado não possui mídias para avaliar.'
}

$colunasObrigatorias = @(
    'Id', 'Tipo', 'Conteudo', 'Sensibilidade', 'LocalArmazenamento',
    'AutorizacaoTransporte', 'EmbalagemProtegida', 'ExposicaoCalor',
    'ExposicaoCampoMagnetico', 'Destino'
)
$colunasAusentes = @($colunasObrigatorias | Where-Object { $_ -notin $midias[0].PSObject.Properties.Name })
if ($colunasAusentes.Count -gt 0) {
    throw ('Colunas obrigatórias ausentes: ' + ($colunasAusentes -join ', '))
}

$avaliacoes = foreach ($midia in $midias) {
    $riscos = New-Object System.Collections.Generic.List[string]
    $critico = $false
    $localProtegido = ([string]$midia.LocalArmazenamento) -match 'Armário|Armario|Cofre|Sala restrita|Sala Restrita'
    $destinoPublico = ([string]$midia.Destino) -match 'pública|publica|comum|recepção|recepcao'
    $sensibilidadeAlta = ([string]$midia.Sensibilidade) -match 'Alta|Crítica|Critica'

    if (-not (Test-ValorSim $midia.AutorizacaoTransporte)) {
        [void]$riscos.Add('transporte sem autorização')
        $critico = $true
    }
    if (-not (Test-ValorSim $midia.EmbalagemProtegida)) {
        [void]$riscos.Add('embalagem sem proteção')
    }
    if (Test-ValorSim $midia.ExposicaoCalor) {
        [void]$riscos.Add('exposição ao calor')
        $critico = $true
    }
    if (Test-ValorSim $midia.ExposicaoCampoMagnetico) {
        [void]$riscos.Add('exposição a campo magnético')
        $critico = $true
    }
    if (-not $localProtegido) {
        [void]$riscos.Add('armazenamento sem restrição explícita')
    }
    if ($sensibilidadeAlta -and $destinoPublico) {
        [void]$riscos.Add('mídia sensível exposta em área pública')
        $critico = $true
    }

    $classificacao = if ($critico) { 'Crítico' } elseif ($riscos.Count -gt 0) { 'Atenção' } else { 'Conforme' }
    [PSCustomObject]@{
        Id             = $midia.Id
        Tipo           = $midia.Tipo
        Sensibilidade  = $midia.Sensibilidade
        Classificacao  = $classificacao
        Riscos         = if ($riscos.Count -gt 0) { $riscos -join '; ' } else { 'Proteção compatível com o cenário' }
    }
}

$conformes = @($avaliacoes | Where-Object { $_.Classificacao -eq 'Conforme' }).Count
$atencoes = @($avaliacoes | Where-Object { $_.Classificacao -eq 'Atenção' }).Count
$criticos = @($avaliacoes | Where-Object { $_.Classificacao -eq 'Crítico' }).Count
$novaLinha = [Environment]::NewLine
$tabela = $avaliacoes | Format-Table Id, Tipo, Sensibilidade, Classificacao, Riscos -AutoSize -Wrap | Out-String -Width 240

$relatorio = @(
    'RELATÓRIO — AUDITORIA DE MÍDIAS E TRANSPORTE'
    ('Mídias analisadas: ' + $avaliacoes.Count)
    ('Conformes: ' + $conformes + ' | Atenção: ' + $atencoes + ' | Críticos: ' + $criticos)
    ''
    $tabela.Trim()
    ''
    'Dica didática: mídias removíveis precisam de controle físico, autorização de transporte e proteção contra calor e campos magnéticos.'
) -join $novaLinha

$pastaResultado = Join-Path $PSScriptRoot 'resultado'
if (-not (Test-Path -LiteralPath $pastaResultado)) {
    New-Item -ItemType Directory -Path $pastaResultado | Out-Null
}
$caminhoRelatorio = Join-Path $pastaResultado ('relatorio-atividade-13-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.txt')
Set-Content -LiteralPath $caminhoRelatorio -Value $relatorio -Encoding UTF8

Write-Output $relatorio
Write-Output ''
Write-Output ('Relatório salvo em: ' + $caminhoRelatorio)

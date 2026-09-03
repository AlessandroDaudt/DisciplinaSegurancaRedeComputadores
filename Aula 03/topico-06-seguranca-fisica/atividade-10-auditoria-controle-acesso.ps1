[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ArquivoAcessos
)

function Test-ValorSim {
    param([object]$Valor)

    $texto = ([string]$Valor).Trim().ToLowerInvariant()
    return $texto -in @('sim', 's', 'true', '1')
}

if ([string]::IsNullOrWhiteSpace($ArquivoAcessos)) {
    throw 'Selecione um arquivo CSV com os acessos físicos antes de executar.'
}

if (-not (Test-Path -LiteralPath $ArquivoAcessos -PathType Leaf)) {
    throw ('Arquivo de acessos não encontrado: ' + $ArquivoAcessos)
}

$registros = @(Import-Csv -LiteralPath $ArquivoAcessos -Encoding UTF8)
if ($registros.Count -eq 0) {
    throw 'O arquivo selecionado não possui registros de acesso.'
}

$colunasObrigatorias = @('DataHora', 'Nome', 'Perfil', 'Area', 'Sensibilidade', 'Autorizado', 'HorarioPermitido')
$colunasAusentes = @($colunasObrigatorias | Where-Object { $_ -notin $registros[0].PSObject.Properties.Name })
if ($colunasAusentes.Count -gt 0) {
    throw ('Colunas obrigatórias ausentes: ' + ($colunasAusentes -join ', '))
}

$avaliacoes = foreach ($registro in $registros) {
    $motivos = New-Object System.Collections.Generic.List[string]
    $autorizado = Test-ValorSim $registro.Autorizado
    $horarioPermitido = Test-ValorSim $registro.HorarioPermitido
    $areaSensivel = ([string]$registro.Sensibilidade) -match 'Alta|Crítica|Critica'
    $perfilCompativel = ([string]$registro.Perfil) -match 'Administr|Segurança|Seguranca|Técnico|Tecnico|Responsável|Responsavel'

    if (-not $autorizado) {
        [void]$motivos.Add('não possui autorização registrada')
    }
    if (-not $horarioPermitido) {
        [void]$motivos.Add('ocorreu fora do horário permitido')
    }
    if ($areaSensivel -and -not $perfilCompativel) {
        [void]$motivos.Add('o perfil não é compatível com uma área de alta sensibilidade')
    }

    $classificacao = 'Conforme'
    if (-not $autorizado -or ($areaSensivel -and -not $horarioPermitido)) {
        $classificacao = 'Crítico'
    }
    elseif ($motivos.Count -gt 0) {
        $classificacao = 'Atenção'
    }

    [PSCustomObject]@{
        DataHora      = $registro.DataHora
        Pessoa        = $registro.Nome
        Area          = $registro.Area
        Classificacao = $classificacao
        Motivo        = if ($motivos.Count -eq 0) { 'Registro compatível com o procedimento' } else { $motivos -join '; ' }
    }
}

$conformes = @($avaliacoes | Where-Object { $_.Classificacao -eq 'Conforme' }).Count
$atencoes = @($avaliacoes | Where-Object { $_.Classificacao -eq 'Atenção' }).Count
$criticos = @($avaliacoes | Where-Object { $_.Classificacao -eq 'Crítico' }).Count
$percentual = [math]::Round(($conformes / $avaliacoes.Count) * 100, 0)
$novaLinha = [Environment]::NewLine

$tabela = $avaliacoes | Format-Table DataHora, Pessoa, Area, Classificacao, Motivo -AutoSize -Wrap | Out-String -Width 240
$orientacao = @(
    'O que observar: uma área sensível exige autorização formal, horário compatível e perfil adequado.'
    'Pergunta para discussão: qual controle reduziria o risco dos registros classificados como Crítico?'
) -join $novaLinha

$relatorio = @(
    'RELATÓRIO — AUDITORIA DE CONTROLE DE ACESSO FÍSICO'
    ('Arquivo analisado: ' + $ArquivoAcessos)
    ('Registros analisados: ' + $avaliacoes.Count)
    ('Conformes: ' + $conformes + ' | Atenção: ' + $atencoes + ' | Críticos: ' + $criticos)
    ('Conformidade do cenário: ' + $percentual + '%')
    ''
    $tabela.Trim()
    ''
    $orientacao
) -join $novaLinha

$pastaResultado = Join-Path $PSScriptRoot 'resultado'
if (-not (Test-Path -LiteralPath $pastaResultado)) {
    New-Item -ItemType Directory -Path $pastaResultado | Out-Null
}
$caminhoRelatorio = Join-Path $pastaResultado ('relatorio-atividade-10-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.txt')
Set-Content -LiteralPath $caminhoRelatorio -Value $relatorio -Encoding UTF8

Write-Output $relatorio
Write-Output ''
Write-Output ('Relatório salvo em: ' + $caminhoRelatorio)

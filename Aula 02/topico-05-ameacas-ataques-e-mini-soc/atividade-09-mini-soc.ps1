[CmdletBinding()]
param(
    [switch]$ColetarHost,
    [string]$ArquivoEventos,
    [string]$ArquivoEvidencia
)

Write-Host 'ATIVIDADE 09 - MINI-SOC EM POWERSHELL' -ForegroundColor Cyan
Write-Host 'A triagem usa dados sintéticos e coleta local opcional somente de leitura.' -ForegroundColor DarkGray
Write-Host ''

$pastaDados = Join-Path $PSScriptRoot 'dados'
if ([string]::IsNullOrWhiteSpace($ArquivoEventos)) {
    $ArquivoEventos = Join-Path $pastaDados 'eventos-triagem.csv'
}
if ([string]::IsNullOrWhiteSpace($ArquivoEvidencia)) {
    $ArquivoEvidencia = Join-Path $pastaDados 'evidencia-arquivo.txt'
}
$pastaResultado = Join-Path $PSScriptRoot 'resultado'
$arquivoRelatorio = Join-Path $pastaResultado 'relatorio-mini-soc.txt'

if (-not (Test-Path -LiteralPath $pastaResultado)) {
    New-Item -ItemType Directory -Path $pastaResultado | Out-Null
}

if (-not (Test-Path -LiteralPath $arquivoEventos) -or -not (Test-Path -LiteralPath $arquivoEvidencia)) {
    Write-Error 'Um ou mais arquivos de teste não foram encontrados.'
    return
}

$eventos = @(Import-Csv -LiteralPath $arquivoEventos -Encoding UTF8)
$hashEvidencia = (Get-FileHash -LiteralPath $arquivoEvidencia -Algorithm SHA256).Hash
$score = 0

foreach ($evento in $eventos) {
    switch ($evento.Severidade) {
        'Alta' { $score += 3 }
        'Média' { $score += 2 }
        'Baixa' { $score += 1 }
    }
}

if ($score -ge 7) {
    $prioridade = 'Alta'
}
elseif ($score -ge 4) {
    $prioridade = 'Média'
}
else {
    $prioridade = 'Baixa'
}

Write-Host 'Eventos de triagem:' -ForegroundColor Yellow
$eventos | Select-Object DataHora, Tipo, Indicador, Severidade, Origem, @{ Name = 'Observação'; Expression = { $_.Observacao } } | Format-Table -Wrap -AutoSize
Write-Host "Hash SHA-256 da evidência: $hashEvidencia"
Write-Host "Pontuação didática: $score"
Write-Host "Prioridade sugerida: $prioridade" -ForegroundColor Magenta

$linhasRelatorio = @(
    'RELATÓRIO DE TRIAGEM - MINI-SOC'
    "Data da execução: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    ''
    'EVIDÊNCIA LOCAL'
    "Arquivo: $arquivoEvidencia"
    "SHA-256: $hashEvidencia"
    ''
    'RESUMO'
    "Quantidade de indicadores: $($eventos.Count)"
    "Pontuação didática: $score"
    "Prioridade sugerida: $prioridade"
    ''
    'OBSERVAÇÃO'
    'A classificação é apenas uma triagem inicial e exige validação humana e contexto adicional.'
)

if ($ColetarHost) {
    $linhasRelatorio += ''
    $linhasRelatorio += 'COLETA LOCAL SOMENTE DE LEITURA'

    if (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue) {
        $portas = @(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
            Select-Object -Property LocalAddress, LocalPort, OwningProcess)
        Write-Host ''
        Write-Host 'Portas TCP em escuta no host:' -ForegroundColor Yellow
        $portas | Select-Object -First 20 | Format-Table -AutoSize
        $linhasRelatorio += "Quantidade de portas em escuta: $($portas.Count)"
    }
    else {
        $linhasRelatorio += 'Get-NetTCPConnection não está disponível neste sistema.'
    }

    $servicosParados = @(Get-Service -ErrorAction SilentlyContinue |
        Where-Object { $_.Status -eq 'Stopped' } |
        Select-Object -First 10 Name, DisplayName, Status)
    Write-Host 'Amostra de serviços parados:' -ForegroundColor Yellow
    $servicosParados | Format-Table -AutoSize
    $linhasRelatorio += "Amostra de serviços parados coletada: $($servicosParados.Count)"
}

Set-Content -LiteralPath $arquivoRelatorio -Value $linhasRelatorio -Encoding UTF8
Write-Host ''
Write-Host "Relatório salvo em: $arquivoRelatorio" -ForegroundColor Green
Write-Host 'Pergunta para discussão: quais dados adicionais ajudariam a confirmar ou descartar cada indicador?' -ForegroundColor Yellow

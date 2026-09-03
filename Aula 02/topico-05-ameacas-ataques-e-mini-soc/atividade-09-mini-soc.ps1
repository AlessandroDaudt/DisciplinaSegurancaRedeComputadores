[CmdletBinding()]
param(
    [switch]$ColetarHost,
    [string]$ArquivoEventos,
    [string]$ArquivoEvidencia
)

Write-Host 'ATIVIDADE 09 - MINI-SOC EM POWERSHELL' -ForegroundColor Cyan
Write-Host 'A triagem usa dados sinteticos e coleta local opcional somente de leitura.' -ForegroundColor DarkGray
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
    Write-Error 'Um ou mais arquivos de teste nao foram encontrados.'
    return
}

$eventos = @(Import-Csv -LiteralPath $arquivoEventos -Encoding UTF8)
$hashEvidencia = (Get-FileHash -LiteralPath $arquivoEvidencia -Algorithm SHA256).Hash
$score = 0

foreach ($evento in $eventos) {
    switch ($evento.Severidade) {
        'Alta' { $score += 3 }
        'Media' { $score += 2 }
        'Baixa' { $score += 1 }
    }
}

if ($score -ge 7) {
    $prioridade = 'Alta'
}
elseif ($score -ge 4) {
    $prioridade = 'Media'
}
else {
    $prioridade = 'Baixa'
}

Write-Host 'Eventos de triagem:' -ForegroundColor Yellow
$eventos | Format-Table -Wrap -AutoSize
Write-Host "Hash SHA-256 da evidencia: $hashEvidencia"
Write-Host "Pontuacao didatica: $score"
Write-Host "Prioridade sugerida: $prioridade" -ForegroundColor Magenta

$linhasRelatorio = @(
    'RELATORIO DE TRIAGEM - MINI-SOC'
    "Data da execucao: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    ''
    'EVIDENCIA LOCAL'
    "Arquivo: $arquivoEvidencia"
    "SHA-256: $hashEvidencia"
    ''
    'RESUMO'
    "Quantidade de indicadores: $($eventos.Count)"
    "Pontuacao didatica: $score"
    "Prioridade sugerida: $prioridade"
    ''
    'OBSERVACAO'
    'A classificacao e apenas uma triagem inicial e exige validacao humana e contexto adicional.'
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
        $linhasRelatorio += 'Get-NetTCPConnection nao esta disponivel neste sistema.'
    }

    $servicosParados = @(Get-Service -ErrorAction SilentlyContinue |
        Where-Object { $_.Status -eq 'Stopped' } |
        Select-Object -First 10 Name, DisplayName, Status)
    Write-Host 'Amostra de servicos parados:' -ForegroundColor Yellow
    $servicosParados | Format-Table -AutoSize
    $linhasRelatorio += "Amostra de servicos parados coletada: $($servicosParados.Count)"
}

Set-Content -LiteralPath $arquivoRelatorio -Value $linhasRelatorio -Encoding UTF8
Write-Host ''
Write-Host "Relatorio salvo em: $arquivoRelatorio" -ForegroundColor Green
Write-Host 'Pergunta para discussao: quais dados adicionais ajudariam a confirmar ou descartar cada indicador?' -ForegroundColor Yellow

[CmdletBinding()]
param(
    [string]$PastaDados
)

if ([string]::IsNullOrWhiteSpace($PastaDados)) {
    $PastaDados = Join-Path $PSScriptRoot 'dados'
}

Write-Host 'ATIVIDADE 01 - AUDITORIA DA TRÍADE CIA' -ForegroundColor Cyan
Write-Host 'O script realiza somente verificações locais de leitura.' -ForegroundColor DarkGray
Write-Host ''

if (-not (Test-Path -LiteralPath $PastaDados)) {
    Write-Error "Pasta de dados não encontrada: $PastaDados"
    return
}

$arquivoTeste = Join-Path $PastaDados 'ativo-confidencial.txt'
$arquivoStatus = Join-Path $PastaDados 'status-servico.txt'
$resultados = @()

if (Test-Path -LiteralPath $arquivoTeste) {
    $acl = Get-Acl -LiteralPath $arquivoTeste
    $listaAcessos = @($acl.Access | ForEach-Object {
            "$($_.IdentityReference) - $($_.FileSystemRights)"
        })

    $resultados += [PSCustomObject]@{
        Dimensão = 'Confidencialidade'
        Evidência = "Arquivo: $($acl.Path)"
        Resultado = 'Permissões coletadas para análise'
        Detalhes = ($listaAcessos -join '; ')
    }

    $hash = Get-FileHash -LiteralPath $arquivoTeste -Algorithm SHA256
    $resultados += [PSCustomObject]@{
        Dimensão = 'Integridade'
        Evidência = 'Hash SHA-256'
        Resultado = 'Hash calculado'
        Detalhes = $hash.Hash
    }
}
else {
    $resultados += [PSCustomObject]@{
        Dimensão = 'Confidencialidade e integridade'
        Evidência = $arquivoTeste
        Resultado = 'Arquivo de teste ausente'
        Detalhes = 'Verifique a pasta dados'
    }
}

$disponivel = Test-Path -LiteralPath $arquivoStatus
if ($disponivel) {
    $status = (Get-Content -LiteralPath $arquivoStatus -Raw -Encoding UTF8).Trim()
    $resultadoDisponibilidade = 'Disponível'
    $detalhesDisponibilidade = "Status informado: $status"
}
else {
    $resultadoDisponibilidade = 'Indisponível'
    $detalhesDisponibilidade = 'Arquivo de status não encontrado'
}

$resultados += [PSCustomObject]@{
    Dimensão = 'Disponibilidade'
    Evidência = $arquivoStatus
    Resultado = $resultadoDisponibilidade
    Detalhes = $detalhesDisponibilidade
}

$resultados | Format-Table -Wrap -AutoSize
Write-Host ''
Write-Host 'Pergunta para discussão: qual controle poderia reduzir o risco observado em cada dimensão?' -ForegroundColor Yellow

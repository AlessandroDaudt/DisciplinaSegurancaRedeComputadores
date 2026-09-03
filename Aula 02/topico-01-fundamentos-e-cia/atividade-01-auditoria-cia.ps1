[CmdletBinding()]
param(
    [string]$PastaDados
)

if ([string]::IsNullOrWhiteSpace($PastaDados)) {
    $PastaDados = Join-Path $PSScriptRoot 'dados'
}

Write-Host 'ATIVIDADE 01 - AUDITORIA DA TRIADE CIA' -ForegroundColor Cyan
Write-Host 'O script realiza somente verificacoes locais de leitura.' -ForegroundColor DarkGray
Write-Host ''

if (-not (Test-Path -LiteralPath $PastaDados)) {
    Write-Error "Pasta de dados nao encontrada: $PastaDados"
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
        Dimensao = 'Confidencialidade'
        Evidencia = "Arquivo: $($acl.Path)"
        Resultado = 'Permissoes coletadas para analise'
        Detalhes = ($listaAcessos -join '; ')
    }

    $hash = Get-FileHash -LiteralPath $arquivoTeste -Algorithm SHA256
    $resultados += [PSCustomObject]@{
        Dimensao = 'Integridade'
        Evidencia = 'Hash SHA-256'
        Resultado = 'Hash calculado'
        Detalhes = $hash.Hash
    }
}
else {
    $resultados += [PSCustomObject]@{
        Dimensao = 'Confidencialidade e integridade'
        Evidencia = $arquivoTeste
        Resultado = 'Arquivo de teste ausente'
        Detalhes = 'Verifique a pasta dados'
    }
}

$disponivel = Test-Path -LiteralPath $arquivoStatus
if ($disponivel) {
    $status = (Get-Content -LiteralPath $arquivoStatus -Raw -Encoding UTF8).Trim()
    $resultadoDisponibilidade = 'Disponivel'
    $detalhesDisponibilidade = "Status informado: $status"
}
else {
    $resultadoDisponibilidade = 'Indisponivel'
    $detalhesDisponibilidade = 'Arquivo de status nao encontrado'
}

$resultados += [PSCustomObject]@{
    Dimensao = 'Disponibilidade'
    Evidencia = $arquivoStatus
    Resultado = $resultadoDisponibilidade
    Detalhes = $detalhesDisponibilidade
}

$resultados | Format-Table -Wrap -AutoSize
Write-Host ''
Write-Host 'Pergunta para discussao: qual controle poderia reduzir o risco observado em cada dimensao?' -ForegroundColor Yellow

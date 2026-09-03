[CmdletBinding()]
param(
    [string[]]$Arquivos
)

Write-Host 'ATIVIDADE 06 - AUTENTICIDADE E ASSINATURA DIGITAL' -ForegroundColor Cyan
Write-Host 'Apenas assinaturas serao consultadas; nenhum arquivo sera executado.' -ForegroundColor DarkGray
Write-Host ''

if (-not (Get-Command Get-AuthenticodeSignature -ErrorAction SilentlyContinue)) {
    Write-Error 'Get-AuthenticodeSignature nao esta disponivel neste ambiente.'
    return
}

if ($null -eq $Arquivos -or $Arquivos.Count -eq 0) {
    $Arquivos = @(
        (Join-Path (Join-Path $PSScriptRoot 'dados') 'script-teste.ps1'),
        (Join-Path $PSHOME 'powershell.exe')
    )
}

$resultados = @()
foreach ($arquivo in $Arquivos) {
    if (-not (Test-Path -LiteralPath $arquivo)) {
        $resultados += [PSCustomObject]@{
            Arquivo = $arquivo
            Status = 'Arquivo nao encontrado'
            Signatario = '-'
            Mensagem = '-'
        }
        continue
    }

    $assinatura = Get-AuthenticodeSignature -FilePath $arquivo
    $signatario = '-'
    if ($null -ne $assinatura.SignerCertificate) {
        $signatario = $assinatura.SignerCertificate.Subject
    }

    $resultados += [PSCustomObject]@{
        Arquivo = $arquivo
        Status = $assinatura.Status
        Signatario = $signatario
        Mensagem = $assinatura.StatusMessage
    }
}

$resultados | Format-Table -Wrap -AutoSize
Write-Host ''
Write-Host 'Pergunta para discussao: autenticidade e integridade sao exatamente a mesma coisa?' -ForegroundColor Yellow

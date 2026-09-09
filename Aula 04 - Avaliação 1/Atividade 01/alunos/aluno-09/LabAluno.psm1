# Módulo auxiliar dos aplicativos gráficos da Atividade 01.
Set-StrictMode -Version Latest

function Resolve-LabHttpsTarget {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseUrl
    )

    try {
        $uri = [System.Uri]$BaseUrl
    }
    catch {
        throw "O alvo informado não é uma URL válida."
    }

    if ($uri.Scheme -ne "https") {
        throw "O alvo precisa usar HTTPS."
    }

    $hostName = $uri.Host.ToLowerInvariant()
    $isLocalTarget = @("127.0.0.1", "localhost") -contains $hostName
    $isAllowedPrivateTarget = $false
    $targetAddress = $null

    if ([System.Net.IPAddress]::TryParse($uri.Host, [ref]$targetAddress) -and
        $targetAddress.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork) {
        $octets = $targetAddress.GetAddressBytes()
        $isAllowedPrivateTarget = ($octets[0] -eq 10) -or
            (($octets[0] -eq 192) -and ($octets[1] -eq 168))
    }

    if (-not ($isLocalTarget -or $isAllowedPrivateTarget)) {
        throw "Por segurança, o alvo precisa ser localhost, 127.0.0.1, 10.0.0.0/8 ou 192.168.0.0/16."
    }

    if ($uri.Port -ne 8443) {
        throw "Por segurança, a porta autorizada é 8443."
    }

    return $uri
}

function Get-Lab7Zip {
    $command = Get-Command 7z.exe -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        return $command.Source
    }

    $paths = @(
        "C:\Program Files\7-Zip\7z.exe",
        "C:\Program Files\7-Zip\7zz.exe",
        "C:\Users\$env:USERNAME\AppData\Local\Programs\7-Zip\7z.exe"
    )

    foreach ($path in $paths) {
        if (Test-Path -LiteralPath $path) {
            return $path
        }
    }

    throw "7z.exe não foi encontrado. Instale 7-Zip com winget e abra o PowerShell novamente."
}

function Limit-LabText {
    param(
        [AllowNull()]
        [string]$Text,

        [int]$Maximum = 12000
    )

    if ($null -eq $Text) {
        return ""
    }

    if ($Text.Length -le $Maximum) {
        return $Text
    }

    return $Text.Substring(0, $Maximum) + "`r`n...[resposta truncada]"
}

function Normalize-LabText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    $normalized = $Text -replace "`r`n", "`n"
    $normalized = $normalized -replace "`r", "`n"
    $normalized = $normalized -replace "\s+", " "
    return $normalized.Trim()
}

Export-ModuleMember -Function Resolve-LabHttpsTarget, Get-Lab7Zip, Limit-LabText, Normalize-LabText

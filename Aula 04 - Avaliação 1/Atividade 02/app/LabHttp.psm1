# Módulo auxiliar usado pelos dois aplicativos gráficos.
# Os únicos arquivos .ps1 executados pelos alunos são Analise-HTTP.ps1
# e Exploracao-HTTP.ps1; ambos abrem uma interface gráfica.
Set-StrictMode -Version Latest

function Resolve-LabTarget {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseUrl
    )

    if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
        throw "Informe o endereço do laboratório."
    }

    try {
        $uri = [System.Uri]$BaseUrl
    }
    catch {
        throw "O endereço informado não é uma URL válida."
    }

    if ($uri.Scheme -ne "http") {
        throw "O laboratório aceita somente HTTP local."
    }

    $allowedHosts = @("127.0.0.1", "localhost")
    if ($allowedHosts -notcontains $uri.Host.ToLowerInvariant()) {
        throw "Por segurança, o alvo precisa ser 127.0.0.1 ou localhost."
    }

    $port = $uri.Port
    if ($port -le 0) {
        $port = 80
    }

    [pscustomobject]@{
        Host = $uri.Host
        Port = $port
        Display = "http://$($uri.Host):$port"
    }
}

function Send-LabHttpRequest {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Target,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not $Path.StartsWith("/")) {
        throw "O caminho HTTP precisa começar com /."
    }

    $client = New-Object System.Net.Sockets.TcpClient
    $stream = $null
    $memory = New-Object System.IO.MemoryStream

    try {
        $client.ReceiveTimeout = 7000
        $client.SendTimeout = 7000
        $client.Connect($Target.Host, $Target.Port)
        $stream = $client.GetStream()

        # O request line é montado manualmente para manter os escapes %2e
        # intactos até o servidor. Isso reproduz a observação do laboratório
        # sem permitir comandos ou caminhos arbitrários na interface.
        $request = "GET $Path HTTP/1.1`r`nHost: $($Target.Host)`r`nConnection: close`r`nUser-Agent: Aula04-Lab/1.0`r`n`r`n"
        $requestBytes = [System.Text.Encoding]::ASCII.GetBytes($request)
        $stream.Write($requestBytes, 0, $requestBytes.Length)
        $stream.Flush()

        $buffer = New-Object byte[] 8192
        while ($true) {
            try {
                $read = $stream.Read($buffer, 0, $buffer.Length)
            }
            catch [System.IO.IOException] {
                break
            }

            if ($read -le 0) {
                break
            }

            $memory.Write($buffer, 0, $read)
        }

        $raw = [System.Text.Encoding]::UTF8.GetString($memory.ToArray())
        $sections = $raw -split "`r?`n`r?`n", 2
        $headerText = $sections[0]
        $body = ""
        if ($sections.Count -gt 1) {
            $body = $sections[1]
        }

        $statusCode = 0
        $statusMatch = [regex]::Match($headerText, "(?m)^HTTP/\d\.\d\s+(\d{3})")
        if ($statusMatch.Success) {
            $statusCode = [int]$statusMatch.Groups[1].Value
        }

        $server = ""
        $serverMatch = [regex]::Match($headerText, "(?im)^Server:\s*(.+)$")
        if ($serverMatch.Success) {
            $server = $serverMatch.Groups[1].Value.Trim()
        }

        [pscustomobject]@{
            Request = $request
            StatusCode = $statusCode
            Server = $server
            Headers = $headerText
            Body = $body
            Raw = $raw
        }
    }
    finally {
        if ($null -ne $stream) {
            $stream.Dispose()
        }
        $memory.Dispose()
        $client.Dispose()
    }
}

function Get-LabServerVersion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerHeader
    )

    $match = [regex]::Match($ServerHeader, "Apache/(\d+\.\d+\.\d+)")
    if ($match.Success) {
        return $match.Groups[1].Value
    }

    return "não identificada"
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

Export-ModuleMember -Function Resolve-LabTarget, Send-LabHttpRequest, Get-LabServerVersion, Limit-LabText

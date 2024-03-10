class DuckDnsException : Exception {
    DuckDnsException([string]$Message) : base([string]$Message) {}
}

class DuckDnsNotImplementedException : DuckDnsException {
    DuckDnsNotImplementedException([string]$Message) : base([string]$Message) {}
}

class DuckDnsInternalErrorException : DuckDnsException {
    DuckDnsInternalErrorException([string]$Message) : base([string]$Message) {}
}

function Test-DuckDnsTemporaryIpv6Address {
  $_.SuffixOrigin -ceq 'Random'
}

function Get-DuckDnsIpv6PreferredAddress {
    Get-NetIPAddress -AddressFamily IPv6 |
    Where-Object { $_.AddressState -eq 'Preferred' } |
    Where-Object { $_.PrefixOrigin -eq 'RouterAdvertisement' } |
    Where-Object { -not (Test-DuckDnsTemporaryIpv6Address $_) }
}

function New-DuckDnsUpdateUri {
    param(
        [Parameter(Mandatory)][string]$Domain,
        [Parameter(Mandatory)][string]$Token,
        [ValidateSet("IPv4", "IPv6", "Both", "")]
        [string]$Update = ""
    )

    switch -Exact ($Update) {
        "IPv4" {
            throw [DuckDnsNotImplementedException]::new("IPv4 is not implemented.")
        }
        "IPv6" {
            $ipv6AddressArray = Get-DuckDnsIpv6PreferredAddress
            if ($ipv6AddressArray.Count -eq 0) {
                throw [DuckDnsInternalErrorException]::new("No IPv6 preferred address found.")
            }
            $ipv6AddressFirst = $ipv6AddressArray[0]
            $ipv6Address = $ipv6AddressFirst.IPAddress

            $urlTemplate = "https://www.duckdns.org/update?domains={0}&token={1}&ipv6={2}&verbose=true"
            $url = $urlTemplate -f $Domain, $Token, $ipv6Address
        }
        "Both" {
            throw [DuckDnsNotImplementedException]::new("Both is not implemented.")
        }
        default {
            $urlTemplate = "https://www.duckdns.org/update?domains={0}&token={1}&verbose=true"
            $url = $urlTemplate -f $Domain, $Token
        }
    }
    return $url
}

function Invoke-DuckDnsWebRequest {
    param([Parameter(Mandatory)][string]$Uri)

    # As of 2024-02-18, duckdns.org response did not include Content-Type,
    # Invoke-WebRequest had difficulty handling content.
    # Instead, use System.Net.HttpWebRequest as an alternative implementation to get the content.
    # https://stackoverflow.com/questions/51333965
    [System.Net.HttpWebRequest]$request = [System.Net.WebRequest]::Create($Uri) -as [System.Net.HttpWebRequest]
    [System.Net.HttpWebResponse]$response = $request.getResponse()
    $responseStream = $response.getResponseStream()
    $streamReader = [IO.StreamReader]::new($responseStream)
    $body = $streamReader.ReadToEnd()
    $response.Close()

    return $body
}

function Update-DuckDnsDomain {
    param(
        [Parameter(Mandatory)][string]$Domain,
        [Parameter(Mandatory)][string]$Token,
        [ValidateSet("IPv4", "IPv6", "Both", "")]
        [string]$Update = ""
    )

    $uri = New-DuckDnsUpdateUri -Domain $Domain -Token $Token -Update $Update
    $body = Invoke-DuckDnsWebRequest -Uri $uri

    $eventSource = "DuckDnsUpdater"
    Write-EventLog -LogName Application -Source $eventSource -EventID 1 -EntryType Information -Message $body

    return $body
}
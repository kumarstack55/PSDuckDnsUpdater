function New-DuckDnsUpdateUri {
    param(
        [Parameter(Mandatory)][string]$Domain,
        [Parameter(Mandatory)][string]$Token
    )
    $urlTemplate = "https://www.duckdns.org/update?domains={0}&token={1}&verbose=true"
    $url = $urlTemplate -f $Domain, $Token
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

    $body
}

function Update-DuckDnsDomain {
    param(
        [Parameter(Mandatory)][string]$Domain,
        [Parameter(Mandatory)][string]$Token
    )

    $uri = New-DuckDnsUpdateUri -Domain $Domain -Token $Token
    $body = Invoke-DuckDnsWebRequest -Uri $uri

    $eventSource = "DuckDnsUpdater"
    Write-EventLog -LogName Application -Source $eventSource -EventID 1 -EntryType Information -Message $body

    return $body
}
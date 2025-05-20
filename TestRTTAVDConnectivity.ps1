# 1. Azure Virtual Desktop URLs (add more if needed)
$avdUrls = @(
    "rdweb.wvd.microsoft.com",
    "rdgateway.wvd.microsoft.com",
    "rdbroker.wvd.microsoft.com",
    "login.microsoftonline.com",
    "aka.ms",
    "learn.microsoft.com"
    "go.microsoft.com",
    "graph.microsoft.com",
    "windows365.microsoft.com",
    "ecs.office.com"
)

# 2. Custom function to test connectivity and RTT
function Test-AVDConnectivity {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Urls
    )

    $results = @()

    foreach ($url in $Urls) {
        $tcpResult = Test-NetConnection -ComputerName $url -Port 443
        $tcpSuccess = $tcpResult.TcpTestSucceeded
        $rtt = $null

        if ($tcpSuccess) {
            $pingResult = Test-Connection -ComputerName $url -Count 1 -ErrorAction SilentlyContinue
            if ($pingResult) {
                $rtt = ($pingResult | Select-Object -First 1).ResponseTime
            }
        }

        $results += [PSCustomObject]@{
            URL           = $url
            TcpConnection = $tcpSuccess
            RTT           = if ($rtt) { "$rtt ms" } else { "-" }
        }
    }

    # 3. Output markup
    Write-Host ""
    Write-Host "Results:" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ("{0,-35} {1,-15} {2,-10}" -f "URL", "Status", "RTT") -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------" -ForegroundColor Cyan

    foreach ($result in $results) {
        $statusText = ""
        $color = "White"

        if ($result.TcpConnection) {
            $statusText = "✅ Success"
            $color = "Green"
        } else {
            $statusText = "❌ Failed"
            $color = "Red"
        }

        $line = "{0,-35} {1,-15} {2,-10}" -f $result.URL, $statusText, $result.RTT
        Write-Host $line -ForegroundColor $color
    }

    Write-Host "-------------------------------------------------------------" -ForegroundColor Cyan
}

# 4. Test connectivity and write the output
Test-AVDConnectivity -Urls $avdUrls
# Justin Verstijnen Test Round Trip Time for AVD Connectivity script
# Github page: https://github.com/JustinVerstijnen/JV-TestRTTAVDConnectivity
# Let's start!

Write-Host "Script made by..." -ForegroundColor DarkCyan
Write-Host "     _           _   _        __     __            _   _  _                  
    | |_   _ ___| |_(_)_ __   \ \   / /__ _ __ ___| |_(_)(_)_ __   ___ _ __  
 _  | | | | / __| __| | '_ \   \ \ / / _ \ '__/ __| __| || | '_ \ / _ \ '_ \ 
| |_| | |_| \__ \ |_| | | | |   \ V /  __/ |  \__ \ |_| || | | | |  __/ | | |
 \___/ \__,_|___/\__|_|_| |_|    \_/ \___|_|  |___/\__|_|/ |_| |_|\___|_| |_|
                                                       |__/                  " -ForegroundColor DarkCyan

# === PARAMETERS ===
# Azure Virtual Desktop URLs (add more in same convention if needed)
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
# === END PARAMETERS ===


# Step 2: Creating function to test connection with command
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


# Step 3: Formatting a nice table for the results
Write-Host ""
Write-Host "Results:" -ForegroundColor Cyan
Write-Host "-------------------------------------------------------------" -ForegroundColor Cyan
Write-Host ("{0,-35} {1,-15} {2,-10}" -f "URL", "Status", "RTT") -ForegroundColor Cyan
Write-Host "-------------------------------------------------------------" -ForegroundColor Cyan

    foreach ($result in $results) {
        $statusText = ""
        $color = "White"

        if ($result.TcpConnection) {
            $statusText = "Success"
            $color = "Green"
        } else {
            $statusText = "Failed"
            $color = "Red"
        }

        $line = "{0,-35} {1,-15} {2,-10}" -f $result.URL, $statusText, $result.RTT
        Write-Host $line -ForegroundColor $color
    }

    Write-Host "-------------------------------------------------------------" -ForegroundColor Cyan
}


# Step 4: Printing the results and wait for 50 seconds
Test-AVDConnectivity -Urls $avdUrls
Start-Sleep -Seconds 50

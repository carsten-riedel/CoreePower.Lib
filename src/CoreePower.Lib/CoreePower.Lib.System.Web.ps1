if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) { 
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

<#
.SYNOPSIS
Downloads a file from a URL that may involve one or more redirects.

.DESCRIPTION
The Get-RedirectDownload function downloads a file from the specified URL that may involve one or more redirects before reaching the final download URL. The function takes two mandatory parameters: $Url, which is the URL to download the file from, and $OutputDirectory, which is the directory to save the downloaded file to.

.PARAMETER Url
The URL to download the file from.

.PARAMETER OutputDirectory
The directory to save the downloaded file to.

.EXAMPLE
Get-RedirectDownload -Url "https://example.com/file.zip" -OutputDirectory "C:\Downloads"
This example downloads the file at the specified URL and saves it to the specified output directory.

.LINK
Link to online documentation or related resources.

#>
function Get-RedirectDownload {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url,
        [Parameter(Mandatory = $true)]
        [string]$OutputDirectory
    )


    # Create a Uri object from the URL and remove any query or fragment parameters.
    $Uri = [System.Uri]::new($Url)
    $UriWithoutParams = [System.UriBuilder]::new($Uri)
    $UriWithoutParams.Query = $null
    $UriWithoutParams.Fragment = $null

    
    # Extract the filename from the URL.
    $FileName = [System.IO.Path]::GetFileName($UriWithoutParams.Uri)

    # Create the output directory if it does not exist.
    if (-not (Test-Path $OutputDirectory)) {
        New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
    }

    $OutputPath = Join-Path $OutputDirectory $FileName

    # Send a HEAD request to the provided URL to check the response status code.
    $request = [System.Net.HttpWebRequest]::Create($UriWithoutParams.Uri)
    $request.Method = 'HEAD'

    # Retrieve the response from the web request.
    $response = $request.GetResponse()

    # Follow any redirects until we reach the final download URL.
    while ($response.StatusCode -eq 'Found') {
        $UriWithoutParams.Path = $response.Headers['Location']
        $request = [System.Net.HttpWebRequest]::Create($UriWithoutParams.Uri)
        $request.Method = 'HEAD'
        $response = $request.GetResponse()
    }

    # Download the file from the final URL and save it to the specified output directory.
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($UriWithoutParams.Uri, $OutputPath)

    return $OutputPath
}
function Get-RedirectDownload2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url,
        [string]$OutputDirectory = "",
        [bool]$RemoveQueryParams = $false
    )

    $Uri = [System.Uri]::new($Url)

    if ($RemoveQueryParams)
    {
        $UriWithoutParams = [System.UriBuilder]::new($Uri)
        $UriWithoutParams.Query = $null
        $UriWithoutParams.Fragment = $null
        $Uri = $UriWithoutParams
    }

    # Send a HEAD request to the provided URL to check the response status code.
    $request = [System.Net.HttpWebRequest]::Create($Uri)
    $request.Method = 'HEAD'

    # Retrieve the response from the web request.
    $response = $request.GetResponse()
   
    foreach ($header in $response.Headers.Keys) {
        #Write-Host "$($header): $($response.Headers[$header])"
    }

    # Extract the filename from the URL.
    $FileName = [System.IO.Path]::GetFileName($response.ResponseUri)


    if ($OutputDirectory -eq "")
    {
        $OutputDirectory = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
    }

    $OutputPath = Join-Path $OutputDirectory $FileName
    # Create the output directory if it does not exist.
    if (-not (Test-Path $OutputDirectory)) {
        New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
    }

    # Download the file from the final URL and save it to the specified output directory.
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($response.ResponseUri, $OutputPath)

    return $OutputPath
}


function Get-GithubLatestReleaseAssetUrls {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RepositoryUrl
    )

    $repositoryUri = [System.Uri]$RepositoryUrl
  
    $result = $(Invoke-GithubApiWithRateLimitMonitoring -monitorRetries 5 -monitorSeconds 2 -apiCallRetries 6 -GitHubApiCall "$($repositoryUri.Scheme)://api.github.com/repos$($repositoryUri.AbsolutePath)/latest").assets.browser_download_url;
    if ($result.EndsWith(".json") -and $result.Count -eq 1)
    {
        $result = Invoke-RestMethod -Uri $result
        $urls = @()

        foreach ($item in $result)
        {
                $urls += $item.downloadUrl
        }
        $result = $urls
    }
    return $result
     
}

function Invoke-GithubApiWithRateLimitMonitoring {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$GitHubApiCall,
        [int]$apiCallRetries = 3,
        [int]$monitorRetries = 20,
        [int]$monitorSeconds = 3
    )

    $retryCount = 0

    while ($true) {
        try {
            if ($retryCount -gt 0) {
                Write-Host "API call attempt $retryCount of $($apiCallRetries). Invoke-RestMethod: $GitHubApiCall"
            }
            $githubApiRequestResult = $(Invoke-RestMethod "$GitHubApiCall")
            return $githubApiRequestResult
        } catch {
            $response = $_.Exception.Response
            if ($response.StatusCode -eq 403) {
                if ($retryCount -lt $apiCallRetries) {
                    $xRateLimitResetExists = $response.Headers.Contains('X-RateLimit-Reset')
                    if ($xRateLimitResetExists) {
                        $xRateLimitResetUnixEpochTime = $response.Headers.GetValues('X-RateLimit-Reset')[0]
                        $xRateLimitResetLocalTime = Convert-UnixEpochToLocalDateTime -UnixEpochTime $xRateLimitResetUnixEpochTime
                        $waitUntil = $xRateLimitResetLocalTime - [System.DateTime]::Now
                        Write-Host "API rate limit exceeded. Reset in $($waitUntil.Minutes) minutes $($waitUntil.Seconds) seconds. Monitoring rate limit for proxy changes..."
                        Monitor-GitHubRateLimit -monitorMaxRetries $monitorRetries -secondsToSleep $monitorSeconds
                        $retryCount++
                    } else {
                        throw "Rate limit exceeded. No X-RateLimit-Reset header found."
                    }
                } else {
                    throw $_.Exception.Message
                }
            } else {
                throw $_.Exception.Message
            }
        }
    }
}



function Monitor-GitHubRateLimit {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param (
        
        [int]$monitorMaxRetries = 20,
        [int]$secondsToSleep = 3
    )

    $retryCount = 1

    while ($retryCount -lt ($monitorMaxRetries+1)) {
        $response = Invoke-RestMethod -Uri "https://api.github.com/rate_limit"
        
        $rateLimitLimit = $response.rate.limit
        $rateLimitRemaining = $response.rate.remaining
        $rateLimitResetTime = $response.rate.reset

        $resetTimeLocalTime = Convert-UnixEpochToLocalDateTime -UnixEpochTime $rateLimitResetTime

        Write-Host "Monitoring github api rate limit. (every $secondsToSleep seconds, Retry: $retryCount of $monitorMaxRetries) Resets at: $resetTimeLocalTime Remaining Requests: $rateLimitRemaining"

        # Check if remaining requests > 0 or reset time has passed
        if ($rateLimitRemaining -gt 0 -or $resetTimeLocalTime -lt [System.DateTime]::Now) {
            Write-Host "Exiting the monitoring."
            return
        }

        # Wait for specified seconds before checking again
        Start-Sleep -Seconds $secondsToSleep
        $retryCount++
    }

    Write-Host "Max retries reached. Exiting the monitoring."
}

function Convert-UnixEpochToLocalDateTime {
    param (
        [double]$UnixEpochTime
    )
    $dateTimeOffset = [System.DateTimeOffset]::FromUnixTimeSeconds($UnixEpochTime)
    $localDateTime = $dateTimeOffset.LocalDateTime
    return $localDateTime
}




function Download-GithubLatestReleaseMatchingAssets {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RepositoryUrl,
        [Parameter(Mandatory)]
        [string[]]$AssetNameFilters,
        [string[]]$BlackList = $null
    )

    $assetUrls = Get-GithubLatestReleaseAssetUrls -RepositoryUrl "$RepositoryUrl"
    $matchedUrl = Filter-ItemsWithLists -InputItems $assetUrls -WhiteListMatch $AssetNameFilters -BlackListMatch $BlackList
    $fileName = $matchedUrl.Split("/")[-1]

    $temporaryDir = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
    if (-not (Test-Path $temporaryDir)) {
        New-Item -ItemType Directory -Path $temporaryDir -Force | Out-Null
    }

    $downloadTargetLocation = "$temporaryDir\$fileName"

    #Invoke-WebRequest -Uri $matchedUrl -OutFile "$downloadTargetLocation"
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($matchedUrl, $downloadTargetLocation)

    return $downloadTargetLocation
}

function Download-String {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param (
        [Parameter(Mandatory)]
        [Uri]$Uri
    )

    #enable unsecure downloads
    $currentServicePointManagerSetting = [System.Net.ServicePointManager]::SecurityProtocol

    if ($uri.Scheme -eq "https")
    {
        #[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 48 # Ssl3
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 192 # Tls
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 768 # Tls11
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 # Tls12
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 12288 # Tls13
    } elseif ($uri.Scheme -eq "http") {
        [System.Net.ServicePointManager]::SecurityProtocol = 0
    }


    try {
        $str = (New-Object Net.WebClient).DownloadString($Uri.OriginalString) 
    }
    catch {
        Write-Host "DownloadString thrown a exception"
        Write-Host "$($PSItem.Exception.Message)"
        $str = ""
    }

    [System.Net.ServicePointManager]::SecurityProtocol = $currentServicePointManagerSetting

    return [string]$str
}

function Find-AHrefInHtml {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param (
        [Parameter(Mandatory)]
        [string]$html,
        [Parameter(Mandatory)]
        [string]$url
    )

    $retval = @()

    $RegExPattern = [regex]::new('<a href\s*=\s*\"(.*?)\".*>')

    $regexMatches = $RegExPattern.Matches($html)

    foreach($match in $regexMatches)
    {
        $ma = [System.Uri]$match.Groups[1].Value
        if ($null -eq $ma.AbsoluteUri)
        {
            $joined = "$($url.TrimEnd('/'))/$($ma.ToString().TrimStart('/'))"
        }
        else {
            $joined = "$ma"
        }
        
        $retval += [System.Uri]$joined
    }

    return $retval
}

function Find-Links {
    param (
    [Parameter(Mandatory)]
    [string]$url
    )

    try {
        $uri = [System.URI]$url
    }
    catch {
         write-error "Error parsing URL"
    }
   

    $content = Download-String -Uri $uri
    $links = Find-AHrefInHtml -url $url -html $content
    return $links
}

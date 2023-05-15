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
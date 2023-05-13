#https://learn.microsoft.com/en-us/nuget/consume-packages/configuring-nuget-behavior
#https://learn.microsoft.com/en-us/nuget/consume-packages/managing-the-global-packages-and-cache-folders

if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

function Initialize-NugetSourceRegistered {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    
    $nugetSource = Get-PackageSource -Name NuGet -Provider Nuget -ErrorAction SilentlyContinue
    if (!$nugetSource) {
        Register-PackageSource -Name NuGet -Location "https://www.nuget.org/api/v2/" -ProviderName NuGet -Trusted | Out-Null
        #Write-Output "NuGet package source registered successfully"
    }

    if ($nugetSource.IsTrusted -eq $false)
    {
        Set-PackageSource -Name NuGet -NewName NuGet -Trusted -ProviderName NuGet
    }

    $nugetSource = Get-PackageSource -Name nuget.org -Provider Nuget -ErrorAction SilentlyContinue
    if (!$nugetSource) {

        Register-PackageSource -Name nuget.org -Location "https://api.nuget.org/v3/index.json" -ProviderName NuGet -Trusted -SkipValidate | Out-Null
        #Write-Output "Nuget.org package source registered successfully."
    }

    if ($nugetSource.IsTrusted -eq $false)
    {
        Set-PackageSource -Name nuget.org -ProviderName NuGet -Trusted -SkipValidate 
    }
}

function Install-NugetToPackagemanagement {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$RequiredVersion = $null,
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [ModuleScope]::LocalMachine)  {
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Install-Package -Name $Name -RequiredVersion $RequiredVersion -Source NuGet -ProviderName NuGet -Scope AllUsers  | Out-Null
        $global:ProgressPreference = $originalProgressPreference
    }
    elseif ($Scope -eq [ModuleScope]::CurrentUser) {
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Install-Package -Name $Name -RequiredVersion $RequiredVersion -Source NuGet -ProviderName NuGet -Scope CurrentUser | Out-Null
        $global:ProgressPreference = $originalProgressPreference
    }
}

function Get-NugetToPackagemanagementPathLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$RequiredVersion = $null,
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [ModuleScope]::LocalMachine) {
        return Find-Package -Name $Name -AllVersions -Source "$($Env:Programfiles)\AppData\Local\PackageManagement\NuGet\Packages" | Select-Object -First 1 @{Name='Path'; Expression={"$($_.Source)\$($_.Name).$($_.Version)"}} | Select-Object -ExpandProperty Path
    }
    elseif ($Scope -eq [ModuleScope]::CurrentUser) {
        return Find-Package -Name $Name -AllVersions -Source "$($env:userprofile)\AppData\Local\PackageManagement\NuGet\Packages" | Select-Object -First 1 @{Name='Path'; Expression={"$($_.Source)\$($_.Name).$($_.Version)"}}  | Select-Object -ExpandProperty Path
    }
}

function Initialize-NugetPackageProviderInstalled {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    $nugetProvider = Get-PackageProvider -ListAvailable -ErrorAction SilentlyContinue | Where-Object Name -eq "nuget"
    if (-not($nugetProvider -and $nugetProvider.Version -ge "2.8.5.201")) {
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope $Scope -Force | Out-Null
        $global:ProgressPreference = $originalProgressPreference
    }
}

function Initialize-PowerShellGetLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }
    $originalProgressPreference = $global:ProgressPreference
    $global:ProgressPreference = 'SilentlyContinue'
    Update-ModulesLatest -ModuleNames @("PowerShellGet") -Scope $Scope  | Out-Null
    Set-PackageSource -Name PSGallery -Trusted -ProviderName PowerShellGet | Out-Null
    $global:ProgressPreference = $originalProgressPreference
}

function Initialize-PackageManagementLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }
    $originalProgressPreference = $global:ProgressPreference
    $global:ProgressPreference = 'SilentlyContinue'
    Update-ModulesLatest -ModuleNames @("PackageManagement") -Scope $Scope | Out-Null
    $global:ProgressPreference = $originalProgressPreference
}

function Initialize-Powershell {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    Initialize-NugetPackageProviderInstalled -Scope $Scope
    Initialize-PowerShellGetLatest -Scope $Scope
    Initialize-PackageManagementLatest -Scope $Scope
    Initialize-NugetSourceRegistered
}

function Initialize-CorePowerLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("cpcp")] 
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($null -ne $MyInvocation.MyCommand.Module)
    {
        $module = Get-Module -Name $MyInvocation.MyCommand.Module.Name
        $moduleName = $module.Name
        $moduleVersion = $module.Version
    }
    else {
        $moduleName = $MyInvocation.MyCommand.CommandType
        $moduleVersion = "None"
    }


    Write-OutputText -PrefixText "$moduleName" -ContentText "Useing module version: $moduleVersion" -SuffixText "Info"

    $updatesDone = $false
    
    Write-OutputText -PrefixText "$moduleName" -ContentText "Initialize-NugetPackageProviderInstalled" -SuffixText "Initiated"
    Initialize-NugetPackageProviderInstalled -Scope $Scope
    Write-OutputText -PrefixText "$moduleName" -ContentText "Initialize-NugetPackageProviderInstalled" -SuffixText "Completed"

    Write-OutputText -PrefixText "$moduleName" -ContentText "Initialize-PowerShellGetLatest" -SuffixText "Initiated"
    Initialize-PowerShellGetLatest  -Scope $Scope
    Write-OutputText -PrefixText "$moduleName" -ContentText "Initialize-PowerShellGetLatest" -SuffixText "Completed"

    Write-OutputText -PrefixText "$moduleName" -ContentText "Initialize-PackageManagementLatest" -SuffixText "Initiated"
    Initialize-PackageManagementLatest  -Scope $Scope
    Write-OutputText -PrefixText "$moduleName" -ContentText "Initialize-PackageManagementLatest" -SuffixText "Completed"

    Write-OutputText -PrefixText "$moduleName" -ContentText "Update-ModulesLatest CoreePower.Module CoreePower.Config" -SuffixText "Initiated"
    $updatesDone = Update-ModulesLatest -ModuleNames @("CoreePower.Module","CoreePower.Config") -Scope $Scope
    Write-OutputText -PrefixText "$moduleName" -ContentText "Update-ModulesLatest CoreePower.Module CoreePower.Config" -SuffixText "Completed"

    Write-OutputText -PrefixText "$moduleName" -ContentText "Initialize-NugetSourceRegistered" -SuffixText "Initiated"
    Initialize-NugetSourceRegistered
    Write-OutputText -PrefixText "$moduleName" -ContentText "Initialize-NugetSourceRegistered" -SuffixText "Completed"

    Write-OutputText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Check"
    if (-not(Get-Command "7z" -ErrorAction SilentlyContinue)) {
        $sz = $(Invoke-RestMethod "https://sourceforge.net/projects/sevenzip/best_release.json").platform_releases.windows
        $temporaryDir = New-TempDirectory
        Write-OutputText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Download"
        $file = Get-RedirectDownload -Url "$($sz.url)" -OutputDirectory "$temporaryDir"
        Write-OutputText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Download Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Change Invoker"
        Set-AsInvoker -FilePath "$file"
        Write-OutputText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Change Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Extracting"
        $output, $errorOutput = Start-ProcessSilent -File "$file" -Arguments "/S /D=`"$($env:localappdata)\7zip`""
        Write-OutputText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Extracting Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\7zip" -Scope CurrentUser
        Write-OutputText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Adding envar Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Available"
    } else {
        Write-OutputText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Already available"
    }
    Write-OutputText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Completed"

    
    Write-OutputText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Check"
    if (-not(Get-Command "git" -ErrorAction SilentlyContinue)) {
        Write-OutputText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Download"
        $file = Download-GithubLatestReleaseMatchingAssets -RepositoryUrl "https://github.com/git-for-windows/git/releases" -AssetNameFilters @("Portable","64-bit",".exe")
        Write-OutputText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Download Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Extracting"
        &7z x -y -o"$($env:localappdata)\PortableGit" "$file" | Out-Null
        Write-OutputText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Extracting Completed"

        Write-OutputText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Initializing"
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $currendir = Get-Location
        Set-Location "$($env:localappdata)\PortableGit"
        $psi.FileName = "$($env:localappdata)\PortableGit\git-bash.exe"
        $psi.Arguments = "--hide --no-cd --command=post-install.bat"
        $psi.WorkingDirectory = [System.IO.Path]::GetDirectoryName("$($env:localappdata)\PortableGit\git-bash.exe")
        $psi.UseShellExecute = $false
        $process = [System.Diagnostics.Process]::Start($psi)
        $process.WaitForExit()
        Set-Location $currendir
        Write-OutputText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Initializing Completed"

        Write-OutputText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\PortableGit\cmd" -Scope CurrentUser
        Write-OutputText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Adding envar Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Available"
    } else {
        Write-OutputText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Already available"
    }
    Write-OutputText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Completed"


    Write-OutputText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Check"
    if (-not(Get-Command "gh" -ErrorAction SilentlyContinue)) {
        Write-OutputText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Download"
        $file = Download-GithubLatestReleaseMatchingAssets -RepositoryUrl "https://github.com/cli/cli/releases" -AssetNameFilters @("windows","amd64",".zip")
        Write-OutputText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Download Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Extracting"
        $temporaryDir = New-TempDirectory
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Expand-Archive -Path $file -DestinationPath $temporaryDir
        $global:ProgressPreference = $originalProgressPreference
        $source = "$temporaryDir"
        $destination = "$($env:localappdata)\githubcli"
        Write-OutputText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Extracting Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Copying"
        Copy-Recursive -Source $source -Destination $destination
        Write-OutputText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Copying  Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\githubcli\bin" -Scope CurrentUser
        Write-OutputText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Adding envar Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Available"
    } else {
        Write-OutputText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Already available"
    }
    Write-OutputText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Completed"

    
    Write-OutputText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Check"
    if (-not(Get-Command "nuget" -ErrorAction SilentlyContinue)) {
        Write-OutputText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Install"
        Install-NugetToPackagemanagement -Name "Nuget.Commandline"
        Write-OutputText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Install Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Adding envar"
        $path = Get-NugetToPackagemanagementPathLatest -Name "Nuget.Commandline"
        AddPathEnviromentVariable -Path "$path\tools" -Scope CurrentUser
        Write-OutputText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Adding envar Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Available"
    } 
    else {
        Write-OutputText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Already available"
    }
    Write-OutputText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Completed"

    Write-OutputText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Check"
    if (-not(Get-Command "dotnet" -ErrorAction SilentlyContinue)) {
        Write-OutputText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Deploy"
        &powershell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; &([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Channel LTS" | Out-Null
        Write-OutputText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Deploy Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\Microsoft\dotnet" -Scope CurrentUser
        Write-OutputText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Adding envar Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Available"
    } else {
        Write-OutputText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Already available"
    }
    Write-OutputText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Completed"

    Write-OutputText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Check"
    if (-not((Test-Path "$($env:localappdata)\vscodezip\code.exe" -PathType Leaf))) {
        Write-OutputText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Download"
        $temporaryDir = New-TempDirectory
        $file = Get-RedirectDownload2 -Url "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"
        Write-OutputText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Download Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Extracting"
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Expand-Archive -Path $file -DestinationPath $temporaryDir
        $global:ProgressPreference = $originalProgressPreference
        Write-OutputText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Extracting Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Copying"
        Copy-Recursive -Source $temporaryDir -Destination "$($env:localappdata)\vscodezip"
        Write-OutputText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Copying Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\vscodezip\bin" -Scope CurrentUser
        Write-OutputText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Adding envar Completed"
        Write-OutputText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Available"
    } else {
        Write-OutputText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Already available"
    }

    Write-OutputText -PrefixText "$moduleName" -ContentText "Update-ModulesLatest CoreePower.Lib" -SuffixText "Initiated"
    $updatesDone = $updatesDone -or (Update-ModulesLatest -ModuleNames @("CoreePower.Lib") -Scope $Scope)
    Write-OutputText -PrefixText "$moduleName" -ContentText "Update-ModulesLatest CoreePower.Lib" -SuffixText "Completed"

    if ($updatesDone)
    {
        Write-OutputText -PrefixText "$moduleName" -ContentText "A restart of Powershell is required to implement the update." -SuffixText "Info"
    }

}


function Get-GithubLatestReleaseAssetUrls {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RepositoryUrl
    )

    $repositoryUri = [System.Uri]$RepositoryUrl
  
    return $(Invoke-RestMethod "$($repositoryUri.Scheme)://api.github.com/repos$($repositoryUri.AbsolutePath)/latest").assets.browser_download_url
}

function Download-GithubLatestReleaseMatchingAssets {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RepositoryUrl,
        [Parameter(Mandatory)]
        [string[]]$AssetNameFilters
    )

    $assetUrls = Get-GithubLatestReleaseAssetUrls -RepositoryUrl "$RepositoryUrl"
    $matchedUrl = Find-ItemsContainingAllStrings -InputItems $assetUrls -SearchStrings $AssetNameFilters
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

function AddPathEnviromentVariable {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }
    
    if ($Scope -eq [ModuleScope]::CurrentUser) {
        $USERPATHS = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::User)
        $NEW = "$USERPATHS;$Path"
        [System.Environment]::SetEnvironmentVariable("PATH",$NEW,[System.EnvironmentVariableTarget]::User)
    }
    elseif ($Scope -eq [ModuleScope]::LocalMachine) {
        $MACHINEPATHS = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::Machine)
        $NEW = "$MACHINEPATHS;$Path"
        [System.Environment]::SetEnvironmentVariable("PATH",$NEW,[System.EnvironmentVariableTarget]::Machine)
    }

    $PROCESSPATHS = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::Process)
    $NEW = "$PROCESSPATHS;$Path"
    [System.Environment]::SetEnvironmentVariable("PATH",$NEW,[System.EnvironmentVariableTarget]::Process)
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

<#
.SYNOPSIS
Starts a new process without creating a visible window.

.DESCRIPTION
The Start-ProcessSilent function starts a new process with the specified file and arguments, and captures both the standard output and standard error streams. This function is designed to be used with applications that normally create a visible window, and suppresses the window from appearing on the desktop.

.PARAMETER File
The path to the file to be executed.

.PARAMETER Arguments
The arguments to be passed to the file.

.EXAMPLE
PS C:\> $output, $errorOutput = Start-ProcessSilent -File "$((Get-Command "cmd.exe").Path)" -Arguments "/C dir"
Starts the specified file with the specified arguments, and captures both the standard output and standard error streams.

#>
function Start-ProcessSilent {
    param(
        [Parameter(Mandatory=$true)]
        [string]$File,

        [Parameter(Mandatory=$false)]
        [string]$Arguments = ""
    )

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $File
    $psi.Arguments = $Arguments
    $psi.WorkingDirectory = [System.IO.Path]::GetDirectoryName($File)
    $psi.CreateNoWindow = $true
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    $process = [System.Diagnostics.Process]::Start($psi)
    $output = $process.StandardOutput.ReadToEnd()
    $errorOutput = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    return ,$output, $errorOutput
}
function CorePower-AdminSetup {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("cpadmin")] 
    param ()
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope ([Module]::LocalMachine)))
    {
        return
    }
}


if ($Host.Name -match "Visual Studio Code")
{
    function FOO {
        write-output "HEY"
        Start-Sleep 2
        write-output "HOY"
        }

       Start-Job -ScriptBlock ${Function:FOO} -Name "ddd" | Out-Null
   
       Wait-Job -Name @('ddd')   | Out-Null
     
       Receive-Job -Name @('ddd') -OutVariable result | Out-Null
       
       $state = Get-Job -State Completed
   
       $state | Remove-Job
   
       $s = $result
    
       $x=1
       Initialize-CorePowerLatest

}



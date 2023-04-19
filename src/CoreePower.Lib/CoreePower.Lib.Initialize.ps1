#https://learn.microsoft.com/en-us/nuget/consume-packages/configuring-nuget-behavior
#https://learn.microsoft.com/en-us/nuget/consume-packages/managing-the-global-packages-and-cache-folders
#nuget install Newtonsoft.Json
function Initialize-NugetSourceRegistered {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    
    $nugetSource = Get-PackageSource -Name NuGet -Provider Nuget -ErrorAction SilentlyContinue
    if (!$nugetSource) {
        Register-PackageSource -Name NuGet -Location "https://www.nuget.org/api/v2/" -ProviderName NuGet -Trusted | Out-Null
        Write-Output "NuGet package source added successfully."
    }

    if ($nugetSource.IsTrusted -eq $false)
    {
        Set-PackageSource -Name NuGet -NewName NuGet -Trusted -ProviderName NuGet
    }

    $nugetSource = Get-PackageSource -Name nuget.org -Provider Nuget -ErrorAction SilentlyContinue
    if (!$nugetSource) {

        Register-PackageSource -Name nuget.org -Location "https://api.nuget.org/v3/index.json" -ProviderName NuGet -Trusted -SkipValidate | Out-Null
         Write-Output "nuget.org package source added successfully."
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
        [Scope]$Scope = [Scope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [Scope]::LocalMachine)
    {
        Install-Package -Name $Name -RequiredVersion $RequiredVersion -Source NuGet -ProviderName NuGet -Scope AllUsers | Out-Null
    }
    elseif ($Scope -eq [Scope]::CurrentUser) {
        Install-Package -Name $Name -RequiredVersion $RequiredVersion -Source NuGet -ProviderName NuGet -Scope CurrentUser | Out-Null
    }
}

function Get-NugetToPackagemanagementPathLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$RequiredVersion = $null,
        [Scope]$Scope = [Scope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [Scope]::LocalMachine) {
        return Find-Package -Name $Name -AllVersions -Source "$($Env:Programfiles)\AppData\Local\PackageManagement\NuGet\Packages" | Select-Object -First 1 @{Name='Path'; Expression={"$($_.Source)\$($_.Name).$($_.Version)"}} | Select-Object -ExpandProperty Path
    }
    elseif ($Scope -eq [Scope]::CurrentUser) {
        return Find-Package -Name $Name -AllVersions -Source "$($env:userprofile)\AppData\Local\PackageManagement\NuGet\Packages" | Select-Object -First 1 @{Name='Path'; Expression={"$($_.Source)\$($_.Name).$($_.Version)"}}  | Select-Object -ExpandProperty Path
    }
}

function Initialize-NugetPackageProviderInstalled {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Scope]$Scope = [Scope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    $nugetProvider = Get-PackageProvider -ListAvailable -ErrorAction SilentlyContinue | Where-Object Name -eq "nuget"
    if (-not($nugetProvider -and $nugetProvider.Version -ge "2.8.5.201")) {
         Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope $Scope -Force | Out-Null
         Write-Output "NuGet package provider successfully installed."
    }
}

function Initialize-PowerShellGetLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Scope]$Scope = [Scope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }
    Update-ModulesLatest -ModuleNames @("PowerShellGet") -Scope $Scope
    Set-PackageSource -Name PSGallery -Trusted -ProviderName PowerShellGet | Out-Null
}

function Initialize-PackageManagementLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Scope]$Scope = [Scope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }
    Update-ModulesLatest -ModuleNames @("PackageManagement") -Scope $Scope
}

function Initialize-Powershell {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Scope]$Scope = [Scope]::CurrentUser
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
        [Scope]$Scope = [Scope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }
    
    Initialize-NugetPackageProviderInstalled -Scope $Scope
    Initialize-PowerShellGetLatest  -Scope $Scope
    Initialize-PackageManagementLatest  -Scope $Scope
    Update-ModulesLatest -ModuleNames @("CoreePower.Module","CoreePower.Config") -Scope $Scope
    Initialize-NugetSourceRegistered

    if (-not(Get-Command "nuget" -ErrorAction SilentlyContinue)) {
        Install-NugetToPackagemanagement -Name "Nuget.Commandline"
        $path = Get-NugetToPackagemanagementPathLatest -Name "Nuget.Commandline"
        AddPathEnviromentVariable -Path "$path\tools" -Scope CurrentUser
    } 

    if (-not(Get-Command "git" -ErrorAction SilentlyContinue)) {
        $file = Download-GithubLatestReleaseMatchingAssets -RepositoryUrl "https://github.com/git-for-windows/git/releases" -AssetNameFilters @("Portable","64-bit",".exe")
        cmd /c "start /min /wait """" ""$file"" -y -o""$($env:localappdata)\PortableGit"" "
        AddPathEnviromentVariable -Path "$($env:localappdata)\PortableGit\cmd" -Scope CurrentUser
    } 

    if (-not(Get-Command "gh" -ErrorAction SilentlyContinue)) {
        
        $file = Download-GithubLatestReleaseMatchingAssets -RepositoryUrl "https://github.com/cli/cli/releases" -AssetNameFilters @("windows","amd64",".zip")
        $temporaryDir = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
        if (-not (Test-Path $temporaryDir)) {
            New-Item -ItemType Directory -Path $temporaryDir -Force | Out-Null
        }
        Expand-Archive -Path $file -DestinationPath $temporaryDir
        
        Copy-Item -Path "$temporaryDir" -Destination "$($env:localappdata)\githubcli" -Recurse -Force -Container
        
        
        $source = "$temporaryDir"
        $destination = "$($env:localappdata)\githubcli"
        
        Get-ChildItem $source -Recurse | Foreach-Object {
            $targetPath = $_.FullName -replace [regex]::Escape($source), $destination
            if ($_.PSIsContainer) {
                New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
            }
            else {
                Copy-Item $_.FullName -Destination $targetPath -Force | Out-Null
            }
        }
        
        #winget install --id GitHub.cli --silent
        #winget install --id GitHub.cli --silent --disable-interactivity --accept-source-agreements --accept-package-agreements
    } 

    if (-not(Get-Command "7z" -ErrorAction SilentlyContinue)) {
        $sz = $(Invoke-RestMethod "https://sourceforge.net/projects/sevenzip/best_release.json").platform_releases.windows
        $file = Get-RedirectDownload -Url "$($sz.url)" -OutputDirectory "C:\temp"
        Set-AsInvoker -FilePath "$file"
        Start-ProcessSilent -File "$file" -Arguments "/S /D=`"$($env:localappdata)\7zip`""
        AddPathEnviromentVariable -Path "$($env:localappdata)\7zip" -Scope CurrentUser
    } 



    Update-ModulesLatest -ModuleNames @("CoreePower.Lib") -Scope $Scope
}

function Get-ModuleInfoExtended {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $ModuleNames,
        [Scope]$Scope = [Scope]::LocalMachine,
        [bool]$ExcludeSystemModules = $false
    )
    
    $LocalModulesAll = Get-Module -ListAvailable $ModuleNames |  Select-Object *,
        @{ Name='BasePath' ; Expression={ $_.ModuleBase.TrimEnd($_.Version.ToString()).TrimEnd('\').TrimEnd($_.Name).TrimEnd('\')  } },
        @{ Name='IsMachine' ; Expression={ ($_.ModuleBase -Like "*$env:ProgramFiles*") -or ($_.ModuleBase -Like "*$env:ProgramW6432*")  } },
        @{ Name='IsUser' ; Expression={ ($_.ModuleBase -Like "*$env:userprofile*") } },
        @{ Name='IsSystem' ; Expression={ ($_.ModuleBase -Like "*$env:SystemRoot*")  } } 

    if ($Scope -eq [Scope]::LocalMachine -and ($ExcludeSystemModules -eq $false))
    {
        return $LocalModulesAll
    }
    elseif ($Scope -eq [Scope]::LocalMachine -and ($ExcludeSystemModules -eq $true)) {
        $LocalAndUser = $LocalModulesAll | Where-Object { $_.IsSystem -eq $false }
        return $LocalAndUser
    }
    elseif ($Scope -eq [Scope]::CurrentUser) {
        $UserModules = $LocalModulesAll | Where-Object { $_.IsUser -eq $true }
        return $UserModules
    }
}

<#
.SYNOPSIS
    Finds and lists updatable PowerShell modules.

.DESCRIPTION
    The Find-UpdatableModules function takes an array of module names and retrieves their update information from the PSGallery repository. 
    It then compares the available versions with locally installed versions and returns a list of modules that have updates available.

.PARAMETER ModuleNames
    An array of module names for which to find update information.

.EXAMPLE
    Find-UpdatableModules -ModuleNames @("ModuleName1", "ModuleName2")
#>
function Find-UpdatableModules {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $ModuleNames,
        [Scope]$Scope = [Scope]::LocalMachine
    )
    
    $AvailableUpdates = Find-Module -Name $ModuleNames -Repository PSGallery | Select-Object @{Name='Name'; Expression={$_.Name}}, @{Name='Version'; Expression={$_.Version}} | Sort-Object Name, Version -Descending
    $LocalModulesAll = Get-ModuleInfoExtended -ModuleNames $ModuleNames -Scope $Scope | Select-Object @{Name='Name'; Expression={$_.Name}}, @{Name='Version'; Expression={$_.Version}} | Sort-Object Name, Version -Descending
    $LatestLocalModules = $LocalModulesAll | Group-Object Name | ForEach-Object { $_.Group | Select-Object -First 1  }

    $ModulesToUpdate = $AvailableUpdates | Where-Object { $currentUpdate = $_; -not ($LatestLocalModules | Where-Object { $_.Name -eq $currentUpdate.Name -and $_.Version -eq $currentUpdate.Version }) }

    return $ModulesToUpdate
}

<#
.SYNOPSIS
    Retrieves a list of locally installed outdated PowerShell modules.

.DESCRIPTION
    The Find-LocalOutdatedModules function takes an array of module names and retrieves information about the locally installed versions.
    It then identifies outdated versions among the installed modules and returns a list of outdated module instances.

.PARAMETER ModuleNames
    An array of module names for which to find outdated installed versions.

.EXAMPLE
    Find-LocalOutdatedModules -ModuleNames @("ModuleName1", "ModuleName2")
#>
function Find-LocalOutdatedModules {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $ModuleNames,
        [Scope]$Scope = [Scope]::CurrentUser
    )

    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    $AllLocalModules = Get-ModuleInfoExtended -ModuleNames $ModuleNames -Scope $Scope -ExcludeSystemModules $true | Sort-Object Name, Version -Descending
    $OutdatedLocalModules = $AllLocalModules | Group-Object Name | ForEach-Object { $_.Group | Select-Object -Skip 1  }

    return $OutdatedLocalModules
}

<#
.SYNOPSIS
    Updates specified PowerShell modules to their latest version.

.DESCRIPTION
    The Update-ModulesLatest function takes an array of module names, identifies the updatable versions, and updates them to the latest version available.
    It installs the updated versions in the CurrentUser scope and imports them, then provides a message to restart the PowerShell session to apply the changes.

.PARAMETER ModuleNames
    An array of module names for which to find updates and apply them.

.EXAMPLE
    Update-ModulesLatest -ModuleNames @("ModuleName1", "ModuleName2")
#>
function Update-ModulesLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $ModuleNames,
        [Scope]$Scope = [Scope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    $UpdatableModules = Find-UpdatableModules -ModuleNames $ModuleNames
    $UpdatesApplied = $false

    foreach($module in $UpdatableModules)
    {
        Write-Output "Installing module: $($module.Name) $($module.Version)" 

        Install-Module -Name $module.Name -RequiredVersion $module.Version -Scope $Scope -Force -AllowClobber | Out-Null
        
        #Write-Output "Importing user module: $($module.Name) $($module.Version)"

        #Import-Module -Name $module.Name -MinimumVersion $module.Version -Force | Out-Null

        $UpdatesApplied = $true
    }

    if ($UpdatesApplied)
    {
        Write-Output "Updates have been applied. Please restart your PowerShell session to ensure that the changes take effect."
    }
}

#CreateModule -Path "C:\temp" -ModuleName "CoreePower.Module" -Description "Library for module management" -Author "Carsten Riedel" 
#UpdateModuleVersion -Path "C:\temp\CoreePower.Module"


function Remove-OutdatedModules {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ModuleNames,
        [Scope]$Scope = [Scope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    $outdated = Find-LocalOutdatedModules -ModuleNames $ModuleNames -Scope $Scope
 
    foreach ($item in $outdated)
    {
        $DirVers = "$($item.BasePath)\$($item.Name)\$($item.Version)"
        Remove-Item -Recurse -Force -Path $DirVers
        Write-Host "User rights removed user module:" $DirVers
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

function Find-ItemsContainingAllStrings {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$InputItems,
        [Parameter(Mandatory)]
        [string[]]$SearchStrings
    )

    $matchedItems = $InputItems | Where-Object {
        $foundStringCount = 0
        foreach ($searchString in $SearchStrings) {
            if ($_.Contains($searchString)) {
                $foundStringCount++
            }
        }
        $foundStringCount -eq $SearchStrings.Count
    }

    return $matchedItems
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

    Invoke-WebRequest -Uri $matchedUrl -OutFile "$downloadTargetLocation"

    return $downloadTargetLocation
}

function AddPathEnviromentVariable {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Scope]$Scope = [Scope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }
    
    if ($Scope -eq [Scope]::CurrentUser) {
        $USERPATHS = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::User)
        $NEW = "$USERPATHS;$Path"
        [System.Environment]::SetEnvironmentVariable("PATH",$NEW,[System.EnvironmentVariableTarget]::User)
    }
    elseif ($Scope -eq [Scope]::LocalMachine) {
        $MACHINEPATHS = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::Machine)
        $NEW = "$MACHINEPATHS;$Path"
        [System.Environment]::SetEnvironmentVariable("PATH",$NEW,[System.EnvironmentVariableTarget]::Machine)
    }

    $PROCESSPATHS = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::Process)
    $NEW = "$PROCESSPATHS;$Path"
    [System.Environment]::SetEnvironmentVariable("PATH",$NEW,[System.EnvironmentVariableTarget]::Process)
}

function Set-AsInvoker {
    param (
        [string] $FilePath
    )

    $bytes = [System.IO.File]::ReadAllBytes($FilePath)

    # Define the byte sequences to search for and replace.
    $searchBytes = [System.Text.Encoding]::ASCII.GetBytes("requireAdministrator`"")
    $replaceBytes = [System.Text.Encoding]::ASCII.GetBytes("asInvoker`"           ")

    # Find the position of the search bytes.
    $pos = IndexOfBytes $bytes $searchBytes

    if ($pos -ge 0) {
        # Replace the search bytes with the replace bytes.
        for ($i = 0; $i -lt $replaceBytes.Length; $i++) {
            $bytes[$pos + $i] = $replaceBytes[$i]
        }

        # Write the modified bytes back to the file.
        [System.IO.File]::WriteAllBytes($FilePath, $bytes)
    }
    else {
        Write-Error "No application manifest found in $FilePath"
    }
}

function IndexOfBytes {
    param (
        [byte[]] $array,
        [byte[]] $search,
        [int] $startIndex = 0
    )

    $i = $startIndex
    while ($i -le $array.Length - $search.Length) {
        $j = 0
        while ($j -lt $search.Length -and $array[$i + $j] -eq $search[$j]) {
            $j++
        }
        if ($j -eq $search.Length) {
            return $i
        }
        $i++
    }
    return -1
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



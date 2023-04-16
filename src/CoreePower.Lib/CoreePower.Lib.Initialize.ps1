#https://learn.microsoft.com/en-us/nuget/consume-packages/configuring-nuget-behavior
#nuget install Newtonsoft.Json
function Initialize-NugetSourceRegistered {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    <#
    $nugetSource = Get-PackageSource -Name NuGet -Provider Nuget -ErrorAction SilentlyContinue
    if (!$nugetSource) {
        Register-PackageSource -Name NuGet -Location "https://www.nuget.org/api/v2/" -ProviderName NuGet -Trusted | Out-Null
        Write-Output "NuGet package source added successfully."
    }

    if ($nugetSource.IsTrusted -eq $false)
    {
        Set-PackageSource -Name NuGet -NewName NuGet -Trusted -ProviderName NuGet
    }
    #>

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
        Install-Package -Name $Name -RequiredVersion $RequiredVersion -Source NuGet -ProviderName NuGet -Scope AllUsers -Verbose
    }
    elseif ($Scope -eq [Scope]::CurrentUser) {
        Install-Package -Name $Name -RequiredVersion $RequiredVersion -Source NuGet -ProviderName NuGet -Scope CurrentUser -Verbose
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

#Initialize-NugetSourceRegistered
#Install-NugetToPackagemanagement -Name "Nuget.Commandline"
#$foo = Get-NugetToPackagemanagementPathLatest -Name "Nuget.Commandline"
#$foox = "$foo\tools\nuget.exe"
#$x1=0
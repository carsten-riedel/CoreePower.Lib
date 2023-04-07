function Initialize-NugetSourceRegistered {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    $nugetSource = Get-PackageSource -Name NuGet -ErrorAction SilentlyContinue
    if (!$nugetSource) {
        Register-PackageSource -Name NuGet -Location https://api.nuget.org/v3/index.json -Provider NuGet
        if ( ($args | ForEach-Object { $_.ToLower() }) -contains '-verbose') {
            Write-Output "NuGet package source added successfully."
        }
    }
    else {
        if ( ($args | ForEach-Object { $_.ToLower() }) -contains '-verbose') {
            Write-Output "NuGet package source already exists."
        }
    }
}

function Initialize-NugetPackageProviderInstalled {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    $nugetProvider = Get-PackageProvider -ListAvailable -ErrorAction SilentlyContinue | Where-Object Name -eq "nuget"
    if (-not($nugetProvider -and $nugetProvider.Version -ge "2.8.5.201")) {
         Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null
         if ( ($args | ForEach-Object { $_.ToLower() }) -contains '-verbose') {
            Write-Output "NuGet package provider successfully installed."
         }
    }
    else {
        if ( ($args | ForEach-Object { $_.ToLower() }) -contains '-verbose') {
            Write-Output   "NuGet package provider already exists."
        }
    }
}

function Initialize-PowerShellGetLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param()
    Update-ModulesLatest -ModulNames @("PowerShellGet")
}

function Initialize-PackageManagementLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param()
    Update-ModulesLatest -ModulNames @("PackageManagement")
}

function Initialize-Powershell {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param()
    Initialize-NugetPackageProviderInstalled
    Initialize-PowerShellGetLatest
    Initialize-PackageManagementLatest
    Initialize-NugetSourceRegistered
}

function Initialize-CorePowerLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param()
    Update-ModulesLatest -ModulNames @("CoreePower.Module","CoreePower.Config")
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
        [string[]] $ModuleNames
    )
    
    $AvailableUpdates = Find-Module -Name $ModuleNames -Repository PSGallery | Select-Object @{Name='Name'; Expression={$_.Name}}, @{Name='Version'; Expression={$_.Version}} | Sort-Object Name, Version -Descending
    $LocalModulesAll = Get-Module -ListAvailable $ModuleNames | Select-Object @{Name='Name'; Expression={$_.Name}}, @{Name='Version'; Expression={$_.Version}} | Sort-Object Name, Version -Descending
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
        [string[]] $ModuleNames
    )
    
    $AllLocalModules = Get-Module -ListAvailable $ModuleNames | Select-Object @{Name='Name'; Expression={$_.Name}}, @{Name='Version'; Expression={$_.Version}} | Sort-Object Name, Version -Descending
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
        [string[]] $ModuleNames
    )
    
    $UpdatableModules = Find-UpdatableModules -ModuleNames $ModuleNames
    $UpdatesApplied = $false

    foreach($module in $UpdatableModules)
    {
        if ( ($args | ForEach-Object { $_.ToLower() }) -contains '-verbose') {
            Write-Output "Installing user module: $($module.Name) $($module.Version)" 
        }

        Install-Module -Name $module.Name -RequiredVersion $module.Version -Scope CurrentUser -Force -AllowClobber | Out-Null
        
        if ( ($args | ForEach-Object { $_.ToLower() }) -contains '-verbose') {
            Write-Output "Importing user module: $($module.Name) $($module.Version)"
        }

        Import-Module -Name $module.Name -MinimumVersion $module.Version -Force | Out-Null

        $UpdatesApplied = $true
    }

    if ($UpdatesApplied)
    {
        if ( ($args | ForEach-Object { $_.ToLower() }) -contains '-verbose') {
            Write-Output "Updates have been applied. Please restart your PowerShell session to ensure that the changes take effect."
        }
    }
}



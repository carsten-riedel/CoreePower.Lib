if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) { 
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

<#
.SYNOPSIS
    Retrieves information about installed PowerShell modules with extended details.

.DESCRIPTION
    The `Get-ModulesInfoExtended` cmdlet retrieves information about installed PowerShell modules, including their name, version, author, and description, as well as extended details about their installation location and scope.
    By default, it retrieves information about all modules installed on the local machine, including modules installed in both the `LocalMachine` and `CurrentUser` scopes.
    Note that when multiple versions of a module are installed on a system, the latest version takes precedence, regardless of whether it is installed in the `LocalMachine` or `CurrentUser` scope.
    Therefore, in this context, `LocalMachine` refers to modules installed in both `LocalMachine` and `CurrentUser` scopes.

.PARAMETER ModuleNames
    Specifies the names of the PowerShell modules to retrieve information for. You can use the wildcard character (*) to retrieve information about all installed modules. 

.PARAMETER Scope
    Specifies the scope of the PowerShell modules to retrieve information for. The available values are "LocalMachine" and "CurrentUser".

.PARAMETER ExcludeSystemModules
    Indicates whether to exclude modules that are installed in system folders from the results. If specified, modules that are installed in system folders (including both user-installed and system-installed modules) are excluded from the results.

.OUTPUTS
    The cmdlet returns an object that includes the following properties additional information for each installed module:
    - BasePath: the base path of the module's installation directory
    - IsMachine: a boolean value indicating whether the module is installed in a machine-wide folder
    - IsUser: a boolean value indicating whether the module is installed in a user-specific folder
    - IsSystem: a boolean value indicating whether the module is installed in a system folder (i.e., a folder within the Windows directory)

.EXAMPLE
    PS C:\> Get-ModulesInfoExtended

    This command retrieves information about all installed PowerShell modules on the local machine, including extended details about their installation location and scope.

.EXAMPLE
    PS C:\> Get-ModulesInfoExtended -ModuleNames MyModule

    This command retrieves information about the PowerShell module named "MyModule", including extended details about its installation location and scope.

.EXAMPLE
    PS C:\> Get-ModulesInfoExtended -Scope LocalMachine -ExcludeSystemModules $true

    This command retrieves information about all installed PowerShell modules, excluding modules that are installed in system folders from the results.
#>
function Get-ModulesInfoExtended {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param(
        [string[]] $ModuleNames = @('*'),
        [ModuleScope]$Scope = [ModuleScope]::LocalMachine,
        [bool]$ExcludeSystemModules = $false
    )

    $LocalModulesAll = Get-Module -Name $ModuleNames -ListAvailable  |  Select-Object *,
        @{ Name='BasePath' ; Expression={ $_.ModuleBase.TrimEnd($_.Version.ToString()).TrimEnd('\').TrimEnd($_.Name).TrimEnd('\')  } },
        @{ Name='IsMachine' ; Expression={ ($_.ModuleBase -Like "*$env:ProgramFiles*") -or ($_.ModuleBase -Like "*$env:ProgramW6432*")  } },
        @{ Name='IsUser' ; Expression={ ($_.ModuleBase -Like "*$env:userprofile*") } },
        @{ Name='IsSystem' ; Expression={ ($_.ModuleBase -Like "*$env:SystemRoot*")  } } 

    if ($Scope -eq [ModuleScope]::LocalMachine -and ($ExcludeSystemModules -eq $false))
    {
        return $LocalModulesAll
    }
    elseif ($Scope -eq [ModuleScope]::LocalMachine -and ($ExcludeSystemModules -eq $true)) {
        $LocalAndUser = $LocalModulesAll | Where-Object { $_.IsSystem -eq $false }
        return $LocalAndUser
    }
    elseif ($Scope -eq [ModuleScope]::CurrentUser) {
        $UserModules = $LocalModulesAll | Where-Object { $_.IsUser -eq $true }
        return $UserModules
    }
}

<#
.SYNOPSIS
    Retrieves local modules based on specified criteria.

.DESCRIPTION
    The Get-ModulesLocal function retrieves local modules based on the specified module names, scope, and record state.

.PARAMETER ModuleNames
    Specifies the names of the modules to retrieve. By default, all modules are included.

.PARAMETER Scope
    Specifies the scope from which to retrieve the modules. The available options are: LocalMachine, CurrentUser.
    The default value is LocalMachine.

.PARAMETER ExcludeSystemModules
    Determines whether system modules are excluded from the results. By default, system modules are excluded.

.PARAMETER ModuleRecordState
    Specifies the record state of the modules to retrieve. The available options are: Latest, Previous.
    The default value is Latest.

.OUTPUTS
    Returns the collection of local modules based on the specified criteria.

.EXAMPLE
    Get-ModulesLocal -ModuleNames ModuleA, ModuleB -Scope CurrentUser
    Retrieves the local modules with the names 'ModuleA' and 'ModuleB' from the CurrentUser scope.

.EXAMPLE
    Get-ModulesLocal -ModuleNames '*' -ExcludeSystemModules $false
    Retrieves all local modules, including system modules.
#>
function Get-ModulesLocal {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param(
        [string[]] $ModuleNames = @('*'),
        [ModuleScope]$Scope = [ModuleScope]::LocalMachine,
        [bool]$ExcludeSystemModules = $true,
        [ModuleRecordState]$ModulRecordState = [ModuleRecordState]::Latest
    )

    $ModuleInfo = Get-ModulesInfoExtended -ModuleNames $ModuleNames -Scope $Scope -ExcludeSystemModules $ExcludeSystemModules
    $LocalModulesAll = $ModuleInfo | Sort-Object Name, Version -Descending

    if ($ModulRecordState -eq [ModuleRecordState]::Latest) {
        $LatestLocalModules = $LocalModulesAll | Group-Object Name | ForEach-Object { $_.Group | Select-Object -First 1  }
    }
    elseif ($ModulRecordState -eq [ModuleRecordState]::Previous){
        $LatestLocalModules = $LocalModulesAll | Group-Object Name | ForEach-Object { $_.Group | Select-Object -Skip 1  }
    } else {
        $LatestLocalModules = $LocalModulesAll | Group-Object Name | ForEach-Object { $_.Group }
    }

    return $LatestLocalModules
}

<#
.SYNOPSIS
    Finds and lists updatable PowerShell modules.

.DESCRIPTION
    The Get-ModulesUpdatable function takes an array of module names and retrieves their update information from the PSGallery repository. 
    It then compares the available versions with locally installed versions and returns a list of modules that have updates available.

.PARAMETER ModuleNames
    An array of module names for which to find update information.

.EXAMPLE
    Get-ModulesUpdatable -ModuleNames @("ModuleName1", "ModuleName2")
#>
function Get-ModulesUpdatable {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param(
        [string[]] $ModuleNames = @('*'),
        [ModuleScope]$Scope = [ModuleScope]::LocalMachine,
        [string[]] $Repositorys = @('All')
    )

    $AllRepositoryNames = (Get-PSRepository | Select-Object -ExpandProperty Name) -as [string[]]

    if ($Repositorys -contains "All") {
        $Repositorys = $AllRepositoryNames
    }

    $LatestLocalModules = Get-ModulesLocal -ModuleNames $ModuleNames -Scope $Scope -ExcludeSystemModules $true -ModulRecordState Latest

    if ($null -eq $LatestLocalModules)
    {
        return
    }

    [string[]]$SeachLocalModulesInPSGallery = $LatestLocalModules | Select-Object -ExpandProperty Name

    $LocalModulesMaxLimitFind = Split-Array -SourceArray $SeachLocalModulesInPSGallery -MaxPartitionSize 63
 
    $LatestRemoteModules = @()

    foreach($Repo in $Repositorys)
    {
        $Block = @()
        foreach($Block in $LocalModulesMaxLimitFind.Partitions)
        {
            $LatestRemoteModules += Find-Module -Name $Block -Repository $Repo -ErrorAction 'silentlycontinue' | Select-Object *
        }
    }
 
    #There can be multiple repos findings , select the last version availible
    $LatestRemoteModules = $LatestRemoteModules | Sort-Object Name, Version -Descending
    $LatestRemoteModules = $LatestRemoteModules | Group-Object Name | ForEach-Object { $_.Group | Select-Object -First 1  }

    #Using wildcards in ModuleNames might cause issues with Find-Module, as it may return a significantly larger number of results.
    $AvailableMatches = $LatestRemoteModules | Where-Object { $_.Name -in $SeachLocalModulesInPSGallery }

    $ModulesToUpdate = $AvailableMatches | Where-Object { $currentUpdate = $_; -not ($LatestLocalModules | Where-Object { $_.Name -eq $currentUpdate.Name -and $_.Version -eq $currentUpdate.Version }) }

    return $ModulesToUpdate
}

<#
.SYNOPSIS
    Removes previous versions of specified modules.

.DESCRIPTION
    The Remove-ModulesPrevious function removes previous versions of modules from the specified scope.

.PARAMETER ModuleNames
    Specifies the names of the modules to remove. This parameter is mandatory.

.PARAMETER Scope
    Specifies the scope from which to remove the modules. The available options are: CurrentUser, LocalMachine.
    The default value is CurrentUser.
#>
function Remove-ModulesPrevious {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [string[]]$ModuleNames = @('*'),
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    $outdated = Get-ModulesLocal -ModuleNames $ModuleNames -Scope $Scope -ExcludeSystemModules $true -ModulRecordState Previous
 
    foreach ($item in $outdated)
    {
        $DirVers = "$($item.BasePath)\$($item.Name)\$($item.Version)"
        Remove-Item -Recurse -Force -Path $DirVers
        Write-Host "Removed module:" $DirVers
    }
}

<#
.SYNOPSIS
    Removes specified PowerShell modules from the current user's module directory.

.DESCRIPTION
    The `Remove-Modules` function removes specified PowerShell modules from the module directory of the current user. It allows for the removal of modules that are no longer needed or outdated.

.PARAMETER ModuleNames
    Specifies the names of the PowerShell modules to be removed. Multiple module names can be provided as an array.

.PARAMETER Scope
    Specifies the scope of the module removal operation. The available values are "LocalMachine" and "CurrentUser". The default value is "CurrentUser".

.NOTES
    - The function requires appropriate permissions to remove modules from the module directory.
    - Removing modules will permanently delete their associated files and directories.
    - The function does not remove modules installed in system folders.
    - It is recommended to use caution when removing modules, as it may affect the functionality of dependent scripts or applications.

.EXAMPLE
    PS C:\> Remove-Modules -ModuleNames "Module1", "Module2"

    This command removes the PowerShell modules named "Module1" and "Module2" from the current user's module directory.

.EXAMPLE
    PS C:\> Remove-Modules -ModuleNames "OutdatedModule" -Scope CurrentUser

    This command removes the PowerShell module named "OutdatedModule" from the module directory of the current user.

.EXAMPLE
    PS C:\> Remove-Modules -ModuleNames "Module3" -Scope LocalMachine

    This command removes the PowerShell module named "Module3" from the module directory of the local machine.

.NOTES
    This function internally uses the `Get-ModulesLocal` function to retrieve module information and the `Remove-Item` cmdlet to delete module files and directories.
#>
function Remove-Modules {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [string[]]$ModuleNames,
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }
    
    $outdated = Get-ModulesLocal -ModuleNames $ModuleNames -Scope $Scope -ExcludeSystemModules $true -ModulRecordState All
 
    foreach ($item in $outdated)
    {
        $DirVers = "$($item.BasePath)\$($item.Name)\$($item.Version)"
        Remove-Item -Recurse -Force -Path $DirVers
        Write-Host "Removed module:" $DirVers
    }
}

<#
.SYNOPSIS
    Updates specified PowerShell modules to their latest versions.

.DESCRIPTION
    The `Update-ModulesLatest` function updates specified PowerShell modules to their latest versions. It retrieves the available updates for the specified modules and installs them, ensuring that the modules are up to date.

.PARAMETER ModuleNames
    Specifies the names of the PowerShell modules to be updated. Multiple module names can be provided as an array. By default, all installed modules are considered for updating.

.PARAMETER Scope
    Specifies the scope of the module update operation. The available values are "LocalMachine" and "CurrentUser". The default value is "CurrentUser".

.PARAMETER SuppressProgressPreference
    Indicates whether to suppress progress preference during the update process. By default, progress preference is not suppressed.

.NOTES
    - The function requires appropriate permissions to update modules in the module directory.
    - The function internally uses the `Get-ModulesUpdatable` function to retrieve information about available module updates.
    - The function uses the `Install-Module` cmdlet to install the updates.
    - Use caution when updating modules, as it may affect the functionality of dependent scripts or applications.

.EXAMPLE
    PS C:\> Update-ModulesLatest

    This command updates all installed PowerShell modules to their latest versions in the current user's module directory.

.EXAMPLE
    PS C:\> Update-ModulesLatest -ModuleNames "Module1", "Module2" -Scope LocalMachine

    This command updates the PowerShell modules named "Module1" and "Module2" to their latest versions in the module directory of the local machine.

.EXAMPLE
    PS C:\> Update-ModulesLatest -ModuleNames "*" -SuppressProgressPreference $true

    This command updates all installed PowerShell modules to their latest versions in the current user's module directory, suppressing progress preference during the update process.

.NOTES
    - If updates are applied successfully, the function returns `$true`. Otherwise, it returns `$false`.
    - It is recommended to regularly update modules to benefit from bug fixes and new features.
#>
function Update-ModulesLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param(
        [string[]] $ModuleNames = @('*'),
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser,
        [bool]$SuppressProgressPreference = $false
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
       # return
    }

    $UpdatableModules = Get-ModulesUpdatable -ModuleNames $ModuleNames
    $UpdatesApplied = $false

    foreach($module in $UpdatableModules)
    {
        #Write-Output "Installing module: $($module.Name) $($module.Version)" 

        if ($SuppressProgressPreference)
        {
            $originalProgressPreference = $global:ProgressPreference
            $global:ProgressPreference = 'SilentlyContinue'
        }
        Install-Module -Name $module.Name -RequiredVersion $module.Version -Scope $Scope -Repository $module.Repository -Force -AllowClobber -SkipPublisherCheck | Out-Null
        if ($SuppressProgressPreference)
        {
        
            $global:ProgressPreference = $originalProgressPreference
        }
        $UpdatesApplied = $true
    }
    if ($UpdatesApplied)
    {
        return $true
    } else {
        return $false
    }
}

function Get-CurrentModule {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param()

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
    return ,$moduleName , $moduleVersion
}
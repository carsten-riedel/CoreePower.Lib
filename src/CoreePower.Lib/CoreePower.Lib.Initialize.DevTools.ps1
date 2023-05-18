if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

function Initialize-DevToolsInitiated {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
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

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-DevTools in module version: $moduleVersion" -SuffixText "Start"
}

function Initialize-DevToolsCompleted {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [bool]$UpdatesDone,
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

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-DevTools in module version: $moduleVersion" -SuffixText "Completed"

    if ($UpdatesDone)
    {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "A restart of Powershell is required to implement the update." -SuffixText "Info"
    }
}

function Initialize-DevToolsBase {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    $moduleName , $moduleVersion = Get-CurrentModule 
    $updatesDone = $false


    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-NugetPackageProvider" -SuffixText "Initiated"
    Initialize-NugetPackageProvider -Scope $Scope
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-NugetPackageProvider" -SuffixText "Completed"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-PowerShellGet" -SuffixText "Initiated"
    Initialize-PowerShellGet  -Scope $Scope
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-PowerShellGet" -SuffixText "Completed"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-PackageManagement" -SuffixText "Initiated"
    Initialize-PackageManagement  -Scope $Scope
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-PackageManagement" -SuffixText "Completed"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-NugetSourceRegistered" -SuffixText "Initiated"
    Initialize-NugetSourceRegistered
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-NugetSourceRegistered" -SuffixText "Completed"

    return $updatesDone
}

function Initialize-DevTools {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("cpdev")] 
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    $UpdatesDone = $false

    Initialize-DevToolsInitiated
 
    $UpdatesDone = $UpdatesDone -or (Initialize-DevToolsBase)
    $UpdatesDone = $UpdatesDone -or (Initialize-DevToolsCoreeModules)
    $UpdatesDone = $UpdatesDone -or (Initialize-DevTools7z)
    $UpdatesDone = $UpdatesDone -or (Initialize-DevToolsGit)
    $UpdatesDone = $UpdatesDone -or (Initialize-DevToolsGh)
    $UpdatesDone = $UpdatesDone -or (Initialize-DevToolsNuget)
    $UpdatesDone = $UpdatesDone -or (Initialize-DevToolsDotnet)
    $UpdatesDone = $UpdatesDone -or (Initialize-DevToolsVsCode)
    $UpdatesDone = $UpdatesDone -or (Initialize-DevToolsImagemagick)
    $UpdatesDone = $UpdatesDone -or (Initialize-DevToolsCoreeLibSelf)

    Initialize-DevToolsCompleted -UpdatesDone $UpdatesDone

}

function Test.CoreePower.Lib.Initialize.DevTools {
    param()
    Write-Host "Start CoreePower.Lib.Initialize.DevTools"
    #Initialize-DevTools
    Write-Host "End CoreePower.Lib.Initialize.DevTools"
}

if ($Host.Name -match "Visual Studio Code")
{
    Test.CoreePower.Lib.Initialize.DevTools
}
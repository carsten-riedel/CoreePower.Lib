if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

function Initialize-DevToolsCoreeModules {
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

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Update-ModulesLatest CoreePower.Module CoreePower.Config" -SuffixText "Initiated"
    $updatesDone = Update-ModulesLatest -ModuleNames @("CoreePower.Module","CoreePower.Config") -Scope $Scope
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Update-ModulesLatest CoreePower.Module CoreePower.Config" -SuffixText "Completed"

    return $updatesDone
}

function Initialize-DevToolsCoreeLibSelf {
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

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Update-ModulesLatest CoreePower.Lib" -SuffixText "Initiated"
    $updatesDone = Update-ModulesLatest -ModuleNames @("CoreePower.Lib") -Scope $Scope
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Update-ModulesLatest CoreePower.Lib" -SuffixText "Completed"

    return $updatesDone
}


#https://learn.microsoft.com/en-us/nuget/consume-packages/configuring-nuget-behavior
#https://learn.microsoft.com/en-us/nuget/consume-packages/managing-the-global-packages-and-cache-folders

if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
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

    Initialize-DevTools -Scope $Scope

}



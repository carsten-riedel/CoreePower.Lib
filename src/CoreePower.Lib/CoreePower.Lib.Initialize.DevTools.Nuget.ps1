if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

function Initialize-DevToolsNuget {
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

    Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Check"
    if (-not(Get-Command "nuget" -ErrorAction SilentlyContinue)) {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Install"
        Install-PackagemanagementNuget -Name "Nuget.Commandline"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Install Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Adding envar"
        $path = Find-PackagemanagementNugetLocal -Name "Nuget.Commandline"
        AddPathEnviromentVariable -Path "$path\tools" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Available"
    } 
    else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Completed"

    return $updatesDone
}
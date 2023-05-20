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

    $contentText = "Nuget (NuGet CLI)"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Check"
    if (-not(Get-Command "nuget" -ErrorAction SilentlyContinue)) {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Install"
        Install-PackagemanagementNuget -Name "Nuget.Commandline"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Install Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Adding envar"
        $path = Find-PackagemanagementNugetLocal -Name "Nuget.Commandline"
        AddPathEnviromentVariable -Path "$path\tools" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Available"
    } 
    else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Completed"

    return $updatesDone
}
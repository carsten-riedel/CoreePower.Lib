if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

function Initialize-DevToolsDotnet {
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

    Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Check"
    if (-not(Get-Command "dotnet" -ErrorAction SilentlyContinue)) {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Deploy"
        &powershell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; &([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Channel LTS" | Out-Null
        Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Deploy Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\Microsoft\dotnet" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Available"
    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Completed"

    return $updatesDone
}
if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

function Initialize-DevToolsGh {
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

    Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Check"
    if (-not(Get-Command "gh" -ErrorAction SilentlyContinue)) {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Download"
        $file = Download-GithubLatestReleaseMatchingAssets -RepositoryUrl "https://github.com/cli/cli/releases" -AssetNameFilters @("windows","amd64",".zip")
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Download Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Extracting"
        $temporaryDir = New-TempDirectory
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Expand-Archive -Path $file -DestinationPath $temporaryDir
        $global:ProgressPreference = $originalProgressPreference
        $source = "$temporaryDir"
        $destination = "$($env:localappdata)\githubcli"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Extracting Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Copying"
        Copy-Recursive -Source $source -Destination $destination
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Copying Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\githubcli\bin" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Available"
    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Completed"

    return $updatesDone
}
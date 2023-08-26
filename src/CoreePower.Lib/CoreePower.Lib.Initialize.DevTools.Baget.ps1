if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

function Initialize-DevToolsBaget {
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

    $contentText = "Baget"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Check Dir"

    $targetdir = "$($global:CoreeDevToolsRoot)\Baget"

    if (-not(Test-Path -Path "$targetdir" -PathType Container)) {
        New-Item -ItemType Directory -Path "$targetdir" -Force | Out-Null
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Directory create"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Download"
        $file = Download-GithubLatestReleaseMatchingAssets -RepositoryUrl "https://github.com/loic-sharma/BaGet/releases" -AssetNameFilters @("Baget",".zip")
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Download Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Extracting"
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Expand-Archive -Path $file -DestinationPath $targetdir
        $global:ProgressPreference = $originalProgressPreference
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Extracting Completed"
        Remove-TempDirectory -TempDirectory $file
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Download removed"
        #Register-PSRepository -Name "BaGet" -SourceLocation "https://localhost:5001/v3/index.json" -PublishLocation "https://localhost:5001/api/v2/package" -InstallationPolicy "Trusted"

    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Completed"

    return $updatesDone
}

function Test.CoreePower.Lib.Initialize.DevTools.Baget {
    param()
    Write-Host "Start CoreePower.Lib.Initialize.DevTools.Baget"
    #Initialize-DevToolsBaget
    Write-Host "End CoreePower.Lib.Initialize.DevTools.Baget"
}

if ($Host.Name -match "Visual Studio Code")
{
    Test.CoreePower.Lib.Initialize.DevTools.Baget
}
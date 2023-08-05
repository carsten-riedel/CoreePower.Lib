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
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Download"
        $targetdir = "$($global:CoreeDevToolsRoot)\Nuget"
        New-Directory -Directory $targetdir
        $JsonNugetVersions = $(Invoke-RestMethod "https://dist.nuget.org/index.json")
        $JsonNugetVersionsCommandLine = $JsonNugetVersions.artifacts | Where-Object { $_.name -like "*commandline*" } | Select-Object -First 1
        $JsonNugetVersionsCommandLineLatest = $JsonNugetVersionsCommandLine.versions | Where-Object { $_.displayName -like "*latest*" } | Select-Object -First 1
        Get-RedirectDownload2 -Url "$($JsonNugetVersionsCommandLineLatest.url)" -OutputDirectory $targetdir
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Download Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$targetdir" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Available"
    } 
    else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Completed"

    return $updatesDone
}

if ($Host.Name -match "Visual Studio Code")
{
    #Initialize-DevToolsNuget2
    #Initialize-DevToolsImagemagick
    #https://www.svgrepo.com/
    #magick convert -density 300 -define icon:auto-resize=256,128,96,64,48,32,16 -background none sunflower-svgrepo-com.svg out.ico
    #magick convert -background none -size 128x128 infile.svg outfile.png
    #magick convert -background none -size 1280x640 "C:\base\github.com\carsten-riedel\CoreePower.Lib\src\logo.svg" "C:\base\github.com\carsten-riedel\CoreePower.Lib\src\logox.png"
}
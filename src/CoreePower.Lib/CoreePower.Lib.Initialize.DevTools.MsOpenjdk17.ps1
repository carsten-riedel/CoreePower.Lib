if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

function Initialize-DevToolsMsOpenjdk17 {
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

    $contentText = "Microsoft OpenJDK17"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Check"
    if (-not(Get-Command "java" -ErrorAction SilentlyContinue)) {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Download"
        $targetdir = "$($global:CoreeDevToolsRoot)\microsoft-jdk-17"
        New-Directory -Directory $targetdir | Out-Null
        $msjdkuri = Find-Links -url "https://learn.microsoft.com/en-us/java/openjdk/download" 
        $stringUris = $msjdkuri | ForEach-Object { $_.AbsoluteUri }
        $foundUrls = @()
        $foundUrls = Filter-ItemsWithLists -InputItems $stringUris -WhiteListMatch @("download-jdk","17","windows","x64",".zip") -BlackListMatch @("sha","debug")
        $file = Get-RedirectDownload2 -Url $foundUrls
        Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Download Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Extracting"
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Expand-Archive -Path $file -DestinationPath $targetdir -Force
        $global:ProgressPreference = $originalProgressPreference
        Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Extracting Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Removing Download"
        Remove-TempDirectory -TempDirectory $file
        $found = Find-FileDirRecursively -DirectoryPath "$targetdir" -FileName "java.exe"
        AddPathEnviromentVariable -Path "$found" -Scope CurrentUser
        AddEnviromentVariable -Name "JAVA_HOME" -Value "$found"
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
    $global:CoreeDevToolsRoot = "$($env:localappdata)\CoreeDevTools"
    Initialize-DevToolsMsOpenjdk17
    #Initialize-DevToolsNuget2
    #Initialize-DevToolsImagemagick
    #https://www.svgrepo.com/
    #magick convert -density 300 -define icon:auto-resize=256,128,96,64,48,32,16 -background none sunflower-svgrepo-com.svg out.ico
    #magick convert -background none -size 128x128 infile.svg outfile.png
    #magick convert -background none -size 1280x640 "C:\base\github.com\carsten-riedel\CoreePower.Lib\src\logo.svg" "C:\base\github.com\carsten-riedel\CoreePower.Lib\src\logox.png"
}
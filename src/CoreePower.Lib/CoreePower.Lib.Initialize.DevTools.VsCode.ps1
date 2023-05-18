if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

function Initialize-DevToolsVsCode {
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

    Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Check"
    if (-not((Test-Path "$($env:localappdata)\vscodezip\code.exe" -PathType Leaf))) {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Download"
        $temporaryDir = New-TempDirectory
        $file = Get-RedirectDownload2 -Url "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Download Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Extracting"
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Expand-Archive -Path $file -DestinationPath $temporaryDir
        $global:ProgressPreference = $originalProgressPreference
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Extracting Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Copying"
        Copy-Recursive -Source $temporaryDir -Destination "$($env:localappdata)\vscodezip"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Copying Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\vscodezip\bin" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Available"
    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Already available"
    }

    return $updatesDone
}
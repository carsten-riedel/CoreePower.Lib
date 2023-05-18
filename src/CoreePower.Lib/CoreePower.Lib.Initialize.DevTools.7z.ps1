if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

function Initialize-DevTools7z {
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

    Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Check"
    if (-not(Get-Command "7z" -ErrorAction SilentlyContinue)) {
        $sz = $(Invoke-RestMethod "https://sourceforge.net/projects/sevenzip/best_release.json").platform_releases.windows
        $temporaryDir = New-TempDirectory
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Download"
        $file = Get-RedirectDownload -Url "$($sz.url)" -OutputDirectory "$temporaryDir"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Download Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Change Invoker"
        Set-AsInvoker -FilePath "$file"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Change Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Extracting"
        $output, $errorOutput = Start-ProcessSilent -File "$file" -Arguments "/S /D=`"$($env:localappdata)\7zip`""
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Extracting Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\7zip" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Available"
    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Completed"

    return $updatesDone
}

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

    $contentText = "7z (7-Zip)"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Check"
    if (-not(Get-Command "7z" -ErrorAction SilentlyContinue)) {
        $sz = $(Invoke-RestMethod "https://sourceforge.net/projects/sevenzip/best_release.json").platform_releases.windows
        $temporaryDir = New-TempDirectory
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Download"
        $file = Get-RedirectDownload -Url "$($sz.url)" -OutputDirectory "$temporaryDir"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Download Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Change Invoker"
        Set-AsInvoker -FilePath "$file"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Change Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Extracting"
        $output, $errorOutput = Start-ProcessSilent -File "$file" -Arguments "/S /D=`"$($global:CoreeDevToolsRoot)\7zip`""
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Extracting Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($global:CoreeDevToolsRoot)\7zip" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Available"
    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Completed"

    return $updatesDone
}

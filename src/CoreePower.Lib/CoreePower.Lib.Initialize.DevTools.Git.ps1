if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

function Initialize-DevToolsGit {
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

    Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Check"
    if (-not(Get-Command "git" -ErrorAction SilentlyContinue)) {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Download"
        $file = Download-GithubLatestReleaseMatchingAssets -RepositoryUrl "https://github.com/git-for-windows/git/releases" -AssetNameFilters @("Portable","64-bit",".exe")
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Download Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Extracting"
        &7z x -y -o"$($env:localappdata)\PortableGit" "$file" | Out-Null
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Extracting Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Initializing"
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $currendir = Get-Location
        Set-Location "$($env:localappdata)\PortableGit"
        $psi.FileName = "$($env:localappdata)\PortableGit\git-bash.exe"
        $psi.Arguments = "--hide --no-cd --command=post-install.bat"
        $psi.WorkingDirectory = [System.IO.Path]::GetDirectoryName("$($env:localappdata)\PortableGit\git-bash.exe")
        $psi.UseShellExecute = $false
        $process = [System.Diagnostics.Process]::Start($psi)
        $process.WaitForExit()
        Set-Location $currendir
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Initializing Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\PortableGit\cmd" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Available"
    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Completed"

    return $updatesDone
}
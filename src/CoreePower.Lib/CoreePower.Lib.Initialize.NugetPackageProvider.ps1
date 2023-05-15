function Initialize-NugetPackageProvider {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    $nugetProvider = Get-PackageProvider -ListAvailable -ErrorAction SilentlyContinue | Where-Object Name -eq "nuget"
    if (-not($nugetProvider -and $nugetProvider.Version -ge "2.8.5.201")) {
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope $Scope -Force | Out-Null
        $global:ProgressPreference = $originalProgressPreference
    }
}
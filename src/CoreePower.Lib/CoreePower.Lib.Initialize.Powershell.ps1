function Initialize-Powershell {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    Initialize-NugetPackageProvider -Scope $Scope
    Initialize-PowerShellGet -Scope $Scope
    Initialize-PackageManagement -Scope $Scope
    Initialize-NugetSourceRegistered
}
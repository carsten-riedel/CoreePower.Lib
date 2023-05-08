
function Update-PowerShellGet {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Scope]$Scope = [Scope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }
    $originalProgressPreference = $global:ProgressPreference
    $global:ProgressPreference = 'SilentlyContinue'
    Update-ModulesLatest -ModuleNames @("PowerShellGet") -Scope $Scope  | Out-Null
    Set-PackageSource -Name PSGallery -Trusted -ProviderName PowerShellGet | Out-Null
    $global:ProgressPreference = $originalProgressPreference
}
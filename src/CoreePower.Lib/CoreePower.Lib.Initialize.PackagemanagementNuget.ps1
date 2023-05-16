function Install-PackagemanagementNuget {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$RequiredVersion = $null,
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [ModuleScope]::LocalMachine)  {
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Install-Package -Name $Name -RequiredVersion $RequiredVersion -Source NuGet -ProviderName NuGet -Scope AllUsers  | Out-Null
        $global:ProgressPreference = $originalProgressPreference
    }
    elseif ($Scope -eq [ModuleScope]::CurrentUser) {
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Install-Package -Name $Name -RequiredVersion $RequiredVersion -Source NuGet -ProviderName NuGet -Scope CurrentUser | Out-Null
        $global:ProgressPreference = $originalProgressPreference
    }
}

function Find-PackagemanagementNugetLocal {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$RequiredVersion = $null,
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [ModuleScope]::LocalMachine) {
        $localPackages = Find-Package -Name $Name -Source "$($Env:Programfiles)\PackageManagement\NuGet\Packages"
        return $localPackages | Select-Object -First 1 @{Name='Path'; Expression={"$($_.Source)\$($_.Name).$($_.Version)"}} | Select-Object -ExpandProperty Path
    }
    elseif ($Scope -eq [ModuleScope]::CurrentUser) {
        $localPackages = Find-Package -Name $Name  -Source "$($env:userprofile)\AppData\Local\PackageManagement\NuGet\Packages"
        return $localPackages | Select-Object -First 1 @{Name='Path'; Expression={"$($_.Source)\$($_.Name).$($_.Version)"}}  | Select-Object -ExpandProperty Path
    }
}
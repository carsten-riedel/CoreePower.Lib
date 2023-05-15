function Initialize-NugetSourceRegistered {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    
    $nugetSource = Get-PackageSource -Name NuGet -Provider Nuget -ErrorAction SilentlyContinue
    if (!$nugetSource) {
        Register-PackageSource -Name NuGet -Location "https://www.nuget.org/api/v2/" -ProviderName NuGet -Trusted | Out-Null
        #Write-Output "NuGet package source registered successfully"
    }

    if ($nugetSource.IsTrusted -eq $false)
    {
        Set-PackageSource -Name NuGet -NewName NuGet -Trusted -ProviderName NuGet
    }

    $nugetSource = Get-PackageSource -Name nuget.org -Provider Nuget -ErrorAction SilentlyContinue
    if (!$nugetSource) {

        Register-PackageSource -Name nuget.org -Location "https://api.nuget.org/v3/index.json" -ProviderName NuGet -Trusted -SkipValidate | Out-Null
        #Write-Output "Nuget.org package source registered successfully."
    }

    if ($nugetSource.IsTrusted -eq $false)
    {
        Set-PackageSource -Name nuget.org -ProviderName NuGet -Trusted -SkipValidate 
    }
}
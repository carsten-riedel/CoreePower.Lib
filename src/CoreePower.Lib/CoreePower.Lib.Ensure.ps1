function Ensure-NugetSourceRegistered {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("cpensr")]
    $nugetSource = Get-PackageSource -Name NuGet -ErrorAction SilentlyContinue
    if (!$nugetSource) {
        Register-PackageSource -Name NuGet -Location https://api.nuget.org/v3/index.json -Provider NuGet
        if ( ($args | ForEach-Object { $_.ToLower() }) -contains '-verbose') {
            Write-Output "NuGet package source added successfully."
        }
    }
    else {
        if ( ($args | ForEach-Object { $_.ToLower() }) -contains '-verbose') {
            Write-Output "NuGet package source already exists."
        }
    }
}

function Ensure-NugetPackageProviderInstalled {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("cpenppi")]
    $nugetProvider = Get-PackageProvider -ListAvailable -ErrorAction SilentlyContinue | Where-Object Name -eq "nuget"
    if (-not($nugetProvider -and $nugetProvider.Version -ge "2.8.5.201")) {
         Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null
         if ( ($args | ForEach-Object { $_.ToLower() }) -contains '-verbose') {
            Write-Output "NuGet package provider successfully installed."
         }
    }
    else {
        if ( ($args | ForEach-Object { $_.ToLower() }) -contains '-verbose') {
            Write-Output   "NuGet package provider already exists."
        }
    }
}

function Ensure-PowerShellGetLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("cpepsgl")]
    $updateinfo = Find-Module -Name @("PowerShellGet","PackageManagement") -Repository PSGallery | Select-Object Name,Version 
    $updateable = $updateinfo | Where-Object { -not (Get-Module -ListAvailable -Name $_.Name | Sort-Object Version -Descending | Select-Object -First 1 | Where-Object Version -eq $_.Version) }
    
    $updateDone = $false
    foreach($item in $updateable)
    {
        if ( ($args | ForEach-Object { $_.ToLower() }) -contains '-verbose') {
            Write-Output "Installing user module: $($item.Name) $($item.Version)" 
        }

        Install-Module -Name $item.Name -RequiredVersion $item.Version -Scope CurrentUser -Force -AllowClobber | Out-Null
        
        if ( ($args | ForEach-Object { $_.ToLower() }) -contains '-verbose') {
            Write-Output "Importing user module: $($_.Name) $($item.Version)"
        }

        Import-Module -Name $item.Name -MinimumVersion $item.Version | Out-Null

        $updateDone = $true
    }

    if ($updateDone)
    {
        if ( ($args | ForEach-Object { $_.ToLower() }) -contains '-verbose') {
            Write-Output "Updates have been applied. Please restart your PowerShell session to ensure that the changes take effect."
        }
    }
}

Ensure-PowerShellGetLatest -verbose
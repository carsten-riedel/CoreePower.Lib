#try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force } catch {} ; $nugetProvider = Get-PackageProvider -ListAvailable | Where-Object Name -eq "nuget"; if (-not($nugetProvider -and $nugetProvider.Version -ge '2.8.5.201')) { $pref = $global:ProgressPreference ; $global:ProgressPreference = 'SilentlyContinue' ; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null ; $global:ProgressPreference = $pref; } ;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 ; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/install.ps1'))

$originalProgressPreference = $global:ProgressPreference
$global:ProgressPreference = 'SilentlyContinue'
Install-Module -Name CoreePower.Lib -Scope CurrentUser -Force -AllowClobber | Out-Null
$global:ProgressPreference = $originalProgressPreference

$module = Get-ModulesLocal -ModuleNames @('CoreePower.Lib')
AddPathEnviromentVariable -Path "$($module.ModuleBase)" -Scope CurrentUser

Write-Output "Note: the 'Initialize-CorePowerLatest' command may conflict with existing installations. Use with caution."
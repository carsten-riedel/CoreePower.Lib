#try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force } catch {} ; $nugetProvider = Get-PackageProvider -ListAvailable | Where-Object Name -eq "nuget"; if (-not($nugetProvider -and $nugetProvider.Version -ge '2.8.5.201')) { $pref = $global:ProgressPreference ; $global:ProgressPreference = 'SilentlyContinue' ; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null ; $global:ProgressPreference = $pref; } ;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 ; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/install.ps1'))

$originalProgressPreference = $global:ProgressPreference
$global:ProgressPreference = 'SilentlyContinue'
Install-Module -Name CoreePower.Lib -Scope CurrentUser -Force -AllowClobber | Out-Null
$global:ProgressPreference = $originalProgressPreference



$process = Get-Process -Id $pid
$parentProcess = Get-Process -Id $process.ParentId

Write-Host "Parent Process Name: $($parentProcess.ProcessName)"
Write-Host "Parent Process ID: $($parentProcess.Id)"

$module = Get-ModulesLocal -ModuleNames @('CoreePower.Lib')

$currentDir = Get-Location
Copy-Item -Path "$($module.ModuleBase)\Initialize-CorePowerLatest.cmd" -Destination "$currentDir\Initialize-CorePowerLatest.cmd"

Write-Output "Note: the 'Initialize-CorePowerLatest' command may conflict with existing installations. Use with caution."
#try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force } catch {} ; $nugetProvider = Get-PackageProvider -ListAvailable | Where-Object Name -eq "nuget"; if (-not($nugetProvider -and $nugetProvider.Version -ge '2.8.5.201')) { $pref = $global:ProgressPreference ; $global:ProgressPreference = 'SilentlyContinue' ; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null ; $global:ProgressPreference = $pref; } ;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 ; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/install.ps1'))

$originalProgressPreference = $global:ProgressPreference
$global:ProgressPreference = 'SilentlyContinue'
Install-Module -Name CoreePower.Lib -Scope CurrentUser -Force -AllowClobber | Out-Null
$global:ProgressPreference = $originalProgressPreference


$parentProcessId = (Get-WmiObject -Query "SELECT ParentProcessId FROM Win32_Process WHERE ProcessId=$pid").ParentProcessId
$parentProcess = Get-Process -Id $parentProcessId

if ($parentProcess.ProcessName -eq "cmd")
{
    $module = Get-ModulesLocal -ModuleNames @('CoreePower.Lib')

    $tempDirectoryPath = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Temp' | Join-Path -ChildPath ([System.Guid]::NewGuid().ToString())
    if (-not (Test-Path $tempDirectoryPath)) {
        New-Item -ItemType Directory -Path $tempDirectoryPath -Force | Out-Null
    }

    $PROCESSPATHS = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::Process)
    $NEW = "$PROCESSPATHS;$tempDirectoryPath"
    [System.Environment]::SetEnvironmentVariable("PATH",$NEW,[System.EnvironmentVariableTarget]::Process)

    Copy-Item -Path "$($module.ModuleBase)\Initialize-CorePowerLatest.cmd" -Destination "$tempDirectoryPath\Initialize-CorePowerLatest.cmd"
}

Write-Output "Note: the 'Initialize-CorePowerLatest' command may conflict with existing installations. Use with caution."
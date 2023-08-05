#try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force } catch {} ; $nugetProvider = Get-PackageProvider -ListAvailable | Where-Object Name -eq "nuget"; if (-not($nugetProvider -and $nugetProvider.Version -ge '2.8.5.201')) { $pref = $global:ProgressPreference ; $global:ProgressPreference = 'SilentlyContinue' ; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null ; $global:ProgressPreference = $pref; } ;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 ; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/install.ps1'))
function Start-ComSpec {
    param (
        [string]$Arguments
    )

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $env:ComSpec
    $psi.Arguments = $Arguments
 
    try {
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $psi
        $process.Start()
     } catch {
        Write-Output "Error: $_.Exception.Message"
    }
}


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

    Copy-Item -Path "$($module.ModuleBase)\Initialize-CorePowerLatest.cmd" -Destination "$tempDirectoryPath\Initialize-CorePowerLatest.cmd"

    Start-ComSpec -Arguments "/k cd ""$tempDirectoryPath"" & echo If you execute the command 'Initialize-CorePowerLatest', it will install the latest devtools. Please be aware that the 'Initialize-CorePowerLatest' command might potentially conflict with existing installations, so use it with caution."
    exit
}

Write-Output "If you execute the command 'Initialize-CorePowerLatest', it will install the latest devtools. Please be aware that the 'Initialize-CorePowerLatest' command might potentially conflict with existing installations, so use it with caution."


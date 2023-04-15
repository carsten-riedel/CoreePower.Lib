# CoreePower.Lib
CoreePower.Lib is a set of functions that can be used to enhance the functionality of your CoreePower project.

## Install via Powershell
```
try { Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force } catch {} ; $nugetProvider = Get-PackageProvider -ListAvailable | Where-Object Name -eq "nuget"; if (-not($nugetProvider -and $nugetProvider.Version -ge '2.8.5.201')) { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null } ;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 ; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/install.ps1'))
```

## Install via cmd
```
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "try { Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force } catch {} ; $nugetProvider = Get-PackageProvider -ListAvailable | Where-Object Name -eq "nuget"; if (-not($nugetProvider -and $nugetProvider.Version -ge '2.8.5.201')) { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null } ;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 ; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/install.ps1'))"
```

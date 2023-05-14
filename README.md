# CoreePower.Lib
CoreePower.Lib is a set of functions that can be used to enhance the functionality of your CoreePower project.

## Install via Powershell
```
try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force } catch {} ; $nugetProvider = Get-PackageProvider -ListAvailable | Where-Object Name -eq "nuget"; if (-not($nugetProvider -and $nugetProvider.Version -ge '2.8.5.201')) { $pref = $global:ProgressPreference ; $global:ProgressPreference = 'SilentlyContinue' ; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null ; $global:ProgressPreference = $pref; } ;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 ; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/install.ps1'))
```

## Install via cmd
```
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "try { Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force } catch {} ; $nugetProvider = Get-PackageProvider -ListAvailable | Where-Object Name -eq "nuget"; if (-not($nugetProvider -and $nugetProvider.Version -ge '2.8.5.201')) { $pref = $global:ProgressPreference ; $global:ProgressPreference = 'SilentlyContinue' ; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null ; $global:ProgressPreference = $pref; } ;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 ; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/install.ps1'))"
```

## After install
### Launch Powershell and invoke the command.
```
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

Try the new cross-platform PowerShell https://aka.ms/pscore6

PS C:\Users\UserName> Install-Module CoreePower.Lib -Scope CurrentUser -Force
PS C:\Users\UserName> Initialize-CorePowerLatest
```

The `Initialize-CorePowerLatest` PowerShell function is a comprehensive script designed to automate the setup and update of a variety of essential tools for a developer's environment. It can be invoked with a specified module scope.

The `Initialize-CorePowerLatest` executes in user scope by default.

The function then initializes and checks for updates for a set of specific tools and modules:

1. **NuGet Package Provider**: NuGet is a free and open-source package manager for the .NET ecosystem. The function ensures NuGet is installed for the specified scope.
2. **PowerShellGet**: This is a module with commands for discovering, installing, updating, and publishing PowerShell artifacts such as Modules, DSC Resources, Role Capabilities, and Scripts. The function initializes the latest version of PowerShellGet for the specified scope.
3. **PackageManagement**: Also known as OneGet, a unified interface to package management systems and aims to make Software Discovery, Installation and Inventory work via a common set of cmdlets, regardless of the installation technology underneath. The function initializes the latest version of PackageManagement for the specified scope.
4. **CorePower Modules**: The function checks for updates for the "CoreePower.Module" and "CoreePower.Config" modules.
5. **7-Zip**: If 7-Zip isn't already installed, the function downloads it from SourceForge and installs it in the local application data directory.
6. **Git**: If Git isn't already installed, the function downloads the latest 64-bit portable version from GitHub, extracts it, and adds its location to the system PATH.
7. **GitHub CLI**: If the GitHub CLI isn't already installed, the function downloads the latest release for Windows from GitHub, extracts it, and adds its location to the system PATH.
8. **NuGet**: If NuGet isn't already installed, the function installs it and adds its location to the system PATH.
9. **.NET Core**: If .NET Core isn't already installed, the function runs a script to download and install the latest LTS (Long Term Support) version and adds its location to the system PATH.
10. **Visual Studio Code**: If Visual Studio Code isn't already installed, the function downloads it, extracts it, and adds its location to the system PATH.

Lastly, the function checks for updates for the "CoreePower.Lib" module.

The function is a one-stop solution for setting up and maintaining a developer's environment with these tools, simplifying the process and saving time.


```
git clone --branch V0.0.0.45 --depth 1 https://github.com/carsten-riedel/CoreePower.Module C:\temp\CoreePower.Module
Remove-Item -Recurse -Force "C:\temp\CoreePower.Module\.git"
```



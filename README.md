# CoreePower.Lib
The "CoreePower.Lib" module is a powerful addition to your CoreePower project, offering a range of specialized functions that enhance its functionality and enable advanced capabilities.

One of the key features of the module is the `Initialize-CorePowerLatest` command, which automates the setup and updates of crucial development tools. By ensuring that you have the latest versions installed, this command streamlines your development environment for maximum efficiency.

## The Module is available via Powershellgallery
https://www.powershellgallery.com/packages/CoreePower.Lib

## Install via Powershell (silent)
```
try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force } catch {} ; $nugetProvider = Get-PackageProvider -ListAvailable | Where-Object Name -eq "nuget"; if (-not($nugetProvider -and $nugetProvider.Version -ge '2.8.5.201')) { $pref = $global:ProgressPreference ; $global:ProgressPreference = 'SilentlyContinue' ; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null ; $global:ProgressPreference = $pref; } ;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 ; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/install.ps1'))
```

## Install via cmd (silent)
```
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force } catch {} ; $nugetProvider = Get-PackageProvider -ListAvailable | Where-Object Name -eq "nuget"; if (-not($nugetProvider -and $nugetProvider.Version -ge '2.8.5.201')) { $pref = $global:ProgressPreference ; $global:ProgressPreference = 'SilentlyContinue' ; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null ; $global:ProgressPreference = $pref; } ;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 ; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/install.ps1'))"
```

## Manual install
### Launch Powershell and invoke the command.

<p align="center">
  <img src="https://github.com/carsten-riedel/CoreePower.Lib/assets/97656046/b3f72ff5-f3c1-4e56-a259-8596cc1a0523" alt="image">
</p>

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
6. **PortableGit**: If Git isn't already installed, the function downloads the latest 64-bit portable version from GitHub, extracts and initializes it.
7. **GitHub CLI**: If the GitHub CLI isn't already installed, the function downloads the latest release for Windows from GitHub, extracts it.
8. **NuGet**: If NuGet isn't already installed, the function installs it.
9. **.NET Core**: If .NET Core isn't already installed, the function runs a script to download and install the latest LTS (Long Term Support) version.
10. **Visual Studio Code**: If Visual Studio Code isn't already installed, the function downloads it, extracts it.
11. **CoreePower.Lib"** Lastly, the function checks for updates for the "CoreePower.Lib" module.

**1-4 + 11:** Are Powershell updates

**5-8 + 10:** Extractions to local application data directory. Locations are added to the process and users path variable, to invoke them from console.

**9:** Invoke of orginal user scoped install.

The function is a one-stop solution for setting up and maintaining a developer's environment with these tools, simplifying the process and saving time.

<h1></h1>

## Powershell git clone a special version of the CoreePower.Lib git to a local directoy
```
git clone --branch V0.0.0.177 --depth 1 https://github.com/carsten-riedel/CoreePower.Lib.git C:\VCS\raw\github.com\carsten-riedel\CoreePower.Module\V0.0.0.177 > null 2>&1
Remove-Item -Recurse -Force "C:\VCS\raw\github.com\carsten-riedel\CoreePower.Module\V0.0.0.177\.git"
```



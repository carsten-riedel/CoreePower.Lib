# <img src="https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/logo_64.png" align="left" />CoreePower.Lib
<br clear="left"/>

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
4. **CorePower Modules**: The function checks for updates for the "CoreePower.Module" and "CoreePower.Config" modules. If not installed nothing happens.
5. **CoreePower.Lib"** The function checks for updates for the "CoreePower.Lib" module.

7. **7-Zip**: If 7-Zip isn't already installed, the function downloads it from SourceForge and installs it in the local application data directory.
8. **PortableGit**: If Git isn't already installed, the function downloads the latest 64-bit portable version from GitHub, extracts and initializes it.
9. **GitHub CLI**: If the GitHub CLI isn't already installed, the function downloads the latest release for Windows from GitHub, extracts it.
10. **NuGet**: If NuGet isn't already installed, the function installs it.
13. **WixToolset** If *dark* part of the WixToolset is not installed, the function downloads the latest release for Windows from GitHub, extracts it. (Required for extracting vc_redist exe)
14. **Imagemagick** Currently not fully working cause of missing dependecy of vc_redist. (vcomp140.dll)

16. **.NET Core**: If .NET Core isn't already installed, the function runs a script to download and install the latest LTS (Long Term Support) version.
17. **Visual Studio Code**: If Visual Studio Code isn't already installed, the function downloads it, extracts it.

**1-5:** Are Powershell updates

**7-14:** Download from **orginal sources** and extractions to local application data directory. Locations are added to the process and users path variable, to invoke them from console.

**16:** Invoke of orginal user scoped install.

**17:** Extraction of the user installer, add adding them to the users path variable.

### After setup the following commands should be available
```
C:\>7z
7-Zip 22.01 (x64) : Copyright (c) 1999-2022 Igor Pavlov : 2022-07-15

C:\>git -v
git version 2.39.2.windows.1

C:\>gh --version
gh version 2.28.0 (2023-04-25)
https://github.com/cli/cli/releases/tag/v2.28.0

C:\>nuget
NuGet Version: 6.5.0.154

C:\>dotnet --version
7.0.201

C:\>code --version
1.78.2

C:>dark
Windows Installer XML Toolset Decompiler version 3.11.2.4516
Copyright (c) .NET Foundation and contributors. All rights reserved.

C:\>magick --version
Version: ImageMagick 7.1.1-9 Q16-HDRI x64 776a88d:20230514 https://imagemagick.org
```

The function is a one-stop solution for setting up and maintaining a developer's environment with these tools, simplifying the process and saving time.

<h1></h1>

## Powershell git clone a special version of the CoreePower.Lib git to a local directoy
```
git clone --branch V0.0.0.177 --depth 1 https://github.com/carsten-riedel/CoreePower.Lib.git C:\VCS\raw\github.com\carsten-riedel\CoreePower.Module\V0.0.0.177 > null 2>&1
Remove-Item -Recurse -Force "C:\VCS\raw\github.com\carsten-riedel\CoreePower.Module\V0.0.0.177\.git"
```



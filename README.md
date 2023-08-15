# <img src="https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/logo_64.png" align="left" />CoreePower.Lib
<br clear="left"/>

The "CoreePower.Lib" module is a powerful addition to your CoreePower project, offering a range of specialized functions that enhance its functionality and enable advanced capabilities.

The key feature of the module is the `Initialize-CorePowerLatest` command, which automates the setup and updates of crucial development tools. By ensuring that you have the latest versions installed, this command streamlines your development environment for maximum efficiency.

This solution provides a comprehensive approach to the identified challenges, implementing several key improvements:

1. **Automated execution:** No user interaction is required. The checks command line runs automatically if the command is not found in the command line. Please be aware, there may be duplicates on your system due to this automatic process.
2. **User-focused privileges:** No administrative rights are necessary, ensuring the solution is fully user-scoped.
3. **Original 7zip download:** The solution includes downloading the original 7zip via the SourceForge API, ensuring we use a trusted source.
4. **Assembly Manifest Modification:** The original 7zip download's assembly manifest is modified, enabling self-extraction without requiring administrative privileges.
5. **Portable Git Installer packaging:** The Portable Git Installer is packaged as a 7z self-extractor, necessitating the use of 7zip for extraction.
6. **Latest release downloads:** The solution provides for downloading the latest releases from GitHub via the GitHub API, ensuring up-to-date components are used.
7. **Nuget.exe acquisition:** The solution ensures the latest version of nuget.exe is obtained for the system.
8. **Imagemagick:** Imagemagick requires vc runtime 2015 even in the portable version. (Basic runtime is been copied, please take care of system updates, API set redirection will point to the latest version of your system)
9. **Github Ratelimits** If you are behind a proxy, there is a good chance that you can not call the github api, cause of github limitations. For unauthenticated requests, the rate limit allows for up to 60 requests per hour. Normal setups have some loadbalancing builtin so the api calls have some retry wait functions.



## The Module is available via Powershellgallery
https://www.powershellgallery.com/packages/CoreePower.Lib

## Install via Powershell (Unattended)
```
try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force } catch {} ; $nugetProvider = Get-PackageProvider -ListAvailable | Where-Object Name -eq "nuget"; if (-not($nugetProvider -and $nugetProvider.Version -ge '2.8.5.201')) { $pref = $global:ProgressPreference ; $global:ProgressPreference = 'SilentlyContinue' ; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null ; $global:ProgressPreference = $pref; } ;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 ; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/install.ps1'))
```

## Install via cmd (Unattended)
```
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force } catch {} ; $nugetProvider = Get-PackageProvider -ListAvailable | Where-Object Name -eq "nuget"; if (-not($nugetProvider -and $nugetProvider.Version -ge '2.8.5.201')) { $pref = $global:ProgressPreference ; $global:ProgressPreference = 'SilentlyContinue' ; Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null ; $global:ProgressPreference = $pref; } ;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 ; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/install.ps1'))" & exit
```
A fully functional `Initialize-CorePowerLatest.cmd` script is generated in the temporary directory, which refreshes the PATH environment after the PowerShell execution concludes. Therefore, simply appending or invoking `Initialize-CorePowerLatest` after the command will suffice.

## Manual install
### Launch Powershell and invoke the command.

<p align="center">
  <img src="https://github.com/carsten-riedel/CoreePower.Lib/assets/97656046/b3f72ff5-f3c1-4e56-a259-8596cc1a0523" alt="image">
</p>

```
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

Try the new cross-platform PowerShell https://aka.ms/pscore6

PS C:\Users\UserName> Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force #Maybe required

PS C:\Users\UserName> Install-Module CoreePower.Lib -Scope CurrentUser -Force

PS C:\Users\UserName> Initialize-CorePowerLatest
```

The `Initialize-CorePowerLatest` PowerShell function is a comprehensive script designed to automate the setup and update of a variety of essential tools for a developer's environment. It can be invoked with a specified module scope.

The `Initialize-CorePowerLatest` executes in user scope by default.

The function then initializes and checks for updates for a set of specific tools and modules:

1. **NuGet Package Provider**: NuGet is a free and open-source package manager for the .NET ecosystem. The function ensures NuGet is installed for the specified scope.
2. **PowerShellGet**: This is a module with commands for discovering, installing, updating, and publishing PowerShell artifacts such as Modules, DSC Resources, Role Capabilities, and Scripts. The function initializes the latest version of PowerShellGet for the specified scope.
3. **PackageManagement**: Also known as OneGet, a unified interface to package management systems and aims to make Software Discovery, Installation and Inventory work via a common set of cmdlets, regardless of the installation technology underneath. The function initializes the latest version of PackageManagement for the specified scope.
4. **NugetSourceRegistered** Registers the urls for the Powershell Install-Package command.
5. **CorePower Modules**: The function checks for updates for the "CoreePower.Module" and "CoreePower.Config" modules. If not installed nothing happens.
6. **7-Zip**: If 7-Zip isn't already installed, the function downloads it from SourceForge and installs it in the local application data directory.
7. **PortableGit**: If Git isn't already installed, the function downloads the latest 64-bit portable version from GitHub, extracts and initializes it.
8. **GitHub CLI**: If the GitHub CLI isn't already installed, the function downloads the latest release for Windows from GitHub, extracts it.
9. **NuGet**: If NuGet isn't already installed, the function installs it.
10. **WixToolset** If *dark* part of the WixToolset is not installed, the function downloads the latest release for Windows from GitHub, extracts it. (Required for extracting vc_redist exe)
11. **Imagemagick** Download latest version from the website and adds required vc runtime.
12. **.NET Core**: If .NET Core isn't already installed, the function runs a script to download and install the latest LTS (Long Term Support) version.
13. **Visual Studio Code**: If Visual Studio Code isn't already installed, the function downloads it, extracts it.
14. **github (Actions Runner)**: The github actions-runner will be copied and extracted.
15. **pwsh (Powershell core)** Powershell core runtime
16. **Python (PythonEmbeded)** Pyhton embeded version runtime.
17. **Microsoft OpenJDK17** Java Runtime
18. **AzurePipelinesAgent** CI/CD runner for https://dev.azure.com/ projects.The agent will be copied and extracted.
19. **Latest. CoreePower.Lib** The function checks for updates for the "CoreePower.Lib" module. (If a update is availble the powershell session needs to be restarted to take affect) 


**1-5 + Latest:** Are Powershell updates

**6-18:** Download from **orginal sources** and extractions to local application data directory. Locations are added to the process and users path variable, to invoke them from console.

**12:** Invoke of orginal user scoped install.

**13:** Extraction of the user installer, add adding them to the users path variable.

### Extract location
All tools are now placed inside ``%localappdata%\CoreeDevTools``

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

C:\>pwsh --version
PowerShell 7.3.6

C:\>python --version
Python 3.11.4

C:\>java --version
openjdk 17.0.8 2023-07-18 LTS
OpenJDK Runtime Environment Microsoft-8035246 (build 17.0.8+7-LTS)
OpenJDK 64-Bit Server VM Microsoft-8035246 (build 17.0.8+7-LTS, mixed mode, sharing)

```

The function is a one-stop solution for setting up and maintaining a developer's environment with these tools, simplifying the process and saving time.

<h1></h1>

## Powershell git clone a special version of the CoreePower.Lib git to a local directoy
```
git clone --branch V0.0.0.178 --depth 1 https://github.com/carsten-riedel/CoreePower.Lib.git C:\VCS\raw\github.com\carsten-riedel\CoreePower.Module\V0.0.0.178 > null 2>&1
Remove-Item -Recurse -Force "C:\VCS\raw\github.com\carsten-riedel\CoreePower.Module\V0.0.0.178\.git"

```



#https://learn.microsoft.com/en-us/nuget/consume-packages/configuring-nuget-behavior
#https://learn.microsoft.com/en-us/nuget/consume-packages/managing-the-global-packages-and-cache-folders

if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}


function Install-NugetToPackagemanagement {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$RequiredVersion = $null,
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [ModuleScope]::LocalMachine)  {
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Install-Package -Name $Name -RequiredVersion $RequiredVersion -Source NuGet -ProviderName NuGet -Scope AllUsers  | Out-Null
        $global:ProgressPreference = $originalProgressPreference
    }
    elseif ($Scope -eq [ModuleScope]::CurrentUser) {
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Install-Package -Name $Name -RequiredVersion $RequiredVersion -Source NuGet -ProviderName NuGet -Scope CurrentUser | Out-Null
        $global:ProgressPreference = $originalProgressPreference
    }
}

function Get-NugetToPackagemanagementPathLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$RequiredVersion = $null,
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [ModuleScope]::LocalMachine) {
        return Find-Package -Name $Name -AllVersions -Source "$($Env:Programfiles)\AppData\Local\PackageManagement\NuGet\Packages" | Select-Object -First 1 @{Name='Path'; Expression={"$($_.Source)\$($_.Name).$($_.Version)"}} | Select-Object -ExpandProperty Path
    }
    elseif ($Scope -eq [ModuleScope]::CurrentUser) {
        return Find-Package -Name $Name -AllVersions -Source "$($env:userprofile)\AppData\Local\PackageManagement\NuGet\Packages" | Select-Object -First 1 @{Name='Path'; Expression={"$($_.Source)\$($_.Name).$($_.Version)"}}  | Select-Object -ExpandProperty Path
    }
}

function Initialize-Powershell {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    Initialize-NugetPackageProvider -Scope $Scope
    Initialize-PowerShellGet -Scope $Scope
    Initialize-PackageManagement -Scope $Scope
    Initialize-NugetSourceRegistered
}

function Initialize-CorePowerLatest {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("cpcp")] 
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($null -ne $MyInvocation.MyCommand.Module)
    {
        $module = Get-Module -Name $MyInvocation.MyCommand.Module.Name
        $moduleName = $module.Name
        $moduleVersion = $module.Version
    }
    else {
        $moduleName = $MyInvocation.MyCommand.CommandType
        $moduleVersion = "None"
    }


    Write-FormatedText -PrefixText "$moduleName" -ContentText "Useing module version: $moduleVersion" -SuffixText "Info"

    $updatesDone = $false
    
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-NugetPackageProvider" -SuffixText "Initiated"
    Initialize-NugetPackageProvider -Scope $Scope
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-NugetPackageProvider" -SuffixText "Completed"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-PowerShellGet" -SuffixText "Initiated"
    Initialize-PowerShellGet  -Scope $Scope
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-PowerShellGet" -SuffixText "Completed"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-PackageManagement" -SuffixText "Initiated"
    Initialize-PackageManagement  -Scope $Scope
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-PackageManagement" -SuffixText "Completed"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Update-ModulesLatest CoreePower.Module CoreePower.Config" -SuffixText "Initiated"
    $updatesDone = Update-ModulesLatest -ModuleNames @("CoreePower.Module","CoreePower.Config") -Scope $Scope
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Update-ModulesLatest CoreePower.Module CoreePower.Config" -SuffixText "Completed"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-NugetSourceRegistered" -SuffixText "Initiated"
    Initialize-NugetSourceRegistered
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Initialize-NugetSourceRegistered" -SuffixText "Completed"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Check"
    if (-not(Get-Command "7z" -ErrorAction SilentlyContinue)) {
        $sz = $(Invoke-RestMethod "https://sourceforge.net/projects/sevenzip/best_release.json").platform_releases.windows
        $temporaryDir = New-TempDirectory
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Download"
        $file = Get-RedirectDownload -Url "$($sz.url)" -OutputDirectory "$temporaryDir"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Download Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Change Invoker"
        Set-AsInvoker -FilePath "$file"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Change Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Extracting"
        $output, $errorOutput = Start-ProcessSilent -File "$file" -Arguments "/S /D=`"$($env:localappdata)\7zip`""
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Extracting Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\7zip" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Available"
    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "7z commandline" -SuffixText "Completed"

    
    Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Check"
    if (-not(Get-Command "git" -ErrorAction SilentlyContinue)) {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Download"
        $file = Download-GithubLatestReleaseMatchingAssets -RepositoryUrl "https://github.com/git-for-windows/git/releases" -AssetNameFilters @("Portable","64-bit",".exe")
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Download Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Extracting"
        &7z x -y -o"$($env:localappdata)\PortableGit" "$file" | Out-Null
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Extracting Completed"

        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Initializing"
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $currendir = Get-Location
        Set-Location "$($env:localappdata)\PortableGit"
        $psi.FileName = "$($env:localappdata)\PortableGit\git-bash.exe"
        $psi.Arguments = "--hide --no-cd --command=post-install.bat"
        $psi.WorkingDirectory = [System.IO.Path]::GetDirectoryName("$($env:localappdata)\PortableGit\git-bash.exe")
        $psi.UseShellExecute = $false
        $process = [System.Diagnostics.Process]::Start($psi)
        $process.WaitForExit()
        Set-Location $currendir
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Initializing Completed"

        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\PortableGit\cmd" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Available"
    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "git commandline" -SuffixText "Completed"


    Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Check"
    if (-not(Get-Command "gh" -ErrorAction SilentlyContinue)) {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Download"
        $file = Download-GithubLatestReleaseMatchingAssets -RepositoryUrl "https://github.com/cli/cli/releases" -AssetNameFilters @("windows","amd64",".zip")
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Download Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Extracting"
        $temporaryDir = New-TempDirectory
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Expand-Archive -Path $file -DestinationPath $temporaryDir
        $global:ProgressPreference = $originalProgressPreference
        $source = "$temporaryDir"
        $destination = "$($env:localappdata)\githubcli"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Extracting Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Copying"
        Copy-Recursive -Source $source -Destination $destination
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Copying Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\githubcli\bin" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Available"
    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "gh commandline" -SuffixText "Completed"

    
    Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Check"
    if (-not(Get-Command "nuget" -ErrorAction SilentlyContinue)) {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Install"
        Install-NugetToPackagemanagement -Name "Nuget.Commandline"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Install Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Adding envar"
        $path = Get-NugetToPackagemanagementPathLatest -Name "Nuget.Commandline"
        AddPathEnviromentVariable -Path "$path\tools" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Available"
    } 
    else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "nuget commandline" -SuffixText "Completed"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Check"
    if (-not(Get-Command "dotnet" -ErrorAction SilentlyContinue)) {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Deploy"
        &powershell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; &([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Channel LTS" | Out-Null
        Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Deploy Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\Microsoft\dotnet" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Available"
    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "dotnet commandline" -SuffixText "Completed"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Check"
    if (-not((Test-Path "$($env:localappdata)\vscodezip\code.exe" -PathType Leaf))) {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Download"
        $temporaryDir = New-TempDirectory
        $file = Get-RedirectDownload2 -Url "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Download Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Extracting"
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Expand-Archive -Path $file -DestinationPath $temporaryDir
        $global:ProgressPreference = $originalProgressPreference
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Extracting Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Copying"
        Copy-Recursive -Source $temporaryDir -Destination "$($env:localappdata)\vscodezip"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Copying Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$($env:localappdata)\vscodezip\bin" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Adding envar Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Available"
    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "code commandline (visual studio code)" -SuffixText "Already available"
    }

    Write-FormatedText -PrefixText "$moduleName" -ContentText "Update-ModulesLatest CoreePower.Lib" -SuffixText "Initiated"
    $updatesDone = $updatesDone -or (Update-ModulesLatest -ModuleNames @("CoreePower.Lib") -Scope $Scope)
    Write-FormatedText -PrefixText "$moduleName" -ContentText "Update-ModulesLatest CoreePower.Lib" -SuffixText "Completed"

    if ($updatesDone)
    {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "A restart of Powershell is required to implement the update." -SuffixText "Info"
    }

}


if ($Host.Name -match "Visual Studio Code")
{
    function FOO {
        write-output "HEY"
        Start-Sleep 2
        write-output "HOY"
        }

       Start-Job -ScriptBlock ${Function:FOO} -Name "ddd" | Out-Null
   
       Wait-Job -Name @('ddd')   | Out-Null
     
       Receive-Job -Name @('ddd') -OutVariable result | Out-Null
       
       $state = Get-Job -State Completed
   
       $state | Remove-Job
   
       #$s = $result
    
       #$x=1
       #Initialize-CorePowerLatest

}



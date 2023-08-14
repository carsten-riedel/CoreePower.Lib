$includes = @(
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.System.Enum.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.System.Array.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.System.IO.ps1"} ,
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.System.Scope.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.System.CustomConsole.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.System.Enviroment.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.System.Web.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.System.Process.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Modules.Management.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.NugetPackageProvider.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.PowerShellGet.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.PackageManagement.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.NugetSourceRegistered.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.Powershell.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.PackagemanagementNuget.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.CoreeModules.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.7z.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Git.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Gh.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Wix.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Nuget.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Dotnet.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.VsCode.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Imagemagick.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.GitActionsRunner.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Pwsh.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.Python.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.MsOpenjdk17.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.AzurePipelinesAgent.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.DevTools.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.ps1"}
   
)

for ($index = 0; $index -lt $includes.Count; $index++) {

    $isloaded = ($includes[$index].Loaded)
    $iscaller = ($includes[$index].Name -eq $MyInvocation.ScriptName)

    if (-not($isloaded) -and -not($iscaller))
    {
        $script = Get-Content $includes[$index].Name -Raw
        $includes[$index].Loaded = $true

        if ($null -ne $script)
        {
            Write-Output "Dot source into the local scope $($includes[$index].Name)"
            . ([scriptblock]::Create($script))
        }
    }
}

<#
. "$PSScriptRoot\CoreePower.Lib.IO.ps1"
. "$PSScriptRoot\CoreePower.Lib.Scope.ps1"
. "$PSScriptRoot\CoreePower.Lib.Initialize.ps1"
. "$PSScriptRoot\CoreePower.Lib.ps1"

$IncludesNeeded = $false
#>
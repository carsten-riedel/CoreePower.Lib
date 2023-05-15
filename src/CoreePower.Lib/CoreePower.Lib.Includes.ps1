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
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.NugetPackageProvider.ps1"}
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.PowerShellGet.ps1"}
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.PackageManagement.ps1"}
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.NugetSourceRegistered.ps1"}
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
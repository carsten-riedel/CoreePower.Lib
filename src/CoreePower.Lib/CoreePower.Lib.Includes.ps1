
$global:includes = @(
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.IO.ps1"} ,
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Scope.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.Initialize.ps1"},
   @{ Loaded=$false; Name="$PSScriptRoot\CoreePower.Lib.ps1"}
)

for ($index = 0; $index -lt $global:includes.Count; $index++) {

    $isloaded = ($global:includes[$index].Loaded)
    $iscaller = ($global:includes[$index].Name -eq $MyInvocation.ScriptName)

    if (-not($isloaded) -and -not($iscaller))
    {
        $script = Get-Content $global:includes[$index].Name -Raw
        $global:includes[$index].Loaded = $true

        if ($script -ne $null)
        {
            Write-Output "Loading $($global:includes[$index].Name)"
            # Execute the script in the global scope using the . operator and the -Scope Global parameter
            . ([scriptblock]::Create($script)) -Scope Global
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
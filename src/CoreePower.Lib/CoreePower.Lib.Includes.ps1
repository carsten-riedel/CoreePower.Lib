

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
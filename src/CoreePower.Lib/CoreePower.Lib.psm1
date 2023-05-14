<#
    CoreePower.Lib root module
#>

# You can specify multiple .ps1 files here, but it's recommended to keep module functionality in a single file.
# Calling functions directly in .psm1 files requires enhanced system configuration, which is not standard practice.

. "$PSScriptRoot\CoreePower.Lib.Includes.ps1" 

$selffound = Get-ModulesLocal -ModuleNames @("CoreePower.Lib") -ModulRecordState All

if ($null -ne $selffound)
{
    $found = $false
    foreach($item in $selffound)
    {
        if (Test-Path "$($item.ModuleBase)\shown.txt") {
            $found = $true
        }
    }

    if (-not ($found))
    {
        $selffound = Get-ModulesLocal -ModuleNames @("CoreePower.Lib") -ModulRecordState  Latest
        $shown = "$($selffound.ModuleBase)\shown.txt"
        New-Item -ItemType File -Path $shown
        Write-Host "Thanks for installing CoreePower.Lib !"
        Write-Host "Note: the 'Initialize-CorePowerLatest' command may conflict with existing installations. Use with caution."
       
    }
}


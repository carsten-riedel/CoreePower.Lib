<#
    CoreePower.Lib root module
#>

. "$PSScriptRoot\CoreePower.Lib.ps1"

function IsLocalAdministrator {
    [alias("isladmin")]
    param()
    return HasLocalAdministratorClaim
}

function NewGuid {
    [alias("nguid")]
    param()
    $guid = New-Guid
    $guidString = $guid.ToString()
    return $guidString
}




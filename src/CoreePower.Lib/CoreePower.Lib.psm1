<#
    CoreePower.Lib root module
#>

. "$PSScriptRoot\CoreePower.Lib.ps1"

# Use Export-ModuleMember because FunctionsToExport can not export enums.
Export-ModuleMember -Enum Scope
Export-ModuleMember -Function HasLocalAdministratorClaim -Alias IsLocalAdministrator
Export-ModuleMember -Function NewGuid -Alias nguid



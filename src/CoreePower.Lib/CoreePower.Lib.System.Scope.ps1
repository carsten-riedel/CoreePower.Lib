if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) { 
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

<#
.SYNOPSIS
Checks whether the current user is a member of the local administrator group by inspecting the process claim.

.DESCRIPTION
This function checks the current user's process claim to determine whether they are a member of the local administrator group. This method is more accurate than other methods that rely on group membership alone.

.NOTES
This function may not work as expected in certain scenarios, such as when running under a virtualized environment.

.EXAMPLE
The following example checks whether the current user is a local administrator on the machine:
$isAdmin = HasLocalAdministratorClaim

.LINK
https://docs.microsoft.com/en-us/windows/security/identity-protection/access-control/access-control
#>
function HasLocalAdministratorClaim {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    $claims = (New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).Claims
    $administratorsSid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid, $null)

    foreach ($claim in $claims) {
        if ($claim.Value -eq $administratorsSid.Value) {
            $isAdmin = $true
            break
        }
    }
    return $isAdmin
}

<#
.SYNOPSIS
This function checks whether the current user has local administrator privileges and returns a Boolean value indicating the result.

.EXAMPLE
The following example assigns the Boolean result of the function to a variable named $CanBeAdmin:
$CanBeAdmin = CouldRunAsAdministrator

.PARAMETER
This function does not accept any parameters.

.NOTES
This function has an alias "ilag" for ease of use.
#>

function CouldRunAsAdministrator {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("craa")]
    param()
    $isAdmin = HasLocalAdministratorClaim
    return $isAdmin
}

<#
.SYNOPSIS
Checks whether the current user has sufficient privileges to execute an operation in the desired scope.

.PARAMETER Scope
Specifies the desired scope. This can be one of the following values: "CurrentUser" or "LocalMachine".

.EXAMPLE
The following example checks whether the current user has sufficient privileges to execute an operation in the "LocalMachine" scope:
$canExecute = CanExecuteInDesiredScope -Scope LocalMachine

.NOTES
This function has an alias "cedc" for ease of use.
#>
function CanExecuteInDesiredScope {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("cedc")]
    param (
        [ModuleScope]$Scope
    )

    $IsAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    #Microsoft just does this inside Install-PowerShellRemoting.ps1
    #if (! ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    #Write-Error "WinRM registration requires Administrator rights. To run this cmdlet, start PowerShell with the `"Run as administrator`" option."
    #return


    if ($Scope -eq [ModuleScope]::CurrentUser) {
        return $true
    } elseif ($Scope -eq [ModuleScope]::LocalMachine) {
        if ($IsAdmin -eq $true) {
            return $true
        } elseif (CouldRunAsAdministrator) {
            # The current user is not running as admin, but is a member of the local admin group
            Write-Error "The operation cannot be executed in the desired scope due to insufficient privileges of the process. You need to run the process as an administrator."
            return $false
        } else {
            # The current user is not an administrator
            Write-Error "The operation cannot be executed in the desired scope due to insufficient privileges of the user. You need to run the process as an administrator for this you need to be member of the local Administrators group."
            return $false
        }
    }
}
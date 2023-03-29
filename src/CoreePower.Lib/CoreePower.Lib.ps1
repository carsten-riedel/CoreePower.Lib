enum Scope {
    CurrentUser = 1
    LocalMachine = 2
}

# Check if the current user is a local administrator on the machine, to be 100% accurate you normaly need to check the process claim, have fun :)
function HasLocalAdministratorClaim {
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

# Check if the current process can execute in the desired scope
function CanExecuteInDesiredScope {
    param (
        [Scope]$Scope
    )

    $IsAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($Scope -eq [Scope]::CurrentUser) {
        return $true
    } elseif ($Scope -eq [Scope]::LocalMachine) {
        if ($IsAdmin -eq $true) {
            return $true
        } elseif (HasLocalAdministratorClaim) {
            # The current user is not running as admin, but is a member of the local admin group
            Write-Error "The operation cannot be executed in the desired scope due to insufficient privileges of the process. You need to run the process as an administrator."
            exit
        } else {
            # The current user is not an administrator
            Write-Error "The operation cannot be executed in the desired scope due to insufficient privileges of the user. You need to run the process as an administrator for this you need to be member of the local Administrators group."
            exit
        }
    }
}

# Modify user or machine settings based on the desired scope
function ChangeSomethingScoped {
    param(
        [Parameter(Position = 0)]
        [Scope]$Scope = [Scope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    CanExecuteInDesiredScope -Scope $Scope

    if ($Scope -eq [Scope]::CurrentUser)
    {
        # Modify user settings
        Write-Output "Modifying user settings..."
    }
    elseif ($Scope -eq [Scope]::LocalMachine) {
        # Modify machine settings
        Write-Output "Modifying machine settings..."
    }
}


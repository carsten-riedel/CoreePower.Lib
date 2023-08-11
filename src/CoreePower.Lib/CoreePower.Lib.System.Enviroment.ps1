function AddPathEnviromentVariable {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }
    
    if ($Scope -eq [ModuleScope]::CurrentUser) {
        # Basic add if not contains
        $USERPATHS = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::User)
        $USERPATHSARRAY = $USERPATHS.Split(';')
        if (-not($USERPATHSARRAY.Contains($Path)))
        {
            $NEW = "$USERPATHS;$Path"
            [System.Environment]::SetEnvironmentVariable("PATH",$NEW,[System.EnvironmentVariableTarget]::User)
        }

        #Remove duplicates,sort and remove trailing slashes
        $USERPATHS = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::User)
        $USERPATHSARRAY = $USERPATHS.Split(';') | Select-Object -Unique | Sort-Object
        $USERPATHSARRAY = $USERPATHSARRAY | ForEach-Object { $_.TrimEnd('\') }
        $JOINEDUSERPATHSARRAY = $USERPATHSARRAY -join ';'
        $JOINEDUSERPATHSARRAY = $JOINEDUSERPATHSARRAY.TrimStart(';')
        $JOINEDUSERPATHSARRAY = $JOINEDUSERPATHSARRAY.TrimEnd(';')
        [System.Environment]::SetEnvironmentVariable("PATH",$JOINEDUSERPATHSARRAY,[System.EnvironmentVariableTarget]::User)
    }
    elseif ($Scope -eq [ModuleScope]::LocalMachine) {
        $MACHINEPATHS = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::Machine)
        $MACHINEPATHSARRAY = $MACHINEPATHS.Split(';')
        if (-not($MACHINEPATHSARRAY.Contains($Path)))
        {
            $NEW = "$MACHINEPATHS;$Path"
            [System.Environment]::SetEnvironmentVariable("PATH",$NEW,[System.EnvironmentVariableTarget]::Machine)
        }

        #Remove duplicates,sort and remove trailing slashes
        $MACHINEPATHS = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::User)
        $MACHINEPATHSARRAY = $MACHINEPATHS.Split(';') | Select-Object -Unique | Sort-Object
        $MACHINEPATHSARRAY = $MACHINEPATHSARRAY | ForEach-Object { $_.TrimEnd('\') }
        $JOINEDMACHINEPATHSARRAY = $MACHINEPATHSARRAY -join ';'
        $JOINEDMACHINEPATHSARRAY = $JOINEDMACHINEPATHSARRAY.TrimStart(';')
        $JOINEDMACHINEPATHSARRAY = $JOINEDMACHINEPATHSARRAY.TrimEnd(';')
        [System.Environment]::SetEnvironmentVariable("PATH",$JOINEDMACHINEPATHSARRAY,[System.EnvironmentVariableTarget]::User)
    }

    $PROCESSPATHS = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::Process)
    $NEW = "$PROCESSPATHS;$Path"
    [System.Environment]::SetEnvironmentVariable("PATH",$NEW,[System.EnvironmentVariableTarget]::Process)
}


function AddEnviromentVariable {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [ValidateNotNullOrEmpty()]
        [string]$Value,
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }
    
    if ($Scope -eq [ModuleScope]::CurrentUser) {
        # Basic add if not contains
        [System.Environment]::SetEnvironmentVariable($Name,$Value,[System.EnvironmentVariableTarget]::User)
    }
    elseif ($Scope -eq [ModuleScope]::LocalMachine) {
        [System.Environment]::SetEnvironmentVariable($Name,$Value,[System.EnvironmentVariableTarget]::Machine)
    }
    
    [System.Environment]::SetEnvironmentVariable($Name,$Value,[System.EnvironmentVariableTarget]::Process)
}

<#
.SYNOPSIS
Removes a directory path from the system's environment variable PATH for a specified scope.

.PARAMETER Path
Specifies the directory path to remove from the PATH environment variable.

.PARAMETER Scope
Specifies the scope where the path will be removed. This can be one of the following values: "CurrentUser" or "LocalMachine". The default value is "CurrentUser".

.NOTES
This function has an alias "delenvpath" for ease of use.

.EXAMPLE
The following example removes the directory "C:\OldDirectory" from the PATH environment variable for the current user:
DeletePathEnvironmentVariable -Path "C:\OldDirectory"

#>
function DeletePathEnviromentVariable {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("delenvpath")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Scope]$Scope = [Scope]::CurrentUser
    )
    
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [Scope]::CurrentUser) {
        $UserPathArrayNew = @()
        $UserPathArray = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::User) -split ';'
        foreach ($item in $UserPathArray)
        {
            if ($Path -notlike $item)
            {
                $UserPathArrayNew += $item
            }
        }
        $UserPathArrayNewString = $UserPathArrayNew  -join ';'
        [System.Environment]::SetEnvironmentVariable("PATH",$UserPathArrayNewString,[System.EnvironmentVariableTarget]::User)
    }
    elseif ($Scope -eq [Scope]::LocalMachine) {
        $MachinePathArrayNew = @()
        $MachinePathArray = [System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::Machine) -split ';'
        foreach ($item in $MachinePathArray)
        {
            if ($Path -notlike $item)
            {
                $MachinePathArrayNew += $item
            }
        }
        $MachinePathArrayNewString = $MachinePathArrayNew  -join ';'
        [System.Environment]::SetEnvironmentVariable("PATH",$MachinePathArrayNewString,[System.EnvironmentVariableTarget]::Machine)
    }
}

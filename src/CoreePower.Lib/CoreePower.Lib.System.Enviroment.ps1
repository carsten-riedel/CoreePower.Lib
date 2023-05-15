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

AddPathEnviromentVariable2 -Path "C:\tempxxx"
if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) { 
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
 }

function Test-InteractiveShell {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param()

    $commandLineArgs = [Environment]::GetCommandLineArgs()
    $nonInteractiveArg = $commandLineArgs | Where-Object { $_ -like '*-NonInteractive*' }

    $isInteractive = [Environment]::UserInteractive -and (-not $nonInteractiveArg)

    return $isInteractive
}



function Restart-Proc {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param (
        [string]$InvokeCommand = "Restart-Proc",
        [bool]$ThisModuleScriptLoading = $false
    )

    if (-not(CanExecuteInDesiredScope -Scope ([Scope]::LocalMachine)))
    {
        $InteractiveShell = Test-InteractiveShell

        $currentPowershellProcess = Get-Process -Id $PID | Select-Object Path , CommandLine
        
        $manifestPath = ""
        $importOrDotSource = ""
        if ($ThisModuleScriptLoading)
        {
            if ($null -ne $MyInvocation.MyCommand.Module)
            {
                $manifestPath = (Get-Module -Name $MyInvocation.MyCommand.Module.Name).Path
            }
            $scriptPath = $MyInvocation.ScriptName
            if ($manifestPath -ne "")
            {
                $importOrDotSource = "Import-Module $manifestPath -DisableNameChecking"
            }
            else {
                $importOrDotSource = ". `"$scriptPath`""
            }
        }

        if ($InteractiveShell)
        {
            $CertAnswer = Confirm-AdminRightsEnabled
            if ($CertAnswer -eq 0)
            {
                Start-Process $currentPowershellProcess.Path -ArgumentList "-NoProfile -ExecutionPolicy ByPass -Command `"$importOrDotSource ; $InvokeCommand`" ; Start-Sleep 10" -Verb RunAs
            }
            return
        } else {
            Start-Process $currentPowershellProcess.Path -ArgumentList "-NoProfile -ExecutionPolicy ByPass -Command `"$importOrDotSource ; $InvokeCommand`" ; Start-Sleep 10" -Verb RunAs
            return
        }
    }
    else {
        Write-Host "Restart-Proc echo"
        Write-Host "Wait 10 seconds."
        Start-Sleep 10
    }
}


#Write-Begin "Initialize-NugetSourceRegistered" -State "Checking"
#Write-State "Donex"
#Write-State "sdgsdg"

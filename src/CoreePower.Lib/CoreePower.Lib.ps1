if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) { 
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
 }


function Write-Begin {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [string]$Text,
        $State
    )

    $WriteOut = @(
        @{ Items=@("installed","ok","already installed","true",'installing',"done"); Color="Green"; },
        @{ Items=@("not installed"); Color="Red"; },
        @{ Items=@("open","check","checking","info"); Color="Yellow"; }
    )

    $uneven = $Host.UI.RawUI.BufferSize.Width % 16
    $parts = ($Host.UI.RawUI.BufferSize.Width - $uneven) / 16

    $consoleWidth = ($parts * 8) + $uneven
    $IntroLimit = $parts * 5
    $StateLimit = $parts * 3
    $TextLimit = $consoleWidth

    $date = [datetime]::Now.ToString()

    $intro = "CoreePower $date`:".PadRight($IntroLimit, ' ').Substring(0,$IntroLimit)
    $Text = "$Text".PadRight($TextLimit, ' ').Substring(0,$TextLimit)
    

    Write-Host -NoNewline "$intro" -ForegroundColor DarkGray -BackgroundColor Black
    Write-Host -NoNewline "$Text" -ForegroundColor Gray -BackgroundColor Black


    if ($null -ne $State )
    {
        $stateStriped = $State.Trim().Trim('.').Trim('!').Trim('?').Trim().ToLower()
        $color = $WriteOut | Where-Object { $_.Items -contains $stateStriped } | Select-Object -First 1
        if ($null -eq $color.Color) { 
            $color = "White"
        }
        else {
            $color= $color.Color
        }

        $write = "$State".PadRight($StateLimit, ' ').Substring(0,$StateLimit)
        Write-Host "$write" -ForegroundColor $color -BackgroundColor Black

    }
    else {
        $write = "".PadRight($StateLimit, ' ').Substring(0,$StateLimit)
        Write-Host "$write" -ForegroundColor White -BackgroundColor Black
    }
}

function Write-State {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [string]$State
    )

    $WriteOut = @(
        @{ Items=@("installed","ok","already installed","true",'installing',"done"); Color="Green"; },
        @{ Items=@("not installed"); Color="Red"; },
        @{ Items=@("open","check","checking","info"); Color="Yellow"; }
    )

    $uneven = $Host.UI.RawUI.BufferSize.Width % 16
    $parts = ($Host.UI.RawUI.BufferSize.Width - $uneven) / 16

    $consoleWidth = ($parts * 8) + $uneven
    $IntroLimit = $parts * 5
    $StateLimit = $parts * 3
    $TextLimit = $consoleWidth

    Set-ConsoleCursorPosition -X ($IntroLimit + $consoleWidth) -Y ($Host.UI.RawUI.CursorPosition.Y - 1)

    if ($null -ne $State )
    {
        $stateStriped = $State.Trim().Trim('.').Trim('!').Trim('?').Trim().ToLower()
        $color = $WriteOut | Where-Object { $_.Items -contains $stateStriped } | Select-Object -First 1
        if ($null -eq $color.Color) { 
            $color = "White"
        }
        else {
            $color= $color.Color
        }

        $write = "$State".PadRight($StateLimit, ' ').Substring(0,$StateLimit)
        Write-Host "$write" -ForegroundColor $color -BackgroundColor Black
    }
    else {
        $write = "".PadRight($StateLimit, ' ').Substring(0,$StateLimit)
        Write-Host "$write" -ForegroundColor White -BackgroundColor Black
    }


}

function Set-ConsoleCursorPosition {
    param($x, $y)

    $bufferWidth = $Host.UI.RawUI.BufferSize.Width
    $bufferHeight = $Host.UI.RawUI.BufferSize.Height

    if ($x -ge $bufferWidth) {
        $x = $bufferWidth - 1
    }

    if ($y -ge $bufferHeight) {
        $y = $bufferHeight - 1
    }

    $pos = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $x, $y
    $Host.UI.RawUI.CursorPosition = $pos
}

function Test-InteractiveShell {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param()

    $commandLineArgs = [Environment]::GetCommandLineArgs()
    $nonInteractiveArg = $commandLineArgs | Where-Object { $_ -like '*-NonInteractive*' }

    $isInteractive = [Environment]::UserInteractive -and (-not $nonInteractiveArg)

    return $isInteractive
}

function Confirm-AdminRightsEnabled {
    param()
    $title   = 'Administrator Rights Required'
    $msg     = 'This command requires administrator rights to run. Please activate/enabled administrator rights before continuing.'
    $Choices = @(
        [System.Management.Automation.Host.ChoiceDescription]::new("&Yes", "I have enabled administrator rights and understand the risks.")
        [System.Management.Automation.Host.ChoiceDescription]::new("&No", "I do not want to run this command.")
    )
    $ChoiceDefault = 1

    try {
        $result = $Host.UI.PromptForChoice($title, $msg, $Choices, $ChoiceDefault)
        return $result
    }
    catch {
        Write-Error "Error occurred while prompting for choice: $_"
        return 1
    }
}

function Restart-Proc {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param (
        [string]$InvokeCommand = "Restart-Proc",
        [bool]$ThisModuleScriptLoading = $true
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
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

    $uneven = $Host.UI.RawUI.WindowSize.Width % 16
    $parts = ($Host.UI.RawUI.WindowSize.Width - $uneven) / 16

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

    $uneven = $Host.UI.RawUI.WindowSize.Width % 16
    $parts = ($Host.UI.RawUI.WindowSize.Width - $uneven) / 16

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

#Write-Begin "Initialize-NugetSourceRegistered" -State "Checking"
#Write-State "Donex"
#Write-State "sdgsdg"
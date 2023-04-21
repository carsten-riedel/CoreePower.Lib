function Write-Begin {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [string]$Text,
        $State
    )

    $WriteOut = @(
        @{ Items=@("installed","ok","true"); Color="Green"; },
        @{ Items=@("not installed"); Color="Red"; },
        @{ Items=@("done","open"); Color="Yellow"; }
    )

    $uneven = $Host.UI.RawUI.WindowSize.Width % 16
    $parts = ($Host.UI.RawUI.WindowSize.Width - $uneven) / 16

    $consoleWidth = ($parts * 8) + $uneven
    $IntroLimit = $parts * 5
    $StateLimit = $parts * 3
    $TextLimit = $consoleWidth

    $date = [datetime]::Now.ToUniversalTime().ToString()

    $intro = "CoreePower $date`:".PadRight($IntroLimit, ' ').Substring(0,$IntroLimit)
    $Text = "$Text".PadRight($TextLimit, ' ').Substring(0,$TextLimit)
    
    Write-Host -NoNewline "$intro" -ForegroundColor Blue -BackgroundColor White
    Write-Host -NoNewline "$Text" -ForegroundColor DarkBlue -BackgroundColor White

    if ($null -ne $State )
    {
        $color = $WriteOut | Where-Object { $_.Items -contains $State.Trim().Trim('.').Trim('!').Trim('?').Trim() }
        if ($null -eq $color) { $color = "DarkBlue" }
        else {
            $color= $color |  Select-Object -ExpandProperty Color
        }

        Write-Host "$State".PadRight($StateLimit, ' ').Substring(0,$StateLimit) -ForegroundColor $color -BackgroundColor White
    }
    else {
        Write-Host "".PadRight($StateLimit, ' ').Substring(0,$StateLimit) -ForegroundColor DarkBlue -BackgroundColor White
    }
}

function Write-State {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory)]
        [string]$State
    )

    $WriteOut = @(
        @{ Items=@("installed","ok","true"); Color="Green"; },
        @{ Items=@("not installed"); Color="Red"; },
        @{ Items=@("done"); Color="Yellow"; }
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
        $color = $WriteOut | Where-Object { $_.Items -contains $State.Trim().Trim('.').Trim('!').Trim('?').Trim()  }
        if ($null -eq $color) { $color = "DarkBlue" }
        else {
            $color= $color |  Select-Object -ExpandProperty Color
        }
        Write-Host "$State".PadRight($StateLimit, ' ').Substring(0,$StateLimit) -ForegroundColor $color -BackgroundColor White
    }
    else {
        Write-Host "".PadRight($StateLimit, ' ').Substring(0,$StateLimit) -ForegroundColor DarkBlue -BackgroundColor White
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

#Write-Begin "sdfsdf" -State "aaaaa"
#Write-State "done"
#Write-State "sdgsdg"
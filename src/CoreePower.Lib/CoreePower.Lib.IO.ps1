

function Copy-Recursive {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("copyrec")] 
    param (
        [string]$Source,
        [string]$Destination
    )
    Get-ChildItem $Source -Recurse | Foreach-Object {
        $targetPath = $_.FullName -replace [regex]::Escape($Source), $Destination
        if ($_.PSIsContainer) {
            New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        }
        else {
            Copy-Item $_.FullName -Destination $targetPath -Force | Out-Null
        }
    }
}

function New-Tempdir {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("newtmp")] 
    param ()

    $temporaryDir = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
    if (-not (Test-Path $temporaryDir)) {
        New-Item -ItemType Directory -Path $temporaryDir -Force | Out-Null
    }

    return $temporaryDir
}
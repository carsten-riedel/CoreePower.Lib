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

<#
.SYNOPSIS
    Updates the specified text in one or multiple files using the specified encoding.

.DESCRIPTION
    The `Update-TextInFileWithEncoding` function replaces the specified text in one or multiple files with the provided replacement text, using the specified encoding.

.PARAMETER FilePath
    Specifies the path to the file or files in which the text should be replaced. This parameter can accept an array of strings to support multiple file paths.

.PARAMETER SearchText
    Specifies the text to search for in the file or files.

.PARAMETER ReplaceText
    Specifies the replacement text to use.

.PARAMETER Encoding
    Specifies the encoding to use when reading and writing the file or files. The default encoding is UTF-8.

.NOTES
    - The function performs a byte-level search and replace operation in the file or files.
    - The function uses the specified encoding when reading the file or files and writing the modified content back to the file or files.
    - If the search text is found in the file or files, it is replaced with the provided replacement text.
    - If the search text is not found in any of the files, an error is displayed.
    - The FilePath parameter accepts an array of strings to support multiple file paths.
    - The FilePath parameter is mandatory, while the SearchText and ReplaceText parameters are optional.
#>
function Update-TextInFileWithEncoding {
    param (
        [Parameter(Mandatory = $true)]
        [string[]] $FilePath,
        [Parameter(Mandatory = $true)]
        [string] $SearchText,
        [Parameter(Mandatory = $true)]
        [string] $ReplaceText,
        [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8
    )

    foreach ($file in $FilePath) {
        $bytes = [System.IO.File]::ReadAllBytes($file)

        # Define the byte sequences to search for and replace.
        $searchBytes = $Encoding.GetBytes($SearchText)
        $replaceBytes = $Encoding.GetBytes($ReplaceText)

        # Find the position of the search bytes.
        $pos = IndexOfBytes $bytes $searchBytes

        if ($pos -ge 0) {
            # Replace the search bytes with the replace bytes.
            for ($i = 0; $i -lt $replaceBytes.Length; $i++) {
                $bytes[$pos + $i] = $replaceBytes[$i]
            }

            # Write the modified bytes back to the file.
            [System.IO.File]::WriteAllBytes($file, $bytes)
        }
        else {
            Write-Error "No search text found in $file"
        }
    }
}


<#
.SYNOPSIS
    Replaces the requireAdministrator manifest entry with asInvoker in an application manifest file.

.DESCRIPTION
    The `Set-AsInvoker` function replaces the `requireAdministrator` manifest entry with `asInvoker` in the specified application manifest file. It uses the `Update-TextInFileWithEncoding` function to perform the replacement.

.PARAMETER FilePath
    Specifies the path to the application manifest file to update.

.NOTES
    - The function performs a text-based search and replace operation in the file, using ASCII encoding.
    - If the `requireAdministrator` entry is found in the file, it is replaced with `asInvoker`.
    - If the `requireAdministrator` entry is not found, an error is displayed.
#>
function Set-AsInvoker {
    param (
        [Parameter(Mandatory = $true)]
        [string] $FilePath
    )

    $searchText = 'requireAdministrator"'
    $replaceText = 'asInvoker"           '

    Update-TextInFileWithEncoding -FilePath $FilePath -SearchText $searchText -ReplaceText $replaceText -Encoding ([System.Text.Encoding]::ASCII)
}
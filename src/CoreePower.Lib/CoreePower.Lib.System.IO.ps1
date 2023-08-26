<#
.SYNOPSIS
    Recursively copies files and directories from a source directory to a destination directory.

.DESCRIPTION
    The `Copy-Recursive` function allows you to copy files and directories from a specified source directory to a destination directory. It performs a recursive copy operation, preserving the directory structure of the source directory.

.PARAMETER Source
    Specifies the path to the source directory. This is the directory from which files and directories will be copied.

.PARAMETER Destination
    Specifies the path to the destination directory. This is the directory where the files and directories from the source directory will be copied to.

.NOTES
    - This function performs a recursive copy, copying all files and directories from the source directory to the destination directory.
    - The directory structure of the source directory is preserved in the destination directory.
    - If the destination directory does not exist, it will be created.
    - If a file or directory with the same name already exists in the destination directory, it will be overwritten.
    - The function accepts the alias 'copyrec' for easier use.

.EXAMPLE
    PS C:\> Copy-Recursive -Source 'C:\SourceFolder' -Destination 'C:\DestinationFolder'

    This example copies all files and directories from 'C:\SourceFolder' to 'C:\DestinationFolder', preserving the directory structure.
#>
function Copy-Recursive {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [alias("copyrec")] 
    param (
        [string]$Source,
        [string]$Destination
    )

    New-Directory -Directory $Destination

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

<#
.SYNOPSIS
    Creates a new temporary directory in the AppData\Local\Temp directory.

.DESCRIPTION
    The `New-TempDirectory` function creates a new temporary directory in the AppData\Local\Temp directory. It generates a unique identifier using `[System.Guid]::NewGuid().ToString()` and combines it with the AppData\Local\Temp path to create a unique directory path. If the directory does not exist, it is created using `New-Item`.

.NOTES
    - The function provides a convenient way to generate and create a new temporary directory.
    - The generated temporary directory path is returned as the output.
    - This function uses the `LocalApplicationData` folder within the AppData directory to ensure the creation of the temporary directory in the user's local application data.
    - The function accepts the alias 'newtmpdir' for easier use.
    
.EXAMPLE
    PS C:\> New-TempDirectory

    This example creates a new temporary directory in the AppData\Local\Temp directory and returns the path of the newly created directory.
#>
function New-TempDirectory {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [Alias("newtmpdir")]
    param ()

    $tempDirectoryPath = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Temp' | Join-Path -ChildPath ([System.Guid]::NewGuid().ToString())
    if (-not (Test-Path $tempDirectoryPath)) {
        New-Item -ItemType Directory -Path $tempDirectoryPath -Force | Out-Null
    }

    return $tempDirectoryPath
}

function New-Directory {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory
    )

    if (-not(Test-Path -Path $Directory -PathType Container)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }

    if (Test-Path -Path $Directory -PathType Leaf) {
        $Directory = [System.IO.Path]::GetDirectoryName($Directory)
        $Directory = New-Directory -Directory $Directory
    }

    return $Directory
}

function Remove-TempDirectory {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    [Alias("rmtmpdir")]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TempDirectory
    )
 
    if (Test-Path -Path $TempDirectory -PathType Container) {
        Remove-Item -Path "$TempDirectory" -Recurse -Force
    }

    if (Test-Path -Path $TempDirectory -PathType Leaf) {
        $TempDirectory = [System.IO.Path]::GetDirectoryName($TempDirectory)
        $guidPattern = "\\[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
        if ($TempDirectory -match $guidPattern) {
            # Removing parent directory recursively if it is a guid pattern
            Remove-Item -Path "$TempDirectory" -Recurse -Force
        }
    }

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

function Recursive-Copy {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [string]$Source,       # The source directory to copy from
        [string]$Destination   # The destination directory to copy to
    )

    # Create the destination directory, if it doesn't exist
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null

    # Get all items in the source directory recursively
    $items = Get-ChildItem $Source -Recurse
    for ($i = 0; $i -lt $items.Count; $i++) {
        $sourceItem = $items[$i]

        # Replace the source path with the destination in the target path
        $targetPath = $sourceItem.FullName -replace [regex]::Escape($Source), $Destination

        if (Test-Path -Path $targetPath)
        {
            $targetItem = Get-Item $targetPath
        }

        # Check if the current sourceItem is a directory
        if ($sourceItem.PSIsContainer) {
            # If it is, create the same directory structure in the destination
            New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        } else {

            $overwrite = $true

            if (Test-Path -Path $targetPath -PathType Leaf)
            {
                # If it's a file, copy it to the destination
                if ($sourceItem.Extension -eq ".dll" -or $sourceItem.Extension -eq ".exe" -or $sourceItem.Extension -eq ".sys" )
                {
                    $sourceVersion = (Get-Command "$($sourceItem.FullName)")
                    $destVersion =  (Get-Command "$($targetPath)")

                    if (($sourceItem.Length -eq $targetItem.Length) -and ($sourceItem.Length -eq $targetItem.Length))
                    {
                        if ($sourceVersion.FileVersionInfo.FileVersion -eq $destVersion.FileVersionInfo.FileVersion)
                        {
                            if ($sourceVersion.FileVersionInfo.ProductVersion -eq $destVersion.FileVersionInfo.ProductVersion)
                            {
                                $overwrite = $false
                            }
                        }

                    }
                }
                elseif ($sourceItem.Extension -eq ".ico")
                {
                  if (($sourceItem.Length -eq $targetItem.Length) -and ($sourceItem.Length -eq $targetItem.Length))
                    {
                        if ($sourceItem.LastWriteTimeUtc -eq $targetItem.LastWriteTimeUtc)
                        {
                                $overwrite = $false
                        }

                    }
                }
            }

            if ($overwrite)
            {
                Write-Host "Copying"
                Write-Host "$($sourceItem.FullName)"
                Write-Host "$targetPath"       
                Copy-Item $sourceItem.FullName -Destination $targetPath -Force | Out-Null
            }
            else {
                Write-Host "Skipping"
                Write-Host "$($sourceItem.FullName)"
            }
            Write-Host ""
            
        }
    }
}

function Find-FileRecursively {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DirectoryPath,
        
        [Parameter(Mandatory = $true)]
        [string]$FileName
    )

    $foundFiles = Get-ChildItem -Path $DirectoryPath -Recurse -File | Where-Object { $_.Name -eq $FileName }


    if ($foundFiles.Count -eq 1) {
        $found = $foundFiles | Select-Object -First 1 -Property FullName
        return $found.FullName
    }
}

function Find-FileDirRecursively {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DirectoryPath,
        
        [Parameter(Mandatory = $true)]
        [string]$FileName
    )

    $found = Find-FileRecursively -DirectoryPath $DirectoryPath -FileName $FileName
    $Directory = [System.IO.Path]::GetDirectoryName($found)
    return $Directory    
}

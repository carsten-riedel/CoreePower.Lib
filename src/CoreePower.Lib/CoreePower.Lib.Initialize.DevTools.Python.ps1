if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

function Sort-MatchGroups {
    param(
        [Parameter(Mandatory=$true)]
        [Array]$MatchGroupsArray,

        [Parameter(Mandatory=$true)]
        [Array]$SortingParameter,

        [Parameter(Mandatory=$false)]
        [Array]$TryVersionConvertForSorting = @()
    )

    # If there's only one or no SortingParameter left, perform final sorting and return
    if ($SortingParameter.Count -le 1) {
        $param = $SortingParameter[0]

        if ($TryVersionConvertForSorting -contains $param) {
            return $MatchGroupsArray | Sort-Object -Property {
                # Try to convert to version; if fail, use the original value
                try {
                    [Version]$_.($param)
                }
                catch {
                    $_.($param)
                }
            }
        }
        else {
            return $MatchGroupsArray | Sort-Object -Property $param
        }
    }

    # Perform grouping and sort each group separately
    $param = $SortingParameter[0]
    $groupedArray = $MatchGroupsArray | Group-Object -Property $param

    # Initialize the sorted array
    $sortedArray = @()

    foreach ($group in $groupedArray) {
        # Recursively sort each group using the rest of the SortingParameters
        $sortedGroup = Sort-MatchGroups -MatchGroupsArray $group.Group -SortingParameter $SortingParameter[1..($SortingParameter.Count - 1)] -TryVersionConvertForSorting $TryVersionConvertForSorting

        # Append the sorted group to the sorted array
        $sortedArray += $sortedGroup
    }

    return $sortedArray
}

function Sort-MatchGroups2 {
    param(
        [Parameter(Mandatory=$true)]
        [Array]$MatchGroupsArray,

        [Parameter(Mandatory=$true)]
        [Array]$SortingParameter,

        [Parameter(Mandatory=$false)]
        [Array]$TryVersionConvertForSorting = @()
    )

    $param = $SortingParameter[0]



    for ($i = 0; $i -lt $SortingParameter.Count; $i++) {
        $input = $input | Group-Object -Property $SortingParameter[$i]
        <# Action that will repeat until the condition is met #>
    }

    $srt = $MatchGroupsArray | Group-Object -Property $param

    # If there's only one or no SortingParameter left, perform final sorting and return
    if ($SortingParameter.Count -le 1) {
        $param = $SortingParameter[0]

        if ($TryVersionConvertForSorting -contains $param) {
            return $MatchGroupsArray | Sort-Object -Property {
                # Try to convert to version; if fail, use the original value
                try {
                    [Version]$_.($param)
                }
                catch {
                    $_.($param)
                }
            }
        }
        else {
            return $MatchGroupsArray | Sort-Object -Property $param
        }
    }

    # Perform grouping and sort each group separately
    $param = $SortingParameter[0]
    $groupedArray = $MatchGroupsArray | Group-Object -Property $param

    # Initialize the sorted array
    $sortedArray = @()

    foreach ($group in $groupedArray) {
        # Recursively sort each group using the rest of the SortingParameters
        $sortedGroup = Sort-MatchGroups -MatchGroupsArray $group.Group -SortingParameter $SortingParameter[1..($SortingParameter.Count - 1)] -TryVersionConvertForSorting $TryVersionConvertForSorting

        # Append the sorted group to the sorted array
        $sortedArray += $sortedGroup
    }

    return $sortedArray
}

function Sort-Hashtable {
    param (
        [Parameter(Mandatory=$true)]
        [Hashtable]$Hashtable,

        [Parameter(Mandatory=$false)]
        [bool]$TryTreatKeyAsPossibleVersion = $false
    )

    $sorted = [ordered]@{}

    # Sort hashtable by key
    $keys = $Hashtable.Keys
    if ($TryTreatKeyAsPossibleVersion) {
        $allKeysCanBeConvertedToVersion = $keys -cnotcontains $null -and ($keys | ForEach-Object {
            try {
                [version]$_ | Out-Null
                $true
            } catch {
                $false
            }
        }) -notcontains $false

        if ($allKeysCanBeConvertedToVersion) {
            $keys = $keys | Sort-Object -Property {[version]$_}
        } else {
            $keys = $keys | Sort-Object
        }
    } else {
        $keys = $keys | Sort-Object
    }

    foreach ($key in $keys) {
        $value = $Hashtable[$key]

        # If value is another hashtable, sort it too
        if ($value -is [Hashtable]) {
            $value = Sort-Hashtable -Hashtable $value -TryTreatKeyAsPossibleVersion $TryTreatKeyAsPossibleVersion
        }
        # If value is an array of hashtables, sort each hashtable
        elseif ($value -is [Array] -and $value[0] -is [Hashtable]) {
            $sortedArray = @()
            foreach ($item in $value) {
                $sortedArray += , (Sort-Hashtable -Hashtable $item -TryTreatKeyAsPossibleVersion $TryTreatKeyAsPossibleVersion)
            }
            $value = $sortedArray
        }

        $sorted[$key] = $value
    }

    return $sorted
}



function Group-CustomObjectArray {
    param (
        [Parameter(Mandatory=$true)]
        [Array]$InputArray,

        [Parameter(Mandatory=$true)]
        [Array]$GroupBy
    )

    # Initiate empty hashtable for grouping
    $groups = @{}

    foreach ($object in $InputArray) {
        $nestedGroup = $groups # Start at top level

        for ($i = 0; $i -lt $GroupBy.Count; $i++) {
            $property = $GroupBy[$i]
            $value = $object.$property

            # If it's the last property, add object to group
            if ($i -eq $GroupBy.Count - 1) {
                if (-not $nestedGroup.ContainsKey($value)) { 
                    $nestedGroup[$value] = @()
                }
                $nestedGroup[$value] += $object
            } else {
                # Otherwise, go deeper or create new group
                if (-not $nestedGroup.ContainsKey($value)) { 
                    $nestedGroup[$value] = @{} 
                }
                $nestedGroup = $nestedGroup[$value]
            }
        }
    }

    return Sort-Hashtable -Hashtable $groups -TryTreatKeyAsPossibleVersion $true
}

function NestedGroup-CustomObjectArray {
    param (
        [Parameter(Mandatory=$true)]
        [Array]$InputArray,

        [Parameter(Mandatory=$true)]
        [Array]$GroupBy
    )

    # Initiate empty hashtable for grouping
    $groups = @{}

    foreach ($object in $InputArray) {
        $nestedGroup = $groups # Start at top level

        for ($i = 0; $i -lt $GroupBy.Count; $i++) {
            $property = $GroupBy[$i]
            $value = $object.$property

            # If it's the last property, add object to group
            if ($i -eq $GroupBy.Count - 1) {
                if (-not $nestedGroup.ContainsKey($value)) { 
                    $nestedGroup[$value] = @()
                }
                $nestedGroup[$value] += $object
            } else {
                # Otherwise, go deeper or create new group
                if (-not $nestedGroup.ContainsKey($value)) { 
                    $nestedGroup[$value] = @{} 
                }
                $nestedGroup = $nestedGroup[$value]
            }
        }
    }

    return $groups
}

function NestedSort-Hashtable {
    param (
        [Parameter(Mandatory=$true)]
        [Hashtable]$Hashtable,

        [Parameter(Mandatory=$false)]
        [bool]$TryTreatKeyAsPossibleVersion = $false
    )

    $sorted = [ordered]@{}

    # Sort hashtable by key
    $keys = $Hashtable.Keys
    if ($TryTreatKeyAsPossibleVersion) {
        $allKeysCanBeConvertedToVersion = $keys -cnotcontains $null -and ($keys | ForEach-Object {
            try {
                [version]$_ | Out-Null
                $true
            } catch {
                $false
            }
        }) -notcontains $false

        if ($allKeysCanBeConvertedToVersion) {
            $keys = $keys | Sort-Object -Property {[version]$_}
        } else {
            $keys = $keys | Sort-Object
        }
    } else {
        $keys = $keys | Sort-Object
    }

    foreach ($key in $keys) {
        $value = $Hashtable[$key]

        # If value is another hashtable, sort it too
        if ($value -is [Hashtable]) {
            $value = Sort-Hashtable -Hashtable $value -TryTreatKeyAsPossibleVersion $TryTreatKeyAsPossibleVersion
        }
        # If value is an array of hashtables, sort each hashtable
        elseif ($value -is [Array] -and $value[0] -is [Hashtable]) {
            $sortedArray = @()
            foreach ($item in $value) {
                $sortedArray += , (Sort-Hashtable -Hashtable $item -TryTreatKeyAsPossibleVersion $TryTreatKeyAsPossibleVersion)
            }
            $value = $sortedArray
        }

        $sorted[$key] = $value
    }

    return $sorted
}

function Flatten-Groups {
    param (
        [Parameter(Mandatory=$true)]
        $GroupedHashtable
    )

    $result = @()

    foreach ($key in $GroupedHashtable.Keys) {
        $value = $GroupedHashtable[$key]

        if ($value -is [Array]) {
            # If value is an array of objects, add objects to result
            $result += $value
        } elseif ($value -is [Hashtable] -or $value -is [System.Collections.Specialized.OrderedDictionary]) {
            # If value is a hashtable or an ordered dictionary, recursively flatten groups
            $result += Flatten-Groups -GroupedHashtable $value
        }
    }

    return $result
}



function Initialize-DevToolPython {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [ModuleScope]$Scope = [ModuleScope]::CurrentUser
    )
    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    $moduleName , $moduleVersion = Get-CurrentModule 
    $updatesDone = $false

    $contentText = "Python (PythonEmbeded)"

    Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Check"
    if (-not(Get-Command "pythonw" -ErrorAction SilentlyContinue)) {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Download"
        $targetdir = "$($global:CoreeDevToolsRoot)\PythonEmbeded"
        $found = Find-Links -url "https://www.python.org/downloads/windows/"
        $AssetNameFilters = @("embed","amd64",".zip")
        $matchedUrl = Filter-ItemsWithLists -InputItems $found -WhiteListMatch $AssetNameFilters
        $regexPattern = "-((\d+\.\d+\.\d+)([a-z]+\d+)*)-"
        $result = Extract-MatchGroups -InputStrings $matchedUrl -RegexPattern $regexPattern
        $Nested = NestedGroup-CustomObjectArray -InputArray $result -GroupBy @("Match2","Match3")
        $NestedSort = NestedSort-Hashtable -Hashtable $Nested -TryTreatKeyAsPossibleVersion $true
        $flattened = Flatten-Groups -GroupedHashtable $NestedSort
        $latstreleaseversion = $flattened | Where-Object {$_.Match3 -eq ""} | Select-Object -Last 1

        $file = Get-RedirectDownload2 -Url "$($latstreleaseversion.OriginalItem)"

        Expand-Archive -Path $file -DestinationPath "$targetdir" -Force
        AddPathEnviromentVariable -Path "$targetdir" -Scope CurrentUser

        $filePath= "$($env:localappdata)\Microsoft\WindowsApps\$((Get-Command "python" -ErrorAction SilentlyContinue).Name)"
        if (Test-Path -Path $filePath -PathType Leaf) {
            Remove-Item -Path $filePath -Force
        }

        $filePath= "$($env:localappdata)\Microsoft\WindowsApps\$((Get-Command "python3" -ErrorAction SilentlyContinue).Name)"
        if (Test-Path -Path $filePath -PathType Leaf) {
            Remove-Item -Path $filePath -Force
        }

        if (Test-Path -Path "$targetdir\python.exe" -PathType Leaf) {
            #&runas /user:guest cmd /c mklink "$targetdir\python3.exe" "$targetdir\python.exe"
        }

        # need to reomve C:\Users\Valgrind\AppData\Local\Microsoft\WindowsApps
    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText "$contentText" -SuffixText "Completed"

    return $updatesDone
}

function Test.CoreePower.Lib.DevToolPython {
    param()
    Write-Host "Start Test.CoreePower.Lib.DevToolPython"

    #Initialize-DevToolPython

    Write-Host "Test.CoreePower.Lib.DevToolPython"
}

if ($Host.Name -match "Visual Studio Code")
{
    #Test.CoreePower.Lib.DevToolPython
}
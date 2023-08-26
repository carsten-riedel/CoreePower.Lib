if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) { 
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

<#
.SYNOPSIS
    Splits an input array into smaller partitions.

.DESCRIPTION
    The Split-Array function splits an input array into partitions of a specified maximum size.

.PARAMETER SourceArray
    The input array to be split into partitions.

.PARAMETER MaxPartitionSize
    The maximum size of each partition. Default value is 50.

.EXAMPLE
    # Generate an array of 10 random values
    $randomValues = 1..10 | ForEach-Object { Get-Random -Minimum 1 -Maximum 100 }

    # Split the random values array into partitions of maximum size 3
    $partitionedArray = Split-Array -SourceArray $randomValues -MaxPartitionSize 3

    # Loop through the partitions and display their content
    $partition = @()
    foreach ($partition in $partitionedArray.Partitions) {
        foreach ($item in $partition) {
            Write-Host "`t$item" -NoNewline
        }
        Write-Host
    }
#>
function Split-Array {
    param(
    [array] $SourceArray,
    [int] $MaxPartitionSize = 50
    )

    $arrayPartitions = New-Object 'System.Collections.Generic.List[System.Collections.Generic.List[object]]'

    if ($SourceArray.Count -le $MaxPartitionSize) {
        $singlePartition = New-Object 'System.Collections.Generic.List[object]'
        $singlePartition.AddRange($SourceArray)
        $arrayPartitions.Add($singlePartition)
    }
    else {
        $totalPartitions = [math]::Ceiling($SourceArray.Count / $MaxPartitionSize)
    
        for ($index = 0; $index -lt $totalPartitions; $index++) {
            $startIndex = $index * $MaxPartitionSize
            $endIndex = [math]::Min($startIndex + $MaxPartitionSize, $SourceArray.Count) - 1
            $subPartition = New-Object 'System.Collections.Generic.List[object]'
            $subPartition.AddRange($SourceArray[$startIndex..$endIndex])
            $arrayPartitions.Add($subPartition)
        }
    }
    
    $result = New-Object PSObject -Property @{
        Partitions = $arrayPartitions
    }
    
    return $result
}    


<#
.SYNOPSIS
    Finds items that contain all specified search strings.

.DESCRIPTION
    The `Find-ItemsContainingAllStrings` function searches through a collection of input items and identifies items that contain all the specified search strings. It is useful for filtering and identifying items that meet specific criteria based on multiple search conditions.

.PARAMETER InputItems
    Specifies the collection of input items to search through. This parameter is mandatory and should not be null or empty.

.PARAMETER SearchStrings
    Specifies the search strings to match against the input items. This parameter is mandatory and should not be empty.

.OUTPUTS
    The function returns a collection of items that contain all the specified search strings.

.EXAMPLE
    PS C:\> $fileUrls = Download-GithubLatestReleaseMatchingAssets -RepositoryUrl "https://github.com/cli/cli/releases" -AssetNameFilters @("windows","amd64",".zip")
    PS C:\> $matchingFiles = Find-ItemsContainingAllStrings -InputItems $fileUrls -SearchStrings "windows", "amd64", ".zip"

    This example demonstrates the use of the `Find-ItemsContainingAllStrings` function in conjunction with the `Download-GithubLatestReleaseMatchingAssets` function. It retrieves a collection of download URLs using the latter function and then identifies the URLs that contain all three specified search strings: "windows", "amd64", and ".zip". The matching URLs are stored in the `$matchingFiles` variable.

.NOTES
    - The function performs a case-sensitive search.
    - The function checks for the presence of all the specified search strings in an item. It does not perform a partial or substring match.
    - The order of the search strings does not matter.
#>
function Find-ItemsContainingAllStrings {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$InputItems,
        [Parameter(Mandatory)]
        [string[]]$SearchStrings
    )

    $matchedItems = @()
    $matchedItems = $InputItems | Where-Object {
        $foundStringCount = 0
        foreach ($searchString in $SearchStrings) {
            if ($_.Contains($searchString)) {
                $foundStringCount++
            }
        }
        $foundStringCount -eq $SearchStrings.Count
    }

    return $matchedItems
}

function Filter-ItemsWithLists {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$InputItems,
        [string[]]$WhiteListMatch = $null,
        [string[]]$BlackListMatch = $null,
        [bool]$RequireAllWhiteListMatches = $true
    )

    $OutputItems = @()

    foreach ($item in $InputItems) {
        $whitelistMatches = 0
        $blacklistMatches = 0

        if ($null -ne $WhiteListMatch) {
            foreach ($whiteItem in $WhiteListMatch) {
                if ($item -match $whiteItem) {
                    $whitelistMatches++
                }
            }

            if ($RequireAllWhiteListMatches -and $whitelistMatches -ne $WhiteListMatch.Count) {
                continue
            }
        }

        foreach ($blackItem in $BlackListMatch) {
            if ($item -match $blackItem) {
                $blacklistMatches++
                break
            }
        }

        if (($whitelistMatches -gt 0 -or $null -eq $WhiteListMatch) -and $blacklistMatches -eq 0) {
            $OutputItems += $item
        }
    }

    return $OutputItems
}

function Extract-MatchGroups {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$InputStrings,
        [Parameter(Mandatory=$true)]
        [string]$RegexPattern
    )

    $regex = [regex]$RegexPattern
    $matchesArray = @()

    foreach ($item in $InputStrings) {
        $matches = $regex.Match($item)
        if ($matches.Success) {
            $groups = $matches.Groups
            $matchGroups = @{
                "OriginalItem" = $item
            }

            for ($i = 1; $i -lt $groups.Count; $i++) {
                $matchGroups["Match$i"] = $groups[$i].Value
            }

            $matchesArray += $matchGroups
        }
    }

    return $matchesArray
}

function Sort-MatchGroupsx {
    param(
        [Parameter(Mandatory=$true)]
        [Array]$MatchGroupsArray,

        [Parameter(Mandatory=$true)]
        [Array]$SortingParameter,

        [Parameter(Mandatory=$false)]
        [Array]$TryVersionConvertForSorting = @()
    )

    # Apply Sort-Object for each parameter in reverse order
    $sortedArray = $MatchGroupsArray
    for ($i = $SortingParameter.Count - 1; $i -ge 0; $i--) {
        $param = $SortingParameter[$i]

        # If the parameter is in the TryVersionConvertForSorting list
        if ($TryVersionConvertForSorting -contains $param) {
            # Try to convert to version and sort. If it's not a version, use the default sorting
            $sortedArray = $sortedArray | Sort-Object -Property {
                if ($_.($param) -as [Version]) {
                    return [Version]$_.($param)
                } else {
                    return $_.($param)
                }
            }
        }
        else {
            # Default sorting
            $sortedArray = $sortedArray | Sort-Object -Property $param
        }
    }

    return $sortedArray
}













<#
.SYNOPSIS
    Finds the index of a byte array within another byte array.

.DESCRIPTION
    The `IndexOfBytes` function searches for the first occurrence of a byte array (`$search`) within another byte array (`$array`). It returns the index of the found match, or -1 if no match is found.

.PARAMETER array
    Specifies the byte array to search within. This parameter should be provided as an array of bytes.

.PARAMETER search
    Specifies the byte array to search for. This parameter should be provided as an array of bytes.

.PARAMETER startIndex
    Specifies the starting index from which the search should begin within the `$array`. The default value is 0.

.OUTPUTS
    The function returns the index of the first occurrence of the `$search` byte array within the `$array`. If no match is found, it returns -1.

.EXAMPLE
    PS C:\> $array = [byte[]] (1, 2, 3, 4, 5, 6, 7, 8)
    PS C:\> $search = [byte[]] (3, 4)
    PS C:\> $index = IndexOfBytes -array $array -search $search

    This example demonstrates the use of the `IndexOfBytes` function to find the index of the byte array `(3, 4)` within the byte array `(1, 2, 3, 4, 5, 6, 7, 8)`. The result is stored in the `$index` variable.

.NOTES
    - The function performs a sequential search and stops when it finds the first match.
    - Both the `$array` and `$search` parameters should be provided as byte arrays.
    - If the `$search` byte array is not found within the `$array`, the function returns -1.
    - The function does not support searching for a partial match within the byte arrays.

#>
function IndexOfBytes {
    param (
        [byte[]] $array,
        [byte[]] $search,
        [int] $startIndex = 0
    )

    $i = $startIndex
    while ($i -le $array.Length - $search.Length) {
        $j = 0
        while ($j -lt $search.Length -and $array[$i + $j] -eq $search[$j]) {
            $j++
        }
        if ($j -eq $search.Length) {
            return $i
        }
        $i++
    }
    return -1
}
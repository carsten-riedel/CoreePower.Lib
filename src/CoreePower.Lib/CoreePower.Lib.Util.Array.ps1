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

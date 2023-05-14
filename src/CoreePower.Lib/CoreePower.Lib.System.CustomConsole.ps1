<#
.SYNOPSIS
    Displays a prompt with choices and allows the user to make a selection.

.DESCRIPTION
    The Invoke-Prompt function displays a prompt with choices and waits for the user to make a selection. It is useful for obtaining user confirmation or choices before executing a command or script.

.PARAMETER PromptTitle
    Specifies the title of the prompt window. The default value is "Confirmation Required".

.PARAMETER PromptMessage
    Specifies the message displayed in the prompt window. The default value is "A confirmation is required to run this command.".

.PARAMETER PromptChoices
    Specifies the choices available to the user as an array of string arrays. Each string array should contain a label and a description for the choice. The default value is @('&Yes', 'I want to run this command.'), @('&No', 'I do not want to run this command.').

.PARAMETER DefaultChoiceIndex
    Specifies the index of the default choice. The default value is 0 (corresponding to the first choice).

.PARAMETER DisplayChoicesBeforePrompt
    Indicates whether to display the choices before the prompt message. If set to $true, the choices will be displayed with their corresponding keys. The default value is $true.

.NOTES
    - The user's selection is returned as an integer representing the index of the selected choice.
    - The function uses the host's UI to display the prompt and collect the user's input.
    - If an error occurs during the prompting process, an error message will be displayed, and the function will return -1.

.EXAMPLE
    PS> Invoke-Prompt -PromptTitle "Confirm Action" -PromptMessage "Do you want to proceed?" -PromptChoices @('&Yes', 'Proceed with the action.'), @('&No', 'Cancel the action.') -DefaultChoiceIndex 1 -DisplayChoicesBeforePrompt $false

    This example displays a prompt window with the title "Confirm Action" and the message "Do you want to proceed?". It provides two choices: "Yes" and "No". The default choice is "No" (index 1) and the choices are not displayed before the prompt message. The user's selection is returned as an integer representing the index of the selected choice.

#>
function Invoke-Prompt {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [Alias("iprompt")] 
    param(
        [string]$PromptTitle = "Confirm Action",
        [string]$PromptMessage = "Do you want to proceed?",
        [string[][]]$PromptChoices = @(@('&Yes', 'Proceed with the action.'), @('&No', 'Cancel the action.')),
        [int]$DefaultChoiceIndex = 0,
        [bool]$DisplayChoicesBeforePrompt = $true
    )

    $choicesDesc = foreach($choice in $PromptChoices)
    {
        [System.Management.Automation.Host.ChoiceDescription]::new($choice[0], $choice[1])
    }

    if ($DisplayChoicesBeforePrompt)
    {
        foreach($choice in $PromptChoices)
        {
            $index = $choice[0].IndexOf('&')
            $nextCharacter = $choice[0].Substring($index + 1, 1).ToUpper()
            $PromptMessage += "`r`n$nextCharacter - $($choice[1])"
        }
    }

    try {
        $result = $Host.UI.PromptForChoice($PromptTitle, $PromptMessage, $choicesDesc, $DefaultChoiceIndex)
        return $result
    }
    catch {
        Write-Error "Error occurred while prompting for choice: $_"
        return -1
    }
}


<#
.SYNOPSIS
    Confirms if administrator rights are enabled before running a command.

.DESCRIPTION
    The Confirm-AdminRightsEnabled function prompts the user to confirm if administrator rights are enabled before running a command. It is useful for ensuring that the command requires the necessary privileges.

.NOTES
    - The function uses the Invoke-Prompt function internally to display the confirmation prompt.
    - The user's selection is returned as an integer representing the index of the selected choice.
    - The default choice is set to "No" (index 1) with choices displayed before the prompt message.

.EXAMPLE
    PS> Confirm-AdminRightsEnabled

    This example prompts the user to confirm if administrator rights are enabled before continuing. It provides two choices: "Yes" and "No" with their corresponding descriptions. The default choice is "No" (index 1). The user's selection is returned as an integer representing the index of the selected choice.

#>
function Confirm-AdminRightsEnabled {
    param()

    return Invoke-Prompt -PromptTitle "Admin Rights Required" -PromptMessage "This command requires administrator rights to run. Activate admin rights before continuing." -PromptChoices @(@("&Yes", "Enable admin rights."), @("&No", "Do not run this command.")) -DefaultChoiceIndex 1 -DisplayChoicesBeforePrompt $true
}

<#
.SYNOPSIS
   Writes an output text to the console with a prefix, content, and suffix.

.DESCRIPTION
   The Write-OutputText function generates a formatted output to the console. It accepts a prefix, content, and suffix as input parameters, and writes them to the console. It also ensures that the raster size used for partitioning the console width is even.

.PARAMETER PrefixText
   Specifies the prefix of the output text. The default is "Custom Message at".

.PARAMETER ContentText
   Specifies the main content of the output text. The default is "Invoking some command".

.PARAMETER SuffixText
   Specifies the suffix of the output text. The default is "Ended".

.PARAMETER includeDateInPrefix
   Specifies whether to include the current date in the prefix. The default is $true.

.EXAMPLE
   Write-OutputText -PrefixText "Start" -ContentText "Processing" -SuffixText "End" -includeDateInPrefix $false

   This example generates an output to the console with "Start" as the prefix, "Processing" as the content, and "End" as the suffix, with the date not included in the prefix.
#>
function Write-OutputText {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [string]$PrefixText = "Custom Message at",
        [string]$ContentText = "Invoking some command",
        [string]$SuffixText = "Ended",
        [bool]$includeDateInPrefix = $true
    )

    $rasterSize = 32

    if($rasterSize % 2 -eq 1) {
        $rasterSize += 1
    }

    $rasterRemainder = $Host.UI.RawUI.BufferSize.Width % $rasterSize
    $rasterPartitions = ($Host.UI.RawUI.BufferSize.Width - $rasterRemainder) / $rasterSize

    if ($includeDateInPrefix) {
        $contentWidth= ($rasterPartitions * 12) + $rasterRemainder
        $prefixWidth = $rasterPartitions * 12
        $suffixWidth = $rasterPartitions * 8
    }
    else {
        $contentWidth= ($rasterPartitions * 16) + $rasterRemainder
        $prefixWidth = $rasterPartitions * 8
        $suffixWidth = $rasterPartitions * 8
    }


    $currentDate = [datetime]::Now.ToString()

    if ($includeDateInPrefix)
    {
        $PrefixText = "$PrefixText $currentDate`: ".PadRight($prefixWidth, ' ').Substring(0, $prefixWidth)
    }
    else {
        $PrefixText = "$PrefixText`: ".PadRight($prefixWidth, ' ').Substring(0, $prefixWidth)
    }
    
    $ContentText = "$ContentText".PadRight($contentWidth, ' ').Substring(0, $contentWidth)
    $SuffixText = "$SuffixText".PadRight($suffixWidth, ' ').Substring(0, $suffixWidth)

    Write-Host -NoNewline "$PrefixText"
    Write-Host -NoNewline "$ContentText"
    Write-Host "$SuffixText"
}

$global:WriteOutputTextPrefix = [int]0
$global:WriteOutputTextSuffix = [int]0
$global:WriteOutputTextScreenWidth = [int]0

function Write-OutputText2 {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [string]$PrefixText = "Custom Message at",
        [string]$ContentText = "Invoking some command",
        [string]$SuffixText = "Ended",
        [bool]$includeDateInPrefix = $true,
        [int]$PrefixTextLenMin = 20,
        [int]$SuffixTextLenMin = 20
    )

    if ($includeDateInPrefix)
    {
        $currentDate = [datetime]::Now.ToString()
        $PrefixText = "$PrefixText $currentDate`: "
    }
    else {
        $PrefixText = "$PrefixText`: "
    }




    $ScreenWidth = $Host.UI.RawUI.BufferSize.Width
    if ($global:WriteOutputTextScreenWidth -ne $ScreenWidth)
    {
        $global:WriteOutputTextScreenWidth = $ScreenWidth
        $global:WriteOutputTextPrefix = 0
        $global:WriteOutputTextSuffix = 0
    }

    if ($global:WriteOutputTextPrefix -lt $PrefixTextLenMin)
    {
        $global:WriteOutputTextPrefix = $PrefixTextLenMin
    }

    if ($global:WriteOutputTextSuffix -lt $SuffixTextLenMin )
    {
        $global:WriteOutputTextSuffix = $SuffixTextLenMin 
    }

    $rasterSize = 16

    if($rasterSize % 2 -eq 1) {
        $rasterSize += 1
    }

    $rasterRemainder = $ScreenWidth % $rasterSize
    $rasterPartitionsWidth = ($ScreenWidth - $rasterRemainder) / $rasterSize

    $rasterPrefixFactor = 0
    for ($i = 0; $i -lt $PrefixText.Length; $i=$i+$rasterPartitionsWidth) {
        $rasterPrefixFactor++
    }

    $prefixWidth = $rasterPartitionsWidth * $rasterPrefixFactor

    $rasterPrefixFactor = 0
    for ($i = 0; $i -lt $SuffixText.Length; $i=$i+$rasterPartitionsWidth) {
        $rasterPrefixFactor++
    }

    $suffixWidth = $rasterPartitionsWidth * $rasterPrefixFactor

    if ($global:WriteOutputTextPrefix -lt $prefixWidth)
    {
        $global:WriteOutputTextPrefix = $prefixWidth
    }
    
    if ($global:WriteOutputTextSuffix -lt $suffixWidth)
    {
        $global:WriteOutputTextSuffix = $suffixWidth
    }

    $contentWidth = $global:WriteOutputTextScreenWidth - $global:WriteOutputTextPrefix - $global:WriteOutputTextSuffix

    $PrefixText = "$PrefixText".PadRight($global:WriteOutputTextPrefix, ' ').Substring(0, $global:WriteOutputTextPrefix)
    $ContentText = "$ContentText".PadRight($contentWidth, ' ').Substring(0, $contentWidth)
    $SuffixText = "$SuffixText".PadRight($global:WriteOutputTextSuffix , ' ').Substring(0, $global:WriteOutputTextSuffix )

    Write-Host -NoNewline "$PrefixText"
    Write-Host -NoNewline "$ContentText"
    Write-Host "$SuffixText"
}


function Test.CoreePower.Lib.System.CustomConsole {
    param()
    Write-Host "Start CoreePower.Lib.System.CustomConsole "
    #Write-OutputText2 -PrefixText "Start" -ContentText "Processingx" -SuffixText "End" -includeDateInPrefix $true
    #Write-OutputText2 -PrefixText "Startaaaaa" -ContentText "Processing" -SuffixText "Ending"
    #Write-OutputText2 -PrefixText "Start" -ContentText "Processing" -SuffixText "Ending aaaaaaaaaaaa" 
    #Write-OutputText2 -PrefixText "Startaaaaacc" -ContentText "Processing" -SuffixText "Ending" 
    #Write-OutputText2 -PrefixText "Startaaa" -ContentText "Processing were" -SuffixText "Ending" 
    Write-Host "End CoreePower.Lib.System.CustomConsole "
}

if ($Host.Name -match "Visual Studio Code")
{
    Test.CoreePower.Lib.System.CustomConsole
}




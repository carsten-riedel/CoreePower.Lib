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


$global:WriteFormatedTextPrefix = [int]0
$global:WriteFormatedTextSuffix = [int]0
$global:WriteFormatedTextScreen = [int]0

<#
.SYNOPSIS
    Writes formatted text to the console.

.DESCRIPTION
    The Write-FormatedText function writes text to the console with a customizable prefix and suffix. 
    The prefix and suffix text can be adjusted to have a minimum length. 
    The prefix can optionally include the current date and time. 
    The text is formatted to fit the current console width.

.PARAMETER PrefixText
    The text to display as a prefix. Default is "Custom Message at".

.PARAMETER ContentText
    The main content of the text to display. Default is "Invoking some command".

.PARAMETER SuffixText
    The text to display as a suffix. Default is "Ended".

.PARAMETER includeDateInPrefix
    Whether to include the current date and time in the prefix. Default is $true.

.PARAMETER PrefixTextLenMin
    The minimum length for the prefix text. Default is 15.

.PARAMETER SuffixTextLenMin
    The minimum length for the suffix text. Default is 25.

.EXAMPLE
    Write-FormatedText -PrefixText "Starting" -ContentText "Running script" -SuffixText "Completed"

    This will output something like:

    2023-05-14 12:34:56 Starting:         Running script                Completed

.NOTES
    The function adjusts the lengths of the prefix, content, and suffix text to fit the current console width.
    It also maintains the last used lengths in global variables.
#>
function Write-FormatedText {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSUseApprovedVerbs","")]
    param (
        [string]$PrefixText = "Starting",
        [string]$ContentText = "Running script",
        [string]$SuffixText = "Completed",
        [bool]$includeDateInPrefix = $true,
        [int]$PrefixTextLenMin = 15,
        [int]$SuffixTextLenMin = 25
    )

    if ($includeDateInPrefix)
    {
        $date = Get-Date
        $dateonly = $date.ToString("yyyy-MM-dd")
        $timeonly = $date.ToString("HH:mm:ss")
        $currentDate = "$dateonly $timeonly"
        $PrefixText = "$currentDate $PrefixText`: "
    }
    else {
        $PrefixText = "$PrefixText`: "
    }

    $SuffixText = " $SuffixText"

    $ScreenWidth = $Host.UI.RawUI.BufferSize.Width
    if ($global:WriteFormatedTextScreen -ne $ScreenWidth)
    {
        $global:WriteFormatedTextScreen = $ScreenWidth
        $global:WriteFormatedTextPrefix = 0
        $global:WriteFormatedTextSuffix = 0
    }

    if ($global:WriteFormatedTextPrefix -lt $PrefixTextLenMin)
    {
        $global:WriteFormatedTextPrefix = $PrefixTextLenMin
    }

    if ($global:WriteFormatedTextSuffix -lt $SuffixTextLenMin )
    {
        $global:WriteFormatedTextSuffix = $SuffixTextLenMin 
    }

    $rasterSize = 32

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

    if ($global:WriteFormatedTextPrefix -lt $prefixWidth)
    {
        $global:WriteFormatedTextPrefix = $prefixWidth
    }
    
    if ($global:WriteFormatedTextSuffix -lt $suffixWidth)
    {
        $global:WriteFormatedTextSuffix = $suffixWidth
    }

    $contentWidth = $global:WriteFormatedTextScreen - $global:WriteFormatedTextPrefix - $global:WriteFormatedTextSuffix

    $PrefixText = "$PrefixText".PadRight($global:WriteFormatedTextPrefix, ' ').Substring(0, $global:WriteFormatedTextPrefix)
    $ContentText = "$ContentText".PadRight($contentWidth, ' ').Substring(0, $contentWidth)
    $SuffixText = "$SuffixText".PadRight($global:WriteFormatedTextSuffix , ' ').Substring(0, $global:WriteFormatedTextSuffix )

    Write-Host -NoNewline "$PrefixText"
    Write-Host -NoNewline "$ContentText"
    Write-Host "$SuffixText"
}

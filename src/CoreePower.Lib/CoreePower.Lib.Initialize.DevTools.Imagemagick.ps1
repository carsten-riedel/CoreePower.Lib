if (-not($PSScriptRoot -eq $null -or $PSScriptRoot -eq "")) {
    . $PSScriptRoot\CoreePower.Lib.Includes.ps1
}

function Initialize-DevToolsImagemagick {
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

    $contentText = "magick (Imagemagick)"

    Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Check"
    if (-not(Get-Command "magick" -ErrorAction SilentlyContinue)) {

        Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Download"
        $uris = Find-Links -url "https://imagemagick.org/script/download.php"
        $stringUris = $uris | ForEach-Object { $_.AbsoluteUri }
        $foundUrls = @()
        $foundUrls = Filter-ItemsWithLists -InputItems $stringUris -WhiteListMatch @("ImageMagick","portable","Q16","HDRI","x64",".zip")
        $file = Get-RedirectDownload2 -Url $foundUrls
        Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Download Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Extracting"
        $ExtractDirectory = New-TempDirectory
        $originalProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        Expand-Archive -Path $file -DestinationPath $ExtractDirectory
        $global:ProgressPreference = $originalProgressPreference
        Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Extracting Completed"
        Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Removing Download"
        Remove-TempDirectory -TempDirectory $file
        Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Copying"
        $TargetDirectory = "$($global:CoreeDevToolsRoot)\ImageMagick"
        Copy-Recursive -Source $ExtractDirectory -Destination $TargetDirectory
        Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Copying Completed"

        Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Removing Extraction"
        Remove-TempDirectory -TempDirectory $ExtractDirectory

        if (Get-Command "dark" -ErrorAction SilentlyContinue) {
            Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Runtime"
            Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Download"
            $file = Get-RedirectDownload2 -Url "https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x64.exe"
            Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Download Completed"
            $ExtractDirectory = New-TempDirectory
            Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Extracting"
            &dark -x "$ExtractDirectory" "$file" | Out-Null
            &expand -F:* "$ExtractDirectory\AttachedContainer\packages\vcRuntimeMinimum_amd64\cab1.cab" "$TargetDirectory" | Out-Null
            Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Extracting Completed"
            Remove-TempDirectory -TempDirectory $file
            Remove-TempDirectory -TempDirectory $ExtractDirectory
            Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Runtime Completed"
         } else {
            Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "dark not available"
         }

         Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Adding envar"
        AddPathEnviromentVariable -Path "$TargetDirectory" -Scope CurrentUser
        Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Adding envar Completed"
    } else {
        Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Already available"
    }
    Write-FormatedText -PrefixText "$moduleName" -ContentText $contentText -SuffixText "Completed"
 
    return $updatesDone
}

if ($Host.Name -match "Visual Studio Code")
{
    #Initialize-DevToolsImagemagick
    #Initialize-DevToolsImagemagick
    #https://www.svgrepo.com/
    #magick convert -density 300 -define icon:auto-resize=256,128,96,64,48,32,16 -background none sunflower-svgrepo-com.svg out.ico
    #magick convert -background none -size 128x128 infile.svg outfile.png
    #magick convert -background none -size 1280x640 "C:\base\github.com\carsten-riedel\CoreePower.Lib\src\logo.svg" "C:\base\github.com\carsten-riedel\CoreePower.Lib\src\logox.png"
}


<#
.SYNOPSIS
    Adds a custom enumeration type if the 'ModuleRecordState' type does not exist.

.DESCRIPTION
    The code block checks if the 'ModuleRecordState' type exists. If it does not exist, it adds a custom enumeration type named 'ModuleRecordState' with three values: 'Latest', 'Previous', and 'All'. This enumeration type is used in certain functions and scripts to specify the module version range of PowerShell modules.

.NOTES
    - This code block is used in PowerShell if there is no 'ModuleRecordState' type defined.
    - The 'ModuleRecordState' enumeration is used to indicate the desired range of module versions to be returned when searching for multiple versions of a module.
    - If the 'ModuleRecordState' type already exists, this code block has no effect.
#>

if (-not ([System.Management.Automation.PSTypeName]'ModuleRecordState').Type) {
    Add-Type @"
    public enum ModuleRecordState {
        Latest,
        Previous,
        All
    }
"@
}

<#
.SYNOPSIS
    Adds a custom enumeration type if the 'ModuleScope' type does not exist.

.DESCRIPTION
    The code block checks if the 'ModuleScope' type exists. If it does not exist, it adds a custom enumeration type named 'ModuleScope' with two values: 'CurrentUser' and 'LocalMachine'. This enumeration type is used in certain functions and scripts to specify the scope of PowerShell modules.

.NOTES
    - This code block is used in PowerShell if there is no 'ModuleScope' type defined.
    - The 'ModuleScope' enumeration is used to indicate whether a PowerShell module should be retrieved from the current user's scope or the local machine's scope.
    - If the 'ModuleScope' type already exists, this code block has no effect.
#>
if (-not ([System.Management.Automation.PSTypeName]'ModuleScope').Type) {
    Add-Type @"
    public enum ModuleScope {
        CurrentUser,
        LocalMachine,
        Process
    }
"@
}

function Test.CoreePower.Lib.System.Enum {
    param()
    Write-Host "Start Test.CoreePower.Lib.System.Enum"
    #$result1 = [ModuleRecordState]::Latest
    #$result2 = [ModuleScope]::LocalMachine
    Write-Host "End Test.CoreePower.Lib.System.Enum"
}

if ($Host.Name -match "Visual Studio Code")
{
    #Test.CoreePower.Lib.System.Enum
}


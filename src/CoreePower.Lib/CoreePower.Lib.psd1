#
# Module manifest for module 'CoreePower.Lib'
#
# Generated by: Carsten Riedel
#
# Generated on: 9/7/2023
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'CoreePower.Lib.psm1'

# Version number of this module.
ModuleVersion = '0.0.2.15'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '91253b1f-8db9-48b8-9fd9-e34a30a54915'

# Author of this module
Author = 'Carsten Riedel'

# Company or vendor of this module
CompanyName = 'Carsten Riedel'

# Copyright statement for this module
Copyright = '(c) Carsten Riedel. All rights reserved.'

# Description of the functionality provided by this module
Description = 'The "CoreePower.Lib" module is the a part of the CoreePower project.
It adds command-line programs like 7-Zip, Git, GitHub CLI, NuGet, dotnet, and Visual Studio Code from the original sources.
See full readme at https://github.com/carsten-riedel/CoreePower.Lib/#readme
Note: the "Initialize-CorePowerLatest" command may conflict with existing installations. Use with caution.
'

# Minimum version of the PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'HasLocalAdministratorClaim', 'CouldRunAsAdministrator', 
               'CanExecuteInDesiredScope', 'Initialize-NugetSourceRegistered', 
               'Initialize-NugetPackageProviderInstalled', 
               'Initialize-PowerShellGet', 'Initialize-PackageManagementLatest', 
               'Initialize-Powershell', 'Copy-Recursive', 'New-Tempdir', 
               'Restart-Proc', 'Initialize-CorePowerLatest', 
               'AddPathEnviromentVariable', 'Get-ModulesLocal', 
               'Initialize-DevTools'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = 'cpcp', 'copyrec', 'newtmp', 'cpdev'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'lib', 'windows', 'beta', 'setup', 'NuGetPackageProvider', 'PowerShellGet', 
               'PackageManagement', '7-Zip', 'Git', 'GitHubCLI', 'NuGet', 'dotnet', 
               'VisualStudioCode'

        # A URL to the license for this module.
        LicenseUri = 'https://www.powershellgallery.com/packages/CoreePower.Lib/0.0.2.15/Content/LICENSE.txt'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/carsten-riedel/CoreePower.Lib'

        # A URL to an icon representing this module.
        IconUri = 'https://raw.githubusercontent.com/carsten-riedel/CoreePower.Lib/main/src/logo.png'

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}


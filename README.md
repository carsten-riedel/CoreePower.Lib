# CoreePower.Lib
CoreePower.Lib is a set of functions that can be used to enhance the functionality of your CoreePower project.

```
$Install="CoreePower*" ; Find-Module -Name @("PackageManagement", "PowerShellGet", "$Install") -Repository PSGallery | Select-Object Name,Version | Where-Object { -not (Get-Module -ListAvailable $_.Name) } | ForEach-Object { Install-Module -Name $_.Name -RequiredVersion $_.Version -Scope CurrentUser -Force -AllowClobber ; Import-Module -Name $_.Name -MinimumVersion $_.Version  }
```

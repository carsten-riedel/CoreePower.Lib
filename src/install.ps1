# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https:///install.ps1'))

Install-Module -Name CoreePower.Lib -RequiredVersion 0.0.0.29 -Scope CurrentUser -Force -AllowClobber | Out-Null
Initialize-CorePowerLatest
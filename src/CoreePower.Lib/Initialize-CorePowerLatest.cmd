@echo off
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "& { Initialize-CorePowerLatest } "
for /f "tokens=2*" %%A in ('reg query "HKEY_CURRENT_USER\Environment" /v "Path"') do set "output=%%B"
SET "Path=%output%"
@del "%~f0" & exit
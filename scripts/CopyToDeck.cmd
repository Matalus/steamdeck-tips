:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: *****************.cmd
:: CREATED BY: Matt Hamende
:: Purpose: Invoke a PowerShell script via CMD in the current DIR
:: LAST UPDATED: 2022.08.13
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
title Starting Powershell Script...
color 0e
cls

goto START

::###################################################################################
::####  START  ######################################################################
:START

PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}"

::###################################################################################
::####  EOF  ########################################################################
:EOF

:: Reference:  https://www.howtogeek.com/204088/how-to-use-a-batch-file-to-make-powershell-scripts-easier-to-run/
::
:: PowerShell.exe -Command “& ‘%~dpn0.ps1′” actually runs the PowerShell script. PowerShell.exe can of course be called from any CMD window or batch file to launch PowerShell to a bare console like usual. You can also use it to run commands straight from a batch file, by including the -Command parameter and appropriate arguments. The way this is used to target our .PS1 file is with the special %~dpn0 variable. Run from a batch file, %~dpn0 evaluates to the drive letter, folder path, and file name (without extension) of the batch file. Since the batch file and PowerShell script will be in the same folder and have the same name, %~dpn0.ps1 will translate to the full file path of the PowerShell script.

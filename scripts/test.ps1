#region prereqs
#Requires -Version 5.1
$RunDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# MAKE IT BLACK # set Host UI Color to Black for Readability
$background = "Black"
if($host.UI.RawUI.BackgroundColor -ne $background){ 
    $host.UI.RawUI.BackgroundColor = $background
    Clear-Host
}

Import-Module "$RunDir\functions.psm1" -Force
#endregion prereqs

#region testCode

$ShortcutsRaw = Get-Content 'C:\Program Files (x86)\Steam\userdata\45072756\config\shortcuts.vdf'
#$ShortcutsRaw = Get-Content "$RunDir\..\shortcuts.vdf"


$JoinArray = $ShortcutsRaw.ToCharArray() | Where-Object {
    ![char]::IsControl("$_")
} | Join-String -Separator ""

$RegExMatch = [regex]::Matches($JoinArray,'(AppName)(.*?)(Exe)(\")(.*?)(\"StartDir\")(.*?)(\")') | Select-Object -ExpandProperty Value

$Apps = $RegExMatch | ForEach-Object {
    [pscustomobject]@{
        Name = $_.Split('"')[0].TrimStart("AppName").TrimEnd("Exe");
        Target = $_.Split('"')[1];
        CommonPath = $_.Split('"')[3];
    }
}

$Apps | Format-Table -AutoSize

#endregion testCode

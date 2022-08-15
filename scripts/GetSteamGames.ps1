<# 
    .SYNOPSIS
    Script for Automating Inventory of All Steam Games on available Storage
    
    .DESCRIPTION
    Scans your Local and Remote Volumes for appmanifest files, To identify games and steam libraries to build inventory of available games

    This Script assumes you have SSH setup on your SteamDeck and are using WinFSP / SSHFS-Win to transfer files directly via mapped drives
    https://github.com/Matalus/steamdeck-tips/blob/main/ssh.md#map-network-drives-in-windows-to-your-deck-sshfs-win-winfsp
    OR 
    You're using a tool like Paragon Software's Linux Filesystem for Windows to locally mount a MicroSDXC Card
    https://www.paragon-software.com/us/home/linuxfs-windows/
    
    .NOTES
    Created by Matt Hamende 2022
    Utilize Robocopy for optimal file transfer speeds as well as native error handling
    Utilizes PSJobs for Threading and Performance
    Leverages the unofficial community ProtonDB API protondb.max-p.me
    Idea Inspired by Shane R Monroe's DeckDriveManager https://deckdrivemanager.com/
    Requries at least PowerShell 5.1 for some commands
    Requires Run as Administrator for File Searches
#>
#region prereqs
#Requires -Version 5.1 -RunAsAdministrator
$RunDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# MAKE IT BLACK # set Host UI Color to Black for Readability
$background = "Black"
if($host.UI.RawUI.BackgroundColor -ne $background){ 
    $host.UI.RawUI.BackgroundColor = $background
    Clear-Host
}

Import-Module "$RunDir\functions.psm1" -Force
#endregion prereqs

#region CheckNetworkDrives
# Check for Disconnect Mapped Drives with 'steam' in the path
$Steam_Network = Get-ChildItem HKCU:\Network\ -ErrorAction SilentlyContinue | Get-ItemProperty | Where-Object {$_.RemotePath -like "*steam*"}
if($Steam_Network){
    $Steam_Active = Get-CimInstance Win32_MappedLogicalDisk -ErrorAction SilentlyContinue | Where-Object {$_.ProviderName -like "*steam*"} 
    if(!$Steam_Active){
        Write-Host -ForegroundColor Yellow "Attempting to Reconnect Disconnected Network Drives"
        ForEach($Drive in $Steam_Network){
            Write-Host "Connecting to: $($Drive.PSChildName) : $($Drive.RemotePath)" -NoNewline
            $null = Invoke-Expression "net use '$($Drive.PSChildName):' '$($Drive.RemotePath)' /persistent:yes /savecred"
            $Steam_Active = Get-CimInstance Win32_MappedLogicalDisk -ErrorAction SilentlyContinue | Where-Object {$_.ProviderName -like "*steam*"} 
            if($Steam_Active){
                Write-Host -ForegroundColor Green " Success!"
            }else{
                Write-Warning "`n WARNING: Mapped Drive $($Drive.PSChildName) $($Drive.RemotePath) Failed to Reconnect, Please Confirm that your SteamDeck is powered on and SSH is enabled."
            }
        }
    }
}
#endregion CheckNetworkDrives

#region GetLocalAppManifests
# enumerate local drives
Write-Host -ForegroundColor Green "$(Get-Date -format u) | Getting All Drives..."
$DriveCols = @('DeviceID', 'DriveType', 'MediaType', 'ProviderName', 'VolumeName', 'FileSystem', @{N = "SizeGB"; E = { [math]::Round($_.Size / 1GB, 2) } }, @{N = "FreeGB"; E = { [math]::Round($_.FreeSpace / 1GB, 2) } })
[array]$AllDrives = Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object $DriveCols

# Gets List of appmanifest*.acf files uses functions.psm1
$Data = Find-AppManifest -Root $AllDrives
#endregion GetLocalAppManifests

#region RequestProtonAPI
# Get ProtonDB API Data
$ApiJobParams = @{
    Name         = "ProtonAPI"
    ArgumentList = $Data.AppManifests -split "`n" | ForEach-Object { [regex]::Matches($_, "\d+") | Select-Object -Last 1 -ExpandProperty Value }
    ScriptBlock  = {
        $AppIDs = $args
        $ProtonReports = @()
        ForEach ($AppID in $AppIDs) {
            $InvokeRestParams = @{
                Method      = "GET"
                Uri         = "https://protondb.max-p.me/games/$($AppID)/reports"
                ErrorAction = "SilentlyContinue"
            }
            $ProtonReports += Invoke-RestMethod @InvokeRestParams
        }
        Return $ProtonReports
    }
}
$null = Start-Job @ApiJobParams
#endregion RequestProtonAPI

#region GetLocalFileContents
Write-Host "Found the Following Steam Libraries:"
$Data.SteamLib | ForEach-Object { Write-Host -ForegroundColor Blue "---> $($_)" }

$appManifests = $Data.AppManifests
Write-Host "Found: $($appManifests.Count) App Manifests"

Write-Host -ForegroundColor White "$(Get-Date -format u) | Getting AppManifest File Contents..."

# Create Jobs to get File Contents
ForEach ($AppManif in $appManifests) {
    $ID = [regex]::Matches($AppManif, "\d+") | Select-Object -ExpandProperty Value | Select-Object -Last 1
    $GetAppManifParams = @{
        Name        = "GetAppManif$($ID)"
        ScriptBlock = {
            [pscustomobject]@{
                Content     = Get-Content $using:AppManif -Raw -Encoding UTF8;
                AppManifest = $using:AppManif
                ID          = $using:ID
            }
        }
        ErrorAction = "SilentlyContinue"
    }
    $null = Start-Job @GetAppManifParams
}

# receive App Manifest Data
$AppManifestsFull = Get-Job -Name "GetAppManif*" | Wait-Job -Timeout 60 -Force | Receive-Job -AutoRemoveJob -Wait
#endregion GetLocalFileContents

#region BuildLocalAppLib
# Build App Library
Write-Host -ForegroundColor White "$(Get-Date -format u) | Identifying Manifest Contents..."
$AppLib = @()
$AppCount = 0
$ErrCount = 0
ForEach ($Manifest in $AppManifestsFull) {
    $AppCount++
    $ID = $Manifest.ID.PadRight(50).Substring(0, 10)
    Write-Host -ForegroundColor Cyan "[ $('{0:0000}' -f $AppCount) / $('{0:0000}' -f $appManifests.Count) ] ---> AppID: $ID" -NoNewline
    $App = Convert-AppManifest -Manifest $Manifest
    if ($App.Status -eq "OK") {
        Write-Host -ForegroundColor Green "[|] Game: $($App.Name) | Size: $($App.GB)GB | Path: $($App.CommonPath)"
        $AppLib += $App | Select-Object Name, AppID, Location, LastUpdated, Library, AppManifest, CommonPath, GB, Status, ProtonDB
    }
    else {
        $ErrCount++
        Write-Host -ForegroundColor Yellow "[x] Game: $($App.Name) | Message: $($App.Message)"
    }
}

Write-Host "Found: $($AppLib.Count) STEAM games"
write-Host "Errors: $($ErrCount)"
#endregion BuildLocalAppLib

#region ReceiveAPI
# receive protonDB data
$null = Get-Job -Name "ProtonAPI" | Receive-Job -OutVariable "ProtonDB" -ErrorVariable "ErrorOutput" -ErrorAction Continue
$null = Get-Job -Name "ProtonAPI" | Stop-Job -ErrorAction SilentlyContinue -Confirm:$false | Remove-Job -Force -Confirm:$false
if ($ProtonDB) {
    Write-Host -ForegroundColor Cyan "Appending ProtonDB Ratings..."
    ForEach ($App in $AppLib) {
        $Rating = $null
        $Reports = $ProtonDB | Where-Object { $_.AppID -eq $App.AppID } 
        if ($Reports) {
            $Rating = $Reports | Group-Object -Property rating -NoElement | Sort-Object Count -Descending | Select-Object -ExpandProperty Name -First 1
            $App | Add-Member ProtonDB($Rating) -Force
        }
    }
}
#endregion ReceiveAPI


$AppLib | Out-GridView -Title "Inventory of [ $($AppLib.Count) ] Games on [ $($AllDrives.Count) Devices ] "

$AppLib | Select-Object * | Export-Csv -Path "$RunDir\SteamInventory.csv" -NoTypeInformation -Force -Confirm:$false

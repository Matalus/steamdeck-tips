<# 
    .SYNOPSIS
    Script for Automating Transfer of Steam Desktop Games to SteamDeck
    
    .DESCRIPTION
    Scans your Local and Remote Volumes for appmanifest files, To identify games and steam libraries, Converts the data to inventory the games installed on your Desktop and SteamDeck
    Then Allows you to choose which Games to copy your SteamDeck or Removeable Media directly

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
#Requires -Version 5.1 -RunAsAdministrator
$RunDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

Import-Module "$RunDir\functions.psm1" -Force

# enumerate local drives
Write-Host -ForegroundColor Green "$(Get-Date -format u) | Getting Local Drives..."
$DriveCols = @('DeviceID', 'DriveType', 'ProviderName', 'VolumeName', 'FileSystem', @{N = "SizeGB"; E = { [math]::Round($_.Size / 1GB, 2) } }, @{N = "FreeGB"; E = { [math]::Round($_.FreeSpace / 1GB, 2) } })
[array]$LocalDrives = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 -and $_.FileSystem -eq "ntfs" } | Select-Object $DriveCols

$Data = Find-AppManifest -Root $LocalDrives

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

# Build App Library
Write-Host -ForegroundColor Black -BackgroundColor Yellow "$(Get-Date -format u) | Identifying Manifest Contents..."
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
        $AppLib += $App | Select-Object Name, AppID, Location, Library, AppManifest, CommonPath, GB, Status, ProtonDB
    }
    else {
        $ErrCount++
        Write-Host -ForegroundColor Yellow "[x] Game: $($App.Name) | Message: $($App.Message)"
    }
}

Write-Host "Found: $($AppLib.Count) Intact STEAM games"
write-Host "Errors: $($ErrCount)"

# Get list of Non Local Volumes
$RemoteVols = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DeviceID -notin $LocalDrives.DeviceID } | Select-Object $DriveCols

# Scan all remote vols for steam libraries
$DeckData = Find-AppManifest -Root $RemoteVols

Write-Host -ForegroundColor White "$(Get-Date -format u) | Getting AppManifest File Contents..."

# Create Jobs to get File Contents
ForEach ($AppManif in $DeckData.AppManifests) {
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
$DeckDataFull = Get-Job -Name "GetAppManif*" | Wait-Job -Timeout 60 -Force | Receive-Job -AutoRemoveJob -Wait



$DeckApps = @()
# Loop through and compare to Steam Deck Inventory
ForEach ($app in $DeckDataFull) {
    $App = Convert-AppManifest -Manifest $App -Deck
    if ($App.AppID -in $AppLib.AppID) {
        Write-Host -ForegroundColor Yellow "[O] Game: $($App.Name) | App Already Installed on Deck"      
    }
    $AppLib += $App | Select-Object Name, AppID, Location, Library, AppManifest, CommonPath, GB, Status, ProtonDB
    $DeckApps += $App.AppID
}

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


# automatically runs the 1st set of transfers, user will be prompted to run additional
# responding with anything that doesn't contain "y" will end the script
$Installed = @()
$copymore = "y"
While ($copymore -like "*y*") {
    # get updated remote vol data each time
    $RemoteVols = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DeviceID -notin $LocalDrives.DeviceID } | Select-Object $DriveCols
    # Append SteamLib data
    $RemoteVols | ForEach-Object { $_ | Add-Member SteamLibrary(($DeckData.SteamLib -match $_.DeviceID)[0]) -Force }

    [array]$SelectApps = $AppLib | Where-Object { $_.AppID -notin $DeckApps } | Out-GridView -PassThru -Title "Select Games to Install on SteamDeck"

    $DeckLib = $RemoteVols  | Out-GridView -PassThru -Title "Select Destination Steam Library"

    # Copy Files to Remote Media
    Write-Host -ForegroundColor Green "$(Get-Date -format u) | Transferring Games to Deck..."
    ForEach ($Game in $SelectApps) {
        Write-Host -ForegroundColor Cyan "---> App Manifest: $($Game.Name) ID: $($Game.AppID)..."
        #$manifargs = "'$(Split-Path -Parent $Game.AppManifest)' '$($DeckLib.SteamLibrary)' '$(Split-Path -Leaf $Game.AppManifest)' /NC"
        Copy-Item -Path $Game.AppManifest -Destination $DeckLib.SteamLibrary -Verbose -Force
        Write-Host -ForegroundColor Cyan "---> Common Files: $($Game.Name) ID: $($Game.AppID)..."
        $DestCommon = "$($DeckLib.SteamLibrary)\common\$(Split-Path -Leaf $Game.CommonPath)"
        if (!(Test-Path $DestCommon)) {
            Write-Host -ForegroundColor Yellow "Creating Directory: $($DestCommon)"
            Try{
                $null = New-Item -ItemType Directory -Path $DestCommon -ErrorAction SilentlyContinue
            }Catch{

            }
        }
        #$commonArgs = "'$($Game.CommonPath)' '$DestCommon' /MIR /NC /ETA"
        Copy-WithProgress -Source $Game.CommonPath -Destination $DestCommon
        $Installed += $Game
    }

    Write-Host -ForegroundColor Green "Games Installed During This Session:"
    $Installed | Format-Table -AutoSize

    # play sound to let you know transfers are done
    $soundFile = "C:\Windows\media\tada.wav"
    if (Test-Path $soundFile) {
        $sound = new-Object System.Media.SoundPlayer
        $sound.SoundLocation = $soundFile
        $sound.Play()
    }
    Write-Host -ForegroundColor Green "### All Games Transfers Complete ###"
    $copymore = Read-Host -Prompt "Would you like to transfer more games (y|n)"
}


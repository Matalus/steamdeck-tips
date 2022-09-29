function Find-AppManifest ([array]$Root) {
    # set working directory
    #$RoboLogPath = "$($PSScriptRoot)\robolog.txt"

    #$RobologPath | Remove-Item -Force -Confirm:$false -ErrorAction SilentlyContinue -Verbose
    # started threaded robocopy list instances to fast search for appmanifest files

    # Kill Old Jobs
    $null = Get-Job -Name "SteamLibSearch*" | Stop-Job -Confirm:$false -PassThru | remove-job -Confirm:$false -Force

    $jobs = @()
    ForEach ($Drive in $Root) {
        Write-Host -ForegroundColor Cyan "$(Get-Date -format u) | Scanning$(if($Drive.VolumeName -and $Drive.VolumeName.Trim().Length -ge 1){" Volume: $($Drive.VolumeName)"}) Drive: $($Drive.DeviceID) for Steam Libraries..."
        $JobName = "SteamLibSearch_$($Drive.DeviceID.Replace(":",$null))"
        #     $RoboParams = @{
        #         FilePath               = "C:\Windows\system32\Robocopy.exe"
        #         ArgumentList           = "$($Drive.DeviceID)\ $($PSScriptRoot) appmanifest*.acf /r:2 /w:2 /s /b /l /fp /xj /ndl /njh /njs /nc /ns /xd /lev:3 'lost+found' /log+:$($RoboLogPath)"
        #         NoNewWindow            = $true
        #         RedirectStandardOutput = "null"
        #     }
        #     # start robocopy list
        #     $null = Start-Process @RoboParams
        $JobParams = @{
            ScriptBlock   = {
                #param($path)
                Get-ChildItem -Path "$($using:Drive.DeviceID)\" -Recurse -Filter "appmanifest*.acf" -Depth 4 -Force -ErrorAction SilentlyContinue
            }
            ArgumentList  = $Drive.DeviceID
            Name          = $JobName      
            ErrorVariable = "STEAMLIBSEARCHERR"
        }
        $jobs += Start-Job @JobParams  
        #DEBUG  
    }

    $Timer = [System.Diagnostics.Stopwatch]::StartNew()

    # wait for roboscans to finish
    # While (Get-Process -Name "Robocopy" -ErrorAction SilentlyContinue ) {
    #     Write-Host "$(Get-Date -format u) | Waiting for Scans to Complete..."
    #     Start-Sleep -Seconds 5
    # }
    # wait for search jobs to finish
    $appManifestList += @()
    $SearchComplete = $false
    while ($SearchComplete -eq $false) {
        [array]$JobList = Get-Job -Name "SteamLibSearch*" -ErrorAction SilentlyContinue
        ForEach ($Job in $JobList) {
            if ($Job.State -eq "Completed") {
                $null = $job | Receive-Job -OutVariable "JobOutput" -ErrorVariable "ErrorOutput" -ErrorAction Continue
                $appManifestList += $JobOutput | Select-Object -ExpandProperty FullName
                $job | Remove-Job -Force -Confirm:$false
            }
        }
        # search timeout trigger 60s or no incomplete jobs remaining
        if ($Timer.Elapsed.Seconds -gt 60 -or $JobList.Count -eq 0) {
            $SearchComplete = $true
            # Kill Old Jobs
            $null = Get-Job -Name "SteamLibSearch*" | Stop-Job -Confirm:$false -PassThru | remove-job -Confirm:$false -Force
            $Timer.Stop()
        }

    }

    # get contents of robolog
    #$robolog = Get-Content $RoboLogPath

    # identify unique acf files
    #[array]$appManifests = $robolog | Where-Object { $_ -match "appmanifest" } | ForEach-Object { $_.Trim() }
    [array]$appManifests = $appManifestList | Where-Object { $_ -match "appmanifest" } | ForEach-Object { $_.Trim() }
    
    # Get Steam Libraries
    [array]$STEAM_lib = $appManifests | ForEach-Object { Split-Path -Parent $_ } | Select-Object -Unique

    $obj = [pscustomobject]@{
        AppManifests = $appManifests
        SteamLib     = $STEAM_lib
        AppCount     = $appManifests.Count
    }

    Return $obj
}

Export-ModuleMember Find-AppManifest

function Convert-AppManifest ($Manifest, [switch]$Deck) {
    
    # Test if input object is full AppManifest, otherwise assume String
    if ($Manifest.GetType().Name -eq "PSCustomObject") {
        $Content = $Manifest.Content
        $ManifestPath = $Manifest.AppManifest
    }
    else {
        # Encoding is REALLY important since some games have the [ ™ ] symbol in their paths
        $Content = Get-Content $Manifest -Raw -Encoding UTF8
        $ManifestPath = $Manifest
    }

    # Auto-Detect Location
    #Get All Drives
    $DriveCols = @('DeviceID', 'DriveType', 'MediaType', 'ProviderName', 'VolumeName', 'FileSystem', @{N = "SizeGB"; E = { [math]::Round($_.Size / 1GB, 2) } }, @{N = "FreeGB"; E = { [math]::Round($_.FreeSpace / 1GB, 2) } })
    [array]$AllDrives = Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object $DriveCols

    ForEach ($Drive in $AllDrives) {

        $DriveLocation = switch ($Drive) {
            { $_.FileSystem -eq 'ext4' -and $_.DriveType -eq 3 -and $_.MediaType -eq 12 } { "Local MicroSDXC" }
            { $_.FileSystem -eq 'FUSE-SSHFS' -and $_.DriveType -eq 4 -and $_.MediaType -eq 0 -and $_.ProviderName -match 'SSHFS[.]{0,1}[kK]{0,1}r' } { "SteamDeck MicroSDXC" }
            { $_.FileSystem -eq 'FUSE-SSHFS' -and $_.DriveType -eq 4 -and $_.MediaType -eq 0 -and $_.ProviderName -match 'SSHFS[.]{0,1}[kK]{0,1}\\' } { "SteamDeck SSD" }
            { $_.FileSystem -eq 'NTFS' -and $_.DriveType -eq 3 -and $_.MediaType -eq 12 } { "$($env:COMPUTERNAME)" }
            Default { "Unknown" }
        }
        $Drive | Add-Member Description($DriveLocation) -Force
    }
    

    if ($Deck) {
        $Location = "SteamDeck"
    }
    else {
        $Location = $AllDrives | Where-Object { $_.DeviceID -eq ($ManifestPath -split "\\" | Select-Object -First 1) } | Select-Object -ExpandProperty Description
    }
    Try {
        $App = [pscustomobject]@{
            Name        = [regex]::Matches($Content, '\"name\"\s+\".*"') | Select-Object -ExpandProperty Value | ForEach-Object { $_ -split '"' } | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Last 1
            AppID       = [regex]::Matches($Content, '\"appid\"\s+\"\d+\"') | Select-Object -ExpandProperty Value | ForEach-Object { $_ -split '"' } | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Last 1
            Library     = Split-Path -Parent $ManifestPath
            AppManifest = $ManifestPath
            InstallDir  = [regex]::Matches($Content, '\"installdir\"\s+\".*"') | Select-Object -ExpandProperty Value | ForEach-Object { $_ -split '"' } | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Last 1
            LastUpdated = [regex]::Matches($Manifest.Content, '\"LastUpdated\"\s+\"\d+\"') | Select-Object -ExpandProperty Value | ForEach-Object { 
                $_ -split '"' } | ForEach-Object { 
                $_.Trim() } | Where-Object { 
                $_ } | Select-Object -Last 1 | Select-Object @{N = "LastUpdated"; E = { (Get-Date "1/1/1970").AddSeconds($_).ToLocalTime() } } | Select-Object -ExpandProperty LastUpdated
            #[system.DateTimeOffset]::FromUnixTimeSeconds(1625346931)
        }
    }
    Catch {
        $App = [pscustomobject]@{
            Name        = "Malformed App Manifest"
            AppID       = "unknown"
            AppManifest = $ManifestPath
        }
    }        


    #try to get ProtonDB rating
    # Try {
    #     $ProtonDB = Invoke-RestMethod -Uri "https://protondb.max-p.me/games/$($App.AppID)/reports"
    #     $Rating = $ProtonDB | Group-Object -Property rating -NoElement | Sort-Object Count -Descending | Select-Object -ExpandProperty Name -First 1
    #     $App | Add-Member ProtonDB($Rating) -Force
    # }
    # Catch {
    #     $App | Add-Member ProtonDB("unknown") -Force
    # }
    
    # Test for Install Files
    $CommonPath = "$($app.Library)\common\$($app.InstallDir)"
    $CommonTest = Test-Path $CommonPath
    $message = $null
    if ($CommonTest) {
        $SizeOnDisk = Try {
            $fso = New-Object -ComObject Scripting.FileSystemObject
            $fso.GetFolder($CommonPath).Size
        }
        Catch {
            Get-ChildItem $CommonPath -Force -Recurse -ErrorAction SilentlyContinue | Measure-Object -Sum -Property Length | Select-Object -ExpandProperty Sum
        }
        $SizeGB = [math]::Round($SizeOnDisk / 1GB, 2)
    }
    else {
        $message = "Directory Not Found: {$($CommonPath)} Size:{$([int]$SizeOnDisk)}"
    }

    if ($CommonTest -and $SizeOnDisk -gt 1 -and $app.InstallDir.Length -ge 3) {
        $App | Add-Member CommonPath($CommonPath) -Force
        $App | Add-Member SizeOnDisk($SizeOnDisk) -Force
        $App | Add-Member GB($SizeGB) -Force
        $App | Add-Member Status("OK") -Force
        
    }
    else {
        $App | Add-Member CommonPath($CommonPath) -Force
        $App | Add-Member SizeOnDisk(0) -Force
        $App | Add-Member Status("Fail") -Force
        $message = "Directory is Empty: {$($CommonPath)} Size:{$([int]$SizeOnDisk)}"
    }
    $App | Add-Member Message($message) -Force
    $App | Add-Member Location($Location) -Force
    Return $App
}

Export-ModuleMember Convert-AppManifest


#Credit to Trevor Sullivan https://stackoverflow.com/questions/13883404/custom-robocopy-progress-bar-in-powershell
function Copy-WithProgress {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Source
        , [Parameter(Mandatory = $true)]
        [string] $Destination
        , [int] $Gap = 200
        , [int] $ReportGap = 2000
    )
    # Define regular expression that will gather number of bytes copied
    $RegexBytes = '(?<=\s+)\d+(?=\s+)';

    #region Robocopy params
    # MIR = Mirror mode
    # NP  = Don't show progress percentage in log
    # NC  = Don't log file classes (existing, new file, etc.)
    # BYTES = Show file sizes in bytes
    # NJH = Do not display robocopy job header (JH)
    # NJS = Do not display robocopy job summary (JS)
    # TEE = Display log in stdout AND in target log file
    $CommonRobocopyParams = '/MIR /NP /NDL /NC /BYTES /NJH /NJS';
    #endregion Robocopy params

    #region Robocopy Staging
    Write-Verbose -Message 'Analyzing robocopy job ...';
    $StagingLogPath = '{0}\temp\{1} robocopy staging.log' -f $env:windir, (Get-Date -Format 'yyyy-MM-dd HH-mm-ss');

    $StagingArgumentList = '"{0}" "{1}" /LOG:"{2}" /L {3}' -f $Source, $Destination, $StagingLogPath, $CommonRobocopyParams;
    Write-Verbose -Message ('Staging arguments: {0}' -f $StagingArgumentList);
    Start-Process -Wait -FilePath robocopy.exe -ArgumentList $StagingArgumentList -NoNewWindow;
    # Get the total number of files that will be copied
    $StagingContent = Get-Content -Path $StagingLogPath;
    $TotalFileCount = $StagingContent.Count - 1;

    # Get the total number of bytes to be copied
    [RegEx]::Matches(($StagingContent -join "`n"), $RegexBytes) | % { $BytesTotal = 0; } { $BytesTotal += $_.Value; };
    Write-Verbose -Message ('Total bytes to be copied: {0}' -f $BytesTotal);
    #endregion Robocopy Staging

    #region Start Robocopy
    # Begin the robocopy process
    $RobocopyLogPath = '{0}\temp\{1} robocopy.log' -f $env:windir, (Get-Date -Format 'yyyy-MM-dd HH-mm-ss');
    $ArgumentList = '"{0}" "{1}" /LOG:"{2}" /ipg:{3} {4}' -f $Source, $Destination, $RobocopyLogPath, $Gap, $CommonRobocopyParams;
    Write-Verbose -Message ('Beginning the robocopy process with arguments: {0}' -f $ArgumentList);
    $Robocopy = Start-Process -FilePath robocopy.exe -ArgumentList $ArgumentList -Verbose -PassThru -NoNewWindow;
    Start-Sleep -Milliseconds 100;
    #endregion Start Robocopy

    #region Progress bar loop
    while (!$Robocopy.HasExited) {
        Start-Sleep -Milliseconds $ReportGap;
        $BytesCopied = 0;
        $LogContent = Get-Content -Path $RobocopyLogPath;
        $BytesCopied = [Regex]::Matches($LogContent, $RegexBytes) | ForEach-Object -Process { $BytesCopied += $_.Value; } -End { $BytesCopied; };
        $CopiedFileCount = $LogContent.Count - 1;
        Write-Verbose -Message ('Bytes copied: {0}' -f $BytesCopied);
        Write-Verbose -Message ('Files copied: {0}' -f $LogContent.Count);
        $Percentage = 0;
        if ($BytesCopied -gt 0) {
            $Percentage = (($BytesCopied / $BytesTotal) * 100)
        }
        Write-Progress -Activity Robocopy -Status ("Copied {0} of {1} files; Copied {2} of {3} bytes" -f $CopiedFileCount, $TotalFileCount, $BytesCopied, $BytesTotal) -PercentComplete $Percentage
    }
    #endregion Progress loop

    #region Function output
    [PSCustomObject]@{
        BytesCopied = $BytesCopied;
        FilesCopied = $CopiedFileCount;
    };
    #endregion Function output
}

Export-ModuleMember Copy-WithProgress
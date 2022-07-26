# Scripts

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="copy-to-deck-anchor"></a>
<BR><BR>

## Install Steam Games from Windows Desktop to SteamDeck (CopyToDeck)

> This Script will automatically scan your Desktop PC for Steam LIbraries and Detect all Installed Games
> Then show you which games are not installed on your Steam Deck and allow you to install them via your Home Network or Removable Media (MicroSDXC Card)

### Prerequisites
> There are 2 known methods for directly transferring games to your SteamDeck
> - Windows Mapped Drives using WinFSP and SSHFS-Win 
>   - see my guides (below) (This Assumes you've also setup SSH on your SteamDeck)
>   - [Setting up SSHD](https://github.com/Matalus/steamdeck-tips/blob/main/wiki/ssh.md#user-content-setting-up-sshd)
>   - [Map Network Drives in Windows to your Deck (SSHFS-Win, WinFsp)](https://github.com/Matalus/steamdeck-tips/blob/main/wiki/ssh.md#user-content-map-network-drives-in-windows-to-your-deck-sshfs-win-winfsp)
> - Locally Mounted MicroSDXC Card using something like **Paragon Software: Linux FileSystem for Windows**
>   - https://www.paragon-software.com/us/home/linuxfs-windows/

### Additional Prerequisites
> - **Windows 10**
> -  **PowerShell 5.1+** Installed in Windows 10 by Default

### Installing the Script
- **Easy Method:** [Download Zip](https://github.com/Matalus/steamdeck-tips/archive/refs/heads/main.zip) And Place the `steamdeck-tips` folder anywhere on your PC
- **Advanced Method (GIT):** (Assumes you have `git` installed https://git-scm.com/download/win)
    1. Create an empty directory on your PC using `PowerShell` or `CMD`  

        ```
        mkdir steamdeck-tips
        cd steamdeck-tips
        ```
        *You should now be inside the `steamdeck-tips` directory*

    2. Run the following `git` commands from the `steamdeck-tips` directory

       ```
       git init
       git remote add origin https://github.com/Matalus/steamdeck-tips.git
       git pull origin master
       ```
### Running the Script

<BR>

> - **Easy Method:** Double-Click the included Batch File
> - I've included a simple clickable batch file for those that may not be familiar with `PowerShell`

1. Open the `steamdeck-tips\scripts` Directory from the location you downloaded it
2. Double-Click the `CopyToDeck.cmd` file

![/images/dbl-click-coptodeckcmd.jpg](/images/dbl-click-copytodeckcmd.jpg)

3. Click **Yes** if prompted by `User Account Control`

<BR>

> - **Advanced Method:** `PowerShell` RunAs Administrator

1. Open a `PowerShell` Prompt as Administrator and Run the following command

    ```PowerShell
    .\scripts\CopyToDeck.ps1
    ```
### Using the Script

1. The Script will run and search your local hard drives for `appmanifest*.acf` files
2. These files will be scanned and used to build an inventory of your installed games
3. Additionally the Script will scan mapped drives and removable media to determine what games are installed on them.
> - `appmanifest_*.acf` are the files **Steam** uses to determine what Games are installed.
> - Each Steam Library on your PC will contain potentially multiple of these files in the `steamapps` directory
> - The default location of these is `c:\program files (x86)\Steam\steamapps`

<BR>

![/images/script-run-inventory.jpg](/images/script-run-inventory.jpg)

4. If any games `common` directories are missing or the directory is empty, the Script will flag it and remove it from the selection.

![/images/script-run-inventory.jpg](/images/script-run-filesmissing.jpg)

5. Additionally the Script will attempt to scan **Remote Media**
 - This includes:
 - Mapped Drives mounted using `SSHFS-Win` as explained in the **prereqs** section
 - Removable Media such as `MicroSDXC` cards mounted locally

<img src="/images/script-run-remotescan.jpg" alt="/images/script-run-remotescan.jpg" height="120px">

6. You'll now see an additional `PowerShell` GUI window popup where you can select which games to install

![/images/select-games.jpg](/images/select-games.jpg)

7. Click the games you'd like to install

    > NOTE: you can use <kbd>Ctrl</kbd> + <kbd>Click</kbd> and  <kbd>Shift</kbd> + <kbd>Click</kbd> to select multiple choices
    > Additionally: you can use the **Filter** field to find specific games

    ![/images/select-filter.jpg](/images/select-filter.jpg)
    
    > All Columns can be sorted by clicking them

    ![/images/select-sorted.jpg](/images/select-sorted.jpg)

8. Once you've selected the Games you'd like to install on your **SteamDeck**, Click <kbd>OK</kbd>
9. Select the Remote Steam Library you'd like to install these games on.

    ![/images/select-remotevol.jpg](/images/select-remotevol.jpg)

10. The Games will begin to copy to your Remote Steam Library

    > This process utilizes `Robocopy` an included windows utility for copying files, Robocopy is capable of transferring large volumes of files very quickly, however actual transfer speed is dependent on factors such as your WLAN tx speed and the maximum write speed of the destination media

    ![/images/copy-games.jpg](/images/copy-games.jpg)

11. Once all games you've selected have been copied to their remote destination a sound will play to let you know the transfer is complete.
12. You'll now be presented with a summary of games you've installed during your session, as well as you'll be presented with an option to either quit or copy additional games. answer `y` to copy more games, any other response will `quit`

    ![/images/transfer-complete.jpg](/images/transfer-complete.jpg)

13. Now if you restart your deck <kbd>STEAM</kbd> > **Power** > **Restart**, And go to your **Library**

    ![/images/deck-games-installed.jpg](/images/deck-games-installed.jpg)


<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="get-steam-games-anchor"></a>
<BR><BR>

## List All Steam Games (GetSteamGames)

WIP

1. Open a `PowerShell` Prompt as Administrator and Run the following command

    ```PowerShell
    .\scripts\GetSteamGames.ps1
    ```

<img src="/images/steam-inventory.jpg" height="350">


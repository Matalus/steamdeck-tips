# Scripts

## Install Steam Games from Windows Desktop to SteamDeck (CopyToDeck)

> This Script will automatically scan your Desktop PC for Steam LIbraries and Detect all Installed Games
> Then show you which games are not installed on your Steam Deck and allow you to install them via your Home Network or Removeable Media (MicroSDXC Card)

### Prerequisites
> There are 2 known methods for directly transferring games to your SteamDeck
> - Windows Mapped Drives using WinFSP and SSHFS-Win 
>   - see my guides (below) (This Assumes you've also setup SSH on your SteamDeck)
>   - [Setting up SSHD](https://github.com/Matalus/steamdeck-tips/blob/main/ssh.md#setting-up-sshd)
>   - [Map Network Drives in Windows to your Deck (SSHFS-Win, WinFsp)](https://github.com/Matalus/steamdeck-tips/blob/main/ssh.md#user-content-map-network-drives-in-windows-to-your-deck-sshfs-win-winfsp)
> - Locally Mounted MicroSDXC Card using something like **Paragon Software: Linux FileSystem for Windows**
>   - https://www.paragon-software.com/us/home/linuxfs-windows/

### Additonal Prerequisites
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
3. Additonally the Script will scan mapped drives and removeable media to determine what games are installed on them.
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
 - Removeable Media such as `MicroSDXC` cards mounted locally

<img src="/images/script-run-remotescan.jpg" alt="/images/script-run-remotescan.jpg" height="60px">





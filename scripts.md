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
- **Easy Method:** Double-Click the included Batch File
> I've included a simple clickable batch file for those that may not be familiar with `PowerShell`
    1. Open the `steamdeck-tips\scripts` Directory from the location you downloaded it
    2. Double-Click the `CopyToDeck.cmd` file

![/images/dbl-click-coptodeckcmd.jpg](/images/dbl-click-copytodeckcmd.jpg)


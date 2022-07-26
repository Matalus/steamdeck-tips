# Non-Steam Games
 ### Find the exe path for non-steam files
 ```bash
 # Format: find [dir] -iname [file name (wildcards allowed, case insensitive)]
 # find battle.net launcher EXE path
 find /home/deck/.local/share/ -iname "battle.net*launcher*exe"

 #output
 /home/deck/.local/share/Steam/steamapps/compatdata/2738429330/pfx/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe
 ```
### BoilR (import non-steam shortcuts and cover art)

> - install **BoilR** `sudo flatpak install io.github.philipk.boilr`
> - **Application Launcher** > **All Applications** > **BoilR**
> - **Import Games** (tab) > Click **Import your games into steam** (bottom left)

### BoilR (import cover art from SteamGridDB)

> - (optional) register account on `https://www.steamgriddb.com` 
> - Create an API Key `https://www.steamgriddb.com/profile/preferences/api`
> - Copy the `API Key`
> - Paste it into: **Settings**  > **Authorization key**
> - **Check* boxes for `Download Images` and `Prefer animated images`

### Battle.net

> - download `Battle.net-setup.exe` using `Chrome` in Desktop Mode
> - Add a **Non-Steam** game to steam pointed at `/home/deck/Downloads/Battle.net-setup.exe`
> - Accept Default installation Path and allow install to complete

### Origin (EA)

> - download `OriginThinSetup.exe` using `Chrome` in Desktop Mode
> - Add a **Non-Steam** game to steam pointed at `/home/deck/Downloads/OriginThinSetup.exe`
> - Accept Default installation Path and allow install to complete

### Epic Games Store

> Use `Heroic Games Launcher` for Epic and GoG
> - install HGL `sudo flatpak install com.heroicgameslauncher.hgl`
> - **Application Launcher** > **All Applications** > **Heroic Games Launcher**
> - Connect to Epic Games Store with your account
> - Install games from the **Library** tab
> - (optional) use `BoilR` to automatically import game shorcuts into **Steam**

## Logging 

> Relevant Logging Directories
- Steam Proton Logs `~/steam-*` example: `steam-17791636650569236480.log`
- Proton Crash Logs `/tmp/proton_crashreports`
- Heroic Games Launcher Logs `/home/deck/.var/app/com.heroicgameslauncher.hgl/config/heroic/GamesConfig`
- Steam Launcher Logs `/home/deck/.local/share/Steam/logs/`
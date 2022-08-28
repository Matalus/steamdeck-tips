# Non-Steam Games

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="find-exe-anchor"></a>
<BR><BR>

 ## Find the exe path for non-steam files
 ---
> You can use `Konsole` and the `find` command in desktop mode to search for any file you want

 1. Press <kbd>STEAM</kbd> > **Power** > **Desktop Mode**
 2. Goto **All Applications** and open **Konsole**
 
**Format your searches from the examples below**

> Search for Non-Steam games installed using steam
 ```bash
# Format: find [dir] -iname [file name (wildcards allowed, case insensitive)]
# find battle.net launcher EXE path
# you'll need to have set a user password previously, if not you can run 'passwd' to do this now
sudo find /home/deck/.local/share/ -iname "battle.net*launcher*exe"

#output
/home/deck/.local/share/Steam/steamapps/compatdata/2738429330/pfx/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe
 ```
<img src="/images/konsole-find-bnet.jpg" height="250" width="950">

<BR>

> Search entire deck for `TheAscent.exe`, `/` is the root directory, meaning everything will be search SSD and SD
```bash
sudo find / -name "*ascent*exe"
```

<img src="/images/konsole-find-ascent.jpg" height="250" width="950">

<BR>

> Search SD Card for `TheOuterWorlds.exe`, `/run/media/` is the is the mount point for SD cards
```bash
sudo find /run/media/ -name "*outer*world*exe"
```

<img src="/images/konsole-find-ascent.jpg" height="250" width="950">

<BR>

> Find `MassEffectAndromeda.exe` in it's `compatdata` folder, `/home/deck/.local/share/Steam/steamapps/compatdata` is where 3rd party stores will install games, provided you used Steam to run the store installer.
```bash
sudo find /home/deck -name "MassEffectAndromeda.exe"
```

<img src="/images/konsole-find-andromeda.jpg" height="200" width="950">

<BR>

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="boilr-install-anchor"></a>
<BR><BR>

## BoilR (import non-steam shortcuts and cover art)
---

> - install **BoilR** `sudo flatpak install io.github.philipk.boilr`
> - **Application Launcher** > **All Applications** > **BoilR**
> - **Import Games** (tab) > Click **Import your games into steam** (bottom left)

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="boilr-steamgriddb-anchor"></a>
<BR><BR>

## BoilR (import cover art from SteamGridDB)
---

> - (optional) register account on `https://www.steamgriddb.com` 
> - Create an API Key `https://www.steamgriddb.com/profile/preferences/api`
> - Copy the `API Key`
> - Paste it into: **Settings**  > **Authorization key**
> - **Check* boxes for `Download Images` and `Prefer animated images`

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="battlenet-anchor"></a>
<BR><BR>

### Battle.net
---

> - download `Battle.net-setup.exe` using `Chrome` in Desktop Mode
> - Add a **Non-Steam** game to steam pointed at `/home/deck/Downloads/Battle.net-setup.exe`
> - Accept Default installation Path and allow install to complete

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="origin-anchor"></a>
<BR><BR>

### Origin (EA)
---

> - download `OriginThinSetup.exe` using `Chrome` in Desktop Mode
> - Add a **Non-Steam** game to steam pointed at `/home/deck/Downloads/OriginThinSetup.exe`
> - Accept Default installation Path and allow install to complete

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="epic-games-anchor"></a>
<BR><BR>

### Epic Games Store
---

> Use `Heroic Games Launcher` for Epic and GoG
> - install HGL `sudo flatpak install com.heroicgameslauncher.hgl`
> - **Application Launcher** > **All Applications** > **Heroic Games Launcher**
> - Connect to Epic Games Store with your account
> - Install games from the **Library** tab
> - (optional) use `BoilR` to automatically import game shortcuts into **Steam**

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="steam-launch-options-anchor"></a>
<BR><BR>

### Steam Launch Options
---

> These are variables that can be specified at runtime, useful for adding non-steam games

**STEAM_COMPAT_DATA_PATH:** specifies the directory where the wine prefix will exist 
- example: `/home/deck/.local/share/Steam/steamapps/compatdata/4021751282`

**PROTON_LOG:** set to `1` to enable proton logs
- example: `PROTON_LOG=1`

**DXVK_HUD:** force an fps counter for Vulkan
- example: `DXVK_HUD= devinfo, fps, frametimes`

**Launch Options Example**
```
STEAM_COMPAT_DATA_PATH=/home/deck/.local/share/Steam/steamapps/compatdata/4021751282 PROTON_LOG=1 %command%
```
<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="logging-anchor"></a>
<BR><BR>

## Logging
---

> Relevant Logging Directories
- Steam Proton Logs `~/steam-*` example: `steam-17791636650569236480.log`
- Proton Crash Logs `/tmp/proton_crashreports`
- Heroic Games Launcher Logs `/home/deck/.var/app/com.heroicgameslauncher.hgl/config/heroic/GamesConfig`
- Steam Launcher Logs `/home/deck/.local/share/Steam/logs/`

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="find-exe-anchor"></a>
<BR><BR>

 ## Managing Storage

 > The Steam Deck makes it really easy to manage Steam games installed, this is in part due to valve including an `appmanifest` file for each game and package installed that gives it's `SizeOnDisk`
 > unfortunately **Non-Steam** games and utilities don't get totalled into this calculation so you may be left wondering *Where did my space go?*

 <img src=/images/settings-storage.jpg height="400">

 In this scenario I have a **256GB** Local SSD, approximately **29GB** is used by installed **Steam** games, but another **128GB** is totally unaccounted for. I'll now go through my process to find where that space is consumed.

 1. Go the desktop mode by pressing <kbd>STEAM</kbd> > Power > Switch to Desktop Mode
 2. open `Konsole`
 3. Run the following command at the prompt
 ```bash
 df -h
 ```
 > `df` = linux command for **Disk Free**

 <img src=/images/df-h.jpg height="300">

 This will give us a breakdown of how each disk partition and mountpoint is using space.

 Since **SteamOS** uses an immutable file system, we'll want to focus on our `/home/deck` directory

 1. Run the following command
 ```bash
 du -h -d3 -t 100M /home/deck | sort -h
 ```
 > `du` = linux command for **Disk Usage** `-h` = **Human-Readable**, so we'll see directory sizes in standard units vs bytes, `-d3` = **depth** this will show us only subdirectories that are 3 or less levels down from the top `/home/deck` directory `-t 500M` sets the size threshold to results greater than 100MB

  <img src=/images/du-home.jpg height="200">



 



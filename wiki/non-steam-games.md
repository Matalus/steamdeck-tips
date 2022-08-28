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
<a name="managing-storage-anchor"></a>
<BR><BR>

 ## Managing Storage

 > The Steam Deck makes it really easy to manage Steam games installed, this is in part due to valve including an `appmanifest` file for each game and package installed that gives it's `SizeOnDisk`
 > unfortunately **Non-Steam** games and utilities don't get totalled into this calculation so you may be left wondering *Where did my space go?*

 <img src=/images/settings-storage.jpg height="400">

 In this scenario I have a **256GB** Local SSD, approximately **29GB** is used by installed **Steam** games, but another **128GB** is totally unaccounted for. I'll now go through my process to find where that space is consumed.

 1. Go the desktop mode by pressing <kbd>STEAM</kbd> > Power > Switch to Desktop Mode
 2. open `Konsole`  
 >alternatively you can connect via SSH from another PC `ssh deck@steamdeck` this makes pasting long commands significantly easier
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
 > `du` = linux command for **Disk Usage** `-h` = **Human-Readable**, so we'll see directory sizes in standard units vs bytes, `-d3` = **depth** this will show us only subdirectories that are 3 or less levels down from the top `/home/deck` directory `-t 100M` sets the size threshold to results greater than 100MB
 ><BR><BR>PROTIP: pressing the <kbd>up</kbd> arrow will always go back to your last command, this is easier than retyping each time.

 <BR>

  <img src=/images/du-home-1.jpg height="400">



  2. We can filter the results using the `grep` command, we'll use this to filter specific patterns
  > `grep` (**G**lobal **R**egular **E**xpression **P**rint) is a very useful linux command we can use to filter output and determine what prints on the screen. 
  3. I'll now show different command examples breaking down these results 

```bash
 du -h -d3 -t 100M /home/deck | sort -h | grep .var/app
```
First we notice a number of results in `/home/deck/.var/app` this is where a lot of our packaged desktop applications will go, <BR>anything we install using either `flatpak` or `Discover` will go to this directory, <BR>we can see **Chrome**, **protontricks** and **Heroic Games Launcher** all installed here so this accounts for about **2GB** in my case.

 <BR>

  <img src=/images/du-var-app.jpg height="120">

```bash
 du -h -d3 -t 100M /home/deck | sort -h | grep Heroic
```

Next we'll look at **Heroic** in `/home/deck/Games/Heroic`, we can see this accounts for a full **20GB** of space,<BR> and we can see both **Rebel Galaxy Outlaw** and **Unrailed** installed as well as some prefix data.

 <BR>

  <img src=/images/du-heroic.jpg height="120">

```bash
 du -h -d3 -t 100M /home/deck | sort -h | grep -Ev 'Heroic|.var'
```
> we're now using `grep -Ev` this is an inverted match, we're now looking for lines that **don't** match the pattern <BR>`-E` turns on **extended regular expression** which allows us to use more advanced patterns <BR> `|` is a separator, any pattern we place in this string with the separator will be filtered out of the results so in this case we're filtering out our previous results containing `Heroic` and `.var`
 
 <BR>

  <img src=/images/du-grep-v.jpg height="200">

  We can see that `.paradoxlauncher` (Stellaris) seems to account for about 500MB, there's about 1.2GB of `.cache` data so we've accounted for about **24GB** of `other` data in total now, but we still have over **100GB** unaccounted for.

```bash
 du -h -d1 -t 100M /home/deck/.local/share/Steams | sort -h
```
> we're now targeting the `Steam` directory

 <BR>

  <img src=/images/du-steamapps.jpg height="120">

  We immediately see that `steamapps` is consuming **120GB** there's also a number of other smaller directories, that appear related to the OS or Proton compatibility. <BR>
  `du -h -d1 -t 100M --exclude="steamapps" -c /home/deck/.local/share/Steam | sort -h` will show us the results excluding the `steamapps` directory `--exclude="steamapps"` will exclude this pattern and `-c` will add a total line so we can see much these directories consume, in my case it's **5.3GB** we'll round up in case we missed anything

  ```bash
  du -h -d1 -t 100M  /home/deck/.local/share/Steam/steamapps/compatdata | sort -h
  ```
  > the `compatdata` directory is where the **proton** compatibility files get installed for every game, this can really add up if steam fails to delete the directories for games you uninstall or if a **Non-Steam** game doesn't get cleaned up properly <BR>
  Additionally any **Non-Steam** game that you use **Steam** to install will have the entire game installed into it's `compatdata` directory

  ```
  188M    /home/deck/.local/share/Steam/steamapps/compatdata/1042800
188M    /home/deck/.local/share/Steam/steamapps/compatdata/1944570
188M    /home/deck/.local/share/Steam/steamapps/compatdata/2024230
188M    /home/deck/.local/share/Steam/steamapps/compatdata/238960
188M    /home/deck/.local/share/Steam/steamapps/compatdata/2611203949
188M    /home/deck/.local/share/Steam/steamapps/compatdata/323190
188M    /home/deck/.local/share/Steam/steamapps/compatdata/527430
188M    /home/deck/.local/share/Steam/steamapps/compatdata/632360
189M    /home/deck/.local/share/Steam/steamapps/compatdata/1774050
189M    /home/deck/.local/share/Steam/steamapps/compatdata/1869380
189M    /home/deck/.local/share/Steam/steamapps/compatdata/1887720
189M    /home/deck/.local/share/Steam/steamapps/compatdata/2106550
189M    /home/deck/.local/share/Steam/steamapps/compatdata/2113430
189M    /home/deck/.local/share/Steam/steamapps/compatdata/911430
190M    /home/deck/.local/share/Steam/steamapps/compatdata/2083070
191M    /home/deck/.local/share/Steam/steamapps/compatdata/396480
192M    /home/deck/.local/share/Steam/steamapps/compatdata/1794680
200M    /home/deck/.local/share/Steam/steamapps/compatdata/2579677180
202M    /home/deck/.local/share/Steam/steamapps/compatdata/1966900
204M    /home/deck/.local/share/Steam/steamapps/compatdata/1660320
215M    /home/deck/.local/share/Steam/steamapps/compatdata/0
216M    /home/deck/.local/share/Steam/steamapps/compatdata/2581508876
216M    /home/deck/.local/share/Steam/steamapps/compatdata/2791824981
216M    /home/deck/.local/share/Steam/steamapps/compatdata/3550137221
217M    /home/deck/.local/share/Steam/steamapps/compatdata/4275862806
260M    /home/deck/.local/share/Steam/steamapps/compatdata/700600
337M    /home/deck/.local/share/Steam/steamapps/compatdata/2914290092
420M    /home/deck/.local/share/Steam/steamapps/compatdata/288370
424M    /home/deck/.local/share/Steam/steamapps/compatdata/1062090
427M    /home/deck/.local/share/Steam/steamapps/compatdata/710920
436M    /home/deck/.local/share/Steam/steamapps/compatdata/1030210
468M    /home/deck/.local/share/Steam/steamapps/compatdata/290300
502M    /home/deck/.local/share/Steam/steamapps/compatdata/979690
523M    /home/deck/.local/share/Steam/steamapps/compatdata/219990
624M    /home/deck/.local/share/Steam/steamapps/compatdata/1128920
645M    /home/deck/.local/share/Steam/steamapps/compatdata/768520
29G     /home/deck/.local/share/Steam/steamapps/compatdata/2738429330
49G     /home/deck/.local/share/Steam/steamapps/compatdata/4021751282
```

In my case I have 38 games installed between my SteamDeck SSD and MicroSD, what's worth noting is steam uses `<APPID>` to identify where game files are installed for `shadercache` `compatdata` and other files. Most Steam AppIDs are 3-7 digits long, the longer numbers are mostly likely 3rd party **Non-Steam** games, we should focus on those

*Which brings us to...*
```bash
# In the IT Industry we call that a One-Liner :)
du -h -d1 -t 100M  /home/deck/.local/share/Steam/steamapps/compatdata | sort -h | awk '{print $2}' | grep -E '\/[[:digit:]]{8,20}$' | xargs du -h -d5 -t 200M | grep drive_c | sort -h
```
<BR>

> I'll try to explain a few things <BR> `awk` is being used to select only the 2nd column from our `du` command <BR> `grep -E` is being used to find directory names that have between 8 and 20 digits in the name since most APPIDs are 7 or less digits <BR> `[[:digit]]` is a class selector, it's matching only numeric characters, and `{8,20}` is only matching filenames between 8-20 digits long <BR> `xargs` allows us to pass the output of our previous command to another command so I'm passing only the directory's that I believe to be **Non-Steam** games to another `du` command to narrow down the results. <BR> lastly `grep drive_c` is finding the fake `c:\` that exists in wine prefixes this is where Windows files will reside

<img src=/images/du-compatdata-breakdown.jpg height=400>

And now it all starts to make sense... <BR>
`4021751282` appears to be where I installed the **Origin** store and also installed **Mass Effect Andromeda** accounting for another **49GB** <BR> `2738429330` seems to be a **Non-Steam** installation of **Battle.net** including **Diablo II Resurrected** another **29GB** <BR> The remaining **Non-Steam** directories account for another about **1GB**

*You don't have to understand regular expression to use it, just paste the full command above and you'll get similar results<BR> I've been using REGEX for 15+ years and I still get confused and think it's Black Magic half the time*

<BR>

### Storage Breakdown
---

So lets review what we've found

| size | directory | contents |
| --- | --- | --- |
| 2GB | /home/deck/.var/apps | flatpak apps |
| 20GB | /home/deck/Games/Heroic | Heroic Games Launcher Games |
| 2GB | /home/deck/.paradoxlauncher and .cache | Hidden Launcher and generic cache files |
| 6GB | /home/deck/.local/share/Steam *except* `steamapps` | SteamOS and Compatibility files |
| 49GB | /home/deck/.local/share/Steam/steamapps/compatdata/4021751282 | Origin (Mass Effect Andromeda) |
| 29GB | /home/deck/.local/share/Steam/steamapps/compatdata/2738429330 | Battle.net (Diablo II Resurrected)
| 1GB | /home/deck/.local/share/Steam/steamapps/compatdata/########## | Other Non-Steam games
| 5GB | /home/deck/.local/share/Steam/steamapps/shadercache | Shader Cache
| 114GB | **Total Accounted** out of **128GB** *Other* files |

While there still is another 14GB unaccounted for, it's possible some of this is consumed by `common` files for other Non-Steam games as well as `proton` prefixes that didn't get cleanly uninstalled. <BR><BR>
This isn't a perfect system but hopefully this helped you understand where your storage is going.
# Proton Tricks

<a name="installing-proton-tricks-gui-anchor"></a>

> proton tricks is a utility that helps you tweak and install windows dependencies into your WINE prefixes to satisfy compatibility requirements

<BR>

## Installing Proton Tricks (GUI)
---

1. press <kbd>STEAM</kbd> button > **Power** > **Switch to Desktop Mode**
2. Click on **Application Launcher** > **All Applications** > **Discover**
3. Use the *Search* box (top left corner) and search for `Protontricks` > click **Install**
4. Once `Protontricks` is installed, search for `Flatseal` > click **Install**
5. Click on **Application Launcher** > **All Applications** > **Flatseal**
6. Once `Flatseal` is loaded, select `Protontricks`
7. Under **Filesystem** > **Other files**, Add the following paths

- `/home/deck`
- `/run/media/mmcblk0p1`

8. Also check the box for **All user files**
9. Add a bash alias by running the following command in `Konsole`
```
echo "alias protontricks='flatpak run com.github.Matoking.protontricks'" >> ~/.bashrc
```
<BR><BR>

<a name="installing-proton-tricks-shell-anchor"></a>

## installing Proton Tricks (shell)
---

> via `ssh` or `Konsole`
>
> Steps for Penguins
> - use flatpak to install proton tricks `sudo flatpak install com.github.Matoking.protontricks`
> - grant filesystem permissions `flatpak override --user --filesystem=/run/media/mmcblk0p1 --filesystem=/home/deck com.github.Matoking.protontricks`
> - add a bash alias `echo "alias protontricks='flatpak run com.github.Matoking.protontricks'" >> ~/.bashrc`

<BR><BR>

<a name="list-detected-steam-games-anchor"></a>

## List detected Steam Games (shell)
---

> via `ssh` or `Konsole`
> You'll need the Steam `APPID` for the games you wish to use protontricks on
> Some `non-steam` games may not show in the list if they are installed in the same prefix, such as `Origin`, `Epic Games Store` etc
1. run the command
```bash
protontricks --list
```
Sample Output
```
#output
Found the following games:
Battlevoid: Harbinger (396480)
EVERSPACE™ 2 (1128920)
Grim Dawn (219990)
Horizon Zero Dawn (1151640)
No Man's Sky (275850)
Non-Steam shortcut: Battle.net (2738429330)
Non-Steam shortcut: D2R (2579677180)
Non-Steam shortcut: Origin (4021751282)
Non-Steam shortcut: Rebel Galaxy Outlaw (2914290092)
Non-Steam shortcut: The Outer Worlds (2581508876)
Path of Exile (238960)
Rebel Galaxy (290300)
Red Solstice 2: Survivors (768520)
Risk of Rain 2 (632360)
Timberborn (1062090)
Torchlight III (1030210)
```
2. *Or* Search for installed Steam Games
```bash
#Format: protontricks -s GAME_NAME
#example search for "Horizon Zero Dawn"
protontricks -s Horizon Zero Dawn

#output
Found the following games:
Horizon Zero Dawn (1151640)
```
3. Note the `APPID`
> For Example the `APPID` for Horizon Zero Dawn is `1151640`

<BR><BR>

<a name="search-for-dependency-anchor"></a>

## Search for an available dependency
---

```bash
# search available dependencies and verbs
# example: search for Visual C++ 2005 Libraries
protontricks 2914290092 list-all | grep "Visual C++ 2005"

#output
vc2005express            MS Visual C++ 2005 Express (Microsoft, 2005) [downloadable]
vc2005expresssp1         MS Visual C++ 2005 Express SP1 (Microsoft, 2007) [downloadable]
vc2005trial              MS Visual C++ 2005 Trial (Microsoft, 2005) [downloadable]
mfc80                    Visual C++ 2005 mfc80 library; part of vcrun2005 (Microsoft, 2011) [downloadable]
vcrun2005                Visual C++ 2005 libraries (mfc80,msvcp80,msvcr80) (Microsoft, 2011) [downloadable]
```
<BR><BR>

<a name="install-windows-dependencies-anchor"></a>

## Install Windows Dependencies
---

```bash
# Format: protontricks APPID [options] verbs
# Install the mfc42 dll and set windows 7 compatibility
protontricks 2914290092 -q --force mfc42 win7
```
<BR><BR>

<a name="reset-wine-prefix-anchor"></a>

### Reset WINE prefix
*When you've really F$%#& it up and nothing is working*
```bash
# Format: protontricks APPID annihilate
protontricks 2914290092 annihilate
```
# SteamDeck Tips
Wiki and files relevant to my Steam Deck tinkering, and all things about NOT playing games on your portable gaming PC

## SSH
> It is highly recommended to setup the SSH service if you plan on doing any serious modding on the deck

### Setting up SSHD 

> (this will walk through setting a user password and enabling the SSH Daemon Service)

1. push the <kbd>STEAM</kbd> button on the deck
2. go to **Power**
3. Select **Switch to Desktop**
4.  From Desktop Mode, Click the **Application Launcher** (Steam Deck Icon, bottom left)
5.  Go to **All Applications** > **Konsole**
6.  run the following commmand
```
passwd
```
7. Enter a secure password (You will be prompted for this anytime you connect to the Deck remotely via SSH)
8. run the following command
```
sudo systemctl enable sshd
```
9. now run the following command to verify the SSHD is enabled
```
sudo systemctl status sshd
```
10. In the output look for `enabled;` on the **Loaded:** line
11. Look for **running** on the `Active:` line
``` example
● sshd.service - OpenSSH Daemon
    Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: disabled)
    Active: active (running) since Sun 2022-07-24 11:13:05 MST; 1 day 11h ago
  Main PID: 911 (sshd)
      Tasks: 1 (limit: 17718)
    Memory: 4.9M
        CPU: 112ms
    CGroup: /system.slice/sshd.service
            └─911 "sshd: /usr/bin/sshd -D [listener] 0 of 10-100 startups"
```

12. If all steps were followed SSH should be enabled, if not *ASK AN ADULT*

### EXTRA CREDIT! Setup Private RSA Keypair and disable password authentication
> This is the most secure way to authenticate
> This assumes you're connecting from your `Windows 10+` gaming rig with at least `PowerShell 5.1` installed

**Prerequisites: Windows (Client)**
  - PowerShell 5.1 or 7.x [guide](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2)
  - OpenSSH (optional feature) [guide](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse#install-openssh-using-powershell)

  **Create and Install the Keypair (Client: Windows)**
  > from a powershell prompt
  1. Run the following command
  ```cmd
  ssh-keygen -t rsa
  ```
  2. When prompted to enter a file location leave it blank for purposes of the guide 

  > generated ssh keys will save to `$HOME\.ssh` by default 
  > typically: `c:\users\<userprofile>\.ssh` 

 3. When prompted enter a secure passphrase
  > Don't recommend leaving this blank, once done you will not need to type a password when you connect via SSH

4. Run the following commands to make sure the `ssh-agent` service is running
```powershell
  Set-Service ssh-agent -StartupType Automatic
  Start-Service ssh-agent -PassThru | Get-Service
```
5. The final output should look like this (otherwise ask an adult)
```
Status   Name               DisplayName
------   ----               -----------
Running  ssh-agent          OpenSSH Authentication Agent
```
6. Run the following command, you'll need the exact path of the key you generated in step 2
```cmd
ssh-add $HOME\.ssh\id_rsa
```
7. When prompted enter your passphrase for the last time, The key is now installed
8. Run the following command to copy your public key to the steam deck

> DO NOT COPY `$HOME\.ssh\id_rsa` this is your Private Key and remains on your windows machine.

```
scp $HOME\.ssh\id_rsa.pub deck@steamdeck:~/.ssh
```

**Configure Public Key Auth (Server: steamdeck)**
> via `ssh` or `Konsole`
>
> Cliffs notes for Penguins
> - confirm the pub key is present `cat ~/.ssh/id_rsa.pub`
> - generate the authorized keys file `cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys`
> - edit `/etc/ssh/sshd_config` and set the values by either uncommenting or appending
> - `PubkeyAuthentication yes`
> - `PasswordAuthentication no`
> - restart **sshd** `sudo systemctl restart sshd.service`
> - test ssh login from windows `ssh deck@steamdeck`


1. confirm your public key was copied to the steamdeck
```
cat ~/.ssh/id_rsa.pub
```
2. assuming the key is present run the following to create the `authorized_keys` file
```
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```
3. run the following commands to modify the `sshd_config` to Enable Public Key Auth, and Disable Password Auth
```
testvar=`grep ^PubkeyAuthentication /etc/ssh/sshd_config`
[ -z "$testvar" ] && echo 'PubkeyAuthentication yes' | sudo tee -a /etc/ssh/sshd_config || echo "already exists: $testvar"

testvar=`grep ^PasswordAuthentication /etc/ssh/sshd_config`
[ -z "$testvar" ] && echo 'PasswordAuthentication no' | sudo tee -a /etc/ssh/sshd_config || echo "already exists: $testvar"

sudo systemctl restart sshd.service
```
**Test Login (Client: Windows)**
1. From your Windows PC login to the deck via SSH

```
ssh deck@steamdeck
```
2. If all instructions were followed, you should NOT be prompted for a password



## proton tricks
> proton tricks is a utility that helps you tweak and install windows dependencies into your WINE prefixes to satisfy compatibility requirements

### Installing Proton Tricks (GUI)

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

### installing Proton Tricks (shell)

> via `ssh` or `Konsole`
>
> Steps for Penguins
> - use flatpak to install proton tricks `sudo flatpak install com.github.Matoking.protontricks`
> - grant filesystem permissions `flatpak override --user --filesystem=/run/media/mmcblk0p1 --filesystem=/home/deck com.github.Matoking.protontricks`
> - add a bash alias `echo "alias protontricks='flatpak run com.github.Matoking.protontricks'" >> ~/.bashrc`

### List detected Steam Games (shell)

> via `ssh` or `Konsole`
> You'll need the Steam `APPID` for the games you wish to use protontricks on
> Some `non-steam` games may not show in the list if they are installed in the same prefex, such as `Origin`, `Epic Games Store` etc
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
#Format protontricks -s GAME_NAME
#example search for "Horizon Zero Dawn"
protontricks -s Horizon Zero Dawn

#output
Found the following games:
Horizon Zero Dawn (1151640)
```
3. Note the `APPID`
> For Example the `APPID` for Horizon Zero Dawn is `1151640`

### Search for an available dependency

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

### Install Windows Dependencies

```bash
# Format protontricks APPID [options] verbs
# Install the mfc42 dll and set windows 7 compatibility
protontricks 2914290092 -q --force mfc42 win7
```

## Non-Steam Games
TBD
### Battle.net
TBD
### Origin (EA)
TBD
### Epic Games Store
TBD
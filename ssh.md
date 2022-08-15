# SSH
> It is highly recommended to setup the SSH service if you plan on doing any serious modding on the deck
<BR><BR>

## Setting up SSHD 
---

> (this will walk through setting a user password and enabling the SSH Daemon Service)

1. push the <kbd>STEAM</kbd> button on the deck
2. go to **Power**
3. Select **Switch to Desktop**
4.  From Desktop Mode, Click the **Application Launcher** (Steam Deck Icon, bottom left)
5.  Go to **All Applications** > **Konsole**
6.  run the following command
```
passwd
```
7. Enter a secure password (You will be prompted for this anytime you connect to the Deck remotely via SSH)
8. run the following command
```
sudo systemctl enable sshd
```
9. now run the following command to verify that SSHD is enabled
```
sudo systemctl status sshd
```
10. In the output look for `enabled;` on the **Loaded:** line
11. Look for **running** on the `Active:` line

  ![/images/sshd-status.jpg](/images/sshd-status.jpg)


<!-- ``` example
● sshd.service - OpenSSH Daemon
    Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: disabled)
    Active: active (running) since Sun 2022-07-24 11:13:05 MST; 1 day 11h ago
  Main PID: 911 (sshd)
      Tasks: 1 (limit: 17718)
    Memory: 4.9M
        CPU: 112ms
    CGroup: /system.slice/sshd.service
            └─911 "sshd: /usr/bin/sshd -D [listener] 0 of 10-100 startups"
``` -->

12. If all steps were followed SSH should be enabled, if not *ASK AN ADULT*

---

<BR><BR>

## Setup Private RSA Keypair and disable password authentication
---
<BR>

> This is the most secure way to authenticate
> This assumes you're connecting from your `Windows 10+` gaming rig with at least `PowerShell 5.1` installed

**Prerequisites: Windows (Client)**
  - PowerShell 5.1 or 7.x [guide](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2)
  - OpenSSH (optional feature) [guide](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse#install-openssh-using-powershell)

  <BR>

**Create and Install the Keypair (Client: Windows)**

> from a powershell prompt

1. Run the following command

  ```cmd
  ssh-keygen -t rsa -f $HOME/.ssh/id_rsa
  ```
  > **Example:** Generating a Test Key (by default your key will be named `id_rsa`)

  ![/images/ssh-keygen.jpg](/images/ssh-keygen.jpg)


2. When prompted to enter a file location leave it blank for purposes of the guide 

  > generated ssh keys will save to `$HOME\.ssh` by default 
  > typically: `c:\users\<userprofile>\.ssh` 

 3. When prompted enter a secure passphrase

  > Don't recommend leaving this blank, once done you will not need to type a password when you connect via SSH
  <br><span style='color:red;font-weight:bold'>If you plan on using [SSHFS](https://github.com/winfsp/sshfs-win#unc-syntax) to map drives to your Deck, leave the passphrase blank, SSHFS doesn't support PubKey passphrases</span>

4. Run the following commands to make sure the `ssh-agent` service is running

```powershell
Set-Service ssh-agent -StartupType Automatic
Start-Service ssh-agent -PassThru | Get-Service
```

5. The final output should look like this (otherwise ask an adult)

  ![/images/ssh-agent-start.jpg](/images/ssh-agent-start.jpg)

<!-- ```
Status   Name               DisplayName
------   ----               -----------
Running  ssh-agent          OpenSSH Authentication Agent
``` -->

6. Run the following command, you'll need the exact path of the key you generated in step 2
```cmd
ssh-add $HOME/.ssh/id_rsa
```

7. When prompted enter your passphrase for the last time, The key is now installed

> **Example:** Test Key added to `ssh-agent`

  ![/images/ssh-add.jpg](/images/ssh-add.jpg)

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
  > WARNING: <span style='color:red;font-weight:bold'>Don't share actual SSH keys you use for authentication on the internet</span>

  ![/images/test-pubkey.jpg](/images/test-pubkey.jpg)


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
> Additionally: This file can also be edited using `nano` or `vim` (if you're a masochist)

  ![/images/nano-edit.jpg](/images/nano-edit.jpg)


**Test Login (Client: Windows)**
1. From your Windows PC login to the deck via SSH

```
ssh deck@steamdeck
```
2. If all instructions were followed, you should NOT be prompted for a password

  ![/images/ssh-connect.jpg](/images/ssh-connect.jpg)

**IF IT STILL DOESN'T WORK ASK AN ADULT**

<BR><BR>

### Map Network Drives in Windows to your Deck (SSHFS-Win, WinFsp)

> SSHFS-Win: enables Windows to connect via SFTP to an SSH Server
> WinFsp: Windows File System Proxy; allows support for custom filesystem on windows
> [github: SSHFS-Win](https://github.com/winfsp/sshfs-win)

**Install SSHFS-Win and WinFsp**

1. From a PowerShell prompt
```
winget install WinFsp.WinFsp; winget install SSHFS-Win.SSHFS-Win
```

  ![/images/winfsp-sshfs-install.jpg](/images/winfsp-sshfs-install.jpg)


This will install the required packages

> NOTE: if you don't have `winget` installed, you can open the `Microsoft Store` and search for **winget** and install it, it may also be called **App Installer**
> [Microsoft Store: App Installer](https://www.microsoft.com/store/productId/9NBLGGH4NNS1)


<img src="/images/msstore-install-winget.jpg" alt="/images/msstore-install-winget.jpg" height="200px">

**Map Network Drives**
> NOTE: SSHFS may require specific syntax depending on you connect to SSH
> `sshfs` by default will connect to your user home directory usually `/home/deck`
> `sshfs.k` will use your private key to connect
> `sshfs.r` will allow you connect from the root dir
> `sshfs.k` and `sshfs.kr` will be needed if you're using `Pubkey` auth

1. Map Drive to your Internal SSD `Steam` directory

```
net use Z: \\sshfs\deck@steamdeck\.local\share\Steam /persistent:yes /savecred
```

2. Map Drive to your MicroSD

> NOTE: if you didn't let the deck auto-format your SD card, replace `mmcblk0p1` with the name of the volume

```
net use Z: \\sshfs.r\deck@steamdeck\run\media\mmcblk0p1 /persistent:yes /savecred
```

  > These Drives should now be persistent and reconnect at login

  ![/images/mapped-drives.jpg](/images/mapped-drives.jpg)



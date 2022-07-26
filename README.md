# SteamDeck Tips
Wiki and files relevant to my Steam Deck tinkering

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


## proton tricks

## Non-Steam Games

### Battle.net

### Origin (EA)

### Epic Games Store

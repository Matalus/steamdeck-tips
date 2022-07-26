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
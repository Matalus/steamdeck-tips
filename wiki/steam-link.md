# Steam Link 

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="setting-up-steamlink-anchor"></a>
<BR><BR>

## Setting up Steam Link
---

> Setting up Steam Link will Allow you to control your Steam Deck remotely from your PC with a fullsize Keyboard and Mouse
> This is really useful for tinkering and troubleshooting non-steam games

<img src="/images/steam-link-example.jpg" height="350">

<!-- ![/images/steam-link-example.jpg](/images/steam-link-example.jpg|width=100) -->

1. Download **Steam Link** for Windows from https://store.steampowered.com/remoteplay#anywhere_how
2. Click the **For Windows** link and allow the file to download

<img src="/images/steam-link-for-windows.jpg" height="350">

3. **Unzip** `SteamLink.zip` into a directory
4. Open the Directory you unzipped `SteamLink.zip` into
5. <kbd>Right Click</kbd> `SteamLink.msi` and select **Install**
6. Follow the On-Screen prompts and click **Next** as prompted, you may have to click **Yes** on a UAC Prompt

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="steamlink-pairing-anchor"></a>
<BR><BR>

## Steam Link Pairing
---

> Generally Steam Link is very simple to setup, but it can be confusing if everything doesn't connect automatically
> The Instruction included are for manually pairing your Steam Deck

1. Open **Steam Link** and Click on the **Settings** Gear

<img src="/images/steam-link-manual-pair-1.jpg" height="350">

2. Goto **Computer**

<img src="/images/steam-link-manual-pair-2.jpg" height="350">

3. Goto **Other Computer**

<img src="/images/steam-link-manual-pair-3.jpg" height="350">

4. Note the `PIN` 

<img src="/images/steam-link-manual-pair-4.jpg" height="350">

5. On your **Steam Deck** Press the <kbd>STEAM</kbd> button
6. Goto **Settings** > **Remote Play**
7. Press **Pair Steam Link**

<img src="/images/steamdeck-manual-pair.jpg" height="350">

8. Enter the `PIN` from Step 4.

<img src="/images/steamdeck-manual-pair-2.jpg" height="350">

9. After a few seconds **Steam Link** should connect and you'll now see `steamdeck` as a valid computer

<img src="/images/steam-link-manual-pair-5.jpg" height="350">

10. Exit the **Settings** Gear and you should see a **Green Check** next to `steamdeck`
11. Select **Start Playing** to Connect your deck

<img src="/images/steam-link-online.jpg" height="350">

> You can use **Steam Link** to remotely manage your Steam Library, Adjust your Settings...

<img src="/images/steam-link-home.jpg" height="350">

> Or even tinker and work in Desktop Mode

<img src="/images/steam-link-desktop.jpg" height="350">

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="steamlink-windowed-mode-anchor"></a>
<BR><BR>

## Use Steam Link in Windowed Mode
---

> By default Steam Link opens in FullScreen mode, which is useful if you're playing games remotely, but if you're just wanting to manage your device remotely you might want to just launch this in a window

1. On your Windows PC
2. Open the Folder `C:\Program Files (x86)\Steam Link`
3. <kbd>Right Click</kbd> on `SteamLink.exe`
4. Go to **Send To** > **Desktop (Create Shortcut)**

<img src="/images/steam-link-create-shortcut.jpg" height="350">

5. Go to your **Desktop** and <kbd>Right Click</kbd> on the newly created Shortcut
6. Go to **Properties** and Paste the string below into the **Target** Field, Replacing the current contents

```
"C:\Program Files (x86)\Steam Link\SteamLink.exe" --windowed
```

<img src="/images/steam-link-edit-shortcut.jpg" height="350">

7. Click <kbd>Apply</kdb> Then <kbd>OK</kdb>
8. Now when you <kbd>Double-Click</kdb> this Shortcut, **Steam Link** should launch in Windowed Mode

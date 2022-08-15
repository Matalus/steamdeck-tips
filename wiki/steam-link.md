# Steam Link 

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="setting-up-steamlink-anchor"></a>
<BR><BR>

## Setting up Steam Link
---

> Setting up Steam Link will Allow you to control your Steam Deck remotely from your PC with a fullsize Keyboard and Mouse
> This is really useful for tinkering and troubleshooting non-steam games

<img src="/images/steam-link-example.jpg" height="400">

<!-- ![/images/steam-link-example.jpg](/images/steam-link-example.jpg|width=100) -->

1. Download **Steam Link** for Windows from https://store.steampowered.com/remoteplay#anywhere_how
2. Click the **For Windows** link and allow the file to download

![/images/steam-link-for-windows.jpg](/images/steam-link-for-windows.jpg)

3. **Unzip** `SteamLink.zip` into a directory
4. Open the Directory you unzipped `SteamLink.zip` into
5. <kbd>Right Click</kbd> `SteamLink.msi` and select **Install**
6. Follow the On-Screen prompts and click **Next** as prompted, you may have to click **Yes** on a UAC Prompt

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="steamlink-pairing"></a>
<BR><BR>

## Steam Link Pairing
---

> Generally Steam Link is very simple to setup, but it can be confusing if everything doesn't connect automatically
> The Instruction included are for manually pairing your Steam Deck

1. Open **Steam Link** and Click on the **Settings** Gear

![/images/steam-link-for-windows.jpg](/images/steam-link-manual-pair-1.jpg)

2. Goto **Computer**

![/images/steam-link-manual-pair-2.jpg](/images/steam-link-manual-pair-2.jpg)

3. Goto **Other Computer**

![/images/steam-link-manual-pair-3.jpg](/images/steam-link-manual-pair-3.jpg)

4. Note the `PIN` 

![/images/steam-link-manual-pair-4.jpg](/images/steam-link-manual-pair-4.jpg)

5. On your **Steam Deck** Press the <kbd>STEAM</kbd> button
6. Goto **Settings** > **Remote Play**
7. Press **Pair Steam Link**

![/images/steamdeck-manual-pair.jpg](/images/steamdeck-manual-pair.jpg)

8. Enter the `PIN` from Step 4.

![/images/steamdeck-manual-pair-2.jpg](/images/steamdeck-manual-pair-2.jpg)

9. After a few seconds **Steam Link** should connect and you'll now see `steamdeck` as a valid computer

![/images/steam-link-manual-pair-5.jpg](/images/steam-link-manual-pair-5.jpg)

10. Exit the **Settings** Gear and you should see a **Green Check** next to `steamdeck`
11. Select **Start Playing** to Connect your deck

![/images/steam-link-online.jpg](/images/steam-link-online.jpg)

> You can use **Steam Link** to remotely manage your Steam Library, Adjust your Settings...

![/images/steamdeck-manual-pair-2.jpg](/images/steam-link-home.jpg)

> Or even tinker and work in Desktop Mode

![/images/steamdeck-manual-pair-2.jpg](/images/steam-link-desktop.jpg)

<!-- ANCHOR BLOCK: needs to be 2 BR above the actual header due to GitHubs frame -->
<a name="steamlink-windowed-mode-anchor"></a>
<BR><BR>

## Use Steam Link in Windowed Mode
---

> By default Steam Link opens in FullScreen mode, which is useful if you're playing games remotely, but if you're just wanting to manage your device remotely you might want to just launch this in a window

```
"C:\Program Files (x86)\Steam Link\SteamLink.exe" --windowed
```
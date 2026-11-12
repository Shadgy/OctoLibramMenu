# OctoLibramMenu 0.3.3

A compact paladin libram menu for **OctoWoW, WoW 1.12.1 / Interface 11200**. All addon messages, tooltips, settings and binding labels are in English.

## Install or update

In **Octo Launcher → Addons → +**, add this custom Git addon:

`https://github.com/Shadgy/OctoLibramMenu`

For manual installation, extract the release ZIP so that `Interface/AddOns/OctoLibramMenu/OctoLibramMenu.toc` exists. Replace the addon files when updating; keep your `WTF` folder and saved settings. **Restart the game after updating** to load the new addon files and audio assets.

The addon loads its UI only for paladins. Existing position, scale, visibility and menu settings are preserved. Sound is disabled by default; no default keys are assigned.

## Libram menu and Final Judgement

- Hover the equipped libram to open the bag-libram menu; click an item to equip it in slot 18.
- Right-click the equipped icon to keep the menu open or return to hover mode.
- A living, attackable target at **35% health or lower** highlights **Libram of Final Judgement**. A separate gold shortcut stays available even when the hover menu is closed.
- If Final Judgement is already equipped, the equipped button glows instead. Above 35%, on a friendly/dead/missing target, or without the item in your bags/equipment, the visual reminder clears.
- The panel and visual reminder must be enabled for the shortcut to appear. The bank is not scanned.
- Alt, Ctrl **or** Shift + left-drag moves the unlocked panel. Ordinary Shift-click with the chat edit box open still inserts an item link.

Equipment changes require your click or key press. The addon never rotates or equips librams automatically. Normal client/server restrictions and cooldowns still apply.

## Settings

Open **ESC → LibramMenu**, right-click the minimap button, or type `/olm`.

**General** controls panel visibility, **Librams always shown**, **Locked**, minimap visibility, tooltips, visual highlighting, scale, columns, direction and reset position. Locked prevents moving the panel and minimap icon. Left-click the minimap icon to show/hide the panel; drag it around the minimap while unlocked. pfUI may collect it into its own addon-button panel.

### Key bindings

The **Key bindings** tab offers:

- **Four configurable libram slots:** select a carried/equipped libram with the arrows, click its key button, then press a key or an Alt/Ctrl/Shift combination.
- **Equip Final Judgement:** a dedicated direct shortcut.
- **Cycle: Final Judgement ↔ selected libram:** choose the second libram and assign a key. Each press makes one swap. If Final Judgement is equipped, the partner is selected; otherwise Final Judgement is selected. Both items must be carried/equipped. A pending or rejected swap does not advance a hidden cycle counter.
- **Pin / unpin libram menu:** change between persistent and hover mode.

**Escape** cancels key capture. **Backspace** clears that action while capturing; each row also has **Clear**. Existing shortcuts assigned to another game action are refused, so they cannot be overwritten accidentally. Keys use the game's currently active account or character binding set. Libram selections are saved per character. Closing the dialog or changing tabs ends key capture.

The same actions are available under **OctoLibramMenu** in the game's native Key Bindings menu. Missing configured items remain listed and produce a message when you try to equip them.

### Sound

The **Sound** tab includes **Play an alert sound**, **Bosses only**, eleven short recordings, and **Play sample**. **LoL - Retreat Ping** is the default. Other choices are **Metal Gear - Alert**, **Mortal Kombat - Finish Him**, **Mario - Coin**, **Sonic - Ring**, **Vine Boom**, **Windows XP - Error**, **Law and Order - Dun Dun**, **Air Horn**, **Boxing Arena Gong** and **Warning Siren**. The picker shows all eleven in two columns.

Each recording is shorter than three seconds and uses mono 16-bit PCM WAV for the older client. See [sound sources, ownership and attribution](Sounds/SOURCES.md). Retired Kenney sound selections migrate to the new LoL default; position, keys, sound enable/boss-only switches and other preferences are preserved. Once you select one of the new sounds, it remains selected on later logins. Sound remains disabled on a fresh installation until you enable it.

Use **Alert volume** to adjust the selected ping from **0% to 200%** in 10% steps. **100%** keeps the previous level and is the default for existing settings. **0%** mutes the automatic alert and its sample. The volume is saved per character and applies to both the alert and **Play sample**. The game's volume settings still apply.

A ping plays once when a living hostile target enters **≤35% HP**, including when a newly selected target is already below the threshold. Repeated HP events and timer updates do not repeat it. Healing above 35% rearms the next crossing. Changing sound settings while the same target remains below the threshold does not replay the alert; use Play sample to preview it.

Sound is independent of panel visibility, the visual-highlighting switch and Final Judgement ownership. It is a health cue and does not equip anything. Game sound settings still apply.

**Bosses only** uses [105 bosses and phase units](BOSSES.md) from the supplied Octo raid reference, plus the client's `worldboss` classification. The auxiliary Chess Knight is excluded. NPC IDs are preferred when a compatible GUID API is available, with enUS boss names as a fallback. The generic Chess name **King** is excluded from name-only matching; players and player-controlled pets are excluded. This list covers the supplied raid/world-boss reference, not every dungeon boss.

## Commands

`/olm` opens settings; `/olm help` lists commands.

`/olm show`, `/olm hide`, `/olm lock`, `/olm unlock`, `/olm keepopen`, `/olm minimap`, `/olm left`, `/olm right`, `/olm scale 1.2`, `/olm columns 4`, `/olm reset`.

`/olm final` manually requests Final Judgement, regardless of target health. `/olm cycle` uses the configured two-item cycle.

## Compatibility and reporting

The addon targets Vanilla Lua 5.0 and requires no external addon library. Item-name fallback targets the enUS client. Nampower/SuperWoW GUID and health APIs are optional; standard client APIs are used when available extensions do not provide valid values.

Report reproducible problems through the repository's Issues, including the addon version and the steps to reproduce. Keep credentials and private SavedVariables out of public reports.

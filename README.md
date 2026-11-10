# OctoLibramMenu

A compact libram menu for paladins on **OctoWoW, WoW 1.12.1 / Interface 11200**. Inspired by the hover-and-click workflow of TrinketMenu.

## Install with Octo Launcher

1. Open the launcher's **Addons** tab.
2. Use **+** to add a custom Git addon.
3. Paste this repository URL and choose **Install**:

   `https://github.com/Shadgy/OctoLibramMenu`

Restart the game after the first installation. For manual installation, extract the release ZIP so that `Interface/AddOns/OctoLibramMenu/OctoLibramMenu.toc` exists.

## Features

- Equipped libram button and a hover menu of librams carried in your bags.
- Click a libram to equip it in slot 18.
- **Libram of Final Judgement reminder at target health ≤35%.** A separate gold-highlighted shortcut appears beside the equipped button, **even when the hover menu is closed**. If Final Judgement is already equipped, the equipped button glows instead.
- Settings through **ESC → LibramMenu**, right-clicking the minimap button, or `/olm`.
- Persistent menu, position lock, scale, columns, direction, tooltips, minimap visibility and reminder toggle.
- Per-character settings preserved across updates.

The reminder requires a **living, attackable target**, Final Judgement in your bags or equipped, and the panel and reminder enabled. It clears above 35%, on target loss, on a friendly target, or when the target dies. The threshold includes exactly 35%; it does not round a higher health percentage down.

The addon never changes equipment automatically. Click the highlighted shortcut or use its key binding to request a swap. Normal client/server equipment restrictions and cooldowns apply.

## Controls

| Action | Result |
|---|---|
| Hover equipped libram | Open the bag-libram menu |
| Click a menu libram or Final Judgement shortcut | Equip that libram |
| Right-click equipped libram | Keep menu open / return to hover mode |
| Alt, Ctrl **or** Shift + left-drag | Move the panel while unlocked |
| Shift-click with chat edit box open | Insert an item link |
| Left-click minimap button | Show / hide the libram panel |
| Right-click minimap button | Open settings |
| Drag minimap button | Move it while unlocked |

The **Locked** setting blocks panel and minimap movement. pfUI may collect the minimap button into its own addon-button panel.

## Commands and key bindings

`/olm` opens settings. `/olm help` lists commands.

`/olm show`, `/olm hide`, `/olm lock`, `/olm unlock`, `/olm keepopen`, `/olm minimap`, `/olm left`, `/olm right`, `/olm scale 1.2`, `/olm columns 4`, `/olm reset`.

`/olm final` manually equips Final Judgement, regardless of target health. The game's key-binding menu includes **OctoLibramMenu** actions for this swap and for keeping the menu open.

## Compatibility and checks

Version **0.2.1** uses the Vanilla Lua 5.0 API and requires no external addon library. It loads its UI only for paladins. The current item-name filtering targets the enUS client. Nampower health fields are optional; standard target health APIs are the fallback.

Automated checks cover the exact health boundary, closed-menu alert visibility, target changes, inventory changes, movement modifiers, settings, and manual-swap safeguards. Client rendering and server equipment acceptance are distinct checks; combat swaps remain subject to the server.

Report reproducible problems in this repository's **Issues**, including the addon version, what you expected, and what happened. Do not include account credentials or private SavedVariables files.

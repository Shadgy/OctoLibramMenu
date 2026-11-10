# Changelog

## 0.3.2

- Replace the active Kenney picker with eleven recognizable game, pop-culture and raid-alert recordings.
- Use LoL - Retreat Ping as the default, with Metal Gear, Finish Him, Mario, Sonic, Vine Boom, Windows XP, Law and Order, Air Horn, Boxing Arena Gong and Warning Siren as alternatives.
- Migrate retired sound IDs to LoL while preserving position, key bindings, sound enable/boss-only switches and all other character preferences. Current choices persist across later logins.
- Show all eleven choices in two columns. Play sample remains an explicit action.
- Bundle PCM16 mono 22050 Hz WAVs, each under three seconds, with bounded sample peaks and smooth edges. The default LoL recording keeps its full 0.9-second decay.
- Add source, ownership and attribution notices. Retain legacy Kenney files and their notice for compatibility with existing addon folders.
- Restart the game after updating to load the new audio files.

## 0.3.1

- Replace the three synthesized cues with ten short cues from Kenney Interface Sounds (CC0).
- Add Glass ping, Soft pluck, Glass bell, Bong, Bright glass, Pluck, Confirmation, Confirmation 2, Question and Select.
- Show all ten choices in a two-column picker above the sound selector.
- Bundle 22,050 Hz mono 16-bit PCM WAVs, with matched whole-cue RMS levels and a sample-peak ceiling.
- Preserve the original three saved sound IDs and all other character preferences.
- Include the author's license notice and the exact original-file mapping.
- Restart the game after updating to load the new audio assets.

## 0.3.0

- Use English throughout messages, tooltips, settings and binding descriptions.
- Add four selectable libram shortcuts and a Final Judgement / selected libram cycle.
- Assign and clear shortcuts in the settings dialog without silently replacing other game controls.
- Add optional Ping, Soft ping and Bell health alerts, with previews and a bosses-only filter.
- Include 105 boss/phase-unit entries from the supplied raid reference.
- Split settings into General, Key bindings and Sound tabs.
- Preserve existing character settings and leave new sounds/keys disabled or unassigned by default.
- Restart the game after updating; this version adds Lua modules and native binding actions.

## 0.2.1

- Move the unlocked panel with Alt, Ctrl or Shift + left-drag.
- Prevent a drag release from also activating an item or inserting a chat link.
- Preserve ordinary Shift-click item links.

## 0.2.0

- Add settings through the ESC menu and minimap button.
- Add persistent-menu, position lock, scale, columns, direction and visibility controls.
- Respect pfUI's minimap-button collection.

## 0.1.0

- Initial libram flyout and manual slot-18 swapping.
- Final Judgement reminder at target health ≤35%, including a shortcut when the menu is closed.

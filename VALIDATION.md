# Validation

Checked on 2026-11-10.

## 0.3.1 checks

- **72 behavioral cases passed:** 30 core, 9 bindings and 33 UI integration cases. Lua syntax and the project's Lua 5.0 / Vanilla checks passed.
- Ten unique sound IDs and file paths, exact preview dispatch for all ten, and retention of the three previous saved IDs and other preferences were checked.
- All ten menu buttons select without playing a sound; Play sample remains an explicit action. Threshold, boss-only and no-repeat behavior still pass.
- The two-column picker was rendered from actual frame geometry and visually reviewed. Tests also check all buttons fit inside the dialog without overlapping each other, the selector or footer.
- All ten audio files match the conversion manifest and are distinct, non-silent PCM16 mono 22,050 Hz WAVs, 0.100–0.692 seconds long. Whole-cue RMS is -22 dBFS; sample peaks remain at or below -3 dBFS.
- The downloaded upstream ZIP checksum and its CC0 author notice were checked. The release includes the notice and original-file mapping in `Sounds`.

These are offline behavior, asset and layout checks. In-game playback and a subjective listening review of the new cues have not been verified by these checks. Use Sound → Play sample to audition the cues in your client.

## 0.3.0 automated checks

- 28 core behavioral cases, 9 binding cases and 31 UI integration cases passed: **68 total**.
- Lua syntax and the project's Lua 5.0 / Vanilla API checks passed.
- Exact 35% qualifies; 35.0001% does not.
- The shortcut remains visible with the flyout closed, including on login, target changes and inventory changes.
- Missing Final Judgement, friendly/dead/missing targets and disabled visibility/reminder settings are covered.
- Alt/Ctrl/Shift movement, settings, minimap interaction and manual equipment-swap safeguards are covered.
- Sound tests cover one ping per crossing/target entry, silent repeated updates, settings changes and boss-only identification, including player/pet exclusions.
- Key tests cover explicit direct swaps, confirmed-state cycling, missing items, conflict refusal, active-set saving, rollback failures and keyboard-capture cleanup.
- All three settings tabs were rendered from actual frame geometry and visually reviewed. The three bundled WAVs were checked as PCM16 mono 22050 Hz audio.

The UI cases execute the addon modules against a simulated WoW API. They are distinct from the live check below.

The new 0.3.0 key capture and sound features were checked with simulated native APIs and local compatibility review; a full in-game acceptance check of these new features remains separate from those tests.

## Previous live Octo client check

A living hostile target had **26/194 HP** (approximately 13.4%, displayed as 14% by the client).

1. Confirmed the highlighted Final Judgement shortcut was present.
2. Disabled the persistent flyout. A local diagnostic showed `menu=nil`, `quick=1`; the gold shortcut remained visible.
3. Clicked the shortcut during combat. The character's relic slot changed to **Libram of Final Judgement**, the shortcut disappeared, and the equipped button glowed.
4. Restored the previous libram and persistent-menu preference.

The loaded client reported 0.2.0 during this check. Later versions retain the visual health/reminder/manual-equip workflow and add the changes documented in the changelog. The exact 35% boundary was checked in the automated suite, rather than by changing a live target to exactly that value.

## Package and launcher

The public repository is named `OctoLibramMenu`, with `OctoLibramMenu.toc` at its root. This follows the official Octo Launcher's custom Git-addon folder and TOC lookup behavior. The release ZIP has one top-level `OctoLibramMenu` folder. Runtime files match the audited source.

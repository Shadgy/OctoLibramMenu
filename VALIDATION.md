# Validation

Checked on 2026-11-10.

## 0.3.3 checks

- **78 behavioral cases passed** on 2026-11-12, covering 35 core, 9 binding and 34 UI cases. Lua syntax and Vanilla compatibility checks passed.
- The volume slider preserves saved levels, starts existing settings at 100%, and stays silent while it is moved. Automatic playback and **Play sample** use the selected level. Tests cover mute, a new health threshold event after adjustment, and selection of the matching WAV.
- The Sound tab layout was rendered and checked with all eleven choices visible. The volume slider, sample button and footer fit.
- All 209 gain variants preserve the source WAV format and duration. Measured RMS rises at each step for every cue and the peak stays below full scale. The 100% level uses the original WAVs.

The 0.3.3 checks used simulated game APIs and measured WAV output. The live-client results below are from 0.3.2.

## 0.3.2 checks

- **74 behavioral cases passed:** 32 core, 9 bindings and 33 UI integration cases. Lua syntax and the project's Lua 5.0 / Vanilla checks passed.
- All eleven unique IDs and exact preview paths are covered. Retired Kenney choices and invalid/missing IDs migrate to LoL; all other preferences remain intact. Every new selection survives a later login.
- All eleven buttons select silently until Play sample is clicked. Existing 35% threshold, boss filtering and no-repeat behavior pass.
- The two-column, six-row picker was rendered from actual frame geometry and visually checked with its final Retreat Ping label. All options fit inside the dialog and clear the selector, footer and Close button.
- Eleven source hashes and eleven converted WAV hashes match the recorded manifest. Active recordings are distinct, non-silent PCM16 mono 22050 Hz WAVs, 0.855–2.900 seconds long; LoL is 0.900 seconds. Peaks are at or below -3 dBFS. Waveform edges return to zero; short tail fades avoid discontinuities.
- The package retains ten legacy Kenney WAVs; they are not active menu options. New source, ownership and three SharedMedia CC BY 3.0 author notices are included. This is provenance documentation, not a legal clearance opinion for the game/pop-culture recordings.

These behavior, file and layout checks were followed by the live-client verification below. Restart the client after updating and use Sound → Play sample to audition the recordings.

## 0.3.2 live Octo client check

Checked on 2026-11-10 with the client reporting version **0.3.2** and sound choice **LoL - Retreat Ping**.

- With the flyout open, selecting a living hostile target at **32/112 HP (28.6%)** triggered one automatic alert. The Final Judgement reminder was visibly highlighted.
- With the flyout closed, selecting a living hostile target at **12/132 HP (9.1%)** triggered one automatic alert. The separate highlighted Final Judgement shortcut remained visible while the flyout stayed closed.
- Both trials used the client's normal target-change event, rather than a manual sound preview. A temporary observer forwarded the original sound method and counted one call in each trial, with no repeated alert while the target remained below the threshold.
- System-output recordings independently matched the shipped LoL cue at the expected target-change times in both trials. This verifies playback in the captured output; it is not a subjective listening review of all eleven recordings.
- Installed files matched all **36 release-package files**. The installation had preserved all **3,313 checked settings files**. Live checks confirmed retained panel preferences, position and the existing cycle binding.
- The sound and persistent-menu switches used during testing were restored to their previous values. The live settings matched the pre-test snapshot, the original sound method was restored, and temporary test globals were cleared. Sound had previously been disabled and was left disabled; enable **Play an alert sound** to use the ping.

These live trials selected targets already below 35%; they did not exercise a live health transition through exactly 35%. The exact boundary and values immediately above it remain covered by automated tests. Bosses-only filtering was not tested against a live boss in this session. No runtime change was needed after the live check; version **0.3.2** remains the current build.

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

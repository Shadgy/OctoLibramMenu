# Validation

Checked on 2026-11-10.

## Automated checks

- 20 core behavioral cases and 26 UI integration cases passed.
- Lua syntax and the project's Lua 5.0 / Vanilla API checks passed.
- Exact 35% qualifies; 35.0001% does not.
- The shortcut remains visible with the flyout closed, including on login, target changes and inventory changes.
- Missing Final Judgement, friendly/dead/missing targets and disabled visibility/reminder settings are covered.
- Alt/Ctrl/Shift movement, settings, minimap interaction and manual equipment-swap safeguards are covered.

The UI cases execute the addon modules against a simulated WoW API. They are distinct from the live check below.

## Live Octo client check

A living hostile target had **26/194 HP** (approximately 13.4%, displayed as 14% by the client).

1. Confirmed the highlighted Final Judgement shortcut was present.
2. Disabled the persistent flyout. A local diagnostic showed `menu=nil`, `quick=1`; the gold shortcut remained visible.
3. Clicked the shortcut during combat. The character's relic slot changed to **Libram of Final Judgement**, the shortcut disappeared, and the equipped button glowed.
4. Restored the previous libram and persistent-menu preference.

The loaded client reported 0.2.0 during this check. The 0.2.1 release retains the same health/reminder/equip logic; its changes add Ctrl/Shift dragging and drag-release click protection. The exact 35% boundary was checked in the automated suite, rather than by changing a live target to exactly that value.

## Package and launcher

The public repository is named `OctoLibramMenu`, with `OctoLibramMenu.toc` at its root. This follows the official Octo Launcher's custom Git-addon folder and TOC lookup behavior. The release ZIP has one top-level `OctoLibramMenu` folder. Runtime files match the audited source.

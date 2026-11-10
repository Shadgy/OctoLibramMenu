# Sound sources

All ten alert cues are from **Interface Sounds 1.0**, created and distributed by **Kenney**.

- Author and download: https://kenney.nl/assets/interface-sounds
- License: **Creative Commons CC0 1.0 Universal**; https://creativecommons.org/publicdomain/zero/1.0/
- Original author notice: [LICENSE-Kenney.txt](LICENSE-Kenney.txt)
- Upstream ZIP SHA-256: `f2193d072726d6758a5f7871b2dcc54dcce0d5c35c6f0a62f92549b327c81232`
- Downloaded: 2026-11-10.

The OGG files were decoded, resampled to 22,050 Hz mono, saved as 16-bit PCM WAV and adjusted toward -22 dBFS whole-cue RMS, with a -3 dBFS sample-peak ceiling. No audio from another game or addon is included. Each cue is shorter than one second.

| Menu label | Bundled file | Original file inside the Kenney ZIP | Duration |
|---|---|---|---:|
| Glass ping | Ping.wav | Audio/glass_001.ogg | 0.276 s |
| Soft pluck | Soft.wav | Audio/pluck_001.ogg | 0.100 s |
| Glass bell | Bell.wav | Audio/glass_004.ogg | 0.692 s |
| Bong | Bong.wav | Audio/bong_001.ogg | 0.120 s |
| Bright glass | Glass.wav | Audio/glass_002.ogg | 0.122 s |
| Pluck | Pluck.wav | Audio/pluck_002.ogg | 0.162 s |
| Confirmation | Confirm.wav | Audio/confirmation_001.ogg | 0.290 s |
| Confirmation 2 | Confirm2.wav | Audio/confirmation_002.ogg | 0.539 s |
| Question | Question.wav | Audio/question_001.ogg | 0.491 s |
| Select | Select.wav | Audio/select_003.ogg | 0.380 s |

The first three saved sound IDs remain `PING`, `SOFT` and `BELL`, so upgrading from 0.3.0 preserves the selection while replacing its audio. The library license permits redistribution and modification; no additional addon or online download is needed to play these files.

# Sound sources — 0.3.2

The active picker contains eleven short alert recordings. **LoL - Retreat Ping** is the default. Original game and brand names identify the recordings and do not imply endorsement.

| Menu label | Bundled file | Source recording | Duration |
|---|---|---|---:|
| LoL - Retreat Ping | LoLDanger.wav | https://www.myinstants.com/en/instant/lol-ping-retreat-78907/ | 0.900 s |
| Metal Gear - Alert | MetalGear.wav | https://www.myinstants.com/en/instant/metal-gear-solid-alert/ | 1.115 s |
| Mortal Kombat - Finish Him | FinishHim.wav | https://www.myinstants.com/en/instant/finish-him/ | 2.102 s |
| Mario - Coin | MarioCoin.wav | https://www.myinstants.com/en/instant/mario-coin/ | 1.026 s |
| Sonic - Ring | SonicRing.wav | https://www.myinstants.com/en/instant/sonic-ring/ | 0.855 s |
| Vine Boom | VineBoom.wav | https://www.myinstants.com/en/instant/vine-boom-sound-70972/ | 1.190 s |
| Windows XP - Error | WindowsError.wav | https://www.myinstants.com/en/instant/windows-xp-error/ | 0.925 s |
| Law and Order - Dun Dun | DunDun.wav | https://www.myinstants.com/en/instant/law-and-order-dun-dun/ | 1.293 s |
| Air Horn | AirHorn.wav | https://github.com/WeakAuras/WeakAuras_SharedMedia/blob/main/Sounds/AirHorn.ogg | 1.899 s |
| Boxing Arena Gong | BoxingGong.wav | https://github.com/WeakAuras/WeakAuras_SharedMedia/blob/main/Sounds/BoxingArenaSound.ogg | 1.744 s |
| Warning Siren | WarningSiren.wav | https://github.com/WeakAuras/WeakAuras_SharedMedia/blob/main/Sounds/WarningSiren.ogg | 2.900 s |

## Audio preparation

Sources were decoded to mono, resampled to 22,050 Hz and saved as 16-bit PCM WAV for the older WoW client. Leading/trailing silence was trimmed, except for the already-short default LoL recording, which keeps its full natural decay. Levels were adjusted toward -20 dBFS whole-cue RMS with a -3 dBFS sample-peak ceiling; brief onset and tail fades avoid discontinuities. Warning Siren was shortened to 2.9 seconds with a tail fade. The other recordings were not length-limited. There is no streaming or download during gameplay.

## Ownership and attribution

See [NOTICE.txt](NOTICE.txt) for third-party recording notices and [ATTRIBUTION-SharedMedia.txt](ATTRIBUTION-SharedMedia.txt) for the three CC BY 3.0 recordings and their authors. The source pages identify the copies used; their availability does not itself establish an open-content license.

The ten previous Kenney WAVs remain in the package for compatibility with existing addon folders. They are no longer in the active picker. They come from [Kenney Interface Sounds 1.0](https://kenney.nl/assets/interface-sounds), under CC0; the author's notice is retained in [LICENSE-Kenney.txt](LICENSE-Kenney.txt). Existing Kenney choice IDs migrate to the new LoL default while all other character preferences are kept. Newly selected sounds remain selected across later logins.

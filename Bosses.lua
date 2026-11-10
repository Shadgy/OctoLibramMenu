-- Raid bosses and boss-phase units from the approved OctoWoW raid reference.
-- Source roster dated 2026-11-08; 106 NPC rows, excluding auxiliary Chess Knight.
-- English names provide a fallback when this Vanilla client has no NPC GUID API.
OctoLibramMenuBosses = {
    count = 105,
    sourceCount = 106,
    sourceDate = "2026-11-08",
    source = "Octo raid reference, 2026-11-08; see BOSSES.md",
    names = {
        -- Molten Core
        ["Lucifron"] = true,
        ["Magmadar"] = true,
        ["Garr"] = true,
        ["Baron Geddon"] = true,
        ["Shazzrah"] = true,
        ["Sulfuron Harbinger"] = true,
        ["Golemagg the Incinerator"] = true,
        ["Majordomo Executus"] = true,
        ["Ragnaros"] = true,
        ["Incindis"] = true,
        ["Basalthar"] = true,
        ["Smoldaris"] = true,
        ["Sorcerer-Thane Thaurissan"] = true,
        -- Onyxia
        ["Onyxia"] = true,
        ["Broodcommander Axelus"] = true,
        -- Blackwing Lair
        ["Razorgore the Untamed"] = true,
        ["Vaelastrasz the Corrupt"] = true,
        ["Broodlord Lashlayer"] = true,
        ["Firemaw"] = true,
        ["Ebonroc"] = true,
        ["Flamegor"] = true,
        ["Chromaggus"] = true,
        ["Nefarian"] = true,
        ["Ezzel Darkbrewer"] = true,
        -- Zul'Gurub
        ["High Priestess Jeklik"] = true,
        ["High Priest Venoxis"] = true,
        ["High Priestess Mar'li"] = true,
        ["Bloodlord Mandokir"] = true,
        ["High Priest Thekal"] = true,
        ["High Priestess Arlokk"] = true,
        ["Jin'do the Hexxer"] = true,
        ["Hakkar"] = true,
        ["Gahz'ranka"] = true,
        ["Gri'lek"] = true,
        ["Hazza'rah"] = true,
        ["Renataki"] = true,
        ["Wushoolay"] = true,
        -- Lower Karazhan Halls
        ["Brood Queen Araxxna"] = true,
        ["Lord Blackwald II"] = true,
        ["Clawlord Howlfang"] = true,
        ["Grizikil"] = true,
        ["Moroes"] = true,
        ["Master Blacksmith Rolfen"] = true,
        -- Emerald Sanctum
        ["Erennius"] = true,
        ["Solnius"] = true,
        -- Ruins of Ahn'Qiraj
        ["Kurinnaxx"] = true,
        ["General Rajaxx"] = true,
        ["Moam"] = true,
        ["Buru the Gorger"] = true,
        ["Ayamiss the Hunter"] = true,
        ["Ossirian the Unscarred"] = true,
        -- Temple of Ahn'Qiraj
        ["The Prophet Skeram"] = true,
        ["Princess Yauj"] = true,
        ["Vem"] = true,
        ["Lord Kri"] = true,
        ["Battleguard Sartura"] = true,
        ["Fankriss the Unyielding"] = true,
        ["Viscidus"] = true,
        ["Princess Huhuran"] = true,
        ["Emperor Vek'lor"] = true,
        ["Emperor Vek'nilash"] = true,
        ["Ouro"] = true,
        ["Eye of C'Thun"] = true,
        ["C'Thun"] = true,
        -- Naxxramas
        ["Anub'Rekhan"] = true,
        ["Grand Widow Faerlina"] = true,
        ["Maexxna"] = true,
        ["Noth the Plaguebringer"] = true,
        ["Heigan the Unclean"] = true,
        ["Loatheb"] = true,
        ["Instructor Razuvious"] = true,
        ["Gothik the Harvester"] = true,
        ["Highlord Mograine"] = true,
        ["Sir Zeliek"] = true,
        ["Thane Korth'azz"] = true,
        ["Lady Blaumeux"] = true,
        ["Patchwerk"] = true,
        ["Grobbulus"] = true,
        ["Gluth"] = true,
        ["Thaddius"] = true,
        ["Sapphiron"] = true,
        ["Kel'Thuzad"] = true,
        -- Tower of Karazhan
        ["Keeper Gnarlmoon"] = true,
        ["Ley-Watcher Incantagos"] = true,
        ["Anomalus"] = true,
        ["Echo of Medivh"] = true,
        ["King"] = true,
        ["Sanv Tas'dal"] = true,
        ["Rupturan the Broken"] = true,
        ["Kruul"] = true,
        ["Mephistroth"] = true,
        ["Echo of Sargeras"] = true,
        -- World Bosses
        ["Azuregos"] = true,
        ["Lord Kazzak"] = true,
        ["Ysondre"] = true,
        ["Lethon"] = true,
        ["Emeriss"] = true,
        ["Taerar"] = true,
        ["Concavius"] = true,
        ["Dark Reaver of Karazhan"] = true,
        ["Nerubian Overseer"] = true,
        ["Ostarius"] = true,
        ["Cla'ckora"] = true,
        ["Father Lycan"] = true,
        ["Moo"] = true,
    },
    ids = {
        -- Molten Core
        [12118] = true, -- Lucifron
        [11982] = true, -- Magmadar
        [12057] = true, -- Garr
        [12056] = true, -- Baron Geddon
        [12264] = true, -- Shazzrah
        [12098] = true, -- Sulfuron Harbinger
        [11988] = true, -- Golemagg the Incinerator
        [12018] = true, -- Majordomo Executus
        [11502] = true, -- Ragnaros
        [52145] = true, -- Incindis
        [65020] = true, -- Basalthar
        [65021] = true, -- Smoldaris
        [57642] = true, -- Sorcerer-Thane Thaurissan
        -- Onyxia
        [10184] = true, -- Onyxia
        [49018] = true, -- Broodcommander Axelus
        -- Blackwing Lair
        [12435] = true, -- Razorgore the Untamed
        [13020] = true, -- Vaelastrasz the Corrupt
        [12017] = true, -- Broodlord Lashlayer
        [11983] = true, -- Firemaw
        [14601] = true, -- Ebonroc
        [11981] = true, -- Flamegor
        [14020] = true, -- Chromaggus
        [11583] = true, -- Nefarian
        [65148] = true, -- Ezzel Darkbrewer
        -- Zul'Gurub
        [14517] = true, -- High Priestess Jeklik
        [14507] = true, -- High Priest Venoxis
        [14510] = true, -- High Priestess Mar'li
        [11382] = true, -- Bloodlord Mandokir
        [14509] = true, -- High Priest Thekal
        [14515] = true, -- High Priestess Arlokk
        [11380] = true, -- Jin'do the Hexxer
        [14834] = true, -- Hakkar
        [15114] = true, -- Gahz'ranka
        [15082] = true, -- Gri'lek
        [15083] = true, -- Hazza'rah
        [15084] = true, -- Renataki
        [15085] = true, -- Wushoolay
        -- Lower Karazhan Halls
        [61221] = true, -- Brood Queen Araxxna
        [61222] = true, -- Lord Blackwald II
        [61223] = true, -- Clawlord Howlfang
        [61224] = true, -- Grizikil
        [61225] = true, -- Moroes
        [61319] = true, -- Master Blacksmith Rolfen
        -- Emerald Sanctum
        [60747] = true, -- Erennius
        [60748] = true, -- Solnius
        -- Ruins of Ahn'Qiraj
        [15348] = true, -- Kurinnaxx
        [15341] = true, -- General Rajaxx
        [15340] = true, -- Moam
        [15370] = true, -- Buru the Gorger
        [15369] = true, -- Ayamiss the Hunter
        [15339] = true, -- Ossirian the Unscarred
        -- Temple of Ahn'Qiraj
        [15263] = true, -- The Prophet Skeram
        [15543] = true, -- Princess Yauj
        [15544] = true, -- Vem
        [15511] = true, -- Lord Kri
        [15516] = true, -- Battleguard Sartura
        [15510] = true, -- Fankriss the Unyielding
        [15299] = true, -- Viscidus
        [15509] = true, -- Princess Huhuran
        [15276] = true, -- Emperor Vek'lor
        [15275] = true, -- Emperor Vek'nilash
        [15517] = true, -- Ouro
        [15589] = true, -- Eye of C'Thun
        [15727] = true, -- C'Thun
        -- Naxxramas
        [15956] = true, -- Anub'Rekhan
        [15953] = true, -- Grand Widow Faerlina
        [15952] = true, -- Maexxna
        [15954] = true, -- Noth the Plaguebringer
        [15936] = true, -- Heigan the Unclean
        [16011] = true, -- Loatheb
        [16061] = true, -- Instructor Razuvious
        [16060] = true, -- Gothik the Harvester
        [16062] = true, -- Highlord Mograine
        [16063] = true, -- Sir Zeliek
        [16064] = true, -- Thane Korth'azz
        [16065] = true, -- Lady Blaumeux
        [16028] = true, -- Patchwerk
        [15931] = true, -- Grobbulus
        [15932] = true, -- Gluth
        [15928] = true, -- Thaddius
        [15989] = true, -- Sapphiron
        [15990] = true, -- Kel'Thuzad
        -- Tower of Karazhan
        [61939] = true, -- Keeper Gnarlmoon
        [61946] = true, -- Ley-Watcher Incantagos
        [61951] = true, -- Anomalus
        [61958] = true, -- Echo of Medivh
        [59967] = true, -- King
        [59981] = true, -- Sanv Tas'dal
        [59961] = true, -- Rupturan the Broken
        [59991] = true, -- Kruul
        [93333] = true, -- Mephistroth
        [60063] = true, -- Echo of Sargeras
        -- World Bosses
        [6109] = true, -- Azuregos
        [12397] = true, -- Lord Kazzak
        [14887] = true, -- Ysondre
        [14888] = true, -- Lethon
        [14889] = true, -- Emeriss
        [14890] = true, -- Taerar
        [92213] = true, -- Concavius
        [80936] = true, -- Dark Reaver of Karazhan
        [16184] = true, -- Nerubian Overseer
        [80935] = true, -- Ostarius
        [59963] = true, -- Cla'ckora
        [62059] = true, -- Father Lycan
        [91799] = true, -- Moo
    }
}

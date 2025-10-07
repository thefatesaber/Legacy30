-- Configuration data for Legacy30 addon
local _, ns = ...

-- Group size restrictions
ns.GroupLimits = {
    minimum = 1,
    maximum = 3
}

-- Mob count thresholds for 100% completion
-- Run this command in-game to get Instance ID: /run print(select(8, GetInstanceInfo()))
ns.MobThresholds = {
    [48] = 80,    -- This is Blackfathom Deeps
    [230] = 474,  -- This is Blackrock Depths
    [36] = 60,    -- This is Deadmines
    [429] = 205,  -- This is Dire Maul
    [90] = 123,   -- This is Gnomeregan
    [229] = 148,  -- This is Lower Blackrock Spire
    [349] = 100,  -- This is Maraudon
    [389] = 46,   -- This is Ragefire Chasm
    [129] = 46,   -- This is Razorfen Downs
    [47] = 62,    -- This is Razorfen Kraul
    [1001] = 46,  -- This is Scarlet Halls
    [1004] = 72,  -- This is Scarlet Monastery
    [1007] = 94,  -- This is Scholomance
    [33] = 100,   -- This is Shadowfang Keep
    [329] = 118,  -- This is Stratholme
    [34] = 55,    -- This is The Stockade
    [109] = 42,   -- This is The Temple of Atal'hakkar
    [70] = 84,    -- This is Uldaman
    [43] = 141,   -- This is Wailing Caverns
    [209] = 199,  -- This is Zul'Farrak
    [558] = 46,   -- This is Auchenai Crypts
    [543] = 80,   -- This is Hellfire Ramparts
    [585] = 74,   -- This is Magisters' Terrace
    [557] = 83,   -- This is Mana-Tombs
    [560] = 102,  -- This is Old Hillsbrad Foothills
    [556] = 71,   -- This is Sethekk Halls
    [555] = 112,  -- This is Shadow Labyrinth
    [552] = 38,   -- This is The Arcatraz
    [269] = 11,   -- This is The Black Morass
    [542] = 94,   -- This is The Blood Furnace
    [553] = 89,   -- This is The Botanica
    [554] = 73,   -- This is The Mechanar
    [540] = 81,   -- This is The Shattered Halls
    [547] = 98,   -- This is The Slave Pens
    [545] = 86,   -- This is The Steamvault
    [546] = 114,  -- This is The Underbog
    [619] = 126,  -- This is Ahn'kahet: The Old Kingdom
    [601] = 17,   -- This is Azjol-Nerub
    [600] = 57,   -- This is Drak'Tharon Keep
    [604] = 49,   -- This is Gundrak
    [602] = 87,   -- This is Halls of Lightning
    [668] = 30,   -- This is Halls of Reflection
    [599] = 69,   -- This is Halls of Stone
    [658] = 90,   -- This is Pit of Saron
    [595] = 42,   -- This is The Culling of Stratholme
    [632] = 31,   -- This is The Forge of Souls
    [576] = 168,  -- This is The Nexus
    [578] = 40,   -- This is The Oculus
    [0] = 0,      -- This is The Violet Hold
    [650] = 5,    -- This is Trial of the Champion
    [574] = 54,   -- This is Utgarde Keep
    [575] = 62,   -- This is Utgarde Pinnacle
    [645] = 102,  -- This is Blackrock Caverns
    [938] = 100,  -- This is End Time
    [670] = 61,   -- This is Grim Batol
    [644] = 193,  -- This is Halls of Origination
    [940] = 100,  -- This is Hour of Twilight
    [755] = 54,   -- This is Lost City of the Tol'vir
    [725] = 81,   -- This is The Stonecore
    [657] = 49,   -- This is The Vortex Pinnacle
    [643] = 78,   -- This is Throne of the Tides
    [939] = 100,  -- This is Well of Eternity
    [568] = 100,  -- This is Zul'Aman
    [859] = 100,  -- This is Zul'Gurub
    [962] = 26,   -- This is Gate of the Setting Sun
    [994] = 54,   -- This is Mogu'shan Palace
    [959] = 88,   -- This is Shado-Pan Monastery
    [1011] = 125, -- This is Siege of Niuzao Temple
    [961] = 35,   -- This is Stormstout Brewery
    [960] = 35,   -- This is Temple of the Jade Serpent
    [1182] = 52,  -- This is Auchindoun
    [1175] = 54,  -- This is Bloodmaul Slag Mines
    [1208] = 100, -- This is Grimrail Depot
    [1195] = 102, -- This is Iron Docks
    [1176] = 124, -- This is Shadowmoon Burial Grounds
    [1209] = 45,  -- This is Skyreach
    [1279] = 100, -- This is The Everbloom
    [1358] = 100, -- This is Upper Blackrock Spire
    [1544] = 0,   -- This is Assault on Violet Hold
    [1501] = 75,  -- This is Black Rook Hold
    [1677] = 100, -- This is Cathedral of Eternal Night
    [1571] = 100, -- This is Court of Stars
    [1466] = 78,  -- This is Darkheart Thicket
    [1456] = 284, -- This is Eye of Azshara
    [1477] = 82,  -- This is Halls of Valor
    [1492] = 100, -- This is Maw of Souls
    [1458] = 57,  -- This is Neltharion's Lair
    [1651] = 100, -- This is Return to Karazhan
    [1753] = 100, -- This is Seat of the Triumvirate
    [1516] = 100, -- This is The Arcway
    [1493] = 90,  -- This is Vault of the Wardens
    [1763] = 110, -- This is Atal'Dazar
    [1754] = 160, -- This is Freehold
    [1762] = 100, -- This is Kings' Rest
    [2097] = 100, -- This is Operation: Mechagon
    [1864] = 212, -- This is Shrine of the Storm
    [1822] = 100, -- This is Siege of Boralus
    [1877] = 117, -- This is Temple of Sethraliss
    [1594] = 184, -- This is The MOTHERLODE!!
    [1841] = 98,  -- This is The Underrot
    [1771] = 123, -- This is Tol Dagor
    [1862] = 147, -- This is Waycrest Manor
    [2291] = 122, -- This is De Other Side
    [2287] = 163, -- This is Halls of Atonement
    [2290] = 104, -- This is Mists of Tirna Scithe
    [2289] = 284, -- This is Plaguefall
    [2284] = 156, -- This is Sanguine Depths
    [2285] = 140, -- This is Spires of Ascension
    [2441] = 100, -- This is Tazavesh, the Veiled Market
    [2286] = 94,  -- This is The Necrotic Wake
    [2293] = 81,  -- This is Theater of Pain
    [2526] = 106, -- This is Algeth'ar Academy
    [2520] = 476, -- This is Brackenhide Hollow
    [2527] = 123, -- This is Halls of Infusion
    [2519] = 181, -- This is Neltharus
    [2521] = 137, -- This is Ruby Life Pools
    [2515] = 98,  -- This is The Azure Vault
    [2516] = 270, -- This is The Nokhud Offensive
    [2451] = 126, -- This is Uldaman: Legacy of Tyr
    [2579] = 100, -- This is Dawn of the Infinite
}

-- Dungeon encounter data
ns.Dungeons = {
    [48] = { -- Blackfathom Deeps
        expansion = 1,
        journalID = 227,
        encounters = {
            { journal = 368, difficulty = 1667 },  -- Ghamoo-Ra
            { journal = 436, difficulty = 1668 },  -- Domina
            { journal = 426, difficulty = 1669 },  -- Subjugator Kor'ul
            { journal = 1145, difficulty = 1675 }, -- Thruk
            { journal = 447, difficulty = 1676 },  -- Guardian of the Deep
            { journal = 1144, difficulty = 1670 }, -- Executioner Gore
            { journal = 437, difficulty = 1671 },  -- Twilight Lord Bathiel
            { journal = 444, difficulty = 1672 },  -- Aku'mai
        }
    },
    [230] = { -- Blackrock Depths
        expansion = 1,
        journalID = 228,
        encounters = {
            { journal = 369, difficulty = 227 }, -- High Interrogator Gerstahn
            { journal = 370, difficulty = 228 }, -- Lord Roccor
            { journal = 371, difficulty = 229 }, -- Houndmaster Grebmar
            { journal = 372, difficulty = 230 }, -- Ring of Law
            { journal = 373, difficulty = 231 }, -- Pyromancer Loregrain
            { journal = 374, difficulty = 232 }, -- Lord Incendius
            { journal = 375, difficulty = 233 }, -- Warder Stilgiss
            { journal = 376, difficulty = 234 }, -- Fineous Darkvire
            { journal = 377, difficulty = 235 }, -- Bael'Gar
            { journal = 378, difficulty = 236 }, -- General Angerforge
            { journal = 379, difficulty = 237 }, -- Golem Lord Argelmach
            { journal = 380, difficulty = 238 }, -- Hurley Blackbreath
            { journal = 381, difficulty = 239 }, -- Phalanx
            { journal = 383, difficulty = 241 }, -- Plugger Spazzring
            { journal = 384, difficulty = 242 }, -- Ambassador Flamelash
            { journal = 385, difficulty = 243 }, -- The Seven
            { journal = 386, difficulty = 244 }, -- Magmus
            { journal = 387, difficulty = 245 }, -- Emperor Dagran Thaurissan
        }
    },
    [36] = { -- Deadmines
        expansion = 1,
        journalID = 63,
        encounters = {
            { journal = 89, difficulty = 1064 }, -- Glubtok
            { journal = 90, difficulty = 1065 }, -- Helix Gearbreaker
            { journal = 91, difficulty = 1063 }, -- Foe Reaper 5000
            { journal = 92, difficulty = 1062 }, -- Admiral Ripsnarl
            { journal = 93, difficulty = 1060 }, -- "Captain" Cookie
        }
    },
    [429] = { -- Dire Maul
        expansion = 1,
        journalID = 230,
        encounters = {
            { journal = 402, difficulty = 343 }, -- Zevrim Thornhoof
            { journal = 403, difficulty = 344 }, -- Hydrospawn
            { journal = 404, difficulty = 345 }, -- Lethtendris
            { journal = 405, difficulty = 346 }, -- Alzzin the Wildshaper
            { journal = 406, difficulty = 350 }, -- Tendris Warpwood
            { journal = 407, difficulty = 347 }, -- Illyanna Ravenoak
            { journal = 408, difficulty = 348 }, -- Magister Kalendris
            { journal = 409, difficulty = 349 }, -- Immol'thar
            { journal = 410, difficulty = 361 }, -- Prince Tortheldrin
            { journal = 411, difficulty = 362 }, -- Guard Mol'dar
            { journal = 412, difficulty = 363 }, -- Stomper Kreeg
            { journal = 413, difficulty = 364 }, -- Guard Fengus
            { journal = 414, difficulty = 365 }, -- Guard Slip'kik
            { journal = 415, difficulty = 366 }, -- Captain Kromcrush
            { journal = 416, difficulty = 367 }, -- Cho'Rush the Observer
            { journal = 417, difficulty = 368 }, -- King Gordok
        }
    },
    [90] = { -- Gnomeregan
        expansion = 1,
        journalID = 231,
        encounters = {
            { journal = 420, difficulty = 378 }, -- Viscous Fallout
            { journal = 421, difficulty = 380 }, -- Electrocutioner 6000
            { journal = 418, difficulty = 381 }, -- Crowd Pummeler 9-60
            { journal = 422, difficulty = 382 }, -- Mekgineer Thermaplugg
        }
    },
    [229] = { -- Lower Blackrock Spire
        expansion = 1,
        journalID = 229,
        encounters = {
            { journal = 390, difficulty = 269 }, -- War Master Voone
            { journal = 394, difficulty = 274 }, -- Halycon
            { journal = 396, difficulty = 275 }, -- Overlord Wyrmthalak
        }
    },
    [349] = { -- Maraudon
        expansion = 1,
        journalID = 232,
        encounters = {
            { journal = 423, difficulty = 422 }, -- Noxxion
            { journal = 424, difficulty = 423 }, -- Razorlash
            { journal = 425, difficulty = 427 }, -- Tinkerer Gizlock
            { journal = 427, difficulty = 424 }, -- Lord Vyletongue
            { journal = 428, difficulty = 425 }, -- Celebras the Cursed
            { journal = 429, difficulty = 426 }, -- Landslide
            { journal = 430, difficulty = 428 }, -- Rotgrip
            { journal = 431, difficulty = 429 }, -- Princess Theradras
        }
    },
    [389] = { -- Ragefire Chasm
        expansion = 1,
        journalID = 226,
        encounters = {
            { journal = 694, difficulty = 1443 }, -- Adarogg
            { journal = 695, difficulty = 1444 }, -- Dark Shaman Koranthal
            { journal = 696, difficulty = 1445 }, -- Slagmaw
            { journal = 697, difficulty = 1446 }, -- Lava Guard Gordoth
        }
    },
    [129] = { -- Razorfen Downs
        expansion = 1,
        journalID = 233,
        encounters = {
            { journal = 1142, difficulty = 1662 }, -- Aarux
            { journal = 433, difficulty = 1663 },  -- Mordresh Fire Eye
            { journal = 1143, difficulty = 1664 }, -- Mushlump
            { journal = 1146, difficulty = 1665 }, -- Death Speaker Blackthorn
            { journal = 1141, difficulty = 1666 }, -- Amnennar the Coldbringer
        }
    },
    [47] = { -- Razorfen Kraul
        expansion = 1,
        journalID = 234,
        encounters = {
            { journal = 896, difficulty = 1656 }, -- Hunter Bonetusk
            { journal = 895, difficulty = 438 },  -- Roogug
            { journal = 899, difficulty = 1659 }, -- Warlord Ramtusk
            { journal = 900, difficulty = 1660 }, -- Groyat, the Blind Hunter
            { journal = 901, difficulty = 1661 }, -- Charlga Razorflank
        }
    },
    [1001] = { -- Scarlet Halls
        expansion = 1,
        journalID = 311,
        encounters = {
            { journal = 660, difficulty = 1422 }, -- Houndmaster Braun
            { journal = 654, difficulty = 1421 }, -- Armsmaster Harlan
            { journal = 656, difficulty = 1420 }, -- Flameweaver Koegler
        }
    },
    [1004] = { -- Scarlet Monastery
        expansion = 1,
        journalID = 316,
        encounters = {
            { journal = 688, difficulty = 1423 }, -- Thalnos the Soulrender
            { journal = 671, difficulty = 1424 }, -- Brother Korloff
            { journal = 674, difficulty = 1425 }, -- High Inquisitor Whitemane
        }
    },
    [1007] = { -- Scholomance
        expansion = 1,
        journalID = 246,
        encounters = {
            { journal = 659, difficulty = 1426 }, -- Instructor Chillheart
            { journal = 663, difficulty = 1427 }, -- Jandice Barov
            { journal = 665, difficulty = 1428 }, -- Rattlegore
            { journal = 666, difficulty = 1429 }, -- Lilian Voss
            { journal = 684, difficulty = 1430 }, -- Darkmaster Gandling
        }
    },
    [33] = { -- Shadowfang Keep
        expansion = 1,
        journalID = 64,
        encounters = {
            { journal = 96, difficulty = 1069 },  -- Baron Ashbury
            { journal = 97, difficulty = 1070 },  -- Baron Silverlaine
            { journal = 98, difficulty = 1071 },  -- Commander Springvale
            { journal = 99, difficulty = 1073 },  -- Lord Walden
            { journal = 100, difficulty = 1072 }, -- Lord Godfrey
        }
    },
    [329] = { -- Stratholme
        expansion = 1,
        journalID = 236,
        encounters = {
            { journal = 445, difficulty = 474 }, -- Timmy the Cruel
            { journal = 749, difficulty = 476 }, -- Commander Malor
            { journal = 446, difficulty = 475 }, -- Willey Hopebreaker
            { journal = 448, difficulty = 477 }, -- Instructor Galford
            { journal = 449, difficulty = 478 }, -- Balnazzar
        }
    },
    [34] = { -- The Stockade
        expansion = 1,
        journalID = 238,
        encounters = {
            { journal = 464, difficulty = 1144 }, -- Hogger
            { journal = 465, difficulty = 1145 }, -- Lord Overheat
            { journal = 466, difficulty = 1146 }, -- Randolph Moloch
        }
    },
    [109] = { -- The Temple of Atal'hakkar
        expansion = 1,
        journalID = 237,
        encounters = {
            { journal = 457, difficulty = 492 }, -- Avatar of Hakkar
            { journal = 458, difficulty = 488 }, -- Jammal'an the Prophet
            { journal = 459, difficulty = 0 },   -- Wardens of the Dream
            { journal = 463, difficulty = 493 }, -- Shade of Eranikus
        }
    },
    [70] = { -- Uldaman
        expansion = 1,
        journalID = 239,
        encounters = {
            { journal = 467, difficulty = 547 }, -- Revelosh
            { journal = 469, difficulty = 549 }, -- Ironaya
            { journal = 470, difficulty = 551 }, -- Ancient Stone Keeper
            { journal = 472, difficulty = 553 }, -- Grimlok
            { journal = 473, difficulty = 554 }, -- Archaedas
        }
    },
    [43] = { -- Wailing Caverns
        expansion = 1,
        journalID = 240,
        encounters = {
            { journal = 474, difficulty = 585 }, -- Lady Anacondra
            { journal = 476, difficulty = 588 }, -- Lord Pythas
            { journal = 475, difficulty = 586 }, -- Lord Cobrahn
            { journal = 477, difficulty = 587 }, -- Kresh
            { journal = 478, difficulty = 589 }, -- Skum
            { journal = 479, difficulty = 590 }, -- Lord Serpentis
            { journal = 480, difficulty = 591 }, -- Verdan the Everliving
            { journal = 481, difficulty = 592 }, -- Mutanus the Devourer
        }
    },
    [209] = { -- Zul'Farrak
        expansion = 1,
        journalID = 241,
        encounters = {
            { journal = 483, difficulty = 594 }, -- Gahz'rilla
            { journal = 484, difficulty = 595 }, -- Antu'sul
            { journal = 485, difficulty = 596 }, -- Theka the Martyr
            { journal = 486, difficulty = 597 }, -- Witch Doctor Zum'rah
            { journal = 487, difficulty = 598 }, -- Nekrum & Sezz'ziz
            { journal = 489, difficulty = 600 }, -- Chief Ukorz Sandscalp
        }
    },
    [558] = { -- Auchenai Crypts
        expansion = 2,
        journalID = 247,
        encounters = {
            { journal = 523, difficulty = 1890 }, -- Shirrak the Dead Watcher
            { journal = 524, difficulty = 1889 }, -- Exarch Maladaar
        }
    },
    [543] = { -- Hellfire Ramparts
        expansion = 2,
        journalID = 248,
        encounters = {
            { journal = 527, difficulty = 1893 }, -- Watchkeeper Gargolmar
            { journal = 528, difficulty = 1891 }, -- Omor the Unscarred
            { journal = 529, difficulty = 1892 }, -- Vazruden the Herald
        }
    },
    [585] = { -- Magisters' Terrace
        expansion = 2,
        journalID = 249,
        encounters = {
            { journal = 530, difficulty = 1897 }, -- Selin Fireheart
            { journal = 531, difficulty = 1898 }, -- Vexallus
            { journal = 532, difficulty = 1895 }, -- Priestess Delrissa
            { journal = 533, difficulty = 1894 }, -- Kael'thas Sunstrider
        }
    },
    [557] = { -- Mana-Tombs
        expansion = 2,
        journalID = 250,
        encounters = {
            { journal = 534, difficulty = 1900 }, -- Pandemonius
            { journal = 535, difficulty = 1901 }, -- Tavarok
            { journal = 537, difficulty = 1899 }, -- Nexus-Prince Shaffar
        }
    },
    [560] = { -- Old Hillsbrad Foothills
        expansion = 2,
        journalID = 251,
        encounters = {
            { journal = 538, difficulty = 1905 }, -- Lieutenant Drake
            { journal = 539, difficulty = 1907 }, -- Captain Skarloc
            { journal = 540, difficulty = 1906 }, -- Epoch Hunter
        }
    },
    [556] = { -- Sethekk Halls
        expansion = 2,
        journalID = 252,
        encounters = {
            { journal = 541, difficulty = 1903 }, -- Darkweaver Syth
            { journal = 543, difficulty = 1902 }, -- Talon King Ikiss
        }
    },
    [555] = { -- Shadow Labyrinth
        expansion = 2,
        journalID = 253,
        encounters = {
            { journal = 544, difficulty = 1908 }, -- Ambassador Hellmaw
            { journal = 545, difficulty = 1909 }, -- Blackheart the Inciter
            { journal = 546, difficulty = 1911 }, -- Grandmaster Vorpil
            { journal = 547, difficulty = 1910 }, -- Murmur
        }
    },
    [552] = { -- The Arcatraz
        expansion = 2,
        journalID = 254,
        encounters = {
            { journal = 548, difficulty = 1916 }, -- Zereketh the Unbound
            { journal = 549, difficulty = 1913 }, -- Dalliah the Doomsayer
            { journal = 550, difficulty = 1915 }, -- Wrath-Scryer Soccothrates
            { journal = 551, difficulty = 1914 }, -- Harbinger Skyriss
        }
    },
    [269] = { -- The Black Morass
        expansion = 2,
        journalID = 255,
        encounters = {
            { journal = 552, difficulty = 1920 }, -- Chrono Lord Deja
            { journal = 553, difficulty = 1921 }, -- Temporus
            { journal = 554, difficulty = 1919 }, -- Aeonus
        }
    },
    [542] = { -- The Blood Furnace
        expansion = 2,
        journalID = 256,
        encounters = {
            { journal = 555, difficulty = 1922 }, -- The Maker
            { journal = 556, difficulty = 1924 }, -- Broggok
            { journal = 557, difficulty = 1923 }, -- Keli'dan the Breaker
        }
    },
    [553] = { -- The Botanica
        expansion = 2,
        journalID = 257,
        encounters = {
            { journal = 558, difficulty = 1925 }, -- Commander Sarannis
            { journal = 559, difficulty = 1926 }, -- High Botanist Freywinn
            { journal = 560, difficulty = 1928 }, -- Thorngrin the Tender
            { journal = 561, difficulty = 1927 }, -- Laj
            { journal = 562, difficulty = 1929 }, -- Warp Splinter
        }
    },
    [554] = { -- The Mechanar
        expansion = 2,
        journalID = 258,
        encounters = {
            { journal = 563, difficulty = 1932 }, -- Mechano-Lord Capacitus
            { journal = 564, difficulty = 1930 }, -- Nethermancer Sepethrea
            { journal = 565, difficulty = 1931 }, -- Pathaleon the Calculator
        }
    },
    [540] = { -- The Shattered Halls
        expansion = 2,
        journalID = 259,
        encounters = {
            { journal = 566, difficulty = 1936 }, -- Grand Warlock Nethekurse
            { journal = 568, difficulty = 1937 }, -- Warbringer O'mrogg
            { journal = 569, difficulty = 1938 }, -- Warchief Kargath Bladefist
        }
    },
    [547] = { -- The Slave Pens
        expansion = 2,
        journalID = 260,
        encounters = {
            { journal = 570, difficulty = 1939 }, -- Mennu the Betrayer
            { journal = 571, difficulty = 1941 }, -- Rokmar the Crackler
            { journal = 572, difficulty = 1940 }, -- Quagmirran
        }
    },
    [545] = { -- The Steamvault
        expansion = 2,
        journalID = 261,
        encounters = {
            { journal = 573, difficulty = 1942 }, -- Hydromancer Thespia
            { journal = 574, difficulty = 1943 }, -- Mekgineer Steamrigger
            { journal = 575, difficulty = 1944 }, -- Warlord Kalithresh
        }
    },
    [546] = { -- The Underbog
        expansion = 2,
        journalID = 262,
        encounters = {
            { journal = 576, difficulty = 1946 }, -- Hungarfen
            { journal = 577, difficulty = 1945 }, -- Ghaz'an
            { journal = 578, difficulty = 1947 }, -- Swamplord Musel'ek
            { journal = 579, difficulty = 1948 }, -- The Black Stalker
        }
    },
    [619] = { -- Ahn'kahet: The Old Kingdom
        expansion = 3,
        journalID = 271,
        encounters = {
            { journal = 580, difficulty = 1969 }, -- Elder Nadox
            { journal = 581, difficulty = 1966 }, -- Prince Taldaram
            { journal = 582, difficulty = 1967 }, -- Jedoga Shadowseeker
            { journal = 584, difficulty = 1968 }, -- Herald Volazj
        }
    },
    [601] = { -- Azjol-Nerub
        expansion = 3,
        journalID = 272,
        encounters = {
            { journal = 585, difficulty = 1971 }, -- Krik'thir the Gatewatcher
            { journal = 586, difficulty = 1972 }, -- Hadronox
            { journal = 587, difficulty = 1973 }, -- Anub'arak
        }
    },
    [600] = { -- Drak'Tharon Keep
        expansion = 3,
        journalID = 273,
        encounters = {
            { journal = 588, difficulty = 1974 }, -- Trollgore
            { journal = 589, difficulty = 1976 }, -- Novos the Summoner
            { journal = 590, difficulty = 1977 }, -- King Dred
            { journal = 591, difficulty = 1975 }, -- The Prophet Tharon'ja
        }
    },
    [604] = { -- Gundrak
        expansion = 3,
        journalID = 274,
        encounters = {
            { journal = 592, difficulty = 1978 }, -- Slad'ran
            { journal = 593, difficulty = 1983 }, -- Drakkari Colossus
            { journal = 594, difficulty = 1980 }, -- Moorabi
            { journal = 596, difficulty = 1981 }, -- Gal'darah
        }
    },
    [602] = { -- Halls of Lightning
        expansion = 3,
        journalID = 275,
        encounters = {
            { journal = 597, difficulty = 1987 }, -- General Bjarngrim
            { journal = 598, difficulty = 1985 }, -- Volkhan
            { journal = 599, difficulty = 1984 }, -- Ionar
            { journal = 600, difficulty = 1986 }, -- Loken
        }
    },
    [668] = { -- Halls of Reflection
        expansion = 3,
        journalID = 276,
        encounters = {
            { journal = 601, difficulty = 1992 }, -- Falric
            { journal = 602, difficulty = 1993 }, -- Marwyn
            { journal = 603, difficulty = 1990 }, -- Escape from Arthas
        }
    },
    [599] = { -- Halls of Stone
        expansion = 3,
        journalID = 277,
        encounters = {
            { journal = 604, difficulty = 1994 }, -- Krystallus
            { journal = 605, difficulty = 1996 }, -- Maiden of Grief
            { journal = 606, difficulty = 1995 }, -- Tribunal of Ages
            { journal = 607, difficulty = 1998 }, -- Sjonnir the Ironshaper
        }
    },
    [658] = { -- Pit of Saron
        expansion = 3,
        journalID = 278,
        encounters = {
            { journal = 608, difficulty = 1999 }, -- Forgemaster Garfrost
            { journal = 609, difficulty = 2001 }, -- Ick & Krick
            { journal = 610, difficulty = 2000 }, -- Scourgelord Tyrannus
        }
    },
    [595] = { -- The Culling of Stratholme
        expansion = 3,
        journalID = 279,
        encounters = {
            { journal = 611, difficulty = 2002 }, -- Meathook
            { journal = 612, difficulty = 2004 }, -- Salramm the Fleshcrafter
            { journal = 613, difficulty = 2003 }, -- Chrono-Lord Epoch
            { journal = 614, difficulty = 2005 }, -- Mal'Ganis
        }
    },
    [632] = { -- The Forge of Souls
        expansion = 3,
        journalID = 280,
        encounters = {
            { journal = 615, difficulty = 2006 }, -- Bronjahm
            { journal = 616, difficulty = 2007 }, -- Devourer of Souls
        }
    },
    [576] = { -- The Nexus
        expansion = 3,
        journalID = 281,
        encounters = {
            { journal = 618, difficulty = 521 }, -- Grand Magus Telestra
            { journal = 619, difficulty = 522 }, -- Anomalus
            { journal = 620, difficulty = 524 }, -- Ormorok the Tree-Shaper
            { journal = 621, difficulty = 527 }, -- Keristrasza
        }
    },
    [578] = { -- The Oculus
        expansion = 3,
        journalID = 282,
        encounters = {
            { journal = 622, difficulty = 528 }, -- Drakos the Interrogator
            { journal = 623, difficulty = 530 }, -- Varos Cloudstrider
            { journal = 624, difficulty = 533 }, -- Mage-Lord Urom
            { journal = 625, difficulty = 534 }, -- Ley-Guardian Eregos
        }
    },
    [0] = { -- The Violet Hold
        expansion = 3,
        journalID = 283,
        encounters = {
            { journal = 626, difficulty = 0 },    -- Erekem
            { journal = 627, difficulty = 0 },    -- Moragg
            { journal = 628, difficulty = 0 },    -- Ichoron
            { journal = 629, difficulty = 0 },    -- Xevozz
            { journal = 630, difficulty = 0 },    -- Lavanthor
            { journal = 631, difficulty = 0 },    -- Zuramat the Obliterator
            { journal = 632, difficulty = 2020 }, -- Cyanigosa
        }
    },
    [650] = { -- Trial of the Champion
        expansion = 3,
        journalID = 284,
        encounters = {
            { journal = 834, difficulty = 2022 }, -- Grand Champions
            { journal = 635, difficulty = 2022 }, -- Eadric the Pure
            { journal = 636, difficulty = 2022 }, -- Argent Confessor Paletress
            { journal = 637, difficulty = 2021 }, -- The Black Knight
        }
    },
    [574] = { -- Utgarde Keep
        expansion = 3,
        journalID = 285,
        encounters = {
            { journal = 638, difficulty = 2026 }, -- Prince Keleseth
            { journal = 639, difficulty = 2024 }, -- Skarvald & Dalronn
            { journal = 640, difficulty = 2025 }, -- Ingvar the Plunderer
        }
    },
    [575] = { -- Utgarde Pinnacle
        expansion = 3,
        journalID = 286,
        encounters = {
            { journal = 641, difficulty = 2030 }, -- Svala Sorrowgrave
            { journal = 642, difficulty = 2027 }, -- Gortok Palehoof
            { journal = 643, difficulty = 2029 }, -- Skadi the Ruthless
            { journal = 644, difficulty = 2028 }, -- King Ymiron
        }
    },
    [645] = { -- Blackrock Caverns
        expansion = 4,
        journalID = 66,
        encounters = {
            { journal = 105, difficulty = 1040 }, -- Rom'ogg Bonecrusher
            { journal = 106, difficulty = 1038 }, -- Corla, Herald of Twilight
            { journal = 107, difficulty = 1039 }, -- Karsh Steelbender
            { journal = 108, difficulty = 1037 }, -- Beauty
            { journal = 109, difficulty = 1036 }, -- Ascendant Lord Obsidius
        }
    },
    [938] = { -- End Time
        expansion = 4,
        journalID = 184,
        encounters = {
            { journal = 340, difficulty = 1881 }, -- Echo of Baine
            { journal = 285, difficulty = 1883 }, -- Echo of Jaina
            { journal = 323, difficulty = 1882 }, -- Echo of Sylvanas
            { journal = 283, difficulty = 1884 }, -- Echo of Tyrande
            { journal = 289, difficulty = 1271 }, -- Murozond
        }
    },
    [670] = { -- Grim Batol
        expansion = 4,
        journalID = 71,
        encounters = {
            { journal = 131, difficulty = 1051 }, -- General Umbriss
            { journal = 132, difficulty = 1050 }, -- Forgemaster Throngus
            { journal = 133, difficulty = 1048 }, -- Drahga Shadowburner
            { journal = 134, difficulty = 1049 }, -- Erudax, the Duke of Below
        }
    },
    [644] = { -- Halls of Origination
        expansion = 4,
        journalID = 70,
        encounters = {
            { journal = 124, difficulty = 1080 }, -- Temple Guardian Anhuur
            { journal = 125, difficulty = 1076 }, -- Earthrager Ptah
            { journal = 126, difficulty = 1075 }, -- Anraphet
            { journal = 127, difficulty = 1077 }, -- Isiset, Construct of Magic
            { journal = 128, difficulty = 1074 }, -- Ammunae, Construct of Life
            { journal = 129, difficulty = 1079 }, -- Setesh, Construct of Destruction
            { journal = 130, difficulty = 1078 }, -- Rajh, Construct of Sun
        }
    },
    [940] = { -- Hour of Twilight
        expansion = 4,
        journalID = 186,
        encounters = {
            { journal = 322, difficulty = 1337 }, -- Arcurion
            { journal = 342, difficulty = 1340 }, -- Asira Dawnslayer
            { journal = 341, difficulty = 1339 }, -- Archbishop Benedictus
        }
    },
    [755] = { -- Lost City of the Tol'vir
        expansion = 4,
        journalID = 69,
        encounters = {
            { journal = 117, difficulty = 1052 }, -- General Husam
            { journal = 118, difficulty = 1054 }, -- Lockmaw
            { journal = 119, difficulty = 1053 }, -- High Prophet Barim
            { journal = 122, difficulty = 1055 }, -- Siamat
        }
    },
    [725] = { -- The Stonecore
        expansion = 4,
        journalID = 67,
        encounters = {
            { journal = 110, difficulty = 1056 }, -- Corborus
            { journal = 111, difficulty = 1059 }, -- Slabhide
            { journal = 112, difficulty = 1058 }, -- Ozruk
            { journal = 113, difficulty = 1057 }, -- High Priestess Azil
        }
    },
    [657] = { -- The Vortex Pinnacle
        expansion = 4,
        journalID = 68,
        encounters = {
            { journal = 114, difficulty = 1043 }, -- Grand Vizier Ertan
            { journal = 115, difficulty = 1041 }, -- Altairus
            { journal = 116, difficulty = 1042 }, -- Asaad, Caliph of Zephyrs
        }
    },
    [643] = { -- Throne of the Tides
        expansion = 4,
        journalID = 65,
        encounters = {
            { journal = 101, difficulty = 1045 }, -- Lady Naz'jar
            { journal = 102, difficulty = 1044 }, -- Commander Ulthok, the Festering Prince
            { journal = 103, difficulty = 1046 }, -- Mindbender Ghur'sha
            { journal = 104, difficulty = 1047 }, -- Ozumat
        }
    },
    [939] = { -- Well of Eternity
        expansion = 4,
        journalID = 185,
        encounters = {
            { journal = 290, difficulty = 1272 }, -- Peroth'arn
            { journal = 291, difficulty = 1273 }, -- Queen Azshara
            { journal = 292, difficulty = 1274 }, -- Mannoroth and Varo'then
        }
    },
    [568] = { -- Zul'Aman
        expansion = 4,
        journalID = 77,
        encounters = {
            { journal = 186, difficulty = 1189 }, -- Akil'zon
            { journal = 187, difficulty = 1190 }, -- Nalorakk
            { journal = 188, difficulty = 1191 }, -- Jan'alai
            { journal = 189, difficulty = 1192 }, -- Halazzi
            { journal = 190, difficulty = 1193 }, -- Hex Lord Malacrass
            { journal = 191, difficulty = 1194 }, -- Daakara
        }
    },
    [859] = { -- Zul'Gurub
        expansion = 4,
        journalID = 76,
        encounters = {
            { journal = 175, difficulty = 1178 }, -- High Priest Venoxis
            { journal = 176, difficulty = 1179 }, -- Bloodlord Mandokir
            { journal = 177, difficulty = 788 },  -- Cache of Madness - Gri'lek
            { journal = 178, difficulty = 788 },  -- Cache of Madness - Hazza'rah
            { journal = 179, difficulty = 788 },  -- Cache of Madness - Renataki
            { journal = 180, difficulty = 788 },  -- Cache of Madness - Wushoolay
            { journal = 181, difficulty = 1180 }, -- High Priestess Kilnara
            { journal = 184, difficulty = 1181 }, -- Zanzil
            { journal = 185, difficulty = 1182 }, -- Jin'do the Godbreaker
        }
    },
    [962] = { -- Gate of the Setting Sun
        expansion = 5,
        journalID = 303,
        encounters = {
            { journal = 655, difficulty = 1397 }, -- Saboteur Kip'tilak
            { journal = 675, difficulty = 1405 }, -- Striker Ga'dok
            { journal = 676, difficulty = 1406 }, -- Commander Ri'mok
            { journal = 649, difficulty = 1419 }, -- Raigonn
        }
    },
    [994] = { -- Mogu'shan Palace
        expansion = 5,
        journalID = 321,
        encounters = {
            { journal = 708, difficulty = 1442 }, -- Trial of the King
            { journal = 690, difficulty = 2129 }, -- Gekkan
            { journal = 698, difficulty = 1441 }, -- Xin the Weaponmaster
        }
    },
    [959] = { -- Shado-Pan Monastery
        expansion = 5,
        journalID = 312,
        encounters = {
            { journal = 673, difficulty = 1303 }, -- Gu Cloudstrike
            { journal = 657, difficulty = 1304 }, -- Master Snowdrift
            { journal = 685, difficulty = 1305 }, -- Sha of Violence
            { journal = 686, difficulty = 1306 }, -- Taran Zhu
        }
    },
    [1011] = { -- Siege of Niuzao Temple
        expansion = 5,
        journalID = 324,
        encounters = {
            { journal = 693, difficulty = 1465 }, -- Vizier Jin'bak
            { journal = 738, difficulty = 1502 }, -- Commander Vo'jak
            { journal = 692, difficulty = 1447 }, -- General Pa'valak
            { journal = 727, difficulty = 1464 }, -- Wing Leader Ner'onok
        }
    },
    [961] = { -- Stormstout Brewery
        expansion = 5,
        journalID = 302,
        encounters = {
            { journal = 668, difficulty = 1412 }, -- Ook-Ook
            { journal = 669, difficulty = 1413 }, -- Hoptallus
            { journal = 670, difficulty = 1414 }, -- Yan-Zhu the Uncasked
        }
    },
    [960] = { -- Temple of the Jade Serpent
        expansion = 5,
        journalID = 313,
        encounters = {
            { journal = 672, difficulty = 1418 }, -- Wise Mari
            { journal = 664, difficulty = 1417 }, -- Lorewalker Stonestep
            { journal = 658, difficulty = 1416 }, -- Liu Flameheart
            { journal = 335, difficulty = 1439 }, -- Sha of Doubt
        }
    },
    [1182] = { -- Auchindoun
        expansion = 6,
        journalID = 547,
        encounters = {
            { journal = 1185, difficulty = 1686 }, -- Vigilant Kaathar
            { journal = 1186, difficulty = 1685 }, -- Soulbinder Nyami
            { journal = 1216, difficulty = 1678 }, -- Azzakel
            { journal = 1225, difficulty = 1714 }, -- Teron'gor
        }
    },
    [1175] = { -- Bloodmaul Slag Mines
        expansion = 6,
        journalID = 385,
        encounters = {
            { journal = 893, difficulty = 1655 }, -- Magmolatus
            { journal = 888, difficulty = 1653 }, -- Slave Watcher Crushto
            { journal = 887, difficulty = 1652 }, -- Roltall
            { journal = 889, difficulty = 1654 }, -- Gug'rokk
        }
    },
    [1208] = { -- Grimrail Depot
        expansion = 6,
        journalID = 536,
        encounters = {
            { journal = 1138, difficulty = 1715 }, -- Rocketspark and Borka
            { journal = 1163, difficulty = 1732 }, -- Nitrogg Thundertower
            { journal = 1133, difficulty = 1736 }, -- Skylord Tovra
        }
    },
    [1195] = { -- Iron Docks
        expansion = 6,
        journalID = 558,
        encounters = {
            { journal = 1235, difficulty = 1749 }, -- Fleshrender Nok'gar
            { journal = 1236, difficulty = 1748 }, -- Grimrail Enforcers
            { journal = 1237, difficulty = 1750 }, -- Oshir
            { journal = 1238, difficulty = 1754 }, -- Skulloc
        }
    },
    [1176] = { -- Shadowmoon Burial Grounds
        expansion = 6,
        journalID = 537,
        encounters = {
            { journal = 1139, difficulty = 1677 }, -- Sadana Bloodfury
            { journal = 1168, difficulty = 1688 }, -- Nhallish
            { journal = 1140, difficulty = 1679 }, -- Bonemaw
            { journal = 1160, difficulty = 1682 }, -- Ner'zhul
        }
    },
    [1209] = { -- Skyreach
        expansion = 6,
        journalID = 476,
        encounters = {
            { journal = 965, difficulty = 1698 }, -- Ranjit
            { journal = 966, difficulty = 1699 }, -- Araknath
            { journal = 967, difficulty = 1700 }, -- Rukhran
            { journal = 968, difficulty = 1701 }, -- High Sage Viryx
        }
    },
    [1279] = { -- The Everbloom
        expansion = 6,
        journalID = 556,
        encounters = {
            { journal = 1214, difficulty = 1746 }, -- Witherbark
            { journal = 1207, difficulty = 1757 }, -- Ancient Protectors
            { journal = 1208, difficulty = 1751 }, -- Archmage Sol
            { journal = 1209, difficulty = 1752 }, -- Xeri'tac
            { journal = 1210, difficulty = 1756 }, -- Yalnu
        }
    },
    [1358] = { -- Upper Blackrock Spire
        expansion = 6,
        journalID = 559,
        encounters = {
            { journal = 1226, difficulty = 1761 }, -- Orebender Gor'ashan
            { journal = 1227, difficulty = 1758 }, -- Kyrak
            { journal = 1228, difficulty = 1759 }, -- Commander Tharbek
            { journal = 1229, difficulty = 1760 }, -- Ragewing the Untamed
            { journal = 1234, difficulty = 1762 }, -- Warlord Zaela
        }
    },
    [1544] = { -- Assault on Violet Hold
        expansion = 7,
        journalID = 777,
        encounters = {
            { journal = 1693, difficulty = 1848 }, -- Festerface
            { journal = 1694, difficulty = 1845 }, -- Shivermaw
            { journal = 1702, difficulty = 1855 }, -- Blood-Princess Thal'ena
            { journal = 1686, difficulty = 1846 }, -- Mindflayer Kaahrj
            { journal = 1688, difficulty = 1847 }, -- Millificent Manastorm
            { journal = 1696, difficulty = 1852 }, -- Anub'esset
            { journal = 1697, difficulty = 1851 }, -- Sael'orn
            { journal = 1711, difficulty = 1856 }, -- Fel Lord Betrug
        }
    },
    [1501] = { -- Black Rook Hold
        expansion = 7,
        journalID = 740,
        encounters = {
            { journal = 1518, difficulty = 1832 }, -- The Amalgam of Souls
            { journal = 1653, difficulty = 1833 }, -- Illysanna Ravencrest
            { journal = 1664, difficulty = 1834 }, -- Smashspite the Hateful
            { journal = 1672, difficulty = 1835 }, -- Lord Kur'talos Ravencrest
        }
    },
    [1677] = { -- Cathedral of Eternal Night
        expansion = 7,
        journalID = 900,
        encounters = {
            { journal = 1905, difficulty = 2055 }, -- Agronox
            { journal = 1906, difficulty = 2057 }, -- Thrashbite the Scornful
            { journal = 1904, difficulty = 2039 }, -- Domatrax
            { journal = 1878, difficulty = 2053 }, -- Mephistroth
        }
    },
    [1571] = { -- Court of Stars
        expansion = 7,
        journalID = 800,
        encounters = {
            { journal = 1718, difficulty = 1868 }, -- Patrol Captain Gerdo
            { journal = 1719, difficulty = 1869 }, -- Talixae Flamewreath
            { journal = 1720, difficulty = 1870 }, -- Advisor Melandrus
        }
    },
    [1466] = { -- Darkheart Thicket
        expansion = 7,
        journalID = 762,
        encounters = {
            { journal = 1654, difficulty = 1836 }, -- Archdruid Glaidalis
            { journal = 1655, difficulty = 1837 }, -- Oakheart
            { journal = 1656, difficulty = 1838 }, -- Dresaron
            { journal = 1657, difficulty = 1839 }, -- Shade of Xavius
        }
    },
    [1456] = { -- Eye of Azshara
        expansion = 7,
        journalID = 716,
        encounters = {
            { journal = 1480, difficulty = 1810 }, -- Warlord Parjesh
            { journal = 1490, difficulty = 1811 }, -- Lady Hatecoil
            { journal = 1491, difficulty = 1812 }, -- King Deepbeard
            { journal = 1479, difficulty = 1813 }, -- Serpentrix
            { journal = 1492, difficulty = 1814 }, -- Wrath of Azshara
        }
    },
    [1477] = { -- Halls of Valor
        expansion = 7,
        journalID = 721,
        encounters = {
            { journal = 1485, difficulty = 1805 }, -- Hymdall
            { journal = 1486, difficulty = 1806 }, -- Hyrja
            { journal = 1487, difficulty = 1807 }, -- Fenryr
            { journal = 1488, difficulty = 1808 }, -- God-King Skovald
            { journal = 1489, difficulty = 1809 }, -- Odyn
        }
    },
    [1492] = { -- Maw of Souls
        expansion = 7,
        journalID = 727,
        encounters = {
            { journal = 1502, difficulty = 1822 }, -- Ymiron, the Fallen King
            { journal = 1512, difficulty = 1823 }, -- Harbaron
            { journal = 1663, difficulty = 1824 }, -- Helya
        }
    },
    [1458] = { -- Neltharion's Lair
        expansion = 7,
        journalID = 767,
        encounters = {
            { journal = 1662, difficulty = 1790 }, -- Rokmora
            { journal = 1665, difficulty = 1791 }, -- Ularogg Cragshaper
            { journal = 1673, difficulty = 1792 }, -- Naraxas
            { journal = 1687, difficulty = 1793 }, -- Dargrul the Underking
        }
    },
    [1651] = { -- Return to Karazhan
        expansion = 7,
        journalID = 860,
        encounters = {
            { journal = 1820, difficulty = 1957 }, -- Opera Hall: Wikket
            { journal = 1826, difficulty = 1957 }, -- Opera Hall: Westfall Story
            { journal = 1827, difficulty = 1957 }, -- Opera Hall: Beautiful Beast
            { journal = 1825, difficulty = 1954 }, -- Maiden of Virtue
            { journal = 1835, difficulty = 1960 }, -- Attumen the Huntsman
            { journal = 1837, difficulty = 1961 }, -- Moroes
            { journal = 1836, difficulty = 1964 }, -- The Curator
            { journal = 1817, difficulty = 1965 }, -- Shade of Medivh
            { journal = 1818, difficulty = 1959 }, -- Mana Devourer
            { journal = 1838, difficulty = 2017 }, -- Viz'aduum the Watcher
        }
    },
    [1753] = { -- Seat of the Triumvirate
        expansion = 7,
        journalID = 945,
        encounters = {
            { journal = 1979, difficulty = 2065 }, -- Zuraal the Ascended
            { journal = 1980, difficulty = 2066 }, -- Saprish
            { journal = 1981, difficulty = 2067 }, -- Viceroy Nezhar
            { journal = 1982, difficulty = 2068 }, -- L'ura
        }
    },
    [1516] = { -- The Arcway
        expansion = 7,
        journalID = 726,
        encounters = {
            { journal = 1497, difficulty = 1827 }, -- Ivanyr
            { journal = 1498, difficulty = 1825 }, -- Corstilax
            { journal = 1499, difficulty = 1828 }, -- General Xakal
            { journal = 1500, difficulty = 1826 }, -- Nal'tira
            { journal = 1501, difficulty = 1829 }, -- Advisor Vandros
        }
    },
    [1493] = { -- Vault of the Wardens
        expansion = 7,
        journalID = 707,
        encounters = {
            { journal = 1467, difficulty = 1815 }, -- Tirathon Saltheril
            { journal = 1695, difficulty = 1850 }, -- Inquisitor Tormentorum
            { journal = 1468, difficulty = 1816 }, -- Ash'golm
            { journal = 1469, difficulty = 1817 }, -- Glazer
            { journal = 1470, difficulty = 1818 }, -- Cordana Felsong
        }
    },
    [1763] = { -- Atal'Dazar
        expansion = 8,
        journalID = 968,
        encounters = {
            { journal = 2082, difficulty = 2084 }, -- Priestess Alun'za
            { journal = 2036, difficulty = 2085 }, -- Vol'kaal
            { journal = 2083, difficulty = 2086 }, -- Rezan
            { journal = 2030, difficulty = 2087 }, -- Yazma
        }
    },
    [1754] = { -- Freehold
        expansion = 8,
        journalID = 1001,
        encounters = {
            { journal = 2102, difficulty = 2093 }, -- Skycap'n Kragg
            { journal = 2093, difficulty = 2094 }, -- Council o' Captains
            { journal = 2094, difficulty = 2095 }, -- Ring of Booty
            { journal = 2095, difficulty = 2096 }, -- Harlan Sweete
        }
    },
    [1762] = { -- Kings' Rest
        expansion = 8,
        journalID = 1041,
        encounters = {
            { journal = 2165, difficulty = 2139 }, -- The Golden Serpent
            { journal = 2171, difficulty = 2142 }, -- Mchimba the Embalmer
            { journal = 2170, difficulty = 2140 }, -- The Council of Tribes
            { journal = 2172, difficulty = 2143 }, -- Dazar, The First King
        }
    },
    [2097] = { -- Operation: Mechagon
        expansion = 8,
        journalID = 1178,
        encounters = {
            { journal = 2357, difficulty = 2290 }, -- King Gobbamak
            { journal = 2358, difficulty = 2292 }, -- Gunker
            { journal = 2360, difficulty = 2312 }, -- Trixie & Naeno
            { journal = 2355, difficulty = 2291 }, -- HK-8 Aerial Oppression Unit
            { journal = 2336, difficulty = 2257 }, -- Tussle Tonks
            { journal = 2339, difficulty = 2258 }, -- K.U.-J.0.
            { journal = 2348, difficulty = 2259 }, -- Machinist's Garden
            { journal = 2331, difficulty = 2260 }, -- King Mechagon
        }
    },
    [1864] = { -- Shrine of the Storm
        expansion = 8,
        journalID = 1036,
        encounters = {
            { journal = 2153, difficulty = 2130 }, -- Aqu'sirr
            { journal = 2154, difficulty = 2131 }, -- Tidesage Council
            { journal = 2155, difficulty = 2132 }, -- Lord Stormsong
            { journal = 2156, difficulty = 2133 }, -- Vol'zith the Whisperer
        }
    },
    [1822] = { -- Siege of Boralus
        expansion = 8,
        journalID = 1023,
        encounters = {
            { journal = 2133, difficulty = 2097 }, -- Sergeant Bainbridge
            { journal = 2173, difficulty = 2109 }, -- Dread Captain Lockwood
            { journal = 2134, difficulty = 2099 }, -- Hadal Darkfathom
            { journal = 2140, difficulty = 2100 }, -- Viq'Goth
        }
    },
    [1877] = { -- Temple of Sethraliss
        expansion = 8,
        journalID = 1030,
        encounters = {
            { journal = 2142, difficulty = 2124 }, -- Adderis and Aspix
            { journal = 2143, difficulty = 2125 }, -- Merektha
            { journal = 2144, difficulty = 2126 }, -- Galvazzt
            { journal = 2145, difficulty = 2127 }, -- Avatar of Sethraliss
        }
    },
    [1594] = { -- The MOTHERLODE!!
        expansion = 8,
        journalID = 1012,
        encounters = {
            { journal = 2109, difficulty = 2105 }, -- Coin-Operated Crowd Pummeler
            { journal = 2114, difficulty = 2106 }, -- Azerokk
            { journal = 2115, difficulty = 2107 }, -- Rixxa Fluxflame
            { journal = 2116, difficulty = 2108 }, -- Mogul Razdunk
        }
    },
    [1841] = { -- The Underrot
        expansion = 8,
        journalID = 1022,
        encounters = {
            { journal = 2157, difficulty = 2111 }, -- Elder Leaxa
            { journal = 2131, difficulty = 2118 }, -- Cragmaw the Infested
            { journal = 2130, difficulty = 2112 }, -- Sporecaller Zancha
            { journal = 2158, difficulty = 2123 }, -- Unbound Abomination
        }
    },
    [1771] = { -- Tol Dagor
        expansion = 8,
        journalID = 1002,
        encounters = {
            { journal = 2097, difficulty = 2101 }, -- The Sand Queen
            { journal = 2098, difficulty = 2102 }, -- Jes Howlis
            { journal = 2099, difficulty = 2103 }, -- Knight Captain Valyri
            { journal = 2096, difficulty = 2104 }, -- Overseer Korgus
        }
    },
    [1862] = { -- Waycrest Manor
        expansion = 8,
        journalID = 1021,
        encounters = {
            { journal = 2125, difficulty = 2113 }, -- Heartsbane Triad
            { journal = 2126, difficulty = 2114 }, -- Soulbound Goliath
            { journal = 2127, difficulty = 2115 }, -- Raal the Gluttonous
            { journal = 2128, difficulty = 2116 }, -- Lord and Lady Waycrest
            { journal = 2129, difficulty = 2117 }, -- Gorak Tul
        }
    },
    [2291] = { -- De Other Side
        expansion = 9,
        journalID = 1188,
        encounters = {
            { journal = 2408, difficulty = 2395 }, -- Hakkar the Soulflayer
            { journal = 2409, difficulty = 2394 }, -- The Manastorms
            { journal = 2398, difficulty = 2400 }, -- Dealer Xy'exa
            { journal = 2410, difficulty = 2396 }, -- Mueh'zala
        }
    },
    [2287] = { -- Halls of Atonement
        expansion = 9,
        journalID = 1185,
        encounters = {
            { journal = 2406, difficulty = 2401 }, -- Halkias, the Sin-Stained Goliath
            { journal = 2387, difficulty = 2380 }, -- Echelon
            { journal = 2411, difficulty = 2403 }, -- High Adjudicator Aleez
            { journal = 2413, difficulty = 2381 }, -- Lord Chamberlain
        }
    },
    [2290] = { -- Mists of Tirna Scithe
        expansion = 9,
        journalID = 1184,
        encounters = {
            { journal = 2400, difficulty = 2397 }, -- Ingra Maloch
            { journal = 2402, difficulty = 2392 }, -- Mistcaller
            { journal = 2405, difficulty = 2393 }, -- Tred'ova
        }
    },
    [2289] = { -- Plaguefall
        expansion = 9,
        journalID = 1183,
        encounters = {
            { journal = 2419, difficulty = 2382 }, -- Globgrog
            { journal = 2403, difficulty = 2384 }, -- Doctor Ickus
            { journal = 2423, difficulty = 2385 }, -- Domina Venomblade
            { journal = 2404, difficulty = 2386 }, -- Margrave Stradama
        }
    },
    [2284] = { -- Sanguine Depths
        expansion = 9,
        journalID = 1189,
        encounters = {
            { journal = 2388, difficulty = 2360 }, -- Kryxis the Voracious
            { journal = 2415, difficulty = 2361 }, -- Executor Tarvold
            { journal = 2421, difficulty = 2362 }, -- Grand Proctor Beryllia
            { journal = 2407, difficulty = 2363 }, -- General Kaal
        }
    },
    [2285] = { -- Spires of Ascension
        expansion = 9,
        journalID = 1186,
        encounters = {
            { journal = 2399, difficulty = 2357 }, -- Kin-Tara
            { journal = 2416, difficulty = 2356 }, -- Ventunax
            { journal = 2414, difficulty = 2358 }, -- Oryphrion
            { journal = 2412, difficulty = 2359 }, -- Devos, Paragon of Doubt
        }
    },
    [2441] = { -- Tazavesh, the Veiled Market
        expansion = 9,
        journalID = 1194,
        encounters = {
            { journal = 2437, difficulty = 2425 }, -- Zo'phex the Sentinel
            { journal = 2454, difficulty = 2441 }, -- The Grand Menagerie
            { journal = 2436, difficulty = 2424 }, -- Mailroom Mayhem
            { journal = 2452, difficulty = 2440 }, -- Myza's Oasis
            { journal = 2451, difficulty = 2437 }, -- So'azmi
            { journal = 2448, difficulty = 2426 }, -- Hylbrande
            { journal = 2449, difficulty = 2419 }, -- Timecap'n Hooktail
            { journal = 2455, difficulty = 2442 }, -- So'leah
        }
    },
    [2286] = { -- The Necrotic Wake
        expansion = 9,
        journalID = 1182,
        encounters = {
            { journal = 2395, difficulty = 2387 }, -- Blightbone
            { journal = 2391, difficulty = 2388 }, -- Amarth, The Harvester
            { journal = 2392, difficulty = 2389 }, -- Surgeon Stitchflesh
            { journal = 2396, difficulty = 2390 }, -- Nalthor the Rimebinder
        }
    },
    [2293] = { -- Theater of Pain
        expansion = 9,
        journalID = 1187,
        encounters = {
            { journal = 2397, difficulty = 2391 }, -- An Affront of Challengers
            { journal = 2401, difficulty = 2365 }, -- Gorechop
            { journal = 2390, difficulty = 2366 }, -- Xav the Unfallen
            { journal = 2389, difficulty = 2364 }, -- Kul'tharok
            { journal = 2417, difficulty = 2404 }, -- Mordretha, the Endless Empress
        }
    },
    [2526] = { -- Algeth'ar Academy
        expansion = 10,
        journalID = 1201,
        encounters = {
            { journal = 2509, difficulty = 2562 }, -- Vexamus
            { journal = 2512, difficulty = 2563 }, -- Overgrown Ancient
            { journal = 2495, difficulty = 2564 }, -- Crawth
            { journal = 2514, difficulty = 2565 }, -- Echo of Doragosa
        }
    },
    [2520] = { -- Brackenhide Hollow
        expansion = 10,
        journalID = 1196,
        encounters = {
            { journal = 2471, difficulty = 2570 }, -- Hackclaw's War-Band
            { journal = 2473, difficulty = 2568 }, -- Treemouth
            { journal = 2472, difficulty = 2567 }, -- Gutshot
            { journal = 2474, difficulty = 2569 }, -- Decatriarch Wratheye
        }
    },
    [2527] = { -- Halls of Infusion
        expansion = 10,
        journalID = 1204,
        encounters = {
            { journal = 2504, difficulty = 2615 }, -- Watcher Irideus
            { journal = 2507, difficulty = 2616 }, -- Gulping Goliath
            { journal = 2510, difficulty = 2617 }, -- Khajin the Unyielding
            { journal = 2511, difficulty = 2618 }, -- Primal Tsunami
        }
    },
    [2519] = { -- Neltharus
        expansion = 10,
        journalID = 1199,
        encounters = {
            { journal = 2490, difficulty = 2613 }, -- Chargath, Bane of Scales
            { journal = 2489, difficulty = 2612 }, -- Forgemaster Gorek
            { journal = 2494, difficulty = 2610 }, -- Magmatusk
            { journal = 2501, difficulty = 2611 }, -- Warlord Sargha
        }
    },
    [2521] = { -- Ruby Life Pools
        expansion = 10,
        journalID = 1202,
        encounters = {
            { journal = 2488, difficulty = 2609 }, -- Melidrussa Chillworn
            { journal = 2485, difficulty = 2606 }, -- Kokia Blazehoof
            { journal = 2503, difficulty = 2623 }, -- Kyrakka and Erkhart Stormvein
        }
    },
    [2515] = { -- The Azure Vault
        expansion = 10,
        journalID = 1203,
        encounters = {
            { journal = 2492, difficulty = 2582 }, -- Leymor
            { journal = 2505, difficulty = 2585 }, -- Azureblade
            { journal = 2483, difficulty = 2583 }, -- Telash Greywing
            { journal = 2508, difficulty = 2584 }, -- Umbrelskul
        }
    },
    [2516] = { -- The Nokhud Offensive
        expansion = 10,
        journalID = 1198,
        encounters = {
            { journal = 2498, difficulty = 2637 }, -- Granyth
            { journal = 2497, difficulty = 2636 }, -- The Raging Tempest
            { journal = 2478, difficulty = 2581 }, -- Teera and Maruuk
            { journal = 2477, difficulty = 2580 }, -- Balakar Khan
        }
    },
    [2451] = { -- Uldaman: Legacy of Tyr
        expansion = 10,
        journalID = 1197,
        encounters = {
            { journal = 2475, difficulty = 2555 }, -- The Lost Dwarves
            { journal = 2487, difficulty = 2556 }, -- Bromach
            { journal = 2484, difficulty = 2557 }, -- Sentinel Talondras
            { journal = 2476, difficulty = 2558 }, -- Emberon
            { journal = 2479, difficulty = 2559 }, -- Chrono-Lord Deios
        }
    },
    [2579] = { -- Dawn of the Infinite
        expansion = 10,
        journalID = 1209,
        encounters = {
            { journal = 2521, difficulty = 2666 }, -- Chronikar
            { journal = 2528, difficulty = 2667 }, -- Manifested Timeways
            { journal = 2535, difficulty = 2668 }, -- Blight of Galakrond
            { journal = 2537, difficulty = 2669 }, -- Iridikron the Stonescaled
            { journal = 2526, difficulty = 2670 }, -- Tyr, the Infinite Keeper
            { journal = 2536, difficulty = 2671 }, -- Morchie
            { journal = 2534, difficulty = 2672 }, -- Time-Lost Battlefield
            { journal = 2538, difficulty = 2673 }, -- Chrono-Lord Deios
        }
    },
}

-- Expansion names for reference
ns.ExpansionNames = {
    [1] = "Classic",
    [2] = "The Burning Crusade",
    [3] = "Wrath of the Lich King",
    [4] = "Cataclysm",
    [5] = "Mists of Pandaria",
    [6] = "Warlords of Draenor",
    [7] = "Legion",
    [8] = "Battle for Azeroth",
    [9] = "Shadowlands",
    [10] = "Dragonflight",
}
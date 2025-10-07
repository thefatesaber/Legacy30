-- Configuration data for Legacy30 addon
local _, ns = ...

-- Group size restrictions
ns.GroupLimits = {
    minimum = 1,
    maximum = 3
}

-- Mob count thresholds for 100% completion
ns.MobThresholds = {
    [48] = 80,    -- Blackfathom Deeps
    [230] = 474,  -- Blackrock Depths
    [36] = 60,    -- Deadmines
    [429] = 205,  -- Dire Maul
    [90] = 123,   -- Gnomeregan
    [229] = 148,  -- Lower Blackrock Spire
    [349] = 100,  -- Maraudon
    [389] = 46,   -- Ragefire Chasm
    [129] = 46,   -- Razorfen Downs
    [47] = 62,    -- Razorfen Kraul
    [1001] = 46,  -- Scarlet Halls
    [1004] = 72,  -- Scarlet Monastery
    [1007] = 94,  -- Scholomance
    [33] = 100,   -- Shadowfang Keep
    [329] = 118,  -- Stratholme
    [34] = 55,    -- The Stockade
    [109] = 42,   -- Temple of Atal'hakkar
    [70] = 84,    -- Uldaman
    [43] = 141,   -- Wailing Caverns
    [209] = 199,  -- Zul'Farrak
}

-- Dungeon encounter data
ns.Dungeons = {
    [48] = {
        expansion = 1,
        journalID = 227,
        encounters = {
            { journal = 368, difficulty = 1667 },
            { journal = 436, difficulty = 1668 },
            { journal = 426, difficulty = 1669 },
            { journal = 1145, difficulty = 1675 },
            { journal = 447, difficulty = 1676 },
            { journal = 1144, difficulty = 1670 },
            { journal = 437, difficulty = 1671 },
            { journal = 444, difficulty = 1672 },
        }
    },
    
    [230] = {
        expansion = 1,
        journalID = 228,
        encounters = {
            { journal = 369, difficulty = 227 },
            { journal = 370, difficulty = 228 },
            { journal = 371, difficulty = 229 },
            { journal = 372, difficulty = 230 },
            { journal = 373, difficulty = 231 },
            { journal = 374, difficulty = 232 },
            { journal = 375, difficulty = 233 },
            { journal = 376, difficulty = 234 },
            { journal = 377, difficulty = 235 },
            { journal = 378, difficulty = 236 },
            { journal = 379, difficulty = 237 },
            { journal = 380, difficulty = 238 },
            { journal = 381, difficulty = 239 },
            { journal = 383, difficulty = 241 },
            { journal = 384, difficulty = 242 },
            { journal = 385, difficulty = 243 },
            { journal = 386, difficulty = 244 },
            { journal = 387, difficulty = 245 },
        }
    },
    
    [36] = {
        expansion = 1,
        journalID = 63,
        encounters = {
            { journal = 89, difficulty = 1064 },
            { journal = 90, difficulty = 1065 },
            { journal = 91, difficulty = 1063 },
            { journal = 92, difficulty = 1062 },
            { journal = 93, difficulty = 1060 },
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
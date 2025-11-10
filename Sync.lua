-- Sync.lua for Legacy30
-- Handles party synchronization of mob kills and timer starts
local _, ns = ...
local L30 = ns.Core

-- Libraries for serialization and compression
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

-- Communication protocol prefixes
ns.Protocol = {
    CREATURE_SYNC = "L30_MOBKILL",
    TIMER_START = "L30_START",
    BOSS_KILL = "L30_BOSS",
    DEATH_SYNC = "L30_DEATH"
}

-- IMPORTANT: Define OnCommReceived BEFORE registering it
-- Handle incoming messages - MUST be on L30.Addon for AceComm
function L30.Addon:OnCommReceived(prefix, payload, distribution, sender)
    -- Don't process messages from ourselves
    if sender == UnitName("player") then
        return
    end
    
    -- Decode the payload
    local decoded = LibDeflate:DecodeForWoWAddonChannel(payload)
    if not decoded then
        return
    end
    
    -- Decompress the payload
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then
        return
    end
    
    -- Deserialize the data
    local success, data = LibSerialize:Deserialize(decompressed)
    if not success then
        return
    end
    
    -- Route to appropriate handler on L30 Core
    if prefix == ns.Protocol.CREATURE_SYNC then
        L30:OnSyncCreatureKill(data, sender)
    elseif prefix == ns.Protocol.TIMER_START then
        L30:OnSyncTimerStart(data, sender)
    elseif prefix == ns.Protocol.BOSS_KILL then
        L30:OnSyncBossKill(data, sender)
    elseif prefix == ns.Protocol.DEATH_SYNC then
        L30:OnSyncDeath(data, sender)
    end
end

-- NOW register communication prefixes AFTER OnCommReceived is defined
if L30.Addon then
    for _, prefix in pairs(ns.Protocol) do
        L30.Addon:RegisterComm(prefix)
    end
end

-- Send a message to the party
function L30:BroadcastMessage(prefix, data, whisperTarget)
    -- Don't broadcast if not in a group
    if not IsInGroup() then
        return
    end
    
    -- Serialize the data
    local serialized = LibSerialize:Serialize(data)
    
    -- Compress the serialized data
    local compressed = LibDeflate:CompressDeflate(serialized)
    
    -- Encode for WoW addon channel
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    
    -- Determine distribution type
    local distribution = whisperTarget and "WHISPER" or "PARTY"
    
    -- Send the message
    if L30.Addon and L30.Addon.SendCommMessage then
        L30.Addon:SendCommMessage(prefix, encoded, distribution, whisperTarget, "BULK")
    end
end

-- Handle synced creature kill
function L30:OnSyncCreatureKill(creatureGUID, sender)
    if not ns.TimerUI or not ns.TimerUI.sessionData.running then
        return
    end
    
    -- Add the creature to our count (will auto-deduplicate via GUID)
    if ns.TimerUI.IncrementCreatureCount then
        ns.TimerUI:IncrementCreatureCount(creatureGUID)
    end
end

-- Handle synced timer start
function L30:OnSyncTimerStart(startTimestamp, sender)
    -- If we don't have a timer running, start one with the synced time
    if not ns.TimerUI or not ns.TimerUI.sessionData.running then
        self:AttemptTimerStart(startTimestamp)
    end
end

-- Handle synced boss kill
function L30:OnSyncBossKill(data, sender)
    local encounterID = data.encounterID
    local encounterName = data.encounterName
    
    if encounterID then
        ns.DefeatedBosses[encounterID] = true
        self:InfoMessage("Synced boss kill from %s: %s", sender, encounterName or "Unknown")
        self:OnBossProgress()
    end
end

-- Broadcast a creature kill to the party
function L30:BroadcastCreatureKill(creatureGUID)
    if IsInGroup() then
        self:BroadcastMessage(ns.Protocol.CREATURE_SYNC, creatureGUID)
    end
end

-- Broadcast timer start to the party
function L30:BroadcastTimerStart(startTimestamp)
    if IsInGroup() then
        self:BroadcastMessage(ns.Protocol.TIMER_START, startTimestamp)
    end
end

-- Broadcast boss kill to the party
function L30:BroadcastBossKill(encounterID, encounterName)
    if IsInGroup() then
        self:BroadcastMessage(ns.Protocol.BOSS_KILL, {
            encounterID = encounterID,
            encounterName = encounterName
        })
    end
end

-- Handle synced death - FIXED to prevent double counting
function L30:OnSyncDeath(playerName, sender)
    if not ns.TimerUI or not ns.TimerUI.sessionData.running then
        return
    end
    
    -- DO NOT increment death count from sync messages
    -- Deaths are only counted locally by the person who sees them in combat log
    -- This prevents double-counting:
    --   - Player A dies -> their client counts it locally
    --   - Player A broadcasts death to party
    --   - Everyone else would count it again = DOUBLE COUNT
    -- Solution: Only count locally, ignore sync messages
    
    -- Optional: Log for debugging (commented out to reduce spam)
    -- self:InfoMessage("Death synced from %s: %s", sender, playerName)
end

-- Broadcast death to the party
function L30:BroadcastDeath(playerName)
    if IsInGroup() then
        self:BroadcastMessage(ns.Protocol.DEATH_SYNC, playerName)
    end
end
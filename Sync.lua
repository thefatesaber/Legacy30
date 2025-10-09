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
    BOSS_KILL = "L30_BOSS"
}

-- Register communication prefixes
if L30.Addon then
    for _, prefix in pairs(ns.Protocol) do
        L30.Addon:RegisterComm(prefix, function(prefix, payload, distribution, sender)
            L30:OnCommReceived(prefix, payload, distribution, sender)
        end)
    end
end

-- Handle incoming messages
function L30:OnCommReceived(prefix, payload, distribution, sender)
    -- Don't process messages from ourselves
    if sender == UnitName("player") then
        return
    end
    
    -- Decode the payload
    local decoded = LibDeflate:DecodeForWoWAddonChannel(payload)
    if not decoded then
        self:ErrorMessage("Failed to decode message from %s", sender)
        return
    end
    
    -- Decompress the payload
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then
        self:ErrorMessage("Failed to decompress message from %s", sender)
        return
    end
    
    -- Deserialize the data
    local success, data = LibSerialize:Deserialize(decompressed)
    if not success then
        self:ErrorMessage("Failed to deserialize message from %s", sender)
        return
    end
    
    -- Route to appropriate handler
    if prefix == ns.Protocol.CREATURE_SYNC then
        self:OnSyncCreatureKill(data, sender)
    elseif prefix == ns.Protocol.TIMER_START then
        self:OnSyncTimerStart(data, sender)
    elseif prefix == ns.Protocol.BOSS_KILL then
        self:OnSyncBossKill(data, sender)
    end
end

-- Send a message to the party
function L30:BroadcastMessage(prefix, data, whisperTarget)
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
    
    -- Add the creature to our count
    if ns.TimerUI.IncrementCreatureCount then
        ns.TimerUI:IncrementCreatureCount(creatureGUID)
        self:InfoMessage("Synced mob kill from %s", sender)
    end
end

-- Handle synced timer start
function L30:OnSyncTimerStart(startTimestamp, sender)
    self:InfoMessage("Received timer sync from %s", sender)
    
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
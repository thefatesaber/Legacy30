-- Legacy30 Dungeon Timer
-- Original implementation for speedrunning legacy content

local ADDON_NAME, ns = ...
local L30 = {}
ns.Core = L30

-- Build info check for compatibility
local BUILD_VERSION = select(4, GetBuildInfo())
if BUILD_VERSION < 100206 then
    -- Wrapper functions for older client versions
    C_Item.IsEquippableItem = IsEquippableItem
    C_Item.IsEquippedItemType = IsEquippedItemType
    C_Item.GetItemInfo = GetItemInfo
    C_Item.GetItemInfoInstant = GetItemInfoInstant
    C_Item.IsCosmeticItem = IsCosmeticItem
end

-- Communication protocol identifiers
ns.Protocol = {
    CREATURE_SYNC = "L30_CreatureSync",
    TIMER_START = "L30_TimerStart",
    GEAR_CHECK = "L30_GearCheck",
    GEAR_DETAILS = "L30_GearDetails",
}

-- Initialize the addon using Ace3
L30.Addon = LibStub("AceAddon-3.0"):NewAddon(
    ADDON_NAME, 
    "AceConsole-3.0", 
    "AceEvent-3.0", 
    "AceComm-3.0"
)

-- Store references to libraries
ns.GUI = LibStub("AceGUI-3.0")
ns.Media = LibStub("LibSharedMedia-3.0")
ns.Version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")

-- Utility: Check if running on PTR
function L30:IsPTREnvironment()
    return GetCVar("portal") == "test"
end

-- Utility: Formatted print with arguments
function L30:InfoMessage(msg, ...)
    local formatted = ... and string.format(msg, ...) or msg
    self.Addon:Print(formatted or "")
end

-- Utility: Error message
function L30:ErrorMessage(msg, ...)
    self:InfoMessage("|cFFe74c3cError:|r " .. msg, ...)
end

-- Utility: Toggle status message
function L30:StatusMessage(enabled, feature)
    local statusColor = enabled and "FF2ecc71" or "FFe74c3c"
    local statusText = enabled and "enabled" or "disabled"
    self:InfoMessage("%s is now |c%s%s|r", feature, statusColor, statusText)
end

-- Initialize saved variables and setup
function L30.Addon:OnInitialize()
    -- Set up persistent storage
    Legacy30DB = Legacy30DB or {
        records = {},
        runHistory = {},
        preferences = {
            position = { "RIGHT" },
            uiScale = 1
        }
    }
    self.database = Legacy30DB
    
    -- Register slash commands
    self:RegisterChatCommand("legacy30", "ProcessCommand")
    self:RegisterChatCommand("l30", "ProcessCommand")
    self:RegisterChatCommand("rl", C_UI.Reload)
    
    -- Register game events
    self:RegisterEvent("SCENARIO_CRITERIA_UPDATE", "OnBossProgress")
    self:RegisterEvent("BOSS_KILL", "OnBossDefeat")
    self:RegisterEvent("RAID_INSTANCE_WELCOME", "OnInstanceEntry")
    self:RegisterEvent("UPDATE_INSTANCE_INFO", "OnInstanceEntry")
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "OnInstanceEntry")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "OnZoneTransition")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatEvent")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Initialize item database if the module exists
    if ns.ItemDB and ns.ItemDB.Initialize then
        ns.ItemDB:Initialize()
    end
    
    L30:InfoMessage("Legacy30 v%s loaded", ns.Version)
end

-- Retrieve best time for a dungeon
function L30:GetBestRecord(dungeonID, bossNumber)
    if not self.Addon.database then return nil end
    
    local records = self.Addon.database.records
    records[dungeonID] = records[dungeonID] or {}
    
    if bossNumber then
        return records[dungeonID][bossNumber]
    else
        return records[dungeonID].fullRun
    end
end

-- Collect active talents
local function GatherTalentData()
    local talents = {}
    local configID = C_ClassTalents.GetActiveConfigID()
    if not configID then return talents end
    
    local configInfo = C_Traits.GetConfigInfo(configID)
    if not configInfo then return talents end
    
    for _, treeID in ipairs(configInfo.treeIDs) do
        local nodes = C_Traits.GetTreeNodes(treeID)
        for _, nodeID in ipairs(nodes) do
            local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
            if nodeInfo and nodeInfo.entryIDsWithCommittedRanks then
                for _, entryID in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
                    local entryInfo = C_Traits.GetEntryInfo(configID, entryID)
                    if entryInfo and entryInfo.definitionID then
                        local defInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID)
                        if defInfo and defInfo.spellID then
                            table.insert(talents, defInfo.spellID)
                        end
                    end
                end
            end
        end
    end
    return talents
end

-- Collect equipped items
local function GatherEquipmentData()
    local equipment = {}
    for slot = 1, 19 do
        local link = GetInventoryItemLink("player", slot)
        if link then
            equipment[slot] = link
        end
    end
    return equipment
end

-- Save a new record
function L30:SaveRecord(dungeonID, bossNumber, timeSeconds, completeData)
    if not self.Addon.database then return end
    
    local records = self.Addon.database.records
    if not self.Addon.database.runHistory then 
        self.Addon.database.runHistory = {} 
    end
    
    records[dungeonID] = records[dungeonID] or {}
    
    if completeData then
        -- Full run completion
        local previousBest = records[dungeonID].fullRun
        if not previousBest or previousBest > timeSeconds then
            records[dungeonID].fullRun = timeSeconds
            records[dungeonID].recordID = completeData.sessionID
            
            L30:InfoMessage("New record! Completed in %s", ns.Utils.FormatTime(timeSeconds))
        end
        
        -- Save detailed history
        local realmName = GetRealmName()
        local groupMembers = {}
        
        -- Collect party member data
        if IsInGroup() then
            for i = 1, GetNumGroupMembers() - 1 do
                local unitID = (IsInRaid() and "raid" or "party") .. i
                if UnitExists(unitID) then
                    local name, realm = UnitName(unitID)
                    groupMembers[unitID] = {
                        name = name,
                        realm = realm or realmName,
                        class = UnitClassBase(unitID),
                        role = UnitGroupRolesAssigned(unitID)
                    }
                end
            end
        end
        
        -- Always include player data
        local playerName, playerRealm = UnitName("player")
        groupMembers["player"] = {
            name = playerName,
            realm = playerRealm or realmName,
            class = UnitClassBase("player"),
            role = UnitGroupRolesAssigned("player")
        }
        
        table.insert(self.Addon.database.runHistory, {
            dungeonID = dungeonID,
            dungeonInfo = ns.Dungeons and ns.Dungeons[dungeonID] or nil,
            version = ns.Version,
            buildVersion = BUILD_VERSION,
            timestamp = time(),
            totalTime = timeSeconds,
            runData = completeData,
            playerData = {
                name = playerName,
                realm = playerRealm or realmName,
                class = UnitClassBase("player"),
                role = UnitGroupRolesAssigned("player"),
                specialization = PlayerUtil.GetCurrentSpecID(),
                talents = GatherTalentData(),
                equipment = GatherEquipmentData()
            },
            groupData = groupMembers
        })
    else
        -- Individual boss record
        local previousBest = records[dungeonID][bossNumber]
        if not previousBest or previousBest > timeSeconds then
            records[dungeonID][bossNumber] = timeSeconds
        end
    end
end

-- Enable communication channels
function L30.Addon:OnEnable()
    -- Register communication channels
    for _, channel in pairs(ns.Protocol) do
        self:RegisterComm(channel)
    end
    
    -- Apply UI settings
    L30:ApplyUISettings()
    
    -- Initialize network module if available
    if ns.Network and ns.Network.Initialize then
        ns.Network:Initialize()
    end
end

-- Apply UI preferences
function L30:ApplyUISettings()
    if not ns.TimerUI then return end
    
    local timerFrame = ns.TimerUI
    local prefs = self.Addon.database.preferences
    
    if prefs and timerFrame.ApplySettings then
        timerFrame:ApplySettings(prefs.uiScale, prefs.position)
    end
end

-- Export namespace for other modules
_G.Legacy30 = L30
_G.Legacy30NS = ns
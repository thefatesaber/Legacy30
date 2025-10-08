-- Events.lua
-- Event handlers for Legacy30 dungeon timer

local ADDON_NAME, ns = ...
local L30 = ns.Core
local addon = L30.Addon

-- Track instance state
local instanceState = {
    currentInstance = nil,
    inDungeon = false,
    timerActive = false,
    lastZone = nil
}

-- Check if in a valid legacy dungeon
local function IsInLegacyDungeon()
    local name, instanceType, difficultyID, _, maxPlayers = GetInstanceInfo()
    
    -- Check if it's a dungeon/raid instance
    if instanceType ~= "party" and instanceType ~= "raid" then
        return false
    end
    
    -- Check if the dungeon is in our database
    if ns.Dungeons then
        for dungeonID, dungeonData in pairs(ns.Dungeons) do
            if dungeonData.name == name then
                return true, dungeonID, dungeonData
            end
        end
    end
    
    return false
end

-- Boss progress update handler
function addon:OnBossProgress(event, ...)
    if not instanceState.timerActive then return end
    
    -- Update timer UI if available
    if ns.TimerUI and ns.TimerUI.OnCriteriaUpdate then
        ns.TimerUI:OnCriteriaUpdate()
    end
    
    L30:InfoMessage("Boss progress updated")
end

-- Boss defeated handler
function addon:OnBossDefeat(event, ...)
    local encounterID, encounterName = ...
    
    if not instanceState.timerActive then return end
    
    L30:InfoMessage("Boss defeated: %s", encounterName or "Unknown")
    
    -- Notify timer UI
    if ns.TimerUI and ns.TimerUI.OnBossKill then
        ns.TimerUI:OnBossKill(encounterID, encounterName)
    end
    
    -- Save boss-specific record
    if instanceState.currentInstance then
        local elapsedTime = ns.TimerUI and ns.TimerUI:GetElapsedTime() or 0
        if elapsedTime > 0 then
            L30:SaveRecord(instanceState.currentInstance, encounterID, elapsedTime)
        end
    end
end

-- Instance entry handler
function addon:OnInstanceEntry(event, ...)
    local inInstance, instanceType = IsInInstance()
    
    if not inInstance then
        -- Left instance
        if instanceState.inDungeon then
            L30:InfoMessage("Left dungeon")
            instanceState.inDungeon = false
            instanceState.timerActive = false
            
            -- Hide timer UI
            if ns.TimerUI and ns.TimerUI.Hide then
                ns.TimerUI:Hide()
            end
        end
        return
    end
    
    -- Check if in a legacy dungeon
    local isLegacy, dungeonID, dungeonData = IsInLegacyDungeon()
    
    if isLegacy then
        instanceState.inDungeon = true
        instanceState.currentInstance = dungeonID
        
        L30:InfoMessage("Entered: %s", dungeonData.name or "Legacy Dungeon")
        
        -- Show timer UI
        if ns.TimerUI and ns.TimerUI.Show then
            ns.TimerUI:Show(dungeonID, dungeonData)
        end
    end
end

-- Group roster update handler
function addon:OnGroupUpdate(event, ...)
    -- Check if still in a valid group
    if IsInGroup() then
        if ns.Network and ns.Network.OnGroupUpdate then
            ns.Network:OnGroupUpdate()
        end
    else
        -- Solo now, may need to adjust UI
        if ns.TimerUI and ns.TimerUI.OnSolo then
            ns.TimerUI:OnSolo()
        end
    end
end

-- Zone transition handler
function addon:OnZoneTransition(event, ...)
    local newZone = GetZoneText()
    
    if newZone ~= instanceState.lastZone then
        instanceState.lastZone = newZone
        
        -- Recheck if in dungeon
        self:OnInstanceEntry(event)
    end
end

-- Combat log event handler
function addon:OnCombatEvent(event, ...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, _, 
          destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()
    
    -- Track important combat events for validation
    if subevent == "SPELL_CAST_SUCCESS" then
        -- Track player abilities for validation
        if sourceGUID == UnitGUID("player") then
            if ns.Validation and ns.Validation.TrackAbility then
                local spellID, spellName = select(12, CombatLogGetCurrentEventInfo())
                ns.Validation:TrackAbility(spellID, timestamp)
            end
        end
    elseif subevent == "UNIT_DIED" then
        -- Track boss deaths
        if destGUID and destFlags then
            local unitType = bit.band(destFlags, COMBATLOG_OBJECT_TYPE_MASK)
            if unitType == COMBATLOG_OBJECT_TYPE_NPC then
                -- Could be a boss
                if ns.TimerUI and ns.TimerUI.OnUnitDied then
                    ns.TimerUI:OnUnitDied(destGUID, destName)
                end
            end
        end
    end
end

-- Player entering world handler
function addon:OnPlayerEntering(event, ...)
    local isLogin, isReload = ...
    
    if isLogin or isReload then
        L30:InfoMessage("Welcome back!")
        
        -- Apply saved settings
        L30:ApplyUISettings()
        
        -- Check if in instance
        self:OnInstanceEntry(event)
    end
end

-- Utility: Get current instance state
function L30:GetInstanceState()
    return instanceState
end

-- Utility: Check if timer is active
function L30:IsTimerActive()
    return instanceState.timerActive
end

-- Utility: Start timer manually
function L30:StartTimer()
    if not instanceState.inDungeon then
        L30:ErrorMessage("Not in a dungeon")
        return false
    end
    
    instanceState.timerActive = true
    
    if ns.TimerUI and ns.TimerUI.StartTimer then
        ns.TimerUI:StartTimer()
    end
    
    L30:InfoMessage("Timer started")
    return true
end

-- Utility: Stop timer manually
function L30:StopTimer()
    instanceState.timerActive = false
    
    if ns.TimerUI and ns.TimerUI.StopTimer then
        ns.TimerUI:StopTimer()
    end
    
    L30:InfoMessage("Timer stopped")
    return true
end

-- Utility: Reset timer
function L30:ResetTimer()
    instanceState.timerActive = false
    
    if ns.TimerUI and ns.TimerUI.ResetTimer then
        ns.TimerUI:ResetTimer()
    end
    
    L30:InfoMessage("Timer reset")
    return true
end
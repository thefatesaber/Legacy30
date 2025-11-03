-- Event handling system for Legacy30
local _, ns = ...
local L30 = ns.Core

-- Track defeated bosses
ns.DefeatedBosses = {}

-- Player enters world
function L30.Addon:PLAYER_ENTERING_WORLD(_, isLogin, isReload)
    L30:CheckZone()
    
    if isLogin or isReload then
        ns.ItemDatabase = ns.ItemDatabase or {}
    end
end

-- Instance entry detection - simplified
function L30:OnInstanceEntry()
    L30:CheckZone()
end

-- Check zone and show/hide timer - ONLY for configured dungeons
function L30:CheckZone()
    local inInstance, instanceType = IsInInstance()
    
    if inInstance and instanceType == "party" then
        local dungeonName, _, _, _, _, _, _, dungeonID = GetInstanceInfo()
        
        -- STRICT CHECK: Only show timer for dungeons in Settings.lua
        if ns.Dungeons and ns.Dungeons[dungeonID] then
            L30:InfoMessage("In configured dungeon: %s (ID: %d)", dungeonName or "Unknown", dungeonID)
            
            -- Show timer frame
            if ns.TimerUI and ns.TimerUI.frame then
                ns.TimerUI.frame:Show()
                L30:InfoMessage("Timer frame shown")
            else
                L30:ErrorMessage("Timer frame doesn't exist!")
            end
            
            -- Auto-start timer if not already running
            if not ns.TimerUI.sessionData.running then
                C_Timer.After(1.5, function()
                    if IsInInstance() and not ns.TimerUI.sessionData.running then
                        L30:InfoMessage("Auto-starting timer...")
                        L30:AttemptTimerStart(GetServerTime())
                    end
                end)
            end
        else
            L30:InfoMessage("Dungeon ID %d NOT configured in Settings.lua - timer hidden", dungeonID or 0)
            -- Unregister combat log when not in configured dungeon
            L30.Addon:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
    else
        -- Not in dungeon, hide timer and unregister combat log
        if ns.TimerUI and ns.TimerUI.frame then
            ns.TimerUI.frame:Hide()
        end
        L30.Addon:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        
        -- Cancel pull timer if leaving instance
        if ns.PullTimer and ns.PullTimer.active then
            ns.PullTimer:Cancel()
        end
    end
end

-- Boss defeat event
function L30:OnBossDefeat(_, defeatedBossID)
    ns.DefeatedBosses[defeatedBossID] = true
    self:OnBossProgress()
end

-- Get death status from scenario criteria
-- Note: Scenario API is unreliable in modern WoW, so we primarily rely on ENCOUNTER_END events
local function FindBossDeathInCriteria(bossName)
    -- For Mythic+ and modern dungeons, we rely on the ENCOUNTER_END event
    -- This function is kept for compatibility but returns true by default
    return true
end

-- Retrieve boss information from Settings.lua
function L30:GetBossData(dungeonID)
    local sessionData = ns.TimerUI.sessionData
    dungeonID = dungeonID or sessionData.dungeonID
    
    -- Check if dungeon exists in Settings.lua
    if not ns.Dungeons or not ns.Dungeons[dungeonID] then
        L30:ErrorMessage("Dungeon ID %d not found in Settings.lua", dungeonID)
        return {}, 0
    end
    
    local dungeonInfo = ns.Dungeons[dungeonID]
    local encounters = dungeonInfo.encounters
    local bossData = {}
    
    -- Build boss list from Settings.lua encounters
    for i, encounter in ipairs(encounters) do
        local bossName = EJ_GetEncounterInfo(encounter.journal)
        
        -- Check if boss is defeated using multiple methods
        -- Priority: Manual tracking > Encounter Journal completion
        -- NOTE: Only check difficulty ID to avoid collisions (Blizzard reuses journal IDs across bosses)
        local isDefeated = ns.DefeatedBosses[encounter.difficulty] or 
                          C_EncounterJournal.IsEncounterComplete(encounter.journal) or
                          false
        
        table.insert(bossData, {
            name = bossName,
            encounterID = encounter.difficulty,
            journalID = encounter.journal,
            defeated = isDefeated,
            timeElapsed = (GetServerTime() - (sessionData.startTimestamp or GetServerTime()))
        })
    end
    
    local totalBosses = #encounters
    
    -- Debug log - only show once per dungeon session
    if totalBosses > 0 and not sessionData.bossDataLogged then
        sessionData.bossDataLogged = true
        L30:InfoMessage("Loaded %d bosses from Settings.lua for dungeon %d", totalBosses, dungeonID)
    end
    
    return bossData, totalBosses
end

-- Update boss progress
function L30:OnBossProgress()
    local timerFrame = ns.TimerUI
    if timerFrame and timerFrame.sessionData and timerFrame.sessionData.running then
        local bossData = self:GetBossData()
        timerFrame:RefreshBosses(bossData)
        
        -- Force display update
        timerFrame:UpdateDisplay()
    end
end

-- Attempt to start timer - STRICT: Only for configured dungeons
function L30:AttemptTimerStart(startTimestamp)
    startTimestamp = tonumber(startTimestamp) or GetServerTime()
    
    local dungeonName, _, _, difficulty, _, _, _, dungeonID = GetInstanceInfo()
    
    if not dungeonName or not dungeonID then
        L30:ErrorMessage("Could not get instance info")
        return
    end
    
    -- STRICT CHECK: Must be in Settings.lua
    if not ns.Dungeons or not ns.Dungeons[dungeonID] then
        L30:ErrorMessage("Dungeon ID %d NOT configured in Settings.lua - cannot start timer", dungeonID)
        return
    end
    
    if not ns.MobThresholds or not ns.MobThresholds[dungeonID] then
        L30:ErrorMessage("Mob threshold for dungeon ID %d NOT found in Settings.lua", dungeonID)
        return
    end
    
    L30:InfoMessage("Starting timer for: %s (ID: %d)", dungeonName, dungeonID)
    
    -- Reset tracking data
    ns.DefeatedBosses = {}
    
    -- Get boss data from Settings.lua
    local bossData, totalBosses = self:GetBossData(dungeonID)
    local mobThreshold = ns.MobThresholds[dungeonID]
    
    L30:InfoMessage("Bosses: %d | Mob threshold: %d", totalBosses, mobThreshold)
    
    local bossRecords = {}
    for i = 1, totalBosses do
        bossRecords[i] = self:GetBestRecord(dungeonID, i)
    end
    
    local sessionInfo = {
        dungeonName = dungeonName,
        difficulty = difficulty,
        startTimestamp = startTimestamp,
        bestTime = self:GetBestRecord(dungeonID),
        totalBosses = totalBosses,
        bossData = bossData,
        dungeonID = dungeonID,
        bossRecords = bossRecords
    }
    
    -- Initialize timer
    ns.TimerUI:Initialize(sessionInfo)
    
    -- Make sure timer is visible
    if ns.TimerUI.frame then
        ns.TimerUI.frame:Show()
        L30:InfoMessage("Timer visible and running")
    end
    
    -- Register combat log events
    L30.Addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    L30:InfoMessage("Combat log tracking enabled")
    
    -- Register encounter events for boss detection
    L30.Addon:RegisterEvent("ENCOUNTER_END")
    L30.Addon:RegisterEvent("BOSS_KILL")
    
    -- Start tracking boss updates every 2 seconds
    C_Timer.NewTicker(2, function()
        if ns.TimerUI.sessionData.running then
            L30:OnBossProgress()
        end
    end)
    
    -- Broadcast timer start to group (if in group and function exists)
    if IsInGroup() and self.BroadcastTimerStart then
        self:BroadcastTimerStart(startTimestamp)
    end
end

-- Zone transition handler
function L30:OnZoneTransition()
    L30:CheckZone()
end

-- Run completion
function L30:OnRunComplete(sessionInfo, totalTime)
    self:SaveRecord(sessionInfo.dungeonID, nil, totalTime, sessionInfo)
    
    -- Unregister combat log when run completes
    L30.Addon:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    L30.Addon:UnregisterEvent("ENCOUNTER_END")
    L30.Addon:UnregisterEvent("BOSS_KILL")
end

-- Boss defeat timing
function L30:OnBossTiming(dungeonID, elapsedTime, bossNumber)
    self:SaveRecord(dungeonID, bossNumber, elapsedTime)
end

-- Handle ENCOUNTER_END event (fired when boss is defeated)
function L30.Addon:ENCOUNTER_END(_, encounterID, encounterName, difficultyID, groupSize, success)
    if success == 1 then
        L30:InfoMessage("Boss defeated: %s (Encounter ID: %d)", encounterName, encounterID)
        
        -- Mark boss as defeated
        ns.DefeatedBosses[encounterID] = true
        
        -- Broadcast to party if function exists
        if IsInGroup() and L30.BroadcastBossKill then
            L30:BroadcastBossKill(encounterID, encounterName)
        end
        
        -- Find which boss index this corresponds to
        if ns.TimerUI.sessionData and ns.TimerUI.sessionData.bossData then
            for i, boss in ipairs(ns.TimerUI.sessionData.bossData) do
                -- Match by journal ID or encounter ID
                if boss.journalID == encounterID or boss.encounterID == encounterID then
                    -- Mark this boss as defeated in our data
                    boss.defeated = true
                    break
                end
            end
        end
        
        L30:OnBossProgress()
    end
end

-- Handle BOSS_KILL event (alternative boss detection)
function L30.Addon:BOSS_KILL(_, encounterID, encounterName)
    L30:InfoMessage("Boss killed: %s (ID: %d)", encounterName, encounterID)
    ns.DefeatedBosses[encounterID] = true
    L30:OnBossProgress()
end

-- Combat log events
function L30.Addon:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, _, 
          destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()
    
    if subevent == "UNIT_DIED" then
        -- Check if it's a player death (party member)
        local isPlayer = bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
        
        if isPlayer then
            -- Track player death
            if ns.TimerUI and ns.TimerUI.sessionData.running and ns.TimerUI.IncrementDeathCount then
                ns.TimerUI:IncrementDeathCount()
                L30:InfoMessage("%s died", destName or "Player")
                
                -- Broadcast death to party if function exists
                if IsInGroup() and L30.BroadcastDeath then
                    L30:BroadcastDeath(destName)
                end
            end
        else
            -- Check if it's an enemy NPC
            local isEnemy = not (bit.band(destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0)
            local isNPC = bit.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) > 0
            
            if isEnemy and isNPC then
                -- Always track locally first
                if ns.TimerUI and ns.TimerUI.IncrementCreatureCount then
                    ns.TimerUI:IncrementCreatureCount(destGUID)
                end
                
                -- Broadcast to party members if function exists
                if IsInGroup() and L30.BroadcastCreatureKill then
                    L30:BroadcastCreatureKill(destGUID)
                end
            end
        end
    end
end

-- Stop the current timer
function L30:StopTimer()
    if not ns.TimerUI or not ns.TimerUI.sessionData.running then
        self:InfoMessage("No timer is currently running")
        return
    end
    
    ns.TimerUI.sessionData.running = false
    
    -- Unregister combat events
    L30.Addon:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    L30.Addon:UnregisterEvent("ENCOUNTER_END")
    L30.Addon:UnregisterEvent("BOSS_KILL")
    
    self:InfoMessage("Timer stopped")
end

-- Reset the timer (stop and clear data)
function L30:ResetTimer()
    -- Stop the timer first
    self:StopTimer()
    
    -- Clear session data
    if ns.TimerUI then
        ns.TimerUI.sessionData = {
            running = false,
            dungeonID = nil,
            startTimestamp = nil,
            bossData = {},
            totalBosses = 0,
            mobCount = 0,
            mobList = {},
            sessionID = nil
        }
        
        -- Reset display
        ns.TimerUI.frame.timerText:SetText("00:00")
        ns.TimerUI.frame.mobText:SetText("Mobs: 0 (0%)")
        ns.TimerUI.frame.bossText:SetText("Bosses: 0/0")
        ns.TimerUI.frame.bestText:SetText("Best: --:--")
    end
    
    -- Clear defeated bosses
    ns.DefeatedBosses = {}
    
    self:InfoMessage("Timer reset")
end

-- Restart the timer (reset and start fresh)
function L30:RestartTimer()
    self:InfoMessage("Restarting timer...")
    
    -- Get current dungeon info before resetting
    local dungeonName, _, _, difficulty, _, _, _, dungeonID = GetInstanceInfo()
    
    if not dungeonID or not ns.Dungeons or not ns.Dungeons[dungeonID] then
        self:ErrorMessage("Cannot restart - not in a configured dungeon")
        return
    end
    
    -- Reset everything
    self:ResetTimer()
    
    -- Wait a moment then start fresh
    C_Timer.After(0.5, function()
        self:AttemptTimerStart(GetServerTime())
    end)
end

-- ============================================================================
-- PULL TIMER SYSTEM
-- ============================================================================

local PullTimer = {
    active = false,
    remaining = 0,
    frame = nil,
    ticker = nil,
    totalSeconds = 0
}

-- Create pull timer frame
function PullTimer:CreateFrame()
    if self.frame then return self.frame end
    
    local frame = CreateFrame("Frame", "Legacy30PullTimer", UIParent, "BackdropTemplate")
    frame:SetSize(300, 150)
    frame:SetPoint("CENTER", 0, 150)
    frame:SetFrameStrata("HIGH")
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.9)
    frame:SetBackdropBorderColor(1, 0.8, 0, 1)
    frame:Hide()
    
    -- Title text
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    frame.title:SetPoint("TOP", 0, -15)
    frame.title:SetText("Pull Timer")
    frame.title:SetTextColor(1, 0.8, 0, 1)
    
    -- Countdown text (large)
    frame.countdown = frame:CreateFontString(nil, "OVERLAY")
    frame.countdown:SetFont("Fonts\\FRIZQT__.TTF", 72, "OUTLINE")
    frame.countdown:SetPoint("CENTER", 0, 10)
    frame.countdown:SetText("10")
    frame.countdown:SetTextColor(1, 1, 1, 1)
    
    -- Status text
    frame.status = frame:CreateFontString(nil, "OVERLAY")
    frame.status:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    frame.status:SetPoint("BOTTOM", 0, 15)
    frame.status:SetText("Timer will start automatically")
    frame.status:SetTextColor(0.7, 0.7, 0.7, 1)
    
    self.frame = frame
    return frame
end

-- Start pull timer
function PullTimer:Start(seconds)
    if self.active then
        if ns.Core then
            ns.Core:ErrorMessage("Pull timer already active")
        end
        return
    end
    
    -- Create frame if needed
    if not self.frame then
        self:CreateFrame()
    end
    
    self.totalSeconds = seconds
    self.remaining = seconds
    self.active = true
    
    -- Show frame
    self.frame:Show()
    self:UpdateDisplay()
    
    -- Play pull sound
    PlaySound(8960, "Master")  -- Ready check sound
    
    if ns.Core then
        ns.Core:InfoMessage("Pull timer started: %d seconds", seconds)
    end
    
    -- Start countdown ticker
    self.ticker = C_Timer.NewTicker(1, function()
        self:Tick()
    end)
end

-- Tick countdown
function PullTimer:Tick()
    if not self.active then
        self:Cancel()
        return
    end
    
    self.remaining = self.remaining - 1
    self:UpdateDisplay()
    
    -- Play sounds at key intervals
    if self.remaining == 5 then
        PlaySound(8959, "Master")  -- Warning sound
    elseif self.remaining <= 3 and self.remaining > 0 then
        PlaySound(8458, "Master")  -- Countdown beep
    elseif self.remaining == 0 then
        PlaySound(8232, "Master")  -- GO! sound
        self:Complete()
    end
end

-- Update display
function PullTimer:UpdateDisplay()
    if not self.frame then return end
    
    -- Update countdown number
    self.frame.countdown:SetText(tostring(self.remaining))
    
    -- Dynamic font sizing - much bigger for last 5 seconds
    local fontSize
    if self.remaining <= 5 then
        fontSize = 150  -- Much bigger for final countdown
    else
        fontSize = 72   -- Normal size
    end
    self.frame.countdown:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
    
    -- Color coding
    if self.remaining <= 3 then
        self.frame.countdown:SetTextColor(1, 0, 0, 1)  -- Red
        self.frame:SetBackdropBorderColor(1, 0, 0, 1)
    elseif self.remaining <= 5 then
        self.frame.countdown:SetTextColor(1, 0.5, 0, 1)  -- Orange
        self.frame:SetBackdropBorderColor(1, 0.5, 0, 1)
    else
        self.frame.countdown:SetTextColor(1, 1, 1, 1)  -- White
        self.frame:SetBackdropBorderColor(1, 0.8, 0, 1)
    end
    
    -- Update status text
    if self.remaining > 0 then
        self.frame.status:SetText("Timer will start automatically")
    else
        self.frame.status:SetText("GO!")
    end
end

-- Complete countdown and start timer
function PullTimer:Complete()
    self.active = false
    
    -- Stop ticker
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
    
    -- Show GO message briefly
    C_Timer.After(0.5, function()
        if self.frame then
            self.frame:Hide()
        end
    end)
    
    -- Start the actual dungeon timer
    if ns.Core then
        ns.Core:InfoMessage("|cFF00FF00GO! Timer started!|r")
        
        -- Reset timer if already running
        if ns.TimerUI and ns.TimerUI.sessionData.running then
            ns.Core:ResetTimer()
            C_Timer.After(0.3, function()
                ns.Core:AttemptTimerStart(GetServerTime())
            end)
        else
            ns.Core:AttemptTimerStart(GetServerTime())
        end
    end
end

-- Cancel pull timer
function PullTimer:Cancel()
    self.active = false
    
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
    
    if self.frame then
        self.frame:Hide()
    end
end

-- Initialize pull timer system
ns.PullTimer = PullTimer
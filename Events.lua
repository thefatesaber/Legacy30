-- Event handling system for Legacy30
local _, ns = ...
local L30 = ns.Core

-- Track defeated bosses
ns.DefeatedBosses = {}

-- Player enters world
function L30.Addon:PLAYER_ENTERING_WORLD(_, isLogin, isReload)
    self:OnZoneTransition()
    
    if isLogin or isReload then
        ns.ItemDatabase = ns.ItemDatabase or {}
    end
end

-- Instance entry detection
function L30:OnInstanceEntry()
    if self:CheckInstanceStatus() and not ns.TimerUI.sessionData.running then
        if ObjectiveTrackerFrame and ObjectiveTrackerFrame:IsVisible() then
            ObjectiveTrackerFrame:Hide()
        end
        
        ns.DefeatedBosses = {}
        self:RequestValidation()
    end
end

-- Boss defeat event
function L30:OnBossDefeat(_, defeatedBossID)
    ns.DefeatedBosses[defeatedBossID] = true
    self:OnBossProgress()
end

-- Get death status from scenario criteria
local function FindBossDeathInCriteria(bossName)
    bossName = strlower(bossName)
    
    local function CheckCriteriaMatch(criteriaData)
        local criteriaName = strlower(criteriaData[1])
        if string.match(criteriaName, bossName) then
            return criteriaData[3]
        end
    end
    
    local normalCount = select(3, C_Scenario.GetStepInfo())
    local bonusSteps = C_Scenario.GetBonusSteps()
    
    if bonusSteps and #bonusSteps > 0 then
        for _, stepID in ipairs(bonusSteps) do
            local bonusCount = select(3, C_Scenario.GetStepInfo(stepID))
            for i = 1, bonusCount do
                local match = CheckCriteriaMatch({
                    C_Scenario.GetCriteriaInfoByStep(stepID, i)
                })
                if match ~= nil then
                    return match
                end
            end
        end
    end
    
    for i = 1, normalCount do
        local match = CheckCriteriaMatch({
            C_Scenario.GetCriteriaInfo(i)
        })
        if match ~= nil then
            return match
        end
    end
    
    return true
end

-- Retrieve boss information
function L30:GetBossData(dungeonID)
    local sessionData = ns.TimerUI.sessionData
    dungeonID = dungeonID or sessionData.dungeonID
    
    local encounters = ns.Dungeons[dungeonID].encounters
    local bossData = {}
    
    for _, encounter in ipairs(encounters) do
        local bossName = EJ_GetEncounterInfo(encounter.journal)
        local isDefeated = ns.DefeatedBosses[encounter.difficulty] or
                          C_EncounterJournal.IsEncounterComplete(encounter.journal)
        
        if isDefeated then
            isDefeated = FindBossDeathInCriteria(bossName)
        end
        
        table.insert(bossData, {
            name = bossName,
            encounterID = encounter.difficulty,
            defeated = isDefeated,
            timeElapsed = (GetServerTime() - (sessionData.startTimestamp or GetServerTime()))
        })
    end
    
    return bossData, #encounters
end

-- Update boss progress
function L30:OnBossProgress()
    local timerFrame = ns.TimerUI
    if timerFrame.sessionData.running then
        timerFrame:RefreshBosses(self:GetBossData())
    end
end

-- Attempt to start timer
function L30:AttemptTimerStart(startTimestamp)
    if ns.WaitingForCombat and self:CheckInstanceStatus() then
        startTimestamp = tonumber(startTimestamp) or GetServerTime()
        
        local timerFrame = ns.TimerUI
        local dungeonName, _, _, difficulty, _, _, _, dungeonID = GetInstanceInfo()
        
        if not dungeonName then return end
        
        local bossData, totalBosses = self:GetBossData(dungeonID)
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
        
        timerFrame:Initialize(sessionInfo)
        self:BroadcastMessage(ns.Protocol.TIMER_START, startTimestamp)
        ns.WaitingForCombat = false
    end
end

-- Check if in valid dungeon
function L30:CheckInstanceStatus()
    local inInstance, instanceType = IsInInstance()
    local isDungeon = inInstance and instanceType == "party"
    
    if isDungeon then
        ns.TimerUI:Show()
    else
        ns.TimerUI:Hide()
    end
    
    return isDungeon
end

-- Zone transition handler
function L30:OnZoneTransition()
    local isValid = self:CheckInstanceStatus()
    return isValid
end

-- Run completion
function L30:OnRunComplete(sessionInfo, totalTime)
    self:SaveRecord(sessionInfo.dungeonID, nil, totalTime, sessionInfo)
end

-- Boss defeat timing
function L30:OnBossTiming(dungeonID, elapsedTime, bossNumber)
    self:SaveRecord(dungeonID, bossNumber, elapsedTime)
end

-- Combat log events
function L30:OnCombatEvent()
    local combatData = { CombatLogGetCurrentEventInfo() }
    
    if combatData[2] == "UNIT_DIED" then
        local isEnemy = not (bit.band(
            combatData[10], 
            COMBATLOG_OBJECT_REACTION_FRIENDLY
        ) > 0)
        
        if isEnemy then
            self:BroadcastMessage(
                ns.Protocol.CREATURE_SYNC, 
                combatData[8]
            )
        end
    end
end
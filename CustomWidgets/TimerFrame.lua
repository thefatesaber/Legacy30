-- Timer Frame Widget for Legacy30
-- Original implementation of dungeon timer UI
local _, ns = ...
local AceGUI = ns.GUI

-- Font configuration
local FONT_PATH = [[Interface\AddOns\Legacy30\Fonts\Expressway.TTF]]
local FONT_AVAILABLE = true

-- Check if custom font exists
local function GetFont(size, flags)
    if FONT_AVAILABLE then
        local font = CreateFont("Legacy30Font" .. size)
        local success = font:SetFont(FONT_PATH, size, flags or "OUTLINE")
        if success then
            return FONT_PATH, size, flags or "OUTLINE"
        else
            FONT_AVAILABLE = false
        end
    end
    return GameFontNormal:GetFont()
end

-- Create timer widget type
local TimerWidget = {
    sessionData = {
        running = false,
        dungeonID = nil,
        startTimestamp = nil,
        bossData = {},
        totalBosses = 0,
        mobCount = 0,
        mobList = {},
        sessionID = nil
    }
}

-- Constructor
function TimerWidget:Create()
    local frame = CreateFrame("Frame", "Legacy30TimerFrame", UIParent, "BackdropTemplate")
    frame:SetSize(300, 150)
    frame:SetPoint("RIGHT", -20, 0)
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(false)
    frame:Hide()
    
    -- Title text
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOP", 0, -10)
    frame.title:SetText("Legacy30 Timer")
    frame.title:SetFont(GetFont(14))
    
    -- Timer display
    frame.timerText = frame:CreateFontString(nil, "OVERLAY")
    frame.timerText:SetPoint("TOP", 0, -40)
    frame.timerText:SetText("00:00")
    frame.timerText:SetFont(GetFont(32, "OUTLINE"))
    frame.timerText:SetTextColor(0.65, 0.54, 0.96, 1)
    
    -- Mob counter
    frame.mobText = frame:CreateFontString(nil, "OVERLAY")
    frame.mobText:SetPoint("TOP", 0, -75)
    frame.mobText:SetText("Mobs: 0 (0%)")
    frame.mobText:SetFont(GetFont(13))
    frame.mobText:SetTextColor(0, 0.88, 0.42, 1)
    
    -- Boss counter
    frame.bossText = frame:CreateFontString(nil, "OVERLAY")
    frame.bossText:SetPoint("TOP", 0, -95)
    frame.bossText:SetText("Bosses: 0/0")
    frame.bossText:SetFont(GetFont(13))
    
    -- Best time display
    frame.bestText = frame:CreateFontString(nil, "OVERLAY")
    frame.bestText:SetPoint("BOTTOM", 0, 10)
    frame.bestText:SetText("Best: --:--")
    frame.bestText:SetFont(GetFont(11))
    frame.bestText:SetTextColor(0.7, 0.7, 0.7, 1)
    
    -- Update loop
    frame.elapsed = 0
    frame:SetScript("OnUpdate", function(self, delta)
        if not TimerWidget.sessionData.running then return end
        
        self.elapsed = self.elapsed + delta
        if self.elapsed >= 0.1 then
            TimerWidget:UpdateDisplay()
            self.elapsed = 0
        end
    end)
    
    -- Drag functionality
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and self:IsMovable() then
            self:StartMoving()
        end
    end)
    
    frame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:StopMovingOrSizing()
            TimerWidget:SavePosition()
        end
    end)
    
    return frame
end

-- Initialize timer for new run
function TimerWidget:Initialize(sessionInfo)
    self.sessionData = {
        running = true,
        dungeonID = sessionInfo.dungeonID,
        dungeonName = sessionInfo.dungeonName,
        startTimestamp = sessionInfo.startTimestamp,
        bestTime = sessionInfo.bestTime,
        totalBosses = sessionInfo.totalBosses,
        bossData = sessionInfo.bossData or {},
        bossRecords = sessionInfo.bossRecords or {},
        mobCount = 0,
        mobList = {},
        sessionID = self:GenerateSessionID()
    }
    
    self.frame.title:SetText(sessionInfo.dungeonName or "Dungeon Run")
    
    if sessionInfo.bestTime then
        self.frame.bestText:SetText(string.format("Best: %s", ns.FormatTime(sessionInfo.bestTime)))
    else
        self.frame.bestText:SetText("Best: --:--")
    end
    
    self:UpdateDisplay()
end

-- Generate unique session ID
function TimerWidget:GenerateSessionID()
    return string.format("%s-%d-%s", 
        UnitName("player"),
        time(),
        GetRealmName()
    )
end

-- Update timer display
function TimerWidget:UpdateDisplay()
    if not self.sessionData.running then return end
    
    local elapsed = GetServerTime() - self.sessionData.startTimestamp
    self.frame.timerText:SetText(ns.FormatTime(elapsed))
    
    local dungeonID = self.sessionData.dungeonID
    local maxMobs = ns.MobThresholds[dungeonID] or 100
    local percentage = math.min(100, (self.sessionData.mobCount / maxMobs) * 100)
    
    self.frame.mobText:SetText(string.format("Mobs: %d (%.0f%%)", 
        self.sessionData.mobCount, 
        percentage
    ))
    
    local bossesKilled = 0
    for _, boss in ipairs(self.sessionData.bossData) do
        if boss.defeated then
            bossesKilled = bossesKilled + 1
        end
    end
    
    self.frame.bossText:SetText(string.format("Bosses: %d/%d", 
        bossesKilled, 
        self.sessionData.totalBosses
    ))
    
    if bossesKilled >= self.sessionData.totalBosses then
        self:CompleteRun(elapsed)
    end
end

-- Refresh boss data
function TimerWidget:RefreshBosses(bossData)
    self.sessionData.bossData = bossData
    
    for i, boss in ipairs(bossData) do
        if boss.defeated and not self.sessionData.bossRecords[i] then
            self.sessionData.bossRecords[i] = true
            ns.Core:OnBossTiming(
                self.sessionData.dungeonID,
                boss.timeElapsed,
                i
            )
        end
    end
end

-- Increment creature count
function TimerWidget:IncrementCreatureCount(creatureGUID)
    if self.sessionData.mobList[creatureGUID] then
        return
    end
    
    self.sessionData.mobList[creatureGUID] = true
    self.sessionData.mobCount = self.sessionData.mobCount + 1
end

-- Complete the run
function TimerWidget:CompleteRun(totalTime)
    self.sessionData.running = false
    
    ns.Core:OnRunComplete({
        dungeonID = self.sessionData.dungeonID,
        dungeonName = self.sessionData.dungeonName,
        totalTime = totalTime,
        bossData = self.sessionData.bossData,
        mobCount = self.sessionData.mobCount,
        sessionID = self.sessionData.sessionID,
        runGUID = self.sessionData.sessionID
    }, totalTime)
    
    if ns.CompletionUI then
        ns.CompletionUI:Display({
            dungeonName = self.sessionData.dungeonName,
            timeString = ns.FormatTime(totalTime),
            bestTime = self.sessionData.bestTime,
            improvement = self.sessionData.bestTime and (self.sessionData.bestTime - totalTime) or nil
        })
    end
end

-- Set draggable state
function TimerWidget:SetDraggable(enabled)
    self.frame:EnableMouse(enabled)
    self.frame:SetMovable(enabled)
    
    if enabled then
        self.frame:SetBackdropBorderColor(0.8, 0.8, 0, 1)
    else
        self.frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    end
end

-- Apply settings
function TimerWidget:ApplySettings(scale, position)
    self.frame:SetScale(scale or 1)
    
    if position and #position > 0 then
        self.frame:ClearAllPoints()
        self.frame:SetPoint(unpack(position))
    end
end

-- Save current position
function TimerWidget:SavePosition()
    local point, _, relativePoint, x, y = self.frame:GetPoint()
    ns.Core.database.preferences.position = { point, relativePoint, x, y }
end

-- Show/hide frame
function TimerWidget:Show()
    self.frame:Show()
end

function TimerWidget:Hide()
    self.frame:Hide()
    self.sessionData.running = false
end

-- Time formatting utility
ns.FormatTime = function(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%d:%02d", minutes, secs)
    end
end

-- Initialize the widget
TimerWidget.frame = TimerWidget:Create()
ns.TimerUI = TimerWidget
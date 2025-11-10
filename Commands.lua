-- Command processing for Legacy30 addon
local _, ns = ...
local L30 = ns.Core

function L30.Addon:ProcessCommand(input)
    input = strlower(input or "")
    local args = {}
    
    for token in gmatch(input, "%S+") do
        table.insert(args, token)
    end
    
    local cmd = args[1]
    
    if cmd == "timer" then
        L30:HandleTimerCommand(args)
        
    elseif cmd == "pull" then
        L30:HandlePullCommand(args)
        
    elseif cmd == "show" then
        -- Manual command to show and start timer - ONLY for configured dungeons
        local inInstance, instanceType = IsInInstance()
        if inInstance and instanceType == "party" then
            local dungeonName, _, _, _, _, _, _, dungeonID = GetInstanceInfo()
            
            -- Check if dungeon is configured
            if ns.Dungeons and ns.Dungeons[dungeonID] then
                L30:InfoMessage("Forcing timer for: %s (ID: %d)", dungeonName, dungeonID)
                
                -- Force show timer frame
                if ns.TimerUI and ns.TimerUI.frame then
                    ns.TimerUI.frame:Show()
                    L30:InfoMessage("Timer frame is now visible")
                else
                    L30:ErrorMessage("Timer frame doesn't exist!")
                end
                
                -- Start timer
                L30:AttemptTimerStart(GetServerTime())
            else
                L30:ErrorMessage("Dungeon ID %d is NOT configured in Settings.lua", dungeonID)
                L30:InfoMessage("This dungeon is not supported by Legacy30")
            end
        else
            L30:ErrorMessage("You must be in a dungeon to use this command")
        end
        
    elseif cmd == "hide" then
        if ns.TimerUI and ns.TimerUI.frame then
            ns.TimerUI.frame:Hide()
            L30:InfoMessage("Timer frame hidden")
        else
            L30:ErrorMessage("Timer frame not initialized")
        end
        
    elseif cmd == "start" then
        -- Manual start command
        L30:AttemptTimerStart(GetServerTime())
        
    elseif cmd == "stop" then
        L30:StopTimer()
        
    elseif cmd == "reset" then
        L30:ResetTimer()
        
    elseif cmd == "restart" then
        L30:RestartTimer()
        
    elseif cmd == "lock" then
        -- Lock all movable frames
        ns.FramesLocked = true
        
        -- Lock timer frame
        if ns.TimerUI then
            ns.TimerUI:SetDraggable(false)
        end
        
        -- Lock completion frame
        if ns.CompletionUI and ns.CompletionUI.frame then
            ns.CompletionUI.frame:SetMovable(false)
            ns.CompletionUI.frame:EnableMouse(false)
        end
        
        -- Lock validation window
        if ns.ValidationUI and ns.ValidationUI.window then
            ns.ValidationUI.window:SetMovable(false)
            ns.ValidationUI.window:EnableMouse(false)
        end
        
        -- Lock export window
        if ns.ExportUI and ns.ExportUI.window then
            ns.ExportUI.window:SetMovable(false)
            ns.ExportUI.window:EnableMouse(false)
        end
        
        L30:InfoMessage("All frames locked in place")
        
    elseif cmd == "unlock" then
        -- Unlock all movable frames
        ns.FramesLocked = false
        
        -- Unlock timer frame
        if ns.TimerUI then
            ns.TimerUI:SetDraggable(true)
        end
        
        -- Unlock completion frame
        if ns.CompletionUI and ns.CompletionUI.frame then
            ns.CompletionUI.frame:SetMovable(true)
            ns.CompletionUI.frame:EnableMouse(true)
        end
        
        -- Unlock validation window
        if ns.ValidationUI and ns.ValidationUI.window then
            ns.ValidationUI.window:SetMovable(true)
            ns.ValidationUI.window:EnableMouse(true)
        end
        
        -- Unlock export window
        if ns.ExportUI and ns.ExportUI.window then
            ns.ExportUI.window:SetMovable(true)
            ns.ExportUI.window:EnableMouse(true)
        end
        
        L30:InfoMessage("All frames unlocked - you can now move them")
        
    elseif cmd == "complete" or cmd == "finish" then
        -- Testing command to simulate run completion
        if not ns.TimerUI or not ns.TimerUI.sessionData.running then
            L30:ErrorMessage("No timer is running - use /l30 start first")
            return
        end
        
        local elapsed = GetServerTime() - ns.TimerUI.sessionData.startTimestamp
        L30:InfoMessage("Testing: Forcing run completion at %s", ns.FormatTime and ns.FormatTime(elapsed) or tostring(elapsed))
        
        -- Force complete the run
        if ns.TimerUI.CompleteRun then
            ns.TimerUI:CompleteRun(elapsed)
        end
        
    elseif cmd == "status" then
        if not ns.TimerUI or not ns.TimerUI.sessionData then
            L30:InfoMessage("Timer not initialized")
        else
            local data = ns.TimerUI.sessionData
            if data.running then
                local elapsed = GetServerTime() - data.startTimestamp
                L30:InfoMessage("|cFF00FF00Timer Status:|r")
                L30:InfoMessage("  Running: |cFF00FF00Yes|r")
                L30:InfoMessage("  Dungeon: |cFFFFFF00%s|r", data.dungeonName or "Unknown")
                L30:InfoMessage("  Time: |cFF00FFFF%s|r", ns.FormatTime and ns.FormatTime(elapsed) or "Unknown")
                L30:InfoMessage("  Mobs: |cFF00FFFF%d|r", data.mobCount or 0)
                
                -- Count defeated bosses
                local killed = 0
                for _, boss in ipairs(data.bossData or {}) do
                    if boss.defeated then
                        killed = killed + 1
                    end
                end
                L30:InfoMessage("  Bosses: |cFF00FFFF%d/%d|r", killed, data.totalBosses or 0)
            else
                L30:InfoMessage("Timer Status: |cFFFF0000Not running|r")
            end
        end
    
    elseif cmd == "key" then
        L30:HandleKeyCommand(args)
    
    elseif cmd == "exportrun" then
        L30:HandleExportRunCommand(args)
        
    elseif cmd == "help" or not cmd then
        L30:ShowHelpText()
        
    elseif cmd == "export" then
        if C_AddOns.IsAddOnLoaded("AllTheThings") then
            local instance = args[2] == "yes"
            local world = args[3] == "yes"
            local craft = args[4] == "yes"
            local pvp = args[5] == "yes"
            
            L30:InfoMessage("Extracting data, please wait...")
            RunNextFrame(function()
                L30:ExportDatabase(instance, world, craft, pvp)
            end)
        else
            L30:ErrorMessage("AllTheThings addon required for export")
        end
        
    elseif cmd == "search" then
        L30:SearchItemDatabase(ns.ItemDatabase)
        
    elseif cmd == "validation" then
        ns.ValidationUI.window:Show()
        
    elseif cmd == "instances" then
        L30:ExportInstanceData()
        
    else
        L30:ErrorMessage("Unknown command: %s", cmd)
        L30:ShowHelpText()
    end
end

function L30:HandleTimerCommand(args)
    local subCmd = args[2]
    
    if subCmd == "drag" then
        ns.CanDragTimer = not ns.CanDragTimer
        ns.TimerUI:SetDraggable(ns.CanDragTimer)
        self:StatusMessage(ns.CanDragTimer, "Timer dragging")
        
    elseif subCmd == "scale" then
        local scaleValue = tonumber(args[3])
        if not scaleValue then
            self:ErrorMessage("%s is not a valid scale value", args[3] or "nil")
            return
        end
        self.Addon.database.preferences.uiScale = scaleValue / 100
        self:InfoMessage("Timer scale: %d%%", scaleValue)
        self:ApplyUISettings()
        
    elseif subCmd == "reset" then
        self.Addon.database.preferences = {
            position = { "RIGHT" },
            uiScale = 1
        }
        self:InfoMessage("Timer settings reset to defaults")
        self:ApplyUISettings()
        
    else
        self:ErrorMessage("Unknown timer command: %s", subCmd or "nil")
    end
end

-- ============================================================================
-- PULL TIMER COMMAND
-- ============================================================================

function L30:HandlePullCommand(args)
    local subCmd = args[2]
    
    if subCmd == "cancel" or subCmd == "stop" then
        -- Cancel active pull timer
        if ns.PullTimer and ns.PullTimer.active then
            ns.PullTimer:Cancel()
            self:InfoMessage("Pull timer cancelled")
        else
            self:ErrorMessage("No pull timer is active")
        end
    else
        -- Start pull timer (default 10 seconds)
        local seconds = tonumber(args[2]) or 10
        
        if seconds < 1 or seconds > 60 then
            self:ErrorMessage("Pull timer must be between 1-60 seconds")
            return
        end
        
        -- Check if we're in a configured dungeon
        local inInstance, instanceType = IsInInstance()
        if not (inInstance and instanceType == "party") then
            self:ErrorMessage("You must be in a dungeon to use pull timer")
            return
        end
        
        local _, _, _, _, _, _, _, dungeonID = GetInstanceInfo()
        if not ns.Dungeons or not ns.Dungeons[dungeonID] then
            self:ErrorMessage("Pull timer only works in configured dungeons")
            return
        end
        
        -- Don't start if timer is already running
        if ns.TimerUI and ns.TimerUI.sessionData.running then
            self:ErrorMessage("Timer is already running - use /l30 reset first")
            return
        end
        
        -- Start the pull timer
        if ns.PullTimer then
			ns.PullTimer:Start(seconds)
			
			-- Broadcast to party members
			if IsInGroup() and L30.BroadcastPullTimer then
				L30:BroadcastPullTimer(seconds)
			end
		else
            self:ErrorMessage("Pull timer not initialized")
        end
    end
end

-- ============================================================================
-- ENCRYPTION KEY COMMAND
-- ============================================================================

function L30:HandleKeyCommand(args)
    if not ns.Encryption then
        self:ErrorMessage("Encryption module not loaded")
        return
    end
    
    -- Remove the "key" command itself
    table.remove(args, 1)
    
    -- Join remaining args as the key
    local key = table.concat(args, " ")
    
    if not key or key == "" then
        -- Show status
        if ns.Encryption:HasKey() then
            local currentKey = ns.Encryption:GetKey()
            self:InfoMessage("|cFF00FF00Encryption key is set|r")
            self:InfoMessage("Preview: %s***", currentKey:sub(1, math.min(6, #currentKey)))
        else
            self:ErrorMessage("No encryption key configured")
        end
        self:InfoMessage("Usage: |cFFFFFF00/l30 key <your-secret-key>|r")
        return
    end
    
    -- Set the key
    local success, err = ns.Encryption:SetKey(key)
    
    if success then
        self:InfoMessage("|cFF00FF00Encryption key set successfully|r")
        self:InfoMessage("Preview: %s***", key:sub(1, math.min(6, #key)))
    else
        self:ErrorMessage("Failed to set key: %s", err or "unknown error")
    end
end

-- ============================================================================
-- EXPORT RUN COMMAND
-- ============================================================================

function L30:HandleExportRunCommand(args)
    if not ns.Encryption then
        self:ErrorMessage("Encryption module not loaded")
        return
    end
    
    -- Get run data
    local runData = self:CollectRunData()
    
    if not runData then
        self:ErrorMessage("No run data available")
        self:InfoMessage("Start or complete a dungeon run first")
        return
    end
    
    -- Show what we're exporting
    self:InfoMessage("Exporting: |cFFFFFF00%s|r", runData.dungeonName)
    self:InfoMessage("Duration: |cFF00FFFF%s|r", ns.FormatTime and ns.FormatTime(runData.durationSeconds) or (runData.durationSeconds .. "s"))
    self:InfoMessage("Players: |cFF00FFFF%d|r", #runData.players)
    
    -- Export
    local exportString, err = ns.Encryption:ExportRun(runData)
    
    if not exportString then
        self:ErrorMessage("Export failed: %s", err or "unknown error")
        return
    end
    
    -- Display the export string
    self:DisplayExportString(exportString)
    
    self:InfoMessage("|cFF00FF00Export generated!|r Length: %d chars", #exportString)
end

-- ============================================================================
-- DATA COLLECTION FOR EXPORT
-- ============================================================================

function L30:CollectRunData()
    -- Try active timer first
    if ns.TimerUI and ns.TimerUI.sessionData then
        local session = ns.TimerUI.sessionData
        
        if session.running or session.completed then
            return self:BuildRunDataFromSession(session)
        end
    end
    
    -- Fallback to last completed run
    if self.Addon.database.runHistory and #self.Addon.database.runHistory > 0 then
        local lastRun = self.Addon.database.runHistory[#self.Addon.database.runHistory]
        return self:BuildRunDataFromHistory(lastRun)
    end
    
    return nil
end

function L30:BuildRunDataFromSession(session)
    local dungeonName, _, difficulty = GetInstanceInfo()
    
    -- Get death counts from session (should be a table like {["PlayerName"] = count})
    local deathCounts = session.deathCounts or {}
    
    -- Collect players
    local players = {}
    
    -- Add player
    local playerName = UnitName("player")
    table.insert(players, {
        name = playerName,
        itemLevel = math.floor(select(1, GetAverageItemLevel()) or 0),
        mobsKilled = session.mobCount or 0,
        deaths = deathCounts[playerName] or 0
    })
    
    -- Add party members
    if IsInGroup() then
        local numMembers = GetNumGroupMembers()
        for i = 1, numMembers do
            local unit = (IsInRaid() and "raid" or "party") .. i
            if UnitExists(unit) and not UnitIsUnit(unit, "player") then
                local name = UnitName(unit)
                if name then
                    table.insert(players, {
                        name = name,
                        itemLevel = 0,
                        mobsKilled = 0,
                        deaths = deathCounts[name] or 0
                    })
                end
            end
        end
    end
    
    -- Calculate duration
    local currentTime = GetServerTime()
    local startTime = session.startTimestamp or currentTime
    local endTime = session.completed and session.completedTimestamp or currentTime
    local duration = endTime - startTime
    
    return {
        dungeonName = dungeonName or "Unknown",
        difficulty = difficulty or "Normal",
        startTime = date("!%Y-%m-%dT%H:%M:%SZ", startTime),
        endTime = date("!%Y-%m-%dT%H:%M:%SZ", endTime),
        durationSeconds = duration,
        players = players
    }
end

function L30:BuildRunDataFromHistory(historyEntry)
    local players = {}
    
    -- Build player list from groupData
    if historyEntry.groupData then
        for _, memberData in pairs(historyEntry.groupData) do
            table.insert(players, {
                name = memberData.name or "Unknown",
                itemLevel = 0,
                mobsKilled = 0,
                deaths = 0
            })
        end
    end
    
    -- Get dungeon name
    local dungeonName = "Unknown"
    if historyEntry.dungeonID then
        dungeonName = GetRealZoneText() or "Dungeon " .. historyEntry.dungeonID
    end
    
    local startTime = historyEntry.timestamp - (historyEntry.totalTime or 0)
    local endTime = historyEntry.timestamp
    
    return {
        dungeonName = dungeonName,
        difficulty = "Normal",
        startTime = date("!%Y-%m-%dT%H:%M:%SZ", startTime),
        endTime = date("!%Y-%m-%dT%H:%M:%SZ", endTime),
        durationSeconds = historyEntry.totalTime or 0,
        players = players
    }
end

-- ============================================================================
-- DISPLAY EXPORT STRING
-- ============================================================================

function L30:DisplayExportString(exportString)
    -- Always use StaticPopup for consistent UI
    StaticPopup_Show("L30_ENCRYPTED_EXPORT", nil, nil, exportString)
end

-- StaticPopup definition
if not StaticPopupDialogs["L30_ENCRYPTED_EXPORT"] then
    StaticPopupDialogs["L30_ENCRYPTED_EXPORT"] = {
        text = "Encrypted Export String:|n|nThe text is selected. Press Ctrl+C to copy.",
        button1 = OKAY,
        hasEditBox = 1,
        editBoxWidth = 350,
        OnShow = function(self, data)
            local editBox = self.EditBox or self.editBox
            if not editBox then return end
            
            editBox:SetText(data)
            editBox:HighlightText()
            editBox:SetFocus()
            editBox:SetAutoFocus(true)
            
            self.ctrlPressed = false
            
            editBox:SetScript("OnKeyDown", function(eb, key)
                if key == "LCTRL" or key == "RCTRL" then
                    self.ctrlPressed = true
                end
            end)
            
            editBox:SetScript("OnKeyUp", function(eb, key)
                if key == "C" and self.ctrlPressed then
                    C_Timer.After(0.05, function()
                        self:Hide()
                    end)
                end
                
                if key == "LCTRL" or key == "RCTRL" then
                    self.ctrlPressed = false
                end
            end)
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
        OnHide = function(self)
            local editBox = self.EditBox or self.editBox
            if editBox then
                editBox:SetScript("OnKeyDown", nil)
                editBox:SetScript("OnKeyUp", nil)
            end
        end,
        OnAccept = function(self)
            self:Hide()
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        preferredIndex = 3,
    }
end

-- ============================================================================
-- HELP TEXT
-- ============================================================================

function L30:ShowHelpText()
    self:InfoMessage("|cFF00FF00=== Legacy30 Commands ===|r")
    self:InfoMessage(" ")
    self:InfoMessage("|cFFFFFF00Timer Control:|r")
    self:InfoMessage("  |cFF00FFFF/l30 pull|r - Start 10 second pull timer")
    self:InfoMessage("  |cFF00FFFF/l30 pull <seconds>|r - Custom pull timer (1-60s)")
    self:InfoMessage("  |cFF00FFFF/l30 pull cancel|r - Cancel active pull timer")
    self:InfoMessage("  |cFF00FFFF/l30 start|r - Manually start the timer")
    self:InfoMessage("  |cFF00FFFF/l30 stop|r - Stop the current timer")
    self:InfoMessage("  |cFF00FFFF/l30 reset|r - Reset timer to 0 and clear data")
    self:InfoMessage("  |cFF00FFFF/l30 restart|r - Reset and start fresh")
    self:InfoMessage("  |cFF00FFFF/l30 complete|r - Force complete the run (testing)")
    self:InfoMessage(" ")
    self:InfoMessage("|cFFFFFF00Display:|r")
    self:InfoMessage("  |cFF00FFFF/l30 show|r - Force show/start timer in current dungeon")
    self:InfoMessage("  |cFF00FFFF/l30 hide|r - Hide the timer frame")
    self:InfoMessage("  |cFF00FFFF/l30 lock|r - Lock all frames in place")
    self:InfoMessage("  |cFF00FFFF/l30 unlock|r - Unlock frames for repositioning")
    self:InfoMessage(" ")
    self:InfoMessage("|cFFFFFF00Timer Settings:|r")
    self:InfoMessage("  |cFF00FFFF/l30 timer drag|r - Toggle timer drag mode")
    self:InfoMessage("  |cFF00FFFF/l30 timer scale <num>|r - Set timer scale (percentage)")
    self:InfoMessage("  |cFF00FFFF/l30 timer reset|r - Reset timer position to defaults")
    self:InfoMessage(" ")
    self:InfoMessage("|cFFFFFF00Info:|r")
    self:InfoMessage("  |cFF00FFFF/l30 status|r - Show current timer status")
    self:InfoMessage("  |cFF00FFFF/l30 validation|r - Show validation window")
    self:InfoMessage(" ")
    self:InfoMessage("|cFFFFFF00Export & Encryption:|r")
    self:InfoMessage("  |cFF00FFFF/l30 key <secret>|r - Set encryption key")
    self:InfoMessage("  |cFF00FFFF/l30 exportrun|r - Export current/last run (encrypted)")
    self:InfoMessage(" ")
    self:InfoMessage("|cFFFFFF00Advanced:|r")
    self:InfoMessage("  |cFF00FFFF/l30 export|r - Export item database (requires AllTheThings)")
    self:InfoMessage("  |cFF00FFFF/l30 search|r - Search item database")
    self:InfoMessage("  |cFF00FFFF/l30 instances|r - Export instance data")
    self:InfoMessage(" ")
    self:InfoMessage("|cFF888888Tip: Timer auto-starts when entering configured dungeons|r")
end

-- ============================================================================
-- EXISTING EXPORT FUNCTIONS (unchanged)
-- ============================================================================

function L30:ExportInstanceData()
    if not IsAddOnLoaded("Blizzard_EncounterJournal") then
        UIParentLoadAddOn("Blizzard_EncounterJournal")
    end
    
    local journal = EncounterJournal
    local events = {
        "EJ_LOOT_DATA_RECIEVED",
        "EJ_DIFFICULTY_UPDATE",
        "UNIT_PORTRAIT_UPDATE",
        "PORTRAITS_UPDATED",
        "SEARCH_DB_LOADED",
        "UI_MODEL_SCENE_INFO_UPDATED"
    }
    
    for _, event in ipairs(events) do
        journal:UnregisterEvent(event)
    end
    
    local output = "ns.Dungeons = {\n"
    local mobCounts = "\n}\n\nns.MobThresholds = {\n"
    
    local function AppendLine(text, isThreshold)
        if isThreshold then
            mobCounts = mobCounts .. text
        else
            output = output .. text
        end
    end
    
    for expID = 1, GetNumExpansions() do
        EJ_SelectTier(expID)
        
        for idx = 1, 50 do
            local instanceID = EJ_GetInstanceByIndex(idx, false)
            if not instanceID then break end
            
            EJ_SelectInstance(instanceID)
            
            for bossIdx = 1, 20 do
                local bossData = { EJ_GetEncounterInfoByIndex(bossIdx, instanceID) }
                
                if bossData and bossData[1] then
                    local journalEncID = bossData[3]
                    local journalInstID = bossData[6]
                    local difficultyEncID = bossData[7]
                    local difficultyInstID = bossData[8]
                    local instName = EJ_GetInstanceInfo(journalInstID)
                    local bossName = bossData[1]
                    
                    if bossIdx == 1 then
                        AppendLine(string.format(
                            "[%d] = {\n  expansion = %d,\n  journalID = %d,\n  encounters = {\n",
                            difficultyInstID, expID, journalInstID
                        ))
                        AppendLine(string.format(
                            "\n[%d] = 100, -- %s", 
                            difficultyInstID, instName
                        ), true)
                    end
                    
                    AppendLine(string.format(
                        "    { journal = %d, difficulty = %d }, -- %s\n",
                        journalEncID, difficultyEncID, bossName
                    ))
                else
                    AppendLine("  }\n},\n")
                    break
                end
            end
        end
    end
    
    AppendLine("}", true)
    
    self:DisplayExport(mobCounts .. output)
    
    for _, event in ipairs(events) do
        journal:RegisterEvent(event)
    end
end

function L30:ExportDatabase(useInstances, useWorld, useCraft, usePvP)
    self:StatusMessage(useInstances, "Instances")
    self:StatusMessage(useWorld, "World drops")
    self:StatusMessage(useCraft, "Craftables")
    self:StatusMessage(usePvP, "PvP items")
    
    local categoryPaths = {
        ["Instances"] = useInstances and 0 or nil,
        ["WorldDrops"] = useWorld and 0 or nil,
        ["Craftables"] = useCraft and 0 or nil,
        ["PVP"] = usePvP and 2 or nil,
    }
    
    ns.ItemsByExpansion = {}
    local db = ATTC.Categories
    
    for exp = 1, 10 do
        ns.ItemsByExpansion[exp] = {}
        for category, offset in pairs(categoryPaths) do
            self:ExtractItems(
                db[category][offset + exp].g, 
                ns.ItemsByExpansion[exp]
            )
        end
    end
    
    self:DisplayExport(ns.ItemsByExpansion, "local exportData = ")
end

function L30:ExtractItems(dataTable, storage)
    storage = storage or {}
    
    if type(dataTable) ~= "table" then 
        return storage 
    end
    
    for _, entry in ipairs(dataTable) do
        if entry.g then
            self:ExtractItems(entry.g, storage)
        elseif entry.itemID then
            if C_Item.IsEquippableItem(entry.itemID) then
                storage[entry.itemID] = true
            end
        end
    end
    
    return storage
end

function L30:DisplayExport(data, prefix)
    prefix = prefix or ""
    local text = data
    
    if type(data) == "table" then
        text = self:SerializeTable(data)
    end
    
    ns.ExportUI:ShowData(prefix .. text)
end

function L30:SerializeTable(tbl)
    local result = "{"
    local first = true
    
    for k, v in pairs(tbl) do
        if not first then
            result = result .. ","
        end
        
        if type(k) == "number" then
            result = result .. "[" .. k .. "]="
        else
            result = result .. '["' .. k .. '"]='
        end
        
        if type(v) == "table" then
            result = result .. self:SerializeTable(v)
        elseif type(v) == "string" then
            result = result .. '"' .. v .. '"'
        else
            result = result .. tostring(v)
        end
        
        first = false
    end
    
    return result .. "}"
end

function L30:SearchItemDatabase(database)
    self:InfoMessage("Item database search not yet implemented")
end
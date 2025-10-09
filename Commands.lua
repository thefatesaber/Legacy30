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
            position = { "RIGHT" },  -- Simple format: just anchor point
            uiScale = 1
        }
        self:InfoMessage("Timer settings reset to defaults")
        self:ApplyUISettings()
        
    else
        self:ErrorMessage("Unknown timer command: %s", subCmd or "nil")
    end
end

function L30:ShowHelpText()
    self:InfoMessage("|cFF00FF00=== Legacy30 Commands ===|r")
    self:InfoMessage(" ")
    self:InfoMessage("|cFFFFFF00Timer Control:|r")
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
    self:InfoMessage("|cFFFFFF00Advanced:|r")
    self:InfoMessage("  |cFF00FFFF/l30 export|r - Export item database (requires AllTheThings)")
    self:InfoMessage("  |cFF00FFFF/l30 search|r - Search item database")
    self:InfoMessage("  |cFF00FFFF/l30 instances|r - Export instance data")
    self:InfoMessage(" ")
    self:InfoMessage("|cFF888888Tip: Timer auto-starts when entering configured dungeons|r")
end

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
    -- Placeholder for item database search functionality
    self:InfoMessage("Item database search not yet implemented")
end
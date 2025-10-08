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
        
    elseif cmd == "start" then
        ns.PlayerReady = true
        ns.WaitingForCombat = true
        L30:InfoMessage("Ready status: Active - Timer will start on first combat")
        -- Don't register event here - Events.lua will handle combat detection
        -- Just set the flag for AttemptTimerStart to check
        
    elseif cmd == "help" or not cmd then
        L30:ShowHelpText()  -- Changed from self: to L30:
        
    elseif cmd == "export" then
        if C_AddOns.IsAddOnLoaded("AllTheThings") then
            local instance = args[2] == "yes"
            local world = args[3] == "yes"
            local craft = args[4] == "yes"
            local pvp = args[5] == "yes"
            
            L30:InfoMessage("Extracting data, please wait...")  -- Changed from self: to L30:
            RunNextFrame(function()
                L30:ExportDatabase(instance, world, craft, pvp)  -- Changed from self: to L30:
            end)
        else
            L30:ErrorMessage("AllTheThings addon required for export")  -- Changed from self: to L30:
        end
        
    elseif cmd == "search" then
        L30:SearchItemDatabase(ns.ItemDatabase)  -- Changed from self: to L30:
        
    elseif cmd == "validation" then
        ns.ValidationUI.window:Show()
        
    elseif cmd == "instances" then
        L30:ExportInstanceData()  -- Changed from self: to L30:
        
    else
        L30:ErrorMessage("Unknown command: %s", cmd)  -- Changed from self: to L30:
        L30:ShowHelpText()  -- Changed from self: to L30:
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
    self:InfoMessage("=== Legacy30 Commands ===")
    self:InfoMessage("/l30 show - Force show/start timer in current dungeon")
    self:InfoMessage("/l30 timer drag - Toggle timer drag mode")
    self:InfoMessage("/l30 timer scale <num> - Set timer scale (percentage)")
    self:InfoMessage("/l30 timer reset - Reset timer to defaults")
    self:InfoMessage("/l30 start - Mark ready to begin")
    self:InfoMessage("/l30 export <instance> <world> <craft> <pvp> - Export item DB")
    self:InfoMessage("/l30 search - Search item database")
    self:InfoMessage("/l30 validation - Show validation window")
    self:InfoMessage("/l30 instances - Export instance data")
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
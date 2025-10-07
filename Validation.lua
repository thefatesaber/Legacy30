-- Gear and level validation system for Legacy30
local _, ns = ...
local L30 = ns.Core

local BANNED_ITEMS = {
    [178769] = true,
    [179356] = true,
}

local allowedItems = {}
local forbiddenItems = {}

for expansion = 1, 10 do
    forbiddenItems[expansion] = BANNED_ITEMS
    allowedItems[expansion] = setmetatable({}, { 
        __index = function() return true end 
    })
end

local function IsItemPermitted(expansion, itemID, itemLink)
    if not itemLink then return true end
    
    if not C_Item.IsEquippableItem(itemLink) then
        return true
    end
    
    local slot = select(4, C_Item.GetItemInfoInstant(itemLink))
    local isCosmetic = C_Item.IsCosmeticItem(itemLink)
    
    if isCosmetic or slot == "INVTYPE_TABARD" then
        return true
    end
    
    local allowed = allowedItems[expansion]
    local forbidden = forbiddenItems[expansion]
    
    local isValid = allowed[itemID] and not forbidden[itemID]
    
    if not isValid and itemID then
        L30:ErrorMessage(
            "Item validation failed: %s not permitted for this expansion", 
            itemLink
        )
        return false
    end
    
    return true
end

local function PerformValidation(expansion)
    local status = "VALID"
    local details = { 
        equipment = {},
        level = {},
        expansion = expansion
    }
    
    local playerLevel = UnitLevel("player")
    local maxLevel = GetMaxLevelForExpansionLevel(expansion - 1)
    
    if playerLevel > maxLevel then
        status = "INVALID"
        L30:ErrorMessage(
            "Level validation failed: %d maximum, you are %d", 
            maxLevel, 
            playerLevel
        )
    end
    
    details.level = { 
        maximum = maxLevel, 
        current = playerLevel 
    }
    
    for slot = 1, 17 do
        if slot ~= 4 then
            local itemID = GetInventoryItemID("player", slot)
            local itemLink = GetInventoryItemLink("player", slot)
            table.insert(details.equipment, itemLink)
            
            if not IsItemPermitted(expansion, itemID, itemLink) then
                status = "INVALID"
            end
        end
    end
    
    for bagID = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        local bagSize = C_Container.GetContainerNumSlots(bagID)
        
        for slot = 1, bagSize do
            local itemInfo = C_Container.GetContainerItemInfo(bagID, slot)
            
            if itemInfo then
                if not IsItemPermitted(
                    expansion, 
                    itemInfo.itemID, 
                    itemInfo.hyperlink
                ) then
                    status = "INVALID"
                end
            end
        end
    end
    
    return status, details
end

function L30:GetValidationStatus(expansion)
    return PerformValidation(expansion)
end

function L30:GetValidationDetails(expansion)
    return select(2, PerformValidation(expansion))
end

ns.ValidationStates = {}

function L30:ResetValidationStates()
    ns.ValidationStates = {}
end

function L30:RequestValidation(dungeonID, wantDetails, targetPlayer)
    dungeonID = dungeonID or select(8, GetInstanceInfo())
    local dungeonInfo = ns.Dungeons[dungeonID]
    
    if dungeonInfo then
        local msgType = wantDetails and "REQUEST_DETAILS" or "REQUEST"
        self:SendNetworkMessage(
            ns.Protocol.GEAR_CHECK,
            { type = msgType, expansion = dungeonInfo.expansion },
            targetPlayer
        )
    end
end

function L30:ProcessValidationResponse(playerName, validationStatus)
    ns.ValidationStates[playerName] = validationStatus
    
    local ui = ns.ValidationUI
    ui:UpdatePlayerStatus(playerName, validationStatus)
    
    self:EvaluateStartConditions()
end

function L30:EvaluateStartConditions()
    if self:IsPTREnvironment() then
        L30:InfoMessage("Validation complete - PTR mode active, ready to start")
        ns.CanStartTimer = true
        return true
    end
    
    local groupSize = GetNumGroupMembers()
    local allValid = true
    
    for _, playerStatus in pairs(ns.ValidationStates) do
        if not playerStatus or playerStatus == "INVALID" then
            allValid = false
            break
        end
    end
    
    local inInstance = IsInInstance()
    local minPlayers = ns.GroupLimits.minimum
    local maxPlayers = ns.GroupLimits.maximum
    local sizeValid = groupSize >= minPlayers and groupSize <= maxPlayers
    
    if inInstance and sizeValid and allValid then
        if not ns.CanStartTimer then
            L30:InfoMessage("All checks passed - ready to begin run")
        end
        ns.CanStartTimer = true
    else
        if ns.CanStartTimer then
            L30:ErrorMessage("Validation checks failed - cannot start")
        end
        ns.CanStartTimer = false
    end
    
    return ns.CanStartTimer
end

ns.GroupLimits = {
    minimum = 1,
    maximum = 3
}
-- Validation Frame Widget for Legacy30
-- Original implementation of gear validation display
local _, ns = ...
local AceGUI = ns.GUI

-- Font configuration
local FONT_PATH = [[Interface\AddOns\Legacy30\Fonts\Expressway.TTF]]

local function GetFont(size, flags)
    local success, font = pcall(function()
        return FONT_PATH
    end)
    if success then
        return FONT_PATH, size, flags or "OUTLINE"
    end
    return GameFontNormal:GetFont()
end

local ValidationWidget = {
    playerData = {}
}

-- Constructor
function ValidationWidget:Create()
    local frame = CreateFrame("Frame", "Legacy30ValidationFrame", UIParent, "BackdropTemplate")
    frame:SetSize(600, 450)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.9)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)
    
    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetPoint("TOP", 0, -15)
    frame.title:SetText("Gear Validation Status")
    frame.title:SetFont(GetFont(16))
    
    -- Player tabs
    frame.tabs = CreateFrame("Frame", nil, frame)
    frame.tabs:SetPoint("TOPLEFT", 10, -45)
    frame.tabs:SetPoint("TOPRIGHT", -10, -45)
    frame.tabs:SetHeight(30)
    
    frame.tabButtons = {}
    
    -- Content area
    frame.content = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.content:SetPoint("TOPLEFT", 10, -80)
    frame.content:SetPoint("BOTTOMRIGHT", -30, 80)
    
    frame.contentChild = CreateFrame("Frame", nil, frame.content)
    frame.contentChild:SetSize(540, 1)
    frame.content:SetScrollChild(frame.contentChild)
    
    -- Player info display
    frame.playerName = frame.contentChild:CreateFontString(nil, "OVERLAY")
    frame.playerName:SetPoint("TOPLEFT", 10, -10)
    frame.playerName:SetText("Player: Unknown")
    frame.playerName:SetFont(GetFont(13))
    
    frame.playerLevel = frame.contentChild:CreateFontString(nil, "OVERLAY")
    frame.playerLevel:SetPoint("TOPLEFT", frame.playerName, "BOTTOMLEFT", 0, -5)
    frame.playerLevel:SetText("Level: --")
    frame.playerLevel:SetFont(GetFont(13))
    
    frame.validationStatus = frame.contentChild:CreateFontString(nil, "OVERLAY")
    frame.validationStatus:SetPoint("TOPLEFT", frame.playerLevel, "BOTTOMLEFT", 0, -5)
    frame.validationStatus:SetText("Status: Unknown")
    frame.validationStatus:SetFont(GetFont(13))
    
    -- Equipment grid (4x4 = 16 slots)
    frame.equipmentSlots = {}
    for i = 1, 16 do
        local slot = CreateFrame("Button", nil, frame.contentChild)
        slot:SetSize(48, 48)
        
        local row = math.floor((i-1) / 4)
        local col = (i-1) % 4
        slot:SetPoint("TOPLEFT", 10 + (col * 55), -80 - (row * 55))
        
        slot.icon = slot:CreateTexture(nil, "ARTWORK")
        slot.icon:SetAllPoints()
        slot.icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
        
        slot.border = slot:CreateTexture(nil, "OVERLAY")
        slot.border:SetAllPoints()
        slot.border:SetTexture("Interface/Buttons/UI-ActionButton-Border")
        slot.border:SetBlendMode("ADD")
        slot.border:Hide()
        
        slot:SetScript("OnEnter", function(self)
            if self.itemLink then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(self.itemLink)
                GameTooltip:Show()
            end
        end)
        
        slot:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        frame.equipmentSlots[i] = slot
    end
    
    -- Action buttons
    frame.requestBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.requestBtn:SetPoint("BOTTOMLEFT", 15, 15)
    frame.requestBtn:SetSize(140, 30)
    frame.requestBtn:SetText("Request Status")
    frame.requestBtn:SetScript("OnClick", function()
        ValidationWidget:RequestCurrentValidation(false)
    end)
    
    frame.requestDetailBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.requestDetailBtn:SetPoint("LEFT", frame.requestBtn, "RIGHT", 5, 0)
    frame.requestDetailBtn:SetSize(140, 30)
    frame.requestDetailBtn:SetText("Request Details")
    frame.requestDetailBtn:SetScript("OnClick", function()
        ValidationWidget:RequestCurrentValidation(true)
    end)
    
    frame.requestAllBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.requestAllBtn:SetPoint("BOTTOMRIGHT", -15, 15)
    frame.requestAllBtn:SetSize(140, 30)
    frame.requestAllBtn:SetText("Request All")
    frame.requestAllBtn:SetScript("OnClick", function()
        ns.Core:RequestValidation()
    end)
    
    return frame
end

-- Create tab button
function ValidationWidget:CreateTab(playerName, index)
    local tab = CreateFrame("Button", nil, self.frame.tabs)
    tab:SetSize(100, 25)
    tab:SetText(playerName)
    
    local fontString = tab:GetFontString() or tab:CreateFontString()
    fontString:SetFont(GetFont(12))
    tab:SetNormalFontObject(fontString)
    tab:SetHighlightFontObject(fontString)
    
    if index == 1 then
        tab:SetPoint("LEFT", 5, 0)
    else
        tab:SetPoint("LEFT", self.frame.tabButtons[index-1], "RIGHT", 5, 0)
    end
    
    tab:SetNormalTexture("Interface/ChatFrame/ChatFrameTab-BGInactive")
    tab:SetHighlightTexture("Interface/ChatFrame/ChatFrameTab-BGHighlight")
    
    tab:SetScript("OnClick", function()
        ValidationWidget:SelectPlayer(playerName)
    end)
    
    return tab
end

-- Update player status
function ValidationWidget:UpdatePlayerStatus(playerName, status)
    if not self.playerData[playerName] then
        self.playerData[playerName] = {}
    end
    
    self.playerData[playerName].status = status
    self:RefreshTabs()
end

-- Update player details
function ValidationWidget:UpdatePlayerDetails(playerName, details)
    if not self.playerData[playerName] then
        self.playerData[playerName] = {}
    end
    
    self.playerData[playerName].details = details
    
    if self.selectedPlayer == playerName then
        self:DisplayPlayerData(playerName)
    end
end

-- Refresh tab buttons
function ValidationWidget:RefreshTabs()
    for _, tab in ipairs(self.frame.tabButtons) do
        tab:Hide()
    end
    wipe(self.frame.tabButtons)
    
    local index = 1
    for playerName in pairs(self.playerData) do
        local tab = self:CreateTab(playerName, index)
        self.frame.tabButtons[index] = tab
        index = index + 1
    end
    
    if not self.selectedPlayer then
        local firstPlayer = next(self.playerData)
        if firstPlayer then
            self:SelectPlayer(firstPlayer)
        end
    end
end

-- Select a player
function ValidationWidget:SelectPlayer(playerName)
    self.selectedPlayer = playerName
    
    for i, tab in ipairs(self.frame.tabButtons) do
        if tab:GetText() == playerName then
            tab:SetNormalTexture("Interface/ChatFrame/ChatFrameTab-BGActive")
        else
            tab:SetNormalTexture("Interface/ChatFrame/ChatFrameTab-BGInactive")
        end
    end
    
    self:DisplayPlayerData(playerName)
end

-- Display player data
function ValidationWidget:DisplayPlayerData(playerName)
    local data = self.playerData[playerName]
    if not data then return end
    
    self.frame.playerName:SetText("Player: " .. playerName)
    
    local status = data.status or "UNKNOWN"
    local statusColor = status == "VALID" and "|cFF00FF00" or "|cFFFF0000"
    self.frame.validationStatus:SetText("Status: " .. statusColor .. status .. "|r")
    
    if data.details then
        local level = data.details.level
        if level then
            local levelText = string.format("Level: %d (Max: %d)", 
                level.current or 0,
                level.maximum or 0
            )
            self.frame.playerLevel:SetText(levelText)
        end
        
        if data.details.equipment then
            for i = 1, 16 do
                local itemLink = data.details.equipment[i]
                local slot = self.frame.equipmentSlots[i]
                
                if itemLink then
                    local icon = C_Item.GetItemIconByID(itemLink)
                    slot.icon:SetTexture(icon)
                    slot.itemLink = itemLink
                    slot.border:Show()
                    
                    local quality = select(3, GetItemInfo(itemLink))
                    if quality then
                        local r, g, b = GetItemQualityColor(quality)
                        slot.border:SetVertexColor(r, g, b)
                    end
                else
                    slot.icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
                    slot.itemLink = nil
                    slot.border:Hide()
                end
            end
        end
    else
        self.frame.playerLevel:SetText("Level: --")
        
        for i = 1, 16 do
            local slot = self.frame.equipmentSlots[i]
            slot.icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
            slot.itemLink = nil
            slot.border:Hide()
        end
    end
end

-- Request validation for currently selected player
function ValidationWidget:RequestCurrentValidation(wantDetails)
    if self.selectedPlayer then
        ns.Core:RequestValidation(nil, wantDetails, self.selectedPlayer)
    end
end

-- Initialize the widget
ValidationWidget.frame = ValidationWidget:Create()
ValidationWidget.window = ValidationWidget.frame
ns.ValidationUI = ValidationWidget
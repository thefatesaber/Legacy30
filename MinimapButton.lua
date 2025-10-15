-- MinimapButton.lua for Legacy30
-- Minimap button implementation
local _, ns = ...
local L30 = ns.Core

-- Create minimap button module
ns.MinimapButton = {}
local MinimapBtn = ns.MinimapButton

-- Button configuration - Using custom logo
local ICON_PATH = "Interface\\AddOns\\Legacy30\\logo"

function MinimapBtn:Initialize()
    -- Create the minimap button
    local button = CreateFrame("Button", "Legacy30MinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    
    -- Icon texture
    button.icon = button:CreateTexture(nil, "BACKGROUND")
    button.icon:SetSize(20, 20)
    button.icon:SetPoint("CENTER", 1, 1)
    button.icon:SetTexture(ICON_PATH)
    button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    
    -- Border texture
    button.border = button:CreateTexture(nil, "OVERLAY")
    button.border:SetSize(53, 53)
    button.border:SetPoint("TOPLEFT", 0, 0)
    button.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    
    -- Highlight texture
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    
    -- Dragging functionality - constrained to minimap edge
    button:SetMovable(true)
    button:RegisterForDrag("LeftButton")
    
    button:SetScript("OnDragStart", function(self)
        self.isDragging = true
        self:LockHighlight()
    end)
    
    button:SetScript("OnDragStop", function(self)
        self.isDragging = false
        self:UnlockHighlight()
        MinimapBtn:SavePosition()
    end)
    
    -- Update position while dragging to stay on minimap edge
    button:SetScript("OnUpdate", function(self)
        if self.isDragging then
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            
            -- Calculate angle from minimap center to cursor
            local angle = math.deg(math.atan2(py - my, px - mx))
            MinimapBtn:SetPosition(angle)
        end
    end)
    
    -- Click handlers
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetScript("OnClick", function(self, btn)
        if btn == "LeftButton" then
            MinimapBtn:OnLeftClick()
        elseif btn == "RightButton" then
            MinimapBtn:OnRightClick()
        end
    end)
    
    -- Tooltip
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Legacy30", 1, 1, 1)
        GameTooltip:AddLine("Dungeon Speedrun Timer", 0.7, 0.7, 0.7)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFFFFFFFFLeft Click:|r Toggle timer frame", 0, 1, 0)
        GameTooltip:AddLine("|cFFFFFFFFRight Click:|r Show menu", 0, 1, 0)
        GameTooltip:AddLine("|cFFFFFFFFDrag:|r Move button", 0.5, 0.5, 0.5)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    self.button = button
    
    -- Load saved position or use default
    self:LoadPosition()
    
    L30:InfoMessage("Minimap button created")
end

-- Left click: Toggle timer frame visibility
function MinimapBtn:OnLeftClick()
    if ns.TimerUI and ns.TimerUI.frame then
        if ns.TimerUI.frame:IsShown() then
            ns.TimerUI.frame:Hide()
            L30:InfoMessage("Timer frame hidden")
        else
            ns.TimerUI.frame:Show()
            L30:InfoMessage("Timer frame shown")
        end
    end
end

-- Right click: Show dropdown menu
function MinimapBtn:OnRightClick()
    -- Create dropdown menu frame if it doesn't exist
    if not self.menuFrame then
        self.menuFrame = CreateFrame("Frame", "Legacy30MinimapDropDown", UIParent, "UIDropDownMenuTemplate")
    end
    
    -- Initialize menu function
    local function InitializeMenu(self, level)
        level = level or 1
        
        local info = UIDropDownMenu_CreateInfo()
        
        if level == 1 then
            -- Title
            info.text = "Legacy30"
            info.isTitle = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Start Timer
            info = UIDropDownMenu_CreateInfo()
            info.text = "Start Timer"
            info.func = function()
                L30:AttemptTimerStart(GetServerTime())
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Stop Timer
            info = UIDropDownMenu_CreateInfo()
            info.text = "Stop Timer"
            info.func = function()
                L30:StopTimer()
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Reset Timer
            info = UIDropDownMenu_CreateInfo()
            info.text = "Reset Timer"
            info.func = function()
                L30:ResetTimer()
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Restart Timer
            info = UIDropDownMenu_CreateInfo()
            info.text = "Restart Timer"
            info.func = function()
                L30:RestartTimer()
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Spacer
            info = UIDropDownMenu_CreateInfo()
            info.text = " "
            info.isTitle = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Show Timer Frame
            info = UIDropDownMenu_CreateInfo()
            info.text = "Show Timer Frame"
            info.func = function()
                if ns.TimerUI and ns.TimerUI.frame then
                    ns.TimerUI.frame:Show()
                end
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Hide Timer Frame
            info = UIDropDownMenu_CreateInfo()
            info.text = "Hide Timer Frame"
            info.func = function()
                if ns.TimerUI and ns.TimerUI.frame then
                    ns.TimerUI.frame:Hide()
                end
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Lock Frames
            info = UIDropDownMenu_CreateInfo()
            info.text = "Lock Frames"
            info.func = function()
                ns.FramesLocked = true
                if ns.TimerUI then
                    ns.TimerUI:SetDraggable(false)
                end
                L30:InfoMessage("Frames locked")
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Unlock Frames
            info = UIDropDownMenu_CreateInfo()
            info.text = "Unlock Frames"
            info.func = function()
                ns.FramesLocked = false
                if ns.TimerUI then
                    ns.TimerUI:SetDraggable(true)
                end
                L30:InfoMessage("Frames unlocked")
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Spacer
            info = UIDropDownMenu_CreateInfo()
            info.text = " "
            info.isTitle = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Export Run
            info = UIDropDownMenu_CreateInfo()
            info.text = "Export Run"
            info.func = function()
                L30:HandleExportRunCommand({})
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Set Encryption Key
            info = UIDropDownMenu_CreateInfo()
            info.text = "Set Encryption Key"
            info.func = function()
                StaticPopup_Show("L30_SET_KEY")
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Spacer
            info = UIDropDownMenu_CreateInfo()
            info.text = " "
            info.isTitle = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
            
            -- Close
            info = UIDropDownMenu_CreateInfo()
            info.text = "Close"
            info.func = function()
                CloseDropDownMenus()
            end
            info.notCheckable = true
            UIDropDownMenu_AddButton(info, level)
        end
    end
    
    -- Initialize and toggle the menu
    UIDropDownMenu_Initialize(self.menuFrame, InitializeMenu, "MENU")
    ToggleDropDownMenu(1, nil, self.menuFrame, "cursor", 0, 0)
end

-- Save button position
function MinimapBtn:SavePosition()
    if not L30.Addon.database then return end
    
    local x, y = self.button:GetCenter()
    local minimapX, minimapY = Minimap:GetCenter()
    local angle = math.deg(math.atan2(y - minimapY, x - minimapX))
    
    L30.Addon.database.minimapButton = {
        angle = angle
    }
end

-- Load button position
function MinimapBtn:LoadPosition()
    if not L30.Addon.database then
        self:SetPosition(225)
        return
    end
    
    local saved = L30.Addon.database.minimapButton
    if saved and saved.angle then
        self:SetPosition(saved.angle)
    else
        self:SetPosition(225)
    end
end

-- Set button position by angle
function MinimapBtn:SetPosition(angle)
    local rad = math.rad(angle)
    local x = math.cos(rad) * 80
    local y = math.sin(rad) * 80
    
    self.button:ClearAllPoints()
    self.button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Show/hide button
function MinimapBtn:Show()
    if self.button then
        self.button:Show()
    end
end

function MinimapBtn:Hide()
    if self.button then
        self.button:Hide()
    end
end

-- Static popup for setting encryption key
StaticPopupDialogs["L30_SET_KEY"] = {
    text = "Enter encryption key:",
    button1 = "Set",
    button2 = "Cancel",
    hasEditBox = 1,
    maxLetters = 64,
    OnAccept = function(self)
        local editBox = self.EditBox or self.editBox
        if not editBox then return end
        
        local key = editBox:GetText()
        if key and key ~= "" then
            if ns.Encryption then
                ns.Encryption:SetKey(key)
                L30:InfoMessage("Encryption key set")
            end
        end
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent()
        local key = self:GetText()
        if key and key ~= "" then
            if ns.Encryption then
                ns.Encryption:SetKey(key)
                L30:InfoMessage("Encryption key set")
            end
        end
        parent:Hide()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3,
}
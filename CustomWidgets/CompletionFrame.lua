-- Completion Frame Widget for Legacy30
-- Original implementation of run completion display
local _, ns = ...

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

local CompletionWidget = {}

-- Constructor
function CompletionWidget:Create()
    local frame = CreateFrame("Frame", "Legacy30CompletionFrame", UIParent, "BackdropTemplate")
    frame:SetSize(500, 300)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.95)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:Hide()
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)
    
    -- Title - SET FONT BEFORE TEXT!
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFont(GetFont(28))  -- MOVED BEFORE SetText
    frame.title:SetPoint("TOP", 0, -30)
    frame.title:SetTextColor(0, 1, 0.4, 1)
    frame.title:SetText("Run Complete!")
    
    -- Dungeon name - SET FONT BEFORE TEXT!
    frame.dungeonName = frame:CreateFontString(nil, "OVERLAY")
    frame.dungeonName:SetFont(GetFont(18))  -- MOVED BEFORE SetText
    frame.dungeonName:SetPoint("TOP", 0, -65)
    frame.dungeonName:SetText("")
    
    -- Time display - SET FONT BEFORE TEXT!
    frame.timeText = frame:CreateFontString(nil, "OVERLAY")
    frame.timeText:SetFont(GetFont(42))  -- MOVED BEFORE SetText
    frame.timeText:SetPoint("CENTER", 0, 20)
    frame.timeText:SetTextColor(0.65, 0.54, 0.96, 1)
    frame.timeText:SetText("00:00")
    
    -- Best time comparison - SET FONT BEFORE TEXT!
    frame.comparisonText = frame:CreateFontString(nil, "OVERLAY")
    frame.comparisonText:SetFont(GetFont(14))  -- MOVED BEFORE SetText
    frame.comparisonText:SetPoint("TOP", frame.timeText, "BOTTOM", 0, -10)
    frame.comparisonText:SetText("")
    
    -- Stats container
    frame.statsFrame = CreateFrame("Frame", nil, frame)
    frame.statsFrame:SetPoint("BOTTOM", 0, 40)
    frame.statsFrame:SetSize(450, 80)
    
    -- Party member icons (up to 3)
    frame.partyIcons = {}
    for i = 1, 3 do
        local icon = frame.statsFrame:CreateTexture(nil, "ARTWORK")
        icon:SetSize(50, 50)
        icon:SetPoint("CENTER", -100 + (i-1) * 100, 0)
        icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
        icon:Hide()
        
        local name = frame.statsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        name:SetPoint("TOP", icon, "BOTTOM", 0, -2)
        name:SetText("")
        
        frame.partyIcons[i] = { texture = icon, name = name }
    end
    
    -- Continue button
    local continueBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    continueBtn:SetPoint("BOTTOM", 0, 15)
    continueBtn:SetSize(120, 30)
    continueBtn:SetText("Continue")
    continueBtn:SetScript("OnClick", function()
        frame:Hide()
    end)
    
    return frame
end

-- Display completion screen
function CompletionWidget:Display(data)
    self.frame.dungeonName:SetText(data.dungeonName or "Dungeon")
    self.frame.timeText:SetText(data.timeString or "00:00")
    
    if data.bestTime and data.improvement then
        if data.improvement > 0 then
            self.frame.comparisonText:SetText(string.format(
                "|cFF00FF00NEW RECORD! -%s|r",
                ns.FormatTime(math.abs(data.improvement))
            ))
            self.frame.comparisonText:SetTextColor(0, 1, 0, 1)
        else
            self.frame.comparisonText:SetText(string.format(
                "Best: %s (+%s)",
                ns.FormatTime(data.bestTime),
                ns.FormatTime(math.abs(data.improvement))
            ))
            self.frame.comparisonText:SetTextColor(1, 0.8, 0, 1)
        end
    else
        self.frame.comparisonText:SetText("|cFF00FFFFFirst completion!|r")
    end
    
    self:UpdatePartyDisplay()
    
    self.frame:Show()
    
    PlaySound(SOUNDKIT.RAID_BOSS_VICTORY)
end

-- Update party member display
function CompletionWidget:UpdatePartyDisplay()
    local shown = 0
    
    shown = shown + 1
    self:SetPartyIcon(shown, "player")
    
    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) then
            shown = shown + 1
            if shown <= 3 then
                self:SetPartyIcon(shown, unit)
            end
        end
    end
    
    for i = shown + 1, 3 do
        self.frame.partyIcons[i].texture:Hide()
        self.frame.partyIcons[i].name:SetText("")
    end
end

-- Set party icon
function CompletionWidget:SetPartyIcon(index, unit)
    local icon = self.frame.partyIcons[index]
    if not icon then return end
    
    local _, class = UnitClass(unit)
    if class then
        local texPath = "Interface\\TargetingFrame\\UI-Classes-Circles"
        icon.texture:SetTexture(texPath)
        
        local coords = CLASS_ICON_TCOORDS[class]
        if coords then
            icon.texture:SetTexCoord(unpack(coords))
        end
    end
    
    local name = UnitName(unit)
    icon.name:SetText(name or "")
    
    icon.texture:Show()
end

-- Initialize the widget
CompletionWidget.frame = CompletionWidget:Create()
ns.CompletionUI = CompletionWidget
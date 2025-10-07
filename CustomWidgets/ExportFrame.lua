-- Export Frame Widget for Legacy30
-- Original implementation of data export display
local _, ns = ...

local ExportWidget = {}

-- Constructor
function ExportWidget:Create()
    local frame = CreateFrame("Frame", "Legacy30ExportFrame", UIParent, "BackdropTemplate")
    frame:SetSize(900, 600)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.95)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    
    -- Title bar
    frame.titleBar = CreateFrame("Frame", nil, frame)
    frame.titleBar:SetPoint("TOPLEFT")
    frame.titleBar:SetPoint("TOPRIGHT")
    frame.titleBar:SetHeight(30)
    frame.titleBar:EnableMouse(true)
    
    frame.title = frame.titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("CENTER")
    frame.title:SetText("Export Data")
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)
    
    -- Scroll frame for text
    frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "ScrollingEditBoxTemplate")
    frame.scrollFrame:SetPoint("TOPLEFT", 15, -40)
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)
    
    -- Edit box
    frame.editBox = frame.scrollFrame.EditBox
    frame.editBox:SetFontObject("GameFontNormalSmall")
    frame.editBox:SetAutoFocus(false)
    frame.editBox:SetMultiLine(true)
    frame.editBox:SetMaxLetters(0)
    frame.editBox:SetScript("OnEscapePressed", function()
        frame:Hide()
    end)
    
    -- Scroll bar
    frame.scrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
    frame.scrollBar:SetPoint("TOPRIGHT", -10, -40)
    frame.scrollBar:SetPoint("BOTTOMRIGHT", -10, 50)
    frame.scrollBar:SetHideIfUnscrollable(true)
    
    ScrollUtil.RegisterScrollBoxWithScrollBar(frame.scrollFrame.ScrollBox, frame.scrollBar)
    
    -- Copy button
    frame.copyBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.copyBtn:SetPoint("BOTTOM", 0, 15)
    frame.copyBtn:SetSize(150, 30)
    frame.copyBtn:SetText("Select All")
    frame.copyBtn:SetScript("OnClick", function()
        frame.editBox:HighlightText()
        frame.editBox:SetFocus()
    end)
    
    -- Character count
    frame.charCount = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.charCount:SetPoint("BOTTOMLEFT", 15, 15)
    frame.charCount:SetText("0 characters")
    frame.charCount:SetTextColor(0.7, 0.7, 0.7, 1)
    
    return frame
end

-- Show data in export window
function ExportWidget:ShowData(text)
    self.frame.editBox:SetText(text)
    
    local length = string.len(text)
    self.frame.charCount:SetText(string.format("%s characters", 
        self:FormatNumber(length)
    ))
    
    self.frame:Show()
    
    C_Timer.After(0.1, function()
        self.frame.editBox:HighlightText()
        self.frame.editBox:SetFocus()
    end)
end

-- Format number with commas
function ExportWidget:FormatNumber(num)
    local formatted = tostring(num)
    local k
    
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    
    return formatted
end

-- Initialize the widget
ExportWidget.frame = ExportWidget:Create()
ns.ExportUI = ExportWidget
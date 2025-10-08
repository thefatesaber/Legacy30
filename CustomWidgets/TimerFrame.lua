-- ============================================
-- FIX 1: TimerFrame.lua (around line 60-70)
-- ============================================
-- BEFORE calling SetText(), add SetFont():

-- Find these lines:
frame.title = frame:CreateFontString(nil, "OVERLAY")
-- ADD THIS LINE immediately after:
frame.title:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
frame.title:SetTextColor(1, 1, 1)
frame.title:SetPoint("TOP", 0, -10)
frame.title:SetText("Legacy30 Timer")  -- Now this works!

-- Same for timerText:
frame.timerText = frame:CreateFontString(nil, "OVERLAY")
-- ADD THIS LINE immediately after:
frame.timerText:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
frame.timerText:SetTextColor(1, 0.84, 0)
frame.timerText:SetPoint("CENTER")
frame.timerText:SetText("00:00")  -- Now this works!


-- ============================================
-- FIX 2: CompletionFrame.lua (around line 45-50)
-- ============================================

-- Find this:
frame.title = frame:CreateFontString(nil, "OVERLAY")
-- ADD THIS LINE immediately after:
frame.title:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
frame.title:SetTextColor(0.18, 0.8, 0.44)
frame.title:SetPoint("TOP", 0, -15)
frame.title:SetText("Run Complete!")  -- Now this works!


-- ============================================
-- FIX 3: ValidationFrame.lua (around line 52-58)
-- ============================================

-- Find this:
frame.title = frame:CreateFontString(nil, "OVERLAY")
-- ADD THIS LINE immediately after:
frame.title:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
frame.title:SetTextColor(1, 1, 1)
frame.title:SetPoint("TOP", 0, -15)
frame.title:SetText("Run Validation")  -- Now this works!


-- ============================================
-- FIX 4: ExportFrame.lua (around line 35-55)
-- ============================================

-- The editBox needs to be CREATED before you set its points
-- Find the section where the scrollFrame is created, then ADD:

-- After creating scrollFrame:
local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -40)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

-- ADD THESE LINES to create the editBox:
local editBox = CreateFrame("EditBox", nil, scrollFrame)
editBox:SetMultiLine(true)
editBox:SetMaxLetters(0)
editBox:SetFont("Fonts\\FRIZQT__.TTF", 11)
editBox:SetAutoFocus(false)
editBox:SetWidth(scrollFrame:GetWidth() - 30)
editBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
end)

-- Store it so other methods can access it:
self.editBox = editBox
frame.scrollFrame:SetScrollChild(editBox)

-- Now you can set points on editBox:
editBox:SetPoint("TOPLEFT", 10, -10)
editBox:SetPoint("BOTTOMRIGHT", -30, 50)


-- ============================================
-- ALTERNATIVE: Create a Helper Function
-- ============================================
-- Add this at the top of any CustomWidget file for consistency:

local function SetupFontString(fontString, size, flags)
    size = size or 12
    flags = flags or "OUTLINE"
    fontString:SetFont("Fonts\\FRIZQT__.TTF", size, flags)
    fontString:SetShadowColor(0, 0, 0, 1)
    fontString:SetShadowOffset(1, -1)
end

-- Then use it like:
local title = frame:CreateFontString(nil, "OVERLAY")
SetupFontString(title, 18)
title:SetTextColor(1, 1, 1)
title:SetText("My Title")  -- Works perfectly!


-- ============================================
-- OR: Use GameFont Objects (Simplest)
-- ============================================

-- Instead of calling SetFont manually, use Blizzard's font objects:

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.title:SetText("My Title")  -- Works immediately!

-- Available font objects:
-- "GameFontNormal"          - Standard text (12pt)
-- "GameFontNormalLarge"     - Large text (16pt)
-- "GameFontNormalHuge"      - Huge text (20pt)
-- "GameFontHighlight"       - Bright yellow text
-- "GameFontHighlightLarge"  - Large bright text
-- "GameFontDisable"         - Grayed out text


-- ============================================
-- SUMMARY OF CHANGES NEEDED:
-- ============================================
-- 1. TimerFrame.lua: Add SetFont() before SetText() on title and timerText
-- 2. CompletionFrame.lua: Add SetFont() before SetText() on title
-- 3. ValidationFrame.lua: Add SetFont() before SetText() on title  
-- 4. ExportFrame.lua: CREATE the editBox before setting its points

-- After making these changes, /reload and all font errors should be fixed!
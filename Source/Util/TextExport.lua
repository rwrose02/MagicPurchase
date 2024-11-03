---@class ns
local ns = select(2, ...)
local TextExporter = {}
TextExporter.__index = TextExporter
function TextExporter.new(text)
    local self = setmetatable({}, TextExporter)
    local f = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(600, 400)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
   
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.title:SetPoint("TOPLEFT", f.TitleBg, "TOPLEFT", 5, 0)
    f.title:SetText("Text Export")
   
    f.scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    f.scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -30)
    f.scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 8)
   
    f.editBox = CreateFrame("EditBox", nil, f.scrollFrame)
    f.editBox:SetMultiLine(true)
    f.editBox:SetFontObject("ChatFontNormal")
    f.editBox:SetWidth(f.scrollFrame:GetWidth())
    f.scrollFrame:SetScrollChild(f.editBox)
    f.editBox:SetText(text)
    f.editBox:HighlightText()
   
    -- Add a close button handler
    f.CloseButton:SetScript("OnClick", function()
        f:Hide()
    end)
    self.frame = f
    return self
end  
-- Create export window

-- Function to show the export window with the given text and title
function TextExporter:setText(text)
    self.frame.editBox:SetText(text)
    self.frame:Show()
end

-- Function to hide the export window
function TextExporter:HideExportWindow()
    self.frame:Hide()
end
function TextExporter:Export(text)
    self:setText(text)
end
ns.TextExporter = TextExporter
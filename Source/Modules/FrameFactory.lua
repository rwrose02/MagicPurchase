---@class ns
local ns = select(2, ...)

---@class FrameFactory
local FrameFactory = {}
ns.FrameFactory = FrameFactory

function FrameFactory:CreatePanelButton(parent, text, size)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(size or 80, 25)
    button:SetText(text)
    return button
end
---comment
---@param parent table|BackdropTemplate|Frame
---@param text string
---@param template any
---@return FontString
function FrameFactory:CreateLabel(parent, text, template)
    local label = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
    label:SetText(text)
    return label
end

---comment
---@param parent table|BackdropTemplate|Frame
---@param text string
---@param value any
---@return table <FontString ,FontString>
function FrameFactory:CreateField(parent,text,value)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText(text)
    local valueLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    valueLabel:SetText(value)
    valueLabel:SetPoint("LEFT", label, "RIGHT", 0, 0)
    
    return {label,valueLabel}
end
---comment
---@param name any
---@param size_x any
---@param size_y any
---@return table|BackdropTemplate|Frame
function FrameFactory:CreateMainFrame(name, size_x, size_y)
    local frame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    local size_x = size_x or 200
    local size_y = size_y or 175
    frame:SetSize(size_x, size_y)
    frame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    return frame
end

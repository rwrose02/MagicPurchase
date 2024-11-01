---@class ns
local ns = select(...)

-- Query Button Mixin
local DisplayButtonMixin = {}

function DisplayButtonMixin:OnLoad(DefaultText, ...)
    -- Set up default properties
    self:SetSize(120, 22)
    self:SetText(DefaultText or "Query")
    
    -- Set up scripts
    self:SetScript("OnEnter", self.OnEnter)
    self:SetScript("OnLeave", self.OnLeave)
    self:SetScript("OnClick", self.OnClick)
end

function DisplayButtonMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.tooltipText or "Query")
    GameTooltip:Show()
end

function DisplayButtonMixin:OnLeave()
    GameTooltip:Hide()
end

function DisplayButtonMixin:OnClick()
    -- Default query behavior
    if self.OnQueryClick then
        self:OnQueryClick()
    end
end

function DisplayButtonMixin:SetTooltip(text)
    self.tooltipText = text
end
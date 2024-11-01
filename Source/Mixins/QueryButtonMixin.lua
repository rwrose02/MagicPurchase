local addonName, addon = ...

-- Query Button Mixin
local QueryButtonMixin = {}

function QueryButtonMixin:OnLoad()
    -- Set up default properties
    self:SetSize(120, 22)
    self:SetText("Query")
    
    -- Set up scripts
    self:SetScript("OnEnter", self.OnEnter)
    self:SetScript("OnLeave", self.OnLeave)
    self:SetScript("OnClick", self.OnClick)
end

function QueryButtonMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.tooltipText or "Query")
    GameTooltip:Show()
end

function QueryButtonMixin:OnLeave()
    GameTooltip:Hide()
end

function QueryButtonMixin:OnClick()
    -- Default query behavior
    if self.OnQueryClick then
        self:OnQueryClick()
    end
end

function QueryButtonMixin:SetTooltip(text)
    self.tooltipText = text
end

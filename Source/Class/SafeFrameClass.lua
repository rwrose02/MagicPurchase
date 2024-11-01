---@class ns
local ns = select(2, ...)

---@class FrameFactory
local FrameFactory = ns.FrameFactory
-- Define the SafeFrame "class"
local SafeFrame = {}
SafeFrame.__index = SafeFrame

-- Constructor function
function SafeFrame.new()
    local self = setmetatable({}, SafeFrame)
    local Y_SPACING = -7
    
    -- Create the main frame
    self.frame = FrameFactory:CreateMainFrame("SafePriceFrame")
    self:createComponents()
    self:setupEventHandlers()
    
    return self
end

-- Initialize the frame propertiesd

-- Create all UI components
function SafeFrame:createComponents()
    -- Create title label
    self.label = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.label:SetPoint("TOP", self.frame, "TOP", 0, -5)
    self.label:SetText("Safe Price Frame")
    
    -- Create price label
    self.setPriceLabel = self.frame:CreateFontString("setPriceLabel", "OVERLAY", "GameFontHighlight")
    self.setPriceLabel:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 9, -32)
    self.setPriceLabel:SetText("Set Price:")
    
    -- Create edit box
    self.editBox = CreateFrame("EditBox", nil, self.frame, "InputBoxTemplate")
    self.editBox:SetSize(115, 15)
    self.editBox:SetPoint("LEFT", self.setPriceLabel, "RIGHT", 10, 0)
    self.editBox:SetAutoFocus(false)
    
    -- Create close button
    self.closeButton = CreateFrame("Button", nil, self.frame, "GameMenuButtonTemplate")
    self.closeButton:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 10)
    self.closeButton:SetSize(100, 20)
    self.closeButton:SetText("Close")
    self.closeButton:SetNormalFontObject("GameFontNormal")
    self.closeButton:SetHighlightFontObject("GameFontHighlight")
    
    -- Create show price button
    self.showPriceButton = CreateFrame("Button", nil, self.frame, "GameMenuButtonTemplate")
    self.showPriceButton:SetPoint("BOTTOMRIGHT", self.frame, "RIGHT", 0, 10)
    self.showPriceButton:SetSize(100, 20)
    self.showPriceButton:SetText("Show Price")
    self.showPriceButton:SetNormalFontObject("GameFontNormal")
    self.showPriceButton:SetHighlightFontObject("GameFontHighlight")
end

-- Set up all event handlers
function SafeFrame:setupEventHandlers()
    -- Frame movement handlers
    self.frame:SetScript("OnDragStart", function() self.frame:StartMoving() end)
    self.frame:SetScript("OnDragStop", function() self.frame:StopMovingOrSizing() end)
    
    -- Edit box handler
    self.editBox:SetScript("OnEnterPressed", function(editBox)
        self:handlePriceInput(editBox:GetText())
        editBox:SetText("")
        editBox:ClearFocus()
    end)
    
    -- Button handlers
    self.closeButton:SetScript("OnClick", function()
        self:hide()
    end)
    
    self.showPriceButton:SetScript("OnClick", function()
        ns.util.MagicPriceView()
    end)
end

-- Handle price input logic
function SafeFrame:handlePriceInput(input)
    if input == "" or input == nil then
        print("No input detected")
        return
    end
    
    local numericInput = tonumber(input)
    if not numericInput then
        print("Invalid input detected")
        return
    end
    
    local convertedPrice = numericInput * 100 * 100
    
    if ns.currentItemId:getValue() == -1 then
        ns.def_safe_price = convertedPrice
        print("Default Safe Price: " .. ns.def_safe_price)
    else
        local currentItemId = ns.currentItemId:getValue()
        ns.safe_table[currentItemId] = convertedPrice
        
        local succeeded = ns.safe_price:setValue(ns.safe_table[currentItemId])
        if not succeeded then
            print("Failed to set safe price")
        else
            print("Safe Price Set for Item: " .. currentItemId .. " to: " .. ns.safe_price:getValue())
        end
    end
end

-- Public methods
function SafeFrame:show()
    self.frame:Show()
end

function SafeFrame:hide()
    self.frame:Hide()
end

function SafeFrame:toggle()
    if self.frame:IsShown() then
        self:hide()
    else
        self:show()
    end
end

-- Create and return an instance
function ns.CreateSafeFrame()
    local safeFrame = SafeFrame.new()
    return safeFrame
end
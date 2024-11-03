---@class ns
local ns = select(2, ...)
---@class FrameFactory
local FrameFactory = ns.FrameFactory

-- Create the frame class
local PurchaseFrame = {}
PurchaseFrame.__index = PurchaseFrame

-- Refactored PurchaseFrame constructor
function PurchaseFrame.new()
    local self = setmetatable({}, PurchaseFrame)
    local Y_SPACING = -7

    -- Create main frame
    self.frame = FrameFactory:CreateMainFrame("SafeFrame", 200, 200)
    
    -- Create labels with consistent spacing
    local labels = {
        {key = "title", text = "Magic Purchase", template = "GameFontNormalLarge"},
        {key = "itemInfo",text = "No Item Selected"},
        {key = "itemId",text = "ItemID: None"},
        {key = "quantity", text= "Quantity: 0"},
        {key = "price", text = "Max Price: 0g"}
    }
    
    local previousLabel
    for _, config in ipairs(labels) do
        local label = FrameFactory:CreateLabel(self.frame, config.text, config.template)
        if config.key == "title" then
            label:SetPoint("TOP", self.frame, "TOP", 0, -10)
        else
            label:SetPoint("TOP", previousLabel, "BOTTOM", 0, Y_SPACING)
        end
        self[config.key .. "Text"] = label
        previousLabel = label
        -- DevTool:AddData(config.key .. "Text", "label text")
    end

    -- Create buttons with consistent configuration
    local buttons = {
        setup = {text = "Setup", point = {"BOTTOM", self.frame, "BOTTOM", -45, 30}},
        confirm = {text = "Confirm", point = {"BOTTOM", self.frame, "BOTTOM", 45, 30}, disabled = true},
        query = {text = "Query", point = {"BOTTOM", self.frame, "BOTTOM", 0, 3}, disabled = true},
        safePrice = {text = "Safe Price", point = {"TOPLEFT", self.frame, "TOPLEFT", 0, 25}}
    }
    for key, config in pairs(buttons) do
        local button = FrameFactory:CreatePanelButton(self.frame, config.text)
        button:SetPoint(unpack(config.point))
        if config.disabled then
            button:Disable()
        end
        self[key .. "Button"] = button
    end

    --[[
    QUICK AND DIRTY WAY TO ADD TIMER CHANGE
    ]]
    self.confirmSettings = {
        baseDelay = 0.25,
        bulkDelay = 0.25,
        lastConfirmTime = 0
    }
    -- Create delay settings edit box
    local delayEditBox = CreateFrame("EditBox", nil, self.frame, "InputBoxTemplate")
    delayEditBox:SetSize(50, 20)
    delayEditBox:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -10, 60)
    delayEditBox:SetAutoFocus(false)
    delayEditBox:SetMaxLetters(4)
    delayEditBox:SetText(tostring(self.confirmSettings.baseDelay))
    
    -- Create delay label
    local delayLabel = FrameFactory:CreateLabel(self.frame, "Confirm Delay (sec):")
    delayLabel:SetPoint("RIGHT", delayEditBox, "LEFT", -5, 0)
    
    -- Add tooltip
    delayEditBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Set delay between confirm clicks (0.1 to 9.9 seconds)")
        GameTooltip:Show()
    end)
    delayEditBox:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Handle input validation and updating
    delayEditBox:SetScript("OnTextChanged", function(self)
        local text = self:GetText()
        -- Remove any non-numeric or decimal characters
        text = string.gsub(text, "[^%d%.]", "")
        -- Ensure only one decimal point
        local decimalCount = select(2, string.gsub(text, "%.", ""))
        if decimalCount > 1 then
            text = string.match(text, "%d*%.?%d*")
        end
        if text ~= self:GetText() then
            self:SetText(text)
        end
    end)
    
    delayEditBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value then
            -- Clamp value between 0.1 and 9.9
            value = math.max(0.001, math.min(9.9, value))
            -- Round to one decimal place
            self:SetText(tostring(value))
            -- Update both base and bulk delays
            ns.purchaseFrame:SetConfirmDelays(value, value)
        end
        self:ClearFocus()
    end)
    
    -- Store reference to edit box
    self.delayEditBox = delayEditBox
    

    -- Create close button (special case)
    local closeButton = CreateFrame("Button", nil, self.frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -1, -1)

    -- Set up state tracking
    self.setupButton.setupState = false
    self.querySettings = {
        baseDelay = 0.4,
        bulkDelay = 0.4,
        lastQueryTime = 0
    }
    -- Set up display value tracking
    self.displayValues = {
        itemId = {
            stateManager = ns.currentItemId,
            display = self.itemInfoText,
            idDisplay = self.itemIdText,
            pending = false
        },
        quantity = {
            stateManager = ns.tqb,
            display = self.quantityText
        },
        maxPrice = {
            stateManager = ns.safe_price,
            display = self.priceText
        },
    }

    -- Set up event handlers
    self:SetupEventHandlers()

    return self
end

-- Separate method for event handling setup
function PurchaseFrame:SetupEventHandlers()
    self.setupButton:SetScript("OnClick", function() self:OnSetupClick() end)
    self.confirmButton:SetScript("OnClick", function() self:OnConfirmClick() end)
    self.queryButton:SetScript("OnClick", function() self:QueryItem() end)
    self.frame:HookScript("OnUpdate", function() self:UpdateDisplay() end)
    self.queryButton:HookScript("OnUpdate", function() self:UpdateQueryButtonState() end)
    self.confirmButton:HookScript("OnUpdate", function() self:UpdateConfirmButtonState() end)
end

-- Check if StateManager value has changed from last displayed value
function PurchaseFrame:HasValueChanged(stateValue, lastDisplayedValue)
    return stateValue:getValue() ~= lastDisplayedValue
end

--[UPDATE DISPLAYS]

function PurchaseFrame:UpdateItemInfo()
    local itemValue = self.displayValues.itemId
    local currentItemId = itemValue.stateManager:getValue()
    -- Only update if the ID changed and we're not already waiting for info
    if self:HasValueChanged(itemValue.stateManager, itemValue.current) and not itemValue.pending then
        itemValue.pending = true
        
        ns.util.GetReagentItemInfo(currentItemId, function(itemInfo)
            itemValue.display:SetText(itemInfo.fullName or "No Item Selected")
            itemValue.idDisplay:SetText(string.format("ItemID: %s", currentItemId or "None"))
            itemValue.current = currentItemId
            itemValue.pending = false
        end)
    end
end

function PurchaseFrame:UpdateQuantity()
    local quantityValue = self.displayValues.quantity
    local currentQuantity = quantityValue.stateManager:getValue()
    if self:HasValueChanged(quantityValue.stateManager, quantityValue.current) then
        quantityValue.display:SetText(string.format("Quantity: %s", currentQuantity or "0"))
        quantityValue.current = currentQuantity
    end
end

function PurchaseFrame:UpdateMaxPrice()
    local priceValue = self.displayValues.maxPrice
    local currentMaxPrice = priceValue.stateManager:getValue()
    
    if self:HasValueChanged(priceValue.stateManager, priceValue.current) then
        priceValue.display:SetText(string.format("Max Price: %.2fg", 
            currentMaxPrice and currentMaxPrice / 10000 or 0))
        priceValue.current = currentMaxPrice
    end
end

-- Optional: Add method to watch for state locks
function PurchaseFrame:UpdateButtonStates()
    local isLocked = self.displayValues.itemId.stateManager:getState() or
                     self.displayValues.quantity.stateManager:getState() or
                     self.displayValues.maxPrice.stateManager:getState()
                     
    -- Disable buttons if states are locked
    self.confirmButton:SetEnabled(not isLocked)
    self.queryButton:SetEnabled(not isLocked)
end

-- Main update function
function PurchaseFrame:UpdateDisplay()
    self:UpdateItemInfo()
    self:UpdateQuantity()
    self:UpdateMaxPrice()
    -- self:UpdateButtonStates()
end

-- Force update now just clears the cached values
function PurchaseFrame:ForceUpdateDisplay()
    for _, value in pairs(self.displayValues) do
        value.current = nil
        value.pending = false
    end
    self:UpdateDisplay()
end

-- Update specific display with StateManager awareness
function PurchaseFrame:UpdateSpecificDisplay(displayType)
    if displayType == "item" then
        self:UpdateItemInfo()
    elseif displayType == "quantity" then
        self:UpdateQuantity()
    elseif displayType == "price" then
        self:UpdateMaxPrice()
    end
    self:UpdateButtonStates()
end

--[QUERY BUTTON]

function PurchaseFrame:QueryItem()
    local canQuery, message = self:IsQueryAllowed()
    if not canQuery then
        return false
    end

    local sort_order = {
        sortOrder = 4,
        reverseSort = false
    }
    
    -- Disable button immediately
    self.queryButton:SetEnabled(false)
    self.queryButton:SetText("Querying...")
    
    -- Send query and update timestamp
    local results = C_AuctionHouse.SendSearchQuery(ns.itemKey, sort_order, false)
    self.querySettings.lastQueryTime = GetTime()
    
    return true
end

function PurchaseFrame:IsQueryAllowed()
    if not self.setupButton.setupState then
        return false, "No Query"
    end
    local itemKey = ns.itemKey
    if not itemKey then
        return false, "No item selected"
    end


    local quantity = ns.tqb:getValue()
    local currentDelay = quantity and quantity > 0 
        and self.querySettings.bulkDelay
        or self.querySettings.baseDelay

    local timeRemaining = currentDelay - (GetTime() - self.querySettings.lastQueryTime)
    
    if timeRemaining > 0 then
        return false, string.format("%.1f sec", timeRemaining)
    end

    return true, "Query Allowed"
end

function PurchaseFrame:UpdateQueryButtonState()
    local canQuery, message = self:IsQueryAllowed()
    
    self.queryButton:SetEnabled(canQuery)
    
    if not canQuery then
        self.queryButton:SetText(message)
        --self.queryButton:SetText(string.format("Query (%s)", message))
    else
        self.queryButton:SetText("Query")

    end
end
function PurchaseFrame:SetQueryDelays(baseDelay, bulkDelay)
    if baseDelay then
        self.querySettings.baseDelay = baseDelay
    end
    if bulkDelay then
        self.querySettings.bulkDelay = bulkDelay
    end
end

--[CONFIRM BUTTON]

function PurchaseFrame:IsConfirmAllowed()
    if not self.setupButton.setupState then
        return false, "No Confirm"
    end
    local itemKey = ns.itemKey
    if not itemKey then
        return false, "No item selected"
    end


    local quantity = ns.tqb:getValue()
    local currentDelay = quantity and quantity > 0 
        and self.confirmSettings.bulkDelay
        or self.confirmSettings.baseDelay

    local timeRemaining = currentDelay - (GetTime() - self.confirmSettings.lastConfirmTime)
    
    if timeRemaining > 0 then
        return false, string.format("%.1f sec", timeRemaining)
    end

    return true, "Confirm Allowed"
end
function PurchaseFrame:UpdateConfirmButtonState()
    local canConfirm, message = self:IsConfirmAllowed()
    
    self.confirmButton:SetEnabled(canConfirm)
    
    if not canConfirm then
        self.confirmButton:SetText(message)
        --self.queryButton:SetText(string.format("Query (%s)", message))
    else
        self.confirmButton:SetText("Confirm")

    end
end
function PurchaseFrame:SetConfirmDelays(baseDelay, bulkDelay)
    if baseDelay then
        self.confirmSettings.baseDelay = baseDelay
        self.delayEditBox:SetText(tostring(baseDelay))
    end
    if bulkDelay then
        self.confirmSettings.bulkDelay = bulkDelay
    end
end

function PurchaseFrame:OnConfirmClick()
    if not ns.currentItemId:getValue() or not ns.tqb:getValue() or not ns.safe_price:getValue() then
        -- print("Missing required purchase information")
        return
    end
    self.confirmButton:SetEnabled(false)
    self.confirmButton:SetText("Confirming...")
    ns.InitiatePurchase(ns.currentItemId:getValue(), ns.tqb:getValue(), ns.safe_price:getValue())
    ns.TimingInstance:AddKeyExec("PURCHASE_FRAME_HANDED_OFF", ns.TimingInstance:PreciseTime())
end

--[INTERNAL SETUP]
function PurchaseFrame:InternalUpdate()
    local itemLink = ns.AHFrame:GetCurrentItemID()
    local id_set = ns.currentItemId:setValue(itemLink)
    local price_set = ns.safe_price:setValue(ns.safe_table[itemLink])
    local quantity_set = ns.tqb:setValue(0)
    local itemKey = AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.ItemDisplay:GetItemKey()
    ns.itemKey = itemKey
    ns.last_call = GetTime()
    print(ns.safe_price:getValue())
    print(ns.currentItemId:getValue())
    print(ns.tqb:getValue())
    return id_set,price_set,quantity_set,quantity_set
end
function PurchaseFrame:OnSetupClick()
    local id_set,price_set,quantity_set = self:InternalUpdate()
    
    if (not id_set or not price_set or not quantity_set) then
        print("Missing required search information")
        return
    end
    self.setupButton.setupState = true
    self:ForceUpdateDisplay()
    self:UpdateDisplay()
    
    -- self:UpdateQueryButtonState()
    
    -- wait for the results to be updated
    -- yield to results frame
    if not ns.ResultMonitor then
        ns.ResultMonitor = ns.CreateResultsMonitor()
    end
    ns.ResultMonitor:ListenForEvents()
    -- refresh the commodity search results
    -- C_AuctionHouse.RefreshCommoditySearchResults(ns.currentItemId:getValue())
    -- C_Timer.After(1, function()
    --     print("killed: q", ns.ResultMonitor.TotalQuantity)
    --     ns.ResultMonitor:reset_state()
    --     self:UpdateDisplay()
    -- end)
    self.queryButton:Enable()
    self.confirmButton:Enable()
end
-- function to manually search by item id using C_AuctionHouse.SendSearchQuery

-- Create and initialize the frame
ns.purchaseFrame = PurchaseFrame.new()

-- Add show/hide functions
function ns.ShowPurchaseFrame()
    ns.purchaseFrame.frame:Show()
    ns.purchaseFrame:UpdateDisplay()
end

function ns.HidePurchaseFrame()
    ns.purchaseFrame.frame:Hide()
end

function ns.confirmClicker()
    ns.purchaseFrame:OnConfirmClick()
end
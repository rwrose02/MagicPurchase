---@class ns
local ns = select(2, ...)

-- Create the frame class
local PurchaseFrame = {}
PurchaseFrame.__index = PurchaseFrame

function PurchaseFrame.new()
    local self = setmetatable({}, PurchaseFrame)

    -- Create main frame
    local frame = CreateFrame("Frame", "MagicPurchaseFrame", UIParent, "BackdropTemplate")
    frame:SetSize(200, 150)
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

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -10)
    title:SetText("Magic Purchase")

    -- Item Info
    local itemInfo = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemInfo:SetPoint("TOP", title, "BOTTOM", 0, -10)
    itemInfo:SetText("No Item Selected")

    -- Quantity Text
    local quantityText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    quantityText:SetPoint("TOP", itemInfo, "BOTTOM", 0, -10)
    quantityText:SetText("Quantity: 0")

    -- Max Price Text
    local priceText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    priceText:SetPoint("TOP", quantityText, "BOTTOM", 0, -10)
    priceText:SetText("Max Price: 0g")

    -- Setup Button
    local setupButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    setupButton:SetSize(80, 25)
    setupButton:SetPoint("BOTTOM", frame, "BOTTOM", -45, 30)
    setupButton:SetText("Setup")

    -- Confirm Button
    local confirmButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    confirmButton:SetSize(80, 25)
    confirmButton:SetPoint("BOTTOM", frame, "BOTTOM", 45, 30)
    confirmButton:SetText("Confirm")
    confirmButton:Disable() -- Disabled by default until setup

    local queryButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    queryButton:SetSize(80, 25)
    queryButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 3)
    queryButton:SetText("Query")
    queryButton:Disable() -- Disabled by default until setup

    -- Close Button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    local safePriceButton = CreateFrame("Button", "nil", frame, "UIPanelButtonTemplate")
    safePriceButton:SetSize(80, 25)
    safePriceButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 25)
    safePriceButton:SetText("Safe Price")
    -- Store references
    self.frame = frame
    self.itemInfo = itemInfo
    self.quantityText = quantityText
    self.priceText = priceText
    self.setupButton = setupButton
    self.confirmButton = confirmButton
    self.queryButton = queryButton

    -- Setup click handlers
    setupButton:SetScript("OnClick", function() self:OnSetupClick() end) -- do these need to be 
    confirmButton:SetScript("OnClick", function() self:OnConfirmClick() end)
    closeButton:SetScript("OnClick", function() frame:Hide() end)
    queryButton:SetScript("OnClick", function() self:QueryItem() end)
    self.frame:HookScript("OnUpdate", function() self:UpdateDisplay() end)
    

    return self
end

function PurchaseFrame:UpdateDisplay()
    local currentItemId = ns.currentItemId:getValue()
    local quantity = ns.tqb:getValue()
    local maxPrice = ns.safe_price:getValue()


    -- Check if item info has changed
    if self.lastItemId ~= currentItemId then
        self.itemInfo:SetText(currentItemId or "No Item Selected")
        self.lastItemId = currentItemId  -- Store the new value
    end

    -- Check if quantity has changed
    if self.lastQuantity ~= quantity then
        self.quantityText:SetText(string.format("Quantity: %d", quantity))
        self.lastQuantity = quantity  -- Store the new value
    end

    -- Check if max price has changed (divide by 10000 to display in gold)
    local displayedPrice = maxPrice
    if self.lastMaxPrice ~= displayedPrice then
        self.priceText:SetText(string.format("Max Price: %.2fg", maxPrice and maxPrice / 10000 or 0))
        self.lastMaxPrice = displayedPrice  -- Store the new value
    end
end
function PurchaseFrame:QueryItem()
    local itemKey = ns.itemKey
    local lastcall = ns.last_call
    local quantity = ns.tqb:getValue()
    if not itemKey then
        print("No item selected")
        return false
    end
    local delay_time = 0.6
    if quantity <= 0 then
        delay_time = 0.6
    else
        delay_time = 0.04
    end
    if GetTime() - ns.last_call < delay_time then
        print("Too soon")
        return false
    else
        local sort_order = {
            sortOrder = 4,
            reverseSort = false
        }
        local results = C_AuctionHouse.SendSearchQuery(itemKey,sort_order,false)
        ns.last_call = GetTime()
        return true
    end
end
function PurchaseFrame:OnSetupClick()
    local itemLink = ns.util.GetCurrentItemID()
    local id_set = ns.currentItemId:setValue(itemLink)
    local price_set = ns.safe_price:setValue(ns.safe_table[itemLink])
    local itemKey = AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.ItemDisplay:GetItemKey()
    ns.itemKey = itemKey
    ns.last_call = GetTime()
    print(ns.safe_price:getValue())
    if (not id_set or not price_set) then
        print("Missing required search information")
        return
    end
    self:UpdateDisplay()
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
function PurchaseFrame:OnConfirmClick()
    if not ns.currentItemId:getValue() or not ns.tqb:getValue() or not ns.safe_price:getValue() then
        -- print("Missing required purchase information")
        return
    end

    ns.InitiatePurchase(ns.currentItemId:getValue(), ns.tqb:getValue(), ns.safe_price:getValue())
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
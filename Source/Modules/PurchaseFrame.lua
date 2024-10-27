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

    -- Setup click handlers
    setupButton:SetScript("OnClick", function() self:OnSetupClick() end)
    confirmButton:SetScript("OnClick", function() self:OnConfirmClick() end)
    closeButton:SetScript("OnClick", function() frame:Hide() end)
    self.frame:HookScript("OnUpdate", function() self:UpdateDisplay() end)

    return self
end

function PurchaseFrame:UpdateDisplay()
    if not ns.currentItemId:getValue() then
        self.itemInfo:SetText("No Item Selected")
        return
    end

    local itemLink = ns.currentItemId:getValue() -- assuming this is already an itemLink
    local quantity = ns.tqb:getValue()
    local maxPrice = ns.safe_price:getValue()
    self.itemInfo:SetText(itemLink)
    self.quantityText:SetText(string.format("Quantity: %d", quantity))
    self.priceText:SetText(string.format("Max Price: %dg", maxPrice and maxPrice / 10000 or 0))
end
function PurchaseFrame:OnSetupClick()
    local itemLink = ns.util.GetCurrentItemID()
    local id_set = ns.currentItemId:setValue(itemLink)
    local price_set = ns.safe_price:setValue(ns.safe_table[ns.currentItemId:getValue()])
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
    C_AuctionHouse.RefreshCommoditySearchResults(ns.currentItemId:getValue())
    C_Timer.After(1, function()
        print("killed: q", ns.ResultMonitor.TotalQuantity)
        ns.ResultMonitor:reset_state()
        self:UpdateDisplay()
    end)
    if ns.tqb == -1 then
        print("Error aggregating search results")
    end
    self.confirmButton:Enable()
end
function PurchaseFrame:OnConfirmClick()
    ns.currentItemId:getValue()
    ns.tqb:getValue()
    ns.safe_price:getValue()

    if not ns.currentItemId:getValue() or not ns.tqb:getValue() or not ns.safe_price:getValue() then
        print("Missing required purchase information")
        return
    end

    ns.InitiatePurchase(ns.currentItemId:getValue(), ns.tqb:getValue(), ns.safe_price:getValue())
end

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

-- Slash command for testing
SLASH_MAGICPURCHASE1 = "/mp"
SlashCmdList["MAGICPURCHASE"] = function(msg)
    if ns.purchaseFrame.frame:IsShown() then
        ns.HidePurchaseFrame()
    else
        ns.ShowPurchaseFrame()
    end
end

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
    
    return self
end

function PurchaseFrame:UpdateDisplay()
    if not ns.currentItemId then
        self.itemInfo:SetText("No Item Selected")
        return
    end
    
    local itemLink = ns.currentItemId -- assuming this is already an itemLink
    local quantity = ns.tqb
    local maxPrice = ns.safe_table[ns.currentItemId]
    
    self.itemInfo:SetText(itemLink)
    self.quantityText:SetText(string.format("Quantity: %d", quantity))
    self.priceText:SetText(string.format("Max Price: %dg", maxPrice and maxPrice/10000 or 0))
end

function PurchaseFrame:OnSetupClick()
    if not ns.currentItemId or not ns.tqb or not ns.safe_table[ns.currentItemId] then
        print("Missing required purchase information")
        return
    end
    C_AuctionHouse.RefreshCommoditySearchResults(ns.currentItemId)
    self:UpdateDisplay()
    self.confirmButton:Enable()
end

function PurchaseFrame:OnConfirmClick()
    local itemId = ns.currentItemId
    local quantity = ns.tqb
    local maxPrice = ns.safe_table[itemId]
    
    if not itemId or not quantity or not maxPrice then
        print("Missing required purchase information")
        return
    end
    
    ns.InitiatePurchase(itemId, quantity, maxPrice)
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
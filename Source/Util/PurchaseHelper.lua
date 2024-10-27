---@class ns
local ns = select(2, ...)

-- Create secure button for hardware event
---@class Button
local secureButton = CreateFrame("Button", "MagicSecurePurchaseButton", UIParent, "SecureActionButtonTemplate")
secureButton:RegisterForClicks("AnyDown")
secureButton:Hide()

-- Create frame for price update events
---@class Frame
local priceUpdateFrame = CreateFrame("Frame")
---@class PendingPurchase
local pendingPurchase = {
    itemID = nil,
    quantity = nil,
    maxPrice = nil,
    state = false
}

-- Register for relevant events
priceUpdateFrame:RegisterEvent("COMMODITY_PRICE_UPDATED")
priceUpdateFrame:RegisterEvent("COMMODITY_PURCHASE_SUCCEEDED")
priceUpdateFrame:RegisterEvent("COMMODITY_PURCHASE_FAILED")

---Price Handler function
---@param self any -- frame reference
---@param event any -- event name
---@param ... any -- variable arguments
local function PriceHandler(self, event, ...)
    if event == "COMMODITY_PRICE_UPDATED" then
        local unitPrice, totalPrice = ...

        if pendingPurchase.waitingForUpdate then
            if ns.debug then
                print(string.format("Price updated - Unit: %d, Total: %d, Max: %d",
                    unitPrice, totalPrice, pendingPurchase.maxPrice))
            end

            if unitPrice <= pendingPurchase.maxPrice then
                if ns.debug then print("Price acceptable, confirming purchase") end
                pendingPurchase.waitingForUpdate = false
                C_AuctionHouse.ConfirmCommoditiesPurchase(pendingPurchase.itemID, pendingPurchase.quantity)
            else
                if ns.debug then print("Price too high, cancelling purchase") end
                pendingPurchase.waitingForUpdate = false
                -- Purchase will auto-cancel if not confirmed
            end
        end
    elseif event == "COMMODITY_PURCHASE_SUCCEEDED" then
        local itemID = ...
        if ns.debug then print("Purchase succeeded for item: ") end
        -- Reset pending purchase state
        pendingPurchase.waitingForUpdate = false
        pendingPurchase.itemID = nil
        pendingPurchase.quantity = nil
        pendingPurchase.maxPrice = nil
    elseif event == "COMMODITY_PURCHASE_FAILED" then
        local itemID = ...
        if ns.debug then print("Purchase failed for item: ") end
        -- Reset pending purchase state
        pendingPurchase.waitingForUpdate = false
        pendingPurchase.itemID = nil
        pendingPurchase.quantity = nil
        pendingPurchase.maxPrice = nil
    end
end

priceUpdateFrame:SetScript("OnEvent", PriceHandler)

--- Start Purchase function to initiate a commodity purchase
---@param itemID integer
---@param quantity integer
---@param maxPrice integer
function ns.AttemptCommodityPurchase(itemID, quantity, maxPrice)
    if ns.debug then
        print(string.format("Attempting purchase for item: %d, quantity: %d, maxPrice: %d",
            itemID, quantity, maxPrice))
    end

    -- Store purchase information
    pendingPurchase.itemID = itemID
    pendingPurchase.quantity = quantity
    pendingPurchase.maxPrice = maxPrice
    pendingPurchase.waitingForUpdate = true

    -- Start the purchase process
    C_AuctionHouse.StartCommoditiesPurchase(itemID, quantity)
    -- The COMMODITY_PRICE_UPDATED event will trigger and handle the confirmation
end

--- Set up secure purchase handler
function ns.SetupSecurePurchase()
    secureButton:SetAttribute("type", "click")
    secureButton:SetScript("PreClick", function(self)
        local itemID = self:GetAttribute("itemID")
        local quantity = self:GetAttribute("quantity")
        local maxPrice = self:GetAttribute("maxPrice")

        if itemID and quantity and maxPrice then
            ns.AttemptCommodityPurchase(itemID, quantity, maxPrice)
        end
    end)
end

-- Function to initiate purchase
function ns.InitiatePurchase(itemID, quantity, maxPrice)
    secureButton:SetAttribute("itemID", itemID)
    secureButton:SetAttribute("quantity", quantity)
    secureButton:SetAttribute("maxPrice", maxPrice)
    secureButton:Click()
end

-- Initialize the system
ns.SetupSecurePurchase()

---@class ns
local ns = select(2, ...)
local priceUpdateFrame = CreateFrame("Frame")

---@class pendingPurchase
local pendingPurchase = {
    itemID = nil,
    quantity = nil,
    maxPrice = nil,
    queueState = {
        lastSentTime = 0,
        queuedAction = nil, -- "price_check" or "purchase"
        pendingOverride = false
    },
}
---@class Button
secureButton = CreateFrame("Button", "MagicSecurePurchaseButton", UIParent, "SecureActionButtonTemplate")
secureButton:RegisterForClicks("AnyDown")
secureButton:Hide()

-- Reset state after completed purchase or error
local function ResetPurchaseState()
    pendingPurchase.itemID = nil
    pendingPurchase.quantity = nil
    pendingPurchase.maxPrice = nil
    pendingPurchase.queueState.queuedAction = nil
    pendingPurchase.queueState.pendingOverride = false

    ns.currentItemId:unlock()
    ns.tqb:unlock()
    ns.safe_price:unlock()
end
-- Modified event handler to measure response times
local function PriceHandler(self, event, ...)
    -- Measure response time for events
    -- local responseTime = GetTime() - pendingPurchase.TimingManager.eventStats.lastRequestTime
    -- pendingPurchase.TimingManager:AddMeasurement("response", responseTime)
    if event == "COMMODITY_PRICE_UPDATED" then
        local unitPrice, totalPrice = ...
        -- local timing = pendingPurchase.TimingManager:GetOptimalTiming()
        -- local queueDelay = timing.queueDelay
        if unitPrice <= pendingPurchase.maxPrice then
            C_Timer.After(0.02, function()
                C_AuctionHouse.ConfirmCommoditiesPurchase(pendingPurchase.itemID, pendingPurchase.quantity)
                ns.TimingInstance:AddKeyExec("PRICE_HANDLER_CB_COMMODITY_PRICE_UPDATED", ns.TimingInstance:PreciseTime())
            end)
        else
    if event == "AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED" then
        C_Timer.After(0.5, function()
            C_AuctionHouse.StartCommoditiesPurchase(pendingPurchase.itemID, pendingPurchase.quantity)
            ns.TimingInstance:AddKeyExec("PRICE_HANDLER_CB_AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED", ns.TimingInstance:PreciseTime())
        end)
    end
        end
    elseif event == "COMMODITY_PURCHASE_SUCCEEDED" then
        ns.TimingInstance:AddKeyExec("PRICE_HANDLER_CB_COMMODITY_PURCHASE_SUCCESS", ns.TimingInstance:PreciseTime())
        ResetPurchaseState()
    elseif event == "COMMODITY_PURCHASE_FAILED" or event == "COMMODITY_PRICE_UNAVAILABLE" then
        ns.TimingInstance:AddKeyExec("PRICE_HANDLER_CB_FAILED_UNAIVAIL_NO_OP", ns.TimingInstance:PreciseTime())
        -- local timing = pendingPurchase.TimingManager:GetOptimalTiming()
        -- C_Timer.After(0.4, function()
        --     C_AuctionHouse.StartCommoditiesPurchase(pendingPurchase.itemID, pendingPurchase.quantity)
        -- end)
    end
    ns.TimingInstance:AddKeyExec("PRICE_HANDLER_GRACEFUL_EXIT", ns.TimingInstance:PreciseTime())
end

-- Export timing manager to namespace
-- Register for relevant events
priceUpdateFrame:RegisterEvent("COMMODITY_PRICE_UPDATED")
priceUpdateFrame:RegisterEvent("COMMODITY_PRICE_UNAVAILABLE")
priceUpdateFrame:RegisterEvent("COMMODITY_PURCHASE_SUCCEEDED")
priceUpdateFrame:RegisterEvent("COMMODITY_PURCHASE_FAILED")
priceUpdateFrame:SetScript("OnEvent", PriceHandler)
-- Function to initiate the purchase process
function ns.AttemptCommodityPurchase(itemID, quantity, maxPrice)
    if not itemID or not quantity or not maxPrice then
        return false
    end
    ns.TimingInstance:AddKeyExec("PRICE_UPDATE_AttemptCommodityPurchase", ns.TimingInstance:PreciseTime())

    -- Lock interface items
    ns.currentItemId:lock()
    ns.tqb:lock()
    ns.safe_price:lock()

    -- Set up purchase state
    pendingPurchase.itemID = itemID
    pendingPurchase.quantity = quantity
    pendingPurchase.maxPrice = maxPrice
    pendingPurchase.queueState.queuedAction = "initial"

    -- Start with initial price check
    C_AuctionHouse.StartCommoditiesPurchase(itemID, quantity)
    ns.TimingInstance:AddKeyExec("StartCommoditiesPurchase", ns.TimingInstance:PreciseTime())
    pendingPurchase.queueState.lastSentTime = GetTime()

    -- Queue next price check immediately
    -- C_Timer.After(0.1, function()
    --     QueueNextAction(false)
    -- end)

    return true
end

--- Set up secure purchase handler
function ns.SetupSecurePurchase()
    secureButton:SetAttribute("type", "click")
    secureButton:SetScript("PreClick", function(self)
       
        local itemID = ns.currentItemId:getValue()
        local quantity = ns.tqb:getValue()
        local maxPrice = ns.safe_price:getValue()

        if itemID and quantity and maxPrice then
            ns.AttemptCommodityPurchase(ns.currentItemId:getValue(), ns.tqb:getValue(), ns.safe_price:getValue())
        end
    end)
end
-- Function to initiate purchase
-- Entry point for purchase initiation
function ns.InitiatePurchase(itemID, quantity, maxPrice)
    -- Set attributes and trigger secure click
    secureButton:SetAttribute("itemID", itemID)
    secureButton:SetAttribute("quantity", quantity)
    secureButton:SetAttribute("maxPrice", maxPrice)
    secureButton:Click()
end
-- Initialize the system
ns.SetupSecurePurchase()
ns.pendingPurchase = pendingPurchase or {} 

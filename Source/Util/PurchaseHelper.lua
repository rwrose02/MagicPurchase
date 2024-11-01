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
priceUpdateFrame:RegisterEvent("COMMODITY_PRICE_UNAVAILABLE")
priceUpdateFrame:RegisterEvent("COMMODITY_PURCHASE_SUCCEEDED")
priceUpdateFrame:RegisterEvent("COMMODITY_PURCHASE_FAILED")

---Price Handler function
---@param self any -- frame reference
---@param event any -- event name
---@param ... any -- variable arguments
local function PriceHandler(self, event, ...)
    if event == "COMMODITY_PRICE_UPDATED" then
        local unitPrice, totalPrice = ...
        -- if ns.log_table.purchase_frame then DevTool:AddData({unitPrice, totalPrice},"mid_purchase U|T") end
        if pendingPurchase.waitingForUpdate then
            -- if ns.log_table.price_handler then
            --     DevTool:AddData(GetTime(), "WAITING COMMODITY_PRICE_UPDATED")
            -- end

            if unitPrice <= pendingPurchase.maxPrice then
                pendingPurchase.waitingForUpdate = false
                
                -- Create a ticker to check throttle state
                -- DevTool:AddData(GetTime(), "THROTTLE_CHECK")
                if pendingPurchase.QueuePrevention then 
                    local throttleCheck = C_Timer.NewTicker(0.02, function(ticker)
                        local throttle_state = C_AuctionHouse.IsThrottledMessageSystemReady()
                    
                        if not throttle_state then
                            -- Throttle is ready, proceed with purchase
                            -- if ns.log_table.price_handler then DevTool:AddData(GetTime(), "Not Throttle_State") end
                            C_AuctionHouse.ConfirmCommoditiesPurchase(pendingPurchase.itemID, pendingPurchase.quantity)
                            ticker:Cancel() -- Stop checking
                        
                            -- if ns.debug_table.throttle_check then print("Throttle ready, confirming purchase") end
                        else
                            -- if ns.debug_table.throttle_check then print("Waiting for throttle...") end
                            -- if ns.log_table.price_handler then DevTool:AddData(GetTime(), "Throttle Wait") end
                        end
                    end,20)
                
                    -- Set a maximum wait time (optional)
                    C_Timer.After(0.3, function()
                        if throttleCheck and throttleCheck.Cancel then
                            -- Handle timeout - could reset state here
                            -- if ns.log_table.throttle_check then DevTool:AddData(GetTime(), "Throttle Timeout") end
                            -- C_AuctionHouse.CancelCommoditiesPurchase()
                            throttleCheck:Cancel()
                            ns.currentItemId:unlock()
                            ns.tqb:unlock()
                            ns.safe_price:unlock()
                        end
                    end)
                else
                    C_Timer.After(0.02, function()
                        C_AuctionHouse.ConfirmCommoditiesPurchase(pendingPurchase.itemID, pendingPurchase.quantity)
                        ns.currentItemId:unlock()
                        ns.tqb:unlock()
                        ns.safe_price:unlock()
                    end)
                    

                end
            else
                pendingPurchase.waitingForUpdate = false
                C_AuctionHouse.CancelCommoditiesPurchase()
                if ns.log_table.price_handler then DevTool:AddData(GetTime(), "CANCEL FOR PRICE") end
                -- if ns.log_table.price_handler then DevTool:AddData(GetTime(), "PRICEUPDATED OVER") end
                ns.currentItemId:unlock()
                ns.tqb:unlock()
                ns.safe_price:unlock()
                return
                -- Purchase will auto-cancel if not confirmed
            end
        end
        -- if ns.log_table.price_handler then DevTool:AddData(GetTime(), "WAITING UPDATE COMMODITY_PRICE_UPDATED EVENT") end
    elseif event == "COMMODITY_PURCHASE_SUCCEEDED" then
        -- local itemID = ...
        -- if ns.log_table.price_handler then DevTool:AddData(GetTime(), "Purchase succeeded EVENT") end
        -- Reset pending purchase state
        pendingPurchase.itemID = nil
        pendingPurchase.quantity = nil
        pendingPurchase.maxPrice = nil
        ns.currentItemId:unlock()
        ns.tqb:unlock()
        ns.safe_price:unlock()
        
    elseif event == "COMMODITY_PURCHASE_FAILED" then
        -- local itemID = ...
        C_AuctionHouse.CancelCommoditiesPurchase()
        -- if ns.log_table.price_handler then DevTool:AddData(GetTime(),"Purchase failed EVENT") end
        -- Reset pending purchase state
        pendingPurchase.waitingForUpdate = false
        pendingPurchase.itemID = nil
        pendingPurchase.quantity = nil
        pendingPurchase.maxPrice = nil
        ns.currentItemId:unlock()
        ns.tqb:unlock()
        ns.safe_price:unlock()
    elseif event == "COMMODITY_PRICE_UNAVAILABLE" then
        -- if ns.log_table.price_handler then DevTool:AddData(GetTime(),"Price unavailable EVENT") end
        C_AuctionHouse.CancelCommoditiesPurchase()
        -- Reset pending purchase state
        pendingPurchase.waitingForUpdate = false
        pendingPurchase.itemID = nil
        pendingPurchase.quantity = nil
        pendingPurchase.maxPrice = nil
        ns.currentItemId:unlock()
        ns.tqb:unlock()
        ns.safe_price:unlock()
    end
end

priceUpdateFrame:SetScript("OnEvent", PriceHandler)

--- Start Purchase function to initiate a commodity purchase
function ns.AttemptCommodityPurchase(itemID, quantity, maxPrice)
    -- if ns.debug_table.purchase_frame then
    --     print(string.format("Attempting purchase for item: %d, quantity: %d, maxPrice: %d",
    --         itemID, quantity, maxPrice))
    -- end
    -- if ns.log_table.purchase_helper then
    --     DevTool:AddData(GetTime(), "AttemptCommodityPurchase")    
    -- end

    -- Store purchase information
    pendingPurchase.itemID = itemID
    pendingPurchase.quantity = quantity
    pendingPurchase.maxPrice = maxPrice
    pendingPurchase.waitingForUpdate = true
    pendingPurchase.waitingThrottleState = false
    pendingPurchase.HardQuantityState = true
    pendingPurchase.HardQuantity = 10
    pendingPurchase.QueuePrevention = false
    ns.currentItemId:lock()
    ns.tqb:lock()
    ns.safe_price:lock()
    -- Start the purchase process
    C_AuctionHouse.StartCommoditiesPurchase(itemID, quantity)
    -- The COMMODITY_PRICE_UPDATED event will trigger and handle the confirmation
end

--- Set up secure purchase handler
function ns.SetupSecurePurchase()
    secureButton:SetAttribute("type", "click")
    secureButton:SetScript("PreClick", function(self)
        
        local itemID = ns.currentItemId:getValue()
        local quantity = ns.tqb:getValue()
        local maxPrice = ns.safe_price:getValue()
        -- DevTool:AddData(GetTime(), "SecureButtonPreClick")
        if itemID and quantity and maxPrice then
            ns.AttemptCommodityPurchase(ns.currentItemId:getValue(), ns.tqb:getValue(), ns.safe_price:getValue())
        end
    end)
end

-- Function to initiate purchase
function ns.InitiatePurchase(itemID, quantity, maxPrice)
    secureButton:SetAttribute("itemID", ns.currentItemId:getValue())
    secureButton:SetAttribute("quantity", ns.tqb:getValue())
    secureButton:SetAttribute("maxPrice", ns.safe_price:getValue())
    secureButton:Click()
end

-- Initialize the system
ns.SetupSecurePurchase()

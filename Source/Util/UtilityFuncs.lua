---@class ns
local ns = select(2, ...)

---A function to aggregate commodity search results by max price
---@param itemID any
---@param maxPrice any
---@return integer
function ns.util.AggregateCommoditySearchResultsByMaxPrice(itemID, maxPrice)
    local totalQuantity = 0
    local numresults = C_AuctionHouse.GetNumCommoditySearchResults(itemID)
    for index = 1, numresults do
        local searchResult = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, index)
        if searchResult == nil then
            if ns.debug == true then print("aggcom nil result") end
            return -1
        elseif searchResult.unitPrice > maxPrice then
            break;
        end
        totalQuantity = totalQuantity + searchResult.quantity
    end
    if ns.debug == true then print("aggcom found : " .. totalQuantity) end
    return totalQuantity
end

---Gives the current item ID from the Auction House Commodity Frame
---@return integer? -- itemID
function ns.util.GetCurrentItemID()
    if AuctionHouseFrame and AuctionHouseFrame and AuctionHouseFrame.ItemSellFrame:GetItem() then
        return AuctionHouseFrame.ItemSellFrame:GetItem()
    end
    return nil
end

---@class ns
local ns = select(2, ...)

--Function to aggregate commodity search results by max price optimized version of AuctionHouseUtil.AggregateCommoditySearchResultsByMaxPrice
function ns.util.AggregateCommoditySearchResultsByMaxPrice(itemID, maxPrice)
    local totalQuantity = 0
    local numresults = C_AuctionHouse.GetNumCommoditySearchResults(itemID)
    for index = 1, numresults do
        local searchResult = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, index)
        if searchResult == nil then
            if ns.debug == true then print("aggcom nil result") end
            return false

        elseif searchResult.unitPrice > maxPrice then
            break;
        end
        totalQuantity = totalQuantity + searchResult.quantity
    end
    if ns.debug == true then print("aggcom found : "..totalQuantity) end
    return totalQuantity
end
function ns.util.GetCurrentItemID()
    if AuctionHouseFrame and AuctionHouseFrame and AuctionHouseFrame.ItemSellFrame:GetItem() then
        return AuctionHouseFrame.ItemSellFrame:GetItem()
    end
end

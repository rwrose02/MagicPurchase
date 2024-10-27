---@class ns
local ns = select(2, ...)

---@class AHFrame
local AHFrame = {
    AuctionHouseFrame = nil
}
---Get Auction House Frame
---@return Frame?
function AHFrame:AHFrame()
    return AuctionHouseFrame
end

---Get Commodity Frame
---@return Frame?
function AHFrame:CommodityFrame()
    return AuctionHouseFrame.CommoditySellFrame
end

---Get Commodity ID
---@return integer? -- itemID
function AHFrame:CommodityID()
    if self:CommodityFrame() then
        return AuctionHouseFrame.CommodityBuyFrame:GetItem()
    end
end
function AHFrame:clickFavoriteButton()
    local ahf = AuctionHouseFrame
    local searchBar = ahf.searchBar
    if searchBar and searchBar.FavoritesSearchButton and searchBar.FavoritesSearchButton:IsVisible() then
        searchBar.FavoritesSearchButton:Click()
        return true
    end
    return false
end
ns.AHFrame = AHFrame

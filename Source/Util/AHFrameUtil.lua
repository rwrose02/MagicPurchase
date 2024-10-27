---@class ns
local ns = select(2, ...)

---@class AHFrame
local AHFrame = {
}
---Get Auction House Frame
---@return Frame?
function AHFrame:getAHFrame()
    local afh = AuctionHouseFrame
    return afh
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
    local ahf = self:getAHFrame()
    local searchBar = ahf.SearchBar or {}
    if searchBar and searchBar.FavoritesSearchButton then
        searchBar.FavoritesSearchButton:Click()
        return true
    end
    return false
end

ns.AHFrame = AHFrame

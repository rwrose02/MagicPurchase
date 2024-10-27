---@class ns
local ns = select(2, ...)

function ns.MagicFav()
    ns.AHFrame:clickFavoriteButton()
end
function ns.MagicRefresh()
    C_AuctionHouse.RefreshCommoditySearchResults(ns.currentItemId:getValue())
end
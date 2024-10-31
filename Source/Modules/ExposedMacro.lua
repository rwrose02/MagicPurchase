---@class ns
local ns = select(2, ...)

function ns.MagicFav()
    ns.AHFrame:clickFavoriteButton()
end
function ns.MagicRefresh()
    C_AuctionHouse.RefreshCommoditySearchResults(ns.currentItemId:getValue())
end
ns.last_call = GetTimePreciseSec()
function ns.MagicQuery()        
    return false
end
--global export
function MagicExport()
    ns.util.ExportAddonTable()
end
function PurchaseQueryBind()
    ns.purchaseFrame:QueryItem()
end
function PurchaseConfirmBind()
    ns.purchaseFrame.confirmButton:Click()
end
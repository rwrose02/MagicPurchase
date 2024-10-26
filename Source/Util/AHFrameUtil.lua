---@class ns
local ns = select(2, ...)
AHFrame = {
    AuctionHouseFrame = nil
}
function AHFrame:_AHFrame()
    return AuctionHouseFrame
end
function AHFrame:_CommodityFrame()
    return AuctionHouseFrame.CommoditySellFrame
end
function AHFrame:_check_frame()
    if not self.AuctionHouseFrame then
        self.AuctionHouseFrame = self:_AHFrame()
    end
end
function AHFrame:CommodityID()
    if AuctionHouseFrame.CommodityBuyFrame and AuctionHouseFrame.CommodityBuyFrame:IsShown() then
        return AuctionHouseFrame.CommodityBuyFrame:GetItem()
    end
end
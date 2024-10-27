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

---@class AHFrame
ns.AHFrame = AHFrame

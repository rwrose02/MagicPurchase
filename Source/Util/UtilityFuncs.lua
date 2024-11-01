---@class ns
local ns = select(2, ...)

---A function to aggregate commodity search results by max price
---@return integer
function ns.util.AggregateCommoditySearchResultsByMaxPrice(itemID, maxPrice)
    -- if ns.debug_table.agg == true then print("aggcom start") end
    local totalQuantity = 0
    local numresults = C_AuctionHouse.GetNumCommoditySearchResults(itemID)
    for index = 1, numresults do
        local searchResult = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, index)
        if searchResult == nil then
            if ns.debug_table.agg == true then print("aggcom nil result") end
            return -1
        end
        if searchResult.unitPrice >= maxPrice then
            break;
        end
        totalQuantity = totalQuantity + searchResult.quantity
    end
    if ns.debug_table.agg == true then print("aggcom found : " .. totalQuantity) end
    return totalQuantity
end

function ns.util.GetSafePrice(item_id)
    return ns.safe_table[item_id]
end
function ns.util.MagicPriceView()
    if ns.currentItemId:getValue() == nil then
        print("No item detected")
        return
    end
    local itemLink = ns.currentItemId:getValue()
    local cached_price = ns.safe_table[itemLink]
    if not itemLink then
        print("No item cached")
        return
    end
    if not cached_price then
        print("No price cached")
        return
    end
    print("DisplayLink: " .. itemLink, "Safe Price: " .. (cached_price / 100 / 100))
end

---@function ns.util.ValidateNumbericInput
---comment
---@param input any
---@return number | boolean
function ns.util.ValidateNumbericInput(input)
    if input == "" or input == nil then
        print(input)
        -- no input case this is valid
        return true
    end
    local int_val = tonumber(input)
    if not int_val then
        -- input is given but not a number
        print("Input is not a number")
        return false
    else
        return int_val
    end 
end

function ns.util.ExportAddonTable()
    local ns = ns
    DevTool:AddData(ns, "ns")
end
---comment
---@param itemID any
---@param callback any
function ns.util.GetReagentItemInfo(itemID, callback)
    if itemID == nil or itemID <= 0 then
        return
    end
    local item = Item:CreateFromItemID(itemID)
    
    item:ContinueOnItemLoad(function()
        local itemName = item:GetItemName()
        local quality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(itemID)
        local qualityIcon = quality and C_Texture.GetCraftingReagentQualityChatIcon(quality) or ""
        
        if callback then
            callback({
                name = itemName,
                quality = quality,
                qualityIcon = qualityIcon,
                fullName = string.format("%s %s", itemName, qualityIcon)
            })
        end
    end)
end

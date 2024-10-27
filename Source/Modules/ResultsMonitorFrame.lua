---@class ns
local ns = select(2, ...)
function ns.CreateResultsMonitor()
    local frame,events = CreateFrame("Frame"), {};
    frame.TotalQuantity = 0
    frame.IgnoreEvents = false
    function frame:ListenForEvents()
        if self.IgnoreEvents == false then
            if ns.debug_table.results_frame == true then print("ResultMonitor already Listening") end
            return
        else
            self.IgnoreEvents = false
            if ns.debug_table.results_frame == true then print("ResultMonitor Listening") end
        end
    end
    function frame:reset_state()
        if self.IgnoreEvents == false then
            if ns.debug_table.results_frame == true then print("ResultKill already Reset") end
            return
        else
            self.IgnoreEvents = true
            if ns.debug_table.results_frame == true then print("ResultMonitor State Reset") end
        end
    end
    function events:COMMODITY_SEARCH_RESULTS_RECEIVED()
        if ns.debug_table.results_frame == true then print("pm: COMMODITY_SEARCH_RESULTS_RECIEVED " .. GetTime()) end
        local totalQuantity = ns.util.AggregateCommoditySearchResultsByMaxPrice(ns.currentItemId:getValue(),ns.safe_price:getValue())
        local set_tqb = ns.tqb:setValue(totalQuantity)
        -- print("Total Quantity: " .. totalQuantity)
        if not set_tqb then
            if ns.debug_table.results_frame == true then print("setting ns.tqb failed") end
        else
            if ns.debug_table.results_frame == true then print("setting ns.tqb: " .. ns.tqb:getValue()) end
        end
    end

    frame:SetScript("OnEvent", function(self, event, ...)
        if frame.IgnoreEvents == true then
            if ns.debug_table.results_frame == true then print("ResultEventKill " .. GetTime()) end
            return
        end
        events[event](self, ...); -- call one of the functions above
    end);

    for k, v in pairs(events) do
        frame:RegisterEvent(k); -- Register all events for which handlers have been defined
    end
    return frame
end
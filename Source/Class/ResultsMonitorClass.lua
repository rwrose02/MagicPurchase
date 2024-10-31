---@class ns
local ns = select(2, ...)

-- Define the ResultsMonitor "class"
local ResultsMonitor = {}
ResultsMonitor.__index = ResultsMonitor

-- Constructor function
function ResultsMonitor.new()
    local self = setmetatable({}, ResultsMonitor)

    -- Create a frame for the instance and assign properties
    self.frame = CreateFrame("Frame")
    self.events = {}
    self.TotalQuantity = 0
    self.IgnoreEvents = false

    -- Set up the event handler
    self.frame:SetScript("OnEvent", function(_, event, ...)
        if not self.IgnoreEvents and self.events[event] then
            self.events[event](self, ...) -- Call the event handler method
        end
    end)

    return self
end

-- Method to start listening for events
function ResultsMonitor:ListenForEvents()
    if not self.IgnoreEvents then
        return
    else
        self.IgnoreEvents = false
    end
end

-- Method to reset state and stop listening to events
function ResultsMonitor:IgnoreEvents()
    if self.IgnoreEvents then
        return
    else
        self.IgnoreEvents = true
    end
end
function ResultsMonitor:GetIgnoreState()
    local state = self.IgnoreEvents
    return state
end

-- Event handler for commodity search results
function ResultsMonitor:COMMODITY_SEARCH_RESULTS_RECEIVED(...)
    local totalQuantity = ns.util.AggregateCommoditySearchResultsByMaxPrice(ns.currentItemId:getValue(), ns.safe_price:getValue())
    local set_tqb = ns.tqb:setValue(totalQuantity)
    if not set_tqb and ns.log_table.results_frame then
        DevTool:AddData(ns.tqb, "MONITOR FAILED TO UPDATE")
    elseif ns.log_table.results_frame then
        DevTool:AddData(ns.tqb, "MONITOR SUCCESSFULLY SET")
    end
end

-- Initialization function to register and set up events
function ResultsMonitor:initializeEvents()
    -- Register the event with the frame
    self.frame:RegisterEvent("COMMODITY_SEARCH_RESULTS_RECEIVED")
    
    -- Add the event handler to the events table
    self.events["COMMODITY_SEARCH_RESULTS_RECEIVED"] = self.COMMODITY_SEARCH_RESULTS_RECEIVED
end

-- Create and return an instance
function ns.CreateResultsMonitor()
    local monitor = ResultsMonitor.new()
    monitor:initializeEvents()
    return monitor
end

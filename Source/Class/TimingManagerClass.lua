---@class ns
local ns = select(2, ...)

-- Timing management system
local TimingManager = {}
TimingManager.__index = TimingManager
function TimingManager.new()
    local self = setmetatable({}, TimingManager)

    -- Rolling window of timing measurements
    self.measurements = {
        responseDelays = {},  -- Time between request and response
        queueDelays = {},    -- Time between queue entry and execution
        maxSamples = 20      -- Keep last 20 measurements for rolling average
    }
    self.keyEvents = {}
    self.bEvents = {}
    -- Current timing estimates
    self.estimates = {
        expectedResponse = 0.1,    -- Default 100ms response time
        expectedQueueTime = 0.05,  -- Default 50ms queue time
        confidenceLevel = 0        -- 0-1 scale of timing confidence
    }
    -- Event tracking for measurement
    self.eventStats = {
        lastRequestTime = 0,
        lastQueueEntryTime = 0,
        pendingEventType = nil     -- "price_check" or "purchase"
    }
    self.eventLog = {}
    return self
end
function TimingManager:InitializeEvents()
    self:RegisterEvents(
        "PLAYER_ENTERING_WORLD",
        "AUCTION_HOUSE_THROTTLED_MESSAGE_SENT",
        "AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED",
        "AUCTION_HOUSE_THROTTLED_MESSAGE_QUEUED",
        "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED",
        "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
        "AUCTION_HOUSE_SHOW",
        "AUCTION_HOUSE_CLOSED"
    )
end
-- Add new timing measurement and update estimates
function TimingManager:AddMeasurement(measurementType, delay)
    local measurements = self.measurements[measurementType .. "Delays"]
    -- Add new measurement
    table.insert(measurements, delay)
    -- Keep only last maxSamples measurements
    if #measurements > self.measurements.maxSamples then
        table.remove(measurements, 1)
    end
    -- Update estimates
    self:UpdateEstimates()
end
function TimingManager:AddKeyExec(key, value)
        -- Initialize the event name table if it doesn't exist
        if not self.keyEvents[key] then
            self.keyEvents[key] = {}
        end
        -- Get the current number of entries to use as the next index
        local nextIndex = #self.keyEvents[key] + 1
        -- Insert the new entry with the next index and timestamp
        self.keyEvents[key][nextIndex] = { timestamp = value }
    end
-- Calculate new estimates based on measurements
function TimingManager:UpdateEstimates()
    local function calculateWeightedAverage(measurements)
        if #measurements == 0 then return nil end
        local total, weight, totalWeight = 0, 1, 0
        -- Give more weight to recent measurements
        for i = 1, #measurements do
            total = total + (measurements[i] * weight)
            totalWeight = totalWeight + weight
            weight = weight * 1.2  -- 20% more weight to newer samples
        end
        return total / totalWeight
    end

    -- Update response time estimate
    local responseAvg = calculateWeightedAverage(self.measurements.responseDelays)
    if responseAvg then
        self.estimates.expectedResponse = responseAvg
    end
    -- Update queue time estimate
    local queueAvg = calculateWeightedAverage(self.measurements.queueDelays)
    if queueAvg then
        self.estimates.expectedQueueTime = queueAvg
    end
    -- Update confidence level based on sample size
    local sampleSize = #self.measurements.responseDelays
    self.estimates.confidenceLevel = math.min(sampleSize / self.measurements.maxSamples, 1)
end

-- Calculate optimal timing for next action
function TimingManager:GetOptimalTiming()
    local latency = select(4, GetNetStats()) / 1000  -- Convert to seconds
    local baseQueueDelay = self.estimates.expectedQueueTime
    local baseResponseDelay = self.estimates.expectedResponse
    -- Adjust based on current server latency
    local latencyFactor = latency / (baseResponseDelay * 2)  -- Compare to expected round trip
    local adjustedQueueDelay = baseQueueDelay * latencyFactor
    -- Never go below minimum safe values
    local minQueueDelay = 0.01
    local minResponseWait = 0.05
    return {
        queueDelay = math.max(adjustedQueueDelay, minQueueDelay),
        responseWait = math.max(baseResponseDelay * latencyFactor, minResponseWait)
    }
end
function TimingManager:EventLog(event, value)
    -- Initialize the event name table if it doesn't exist
    if not self.bEvents[event] then
        self.bEvents[event] = {}
    end
    -- Get the current number of entries to use as the next index
    local nextIndex = #self.bEvents[event] + 1
    -- Insert the new entry with the next index and timestamp
    self.bEvents[event][nextIndex] = { timestamp = value }
end
function TimingManager:PLAYER_ENTERING_WORLD(...)
    self:EventLog("PLAYER_ENTERING_WORLD", self:PreciseTime())
end
function TimingManager:AUCTION_HOUSE_THROTTLED_SYSTEM_READY(...)
    self:EventLog("TM_AUCTION_HOUSE_THROTTLED_SYSTEM_READY", self:PreciseTime())
end
function TimingManager:AUCTION_HOUSE_THROTTLED_MESSAGE_SENT(...)
    self:EventLog("TM_AUCTION_HOUSE_THROTTLED_MESSAGE_SENT", self:PreciseTime())
    -- local responseTime = self:PreciseTime() - self.eventStats.lastRequestTime
    -- self:AddMeasurement("response", responseTime)
end
function TimingManager:AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED(...)
    self:EventLog("TM_AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED", self:PreciseTime())
    -- local responseTime = self:PreciseTime() - self.eventStats.lastRequestTime
    -- self:AddMeasurement("response", responseTime)
end

function TimingManager:AUCTION_HOUSE_THROTTLED_MESSAGE_QUEUED(...)
    self:EventLog("AUCTION_HOUSE_THROTTLED_MESSAGE_QUEUED", self:PreciseTime())
    -- self.eventStats.lastQueueEntryTime = self:PreciseTime()
end
function TimingManager:AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED(...)
    self:EventLog("AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED", self:PreciseTime())
    -- local queueTime = self:PreciseTime() - self.eventStats.lastQueueEntryTime
    -- self:AddMeasurement("queue", queueTime)
end
function TimingManager:AUCTION_HOUSE_SHOW(...)
    self:EventLog("AUCTION_HOUSE_SHOW", self:PreciseTime())
end
function TimingManager:AUCTION_HOUSE_CLOSED(...)
    self:EventLog("AUCTION_HOUSE_CLOSED", self:PreciseTime())
end
function TimingManager:PreciseTime()
    return GetTimePreciseSec()
end
function TimingManager:DumpCSV(keyEventsTable)
    local csvString = ""
    for eventName, entries in pairs(keyEventsTable) do
        for _, entry in ipairs(entries) do
            csvString = csvString .. eventName .. ";" .. entry.timestamp .. "\n"
        end
    end
    return csvString
end
function TimingManager:showCSV(table)
    local csvString = self:DumpCSV(table)
    ns.TextExporter.new(csvString)
end

TimingManger = ns.EventSystem.EnableEvents(TimingManager)
ns.TimingInstance = TimingManager.new()
ns.TimingInstance:InitializeEvents()
ns.TimingInstance:AddKeyExec("TM_FRAME_CREATED", ns.TimingInstance:PreciseTime())


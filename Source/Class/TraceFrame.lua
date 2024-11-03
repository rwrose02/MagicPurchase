---@class ns
local ns = select(2, ...)
---@class FrameFactory
local FrameFactory = ns.FrameFactory

local TraceFrame = {}
TraceFrame.__index = TraceFrame
function TraceFrame.new()
    local self = setmetatable({}, TraceFrame)
    local Y_SPACING = -7
    
    -- Create the main frame
    self.frame = FrameFactory:CreateMainFrame("TraceFrame", 200,300)
    
    local labels = {
        {key = "title", text = "TraceFrame", template = "GameFontNormalLarge"},
    }
    local previousLabel
    for _, config in ipairs(labels) do
        local label = FrameFactory:CreateLabel(self.frame, config.text, config.template)
        if config.key == "title" then
            label:SetPoint("TOP", self.frame, "TOP", 0, -10)
        else
            label:SetPoint("TOP", previousLabel, "BOTTOM", 0, Y_SPACING)
        end
        self[config.key .. "Text"] = label
        previousLabel = label
    end
    local field = FrameFactory:CreateField(self.frame, "Drop Counter: ", "0")
    self.counterText = field[1]
    self.counterVal = field[2]
    self.counterText:SetPoint("CENTER", self.frame, "TOP", 0, 5*Y_SPACING)
    
    local field = FrameFactory:CreateField(self.frame, "QPM: ", "0")
    self.qpmText = field[1]
    self.qpmVal = field[2]
    self.qpmText:SetPoint("TOPLEFT", self.counterText, "BOTTOMLEFT", 0, Y_SPACING)
    
    local field = FrameFactory:CreateField(self.frame, "Last Event: ", "None")
    self.lastEventText = field[1]
    self.lastEventVal = field[2]
    self.lastEventText:SetPoint("LEFT", self.frame, "LEFT", 7, 75)
    
    local field = FrameFactory:CreateField(self.frame, "Last Drop: ", "None")
    self.lastDropText = field[1]
    self.lastDropVal = field[2]
    self.lastDropText:SetPoint("TOPLEFT", self.lastEventText, "BOTTOMLEFT", 0, Y_SPACING)
    
    local field = FrameFactory:CreateField(self.frame, "RTT: ", "0")
    self.rttText = field[1]
    self.rttVal = field[2]
    self.rttText:SetPoint("TOPLEFT", self.lastDropText, "BOTTOMLEFT", 0, Y_SPACING)
    self.rttVal:SetText(0)
    self.rttLastReady = GetTime()
    self.rttReadyTime = GetTime()
    self.dropTimeLast = nil
    self.cumRtt = 0

    local field = FrameFactory:CreateField(self.frame, "AVG RTT: ", "0")
    self.avgRttText = field[1]
    self.avgRttVal = field[2]
    self.avgRttText:SetPoint("TOPLEFT", self.rttText, "BOTTOMLEFT", 0, Y_SPACING)
    self.totalResponseTime = nil -- short interval between sending and receiving a message
    self.averageTotalResponseTimeVal = nil -- long run sum of all response times / number of responses
    self.sentToReceivedCount = -2 -- number of messages sent
    self.cumulativeTotalResponseTime = 0 -- sum of all response times
    
    local field = FrameFactory:CreateField(self.frame, "TotRespTime: ", "0")
    self.totalResponseTimeText = field[1]
    self.totalResponseTimeVal = field[2]
    self.totalResponseTimeText:SetPoint("TOPLEFT", self.avgRttText, "BOTTOMLEFT", 0, Y_SPACING)
    
    local field = FrameFactory:CreateField(self.frame, "AVG TotalRespTime: ", "0")
    self.avgTotalResponseTimeText = field[1]
    self.avgTotalResponseTimeVal = field[2]
    self.avgTotalResponseTimeText:SetPoint("TOPLEFT", self.totalResponseTimeText, "BOTTOMLEFT", 0, Y_SPACING)
    
    local field = FrameFactory:CreateField(self.frame, "Throt2R: ", "0")
    self.throttleToReadyText = field[1]
    self.throttleToReadyVal = field[2]
    self.throttleToReadyText:SetPoint("TOPLEFT", self.avgTotalResponseTimeText, "BOTTOMLEFT", 0, Y_SPACING)
    self.cumThrottleToReadyVal = 0
    self.throttleReadyCount = -1
    
    local field = FrameFactory:CreateField(self.frame, "AVG Throt2R: ", "0")
    self.avgThrottleToReadyText = field[1]
    self.avgThrottleToReadyVal = field[2]
    self.avgThrottleToReadyText:SetPoint("TOPLEFT", self.throttleToReadyText, "BOTTOMLEFT", 0, Y_SPACING)
    local field = FrameFactory:CreateField(self.frame, "R2Throt: ", "0")
    self.r2throtText = field[1]
    self.r2throtVal = field[2]
    self.r2throtText:SetPoint("TOPLEFT", self.avgThrottleToReadyText, "BOTTOMLEFT", 0, Y_SPACING)
    self.cumR2throt = 0 -- total time from ready to throttle sent
    self.r2throtCount = -2
    local field = FrameFactory:CreateField(self.frame, "AVG R2Throt: ", "0")
    self.avgR2throtText = field[1]
    self.avgR2throtVal = field[2]
    self.avgR2throtText:SetPoint("TOPLEFT", self.r2throtText, "BOTTOMLEFT", 0, Y_SPACING)
    local field = FrameFactory:CreateField(self.frame, "R2TSplit Ratio: ", "0")
    self.r2tsplitRatioText = field[1]
    self.r2tsplitRatioVal = field[2]
    self.r2tsplitRatioText:SetPoint("TOPLEFT", self.avgR2throtText, "BOTTOMLEFT", 0, Y_SPACING)
    local field = FrameFactory:CreateField(self.frame, "Throt Waste Ratio: ", "0")
    self.throtWasteRatioText = field[1]
    self.throtWasteRatioVal = field[2]
    self.throtWasteRatioText:SetPoint("TOPLEFT", self.r2tsplitRatioText, "BOTTOMLEFT", 0, Y_SPACING)
    self.UpdatingFrames = nil
    local field = FrameFactory:CreateField(self.frame, "Sent2Sent: ", "0")
    self.sent2sentText = field[1]
    self.sent2sentVal = field[2]
    self.sent2sentText:SetPoint("TOPLEFT", self.throtWasteRatioText, "BOTTOMLEFT", 0, Y_SPACING)
    self.cums2sTime = 0 -- cumulative total time between sending messages
    self.lastsent = 0
    self.throttle_sent = 0
    self.s2sTime = 0 -- single interval between sending messages
    local field = FrameFactory:CreateField(self.frame, "AVG S2S: ", "0")
    self.avgS2sText = field[1]
    self.avgS2sVal = field[2]
    self.avgS2sText:SetPoint("TOPLEFT", self.sent2sentText, "BOTTOMLEFT", 0, Y_SPACING)

    return self
end
function TraceFrame:InitializeEvents()
    self:RegisterEvents(
        "PLAYER_ENTERING_WORLD",
        "AUCTION_HOUSE_PURCHASE_COMPLETED",
        "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED",
        "AUCTION_HOUSE_THROTTLED_MESSAGE_QUEUED",
        "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
        "AUCTION_HOUSE_THROTTLED_MESSAGE_SENT",
        "AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED"
    )
end
function TraceFrame:PLAYER_ENTERING_WORLD(...)
    print("Player entered world")
    print("it Works!")
end
function TraceFrame:AUCTION_HOUSE_THROTTLED_MESSAGE_SENT(...)
    self.lastsent = self.throttle_sent
    self.throttle_sent = GetTime()

    self.cums2sTime = self.s2sTime + (GetTime() - self.lastsent)
    -- self.waitingForAnswer = true
    self.r2throtVal:SetText(self.throttle_sent - self.rttReadyTime)
    -- if self.throttle_sent - self.rttReadyTime < 1 then
    self.r2throtCount = self.r2throtCount + 1
    self.cumR2throt = self.cumR2throt + (self.throttle_sent - self.rttReadyTime)
    self.avgR2throtVal:SetText(self.cumR2throt / self.throttleReadyCount)
    -- end
end
function TraceFrame:AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED(...)
    -- if self.waitingForAnswer then
        self.throttle_received = GetTime()
        self.waitingForAnswer = false
        self.totalResponseTime = self.throttle_received - self.throttle_sent
        self.totalResponseTimeVal:SetText(self.totalResponseTime)
        self.cumulativeTotalResponseTime = self.cumulativeTotalResponseTime + self.totalResponseTime
        self.sentToReceivedCount = self.sentToReceivedCount + 1
        self.avgTotalResponseTime = self.cumulativeTotalResponseTime / self.sentToReceivedCount
        self.avgTotalResponseTimeVal:SetText(self.avgTotalResponseTime)
    -- else
        -- print("WARN: Received without sending")
    -- end
end

function TraceFrame:AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED(...)
    self.lastDropVal:SetText("DROPPED: " .. GetTime())
    local val = self.counterVal:GetText() 
    self.counterVal:SetText(val + 1)
    self.dropTimeLast = GetTime()
end
function TraceFrame:AUCTION_HOUSE_THROTTLED_MESSAGE_QUEUED(...)
    return
    self.lastEventVal:SetText("QUEUED: " .. GetTime())
end
function TraceFrame:AUCTION_HOUSE_THROTTLED_SYSTEM_READY(...)
    self.throttleReadyCount = self.throttleReadyCount + 1
    self.rttLastReady = self.rttReadyTime
    self.rttReadyTime = GetTime()
    self.rttVal:SetText(self.rttReadyTime - self.rttLastReady)
    self.cumRtt = self.cumRtt + (self.rttReadyTime - self.rttLastReady)
    self.avgRttVal:SetText(self.cumRtt / self.throttleReadyCount)
    self.throttleToReadyVal:SetText(GetTime() - self.throttle_sent)
    self.cumThrottleToReadyVal = self.cumThrottleToReadyVal + (GetTime() - self.throttle_sent)
    self.avgThrottleToReadyVal:SetText(self.cumThrottleToReadyVal / self.throttleReadyCount)
    if self.UpdatingFrames == nil then -- trigger updating frames because we have all the data
        self:UpdateFunc()
        self.UpdatingFrames = true
    end
end

function TraceFrame:AUCTION_HOUSE_PURCHASE_COMPLETED(...)
    local qpm = self.qpmVal:GetText()
    local qpm = qpm + 1
    self.qpmVal:SetText(qpm)
end
function TraceFrame:UpdateFunc()
    self.frame:HookScript("OnUpdate", function()
        self.throtWasteRatioVal:SetText((self.cumThrottleToReadyVal + self.cumR2throt)/self.cumRtt)
        self.r2tsplitRatioVal:SetText(self.cumR2throt/self.cumThrottleToReadyVal)
        if self.r2throtCount > 1 then
            self.avgS2sVal:SetText(self.cums2sTime / self.r2throtCount)
        end
        
    end)
end

if ns.Trace == true then
    TraceFrame = ns.EventSystem.EnableEvents(TraceFrame)

    ns.TraceInstance = TraceFrame.new()
end

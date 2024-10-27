---@class ns
local ns = select(2, ...)

local core_frame, events = CreateFrame("Frame"), {};
function events:ADDON_LOADED(addon)
    if addon == "MagicPurchase" then
        ns.SafeFrame = ns.CreateSafeFrame()
    end
end
function events:PLAYER_ENTERING_WORLD(...)
    if ns.debug == true then DevTool:AddData(ns, "ns") end
    
end
function events:PLAYER_LEAVING_WORLD(...)
  -- handle PLAYER_LEAVING_WORLD here
end
core_frame:SetScript("OnEvent", function(self, event, ...)
  events[event](self, ...); -- call one of the functions above
end);
for k, v in pairs(events) do
  core_frame:RegisterEvent(k); -- Register all events for which handlers have been defined
end
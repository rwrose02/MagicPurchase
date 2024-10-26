---@class ns
local ns = select(2, ...)
ns.core_frame = CreateFrame("Frame")
ns.core_frame:RegisterEvent("ADDON_LOADED")
if ns.debug == true then DevTool:AddData(ns, "ns") end

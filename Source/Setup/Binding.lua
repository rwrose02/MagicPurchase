-- bindings.lua
---@class ns
local ns = select(2, ...)

-- Create a hidden frame to hold our bindings
local bindingFrame = CreateFrame("Frame", "MagicBindingFrame", UIParent)
bindingFrame:Hide()

-- Create the buyout button
local MagicFavButton = CreateFrame("Button", "MagicFavButton", bindingFrame, "SecureActionButtonTemplate")
MagicFavButton:RegisterForClicks("LeftButtonDown")
MagicFavButton:SetScript("OnClick", function()
    ns.MagicFav()
end)

-- Create the refresh button
local MagicRefreshButton = CreateFrame("Button", "MagicRefreshButton", bindingFrame, "SecureActionButtonTemplate")
MagicRefreshButton:RegisterForClicks("LeftButtonDown")
MagicRefreshButton:SetScript("OnClick", function()
    ns.MagicRefresh()
end)
_G["BINDING_NAME_CLICK MagicBuyoutButton:LeftButton"]="Magic Buyout";
_G["BINDING_NAME_CLICK MagicRefreshButton:LeftButton"]="Magic Refresh";
_G["BINDING_NAME_CLICK MagicFavButton:LeftButton"]="Magic Favorites";
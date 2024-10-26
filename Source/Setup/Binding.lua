-- bindings.lua
---@class ns
local ns = select(2, ...)

-- -- Create a hidden frame to hold our bindings
-- local bindingFrame = CreateFrame("Frame", "MagicBindingFrame", UIParent)
-- bindingFrame:Hide()


--[[
-- EXAMPLE BINDING BUTTON
local MagicBuyoutButton = CreateFrame("Button", "MagicBuyoutButton", bindingFrame, "SecureActionButtonTemplate")
MagicBuyoutButton:RegisterForClicks("LeftButtonDown")
MagicBuyoutButton:SetScript("OnClick", function()
    ns.MagicButton()
end)
]]


-- -- Register the binding names and header
-- _G["BINDING_NAME_CLICK MagicBuyoutButton:LeftButton"]="Magic Buyout";
-- _G["BINDING_NAME_CLICK MagicRefreshButton:LeftButton"]="Magic Refresh";
-- _G["BINDING_NAME_CLICK MagicFavButton:LeftButton"]="Magic Favorites";
-- _G["BINDING_NAME_CLICK MagicPriceButton:LeftButton"]="Magic Price View";
-- _G["BINDING_NAME_CLICK MagicOkayButton:LeftButton"]="Magic Okay";
-- _G["BINDING_NAME_CLICK MagicOverrideBuy:LeftButton"]="Magic Override Buy";

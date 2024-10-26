---@class ns
local ns = select(2, ...)
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", function(self, event)
    if event == "ADDON_LOADED" then
        -- Our saved variables, if they exist, have been loaded at this point.
        if Magic_SavedVars == nil then
            -- This is the first time this addon is loaded; set SVs to default values
            Magic_SavedVars = {}
        else
            ns.safe_table = Magic_SavedVars
        end
        if Magic_LatencyLog == nil then
            -- This is the first time this addon is loaded; set SVs to default values
            Magic_LatencyLog = {}
        end
    elseif event == "PLAYER_LOGOUT" then
            -- Save the time at which the character logs out
            Magic_SavedVars = ns.safe_table
    end
end)

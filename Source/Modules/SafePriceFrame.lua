---@class ns
local ns = select(2, ...)
function ns.CreateSafeFrame()
    local SafeFrame = CreateFrame("Frame", "SafePriceFrame", UIParent, "BackdropTemplate")
    SafeFrame:SetSize(200, 150)
    SafeFrame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
    SafeFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    -- local SafeFrame = CreateFrame("Frame", "SafePriceFrame", UIParent, "BasicFrameTemplateWithInset")
    -- SafeFrame.EditAHShown = false
    -- SafeFrame:SetSize(200, 200)  -- Set width and height
    -- SafeFrame:SetPoint("CENTER", UIParent, "CENTER")  -- Position at the center of the screen
    SafeFrame:SetMovable(true)
    SafeFrame:EnableMouse(true)
    SafeFrame:SetBackdropColor(0, 0, 0, 0.8)
    SafeFrame:RegisterForDrag("LeftButton")
    SafeFrame:SetScript("OnDragStart", SafeFrame.StartMoving)
    SafeFrame:SetScript("OnDragStop", SafeFrame.StopMovingOrSizing)

    -- Create a label for the text box
    local label = SafeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOP", SafeFrame,"TOP" , 0, -5)
    label:SetText("Safe Price Frame")
    -- Create the editable text box
    local set_price_label = SafeFrame:CreateFontString("setPriceLabel", "OVERLAY", "GameFontHighlight")
    set_price_label:SetPoint("TOPLEFT", SafeFrame, "TOPLEFT", 9, -32)
    set_price_label:SetText("Set Price:")
    local editBox = CreateFrame("EditBox", nil, SafeFrame, "InputBoxTemplate")
    editBox:SetSize(115, 15)  -- Set width and height
    editBox:SetPoint("LEFT", set_price_label, "RIGHT", 10, 0)
    editBox:SetAutoFocus(false)  -- Don't automatically focus the text box when shown


    -- Function to update the safe_price variable
    editBox:SetScript("OnEnterPressed", function(self)
        local input = self:GetText()
        if ns.currentItemId:getValue() == -1 then
            if input == "" or input == nil then
                -- no input case and no item selected
                print("No input detected")
            elseif tonumber(input) == nil then
               -- check if input is a number 
                print("Invalid input detected")
            else
                ns.def_safe_price = tonumber(input)*100*100 or ns.def_safe_price
                print("Default Safe Price: "..ns.def_safe_price)
            end
        else
            if input == "" or input == nil then
                -- no input case
                print("No input detected")
            elseif tonumber(input) == nil then
                -- check if input is a number 
                print("Invalid input detected")
            else
                local currentItemId = ns.currentItemId:getValue()
                ns.safe_table[currentItemId] = tonumber(input)*100*100 or ns.def_safe_price
                local succeeded = ns.safe_price:setValue(ns.safe_table[currentItemId])
                if not succeeded then
                    print("Failed to set safe price")
                else
                    print("Safe Price Set for Item: " .. ns.currentItemId:getValue() .. " to: " .. ns.safe_price:getValue())
                end
            end
        end
        self:SetText("")  -- Clear the text box
        self:ClearFocus()  -- Remove focus from the edit box
    end)

    -- Create a button to confirm and close the frame (optional)
    local closeButton = CreateFrame("Button", nil, SafeFrame, "GameMenuButtonTemplate")
    closeButton:SetPoint("BOTTOM", SafeFrame, "BOTTOM", 0, 10)
    closeButton:SetSize(100, 20)
    closeButton:SetText("Close")
    closeButton:SetNormalFontObject("GameFontNormal")
    closeButton:SetHighlightFontObject("GameFontHighlight")

    closeButton:SetScript("OnClick", function()
        SafeFrame:Hide()  -- Hide the frame when the button is clicked
    end)
    local showprice = CreateFrame("Button", nil, SafeFrame, "GameMenuButtonTemplate")
    showprice:SetPoint("BOTTOMRIGHT", SafeFrame, "RIGHT", 0, 10)
    showprice:SetSize(100, 20)
    showprice:SetText("Show Price")
    showprice:SetNormalFontObject("GameFontNormal")
    showprice:SetHighlightFontObject("GameFontHighlight")
    showprice:SetScript("OnClick", function()
        ns.util.MagicPriceView()
    end)
    return SafeFrame
end

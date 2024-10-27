---@class ns
local ns = select(2, ...)
function ns.CreateSafeFrame()
    local SafeFrame = CreateFrame("Frame", "SafePriceFrame", UIParent, "BasicFrameTemplateWithInset")
    SafeFrame.EditAHShown = false
    SafeFrame:SetSize(200, 100)  -- Set width and height
    SafeFrame:SetPoint("CENTER", UIParent, "CENTER")  -- Position at the center of the screen
    SafeFrame:SetMovable(true)
    SafeFrame:EnableMouse(true)
    SafeFrame:RegisterForDrag("LeftButton")
    SafeFrame:SetScript("OnDragStart", SafeFrame.StartMoving)
    SafeFrame:SetScript("OnDragStop", SafeFrame.StopMovingOrSizing)

    -- Create a label for the text box
    local label = SafeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOP", SafeFrame,"TOP" , 0, -5)
    label:SetText("Set Safe Price:")

    -- Create the editable text box
    local editBox = CreateFrame("EditBox", nil, SafeFrame, "InputBoxTemplate")
    editBox:SetSize(140, 20)  -- Set width and height
    editBox:SetPoint("CENTER", SafeFrame, "CENTER", 0, 0)
    editBox:SetAutoFocus(false)  -- Don't automatically focus the text box when shown

    -- Function to update the safe_price variable
    editBox:SetScript("OnEnterPressed", function(self)
        local input = self:GetText()
        if not SafeFrame.EditAHShown then
            ns.def_safe_price = tonumber(input)*100*100 or ns.def_safe_price
            print("Default Safe Price: "..ns.def_safe_price)
            return
        end
        ns.safe_table[ns.currentItemId] = tonumber(input)*100*100 or ns.def_safe_price
        ns.safe_price:setValue(ns.safe_table[ns.currentItemId])
        print("Safe Price Set for Item: " .. ns.currentItemId:getValue() .. " to: " .. ns.safe_table[ns.currentItemId])
        -- DevTool:AddData(ns.safe_table, "safe_table")
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

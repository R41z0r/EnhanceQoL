local frame = CreateFrame("Frame", "RaizorQueryFrame", UIParent, "BasicFrameTemplateWithInset")
local reSearchList = {}
local resultsAHSearch = {}

frame:SetSize(400, 300)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide() -- Initially hide the frame

frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlight")
frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
frame.title:SetText("Raizor Query")

frame.editBox = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
frame.editBox:SetSize(360, 40)
frame.editBox:SetPoint("TOP", frame, "TOP", 0, -40)

frame.editEditBox = CreateFrame("EditBox", nil, frame.editBox)
frame.editEditBox:SetSize(360, 40)
frame.editEditBox:SetMultiLine(true)
frame.editEditBox:SetAutoFocus(false)
frame.editEditBox:SetFontObject("ChatFontNormal")
frame.editBox:SetScrollChild(frame.editEditBox)
frame.editEditBox:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
end)

frame.outputBox = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
frame.outputBox:SetSize(360, 150)
frame.outputBox:SetPoint("TOP", frame.editBox, "BOTTOM", 0, -20)

frame.outputEditBox = CreateFrame("EditBox", nil, frame.outputBox)
frame.outputEditBox:SetSize(360, 150)
frame.outputEditBox:SetMultiLine(true)
frame.outputEditBox:SetAutoFocus(false)
frame.outputEditBox:SetFontObject("ChatFontNormal")
frame.outputBox:SetScrollChild(frame.outputEditBox)
frame.outputEditBox:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
end)

local addedItems = {}

local function extractManaFromTooltip(itemLink)
    local tooltip = CreateFrame("GameTooltip", "RaizorQueryTooltip", UIParent, "GameTooltipTemplate")
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetHyperlink(itemLink)
    local mana = 0

    for i = 1, tooltip:NumLines() do
        local text = _G["RaizorQueryTooltipTextLeft" .. i]:GetText()
        if text and text:find("mana") then
            local manaValue = text:match("(%d[%d,%.]*) mana")
            if manaValue then
                manaValue = manaValue:gsub(",", "") -- Remove thousands separator
                mana = tonumber(manaValue)
                break
            end
        end
    end

    tooltip:Hide()
    return mana
end

local function updateItemInfo(itemLink)
    if not itemLink then
        return
    end
    local name, link, quality, level, minLevel, type, subType, stackCount, equipLoc, texture = GetItemInfo(itemLink)
    local mana = extractManaFromTooltip(itemLink)
    if name and type and subType and minLevel and mana > 0 then
        local formattedKey = name:gsub("%s+", "")
        return string.format("{ key = \"%s\", id = %d, desc = \"%s\", requiredLevel = %d, mana = %d }\n", formattedKey,
            itemLink:match("item:(%d+)"), name, minLevel, mana)
    end
    return nil
end

frame.editEditBox:SetScript("OnTextChanged", function(self)
    local itemLinks = {strsplit(" ", self:GetText())}
    local results = {}

    for _, itemLink in ipairs(itemLinks) do
        local result = updateItemInfo(itemLink)
        if result then
            table.insert(results, result)
        end
    end

    frame.outputEditBox:SetText(table.concat(results, ",\n        "))
end)

local function addToSearchResult(itemID)
    local name, link, quality, level, minLevel, type, subType = GetItemInfo(itemID)
    local mana = extractManaFromTooltip(link)
    if name and type and subType and minLevel and mana > 0 then
        local formattedKey = name:gsub("%s+", "")
        result = string.format("{ key = \"%s\", id = %d, requiredLevel = %d, mana = %d }",
            formattedKey, itemID, minLevel, mana)
        table.insert(resultsAHSearch, result)
    end
    frame.outputEditBox:SetText(table.concat(resultsAHSearch, ",\n        "))
end

local function handleItemLink(text)
    local name, link, quality, level, minLevel, type, subType, stackCount, equipLoc, texture = GetItemInfo(text)
    if type == "Consumable" and subType == "Food & Drink" then
        local itemId = text:match("item:(%d+)")
        if not addedItems[itemId] then
            addedItems[itemId] = true
            local currentText = frame.editEditBox:GetText()
            frame.editEditBox:SetText(currentText .. " " .. text)
            frame.editEditBox:GetScript("OnTextChanged")(frame.editEditBox)
        else
            print("Item is already in the list.")
        end
    else
        print("Item is not a Consumable - Food & Drink or does not restore mana.")
    end
end

local function onAddonLoaded(event, addonName)
    if addonName == "RaizorQuery" then
        SLASH_RAIZORQUERY1 = "/rq"
        SlashCmdList["RAIZORQUERY"] = function(msg)
            frame:Show()
        end
    end
end

local function onItemPush(...)
    local itemLink = GetContainerItemLink(...)
    if itemLink then
        handleItemLink(itemLink)
    end
end

local function onAuctionHouseEvent(self, event, ...)
    if event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
        browseResults = C_AuctionHouse.GetBrowseResults()
        print(#browseResults)
        for i = 1, #browseResults do
            _, link = GetItemInfo(browseResults[i].itemKey.itemID)
            if nil == link then
                reSearchList[browseResults[i].itemKey.itemID] = true
            else
                addToSearchResult(browseResults[i].itemKey.itemID)
            end
        end
    end
end

local function onGetItemInfoReceived(...)
    itemID, success = ...
    if success == true and reSearchList[itemID] == true then
        addToSearchResult(itemID)
    end
end

local function onEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        onAddonLoaded(event, ...)
    elseif event == "ITEM_PUSH" then
        onItemPush(...)
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        onGetItemInfoReceived(...)
    else
        onAuctionHouseEvent(self, event, ...)
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("ITEM_PUSH")
frame:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED")
frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
frame:SetScript("OnEvent", onEvent)

-- Handling Shift+Click to add item link to the EditBox and clear previous item
hooksecurefunc("ChatEdit_InsertLink", function(itemLink)
    if itemLink then
        handleItemLink(itemLink)
        return true
    end
end)

-- Button to copy the output to the clipboard
local copyButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
copyButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
copyButton:SetSize(100, 25)
copyButton:SetText("Copy")
copyButton:SetScript("OnClick", function()
    if frame.outputEditBox:GetText() ~= "" then
        frame.outputEditBox:HighlightText()
        frame.outputEditBox:SetFocus()
        C_Timer.After(1, function()
            frame.outputEditBox:ClearFocus()
        end)
    end
end)

-- Button to scan auction house items
local scanButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
scanButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 40)
scanButton:SetSize(100, 25)
scanButton:SetText("Scan AH")
scanButton:SetScript("OnClick", function()
    if AuctionHouseFrame and AuctionHouseFrame:IsShown() then
        -- Search for consumables in the Food & Drink category
        local query = {
            searchString = "",
            sorts = { -- {sortOrder = Enum.AuctionHouseSortOrder.Price, reverseSort = false},
            {
                sortOrder = Enum.AuctionHouseSortOrder.Name,
                reverseSort = false
            }},
            filters = {Enum.AuctionHouseFilter.Potions},
            itemClassFilters = {{
                classID = Enum.ItemClass.Consumable,
                subClassID = Enum.ItemConsumableSubclass.Fooddrink
            }}
        }
        -- Clear the reSearchList
        reSearchList = {}
        resultsAHSearch = {}
        C_AuctionHouse.SendBrowseQuery(query)
    else
        print("Auction House is not open.")
    end
end)

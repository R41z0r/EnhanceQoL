local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local frame = CreateFrame("Frame", "EnhanceQoLQueryFrame", UIParent, "BasicFrameTemplateWithInset")
local reSearchList = {}
local resultsAHSearch = {}

local executeSearch = false

addon.Query = {}

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
frame.title:SetText(addonName)

frame.editBox = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
frame.editBox:SetSize(360, 40)
frame.editBox:SetPoint("TOP", frame, "TOP", 0, -40)

frame.editEditBox = CreateFrame("EditBox", nil, frame.editBox)
frame.editEditBox:SetSize(360, 40)
frame.editEditBox:SetMultiLine(true)
frame.editEditBox:SetAutoFocus(false)
frame.editEditBox:SetFontObject("ChatFontNormal")
frame.editBox:SetScrollChild(frame.editEditBox)
frame.editEditBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

frame.outputBox = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
frame.outputBox:SetSize(360, 150)
frame.outputBox:SetPoint("TOP", frame.editBox, "BOTTOM", 0, -20)

frame.outputEditBox = CreateFrame("EditBox", nil, frame.outputBox)
frame.outputEditBox:SetSize(360, 150)
frame.outputEditBox:SetMultiLine(true)
frame.outputEditBox:SetAutoFocus(false)
frame.outputEditBox:SetFontObject("ChatFontNormal")
frame.outputBox:SetScrollChild(frame.outputEditBox)
frame.outputEditBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

local addedItems = {}

local function extractManaFromTooltip(itemLink)
    local tooltip = CreateFrame("GameTooltip", "EnhanceQoLQueryTooltip", UIParent, "GameTooltipTemplate")
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetHyperlink(itemLink)
    local mana = 0

    for i = 1, tooltip:NumLines() do
        local text = _G["EnhanceQoLQueryTooltipTextLeft" .. i]:GetText()
        if text and text:find("mana") then
            local manaValue = text:match("([%d,%.]+)%s*million%s*mana") or text:match("([%d,%.]+)%s*mana")
            if manaValue then
                if text:find("million") then
                    manaValue = manaValue:gsub(",", "") -- Remove thousands separator
                    mana = tonumber(manaValue) * 1000000 -- Convert to numeric value for millions
                else
                    manaValue = manaValue:gsub("[,%.]", "") -- Remove commas and periods
                    mana = tonumber(manaValue)
                end
                break
            end
        end
    end

    tooltip:Hide()
    return mana
end

local function extractWellFedFromTooltip(itemLink)
    local tooltip = CreateFrame("GameTooltip", "EnhanceQoLQueryTooltip", UIParent, "GameTooltipTemplate")
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetHyperlink(itemLink)
    local buffFood = "false"

    for i = 1, tooltip:NumLines() do
        local text = _G["EnhanceQoLQueryTooltipTextLeft" .. i]:GetText()
        if text and (text:match("well fed") or text:match("Well Fed")) then
            buffFood = "true"
            break
        end
    end

    tooltip:Hide()
    return buffFood
end

local function updateItemInfo(itemLink)
    if not itemLink then return end
    local name, link, quality, level, minLevel, type, subType, stackCount, equipLoc, texture = C_Item.GetItemInfo(
        itemLink)
    local mana = extractManaFromTooltip(itemLink)
    if name and type and subType and minLevel and mana > 0 then
        local buffFood = extractWellFedFromTooltip(itemLink)
        local formattedKey = name:gsub("%s+", "")
        if type == "Gem" then
            return string.format("{ key = \"%s\", id = %d, requiredLevel = %d, mana = %d, isBuffFood = " .. buffFood ..
                                     ", isEarthenFood = true, earthenOnly = true }", formattedKey,
                itemLink:match("item:(%d+)"), minLevel, mana)
        else
            return string.format("{ key = \"%s\", id = %d, requiredLevel = %d, mana = %d, isBuffFood = " .. buffFood ..
                                     " }", formattedKey, itemLink:match("item:(%d+)"), minLevel, mana)
        end
    end
    return nil
end

local loadedResults = {}

frame.editEditBox:SetScript("OnTextChanged", function(self)
    local itemLinks = {strsplit(" ", self:GetText())}
    local results = {}

    for _, itemLink in ipairs(itemLinks) do
        local itemID = itemLink:match("item:(%d+)")
        if nil ~= itemID then
            local result = nil
            if nil == loadedResults[itemID] then
                result = updateItemInfo(itemLink)
                loadedResults[itemID] = result
            else
                result = loadedResults[itemID]
            end
            if result then table.insert(results, result) end
        end
    end

    frame.outputEditBox:SetText(table.concat(results, ",\n        "))
end)

local function addToSearchResult(itemID)
    local name, link, quality, level, minLevel, type, subType = C_Item.GetItemInfo(itemID)
    local mana = extractManaFromTooltip(link)
    if name and type and subType and minLevel and mana > 0 and type == Enum.ItemClass.Consumable and subType ==
        Enum.ItemConsumableSubclass.Fooddrink then
        if not addedItems["" .. itemID] then
            local buffFood = extractWellFedFromTooltip(link)
            local formattedKey = name:gsub("%s+", "")
            result = string.format(
                "{ key = \"%s\", id = %d, requiredLevel = %d, mana = %d, isBuffFood = " .. buffFood .. " }",
                formattedKey, itemID, minLevel, mana)
            table.insert(resultsAHSearch, result)
        end
    end
    frame.outputEditBox:SetText(table.concat(resultsAHSearch, ",\n        "))
end

local function handleItemLink(text)
    local name, link, quality, level, minLevel, type, subType, stackCount, equipLoc, texture = C_Item.GetItemInfo(text)
    if (type == "Consumable" and subType == "Food & Drink") or select(2, UnitRace("player")) == "EarthenDwarf" and type ==
        "Gem" then
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

local isLoggingActive = false -- Status für Hintergrund-Logging
local performanceFrame = nil
addon.Performance = {}
addon.Performance.Data = {}
addon.Performance.Log = {} -- Enthält alle Logs

local function UpdatePerformanceFrame()
    if not performanceFrame or not performanceFrame.content then return end

    local content = performanceFrame.content
    local yOffset = 0

    -- Entferne alte Logzeilen
    for _, child in ipairs({content:GetChildren()}) do child:Hide() end

    -- Zeige neue Logzeilen
    for _, log in ipairs(addon.Performance.Log) do
        local line = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        line:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -yOffset)
        line:SetPoint("TOPRIGHT", content, "TOPRIGHT", -5, -yOffset)
        line:SetText(string.format("[%s] %s - %s: %.2f ms", log.timestamp, log.addonName, log.event, log.elapsedTime))
        yOffset = yOffset + 20
    end

    -- Passe die Höhe des Inhalts an
    content:SetHeight(yOffset)
end

local function ShowPerformanceData()
    if not performanceFrame then
        performanceFrame = CreateFrame("Frame", "PerformanceFrame", UIParent, "BasicFrameTemplateWithInset")
        performanceFrame:SetSize(600, 300)
        performanceFrame:SetPoint("CENTER")
        performanceFrame:SetMovable(true)
        performanceFrame:EnableMouse(true)
        performanceFrame:RegisterForDrag("LeftButton")
        performanceFrame:SetScript("OnDragStart", performanceFrame.StartMoving)
        performanceFrame:SetScript("OnDragStop", performanceFrame.StopMovingOrSizing)

        performanceFrame.title = performanceFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        performanceFrame.title:SetPoint("TOP", 0, -10)
        performanceFrame.title:SetText("Performance Log")

        local scrollFrame = CreateFrame("ScrollFrame", nil, performanceFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetSize(560, 220)
        scrollFrame:SetPoint("TOP", performanceFrame.title, "BOTTOM", 0, -10)

        local content = CreateFrame("Frame", nil, scrollFrame)
        content:SetSize(540, 1)
        scrollFrame:SetScrollChild(content)

        performanceFrame.content = content

        local closeButton = CreateFrame("Button", nil, performanceFrame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", performanceFrame, "TOPRIGHT")
    end

    -- Initiale Aktualisierung
    UpdatePerformanceFrame()

    performanceFrame:Show()
end

local function onAddonLoaded(event, addonName)
    if addonName == "EnhanceQoLQuery" then
        -- Registriere den Slash-Command für /rq
        SLASH_EnhanceQoLQUERY1 = "/rq"
        SlashCmdList["EnhanceQoLQUERY"] = function(msg)
            if frame and frame.Show then
                frame:Show()
            else
                print("Frame not found or not initialized.")
            end
        end

        -- Registriere den Slash-Command für /perfdump
        SLASH_PERFDATA1 = "/perfdump"
        SlashCmdList["PERFDATA"] = function(msg)
            local command = strlower(msg or "")

            if command == "start" then
                if isLoggingActive then
                    print("Performance logging is already active.")
                else
                    isLoggingActive = true
                    print("Performance logging started.")
                end
            elseif command == "stop" then
                if not isLoggingActive then
                    print("Performance logging is already stopped.")
                else
                    isLoggingActive = false
                    print("Performance logging stopped.")
                end
            elseif command == "" then
                ShowPerformanceData()
            else
                print("Invalid command. Use '/perfdump start', '/perfdump stop', or '/perfdump'.")
            end
        end

        print("EnhanceQoLQuery commands registered: /rq, /perfdump")
    end
end

local function onItemPush(bag, slot)
    if nil == bag or nil == slot then return end
    if bag < 0 or bag > 5 or slot < 1 or slot > C_Container.GetContainerNumSlots(bag) then return end
    local itemLink = GetContainerItemLink(bag, slot)
    if itemLink then handleItemLink(itemLink) end
end

local function onAuctionHouseEvent(self, event, ...)
    if executeSearch then
        if event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
            browseResults = C_AuctionHouse.GetBrowseResults()
            print(#browseResults)
            for i = 1, #browseResults do
                _, link = C_Item.GetItemInfo(browseResults[i].itemKey.itemID)
                if nil == link then
                    reSearchList[browseResults[i].itemKey.itemID] = true
                else
                    addToSearchResult(browseResults[i].itemKey.itemID)
                end
            end
        end
    end
end

local function onGetItemInfoReceived(...)
    itemID, success = ...
    if success == true and reSearchList[itemID] == true then addToSearchResult(itemID) end
end

local function onEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        onAddonLoaded(event, ...)
        for _, drink in ipairs(addon.Drinks.drinkList) do addedItems["" .. drink.id] = true end
    elseif event == "ITEM_PUSH" and frame:IsShown() then
        onItemPush(...)
    elseif event == "GET_ITEM_INFO_RECEIVED" and frame:IsShown() then
        onGetItemInfoReceived(...)
    elseif frame:IsShown() then
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
    if itemLink and frame:IsShown() then
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
        C_Timer.After(1, function() frame.outputEditBox:ClearFocus() end)
    end
end)

-- Button to scan auction house items
local scanButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
scanButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 40)
scanButton:SetSize(100, 25)
scanButton:SetText("Scan AH")
scanButton:SetScript("OnClick", function()
    executeSearch = true
    if AuctionHouseFrame and AuctionHouseFrame:IsShown() then

        -- local function SearchAuctionHouseByMultipleItemIDs(itemIDs)
        --     local itemKeys = {}

        --     for _, itemID in ipairs(itemIDs) do
        --         local itemKey = C_AuctionHouse.MakeItemKey(itemID)
        --         if itemKey then
        --             table.insert(itemKeys, itemKey)
        --         else
        --             print("Kein ItemKey für ItemID:", itemID)
        --         end
        --     end

        --     if #itemKeys > 0 then
        --         -- Sortieren nach Preis aufsteigend
        --         local sorts =
        --             {{sortOrder = 0, reverseSort = false} -- 0 ist der Index für Preis, "false" bedeutet aufsteigend
        --             }

        --         -- Suche nach allen ItemKeys gleichzeitig mit Sortierung
        --         C_AuctionHouse.SearchForItemKeys(itemKeys, sorts)
        --         print("Suche nach den ItemIDs:", table.concat(itemIDs, ", "))
        --     else
        --         print("Keine gültigen ItemKeys gefunden.")
        --     end
        -- end

        -- -- Beispielaufruf mit einer Liste von ItemIDs
        -- SearchAuctionHouseByMultipleItemIDs({221853, 221854, 221855, 221859, 221860, 221861, 221856, 221857, 221858})

        -- Search for consumables in the Food & Drink category
        local query = {searchString = "",
                       sorts = { -- {sortOrder = Enum.AuctionHouseSortOrder.Price, reverseSort = false},
        {sortOrder = Enum.AuctionHouseSortOrder.Name, reverseSort = true}}, filters = {Enum.AuctionHouseFilter.Potions},
                       itemClassFilters = {{classID = Enum.ItemClass.Consumable,
                                            subClassID = Enum.ItemConsumableSubclass.Fooddrink}}}
        -- Clear the reSearchList
        reSearchList = {}
        resultsAHSearch = {}
        C_AuctionHouse.SendBrowseQuery(query)
    else
        print("Auction House is not open.")
    end
end)

-- Performance Module

function addon.Performance.MeasurePerformance(addonName, event, func, ...)
    local startTime = debugprofilestop() -- Startzeitpunkt
    local results = {func(...)} -- Funktion ausführen
    local elapsedTime = debugprofilestop() - startTime -- Dauer berechnen

    if isLoggingActive then addon.Performance.LogEvent(addonName, event, elapsedTime) end

    return unpack(results)
end

function addon.Performance.LogEvent(addonName, event, elapsedTime)
    -- Füge neuen Eintrag hinzu
    table.insert(addon.Performance.Log,
        {addonName = addonName, event = event, elapsedTime = elapsedTime, timestamp = date("%H:%M:%S")})

    -- Aktualisiere das Frame, wenn es offen ist
    if performanceFrame and performanceFrame:IsShown() then UpdatePerformanceFrame() end
end

function addon.Performance.GetPerformanceData() return addon.Performance.Data end
function addon.Performance.GetPerformanceData() return addon.Performance.Data end

addon.Query.frame = frame
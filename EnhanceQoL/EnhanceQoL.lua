local addonName, addon = ...
local L = addon.L

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local LFGListFrame = _G.LFGListFrame

local EQOL = select(2, ...)
EQOL.C = {}

hooksecurefunc("LFGListSearchEntry_OnClick", function(s, button)
    local panel = LFGListFrame.SearchPanel
    if button ~= "RightButton" and LFGListSearchPanelUtil_CanSelectResult(s.resultID) and panel.SignUpButton:IsEnabled() then
        if panel.selectedResult ~= s.resultID then LFGListSearchPanel_SelectResult(panel, s.resultID) end
        LFGListSearchPanel_SignUp(panel)
    end
end)

LFGListApplicationDialog:HookScript("OnShow", function(self)
    if not EnhanceQoLDB.skipSignUpDialog then return end

    if self.SignUpButton:IsEnabled() and not IsShiftKeyDown() then self.SignUpButton:Click() end
end)

local didApplyPatch = false
local originalFunc = LFGListApplicationDialog_Show
local patchedFunc = function(self, resultID)
    if resultID then
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID);

        self.resultID = resultID;
        self.activityID = searchResultInfo.activityID;
    end
    LFGListApplicationDialog_UpdateRoles(self);
    StaticPopupSpecial_Show(self);
end

function EQOL.PersistSignUpNote()
    if EnhanceQoLDB.persistSignUpNote then
        -- overwrite function with patched func missing the call to ClearApplicationTextFields
        LFGListApplicationDialog_Show = patchedFunc
        didApplyPatch = true
    elseif didApplyPatch then
        -- restore previously overwritten function
        LFGListApplicationDialog_Show = originalFunc
    end
end

local doneHook = false
local inspectDone = {}
local inspectUnit = nil
local function CheckItemGems(element, itemLink, emptySocketsCount, key, pdElement, attempts)
    attempts = attempts or 1 -- Anzahl der Versuche
    if attempts > 10 then -- Abbruch nach 5 Versuchen, um Endlosschleifen zu vermeiden
        return
    end

    for i = 1, emptySocketsCount do
        local gemName, gemLink = C_Item.GetItemGem(itemLink, i)

        if gemName then
            local icon = GetItemIcon(gemLink)
            element.gems[i].icon:SetTexture(icon)
        else
            -- Wiederhole die Überprüfung nach einer Verzögerung, wenn der Edelstein noch nicht geladen ist
            C_Timer.After(0.1, function()
                CheckItemGems(element, itemLink, emptySocketsCount, key, pdElement, attempts + 1)
            end)
            return -- Abbrechen, damit wir auf die nächste Überprüfung warten
        end
    end
end

local function GetUnitFromGUID(targetGUID)
    if IsInGroup() then
        for i = 1, 4 do
            local unit = "party" .. i
            if UnitGUID(unit) == targetGUID then
                return unit -- Gibt "partyN" zurück
            end
        end
    end

    if IsInRaid() then
        for i = 1, 40 do
            local unit = "raid" .. i
            if UnitGUID(unit) == targetGUID then
                return unit -- Gibt "raidN" zurück
            end
        end
    end

    return nil
end

local itemCount = 0
local ilvlSum = 0
local function removeInspectElements()
    if nil == InspectPaperDollFrame then return end
    itemCount = 0
    ilvlSum = 0
    if InspectPaperDollFrame.ilvl then InspectPaperDollFrame.ilvl:SetText("") end
    local itemSlotsInspectList = {[1] = InspectHeadSlot, [2] = InspectNeckSlot, [3] = InspectShoulderSlot,
                                  [15] = InspectBackSlot, [5] = InspectChestSlot, [9] = InspectWristSlot,
                                  [10] = InspectHandsSlot, [6] = InspectWaistSlot, [7] = InspectLegsSlot,
                                  [8] = InspectFeetSlot, [11] = InspectFinger0Slot, [12] = InspectFinger1Slot,
                                  [13] = InspectTrinket0Slot, [14] = InspectTrinket1Slot, [16] = InspectMainHandSlot,
                                  [17] = InspectSecondaryHandSlot}
    for key, element in pairs(itemSlotsInspectList) do
        if element.ilvl then element.ilvl:SetFormattedText("") end
        if element.ilvlBackground then element.ilvlBackground:Hide() end
        if element.enchant then element.enchant:SetText("") end
        if element.borderGradient then element.borderGradient:Hide() end
        if element.gems and #element.gems > 0 then
            for i = 1, #element.gems do
                element.gems[i]:UnregisterAllEvents()
                element.gems[i]:SetScript("OnUpdate", nil)
                element.gems[i]:Hide()
            end
        end
    end
    collectgarbage("collect")
end

local function onInspect(arg1)
    if nil == InspectFrame then return end
    local unit = InspectFrame.unit
    if nil == unit then return end

    if UnitGUID(InspectFrame.unit) ~= arg1 then return end

    local pdElement = InspectPaperDollFrame
    if not doneHook then
        doneHook = true
        InspectFrame:HookScript("OnHide", function(self)
            inspectDone = {}
            removeInspectElements()
        end)
    end
    if inspectUnit ~= InspectFrame.unit then
        inspectUnit = InspectFrame.unit
        inspectDone = {}
    end
    if not addon.db["showIlvlOnCharframe"] and pdElement.ilvl then pdElement.ilvl:SetText("") end
    if not pdElement.ilvl and addon.db["showIlvlOnCharframe"] then
        pdElement.ilvlBackground = pdElement:CreateTexture(nil, "BACKGROUND")
        pdElement.ilvlBackground:SetColorTexture(0, 0, 0, 0.8) -- Schwarzer Hintergrund mit 80% Transparenz
        pdElement.ilvlBackground:SetPoint("TOPRIGHT", pdElement, "TOPRIGHT", -2, -28)
        pdElement.ilvlBackground:SetSize(20, 16) -- Größe des Hintergrunds (muss ggf. angepasst werden)

        pdElement.ilvl = pdElement:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        pdElement.ilvl:SetPoint("TOPRIGHT", pdElement.ilvlBackground, "TOPRIGHT", -1, -1) -- Position des Textes im Zentrum des Hintergrunds
        pdElement.ilvl:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE") -- Setzt die Schriftart, -größe und -stil (OUTLINE)

        pdElement.ilvl:SetFormattedText("")
        pdElement.ilvl:SetTextColor(1, 1, 1, 1)

        local textWidth = pdElement.ilvl:GetStringWidth()
        pdElement.ilvlBackground:SetSize(textWidth + 6, pdElement.ilvl:GetStringHeight() + 4) -- Mehr Padding für bessere Lesbarkeit
    end
    local itemSlotsInspectList = {[1] = InspectHeadSlot, [2] = InspectNeckSlot, [3] = InspectShoulderSlot,
                                  [15] = InspectBackSlot, [5] = InspectChestSlot, [9] = InspectWristSlot,
                                  [10] = InspectHandsSlot, [6] = InspectWaistSlot, [7] = InspectLegsSlot,
                                  [8] = InspectFeetSlot, [11] = InspectFinger0Slot, [12] = InspectFinger1Slot,
                                  [13] = InspectTrinket0Slot, [14] = InspectTrinket1Slot, [16] = InspectMainHandSlot,
                                  [17] = InspectSecondaryHandSlot}

    for key, element in pairs(itemSlotsInspectList) do
        if nil == inspectDone[key] then
            if element.ilvl then element.ilvl:SetFormattedText("") end
            if element.ilvlBackground then element.ilvlBackground:Hide() end
            if element.enchant then element.enchant:SetText("") end
            local itemLink = GetInventoryItemLink(unit, key)
            if itemLink then
                local eItem = Item:CreateFromItemLink(itemLink)
                if eItem and not eItem:IsItemEmpty() then
                    eItem:ContinueOnItemLoad(function()
                        inspectDone[key] = true
                        if addon.db["showGemsOnCharframe"] then
                            local hasSockets = false
                            local emptySocketsCount = 0
                            local itemStats = C_Item.GetItemStats(itemLink)
                            for statName, statValue in pairs(itemStats) do
                                if (statName:find("EMPTY_SOCKET") or statName:find("empty_socket")) and
                                    addon.variables.allowedSockets[statName] then
                                    hasSockets = true
                                    emptySocketsCount = emptySocketsCount + statValue
                                end
                            end

                            if hasSockets then
                                if element.gems and #element.gems > emptySocketsCount then
                                    for i = emptySocketsCount + 1, #element.gems do
                                        element.gems[i]:UnregisterAllEvents()
                                        element.gems[i]:SetScript("OnUpdate", nil)
                                        element.gems[i]:Hide()
                                    end
                                end
                                if not element.gems then element.gems = {} end
                                for i = 1, emptySocketsCount do
                                    if not element.gems[i] then
                                        element.gems[i] = CreateFrame("Frame", nil, pdElement)
                                        element.gems[i]:SetSize(16, 16) -- Setze die Größe des Icons
                                        if addon.variables.itemSlotSide[key] == 0 then
                                            element.gems[i]:SetPoint("TOPLEFT", element, "TOPRIGHT", 5 + (i - 1) * 16,
                                                -1) -- Verschiebe jedes Icon um 20px
                                        elseif addon.variables.itemSlotSide[key] == 1 then
                                            element.gems[i]:SetPoint("TOPRIGHT", element, "TOPLEFT", -5 - (i - 1) * 16,
                                                -1)
                                        else
                                            element.gems[i]:SetPoint("BOTTOM", element, "TOPLEFT", -1, 5 + (i - 1) * 16)
                                        end

                                        element.gems[i]:SetFrameStrata("DIALOG")

                                        element.gems[i].icon = element.gems[i]:CreateTexture(nil, "OVERLAY")
                                        element.gems[i].icon:SetAllPoints(element.gems[i])
                                    end
                                    element.gems[i].icon:SetTexture(
                                        "Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic") -- Setze die erhaltene Textur

                                    element.gems[i]:Show()
                                end
                                CheckItemGems(element, itemLink, emptySocketsCount, key, pdElement)
                            else
                                if element.gems then
                                    for i = 1, #element.gems do
                                        element.gems[i]:UnregisterAllEvents()
                                        element.gems[i]:SetScript("OnUpdate", nil)
                                        element.gems[i]:Hide()
                                    end
                                end
                            end
                        else
                            if element.gems and #element.gems > 0 then
                                for i = 1, #element.gems do
                                    element.gems[i]:UnregisterAllEvents()
                                    element.gems[i]:SetScript("OnUpdate", nil)
                                    element.gems[i]:Hide()
                                end
                            end
                        end

                        if addon.db["showIlvlOnCharframe"] then
                            itemCount = itemCount + 1
                            if not element.ilvlBackground then
                                element.ilvlBackground = element:CreateTexture(nil, "BACKGROUND")
                                element.ilvlBackground:SetColorTexture(0, 0, 0, 0.8) -- Schwarzer Hintergrund mit 80% Transparenz
                                element.ilvlBackground:SetPoint("TOPRIGHT", element, "TOPRIGHT", 1, 1)
                                element.ilvlBackground:SetSize(30, 16) -- Größe des Hintergrunds (muss ggf. angepasst werden)

                                -- Text für das Item-Level
                                element.ilvl = element:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
                                element.ilvl:SetPoint("TOPRIGHT", element.ilvlBackground, "TOPRIGHT", -1, -2) -- Position des Textes im Zentrum des Hintergrunds
                                element.ilvl:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE") -- Setzt die Schriftart, -größe und -stil (OUTLINE)
                            end

                            local color = eItem:GetItemQualityColor()
                            local itemLevelText = eItem:GetCurrentItemLevel()
                            ilvlSum = ilvlSum + itemLevelText
                            element.ilvl:SetFormattedText(itemLevelText)
                            element.ilvl:SetTextColor(color.r, color.g, color.b, 1)

                            local textWidth = element.ilvl:GetStringWidth()
                            element.ilvlBackground:SetSize(textWidth + 6, element.ilvl:GetStringHeight() + 4) -- Mehr Padding für bessere Lesbarkeit

                        end
                        if addon.db["showEnchantOnCharframe"] then
                            if not element.enchant then
                                element.enchant = element:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
                                if addon.variables.itemSlotSide[key] == 0 then
                                    element.enchant:SetPoint("BOTTOMLEFT", element, "BOTTOMRIGHT", 2, 1)
                                elseif addon.variables.itemSlotSide[key] == 2 then
                                    element.enchant:SetPoint("TOPLEFT", element, "TOPRIGHT", 2, -1)
                                else
                                    element.enchant:SetPoint("BOTTOMRIGHT", element, "BOTTOMLEFT", -2, 1)
                                end
                                if addon.variables.shouldEnchanted[key] then
                                    element.borderGradient = element:CreateTexture(nil, "ARTWORK")
                                    element.borderGradient:SetPoint("TOPLEFT", element, "TOPLEFT", -2, 2)
                                    element.borderGradient:SetPoint("BOTTOMRIGHT", element, "BOTTOMRIGHT", 2, -2)
                                    element.borderGradient:SetColorTexture(1, 0, 0, 0.6) -- Grundfarbe Rot
                                    element.borderGradient:SetGradient("VERTICAL", CreateColor(1, 0, 0, 1),
                                        CreateColor(1, 0.3, 0.3, 0.5))
                                    element.borderGradient:Hide()
                                end
                                element.enchant:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                            end
                            local tooltip = CreateFrame("GameTooltip", "ScanTooltip", nil, "GameTooltipTemplate")
                            tooltip:SetOwner(UIParent, "ANCHOR_NONE")
                            tooltip:SetHyperlink(itemLink)
                            local foundEnchant = false
                            for i = 1, tooltip:NumLines() do
                                local line = _G["ScanTooltipTextLeft" .. i]:GetText()
                                if line then
                                    local enchant = strmatch(line, addon.variables.enchantString)
                                    if enchant then
                                        local color1, color2 = strmatch(enchant, '(|cn.-:).-(|r)')
                                        local text = strmatch(gsub(
                                            gsub(gsub(line, '%s?|A.-|a', ''), '|cn.-:(.-)|r', '%1'), '[&+] ?', ''),
                                            addon.variables.enchantString)

                                        foundEnchant = true

                                        local enchantText = text:gsub(".*" .. ENCHANTED_TOOLTIP_LINE .. ": ", "") -- Entferne den Text vor dem Enchant
                                        enchantText = enchantText:gsub('(%d+)', '%1')
                                        enchantText = enchantText:gsub('(%a%a%a)%a+', '%1')

                                        -- local shortAbbrev = gsub(enchantText, '(%w%w%w)%w+', '%1')
                                        local r, g, b = _G["ScanTooltipTextLeft" .. i]:GetTextColor()
                                        local colorHex = ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)

                                        enchantText = enchantText:gsub("%%", "%%%%")

                                        if color1 or color2 then
                                            element.enchant:SetFormattedText(
                                                format('%s%s%s', color1 or '', string.utf8sub(enchantText, 1, 20),
                                                    color2 or ''))
                                        else
                                            element.enchant:SetFormattedText(colorHex .. enchantText .. "|r")
                                        end
                                        break
                                    end
                                end
                            end

                            if foundEnchant == false then
                                element.enchant:SetText("")
                                if element.borderGradient and UnitLevel(inspectUnit) == addon.variables.maxLevel then
                                    if key == 17 then
                                        local _, _, _, _, _, _, _, _, itemEquipLoc = C_Item.GetItemInfo(itemLink)
                                        if addon.variables.allowedEnchantTypesForOffhand[itemEquipLoc] then
                                            element.borderGradient:Show()
                                            element.enchant:SetFormattedText(
                                                ("|cff%02x%02x%02x"):format(255, 0, 0) .. L["MissingEnchant"] .. "|r")
                                        end
                                    else
                                        element.borderGradient:Show()
                                        element.enchant:SetFormattedText(
                                            ("|cff%02x%02x%02x"):format(255, 0, 0) .. L["MissingEnchant"] .. "|r")
                                    end
                                end
                            end
                            tooltip:Hide()
                        else
                            if element.borderGradient then element.borderGradient:Hide() end
                            element.enchant:SetText("")
                        end
                    end)
                end
            end
        end
    end
    if addon.db["showIlvlOnCharframe"] and ilvlSum > 0 and itemCount > 0 then
        pdElement.ilvl:SetText("" .. (math.floor((ilvlSum / itemCount) * 100 + 0.5) / 100))
    end
end

local function setIlvlText(element, slot)
    -- Hide all gemslots
    if element then
        if element.gems then
            for i = 1, 3 do
                if element.gems[i] then
                    element.gems[i]:Hide()
                    element.gems[i].icon:SetTexture("Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic")
                end
            end
        end

        if element.borderGradient then element.borderGradient:Hide() end
        if addon.db["showGemsOnCharframe"] == false and addon.db["showIlvlOnCharframe"] == false and
            addon.db["showEnchantOnCharframe"] == false then
            element.ilvl:SetFormattedText("")
            element.enchant:SetText("")
            element.ilvlBackground:Hide()
            return
        end

        local eItem = Item:CreateFromEquipmentSlot(slot)
        if eItem and not eItem:IsItemEmpty() then
            eItem:ContinueOnItemLoad(function()
                local link = eItem:GetItemLink()
                local _, itemID, enchantID = string.match(link,
                    "item:(%d+):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*)")
                if addon.db["showGemsOnCharframe"] then
                    local hasSockets = false
                    local emptySocketsCount = 0
                    local itemStats = C_Item.GetItemStats(link)
                    for statName, statValue in pairs(itemStats) do
                        if (statName:find("EMPTY_SOCKET") or statName:find("empty_socket")) and
                            addon.variables.allowedSockets[statName] then
                            hasSockets = true
                            emptySocketsCount = emptySocketsCount + statValue
                        end
                    end

                    if hasSockets then
                        for i = 1, emptySocketsCount do
                            element.gems[i]:Show()
                            local gemName, gemLink = C_Item.GetItemGem(link, i)
                            if gemName then
                                local icon = GetItemIcon(gemLink)
                                element.gems[i].icon:SetTexture(icon)
                                emptySocketsCount = emptySocketsCount - 1
                            end
                        end
                    end
                end

                if addon.db["showIlvlOnCharframe"] then
                    local color = eItem:GetItemQualityColor()
                    local itemLevelText = eItem:GetCurrentItemLevel()

                    element.ilvl:SetFormattedText(itemLevelText)
                    element.ilvl:SetTextColor(color.r, color.g, color.b, 1)

                    local textWidth = element.ilvl:GetStringWidth()
                    element.ilvlBackground:SetSize(textWidth + 6, element.ilvl:GetStringHeight() + 4) -- Mehr Padding für bessere Lesbarkeit
                else
                    element.ilvl:SetFormattedText("")
                    element.ilvlBackground:Hide()
                end

                if addon.db["showEnchantOnCharframe"] then
                    local tooltip = CreateFrame("GameTooltip", "ScanTooltip", nil, "GameTooltipTemplate")
                    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
                    tooltip:SetHyperlink(link)
                    local foundEnchant = false
                    for i = 1, tooltip:NumLines() do
                        local line = _G["ScanTooltipTextLeft" .. i]:GetText()
                        if line then
                            local enchant = strmatch(line, addon.variables.enchantString)
                            if enchant then
                                local color1, color2 = strmatch(enchant, '(|cn.-:).-(|r)')
                                local text = strmatch(gsub(gsub(gsub(line, '%s?|A.-|a', ''), '|cn.-:(.-)|r', '%1'),
                                    '[&+] ?', ''), addon.variables.enchantString)

                                foundEnchant = true

                                -- local enchantText = gsub(text:gsub(".*" .. ENCHANTED_TOOLTIP_LINE .. ": ", ""),
                                --     '(%w%w%w)%w+', '%1')
                                local enchantText = text:gsub(".*" .. ENCHANTED_TOOLTIP_LINE .. ": ", "") -- Entferne den Text vor dem Enchant
                                enchantText = enchantText:gsub('(%d+)', '%1')
                                enchantText = enchantText:gsub('(%a%a%a)%a+', '%1')

                                -- local shortAbbrev = gsub(enchantText, '(%w%w%w)%w+', '%1')
                                local r, g, b = _G["ScanTooltipTextLeft" .. i]:GetTextColor()
                                local colorHex = ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)

                                enchantText = enchantText:gsub("%%", "%%%%")

                                if color1 or color2 then
                                    element.enchant:SetFormattedText(
                                        format('%s%s%s', color1 or '', string.utf8sub(enchantText, 1, 20), color2 or ''))
                                else
                                    element.enchant:SetFormattedText(colorHex .. enchantText .. "|r")
                                end
                                break
                            end
                        end
                    end

                    if foundEnchant == false then
                        element.enchant:SetText("")
                        if element.borderGradient and UnitLevel("player") == addon.variables.maxLevel then
                            if slot == 17 then
                                local _, _, _, _, _, _, _, _, itemEquipLoc = C_Item.GetItemInfo(link)
                                if addon.variables.allowedEnchantTypesForOffhand[itemEquipLoc] then
                                    element.borderGradient:Show()
                                    element.enchant:SetFormattedText(
                                        ("|cff%02x%02x%02x"):format(255, 0, 0) .. L["MissingEnchant"] .. "|r")
                                end
                            else
                                element.borderGradient:Show()
                                element.enchant:SetFormattedText(
                                    ("|cff%02x%02x%02x"):format(255, 0, 0) .. L["MissingEnchant"] .. "|r")
                            end
                        end
                    end
                    tooltip:Hide()
                else
                    element.enchant:SetText("")
                end
            end)
        else
            element.ilvl:SetFormattedText("")
            element.ilvlBackground:Hide()
            element.enchant:SetText("")
            if element.borderGradient then element.borderGradient:Hide() end
        end
    end
end

local function IsIndestructible(link)
    local itemParts = {strsplit(":", link)}
    for i = 13, #itemParts do
        local bonusID = tonumber(itemParts[i])
        if bonusID and bonusID == 43 then return true; end
    end
    return false;
end

local function calculateDurability()
    local maxDur = 0 -- combined value of durability
    local counter = 0 -- general counter for damaged items
    local critDura = 0 -- counter of items under 50%

    for key, _ in pairs(addon.variables.itemSlots) do
        local eItem = Item:CreateFromEquipmentSlot(key);
        if eItem and not eItem:IsItemEmpty() then
            eItem:ContinueOnItemLoad(function()
                local link = eItem:GetItemLink();
                if link then
                    if IsIndestructible(link) == false then
                        local current, maximum = GetInventoryItemDurability(key)
                        if nil ~= current then
                            local fDur = tonumber(string.format("%." .. 0 .. "f", current * 100 / maximum))
                            counter = counter + 1
                            maxDur = maxDur + fDur
                            if fDur < 50 then critDura = critDura + 1 end
                        end
                    end
                end
            end)
        end
    end

    -- When we only have full durable items so fake the numbers to show 100%
    if maxDur == 0 and counter == 0 then
        maxDur = 100
        counter = 1
    end

    addon.variables.durabilityCount = tonumber(string.format("%." .. 0 .. "f", maxDur / counter)) .. "%"
    addon.general.durabilityIconFrame.count:SetText(addon.variables.durabilityCount)

    if tonumber(string.format("%." .. 0 .. "f", maxDur / counter)) > 80 then
        addon.general.durabilityIconFrame.count:SetTextColor(1, 1, 1)
    elseif tonumber(string.format("%." .. 0 .. "f", maxDur / counter)) > 50 then
        addon.general.durabilityIconFrame.count:SetTextColor(1, 1, 0)
    else
        addon.general.durabilityIconFrame.count:SetTextColor(1, 0, 0)
    end
end

local function UpdateItemLevel()
    local statFrame = CharacterStatsPane.ItemLevelFrame
    if statFrame and statFrame.Value then
        local avgItemLevel, equippedItemLevel = GetAverageItemLevel()
        local customItemLevel = equippedItemLevel
        statFrame.Value:SetText(string.format("%.2f", customItemLevel))
    end
end

hooksecurefunc("PaperDollFrame_SetItemLevel", function(statFrame, unit) UpdateItemLevel() end)

local function setCharFrame()
    UpdateItemLevel()
    if addon.db["showCatalystChargesOnCharframe"] then
        local cataclystInfo = C_CurrencyInfo.GetCurrencyInfo(addon.variables.catalystID)
        addon.general.iconFrame.count:SetText(cataclystInfo.quantity)
    end
    if addon.db["showDurabilityOnCharframe"] then calculateDurability() end
    for key, value in pairs(addon.variables.itemSlots) do setIlvlText(value, key) end
end

local function addDungeonFrame(tab)
    addon.functions.InitDBValue("autoChooseDelvePower", true)
    addon.functions.InitDBValue("lfgSortByRio", true)

    local fDungeon = addon.functions.createTabFrameMain(L["Dungeon"], tab)

    local cbPersistSignUpNote = addon.functions.createCheckbox("persistSignUpNote", fDungeon,
        L["Persist LFG signup note"], 10, -10)

    local cbSkipSignup = addon.functions.createCheckbox("skipSignUpDialog", fDungeon, L["Quick signup"], 10,
        (addon.functions.getHeightOffset(cbPersistSignUpNote)))

    local cbAutoChooseDelvePower = addon.functions.createCheckbox("autoChooseDelvePower", fDungeon,
        L["autoChooseDelvePower"], 10, (addon.functions.getHeightOffset(cbSkipSignup)))

    local cbSortApplicantsByRio = addon.functions.createCheckbox("lfgSortByRio", fDungeon, L["lfgSortByRio"], 10,
        (addon.functions.getHeightOffset(cbAutoChooseDelvePower)))
end

local function addHideOption(type, parent, anchor, className)
    if type == "TOTEM" then
        local cbHideTotemFrame = addon.functions.createCheckbox(className .. "_HideTotem", parent,
            L["shaman_HideTotem"], 10, (addon.functions.getHeightOffset(anchor)) - 10)
        cbHideTotemFrame:SetScript("OnClick", function(self)
            addon.db[className .. "_HideTotem"] = self:GetChecked()
            if self:GetChecked() then
                TotemFrame:Hide()
            else
                TotemFrame:Show()
            end
        end)
        TotemFrame:HookScript("OnShow", function(self)
            if addon.db[className .. "_HideTotem"] then
                TotemFrame:Hide()
            else
                TotemFrame:Show()
            end
        end)
    end
end

local function addTotemHideToggle(dbValue, language, frame, anchor)
    local cbHideTotemFrame = addon.functions.createCheckbox(dbValue, frame, L[language], 10,
        (addon.functions.getHeightOffset(anchor)) - 10)
    cbHideTotemFrame:SetScript("OnClick", function(self)
        addon.db[dbValue] = self:GetChecked()
        if self:GetChecked() then
            TotemFrame:Hide()
        else
            TotemFrame:Show()
        end
    end)
    TotemFrame:HookScript("OnShow", function(self)
        if addon.db[dbValue] then
            TotemFrame:Hide()
        else
            TotemFrame:Show()
        end
    end)
    if addon.db[dbValue] then TotemFrame:Hide() end
    return cbHideTotemFrame
end

local function addCVarFrame(tab)
    local fCVar = addon.functions.createTabFrameMain(L["CVar"], tab)

    local sortedOptions = {}

    for key, data in pairs(L["CVarOptions"]) do
        table.insert(sortedOptions, {key = key, description = data.description, trueValue = data.trueValue,
                                     falseValue = data.falseValue})
    end
    table.sort(sortedOptions, function(a, b) return a.description < b.description end)

    local lastElement = nil

    for _, option in ipairs(sortedOptions) do
        local key = option.key
        local description = option.description
        local trueValue = option.trueValue
        local falseValue = option.falseValue

        if lastElement ~= nil then
            lastElement = addon.functions.createCheckboxNoDB(key, fCVar, description, 10,
                (addon.functions.getHeightOffset(lastElement)))
        else
            lastElement = addon.functions.createCheckboxNoDB(key, fCVar, description, 10, -10)
        end

        lastElement:SetScript("OnClick", function(self)
            addon.variables.requireReload = true
            if self:GetChecked() then
                SetCVar(key, trueValue)
            else
                SetCVar(key, falseValue)
            end
        end)

        if GetCVar(key) == trueValue then
            lastElement:SetChecked(true)
        else
            lastElement:SetChecked(false)
        end
    end

end

local function addCharacterFrame(tab)
    addon.functions.InitDBValue("showIlvlOnCharframe", false)
    addon.functions.InitDBValue("showInfoOnInspectFrame", false)
    addon.functions.InitDBValue("showGemsOnCharframe", false)
    addon.functions.InitDBValue("showEnchantOnCharframe", false)
    addon.functions.InitDBValue("showCatalystChargesOnCharframe", false)

    local fCharacter = addon.functions.createTabFrameMain(L["Character"], tab)

    local cbShowIlvlCharframe = addon.functions.createCheckbox("showIlvlOnCharframe", fCharacter,
        L["showIlvlOnCharframe"], 10, -10)
    cbShowIlvlCharframe:SetScript("OnClick", function(self)
        addon.db["showIlvlOnCharframe"] = self:GetChecked()
        setCharFrame()
        -- if InspectFrame and InspectFrame:IsShown() then onInspect() end
    end)
    local cbShowGemsCharframe = addon.functions.createCheckbox("showGemsOnCharframe", fCharacter,
        L["showGemsOnCharframe"], 10, (addon.functions.getHeightOffset(cbShowIlvlCharframe)) - 10)
    cbShowGemsCharframe:SetScript("OnClick", function(self)
        addon.db["showGemsOnCharframe"] = self:GetChecked()
        setCharFrame()
        -- if InspectFrame and InspectFrame:IsShown() then onInspect() end
    end)
    local cbShowEnchantCharframe = addon.functions.createCheckbox("showEnchantOnCharframe", fCharacter,
        L["showEnchantOnCharframe"], 10, (addon.functions.getHeightOffset(cbShowGemsCharframe)) - 10)
    cbShowEnchantCharframe:SetScript("OnClick", function(self)
        addon.db["showEnchantOnCharframe"] = self:GetChecked()
        setCharFrame()
        -- if InspectFrame and InspectFrame:IsShown() then onInspect() end
    end)

    local cbShowInfoOnInspectFrame = addon.functions.createCheckbox("showInfoOnInspectFrame", fCharacter,
        L["showInfoOnInspectFrame"], 10, (addon.functions.getHeightOffset(cbShowEnchantCharframe)) - 10)
    cbShowEnchantCharframe:SetScript("OnClick", function(self)
        addon.db["showInfoOnInspectFrame"] = self:GetChecked()
        removeInspectElements()
    end)

    -- Add Cataclyst charges in char frame
    local cataclystInfo = C_CurrencyInfo.GetCurrencyInfo(addon.variables.catalystID)
    local iconID = cataclystInfo.iconFileID

    addon.general.iconFrame = CreateFrame("Button", nil, PaperDollFrame, "BackdropTemplate")
    addon.general.iconFrame:SetSize(32, 32)
    addon.general.iconFrame:SetPoint("BOTTOMLEFT", PaperDollSidebarTab3, "BOTTOMRIGHT", 4, 0)

    addon.general.iconFrame.icon = addon.general.iconFrame:CreateTexture(nil, "OVERLAY")
    addon.general.iconFrame.icon:SetSize(32, 32)
    addon.general.iconFrame.icon:SetPoint("CENTER", addon.general.iconFrame, "CENTER")
    addon.general.iconFrame.icon:SetTexture(iconID)

    addon.general.iconFrame.count = addon.general.iconFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    addon.general.iconFrame.count:SetPoint("BOTTOMRIGHT", addon.general.iconFrame, "BOTTOMRIGHT", 1, 2)
    addon.general.iconFrame.count:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    addon.general.iconFrame.count:SetText(cataclystInfo.quantity)
    addon.general.iconFrame.count:SetTextColor(1, 0.82, 0)

    local cbshowCatalystChargesOnCharframe = addon.functions.createCheckbox("showCatalystChargesOnCharframe",
        fCharacter, L["showCatalystChargesOnCharframe"], 10,
        (addon.functions.getHeightOffset(cbShowInfoOnInspectFrame)) - 10)
    cbshowCatalystChargesOnCharframe:SetScript("OnClick", function(self)
        addon.db["showCatalystChargesOnCharframe"] = self:GetChecked()
        if self:GetChecked() then
            addon.general.iconFrame:Show()
        else
            addon.general.iconFrame:Hide()
        end
    end)

    if addon.db["showCatalystChargesOnCharframe"] == false then addon.general.iconFrame:Hide() end

    -- add durability icon on charframe

    addon.general.durabilityIconFrame = CreateFrame("Button", nil, PaperDollFrame, "BackdropTemplate")
    addon.general.durabilityIconFrame:SetSize(32, 32)
    addon.general.durabilityIconFrame:SetPoint("TOPLEFT", CharacterFramePortrait, "RIGHT", 4, 0)

    addon.general.durabilityIconFrame.icon = addon.general.durabilityIconFrame:CreateTexture(nil, "OVERLAY")
    addon.general.durabilityIconFrame.icon:SetSize(32, 32)
    addon.general.durabilityIconFrame.icon:SetPoint("CENTER", addon.general.durabilityIconFrame, "CENTER")
    addon.general.durabilityIconFrame.icon:SetTexture(addon.variables.durabilityIcon)

    addon.general.durabilityIconFrame.count = addon.general.durabilityIconFrame:CreateFontString(nil, "OVERLAY",
        "GameFontHighlightLarge")
    addon.general.durabilityIconFrame.count:SetPoint("BOTTOMRIGHT", addon.general.durabilityIconFrame, "BOTTOMRIGHT", 1,
        2)
    addon.general.durabilityIconFrame.count:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    local cbShowDurabilityOnCharframe = addon.functions.createCheckbox("showDurabilityOnCharframe", fCharacter,
        L["showDurabilityOnCharframe"], 10, (addon.functions.getHeightOffset(cbshowCatalystChargesOnCharframe)) - 10)
    cbShowDurabilityOnCharframe:SetScript("OnClick", function(self)
        addon.db["showDurabilityOnCharframe"] = self:GetChecked()
        calculateDurability()
        if self:GetChecked() then
            addon.general.durabilityIconFrame:Show()
        else
            addon.general.durabilityIconFrame:Hide()
        end
    end)
    if addon.db["showDurabilityOnCharframe"] == false then addon.general.durabilityIconFrame:Hide() end

    for key, value in pairs(addon.variables.itemSlots) do
        -- Hintergrund für das Item-Level
        value.ilvlBackground = value:CreateTexture(nil, "BACKGROUND")
        value.ilvlBackground:SetColorTexture(0, 0, 0, 0.8) -- Schwarzer Hintergrund mit 80% Transparenz
        value.ilvlBackground:SetPoint("TOPRIGHT", value, "TOPRIGHT", 1, 1)
        value.ilvlBackground:SetSize(30, 16) -- Größe des Hintergrunds (muss ggf. angepasst werden)

        -- Roter Rahmen mit Farbverlauf
        if addon.variables.shouldEnchanted[key] then
            value.borderGradient = value:CreateTexture(nil, "ARTWORK")
            value.borderGradient:SetPoint("TOPLEFT", value, "TOPLEFT", -2, 2)
            value.borderGradient:SetPoint("BOTTOMRIGHT", value, "BOTTOMRIGHT", 2, -2)
            value.borderGradient:SetColorTexture(1, 0, 0, 0.6) -- Grundfarbe Rot
            value.borderGradient:SetGradient("VERTICAL", CreateColor(1, 0, 0, 1), CreateColor(1, 0.3, 0.3, 0.5))
            value.borderGradient:Hide()
        end
        -- Text für das Item-Level
        value.ilvl = value:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        value.ilvl:SetPoint("TOPRIGHT", value.ilvlBackground, "TOPRIGHT", -1, -2) -- Position des Textes im Zentrum des Hintergrunds
        value.ilvl:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE") -- Setzt die Schriftart, -größe und -stil (OUTLINE)

        value.enchant = value:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        if addon.variables.itemSlotSide[key] == 0 then
            value.enchant:SetPoint("BOTTOMLEFT", value, "BOTTOMRIGHT", 2, 1)
        elseif addon.variables.itemSlotSide[key] == 2 then
            value.enchant:SetPoint("BOTTOMLEFT", value, "BOTTOMRIGHT", 2, 1)
        else
            value.enchant:SetPoint("BOTTOMRIGHT", value, "BOTTOMLEFT", -2, 1)
        end
        value.enchant:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

        value.gems = {}
        for i = 1, 3 do
            value.gems[i] = CreateFrame("Frame", nil, PaperDollFrame)
            value.gems[i]:SetSize(16, 16) -- Setze die Größe des Icons

            if addon.variables.itemSlotSide[key] == 0 then
                value.gems[i]:SetPoint("TOPLEFT", value, "TOPRIGHT", 5 + (i - 1) * 16, -1) -- Verschiebe jedes Icon um 20px
            elseif addon.variables.itemSlotSide[key] == 1 then
                value.gems[i]:SetPoint("TOPRIGHT", value, "TOPLEFT", -5 - (i - 1) * 16, -1)
            else
                value.gems[i]:SetPoint("BOTTOM", value, "TOPLEFT", -1, 5 + (i - 1) * 16)
            end

            value.gems[i]:SetFrameStrata("DIALOG")

            value.gems[i].icon = value.gems[i]:CreateTexture(nil, "OVERLAY")
            value.gems[i].icon:SetAllPoints(value.gems[i])
            value.gems[i].icon:SetTexture("Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic") -- Setze die erhaltene Textur

            value.gems[i]:Hide()
        end
    end

    PaperDollFrame:HookScript("OnShow", function(self) setCharFrame() end)

    local function updateButtonInfo(itemButton, bag, slot)
        local eItem = Item:CreateFromBagAndSlot(bag, slot)
        if eItem and not eItem:IsItemEmpty() then
            eItem:ContinueOnItemLoad(function()
                if not itemButton.ItemLevelText then
                    itemButton.ItemLevelText = itemButton:CreateFontString(nil, "OVERLAY")
                    itemButton.ItemLevelText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
                    itemButton.ItemLevelText:SetPoint("TOPRIGHT", itemButton, "TOPRIGHT", 0, -2)

                    itemButton.ItemLevelText:SetShadowOffset(2, -2)
                    itemButton.ItemLevelText:SetShadowColor(0, 0, 0, 1)
                end
                local link = eItem:GetItemLink()
                local invSlot = select(4, GetItemInfoInstant(link))
                if nil == addon.variables.allowedEquipSlotsBagIlvl[invSlot] then return end

                local color = eItem:GetItemQualityColor()
                local itemLevelText = eItem:GetCurrentItemLevel()

                itemButton.ItemLevelText:SetFormattedText(itemLevelText)
                itemButton.ItemLevelText:SetTextColor(color.r, color.g, color.b, 1)

                itemButton.ItemLevelText:Show()
            end)
        elseif itemButton.ItemLevelText then
            itemButton.ItemLevelText:Hide()
        end
    end

    local updateBags = function(frame)

        for _, itemButton in frame:EnumerateValidItems() do
            if addon.db["showIlvlOnBagItems"] then
                updateButtonInfo(itemButton, itemButton:GetBagID(), itemButton:GetID())
            elseif itemButton.ItemLevelText then
                itemButton.ItemLevelText:Hide()
            end
        end
    end

    -- @debug@
    -- local lastButtons = {} -- needed as of 11.0.0, see below for why
    -- local updateBank = function(frame)
    --     -- table.wipe(lastButtons)
    --     for itemButton in frame:EnumerateValidItems() do
    --         if addon.db["showIlvlOnBagItems"] then
    --             updateButtonInfo(itemButton, itemButton:GetBankTabID(), itemButton:GetContainerSlotID())
    --             -- table.insert(lastButtons, itemButton)
    --         elseif itemButton.ItemLevelText then
    --             itemButton.ItemLevelText:Hide()
    --         end
    --     end
    -- end

    -- -- hooksecurefunc("BankFrameItemButton_Update", function(button)
    -- --     if not button.isBag then
    -- --         updateButtonInfo(button, button:GetParent():GetID())
    -- --     end
    -- -- end)

    -- if _G.AccountBankPanel then
    --     hooksecurefunc(AccountBankPanel, "GenerateItemSlotsForSelectedTab", updateBank)
    --     hooksecurefunc(AccountBankPanel, "RefreshAllItemsForSelectedTab", updateBank)
    --     -- hooksecurefunc(AccountBankPanel, "SetItemDisplayEnabled", function(_, state)
    --     --     -- Papering over a Blizzard bug: when you open the "buy" tab, they
    --     --     -- call this which releases the itembuttons from the pool... but
    --     --     -- doesn't *hide* them, so they're all still there with the buy panel
    --     --     -- sitting one layer above them.
    --     --     -- I sadly need to remember the buttons, because once it released them
    --     --     -- they're no longer available via EnumerateValidItems.
    --     --     if state == false then
    --     --         for _, itemButton in ipairs(lastButtons) do
    --     --             if itemButton.ItemLevelText then itemButton.ItemLevelText:Hide() end
    --     --         end
    --     --     end
    --     -- end)
    -- end
    -- @end-debug@

    local cbShowIlvlOnBags = addon.functions.createCheckbox("showIlvlOnBagItems", fCharacter, L["showIlvlOnBagItems"],
        10, (addon.functions.getHeightOffset(cbShowDurabilityOnCharframe)) - 10)
    cbShowIlvlOnBags:SetScript("OnClick", function(self)
        addon.db["showIlvlOnBagItems"] = self:GetChecked()
        for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
            if frame:IsShown() then updateBags(frame) end
        end
        if ContainerFrameCombinedBags:IsShown() then updateBags(ContainerFrameCombinedBags) end
    end)

    hooksecurefunc(ContainerFrameCombinedBags, "UpdateItems", updateBags)
    for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
        hooksecurefunc(frame, "UpdateItems", updateBags)
    end

    -- Order Hall Bar
    local cbHideOrderHallFrame = addon.functions.createCheckbox("hideOrderHallBar", fCharacter, L["hideOrderHallBar"],
        10, (addon.functions.getHeightOffset(cbShowIlvlOnBags)) - 10)
    cbHideOrderHallFrame:SetScript("OnClick", function(self)
        addon.db["hideOrderHallBar"] = self:GetChecked()
        if OrderHallCommandBar then
            if self:GetChecked() then
                OrderHallCommandBar:Hide()
            else
                OrderHallCommandBar:Show()
            end
        end
    end)

    if OrderHallCommandBar then
        OrderHallCommandBar:HookScript("OnShow", function(self)
            if addon.db["hideOrderHallBar"] then
                self:Hide()
            else
                self:Show()
            end
        end)
        if addon.db["hideOrderHallBar"] then OrderHallCommandBar:Hide() end
    end

    local labelClassSpecific = addon.functions.createLabel(fCharacter, L["headerClassInfo"], 0, (addon.functions
        .getHeightOffset(cbHideOrderHallFrame)) - 20, "TOP", "TOP")

    local classname = select(2, UnitClass("player"))

    -- Classspecific stuff
    if classname == "DEATHKNIGHT" then
        local cbHideDKRuneFrame = addon.functions.createCheckbox("deathknight_HideRuneFrame", fCharacter,
            L["deathknight_HideRuneFrame"], 10, (addon.functions.getHeightOffset(labelClassSpecific)) - 10)
        cbHideDKRuneFrame:SetScript("OnClick", function(self)
            addon.db["deathknight_HideRuneFrame"] = self:GetChecked()
            if self:GetChecked() then
                RuneFrame:Hide()
            else
                RuneFrame:Show()
            end
        end)
        RuneFrame:HookScript("OnShow", function(self)
            if addon.db["deathknight_HideRuneFrame"] then
                RuneFrame:Hide()
            else
                RuneFrame:Show()
            end
        end)
        if addon.db["deathknight_HideRuneFrame"] then RuneFrame:Hide() end

        addTotemHideToggle("deathknight_HideTotemBar", "shaman_HideTotem", fCharacter, cbHideDKRuneFrame)
    elseif classname == "DRUID" then
        addTotemHideToggle("druid_HideTotemBar", "shaman_HideTotem", fCharacter, labelClassSpecific)
    elseif classname == "EVOKER" then
        local cbHideEssenceFrame = addon.functions.createCheckbox("evoker_HideEssence", fCharacter,
            L["evoker_HideEssence"], 10, (addon.functions.getHeightOffset(labelClassSpecific)) - 10)
        cbHideEssenceFrame:SetScript("OnClick", function(self)
            addon.db["evoker_HideEssence"] = self:GetChecked()
            if self:GetChecked() then
                EssencePlayerFrame:Hide()
            else
                EssencePlayerFrame:Show()
            end
        end)
        EssencePlayerFrame:HookScript("OnShow", function(self)
            if addon.db["evoker_HideEssence"] then EssencePlayerFrame:Hide() end
        end)
        if addon.db["evoker_HideEssence"] then EssencePlayerFrame:Hide() end -- Initialset
    elseif classname == "MAGE" then
        addTotemHideToggle("mage_HideTotemBar", "shaman_HideTotem", fCharacter, labelClassSpecific)
    elseif classname == "MONK" then
        local cbHideMonkHarmonyBar = addon.functions.createCheckbox("monk_HideHarmonyBar", fCharacter,
            L["monk_HideHarmonyBar"], 10, (addon.functions.getHeightOffset(labelClassSpecific)) - 10)
        cbHideMonkHarmonyBar:SetScript("OnClick", function(self)
            addon.db["monk_HideHarmonyBar"] = self:GetChecked()
            if self:GetChecked() then
                MonkHarmonyBarFrame:Hide()
            else
                MonkHarmonyBarFrame:Show()
            end
        end)
        MonkHarmonyBarFrame:HookScript("OnShow", function(self)
            if addon.db["monk_HideHarmonyBar"] then
                MonkHarmonyBarFrame:Hide()
            else
                MonkHarmonyBarFrame:Show()
            end
        end)
        addTotemHideToggle("monk_HideTotemBar", "shaman_HideTotem", fCharacter, cbHideMonkHarmonyBar)
        if addon.db["monk_HideHarmonyBar"] then MonkHarmonyBarFrame:Hide() end
    elseif classname == "PRIEST" then
        addTotemHideToggle("priest_HideTotemBar", "shaman_HideTotem", fCharacter, labelClassSpecific)
    elseif classname == "SHAMAN" then
        local cbHideTotemFrame = addTotemHideToggle("shaman_HideTotem", "shaman_HideTotem", fCharacter,
            labelClassSpecific)
    elseif classname == "ROGUE" then
        local cbHideRogueCPFrame = addon.functions.createCheckbox("rogue_HideComboPoint", fCharacter,
            L["rogue_HideComboPoint"], 10, (addon.functions.getHeightOffset(labelClassSpecific)) - 10)
        cbHideRogueCPFrame:SetScript("OnClick", function(self)
            addon.db["rogue_HideComboPoint"] = self:GetChecked()
            if self:GetChecked() then
                RogueComboPointBarFrame:Hide()
            else
                RogueComboPointBarFrame:Show()
            end
        end)
        RogueComboPointBarFrame:HookScript("OnShow", function(self)
            if addon.db["rogue_HideComboPoint"] then
                RogueComboPointBarFrame:Hide()
            else
                RogueComboPointBarFrame:Show()
            end
        end)
        if addon.db["rogue_HideComboPoint"] then RogueComboPointBarFrame:Hide() end
    elseif classname == "PALADIN" then
        local cbHidePaladinHolyFrame = addon.functions.createCheckbox("paladin_HideHolyPower", fCharacter,
            L["paladin_HideHolyPower"], 10, (addon.functions.getHeightOffset(labelClassSpecific)) - 10)
        cbHidePaladinHolyFrame:SetScript("OnClick", function(self)
            addon.db["paladin_HideHolyPower"] = self:GetChecked()
            if self:GetChecked() then
                PaladinPowerBarFrame:Hide()
            else
                PaladinPowerBarFrame:Show()
            end
        end)
        PaladinPowerBarFrame:HookScript("OnShow", function(self)
            if addon.db["paladin_HideHolyPower"] then
                PaladinPowerBarFrame:Hide()
            else
                PaladinPowerBarFrame:Show()
            end
        end)
        addTotemHideToggle("paladin_HideTotemBar", "shaman_HideTotem", fCharacter, cbHidePaladinHolyFrame)
        if addon.db["paladin_HideHolyPower"] then PaladinPowerBarFrame:Hide() end
    elseif classname == "WARLOCK" then
        local cbHideWarlockSoulShardBar = addon.functions.createCheckbox("warlock_HideSoulShardBar", fCharacter,
            L["warlock_HideSoulShardBar"], 10, (addon.functions.getHeightOffset(labelClassSpecific)) - 10)
        cbHideWarlockSoulShardBar:SetScript("OnClick", function(self)
            addon.db["warlock_HideSoulShardBar"] = self:GetChecked()
            if self:GetChecked() then
                WarlockPowerFrame:Hide()
            else
                WarlockPowerFrame:Show()
            end
        end)
        WarlockPowerFrame:HookScript("OnShow", function(self)
            if addon.db["warlock_HideSoulShardBar"] then
                WarlockPowerFrame:Hide()
            else
                WarlockPowerFrame:Show()
            end
        end)
        addTotemHideToggle("warlock_HideTotemBar", "shaman_HideTotem", fCharacter, cbHideWarlockSoulShardBar)
        if addon.db["warlock_HideSoulShardBar"] then WarlockPowerFrame:Hide() end
    else
        labelClassSpecific:Hide()
    end
end

local function addMiscFrame(tab)
    addon.functions.InitDBValue("deleteItemFillDialog", false)
    addon.functions.InitDBValue("hideRaidTools", false)
    addon.functions.InitDBValue("autoRepair", false)
    addon.functions.InitDBValue("sellAllJunk", false)
    addon.functions.InitDBValue("ignoreTalkingHead", true)
    addon.functions.InitDBValue("hiddenLandingPages", {})
    addon.functions.InitDBValue("hideMinimapButton", false)

    local fMisc = addon.functions.createTabFrameMain(L["Misc"], tab)

    local cbIgnoreTalkingHead = addon.functions.createCheckbox("ignoreTalkingHead", fMisc, L["ignoreTalkingHead"], 10,
        -10)
    hooksecurefunc(TalkingHeadFrame, "PlayCurrent",
        function(self) if addon.db["ignoreTalkingHead"] then self:Hide() end end)

    local cbAutoRepair = addon.functions.createCheckbox("autoRepair", fMisc, L["autoRepair"], 10,
        (addon.functions.getHeightOffset(cbIgnoreTalkingHead)))

    local cbSellAllJunk = addon.functions.createCheckbox("sellAllJunk", fMisc, L["sellAllJunk"], 10,
        (addon.functions.getHeightOffset(cbAutoRepair)))

    local cbDeleteItemFill = addon.functions.createCheckbox("deleteItemFillDialog", fMisc, L["deleteItemFillDialog"],
        10, (addon.functions.getHeightOffset(cbSellAllJunk)))

    local cbHideBagBar = addon.functions.createCheckbox("hideBagsBar", fMisc, L["hideBagsBar"], 10,
        (addon.functions.getHeightOffset(cbDeleteItemFill)))
    cbHideBagBar:SetScript("OnClick", function(self)
        addon.db["hideBagsBar"] = self:GetChecked()
        addon.functions.toggleBagsBar(addon.db["hideBagsBar"])
    end)

    local cbMinimapHide = addon.functions.createCheckbox("hideMinimapButton", fMisc, L["Hide Minimap Button"], 10,
        (addon.functions.getHeightOffset(cbHideBagBar)))
    cbMinimapHide:SetScript("OnClick", function(self)
        addon.db["hideMinimapButton"] = self:GetChecked()
        addon.functions.toggleMinimapButton(addon.db["hideMinimapButton"])
    end)

    local cbHideRaidTools = addon.functions.createCheckbox("hideRaidTools", fMisc, L["Hide Raid Tools"], 10,
        (addon.functions.getHeightOffset(cbMinimapHide)))
    cbHideRaidTools:SetScript("OnClick", function(self)
        addon.db["hideRaidTools"] = self:GetChecked()
        addon.functions.toggleRaidTools(addon.db["hideRaidTools"], _G.CompactRaidFrameManager)
    end)
    _G.CompactRaidFrameManager:SetScript("OnShow", function(self)
        addon.functions.toggleRaidTools(addon.db["hideRaidTools"], self)
    end)

    local cbOpenCharFrameOnUpgrade = addon.functions.createCheckbox("openCharframeOnUpgrade", fMisc,
        L["openCharframeOnUpgrade"], 10, (addon.functions.getHeightOffset(cbHideRaidTools)))
    local cbQuickLoot = addon.functions.createCheckbox("autoQuickLoot", fMisc, L["autoQuickLoot"], 10,
        (addon.functions.getHeightOffset(cbOpenCharFrameOnUpgrade)))

    local labelHeadline = addon.functions.createLabel(fMisc, L["landingPageHide"], 10,
        addon.functions.getHeightOffset(cbQuickLoot) - 20, "TOP", "TOP")

    local lastCheckbox = labelHeadline

    local sortedKeys = {}
    for id in pairs(addon.variables.landingPageType) do table.insert(sortedKeys, id) end
    table.sort(sortedKeys)

    for _, id in ipairs(sortedKeys) do
        local page = addon.variables.landingPageType[id]

        -- Erstelle die Checkbox
        local cbLandingPage = addon.functions.createCheckbox("landingPageType_" .. id, fMisc, page.checkbox, 10,
            (addon.functions.getHeightOffset(lastCheckbox)))
        cbLandingPage:SetScript("OnClick", function(self)
            addon.db["hiddenLandingPages"][id] = self:GetChecked()
            addon.functions.toggleLandingPageButton(page.title, self:GetChecked())
        end)
        if addon.db["hiddenLandingPages"][id] then cbLandingPage:SetChecked(true) end

        lastCheckbox = cbLandingPage
    end

    ExpansionLandingPageMinimapButton:HookScript("OnShow", function(self)
        local id = addon.variables.landingPageReverse[self.title]
        if addon.db["hiddenLandingPages"][id] then self:Hide() end
    end)
end

local function addQuestFrame(tab)
    addon.functions.InitDBValue("autoChooseQuest", false)
    addon.functions.InitDBValue("ignoreTrivialQuests", true)
    addon.functions.InitDBValue("ignoreDailyQuests", true)
    addon.functions.InitDBValue("ignoredQuestNPC", {})

    local fQuest = addon.functions.createTabFrameMain(L["Quest"], tab)

    local cbAutoChooseQuest = addon.functions.createCheckbox("autoChooseQuest", fQuest, L["autoChooseQuest"], 10, -10)
    local cbIgnoreDailyQuests = addon.functions.createCheckbox("ignoreDailyQuests", fQuest, L["ignoreDailyQuests"], 10,
        (addon.functions.getHeightOffset(cbAutoChooseQuest)))
    local cbIgnoreTrivialQuests = addon.functions.createCheckbox("ignoreTrivialQuests", fQuest,
        L["ignoreTrivialQuests"], 10, (addon.functions.getHeightOffset(cbIgnoreDailyQuests)))

    local labelHeadline = addon.functions.createLabel(fQuest, L["questAddNPCToExclude"], 10,
        addon.functions.getHeightOffset(cbIgnoreTrivialQuests) - 10, "TOP", "TOP")

    local tExclude = {}
    local dropIncludeList, btnRemoveInclude

    for id, name in pairs(addon.db["ignoredQuestNPC"]) do table.insert(tExclude, {value = id, text = name}) end

    local btnAddInclude = addon.functions.createButton(fQuest, 10, addon.functions.getHeightOffset(labelHeadline) - 7,
        50, 30, ADD, function()
            local guid = nil
            local name = nil
            local type = nil
            local unitType = nil

            if nil ~= UnitGUID("npc") then
                type = "npc"
            elseif nil ~= UnitGUID("target") then
                type = "target"
            else
                return
            end

            guid = UnitGUID(type)
            name = UnitName(type)
            unitType = strsplit("-", guid)

            if UnitCanAttack(type, "player") or (UnitPlayerControlled(type) and not unitType == "Vehicle") then
                return
            end -- ignore attackable and player types

            local mapID = C_Map.GetBestMapForUnit("player")
            if mapID and not unitType == "Vehicle" then
                local mapInfo = C_Map.GetMapInfo(mapID)
                if mapInfo and mapInfo.name then name = name .. " (" .. mapInfo.name .. ")" end
            end

            guid = addon.functions.getIDFromGUID(guid)
            if addon.db["ignoredQuestNPC"][guid] then return end -- no duplicates

            print(ADD .. ":", guid, name)

            addon.db["ignoredQuestNPC"][guid] = name
            addon.functions.addDropdownItem(dropIncludeList, tExclude, {text = name, value = guid})
        end)
    btnAddInclude:SetWidth(btnAddInclude:GetFontString():GetStringWidth() + 20)

    dropIncludeList = addon.functions.createDropdownNoInitial("ignoredQuestNPC", fQuest, tExclude, 150,
        L["ignoredQuestNPC"], 10, addon.functions.getHeightOffset(btnAddInclude) - 10)

    btnRemoveInclude = addon.functions.createButton(fQuest, dropIncludeList:GetWidth(),
        addon.functions.getHeightOffset(btnAddInclude) - 20, 50, 30, REMOVE, function()
            local selectedID = UIDropDownMenu_GetSelectedID(dropIncludeList)
            if selectedID then
                local selectedItem = tExclude[selectedID]
                if selectedItem then
                    addon.db["ignoredQuestNPC"][selectedItem.value] = nil
                    table.remove(tExclude, selectedID)
                    local function Initialize(self, level)
                        local info = UIDropDownMenu_CreateInfo()
                        for i, item in ipairs(tExclude) do
                            info.text = item.text
                            info.value = item.value
                            info.checked = nil
                            info.func = function(self)
                                UIDropDownMenu_SetSelectedID(dropIncludeList, i)
                            end
                            UIDropDownMenu_AddButton(info, level)
                        end
                    end

                    UIDropDownMenu_Initialize(dropIncludeList, Initialize)
                    UIDropDownMenu_SetText(dropIncludeList, "")
                end
            end
        end)
    btnRemoveInclude:SetWidth(btnRemoveInclude:GetFontString():GetStringWidth() + 20)
end

function loadMain()

    -- Erstelle das Hauptframe
    local frame = CreateFrame("Frame", "EnhanceQoLMainFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:Hide() -- Das Frame wird initial versteckt
    frame:SetSize(500, 550)

    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnHide", function()

        if addon.variables.requireReload == false then return end

        local reloadFrame = CreateFrame("Frame", "ReloadUIPopup", UIParent, "BasicFrameTemplateWithInset")
        reloadFrame:SetSize(500, 120) -- Breite und Höhe
        reloadFrame:SetPoint("TOP", UIParent, "TOP", 0, -200) -- Zentriert auf dem Bildschirm

        reloadFrame.title = reloadFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        reloadFrame.title:SetPoint("TOP", reloadFrame, "TOP", 0, -6)
        reloadFrame.title:SetText(L["tReloadInterface"])

        reloadFrame.infoText = reloadFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        reloadFrame.infoText:SetPoint("CENTER", reloadFrame, "CENTER", 0, 10)
        reloadFrame.infoText:SetText(L["bReloadInterface"])

        local reloadButton = CreateFrame("Button", nil, reloadFrame, "GameMenuButtonTemplate")
        reloadButton:SetSize(120, 30)
        reloadButton:SetPoint("BOTTOMLEFT", reloadFrame, "BOTTOMLEFT", 10, 10)
        reloadButton:SetText(RELOADUI)
        reloadButton:SetScript("OnClick", function() ReloadUI() end)

        local cancelButton = CreateFrame("Button", nil, reloadFrame, "GameMenuButtonTemplate")
        cancelButton:SetSize(120, 30)
        cancelButton:SetPoint("BOTTOMRIGHT", reloadFrame, "BOTTOMRIGHT", -10, 10)
        cancelButton:SetText(CANCEL)
        cancelButton:SetScript("OnClick", function()
            reloadFrame:Hide()
            addon.variables.requireReload = false -- disable the prompt on cancel
        end)

        reloadFrame:Show()
    end)

    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Position speichern
        local point, _, _, xOfs, yOfs = self:GetPoint()
        EnhanceQoLDB.point = point
        EnhanceQoLDB.x = xOfs
        EnhanceQoLDB.y = yOfs
    end)
    if UISpecialFrames then table.insert(UISpecialFrames, frame:GetName()) end
    frame.tabs = {}

    frame:SetScript("OnSizeChanged", function(self, width, height)
        for i, tab in ipairs(frame.tabs) do tab:SetSize(width - 8, height - 20) end
    end)

    function frame:ShowTab(id)
        for _, tabContent in pairs(self.tabs) do tabContent:Hide() end
        if self.tabs[id] then self.tabs[id]:Show() end
    end
    -- Titel des Frames
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlight")
    frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 0, 0)
    frame.title:SetText(addonName)
    frame:SetFrameStrata("DIALOG")

    -- Schleife zur Erzeugung der Checkboxen
    addon.frame = frame
    addon.checkboxes = {}
    addon.db = EnhanceQoLDB
    addon.variables.acceptQuestID = {}

    local fTab = addon.functions.createTabFrame(L["General"])
    fTab.tabs = {} -- Add the tabs to switch

    fTab:SetScript("OnSizeChanged", function(self, width, height)
        for i, tab in ipairs(fTab.tabs) do tab:SetSize(width - 5, height - 35) end
    end)
    function fTab:ShowTab(id)
        for _, tabContent in pairs(self.tabs) do tabContent:Hide() end
        if self.tabs[id] then self.tabs[id]:Show() end
    end

    -- character
    addCharacterFrame(fTab)
    -- cvar
    addCVarFrame(fTab)
    -- dungeon
    addDungeonFrame(fTab)
    -- Misc
    addMiscFrame(fTab)
    -- quest
    addQuestFrame(fTab)

    -- Slash-Command hinzufügen
    SLASH_ENHANCEQOL1 = "/eqol"
    SLASH_ENHANCEQOL2 = "/eqol resetframe"
    SlashCmdList["ENHANCEQOL"] = function(msg)
        if msg == "resetframe" then
            -- Frame zurücksetzen
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", UIParent, "CENTER")
            EnhanceQoLDB.point = "CENTER"
            EnhanceQoLDB.x = 0
            EnhanceQoLDB.y = 0
            print(addonName .. " frame has been reset to the center.")
        else
            if frame:IsShown() then
                frame:Hide()
            else
                frame:Show()
            end
        end
    end

    -- Datenobjekt für den Minimap-Button
    local EnhanceQoLLDB = LDB:NewDataObject("EnhanceQoL",
        {type = "launcher", text = addonName, icon = "Interface\\AddOns\\" .. addonName .. "\\Icons\\Icon.tga", -- Hier kannst du dein eigenes Icon verwenden
         OnClick = function(_, msg)

            if msg == "LeftButton" then
                if frame:IsShown() then
                    frame:Hide()
                else
                    frame:Show()
                end
            end
        end, OnTooltipShow = function(tt)
            tt:AddLine(addonName)
            tt:AddLine(L["Left-Click to show options"])
        end})
    -- Toggle Minimap Button based on settings
    LDBIcon:Register(addonName, EnhanceQoLLDB, EnhanceQoLDB)

    -- Register to addon compartment
    AddonCompartmentFrame:RegisterAddon({text = "Enhance QoL", icon = "Interface\\AddOns\\EnhanceQoL\\Icons\\Icon.tga",
                                         notCheckable = true, func = function(button, menuInputData, menu)
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end, funcOnEnter = function(button)
        MenuUtil.ShowTooltip(button, function(tooltip) tooltip:SetText(L["Left-Click to show options"]) end)
    end, funcOnLeave = function(button) MenuUtil.HideTooltip(button) end})

    function addon.functions.toggleMinimapButton(value)
        if value == false then
            LDBIcon:Show(addonName)
        else
            LDBIcon:Hide(addonName)
        end
    end
    function addon.functions.toggleBagsBar(value)
        if value == false then
            BagsBar:Show()
        else
            BagsBar:Hide()
        end
    end
    addon.functions.toggleBagsBar(addon.db["hideBagsBar"])

    local eventFrame = CreateFrame("Frame")
    eventFrame:SetScript("OnUpdate", function(self)
        addon.functions.toggleMinimapButton(addon.db["hideMinimapButton"])
        self:SetScript("OnUpdate", nil)
    end)

    -- Frame für die Optionen
    local configFrame = CreateFrame("Frame", addonName .. "ConfigFrame", InterfaceOptionsFramePanelContainer)
    configFrame.name = addonName

    -- Button für die Optionen
    local configButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    configButton:SetSize(140, 40)
    configButton:SetPoint("TOPLEFT", 10, -10)
    configButton:SetText("Config")
    configButton:SetScript("OnClick", function()
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end)

    local function SortApplicants(applicants)
        if addon.db["lfgSortByRio"] then
            local function SortApplicantsCB(applicantID1, applicantID2)
                local applicantInfo1 = C_LFGList.GetApplicantInfo(applicantID1);
                local applicantInfo2 = C_LFGList.GetApplicantInfo(applicantID2);

                if (applicantInfo1 == nil) then return false; end

                if (applicantInfo2 == nil) then return true; end

                local _, _, _, _, _, _, _, _, _, _, _, dungeonScore1 =
                    C_LFGList.GetApplicantMemberInfo(applicantInfo1.applicantID, 1);

                local _, _, _, _, _, _, _, _, _, _, _, dungeonScore2 =
                    C_LFGList.GetApplicantMemberInfo(applicantInfo2.applicantID, 1);

                return dungeonScore1 > dungeonScore2;
            end

            table.sort(applicants, SortApplicantsCB);
            LFGListApplicationViewer_UpdateResults(LFGListFrame.ApplicationViewer);
        end
    end

    hooksecurefunc("LFGListUtil_SortApplicants", SortApplicants);

    -- Frame zu den Interface-Optionen hinzufügen
    -- InterfaceOptions_AddCategory(configFrame)
    local category, layout = Settings.RegisterCanvasLayoutCategory(configFrame, configFrame.name);
    Settings.RegisterAddOnCategory(category);
    addon.settingsCategory = category

    -- Frame-Position wiederherstellen
    local function RestorePosition()
        if EnhanceQoLDB.point and EnhanceQoLDB.x and EnhanceQoLDB.y then
            frame:ClearAllPoints()
            frame:SetPoint(EnhanceQoLDB.point, UIParent, EnhanceQoLDB.point, EnhanceQoLDB.x, EnhanceQoLDB.y)
        end
    end

    -- Frame wiederherstellen und überprüfen, wenn das Addon geladen wird
    frame:SetScript("OnShow", function() RestorePosition() end)
end

-- Erstelle ein Frame für Events
local frameLoad = CreateFrame("Frame")

local gossipClicked = {}

local eventHandlers = {["ADDON_LOADED"] = function(arg1)
    if arg1 == addonName then
        if not EnhanceQoLDB then EnhanceQoLDB = {} end

        loadMain()
        EQOL.PersistSignUpNote()
    end
end, ["CURRENCY_DISPLAY_UPDATE"] = function(arg1)
    if arg1 == 2815 then
        local cataclystInfo = C_CurrencyInfo.GetCurrencyInfo(addon.variables.catalystID)
        addon.general.iconFrame.count:SetText(cataclystInfo.quantity)
    end
end, ["ENCHANT_SPELL_COMPLETED"] = function(arg1, arg2)
    if PaperDollFrame:IsShown() and addon.db["showEnchantOnCharframe"] and arg1 == true and arg2 and
        arg2.equipmentSlotIndex then
        C_Timer.After(1, function()
            setIlvlText(addon.variables.itemSlots[arg2.equipmentSlotIndex], arg2.equipmentSlotIndex)
        end)
    end
end, ["DELETE_ITEM_CONFIRM"] = function()
    if addon.db["deleteItemFillDialog"] and StaticPopup1:IsShown() then
        StaticPopup1EditBox:SetText(DELETE_ITEM_CONFIRM_STRING)
    end
end, ["GOSSIP_CLOSED"] = function()
    gossipClicked = {} -- clear all already clicked gossips
end, ["GOSSIP_SHOW"] = function()
    if addon.db["autoChooseQuest"] and not IsShiftKeyDown() then
        if nil ~= UnitGUID("npc") and nil ~= addon.db["ignoredQuestNPC"][addon.functions.getIDFromGUID(UnitGUID("npc"))] then
            return
        end

        local options = C_GossipInfo.GetOptions()

        local aQuests = C_GossipInfo.GetAvailableQuests()

        if C_GossipInfo.GetNumActiveQuests() > 0 then
            for i, quest in pairs(C_GossipInfo.GetActiveQuests()) do
                if quest.isComplete then C_GossipInfo.SelectActiveQuest(quest.questID) end
            end
        end

        if #aQuests > 0 then
            for i, quest in pairs(aQuests) do
                if addon.db["ignoreTrivialQuests"] and quest.isTrivial then
                    -- ignore trivial
                elseif addon.db["ignoreDailyQuests"] and (quest.frequency > 0) then
                    -- ignore daily/weekly
                else
                    C_GossipInfo.SelectAvailableQuest(quest.questID)
                end
            end
        else
            if options and #options == 1 and options[1] and not gossipClicked[options[1].gossipOptionID] then
                gossipClicked[options[1].gossipOptionID] = true
                C_GossipInfo.SelectOption(options[1].gossipOptionID)
            end
        end
    end
end,
                       ["GUILDBANK_UPDATE_MONEY"] = function()
    if addon.db["showDurabilityOnCharframe"] then calculateDurability() end
end, ["LOOT_READY"] = function()
    if addon.db["autoQuickLoot"] and not IsShiftKeyDown() then
        for i = 1, GetNumLootItems() do C_Timer.After(0.1, function() LootSlot(i) end) end
    end
end, ["INSPECT_READY"] = function(arg1) if addon.db["showInfoOnInspectFrame"] then onInspect(arg1) end end,
                       ["MERCHANT_SHOW"] = function()
    if addon.db["autoRepair"] then
        if CanMerchantRepair() then
            local repairAllCost = GetRepairAllCost()
            if repairAllCost and repairAllCost > 0 then
                RepairAllItems()
                PlaySound(SOUNDKIT.ITEM_REPAIR)
                print(L["repairCost"] .. addon.functions.formatMoney(repairAllCost))
            end
        end
    end

    if addon.db["sellAllJunk"] and MerchantSellAllJunkButton:IsEnabled() then
        MerchantSellAllJunkButton:Click()
        if StaticPopup1 and StaticPopup1:IsShown() then StaticPopup1.button1:Click() end
    end
end, ["PLAYER_CHOICE_UPDATE"] = function()
    if select(3, GetInstanceInfo()) == 208 and addon.db["autoChooseDelvePower"] then
        local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo()
        if choiceInfo and choiceInfo.options and #choiceInfo.options == 1 then
            C_PlayerChoice.SendPlayerChoiceResponse(choiceInfo.options[1].buttons[1].id)
            if PlayerChoiceFrame:IsShown() then PlayerChoiceFrame:Hide() end
        end
    end
end, ["PLAYER_DEAD"] = function() if addon.db["showDurabilityOnCharframe"] then calculateDurability() end 
end, ["PLAYER_EQUIPMENT_CHANGED"] = function(arg1)
    if addon.variables.itemSlots[arg1] and PaperDollFrame:IsShown() then
        setIlvlText(addon.variables.itemSlots[arg1], arg1)
    end
    if addon.db["showDurabilityOnCharframe"] then calculateDurability() end
end, ["PLAYER_INTERACTION_MANAGER_FRAME_SHOW"] = function(arg1)
    if arg1 == 53 and addon.db["openCharframeOnUpgrade"] then
        if CharacterFrame:IsShown() == false then ToggleCharacter("PaperDollFrame") end
    end
end, ["PLAYER_MONEY"] = function() if addon.db["showDurabilityOnCharframe"] then calculateDurability() end end,
                       ["PLAYER_REGEN_ENABLED"] = function()
    if addon.db["showDurabilityOnCharframe"] then calculateDurability() end
end, ["PLAYER_UNGHOST"] = function() if addon.db["showDurabilityOnCharframe"] then calculateDurability() end end,
                       ["QUEST_COMPLETE"] = function()
    if addon.db["autoChooseQuest"] and not IsShiftKeyDown() then
        local numQuestRewards = GetNumQuestChoices()
        if numQuestRewards > 0 then

        else
            GetQuestReward()
        end
    end
end, ["QUEST_DATA_LOAD_RESULT"] = function(arg1)
    if arg1 and addon.variables.acceptQuestID[arg1] and addon.db["autoChooseQuest"] then
        if nil ~= UnitGUID("npc") and nil ~= addon.db["ignoredQuestNPC"][addon.functions.getIDFromGUID(UnitGUID("npc"))] then
            return
        end
        if addon.db["ignoreDailyQuests"] and C_QuestLog.IsQuestRepeatableType(arg1) then return end

        if addon.db["ignoreTrivialQuests"] and C_QuestLog.IsQuestTrivial(arg1) then return end
        AcceptQuest()
        if QuestFrame:IsShown() then QuestFrame:Hide() end -- Sometimes the frame is still stuck - hide it forcefully than
    end
end, ["QUEST_DETAIL"] = function()
    if addon.db["autoChooseQuest"] and not IsShiftKeyDown() then
        if nil ~= UnitGUID("npc") and nil ~= addon.db["ignoredQuestNPC"][addon.functions.getIDFromGUID(UnitGUID("npc"))] then
            return
        end

        local id = GetQuestID()
        addon.variables.acceptQuestID[id] = true
        C_QuestLog.RequestLoadQuestByID(id)
    end
end, ["QUEST_GREETING"] = function()
    if addon.db["autoChooseQuest"] and not IsShiftKeyDown() then
        if nil ~= UnitGUID("npc") and nil ~= addon.db["ignoredQuestNPC"][addon.functions.getIDFromGUID(UnitGUID("npc"))] then
            return
        end
        for i = 1, GetNumAvailableQuests() do
            if addon.db["ignoreTrivialQuests"] and IsAvailableQuestTrivial(i) then
            else
                SelectAvailableQuest(i)
            end
        end
        for i = 1, GetNumActiveQuests() do if select(2, GetActiveTitle(1)) then SelectActiveQuest(1) end end
    end
end, ["QUEST_PROGRESS"] = function()
    if addon.db["autoChooseQuest"] and not IsShiftKeyDown() and IsQuestCompletable() then CompleteQuest() end
end, ["SOCKET_INFO_ACCEPT"] = function()
    if PaperDollFrame:IsShown() and addon.db["showGemsOnCharframe"] then
        C_Timer.After(0.5, function() setCharFrame() end)
    end
end, ["ZONE_CHANGED_NEW_AREA"] = function()
    if addon.variables.hookedOrderHall == false then
        local ohcb = OrderHallCommandBar
        if ohcb then
            ohcb:HookScript("OnShow", function(self)
                if addon.db["hideOrderHallBar"] then
                    self:Hide()
                else
                    self:Show()
                end
            end)
            addon.variables.hookedOrderHall = true
            if addon.db["hideOrderHallBar"] then OrderHallCommandBar:Hide() end
        end
    end
end}

local function registerEvents(frame) for event in pairs(eventHandlers) do frame:RegisterEvent(event) end end

local function eventHandler(self, event, ...)
    if eventHandlers[event] then
        if addon.Performance and addon.Performance.MeasurePerformance then
            addon.Performance.MeasurePerformance(addonName, event, eventHandlers[event], ...)
        else
            -- Normale Event-Verarbeitung
            eventHandlers[event](...)
        end
        -- if eventHandlers[event] then 
        -- eventHandlers[event](...) 
    end
end

registerEvents(frameLoad)
frameLoad:SetScript("OnEvent", eventHandler)

local addonName, addon = ...
local L = addon.L
-- Bibliotheken laden
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

local function onInspect(arg1)
    if nil == InspectFrame then return end
    local unit = nil
    if not unit and UnitGUID("target") == arg1 then unit = "target" end
    if not unit then unit = GetUnitFromGUID(arg1) end
    if not unit then return end

    local pdElement = InspectFrame
    if not doneHook then
        doneHook = true
        InspectFrame:HookScript("OnHide", function(self) inspectDone = {} end)
    end
    if inspectUnit ~= UnitGUID(unit) then
        inspectUnit = UnitGUID(unit)
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
    local itemCount = 0
    local ilvlSum = 0
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
                                else
                                    element.enchant:SetPoint("BOTTOMRIGHT", element, "BOTTOMLEFT", -2, 1)
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

                            if foundEnchant == false then element.enchant:SetText("") end
                            tooltip:Hide()
                        else
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

                    if foundEnchant == false then element.enchant:SetText("") end
                    tooltip:Hide()
                else
                    element.enchant:SetText("")
                end
            end)
        else
            element.ilvl:SetFormattedText("")
            element.ilvlBackground:Hide()
            element.enchant:SetText("")
        end
    end
end

local function setCharFrame() for key, value in pairs(addon.variables.itemSlots) do setIlvlText(value, key) end end

local function addDungeonFrame(tab)
    if nil == addon.db["autoChooseDelvePower"] then addon.db["autoChooseDelvePower"] = true end
    if nil == addon.db["lfgSortByRio"] then addon.db["lfgSortByRio"] = true end

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

local function addCharacterFrame(tab)
    if nil == addon.db["showIlvlOnCharframe"] then addon.db["showIlvlOnCharframe"] = false end
    if nil == addon.db["showGemsOnCharframe"] then addon.db["showGemsOnCharframe"] = false end
    if nil == addon.db["showEnchantOnCharframe"] then addon.db["showEnchantOnCharframe"] = false end
    if nil == addon.db["showCatalystChargesOnCharframe"] then addon.db["showCatalystChargesOnCharframe"] = false end
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
        fCharacter, L["showCatalystChargesOnCharframe"], 10, (addon.functions.getHeightOffset(cbShowEnchantCharframe)) -
            10)
    cbshowCatalystChargesOnCharframe:SetScript("OnClick", function(self)
        addon.db["showCatalystChargesOnCharframe"] = self:GetChecked()
        if self:GetChecked() then
            addon.general.iconFrame:Show()
        else
            addon.general.iconFrame:Hide()
        end
    end)

    if addon.db["showCatalystChargesOnCharframe"] == false then addon.general.iconFrame:Hide() end

    for key, value in pairs(addon.variables.itemSlots) do
        -- Hintergrund für das Item-Level
        value.ilvlBackground = value:CreateTexture(nil, "BACKGROUND")
        value.ilvlBackground:SetColorTexture(0, 0, 0, 0.8) -- Schwarzer Hintergrund mit 80% Transparenz
        value.ilvlBackground:SetPoint("TOPRIGHT", value, "TOPRIGHT", 1, 1)
        value.ilvlBackground:SetSize(30, 16) -- Größe des Hintergrunds (muss ggf. angepasst werden)

        -- Text für das Item-Level
        value.ilvl = value:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        value.ilvl:SetPoint("TOPRIGHT", value.ilvlBackground, "TOPRIGHT", -1, -2) -- Position des Textes im Zentrum des Hintergrunds
        value.ilvl:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE") -- Setzt die Schriftart, -größe und -stil (OUTLINE)

        value.enchant = value:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        if addon.variables.itemSlotSide[key] == 0 then
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

    local labelClassSpecific = addon.functions.createLabel(fCharacter, L["headerClassInfo"], 0, (addon.functions
        .getHeightOffset(cbshowCatalystChargesOnCharframe)) - 20, "TOP", "TOP")

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

-- @dubug@
-- /dump PlayerFrame.PlayerFrameContainer.PlayerPortrait:Hide()
-- /dump PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:Hide()
-- /dump PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon:Hide()
-- /dump PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop:Hide()
-- /dump PlayerFrame.PlayerFrameContainer.FrameTexture:Hide()
-- /dump PlayerFrame.PlayerFrameContainer.FrameTexture:Show()

-- PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon:HookScript("OnShow", function(self)
--     self:Hide()
-- end)
-- PlayerFrame.PlayerFrameContainer.PlayerPortrait:Hide()
-- PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon:Hide()
-- PlayerFrame.PlayerFrameContainer.PlayerPortraitMask:Hide()
-- PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop:Hide()
-- @end-dubug@
local function addMiscFrame(tab)
    if nil == addon.db["deleteItemFillDialog"] then addon.db["deleteItemFillDialog"] = false end
    if nil == addon.db["hideRaidTools"] then addon.db["hideRaidTools"] = false end
    if nil == addon.db["autoRepair"] then addon.db["autoRepair"] = false end
    if nil == addon.db["sellAllJunk"] then addon.db["sellAllJunk"] = false end
    if nil == addon.db["ignoreTalkingHead"] then addon.db["ignoreTalkingHead"] = true end

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
    local cbQuickLoot = addon.functions.createCheckbox("autoQuickLoot", fMisc, L["autoQuickLoot"], 10,
        (addon.functions.getHeightOffset(cbHideRaidTools)))
end

local function addQuestFrame(tab)
    if nil == addon.db["autoChooseQuest"] then addon.db["autoChooseQuest"] = false end
    if nil == addon.db["ignoreTrivialQuests"] then addon.db["ignoreTrivialQuests"] = true end
    if nil == addon.db["ignoreDailyQuests"] then addon.db["ignoreDailyQuests"] = true end
    local fQuest = addon.functions.createTabFrameMain(L["Quest"], tab)

    local cbAutoChooseQuest = addon.functions.createCheckbox("autoChooseQuest", fQuest, L["autoChooseQuest"], 10, -10)
    local cbIgnoreDailyQuests = addon.functions.createCheckbox("ignoreDailyQuests", fQuest, L["ignoreDailyQuests"], 10,
        (addon.functions.getHeightOffset(cbAutoChooseQuest)))
    local cbIgnoreTrivialQuests = addon.functions.createCheckbox("ignoreTrivialQuests", fQuest,
        L["ignoreTrivialQuests"], 10, (addon.functions.getHeightOffset(cbIgnoreDailyQuests)))
end

function loadMain()

    -- Erstelle das Hauptframe
    local frame = CreateFrame("Frame", "EnhanceQoLMainFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(500, 550)

    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
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
    frame:Hide() -- Das Frame wird initial versteckt
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

    if nil == addon.db["hideMinimapButton"] then addon.db["hideMinimapButton"] = false end

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

-- Funktion zum Umgang mit Events
local function eventHandler(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Dein Code zur Initialisierung der Datenbank
        if not EnhanceQoLDB then EnhanceQoLDB = {} end

        loadMain()
        EQOL.PersistSignUpNote()
    elseif event == "MERCHANT_SHOW" then
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
    elseif event == "PLAYER_EQUIPMENT_CHANGED" and addon.variables.itemSlots[arg1] and PaperDollFrame:IsShown() then
        setIlvlText(addon.variables.itemSlots[arg1], arg1)
    elseif event == "SOCKET_INFO_ACCEPT" and PaperDollFrame:IsShown() and addon.db["showGemsOnCharframe"] then
        C_Timer.After(0.5, function() setCharFrame() end)
    elseif event == "ENCHANT_SPELL_COMPLETED" and PaperDollFrame:IsShown() and addon.db["showEnchantOnCharframe"] then
        if arg1 == true and arg2 and arg2.equipmentSlotIndex then
            C_Timer.After(1, function()
                setIlvlText(addon.variables.itemSlots[arg2.equipmentSlotIndex], arg2.equipmentSlotIndex)
            end)
        end
    elseif event == "GOSSIP_SHOW" and addon.db["autoChooseQuest"] and not IsShiftKeyDown() then
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

    elseif event == "GOSSIP_CLOSED" then
        gossipClicked = {} -- clear all already clicked gossips
    elseif event == "LOOT_READY" and addon.db["autoQuickLoot"] and not IsShiftKeyDown() then
        for i = 1, GetNumLootItems() do C_Timer.After(0.1, function() LootSlot(i) end) end
    elseif event == "QUEST_DETAIL" and addon.db["autoChooseQuest"] and not IsShiftKeyDown() then
        local id = GetQuestID()
        addon.variables.acceptQuestID[id] = true
        C_QuestLog.RequestLoadQuestByID(id)
    elseif event == "QUEST_DATA_LOAD_RESULT" and arg1 and addon.variables.acceptQuestID[arg1] and
        addon.db["autoChooseQuest"] then

        if addon.db["ignoreDailyQuests"] and C_QuestLog.IsQuestRepeatableType(arg1) then return end

        if addon.db["ignoreTrivialQuests"] and C_QuestLog.IsQuestTrivial(arg1) then return end
        AcceptQuest()
        if QuestFrame:IsShown() then QuestFrame:Hide() end -- Sometimes the frame is still stuck - hide it forcefully than
    elseif event == "QUEST_PROGRESS" and addon.db["autoChooseQuest"] and not IsShiftKeyDown() then
        if IsQuestCompletable() then CompleteQuest() end
    elseif event == "QUEST_COMPLETE" and addon.db["autoChooseQuest"] and not IsShiftKeyDown() then
        local numQuestRewards = GetNumQuestChoices()
        if numQuestRewards > 0 then

        else
            GetQuestReward()
        end
    elseif event == "QUEST_GREETING" and addon.db["autoChooseQuest"] and not IsShiftKeyDown() then
        for i = 1, GetNumAvailableQuests() do
            if addon.db["ignoreTrivialQuests"] and IsAvailableQuestTrivial(i) then
            else
                SelectAvailableQuest(i)
            end
        end
        for i = 1, GetNumActiveQuests() do if select(2, GetActiveTitle(1)) then SelectActiveQuest(1) end end
    elseif event == "PLAYER_CHOICE_UPDATE" and select(3, GetInstanceInfo()) == 208 and addon.db["autoChooseDelvePower"] then
        -- We are in a delve and have a choice for buff - autopick it
        local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo()

        if choiceInfo and choiceInfo.options and #choiceInfo.options == 1 then
            C_PlayerChoice.SendPlayerChoiceResponse(choiceInfo.options[1].buttons[1].id)
            if PlayerChoiceFrame:IsShown() then PlayerChoiceFrame:Hide() end
        end
        -- @debug@
    elseif event == "INSPECT_READY" then
        -- Einbauen einer Prüfung, ob ich den Character schon angeschaut habe, löschen der Liste nach InspectFRAME close
        -- Aktuell kommt es vor, dass die Grafik von Sockeln fehlt
        onInspect(arg1)
        -- elseif event == "CURRENCY_DISPLAY_UPDATE" and arg1 == addon.variables.catalystID then
        -- @end-debug@
    elseif event == "CURRENCY_DISPLAY_UPDATE" and arg1 == 2815 then
        local cataclystInfo = C_CurrencyInfo.GetCurrencyInfo(addon.variables.catalystID)
        addon.general.iconFrame.count:SetText(cataclystInfo.quantity)
        print("Test")
    elseif event == "DELETE_ITEM_CONFIRM" and addon.db["deleteItemFillDialog"] then
        if StaticPopup1:IsShown() then StaticPopup1EditBox:SetText(COMMUNITIES_DELETE_CONFIRM_STRING) end
    end
end

-- Registriere das Event
frameLoad:RegisterEvent("ADDON_LOADED")
frameLoad:RegisterEvent("MERCHANT_SHOW")
frameLoad:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frameLoad:RegisterEvent("SOCKET_INFO_ACCEPT")
frameLoad:RegisterEvent("ENCHANT_SPELL_COMPLETED")
frameLoad:RegisterEvent("DELETE_ITEM_CONFIRM")
frameLoad:RegisterEvent("GOSSIP_SHOW")
frameLoad:RegisterEvent("GOSSIP_CLOSED")

frameLoad:RegisterEvent("QUEST_DETAIL")
frameLoad:RegisterEvent("QUEST_GREETING")
frameLoad:RegisterEvent("QUEST_COMPLETE")
frameLoad:RegisterEvent("QUEST_PROGRESS")
frameLoad:RegisterEvent("QUEST_DATA_LOAD_RESULT")
frameLoad:RegisterEvent("LOOT_READY")
frameLoad:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

frameLoad:RegisterEvent("PLAYER_CHOICE_UPDATE") -- for delves

-- @debug@
frameLoad:RegisterEvent("INSPECT_READY")
-- @end-debug@

-- Setze den Event-Handler
frameLoad:SetScript("OnEvent", eventHandler)

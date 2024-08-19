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
        if panel.selectedResult ~= s.resultID then
            LFGListSearchPanel_SelectResult(panel, s.resultID)
        end
        LFGListSearchPanel_SignUp(panel)
    end
end)

LFGListApplicationDialog:HookScript("OnShow", function(self)
    if not EnhanceQoLDB.skipSignUpDialog then
        return
    end

    if self.SignUpButton:IsEnabled() and not IsShiftKeyDown() then
        self.SignUpButton:Click()
    end
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

local function setIlvlText(element, slot)
    -- Hide all gemslots
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

                            local enchantText = gsub(text:gsub(".*" .. ENCHANTED_TOOLTIP_LINE .. ": ", ""),
                                '(%w%w%w)%w+', '%1')
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
    end
end

local function setCharFrame()
    for key, value in pairs(addon.variables.itemSlots) do
        setIlvlText(value, key)
    end
end

function loadMain()
    -- Erstelle das Hauptframe
    local frame = CreateFrame("Frame", "MyAddonFrame", UIParent, "BasicFrameTemplateWithInset")
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
    frame:Hide() -- Das Frame wird initial versteckt
    frame.tabs = {}

    frame:SetScript("OnSizeChanged", function(self, width, height)
        for i, tab in ipairs(frame.tabs) do
            tab:SetSize(width - 8, height - 20)
        end
    end)

    function frame:ShowTab(id)
        for _, tabContent in pairs(self.tabs) do
            tabContent:Hide()
        end
        if self.tabs[id] then
            self.tabs[id]:Show()
        end
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

    if nil == addon.db["hideRaidTools"] then
        addon.db["hideRaidTools"] = false
    end
    if nil == addon.db["autoRepair"] then
        addon.db["autoRepair"] = false
    end
    if nil == addon.db["sellAllJunk"] then
        addon.db["sellAllJunk"] = false
    end
    if nil == addon.db["ignoreTalkingHead"] then
        addon.db["ignoreTalkingHead"] = true
    end
    if nil == addon.db["showIlvlOnCharframe"] then
        addon.db["showIlvlOnCharframe"] = false
    end
    if nil == addon.db["showGemsOnCharframe"] then
        addon.db["showGemsOnCharframe"] = false
    end
    if nil == addon.db["showEnchantOnCharframe"] then
        addon.db["showEnchantOnCharframe"] = false
    end

    local fTab = addon.functions.createTabFrame("General")
    local header = addon.functions.createHeader(fTab, "General", 0, -10)

    local checkbox = addon.functions.createCheckbox("skipSignUpDialog", fTab, L["Quick signup"], 10,
        (addon.functions.getHeightOffset(header) - 10))

    local checkbox2 = addon.functions.createCheckbox("persistSignUpNote", fTab, L["Persist LFG signup note"], 10,
        (addon.functions.getHeightOffset(checkbox)))

    local checkbox3 = addon.functions.createCheckbox("hideMinimapButton", fTab, L["Hide Minimap Button"], 10,
        (addon.functions.getHeightOffset(checkbox2)))
    checkbox3:SetScript("OnClick", function(self)
        addon.db["hideMinimapButton"] = self:GetChecked()
        addon.functions.toggleMinimapButton(addon.db["hideMinimapButton"])
    end)

    local cbHideRaidTools = addon.functions.createCheckbox("hideRaidTools", fTab, L["Hide Raid Tools"], 10,
        (addon.functions.getHeightOffset(checkbox3)))
    cbHideRaidTools:SetScript("OnClick", function(self)
        addon.db["hideRaidTools"] = self:GetChecked()
        addon.functions.toggleRaidTools(addon.db["hideRaidTools"], _G.CompactRaidFrameManager)
    end)

    local cbIgnoreTalkingHead = addon.functions.createCheckbox("ignoreTalkingHead", fTab, L["ignoreTalkingHead"], 10,
        (addon.functions.getHeightOffset(cbHideRaidTools)))

    _G.CompactRaidFrameManager:SetScript("OnShow", function(self)
        addon.functions.toggleRaidTools(addon.db["hideRaidTools"], self)
    end)

    hooksecurefunc(TalkingHeadFrame, "PlayCurrent", function(self)
        if addon.db["ignoreTalkingHead"] then
            self:Hide()
        end
    end)

    local cbAutoRepair = addon.functions.createCheckbox("autoRepair", fTab, L["autoRepair"], 10,
        (addon.functions.getHeightOffset(cbIgnoreTalkingHead)))

    local cbSellAllJunk = addon.functions.createCheckbox("sellAllJunk", fTab, L["sellAllJunk"], 10,
        (addon.functions.getHeightOffset(cbAutoRepair)))

    local cbShowIlvlCharframe = addon.functions.createCheckbox("showIlvlOnCharframe", fTab, L["showIlvlOnCharframe"],
        10, (addon.functions.getHeightOffset(cbSellAllJunk)) - 10)
    cbShowIlvlCharframe:SetScript("OnClick", function(self)
        addon.db["showIlvlOnCharframe"] = self:GetChecked()
        setCharFrame()
    end)
    local cbShowGemsCharframe = addon.functions.createCheckbox("showGemsOnCharframe", fTab, L["showGemsOnCharframe"],
        10, (addon.functions.getHeightOffset(cbShowIlvlCharframe)) - 10)
    cbShowGemsCharframe:SetScript("OnClick", function(self)
        addon.db["showGemsOnCharframe"] = self:GetChecked()
        setCharFrame()
    end)
    local cbShowEnchantCharframe = addon.functions.createCheckbox("showEnchantOnCharframe", fTab,
        L["showEnchantOnCharframe"], 10, (addon.functions.getHeightOffset(cbShowGemsCharframe)) - 10)
    cbShowEnchantCharframe:SetScript("OnClick", function(self)
        addon.db["showEnchantOnCharframe"] = self:GetChecked()
        setCharFrame()
    end)

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
        elseif addon.variables.itemSlotSide[key] == 1 then
            value.enchant:SetPoint("BOTTOMRIGHT", value, "BOTTOMLEFT", -2, 1)
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

    PaperDollFrame:HookScript("OnShow", function(self)
        setCharFrame()
    end)

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
    local EnhanceQoLLDB = LDB:NewDataObject("EnhanceQoL", {
        type = "launcher",
        text = addonName,
        icon = "Interface\\AddOns\\" .. addonName .. "\\Icons\\Icon.tga", -- Hier kannst du dein eigenes Icon verwenden
        OnClick = function(_, msg)

            if msg == "LeftButton" then
                if frame:IsShown() then
                    frame:Hide()
                else
                    frame:Show()
                end
            end
        end,
        OnTooltipShow = function(tt)
            tt:AddLine(addonName)
            tt:AddLine(L["Left-Click to show options"])
        end
    })
    -- Toggle Minimap Button based on settings
    LDBIcon:Register(addonName, EnhanceQoLLDB, EnhanceQoLDB)

    -- Register to addon compartment
    AddonCompartmentFrame:RegisterAddon({
        text = "Enhance QoL",
        icon = "Interface\\AddOns\\EnhanceQoL\\Icons\\Icon.tga",
        notCheckable = true,
        func = function(button, menuInputData, menu)
            if frame:IsShown() then
                frame:Hide()
            else
                frame:Show()
            end
        end,
        funcOnEnter = function(button)
            MenuUtil.ShowTooltip(button, function(tooltip)
                tooltip:SetText(L["Left-Click to show options"])
            end)
        end,
        funcOnLeave = function(button)
            MenuUtil.HideTooltip(button)
        end
    })

    if nil == addon.db["hideMinimapButton"] then
        addon.db["hideMinimapButton"] = false
    end

    function addon.functions.toggleMinimapButton(value)
        if value == false then
            LDBIcon:Show(addonName)
        else
            LDBIcon:Hide(addonName)
        end
    end

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
    frame:SetScript("OnShow", function()
        RestorePosition()
    end)
end

-- Erstelle ein Frame für Events
local frameLoad = CreateFrame("Frame")

-- Funktion zum Umgang mit Events
local function eventHandler(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Dein Code zur Initialisierung der Datenbank
        if not EnhanceQoLDB then
            EnhanceQoLDB = {}
        end

        loadMain()
        EQOL.PersistSignUpNote()
    elseif type(addon.functions.updateAvailableDrinks) == "function" then
        -- functions for DrinkMacro
        if event == "BAG_UPDATE_DELAYED" then
            addon.functions.updateAvailableDrinks(false)
        elseif event == "PLAYER_LOGIN" then
            -- on login always load the macro
            addon.functions.updateAllowedDrinks()
            addon.functions.updateAvailableDrinks(false)
        elseif event == "PLAYER_REGEN_ENABLED" then
            -- PLAYER_REGEN_ENABLED always load, because we don't know if something changed in Combat
            addon.functions.updateAvailableDrinks(true)
        elseif event == "PLAYER_LEVEL_UP" then
            -- on level up, reload the complete list of allowed drinks
            addon.functions.updateAllowedDrinks()
            addon.functions.updateAvailableDrinks(true)
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
                if StaticPopup1 and StaticPopup1:IsShown() then
                    StaticPopup1.button1:Click()
                end
            end
        elseif event == "PLAYER_EQUIPMENT_CHANGED" and PaperDollFrame:IsShown() then
            setIlvlText(addon.variables.itemSlots[arg1], arg1)
        elseif event == "SOCKET_INFO_ACCEPT" and PaperDollFrame:IsShown() and addon.db["showGemsOnCharframe"] then
            C_Timer.After(0.5, function()
                setCharFrame()
            end)
        elseif event == "ENCHANT_SPELL_COMPLETED" and PaperDollFrame:IsShown() and addon.db["showEnchantOnCharframe"] then
            if arg1 == true and arg2 and arg2.equipmentSlotIndex then
                C_Timer.After(1, function()
                    setIlvlText(addon.variables.itemSlots[arg2.equipmentSlotIndex], arg2.equipmentSlotIndex)
                end)
            end
        end
    end
end

-- Registriere das Event
frameLoad:RegisterEvent("ADDON_LOADED")
frameLoad:RegisterEvent("PLAYER_LOGIN")
frameLoad:RegisterEvent("PLAYER_REGEN_ENABLED")
frameLoad:RegisterEvent("PLAYER_LEVEL_UP")
frameLoad:RegisterEvent("BAG_UPDATE_DELAYED")
frameLoad:RegisterEvent("MERCHANT_SHOW")
frameLoad:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frameLoad:RegisterEvent("SOCKET_INFO_ACCEPT")
frameLoad:RegisterEvent("ENCHANT_SPELL_COMPLETED")

-- Setze den Event-Handler
frameLoad:SetScript("OnEvent", eventHandler)

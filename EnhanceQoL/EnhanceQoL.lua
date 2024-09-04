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
    local fDungeon = addon.functions.createTabFrameMain(L["Dungeon"], tab)

    local cbPersistSignUpNote = addon.functions.createCheckbox("persistSignUpNote", fDungeon,
        L["Persist LFG signup note"], 10, -10)

    local cbSkipSignup = addon.functions.createCheckbox("skipSignUpDialog", fDungeon, L["Quick signup"], 10,
        (addon.functions.getHeightOffset(cbPersistSignUpNote)))

    local cbAutoChooseDelvePower = addon.functions.createCheckbox("autoChooseDelvePower", fDungeon,
        L["autoChooseDelvePower"], 10, (addon.functions.getHeightOffset(cbSkipSignup)))
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

local function addCharacterFrame(tab)
    if nil == addon.db["showIlvlOnCharframe"] then addon.db["showIlvlOnCharframe"] = false end
    if nil == addon.db["showGemsOnCharframe"] then addon.db["showGemsOnCharframe"] = false end
    if nil == addon.db["showEnchantOnCharframe"] then addon.db["showEnchantOnCharframe"] = false end
    local fCharacter = addon.functions.createTabFrameMain(L["Character"], tab)

    local cbShowIlvlCharframe = addon.functions.createCheckbox("showIlvlOnCharframe", fCharacter,
        L["showIlvlOnCharframe"], 10, -10)
    cbShowIlvlCharframe:SetScript("OnClick", function(self)
        addon.db["showIlvlOnCharframe"] = self:GetChecked()
        setCharFrame()
    end)
    local cbShowGemsCharframe = addon.functions.createCheckbox("showGemsOnCharframe", fCharacter,
        L["showGemsOnCharframe"], 10, (addon.functions.getHeightOffset(cbShowIlvlCharframe)) - 10)
    cbShowGemsCharframe:SetScript("OnClick", function(self)
        addon.db["showGemsOnCharframe"] = self:GetChecked()
        setCharFrame()
    end)
    local cbShowEnchantCharframe = addon.functions.createCheckbox("showEnchantOnCharframe", fCharacter,
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

    PaperDollFrame:HookScript("OnShow", function(self) setCharFrame() end)

    -- @debug@
    local labelClassSpecific = addon.functions.createLabel(fCharacter, L["headerClassInfo"], 0, (addon.functions
        .getHeightOffset(cbShowEnchantCharframe)) - 20, "TOP", "TOP")

    local classname = select(2, UnitClass("player"))

    -- Classspecific stuff
    if classname == "EVOKER" then
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
    elseif classname == "SHAMAN" then
        local cbHideTotemFrame = addon.functions.createCheckbox("shaman_HideTotem", fCharacter, L["shaman_HideTotem"],
            10, (addon.functions.getHeightOffset(labelClassSpecific)) - 10)
        cbHideTotemFrame:SetScript("OnClick", function(self)
            addon.db["shaman_HideTotem"] = self:GetChecked()
            if self:GetChecked() then
                TotemFrame:Hide()
            else
                TotemFrame:Show()
            end
        end)
        TotemFrame:HookScript("OnShow", function(self)
            if addon.db["shaman_HideTotem"] then
                TotemFrame:Hide()
            else
                TotemFrame:Show()
            end
        end)
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
        if addon.db["paladin_HideHolyPower"] then PaladinPowerBarFrame:Hide() end
    else
        labelClassSpecific:Hide()
    end
    -- @end-debug@
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

    local cbMinimapHide = addon.functions.createCheckbox("hideMinimapButton", fMisc, L["Hide Minimap Button"], 10,
        (addon.functions.getHeightOffset(cbDeleteItemFill)))
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

        for i = 1, GetNumActiveQuests() do
            if select(2, GetActiveTitle(1)) then
                SelectActiveQuest(1)
            end
        end
    elseif event == "PLAYER_CHOICE_UPDATE" and select(3, GetInstanceInfo()) == 208 and addon.db["autoChooseDelvePower"] then
        -- We are in a delve and have a choice for buff - autopick it
        local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo()

        if choiceInfo and choiceInfo.options and #choiceInfo.options == 1 then
            C_PlayerChoice.SendPlayerChoiceResponse(choiceInfo.options[1].buttons[1].id)
            if PlayerChoiceFrame:IsShown() then PlayerChoiceFrame:Hide() end
        end
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

frameLoad:RegisterEvent("PLAYER_CHOICE_UPDATE") -- for delves

-- Setze den Event-Handler
frameLoad:SetScript("OnEvent", eventHandler)

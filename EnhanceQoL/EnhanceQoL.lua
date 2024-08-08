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

function loadMain()
    -- Erstelle das Hauptframe
    local frame = CreateFrame("Frame", "MyAddonFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(300, 550)
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

    local fTab = addon.functions.createTabFrame("General")
    local header = addon.functions.createHeader(fTab, "General", 0, -10)

    local checkbox = addon.functions.createCheckbox("skipSignUpDialog", fTab, L["Quick signup"], 10,
        (addon.functions.getHeightOffset(header) - 10))

    local checkbox2 = addon.functions.createCheckbox("persistSignUpNote", fTab, L["Persist LFG signup note"], 10,
        (addon.functions.getHeightOffset(checkbox)))

    local checkbox3 = addon.functions.createCheckbox("hideMinimapButton", fTab, L["Hide Minimap Button"], 10,
        (addon.functions.getHeightOffset(checkbox2)))

    -- Funktion zum Abrufen der Checkbox-Werte
    local function getCheckboxValues(self)
        local oldKey = {}
        for i, checkbox in ipairs(addon.checkboxes) do
            EnhanceQoLDB[checkbox:GetName()] = checkbox:GetChecked()
            if(checkbox:GetName() == "hideMinimapButton") then
                addon.functions.toggleMinimapButton(addon.db["hideMinimapButton"])
            end
        end

        for key, value in pairs(addon.saveVariables) do
            EnhanceQoLDB[key] = value
        end

        if type(addon.functions.updateAvailableDrinks) == "function" then
            -- Update allowed drinks because of changed mana value
            addon.functions.updateAllowedDrinks()
            addon.functions.updateAvailableDrinks(false)
        end

        self:GetParent():Hide()
    end

    -- Button zum Abrufen der Checkbox-Werte
    local button = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    button:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
    button:SetSize(140, 40)
    button:SetText(L["Save"])
    button:SetNormalFontObject("GameFontNormalLarge")
    button:SetHighlightFontObject("GameFontHighlightLarge")
    button:SetScript("OnClick", getCheckboxValues)

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

    --Register to addon compartment
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
        end,
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
local function eventHandler(self, event, arg1)
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
        end
    end
end

-- Registriere das Event
frameLoad:RegisterEvent("ADDON_LOADED")
frameLoad:RegisterEvent("PLAYER_LOGIN")
frameLoad:RegisterEvent("PLAYER_REGEN_ENABLED")
frameLoad:RegisterEvent("PLAYER_LEVEL_UP")
frameLoad:RegisterEvent("BAG_UPDATE_DELAYED")

-- Setze den Event-Handler
frameLoad:SetScript("OnEvent", eventHandler)

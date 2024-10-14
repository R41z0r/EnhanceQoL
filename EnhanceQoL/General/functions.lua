local addonName, addon = ...

addon.functions = {}
-- Checkboxen erstellen
function addon.functions.createCheckbox(name, parent, label, x, y)
    local checkbox = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox:SetChecked(addon.db["" .. name])
    checkbox:SetScript("OnClick", function(self)
        addon.db["" .. name] = self:GetChecked()
    end)
    getglobal(checkbox:GetName() .. 'Text'):SetText(label)
    table.insert(addon.checkboxes, checkbox)
    return checkbox
end

function addon.functions.createSlider(id, parent, label, x, y, initial, min, max, addText)
    local slider = CreateFrame("Slider", id, parent, "OptionsSliderTemplate")
    slider:SetOrientation('HORIZONTAL')
    slider:SetSize(200, 20)
    slider:SetMinMaxValues(min, max)
    if nil == initial then
        initial = 50
    end
    slider:SetValue(initial)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    slider:ClearAllPoints()
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    slider:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -x, y)

    _G[slider:GetName() .. 'Low']:SetText("" .. min .. addText)
    _G[slider:GetName() .. 'High']:SetText(max .. addText)
    _G[slider:GetName() .. 'Text']:SetText(label .. ': ' .. initial .. addText)

    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        _G[self:GetName() .. 'Text']:SetText(label .. ': ' .. value .. addText)
        addon.db[id] = value
    end)
    return slider
end

function addon.functions.createHeader(parent, label, x, y)
    local header = parent:CreateFontString(nil, "OVERLAY")
    header:SetFontObject("GameFontHighlightLarge")
    header:SetPoint("TOP", parent, "TOP", x, y)
    header:SetText(label)
    return header
end

function addon.functions.createTabButton(parent, id, text)
    local tab = CreateFrame("Button", nil, parent,
        C_EditMode and "CharacterFrameTabTemplate" or "CharacterFrameTabButtonTemplate")
    tab:SetID(id)
    tab:SetText(text)
    tab:SetScript("OnClick", function(self)
        PanelTemplates_SetTab(parent, self:GetID())
        parent:ShowTab(self:GetID())
    end)
    return tab
end

function addon.functions.createTabFrame(text)
    addon.variables.numOfTabs = addon.variables.numOfTabs + 1
    local tab1 = addon.functions.createTabButton(addon.frame, addon.variables.numOfTabs, text)
    tab1:SetPoint("TOPLEFT", addon.frame, "BOTTOMLEFT", 5, 7)

    PanelTemplates_SetNumTabs(addon.frame, addon.variables.numOfTabs)
    PanelTemplates_SetTab(addon.frame, 1)

    addon.frame.tabs[addon.variables.numOfTabs] = CreateFrame("Frame", nil, addon.frame, "InsetFrameTemplate")
    addon.frame.tabs[addon.variables.numOfTabs]:SetSize((addon.frame:GetWidth() - 8), (addon.frame:GetHeight() - 20))
    addon.frame.tabs[addon.variables.numOfTabs]:SetPoint("TOPLEFT", 3, -20)

    if addon.variables.numOfTabs == 1 then
        addon.frame.tabs[addon.variables.numOfTabs]:Show()
    else
        addon.frame.tabs[addon.variables.numOfTabs]:Hide()
    end
    return addon.frame.tabs[addon.variables.numOfTabs]
end

function addon.functions.createTabFrameMain(text, frame)
    addon.general.variables.numOfTabs = addon.general.variables.numOfTabs + 1
    local tab1 = addon.functions.createTabButton(frame, addon.general.variables.numOfTabs, text)
    tab1:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

    PanelTemplates_SetNumTabs(frame, addon.general.variables.numOfTabs)
    PanelTemplates_SetTab(frame, 1)

    frame.tabs[addon.general.variables.numOfTabs] = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    frame.tabs[addon.general.variables.numOfTabs]:SetSize((frame:GetWidth() - 8), (frame:GetHeight() - 20))
    frame.tabs[addon.general.variables.numOfTabs]:SetPoint("TOPLEFT", 3, -2 - (tab1:GetHeight()))

    if addon.general.variables.numOfTabs == 1 then
        frame.tabs[addon.general.variables.numOfTabs]:Show()
    else
        frame.tabs[addon.general.variables.numOfTabs]:Hide()
    end
    return frame.tabs[addon.general.variables.numOfTabs]
end

function addon.functions.getHeightOffset(element)
    local _, _, _, _, headerY = element:GetPoint()
    return headerY - element:GetHeight()
end

function addon.functions.createLabel(frame, text, x, y, anchor, point)
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint(point, frame, anchor, x, y)
    label:SetText(text)
    return label
end

function addon.functions.createDropdown(id, frame, items, width, text, x, y, initial)
    -- Erstelle ein Label
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
    label:SetText(text)

    -- Erstelle ein Dropdown-Menü
    local dropdown = CreateFrame("Frame", "MyDropdown", frame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -16, -10) -- Position relativ zum Label

    -- Initialisiere das Dropdown-Menü
    UIDropDownMenu_SetWidth(dropdown, width)
    UIDropDownMenu_SetText(dropdown, addon.L["Select an option"])
    dropdown:SetFrameStrata("DIALOG")

    -- Funktion zum Erstellen der Menüeinträge
    local function OnClick(self)
        UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
        addon.db[id] = self.value
    end

    local function Initialize(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for i = 1, #items do
            info.text = items[i].text
            info.value = items[i].value
            info.func = OnClick
            info.arg1 = items[i].value
            info.checked = nil
            UIDropDownMenu_AddButton(info, level)
        end
    end
    UIDropDownMenu_SetSelectedID(dropdown, initial)
    UIDropDownMenu_SetText(dropdown, items[initial].text)
    -- Initialisiere das Dropdown-Menü
    UIDropDownMenu_Initialize(dropdown, Initialize)
    return label, dropdown
end

function addon.functions.createButton(parent, x, y, width, height, text, script)
    local button = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    button:SetSize(width, height)
    button:SetText(text)
    button:SetFrameStrata("DIALOG")
    button:SetNormalFontObject("GameFontNormalLarge")
    button:SetHighlightFontObject("GameFontHighlightLarge")
    button:SetScript("OnClick", script)
    return button
end

function addon.functions.toggleRaidTools(value, self)
    if value == false and (UnitInParty("player") or UnitInRaid("player")) then
        self:Show()
    elseif UnitInParty("player") then
        self:Hide()
    end
end

function addon.functions.formatMoney(copper)
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local bronze = copper % 100

    local formatted = ""

    if gold > 0 then
        formatted = string.format("%d|cffffd700g|r ", gold)
    end

    if silver > 0 or gold > 0 then
        formatted = formatted .. string.format("%d|cffc7c7cfs|r ", silver)
    end

    formatted = formatted .. string.format("%d|cffeda55fc|r", bronze)

    return formatted
end

local addonName, addon = ...

addon.functions = {}
-- Checkboxen erstellen
function addon.functions.createCheckbox(name, parent, label, x, y)
    local checkbox = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", x, y)
    getglobal(checkbox:GetName() .. 'Text'):SetText(label)
    table.insert(addon.checkboxes, checkbox)
    return checkbox
end

function addon.functions.createSlider(id, parent, label, x, y, initial)
    local slider = CreateFrame("Slider", "EnhanceQoLSlider", parent, "OptionsSliderTemplate")
    slider:SetOrientation('HORIZONTAL')
    slider:SetSize(200, 20)
    slider:SetMinMaxValues(0, 100)
    if nil == initial then
        initial = 50
    end
    slider:SetValue(initial)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    slider:ClearAllPoints()
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    slider:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -x, y)

    _G[slider:GetName() .. 'Low']:SetText('0%')
    _G[slider:GetName() .. 'High']:SetText('100%')
    _G[slider:GetName() .. 'Text']:SetText(label .. ': ' .. initial .. '%')

    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        _G[self:GetName() .. 'Text']:SetText(label .. ': ' .. value .. '%')
        addon.saveVariables[id] = value
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


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
local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

addon.Vendor = {}
addon.LVendor = {} -- Locales for MythicPlus
addon.Vendor.functions = {}

addon.Vendor.Buttons = {}
addon.Vendor.nrOfButtons = 0
addon.Vendor.variables = {}
addon.Vendor.variables.numOfTabs = 0
local _, avgItemLevelEquipped = GetAverageItemLevel()
addon.Vendor.variables.avgItemLevelEquipped = avgItemLevelEquipped

function addon.Vendor.functions.createTabFrame(text, frame)
    addon.Vendor.variables.numOfTabs = addon.Vendor.variables.numOfTabs + 1
    local tab1 = addon.functions.createTabButton(frame, addon.Vendor.variables.numOfTabs, text)
    tab1:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

    PanelTemplates_SetNumTabs(frame, addon.Vendor.variables.numOfTabs)
    PanelTemplates_SetTab(frame, 1)

    frame.tabs[addon.Vendor.variables.numOfTabs] = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    frame.tabs[addon.Vendor.variables.numOfTabs]:SetSize((frame:GetWidth() - 8), (frame:GetHeight() - 20))
    frame.tabs[addon.Vendor.variables.numOfTabs]:SetPoint("TOPLEFT", 3, -2 - (tab1:GetHeight()))

    if addon.Vendor.variables.numOfTabs == 1 then
        frame.tabs[addon.Vendor.variables.numOfTabs]:Show()
    else
        frame.tabs[addon.Vendor.variables.numOfTabs]:Hide()
    end
    return frame.tabs[addon.Vendor.variables.numOfTabs]
end

addon.Vendor.variables.itemQualityFilter = {} -- Filter for Enable/Disable Qualities
addon.Vendor.variables.itemBindTypeQualityFilter = {} -- Filter for BindType in Quality
addon.Vendor.variables.tabNames = { -- Used to create autosell tabs
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic"
}

-- Includelist
if nil == addon.db["vendorIncludeSellList"] then
    addon.db["vendorIncludeSellList"] = {}
end

addon.Vendor.variables.tabKeyNames = {}
for key in pairs(addon.Vendor.variables.tabNames) do
    table.insert(addon.Vendor.variables.tabKeyNames, key)
end
table.sort(addon.Vendor.variables.tabKeyNames)

for key, value in pairs(addon.Vendor.variables.tabNames) do
    if nil == addon.db["vendor" .. value .. "Enable"] then
        addon.db["vendor" .. value .. "Enable"] = false
    end
    if nil == addon.db["vendor" .. value .. "MinIlvlDif"] then
        addon.db["vendor" .. value .. "MinIlvlDif"] = 200
    end

    if nil == addon.db["vendor" .. value .. "IgnoreWarbound"] then
        addon.db["vendor" .. value .. "IgnoreWarbound"] = true
    end
    if nil == addon.db["vendor" .. value .. "IgnoreBoE"] then
        addon.db["vendor" .. value .. "IgnoreBoE"] = true
    end
    if key ~= 1 then
        if nil == addon.db["vendor" .. value .. "IgnoreUpgradable"] then
            addon.db["vendor" .. value .. "IgnoreUpgradable"] = false
        end
    end

    addon.Vendor.variables.itemQualityFilter[key] = addon.db["vendor" .. value .. "Enable"]
    addon.Vendor.variables.itemBindTypeQualityFilter[key] = {
        [0] = true, -- None
        [1] = true, -- Bind on Pickup
        [2] = not addon.db["vendor" .. value .. "IgnoreBoE"], -- Bind on Equip
        [3] = true, -- Bind on Use
        [4] = false, -- Quest item
        [5] = false, -- Unused 1
        [6] = false, -- Unused 2
        [7] = true, -- Bind to Account
        [8] = not addon.db["vendor" .. value .. "IgnoreWarbound"], -- Bind to Warband
        [9] = not addon.db["vendor" .. value .. "IgnoreWarbound"] -- Bind to Warband
    }
end

addon.Vendor.variables.itemTypeFilter = {
    [2] = true, -- Weapon
    [3] = true, -- Gems
    [4] = true -- Armor
}

-- List to filter specific gems only
addon.Vendor.variables.itemSubTypeFilter = {
    [3] = {
        [11] = true -- Artifact Relic
    }
}

addon.Vendor.variables.upgradePattern = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING:gsub("%%s", "%%a+"):gsub("%%d", "%%d+")

function addon.Vendor.functions.createDropdown(id, frame, items, width, text, x, y)

    table.sort(items, function(a, b)
        return a.text < b.text
    end)

    -- Erstelle ein Label
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
    label:SetText(text)

    -- Erstelle ein Dropdown-Menü
    local dropdown = CreateFrame("Frame", "MyDropdown", frame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -16, -10) -- Position relativ zum Label

    -- Initialisiere das Dropdown-Menü
    UIDropDownMenu_SetWidth(dropdown, 180)
    dropdown:SetFrameStrata("DIALOG")

    local function Initialize(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for i, item in ipairs(items) do
            info.text = item.text
            info.value = item.value
            info.checked = nil
            info.func = function(self)
                UIDropDownMenu_SetSelectedID(dropdown, i)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_SetText(dropdown, "")
    -- Initialisiere das Dropdown-Menü
    UIDropDownMenu_Initialize(dropdown, Initialize)
    return dropdown
end

function addon.Vendor.functions.addDropdownItem(dropdown, items, newItem)
    -- Füge das neue Item zur Items-Tabelle hinzu
    table.insert(items, newItem)

    table.sort(items, function(a, b)
        return a.text < b.text
    end)
    -- Neuinitialisiere das Dropdown-Menü
    local function Initialize(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for i, item in ipairs(items) do
            info.text = item.text
            info.value = item.value
            info.checked = nil
            info.func = function(self)
                UIDropDownMenu_SetSelectedID(dropdown, i)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(dropdown, Initialize)
end

function addon.Vendor.functions.createEditBox(parent, x, y, text)

    local editBox = CreateFrame("EditBox", "EditBox", parent, "InputBoxTemplate")
    editBox:SetSize(180, 20)
    editBox:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(100)
    editBox:SetTextInsets(10, 10, 0, 0)
    editBox:SetText(text)
    editBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == text then
            self:SetText("")
        end
    end)
    editBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self:SetText(text)
        end
    end)
    editBox:SetScript("OnReceiveDrag", function(self)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType == "item" then
            self:SetText(itemID)
            ClearCursor()
        end
    end)

    editBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            local text = self:GetText()
            local filteredText = text:gsub("[^0-9]", "") -- Entfernt alle Zeichen außer Zahlen
            if text ~= filteredText then
                self:SetText(filteredText) -- Setzt den gefilterten Text zurück in die EditBox
                self:SetCursorPosition(#filteredText) -- Setzt den Cursor ans Ende
            end
        end
    end)

    editBox:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            local infoType, itemID, itemLink = GetCursorInfo()
            if infoType == "item" then
                self:SetText(itemID)
                ClearCursor()
            end
        end
    end)

    editBox:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            self:SetText("")
        end
    end)
    editBox:SetScript("OnDragStart", function(self)
        self:SetFocus()
    end)
    editBox:SetScript("OnDragStop", function(self)
        self:ClearFocus()
    end)
    return editBox
end

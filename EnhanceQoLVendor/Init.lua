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
    [4] = true -- Armor
}

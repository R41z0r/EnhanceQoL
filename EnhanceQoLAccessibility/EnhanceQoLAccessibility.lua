local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL_Accessibility")
local AceGUI = addon.AceGUI
local LSM = LibStub("LibSharedMedia-3.0")

addon.variables.statusTable.groups["accessibility"] = true

local fonts = {
    ["Friz Quadrata"] = "Fonts\\FRIZQT__.TTF",
    ["Arial Narrow"] = "Fonts\\ARIALN.TTF",
    ["Morpheus"] = "Fonts\\MORPHEUS.ttf",
    ["Skurri"] = "Fonts\\skurri.ttf",
}
for name, path in pairs(LSM:HashTable("font")) do
    fonts[name] = path
end
addon.Accessibility.fonts = fonts

-- apply saved font
local savedFont = addon.db["accessibilityFont"]
if savedFont and fonts[savedFont] then addon.variables.defaultFont = fonts[savedFont] end

local function addFontFrame(container)
    local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
    container:AddChild(wrapper)

    local group = addon.functions.createContainer("InlineGroup", "List")
    wrapper:AddChild(group)

    local list, order = addon.functions.prepareListForDropdown(fonts, true)
    local drop = addon.functions.createDropdownAce(L["Default Font"], list, order, function(self, _, key)
        addon.db["accessibilityFont"] = key
        addon.variables.defaultFont = fonts[key]
        addon.variables.requireReload = true
        addon.functions.checkReloadFrame()
    end)
    drop:SetValue(addon.db["accessibilityFont"])
    drop:SetWidth(250)
    group:AddChild(drop)
end

local function applyListingColor(entry)
    local color = addon.db["lfgListingColor"]
    if not color or not entry then return end
    if entry.ActivityName then entry.ActivityName:SetTextColor(color.r, color.g, color.b) end
    -- if entry.Name then entry.Name:SetTextColor(color.r, color.g, color.b) end
    -- if entry.Comment then entry.Comment:SetTextColor(color.r, color.g, color.b) end
end

hooksecurefunc("LFGListSearchEntry_Update", applyListingColor)

local function addLFGFrame(container)
    local wrapper = addon.functions.createContainer("SimpleGroup", "Flow")
    container:AddChild(wrapper)

    local group = addon.functions.createContainer("InlineGroup", "List")
    wrapper:AddChild(group)

    local colorPicker = AceGUI:Create("ColorPicker")
    colorPicker:SetLabel(L["Listing description color"])
    local c = addon.db["lfgListingColor"] or { r = 1, g = 1, b = 1 }
    colorPicker:SetColor(c.r, c.g, c.b)
    colorPicker:SetCallback("OnValueChanged", function(widget, event, r, g, b)
        addon.db["lfgListingColor"] = { r = r, g = g, b = b }
    end)
    group:AddChild(colorPicker)
end

addon.functions.addToTree(nil, {
    value = "accessibility",
    text = L["Accessibility"],
    children = {
        { value = "font", text = L["Font"] },
        { value = "lfg", text = L["Dungeon Browser"] },
    },
})

function addon.Accessibility.functions.treeCallback(container, group)
    container:ReleaseChildren()
    if group == "accessibility\001font" then
        addFontFrame(container)
    elseif group == "accessibility\001lfg" then
        addLFGFrame(container)
    end
end

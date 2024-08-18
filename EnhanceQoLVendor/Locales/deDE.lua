if (GAME_LOCALE or GetLocale()) ~= "deDE" then
    return
end
local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LVendor

L["Vendor"] = "Verkäufer"
L["MerchantWindowClosed"] = "Händlerfenster ist geschlossen. Verkauf wird gestoppt"

-- Allgemein
L["vendorMinIlvlDif"] = "Mindestgegenstandsstufe unter meinem Durchschnitt,\num zum automatischen Verkauf markiert zu werden"
L["vendorIgnoreBoE"] = "Beim Anlegen gebundene Gegenstände ignorieren"
L["vendorIgnoreWarbound"] = "Kriegsgebundene Gegenstände ignorieren"

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
    local value = addon.Vendor.variables.tabNames[key]
    L["labelItemQuality" .. value .. "line"] =
        "Dies ermöglicht es Ihnen, " .. ITEM_QUALITY_COLORS[key].hex ..
            _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r Gegenstände\nbasierend auf Filterkriterien beim Händler automatisch zu verkaufen."
    L["vendor" .. value .. "Enable"] = "Automatisches Verkaufen für " .. ITEM_QUALITY_COLORS[key].hex ..
                                           _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r\nGegenstände aktivieren"
end
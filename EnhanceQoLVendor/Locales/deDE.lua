if (GAME_LOCALE or GetLocale()) ~= "deDE" then return end
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
L["vendorMinIlvlDif"] = "Mindestgegenstandsstufe unter meinem Durchschnitt, um zum automatischen Verkauf markiert zu werden"
L["vendorIgnoreBoE"] = "Beim Anlegen gebundene Gegenstände ignorieren"
L["vendorIgnoreWarbound"] = "Kriegsgebundene Gegenstände ignorieren"
L["vendorIgnoreUpgradable"] = "Ignoriere upgradebare Gegenstände"
L["vendorSwapAutoSellShift"] = "Automatisch nur verkaufen, wenn Shift beim Öffnen gehalten wird"
L["vendorOnly12Items"] = "Begrenzt die Anzahl der verkauften Gegenstände pro Transaktion auf 12, um ein einfacheres Zurückkaufen beim Händler zu ermöglichen."

L["IncludeVendorList"] = "Artikelliste"
L["ExcludeVendorList"] = "Artikelliste"
L["Include"] = "Hinzufügen"
L["Exclude"] = "Ausschließen"

L["Add"] = "Hinzufügen"
L["Remove"] = "Entfernen"
L["Item id or drag item"] = "Artikel-ID oder Artikel ziehen"
L["Item id does not exist"] = "Artikel-ID existiert nicht"
L["vendorAddItemToInclude"] = "Fügen Sie Artikel zu dieser Liste hinzu, um sie zum Verkauf einzuschließen. WICHTIG: Dies ignoriert alle anderen Prüfungen für diesen Artikel"
L["vendorAddItemToExclude"] = "Füge Gegenstände zu dieser Liste hinzu, um sie vom Verkauf auszuschließen. WICHTIG: Ausschlüsse haben immer Vorrang, es sei denn, es handelt sich um Müll"

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
	local value = addon.Vendor.variables.tabNames[key]
	L["labelItemQuality" .. value .. "line"] = "Dies ermöglicht es Ihnen, "
		.. ITEM_QUALITY_COLORS[key].hex
		.. _G["ITEM_QUALITY" .. key .. "_DESC"]
		.. "|r Gegenstände basierend auf Filterkriterien beim Händler automatisch zu verkaufen."
	L["vendor" .. value .. "Enable"] = "Automatisches Verkaufen für " .. ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r Gegenstände aktivieren"
	L["labelExplained" .. value .. "line"] = "Das bedeutet, dass automatisch "
		.. ITEM_QUALITY_COLORS[key].hex
		.. _G["ITEM_QUALITY" .. key .. "_DESC"]
		.. "|r Gegenstände mit einer Gegenstandsstufe von %s und niedriger verkauft werden %s"
end

local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LVendor

L["Vendor"] = "Vendor"
L["MerchantWindowClosed"] = "Merchant window is closed. Stopping sales"

-- General
L["vendorMinIlvlDif"] = "Min. ilvl under my average to mark for autosell"
L["vendorIgnoreBoE"] = "Ignore Bind on Equip items"
L["vendorIgnoreWarbound"] = "Ignore Warbound items"
L["vendorIgnoreUpgradable"] = "Ignore Upgradable items"
L["vendorSwapAutoSellShift"] = "Only auto sell when Shift is held on open"
L["vendorOnly12Items"] = "Limits the number of items sold per transaction to 12, allowing easier buyback from the merchant."

L["IncludeVendorList"] = "Itemlist"
L["ExcludeVendorList"] = "Itemlist"
L["Include"] = "Include"
L["Exclude"] = "Exclude"

L["Add"] = "Add"
L["Remove"] = "Remove"
L["Item id or drag item"] = "Item id or drag item"
L["Item id does not exist"] = "Item id does not exist"
L["vendorAddItemToInclude"] = "Add items to this list to include for sale. IMPORTANT: This ignores all other checks for this item"
L["vendorAddItemToExclude"] = "Add items to this list to exclude for sale. IMPORTANT: Exclude wins all the time, unless it's junk"
L["vendorMinIlvl"] = "Mark items with an ilvl below the selected value for autosell"
L["vendorAbsolutIlvl"] = "Use absolute ilvl for selling gear instead of the minimum equipped ilvl"

for _, key in ipairs(addon.Vendor.variables.tabKeyNames) do
	local value = addon.Vendor.variables.tabNames[key]
	L["labelItemQuality" .. value .. "line"] = "This enabled you to automatically sell "
		.. ITEM_QUALITY_COLORS[key].hex
		.. _G["ITEM_QUALITY" .. key .. "_DESC"]
		.. "|r items based on of filter criteria when at a merchant"
	L["vendor" .. value .. "Enable"] = "Enable automatic selling for " .. ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r items"
	L["labelExplained" .. value .. "line"] = "This means it automatically sells " .. ITEM_QUALITY_COLORS[key].hex .. _G["ITEM_QUALITY" .. key .. "_DESC"] .. "|r items with an ilvl of %s and lower %s"
end

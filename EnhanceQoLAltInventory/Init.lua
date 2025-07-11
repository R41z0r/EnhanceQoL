local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

addon.AltInventory = addon.AltInventory or {}
addon.AltInventory.functions = addon.AltInventory.functions or {}

addon.functions.InitDBValue("altInventory", {})

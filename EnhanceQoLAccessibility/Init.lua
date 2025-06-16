local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

addon.Accessibility = {}
addon.Accessibility.functions = {}
addon.LAccessibility = {}

addon.functions.InitDBValue("accessibilityFont", "Friz Quadrata")
addon.functions.InitDBValue("lfgListingColor", { r = 1, g = 1, b = 1 })
addon.functions.InitDBValue("lfgAccessibilityEnabled", true)
addon.functions.InitDBValue("lfgListingColorActivity", { r = 1, g = 1, b = 1 })
addon.functions.InitDBValue("lfgListingColorCustom", { r = 1, g = 1, b = 1 })
addon.functions.InitDBValue("lfgBackgroundColor", { r = 0, g = 0, b = 0 })

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

local parentAddonName = "Raizor"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end

addon.LDrinkMacro = {} --Locales for drink macro
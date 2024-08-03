local parentAddonName = "Raizor"
local addonName, addon = ...
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LDrinkMacro

L["Prefer mage food"] = "Prefer mage food"
L["Minimum mana restore for food"] = "Minimum mana restore for food"
L["Ignore bufffood"] = "Ignore \"Well Fed\" food"
if (GAME_LOCALE or GetLocale()) ~= "deDE" then
    return
end

local parentAddonName = "Raizor"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LDrinkMacro

L["Prefer mage food"] = "Magier-Essen bevorzugen"
L["Minimum mana restore for food"] = "Mindest Manawiederherstellung des Essens"

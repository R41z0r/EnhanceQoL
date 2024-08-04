if (GAME_LOCALE or GetLocale()) ~= "deDE" then
    return
end

local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LDrinkMacro

L["Prefer mage food"] = "Magier-Essen bevorzugen"
L["Minimum mana restore for food"] = "Mindest Manawiederherstellung des Essens"
L["Ignore bufffood"] = "Ignoriere Essen mit \"Gesättigt\" Effekt"
L["Drink Macro"] = "Trink Macro"
L[addonName] = "Trink Macro"

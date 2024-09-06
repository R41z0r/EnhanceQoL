if (GAME_LOCALE or GetLocale()) ~= "frFR" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LDrinkMacro

L["Prefer mage food"] = "Préférer la nourriture de mage"
L["Minimum mana restore for food"] = "Restauration minimale\nde mana pour la nourriture"
L["Ignore bufffood"] = "Ignorer la nourriture \"Bien nourri\""
L["Drink Macro"] = "Macro de boisson"
L[addonName] = "Macro de boisson"
L["ignoreGemsEarthen"] = "Ignorer les gemmes de joaillerie pour la race Terrestres"

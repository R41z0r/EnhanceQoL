if (GAME_LOCALE or GetLocale()) ~= "ptBR" then
    return
end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LDrinkMacro

L["Prefer mage food"] = "Preferir comida de mago"
L["Minimum mana restore for food"] = "Restauro mínimo de\nmana para comida"
L["Ignore bufffood"] = "Ignorar comida com \"Bem Alimentado\""
L["Drink Macro"] = "Macro de beber"
L[addonName] = "Macro de beber"

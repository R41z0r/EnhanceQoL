if (GAME_LOCALE or GetLocale()) ~= "esES" or (GAME_LOCALE or GetLocale()) ~= "esMX" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LDrinkMacro

L["Prefer mage food"] = "Preferir comida de mago"
L["Minimum mana restore for food"] = "Restauración mínima de maná para comida"
L["Ignore bufffood"] = "Ignorar comida \"Bien alimentado\""
L["Drink Macro"] = "Macro de bebida"
L["ignoreGemsEarthen"] = "Ignorar gemas de orfebrería para la raza terránea"

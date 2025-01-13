if (GAME_LOCALE or GetLocale()) ~= "ruRU" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LDrinkMacro

L["Prefer mage food"] = "Предпочитать еду мага"
L["Minimum mana restore for food"] = "Минимальное восстановление маны от еды"
L["Ignore bufffood"] = "Игнорировать еду с баффом \"Сыт\""
L["Drink Macro"] = "Макрос на питье"
L[addonName] = "Макрос на питье"
L["ignoreGemsEarthen"] =
    "Игнорировать самоцветы ювелирного дела для расы земельников"

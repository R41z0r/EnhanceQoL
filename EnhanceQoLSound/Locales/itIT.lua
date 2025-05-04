if (GAME_LOCALE or GetLocale()) ~= "itIT" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LDrinkMacro

L["Prefer mage food"] = "Preferisci il cibo del mago"
L["Minimum mana restore for food"] = "Ripristino minimo di mana per il cibo"
L["Ignore bufffood"] = "Ignora cibo \"Ben Nutrito\""
L["Drink Macro"] = "Macro per bere"
L["ignoreGemsEarthen"] = "Ignora le gemme di oreficeria per la razza dei Terrigeni"

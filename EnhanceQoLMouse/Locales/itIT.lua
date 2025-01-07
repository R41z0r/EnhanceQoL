if (GAME_LOCALE or GetLocale()) ~= "itIT" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMouse

L["mouseRingEnabled"] = "Abilita l'anello visibile attorno al cursore"
L["mouseTrailEnabled"] = "Abilita la scia visibile quando il cursore si muove"
L["Trailinfo"] = "A seconda dell'hardware, ciò potrebbe influire sulle prestazioni"
L["Ring Color"] = "Colore dell'anello"
L["Trail Color"] = "Colore della scia"
L["mouseTrailDensity"] = "Densità della scia del cursore"

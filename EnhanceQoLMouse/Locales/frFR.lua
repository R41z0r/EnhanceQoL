if (GAME_LOCALE or GetLocale()) ~= "frFR" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMouse

L["mouseRingEnabled"] = "Activer l’anneau visible autour du curseur"
L["mouseTrailEnabled"] = "Activer la traînée visible lors du déplacement du curseur"
L["Trailinfo"] = "Selon votre matériel, cela pourrait avoir un impact sur les performances"
L["Ring Color"] = "Couleur de l’anneau"
L["Trail Color"] = "Couleur de la traînée"
L["mouseTrailDensity"] = "Densité de la traînée du curseur"

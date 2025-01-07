if (GAME_LOCALE or GetLocale()) ~= "esES" or (GAME_LOCALE or GetLocale()) ~= "esMX" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMouse

L["mouseRingEnabled"] = "Habilitar anillo visible alrededor del cursor"
L["mouseTrailEnabled"] = "Habilitar rastro visible mientras se mueve el cursor"
L["Trailinfo"] = "Dependiendo de tu hardware, esto podría impactar el rendimiento"
L["Ring Color"] = "Color del anillo"
L["Trail Color"] = "Color del rastro"
L["mouseTrailDensity"] = "Densidad del rastro del ratón"

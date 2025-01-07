if (GAME_LOCALE or GetLocale()) ~= "deDE" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMouse

L["mouseRingEnabled"] = "Sichtbaren Ring um den Mauszeiger aktivieren"
L["mouseTrailEnabled"] = "Sichtbare Spur beim Bewegen des Mauszeigers aktivieren"
L["Trailinfo"] = "Abhängig von deiner Hardware könnte dies Auswirkungen auf die Leistung haben"
L["Ring Color"] = "Ringfarbe"
L["Trail Color"] = "Spurfarbe"
L["mouseTrailDensity"] = "Dichte der Mausspur"
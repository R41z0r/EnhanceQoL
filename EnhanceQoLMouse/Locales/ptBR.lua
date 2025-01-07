if (GAME_LOCALE or GetLocale()) ~= "ptBR" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMouse

L["mouseRingEnabled"] = "Ativar anel visível ao redor do cursor"
L["mouseTrailEnabled"] = "Ativar trilha visível enquanto move o cursor"
L["Trailinfo"] = "Dependendo do seu hardware, isso pode afetar o desempenho"
L["Ring Color"] = "Cor do anel"
L["Trail Color"] = "Cor da trilha"
L["mouseTrailDensity"] = "Densidade da trilha do mouse"

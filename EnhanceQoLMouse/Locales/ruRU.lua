if (GAME_LOCALE or GetLocale()) ~= "ruRU" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMouse

L["mouseRingEnabled"] = "Включить видимое кольцо вокруг курсора"
L["mouseTrailEnabled"] = "Включить видимый след при перемещении курсора"
L["Trailinfo"] = "В зависимости от вашей аппаратуры это может влиять на производительность"
L["Ring Color"] = "Цвет кольца"
L["Trail Color"] = "Цвет следа"
L["mouseTrailDensity"] = "Плотность следа курсора"

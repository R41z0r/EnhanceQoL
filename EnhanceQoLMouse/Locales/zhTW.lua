if (GAME_LOCALE or GetLocale()) ~= "zhTW" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMouse

L["mouseRingEnabled"] = "啟用鼠標指針周圍的可見環"
L["mouseTrailEnabled"] = "啟用移動鼠標時的可見軌跡"
L["Trailinfo"] = "依據您的硬體配置，這可能會影響效能"
L["Ring Color"] = "環的顏色"
L["Trail Color"] = "軌跡顏色"
L["mouseTrailDensity"] = "鼠標軌跡密度"

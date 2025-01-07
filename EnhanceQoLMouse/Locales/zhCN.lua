if (GAME_LOCALE or GetLocale()) ~= "zhCN" then return end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end
local L = addon.LMouse

L["mouseRingEnabled"] = "启用鼠标指针周围的可见环"
L["mouseTrailEnabled"] = "启用鼠标移动时的可见轨迹"
L["Trailinfo"] = "根据您的硬件配置，这可能会影响性能"
L["Ring Color"] = "环的颜色"
L["Trail Color"] = "轨迹颜色"
L["mouseTrailDensity"] = "鼠标轨迹密度"

if (GAME_LOCALE or GetLocale()) ~= "zhCN" then
    return
end

local addonName, addon = ...
local parentAddonName = "EnhanceQoL"
if _G[parentAddonName] then
    addon = _G[parentAddonName]
else
    error(parentAddonName .. " is not loaded")
end
local L = addon.LTooltip

L["Tooltip"] = "工具提示"
L[addonName] = "工具提示"
L["TooltipUnitHideType"] = "在单位上隐藏"
L["None"] = "无"
L["Enemies"] = "敌人"
L["Friendly"] = "友好"
L["Both"] = "两者"
L["TooltipOFF"] = "关闭"
L["TooltipON"] = "开启"

L["TooltipUnitHideInCombat"] = "仅在战斗中隐藏单位"
L["TooltipUnitHideInDungeon"] = "仅在地下城中隐藏单位"

--Spell
L["TooltipSpellHideType"] = "在法术上隐藏"

L["TooltipSpellHideInCombat"] = "仅在战斗中隐藏法术"
L["TooltipSpellHideInDungeon"] = "仅在地下城中隐藏法术"

--Item
L["TooltipItemHideType"] = "在物品上隐藏"

L["TooltipItemHideInCombat"] = "仅在战斗中隐藏物品"
L["TooltipItemHideInDungeon"] = "仅在地下城中隐藏物品"
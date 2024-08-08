if (GAME_LOCALE or GetLocale()) ~= "zhTW" then
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
L["TooltipUnitHideType"] = "在單位上隱藏"
L["None"] = "無"
L["Enemies"] = "敵人"
L["Friendly"] = "友好"
L["Both"] = "兩者"
L["TooltipOFF"] = "關閉"
L["TooltipON"] = "開啟"

L["TooltipUnitHideInCombat"] = "僅在戰鬥中隱藏單位"
L["TooltipUnitHideInDungeon"] = "僅在地下城中隱藏單位"

--Spell
L["TooltipSpellHideType"] = "在法術上隱藏"

L["TooltipSpellHideInCombat"] = "僅在戰鬥中隱藏法術"
L["TooltipSpellHideInDungeon"] = "僅在地下城中隱藏法術"

--Item
L["TooltipItemHideType"] = "在物品上隱藏"

L["TooltipItemHideInCombat"] = "僅在戰鬥中隱藏物品"
L["TooltipItemHideInDungeon"] = "僅在地下城中隱藏物品"